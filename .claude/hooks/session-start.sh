#!/bin/bash
# Ensures the gstack skill (github.com/garrytan/gstack) is installed under
# ~/.claude/skills/gstack for Claude Code on the web sessions. Best-effort:
# never fails the session on network or setup errors.
set -uo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

SKILL_DIR="$HOME/.claude/skills/gstack"
REPO_URL="https://github.com/garrytan/gstack.git"

if [ -d "$SKILL_DIR/.git" ]; then
  # Already cloned from a previous session - update in place.
  if ! git -C "$SKILL_DIR" fetch --depth 1 origin 2>&1; then
    echo "gstack skill: fetch failed, continuing with existing copy" >&2
  elif ! git -C "$SKILL_DIR" reset --hard FETCH_HEAD 2>&1; then
    echo "gstack skill: update failed, continuing with existing copy" >&2
  fi
elif [ -e "$SKILL_DIR" ]; then
  # Something's there but it's not a git clone (e.g. a dev symlink) - leave it alone.
  echo "gstack skill: $SKILL_DIR exists and is not a git checkout, skipping install" >&2
else
  mkdir -p "$HOME/.claude/skills"
  if ! git clone --single-branch --depth 1 "$REPO_URL" "$SKILL_DIR" 2>&1; then
    echo "gstack skill: clone failed, continuing without it" >&2
    exit 0
  fi
fi

if [ -x "$SKILL_DIR/setup" ]; then
  if ! (cd "$SKILL_DIR" && ./setup) 2>&1; then
    echo "gstack skill: setup script failed, continuing" >&2
  fi
fi

exit 0
