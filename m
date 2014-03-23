Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 279ED6B00C9
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:08:59 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kp14so4480002pab.5
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:08:58 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id zw7si3963436pac.29.2014.03.23.12.08.57
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:08:58 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v7 00/22] Support ext4 on NV-DIMMs
Date: Sun, 23 Mar 2014 15:08:26 -0400
Message-Id: <cover.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

One of the primary uses for NV-DIMMs is to expose them as a block device
and use a filesystem to store files on the NV-DIMM.  While that works,
it currently wastes memory and CPU time buffering the files in the page
cache.  We have support in ext2 for bypassing the page cache, but it
has some races which are unfixable in the current design.  This series
of patches rewrite the underlying support, and add support for direct
access to ext4.

This iteration of the patchset rebases to Linus' 3.14-rc7 (plus Kirill's
patches in linux-next http://marc.info/?l=linux-mm&m=139206489208546&w=2)
and fixes several bugs:

 - Initialise cow_page in do_page_mkwrite() (Matthew Wilcox)
 - Clear new or unwritten blocks in page fault handler (Matthew Wilcox)
 - Only call get_block when necessary (Matthew Wilcox)
 - Reword Kconfig options (Matthew Wilcox / Vishal Verma)
 - Fix a race between page fault and truncate (Matthew Wilcox)
 - Fix a race between fault-for-read and fault-for-write (Matthew Wilcox)
 - Zero the correct bytes in dax_new_buf() (Toshi Kani)
 - Add DIO_LOCKING to an invocation of dax_do_io in ext4 (Ross Zwisler)

Relative to the last patchset, I folded the 'Add reporting of major faults'
patch into the patch that adds the DAX page fault handler.

The v6 patchset had seven additional xfstests failures.  This patchset
now passes approximately as many xfstests as ext4 does on a ramdisk.

Matthew Wilcox (21):
  Fix XIP fault vs truncate race
  Allow page fault handlers to perform the COW
  axonram: Fix bug in direct_access
  Change direct_access calling convention
  Introduce IS_DAX(inode)
  Replace XIP read and write with DAX I/O
  Replace the XIP page fault handler with the DAX page fault handler
  Replace xip_truncate_page with dax_truncate_page
  Remove mm/filemap_xip.c
  Remove get_xip_mem
  Replace ext2_clear_xip_target with dax_clear_blocks
  ext2: Remove ext2_xip_verify_sb()
  ext2: Remove ext2_use_xip
  ext2: Remove xip.c and xip.h
  Remove CONFIG_EXT2_FS_XIP and rename CONFIG_FS_XIP to CONFIG_FS_DAX
  ext2: Remove ext2_aops_xip
  Get rid of most mentions of XIP in ext2
  xip: Add xip_zero_page_range
  ext4: Make ext4_block_zero_page_range static
  ext4: Fix typos
  brd: Rename XIP to DAX

Ross Zwisler (1):
  ext4: Add DAX functionality

 Documentation/filesystems/Locking  |   3 -
 Documentation/filesystems/dax.txt  |  84 ++++++
 Documentation/filesystems/ext4.txt |   2 +
 Documentation/filesystems/xip.txt  |  68 -----
 arch/powerpc/sysdev/axonram.c      |   8 +-
 drivers/block/Kconfig              |  13 +-
 drivers/block/brd.c                |  22 +-
 drivers/s390/block/dcssblk.c       |  19 +-
 fs/Kconfig                         |  21 +-
 fs/Makefile                        |   1 +
 fs/dax.c                           | 509 +++++++++++++++++++++++++++++++++++++
 fs/exofs/inode.c                   |   1 -
 fs/ext2/Kconfig                    |  11 -
 fs/ext2/Makefile                   |   1 -
 fs/ext2/ext2.h                     |   9 +-
 fs/ext2/file.c                     |  45 +++-
 fs/ext2/inode.c                    |  37 +--
 fs/ext2/namei.c                    |  13 +-
 fs/ext2/super.c                    |  48 ++--
 fs/ext2/xip.c                      |  91 -------
 fs/ext2/xip.h                      |  26 --
 fs/ext4/ext4.h                     |   8 +-
 fs/ext4/file.c                     |  53 +++-
 fs/ext4/indirect.c                 |  19 +-
 fs/ext4/inode.c                    |  94 ++++---
 fs/ext4/namei.c                    |  10 +-
 fs/ext4/super.c                    |  39 ++-
 fs/open.c                          |   5 +-
 include/linux/blkdev.h             |   4 +-
 include/linux/fs.h                 |  49 +++-
 include/linux/mm.h                 |   2 +
 mm/Makefile                        |   1 -
 mm/fadvise.c                       |   6 +-
 mm/filemap.c                       |   6 +-
 mm/filemap_xip.c                   | 483 -----------------------------------
 mm/madvise.c                       |   2 +-
 mm/memory.c                        |  45 +++-
 37 files changed, 984 insertions(+), 874 deletions(-)
 create mode 100644 Documentation/filesystems/dax.txt
 delete mode 100644 Documentation/filesystems/xip.txt
 create mode 100644 fs/dax.c
 delete mode 100644 fs/ext2/xip.c
 delete mode 100644 fs/ext2/xip.h
 delete mode 100644 mm/filemap_xip.c

-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
