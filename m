Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1AE6B7D2C
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 03:39:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x19-v6so7171466pfh.15
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 00:39:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18-v6sor1321394pgp.3.2018.09.07.00.39.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 00:39:36 -0700 (PDT)
From: Omar Sandoval <osandov@osandov.com>
Subject: [PATCH v6 0/6] Btrfs: implement swap file support
Date: Fri,  7 Sep 2018 00:39:14 -0700
Message-Id: <cover.1536305017.git.osandov@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-btrfs@vger.kernel.org
Cc: kernel-team@fb.com, linux-mm@kvack.org

From: Omar Sandoval <osandov@fb.com>

Hi,

This series implements swap file support for Btrfs.

Compared to v5 [1], this is pretty much feature-complete. It now
supports:

- Balance (skips block groups containing an active swap file)
- Resize (error if trying to shrink past a block group containing an
  active swap file, allowed otherwise)
- Device delete/replace (as long as the device in question does not
  contain an active swap file)

This implementation Chris and I came up with is much cleaner than my
earlier ideas: instead of adding any counters to struct
btrfs_block_group_cache or struct btrfs_device, we just have a small
red-black tree of block groups and devices which contain an active
swapfile.

I updated the xfstests for this series [2] to test this new
functionality, and put it through the same tests as v5.

Based on v4.19-rc2, please take a look.

Thanks!

1: https://www.spinics.net/lists/linux-btrfs/msg81550.html
2: https://github.com/osandov/xfstests/tree/btrfs-swap

Omar Sandoval (6):
  mm: split SWP_FILE into SWP_ACTIVATED and SWP_FS
  mm: export add_swap_extent()
  vfs: update swap_{,de}activate documentation
  Btrfs: prevent ioctls from interfering with a swap file
  Btrfs: rename get_chunk_map() and make it non-static
  Btrfs: support swap files

 Documentation/filesystems/Locking |  17 +-
 Documentation/filesystems/vfs.txt |  12 +-
 fs/btrfs/ctree.h                  |  24 +++
 fs/btrfs/dev-replace.c            |   8 +
 fs/btrfs/disk-io.c                |   4 +
 fs/btrfs/inode.c                  | 316 ++++++++++++++++++++++++++++++
 fs/btrfs/ioctl.c                  |  31 ++-
 fs/btrfs/relocation.c             |  18 +-
 fs/btrfs/volumes.c                |  71 +++++--
 fs/btrfs/volumes.h                |   9 +
 include/linux/swap.h              |  13 +-
 mm/page_io.c                      |   6 +-
 mm/swapfile.c                     |  14 +-
 13 files changed, 492 insertions(+), 51 deletions(-)

-- 
2.18.0
