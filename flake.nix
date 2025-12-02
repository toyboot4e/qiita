{
  description = "A basic flake with a shell";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        # qiita-cli = pkgs.mkYarnPackage {
        #   pname = "qiita-cli";
        #   version = "2.2.0";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "increments";
        #     repo = "qiita-cli";
        #     tag = "v1.6.2";
        #     hash = "sha256-moJj304IywajBgFz0wNMspWXqdOQ2YFY4E1uZbbzfxg=";
        #   };
        #   # npmDepsHash = "sha256-ufG7Fq5D2SOzUp8KYRYUB5tYJYoADuhK+2zDfG0a3ks";
        #   # npmFlags = [ "--ignore-scripts" ];
        #   # NODE_OPTIONS = "--openssl-legacy-provider";
        # };
      in
      {
        apps.build = flake-utils.lib.mkApp {
          drv = pkgs.writeShellApplication {
            name = "build-command";
            runtimeInputs = with pkgs; [
              (emacs.pkgs.withPackages (
                epkgs: with epkgs; [
                  # org
                ]
              ))
              nodePackages.prettier
            ];
            text = ''
              emacs -Q --script "./build.el" -- "--release"
            '';
          };
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            zenn-cli
            # pandoc
            # texlive-full
          ];

          shellHook = ''
            export PANDOC_TEMPLATES="$HOME/.pandoc/templates"
            # Download eivogel template if not already present
            if [ ! -f "$HOME/.pandoc/templates/eivogel.latex" ]; then
              echo "Downloading eivogel template..."
              mkdir -p $HOME/.pandoc/templates
              curl -L https://raw.githubusercontent.com/eivogel/eivogel/master/eivogel.latex -o $HOME/.pandoc/templates/eivogel.latex
            fi
          '';
        };
      }
    );
}
