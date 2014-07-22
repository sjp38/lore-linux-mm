Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 84D586B0062
	for <linux-mm@kvack.org>; Tue, 22 Jul 2014 15:48:47 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so169858pdb.3
        for <linux-mm@kvack.org>; Tue, 22 Jul 2014 12:48:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id rq15si52299pac.50.2014.07.22.12.48.45
        for <linux-mm@kvack.org>;
        Tue, 22 Jul 2014 12:48:45 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v8 00/22] Support ext4 on NV-DIMMs
Date: Tue, 22 Jul 2014 15:47:48 -0400
Message-Id: <cover.1406058387.git.matthew.r.wilcox@intel.com>
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

I would particularly welcome feedback from mm people on patch 5 ("Add
vm_replace_mixed()") and from fs people on patch 7 ("Add copy_to_iter(),
copy_from_iter() and iov_iter_zero()").

This iteration of the patchset rebases to 3.16-rc6 and makes substantial
changes based on Jan Kara's feedback:

 - Handles errors in copy_user_bh()
 - Changes calling convention for dax_get_addr() / dax_get_pfn() to take a
   blkbits argument instead of an inode argument
 - Cache inode->i_blkbits in a local variable
 - Rename file offset to 'pos' to fit the rest of the VFS
 - Added a FIXME to fall back to buffered I/O if the filesystem doesn't
   support filling a hole from within the direct I/O path.  Mysterious
   and complex are the ways of get_block implementations.
 - Moved the call to inode_dio_done() to after end_io() to fix a race
 - Added a comment about why we have to recheck i_size under the page lock
 - Use vm_insert_page() in the COW path instead of returning VM_FAULT_COWED
 - Handle errors coming back from dax_get_pfn() correctly in do_dax_fault()
 - Removes zero pages from the process' address space before trying to
   replace them with the PFN of the newly allocated block
 - Factor out bdev_direct_access() to support partitioning properly
 - Rework the i_mmap_mutex locking to remove an inversion vs the page lock
 - Make the ext2 rename of -o xip to -o dax more graceful
 - Only update file mtime/ctime on a write fault, not a read fault


Matthew Wilcox (21):
  Fix XIP fault vs truncate race
  Allow page fault handlers to perform the COW
  axonram: Fix bug in direct_access
  Change direct_access calling convention
  Add vm_replace_mixed()
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
 Documentation/filesystems/xip.txt  |  68 -----
 arch/powerpc/sysdev/axonram.c      |  14 +-
 drivers/block/Kconfig              |  13 +-
 drivers/block/brd.c                |  22 +-
 drivers/s390/block/dcssblk.c       |  19 +-
 fs/Kconfig                         |  21 +-
 fs/Makefile                        |   1 +
 fs/block_dev.c                     |  28 +++
 fs/dax.c                           | 503 +++++++++++++++++++++++++++++++++++++
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
 fs/ext4/inode.c                    |  51 ++--
 fs/ext4/namei.c                    |  10 +-
 fs/ext4/super.c                    |  39 ++-
 fs/open.c                          |   5 +-
 include/linux/blkdev.h             |   6 +-
 include/linux/fs.h                 |  49 +++-
 include/linux/mm.h                 |   9 +-
 include/linux/uio.h                |   3 +
 mm/Makefile                        |   1 -
 mm/fadvise.c                       |   6 +-
 mm/filemap.c                       |   6 +-
 mm/filemap_xip.c                   | 483 -----------------------------------
 mm/iov_iter.c                      | 237 +++++++++++++++--
 mm/madvise.c                       |   2 +-
 mm/memory.c                        |  45 ++--
 40 files changed, 1228 insertions(+), 875 deletions(-)
 create mode 100644 Documentation/filesystems/dax.txt
 delete mode 100644 Documentation/filesystems/xip.txt
 create mode 100644 fs/dax.c
 delete mode 100644 fs/ext2/xip.c
 delete mode 100644 fs/ext2/xip.h
 delete mode 100644 mm/filemap_xip.c

-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
