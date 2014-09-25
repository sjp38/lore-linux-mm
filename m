Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 306656B007B
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 16:34:36 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fb1so11847300pad.27
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 13:34:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id md3si5664064pdb.135.2014.09.25.13.34.34
        for <linux-mm@kvack.org>;
        Thu, 25 Sep 2014 13:34:35 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
Date: Thu, 25 Sep 2014 16:33:17 -0400
Message-Id: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

We currently have two unrelated things inside the Linux kernel called
"XIP".  One allows the kernel to run out of flash without being copied
into DRAM, the other allows executables to be run without copying them
into the page cache.  The latter is almost the behaviour we want for
NV-DIMMs, except that we primarily want data to be accessed through
this filesystem, not executables.  We deal with the confusion between
the two XIPs by renaming the second one to DAX (short for Direct Access).

DAX bears some resemblance to its ancestor XIP but fixes many races that
were not relevant for its original use case of storing executables.
The major design change is using the filesystem's get_block routine
instead of a special-purpose ->get_xip_mem() address_space operation.
Further enhancements are planned, such as supporting huge pages, but
this is a useful amount of work to merge before adding more functionality.

This is not the only way to support NV-DIMMs, of course.  People have
written new filesystems to support them, some of which have even seen
the light of day.  We believe it is valuable to support traditional
filesystems such as ext4 and XFS on NV-DIMMs in a more efficient manner
than copying the contents of the NV-DIMM to DRAM.

Patch 1 is a bug fix.  It is obviously correct, and should be included
into 3.18.

Patch 2 starts the transformation by changing how ->direct_access works.
Much code is moved from the drivers and filesystems into the block
layer, and we add the flexibility of being able to map more than one
page at a time.  It would be good to get this patch into 3.18 as it is
useful for people who are pursuing non-DAX approaches to working with
persistent memory.

Patch 3 is also a bug fix, probably worth including in 3.18.

Patches 4-6 are infrastructure for DAX (note that patch 6 is in the
for-next branch of Al Viro's VFS tree).

Patches 7-11 replace the XIP code with its DAX equivalents, transforming
ext2 to use the DAX code as we go.  Note that patch 11 is the
Documentation patch.

Patches 12-18 clean up after the XIP code, removing the infrastructure
that is no longer needed and renaming various XIP things to DAX.
Most of these patches were added after Jan found things he didn't
like in an earlier version of the ext4 patch ... that had been copied
from ext2.  So ext2 i being transformed to do things the same way that
ext4 will later.  The ability to mount ext2 filesystems with the 'xip'
option is retained, although the 'dax' option is now preferred.

Patch 19 adds some DAX infrastructure to support ext4.

Patch 20 adds DAX support to ext4.  It is broadly similar to ext2's DAX
support, but it is more efficient than ext4's due to its support for
unwritten extents.

Patch 21 is another cleanup patch renaming XIP to DAX.

Matthew Wilcox (20):
  axonram: Fix bug in direct_access
  block: Change direct_access calling convention
  mm: Fix XIP fault vs truncate race
  mm: Allow page fault handlers to perform the COW
  vfs,ext2: Introduce IS_DAX(inode)
  vfs: Add copy_to_iter(), copy_from_iter() and iov_iter_zero()
  dax,ext2: Replace XIP read and write with DAX I/O
  dax,ext2: Replace ext2_clear_xip_target with dax_clear_blocks
  dax,ext2: Replace the XIP page fault handler with the DAX page fault
    handler
  dax,ext2: Replace xip_truncate_page with dax_truncate_page
  dax: Replace XIP documentation with DAX documentation
  vfs: Remove get_xip_mem
  ext2: Remove ext2_xip_verify_sb()
  ext2: Remove ext2_use_xip
  ext2: Remove xip.c and xip.h
  vfs,ext2: Remove CONFIG_EXT2_FS_XIP and rename CONFIG_FS_XIP to
    CONFIG_FS_DAX
  ext2: Remove ext2_aops_xip
  ext2: Get rid of most mentions of XIP in ext2
  dax: Add dax_zero_page_range
  brd: Rename XIP to DAX

Ross Zwisler (1):
  ext4: Add DAX functionality

 Documentation/filesystems/Locking  |   3 -
 Documentation/filesystems/dax.txt  |  91 +++++++
 Documentation/filesystems/ext4.txt |   2 +
 Documentation/filesystems/xip.txt  |  68 -----
 MAINTAINERS                        |   6 +
 arch/powerpc/sysdev/axonram.c      |  19 +-
 drivers/block/Kconfig              |  13 +-
 drivers/block/brd.c                |  26 +-
 drivers/s390/block/dcssblk.c       |  21 +-
 fs/Kconfig                         |  21 +-
 fs/Makefile                        |   1 +
 fs/block_dev.c                     |  40 +++
 fs/dax.c                           | 532 +++++++++++++++++++++++++++++++++++++
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
 fs/ext4/file.c                     |  49 +++-
 fs/ext4/indirect.c                 |  18 +-
 fs/ext4/inode.c                    |  89 +++++--
 fs/ext4/namei.c                    |  10 +-
 fs/ext4/super.c                    |  39 ++-
 fs/open.c                          |   5 +-
 include/linux/blkdev.h             |   6 +-
 include/linux/fs.h                 |  49 +++-
 include/linux/mm.h                 |   1 +
 include/linux/uio.h                |   3 +
 mm/Makefile                        |   1 -
 mm/fadvise.c                       |   6 +-
 mm/filemap.c                       |  25 +-
 mm/filemap_xip.c                   | 483 ---------------------------------
 mm/iov_iter.c                      | 237 ++++++++++++++++-
 mm/madvise.c                       |   2 +-
 mm/memory.c                        |  33 ++-
 41 files changed, 1305 insertions(+), 889 deletions(-)
 create mode 100644 Documentation/filesystems/dax.txt
 delete mode 100644 Documentation/filesystems/xip.txt
 create mode 100644 fs/dax.c
 delete mode 100644 fs/ext2/xip.c
 delete mode 100644 fs/ext2/xip.h
 delete mode 100644 mm/filemap_xip.c

-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
