Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0066B0038
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:01 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id kp14so1924740pab.23
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:01 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ez5si5304758pab.251.2014.01.15.17.24.59
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:25:00 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 00/22] Rewrite XIP code and add XIP support to ext4
Date: Wed, 15 Jan 2014 20:24:18 -0500
Message-Id: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

This series of patches add support for XIP to ext4.  Unfortunately,
it turns out to be necessary to rewrite the existing XIP support code
first due to races that are unfixable in the current design.

Since v4 of this patchset, I've improved the documentation, fixed a
couple of warnings that a newer version of gcc emitted, and fixed a
bug where we would read/write the wrong address for I/Os that were not
aligned to PAGE_SIZE.

I've dropped the PMD fault patch from this set since there are some
places where we would need to split a PMD page and there's no way to do
that right now.  In its place, I've added a patch which attempts to add
support for unwritten extents.  I'm still in two minds about this; on the
one hand, it's clearly a win for reads and writes.  On the other hand,
it adds a lot of complexity, and it probably isn't a win for pagefaults.

Patch 2 wants careful review from the MM people.

Matthew Wilcox (21):
  Fix XIP fault vs truncate race
  Allow page fault handlers to perform the COW
  axonram: Fix bug in direct_access
  Change direct_access calling convention
  Introduce IS_XIP(inode)
  Treat XIP like O_DIRECT
  Rewrite XIP page fault handling
  Change xip_truncate_page to take a get_block parameter
  Remove mm/filemap_xip.c
  Remove get_xip_mem
  Replace ext2_clear_xip_target with xip_clear_blocks
  ext2: Remove ext2_xip_verify_sb()
  ext2: Remove ext2_use_xip
  ext2: Remove xip.c and xip.h
  Remove CONFIG_EXT2_FS_XIP
  ext2: Remove ext2_aops_xip
  xip: Add xip_zero_page_range
  ext4: Make ext4_block_zero_page_range static
  ext4: Fix typos
  xip: Add reporting of major faults
  XIP: Add support for unwritten extents

Ross Zwisler (1):
  ext4: Add XIP functionality

 Documentation/filesystems/Locking  |   3 -
 Documentation/filesystems/ext4.txt |   2 +
 Documentation/filesystems/xip.txt  | 126 +++++-----
 arch/powerpc/sysdev/axonram.c      |   8 +-
 drivers/block/brd.c                |   8 +-
 drivers/s390/block/dcssblk.c       |  19 +-
 fs/Kconfig                         |  21 +-
 fs/Makefile                        |   1 +
 fs/exofs/inode.c                   |   1 -
 fs/ext2/Kconfig                    |  11 -
 fs/ext2/Makefile                   |   1 -
 fs/ext2/ext2.h                     |   1 -
 fs/ext2/file.c                     |  43 +++-
 fs/ext2/inode.c                    |  35 +--
 fs/ext2/namei.c                    |   9 +-
 fs/ext2/super.c                    |  38 ++-
 fs/ext2/xip.c                      |  91 -------
 fs/ext2/xip.h                      |  26 --
 fs/ext4/ext4.h                     |   4 +-
 fs/ext4/file.c                     |  53 +++-
 fs/ext4/indirect.c                 |  19 +-
 fs/ext4/inode.c                    | 106 +++++---
 fs/ext4/namei.c                    |  10 +-
 fs/ext4/super.c                    |  39 ++-
 fs/open.c                          |   5 +-
 fs/xip.c                           | 428 ++++++++++++++++++++++++++++++++
 include/linux/blkdev.h             |   4 +-
 include/linux/fs.h                 |  47 +++-
 include/linux/mm.h                 |   2 +
 mm/Makefile                        |   1 -
 mm/fadvise.c                       |   6 +-
 mm/filemap.c                       |   6 +-
 mm/filemap_xip.c                   | 483 -------------------------------------
 mm/madvise.c                       |   2 +-
 mm/memory.c                        |  19 +-
 35 files changed, 851 insertions(+), 827 deletions(-)
 delete mode 100644 fs/ext2/xip.c
 delete mode 100644 fs/ext2/xip.h
 create mode 100644 fs/xip.c
 delete mode 100644 mm/filemap_xip.c

-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
