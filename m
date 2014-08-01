Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 008406B0037
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 09:27:51 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so5800461pad.24
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 06:27:51 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id c9si4902164pdn.254.2014.08.01.06.27.50
        for <linux-mm@kvack.org>;
        Fri, 01 Aug 2014 06:27:50 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v9 00/22] Support ext4 on NV-DIMMs
Date: Fri,  1 Aug 2014 09:27:16 -0400
Message-Id: <cover.1406897885.git.willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

One of the primary uses for NV-DIMMs is to expose them as a block device
and use a filesystem to store files on the NV-DIMM.  While that works,
it currently wastes memory and CPU time buffering the files in the page
cache.  We have support in ext2 for bypassing the page cache, but it
has some races which are unfixable in the current design.  This series
of patches rewrite the underlying support, and add support for direct
access to ext4.

This iteration of the patchset rebases to 3.16-rc7 and makes substantial
changes based on feedback from Jan Kara, Boaz Harrosh and Kirill Shutemov:

 - Fixes a double-unlock on i_mmap_mutex
 - Switch the order of calling delete_from_page_cache() and
   unmap_mapping_range() to match the truncate path
 - Make dax_mkwrite a macro (Kirill)
 - Drop vm_replace_mixed(); instead call unmap_mapping_range() before calling
   vm_insert_mixed() (Kirill)
 - Avoid lock inversion between i_mmap_mutex and transaction start (Jan)
 - Move alignment & length checks into bdev_direct_access() (Boaz)
 - Fix bugs in COW code; unfortunately this means reintroducing the knowledge
   that the i_mmap_mutex protects PFNs to the core MM code.

Jan Kara (1):
  ext4: Avoid lock inversion between i_mmap_mutex and transaction start

Matthew Wilcox (20):
  axonram: Fix bug in direct_access
  Change direct_access calling convention
  Fix XIP fault vs truncate race
  Allow page fault handlers to perform the COW
  Introduce IS_DAX(inode)
  Add copy_to_iter(), copy_from_iter() and iov_iter_zero()
  Replace XIP read and write with DAX I/O
  Replace ext2_clear_xip_target with dax_clear_blocks
  Replace the XIP page fault handler with the DAX page fault handler
  Replace xip_truncate_page with dax_truncate_page
  Replace XIP documentation with DAX documentation
  Remove get_xip_mem
  ext2: Remove ext2_xip_verify_sb()
  ext2: Remove ext2_use_xip
  ext2: Remove xip.c and xip.h
  Remove CONFIG_EXT2_FS_XIP and rename CONFIG_FS_XIP to CONFIG_FS_DAX
  ext2: Remove ext2_aops_xip
  Get rid of most mentions of XIP in ext2
  xip: Add xip_zero_page_range
  brd: Rename XIP to DAX

Ross Zwisler (1):
  ext4: Add DAX functionality

 Documentation/filesystems/Locking  |   3 -
 Documentation/filesystems/dax.txt  |  91 +++++++
 Documentation/filesystems/ext4.txt |   2 +
 Documentation/filesystems/xip.txt  |  68 ------
 arch/powerpc/sysdev/axonram.c      |  19 +-
 drivers/block/Kconfig              |  13 +-
 drivers/block/brd.c                |  26 +-
 drivers/s390/block/dcssblk.c       |  21 +-
 fs/Kconfig                         |  21 +-
 fs/Makefile                        |   1 +
 fs/block_dev.c                     |  34 +++
 fs/dax.c                           | 476 ++++++++++++++++++++++++++++++++++++
 fs/exofs/inode.c                   |   1 -
 fs/ext2/Kconfig                    |  11 -
 fs/ext2/Makefile                   |   1 -
 fs/ext2/ext2.h                     |  10 +-
 fs/ext2/file.c                     |  45 +++-
 fs/ext2/inode.c                    |  38 +--
 fs/ext2/namei.c                    |  13 +-
 fs/ext2/super.c                    |  53 ++--
 fs/ext2/xip.c                      |  91 -------
 fs/ext2/xip.h                      |  26 --
 fs/ext4/ext4.h                     |   6 +
 fs/ext4/file.c                     |  53 +++-
 fs/ext4/indirect.c                 |  18 +-
 fs/ext4/inode.c                    |  65 +++--
 fs/ext4/namei.c                    |  10 +-
 fs/ext4/super.c                    |  39 ++-
 fs/open.c                          |   5 +-
 include/linux/blkdev.h             |   6 +-
 include/linux/fs.h                 |  49 +++-
 include/linux/mm.h                 |   1 +
 include/linux/uio.h                |   3 +
 mm/Makefile                        |   1 -
 mm/fadvise.c                       |   6 +-
 mm/filemap.c                       |   6 +-
 mm/filemap_xip.c                   | 483 -------------------------------------
 mm/iov_iter.c                      | 237 ++++++++++++++++--
 mm/madvise.c                       |   2 +-
 mm/memory.c                        |  33 ++-
 40 files changed, 1206 insertions(+), 881 deletions(-)
 create mode 100644 Documentation/filesystems/dax.txt
 delete mode 100644 Documentation/filesystems/xip.txt
 create mode 100644 fs/dax.c
 delete mode 100644 fs/ext2/xip.c
 delete mode 100644 fs/ext2/xip.h
 delete mode 100644 mm/filemap_xip.c

-- 
2.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
