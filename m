Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCA4A6B0038
	for <linux-mm@kvack.org>; Fri,  7 Oct 2016 17:09:13 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u84so35203417pfj.1
        for <linux-mm@kvack.org>; Fri, 07 Oct 2016 14:09:13 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n9si18446948pac.82.2016.10.07.14.09.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Oct 2016 14:09:12 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v5 00/17] re-enable DAX PMD support
Date: Fri,  7 Oct 2016 15:08:47 -0600
Message-Id: <1475874544-24842-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
locking.  This series allows DAX PMDs to participate in the DAX radix tree
based locking scheme so that they can be re-enabled.

Dave, can you please take this through the XFS tree as we discussed during
the v4 review?

Changes since v4:
 - Reworked the DAX flags handling to simplify things and get rid of
   RADIX_DAX_PTE. (Jan & Christoph)
 - Moved RADIX_DAX_* macros to be inline functions in include/linux/dax.h.
   (Christoph)
 - Got rid of unneeded macros RADIX_DAX_HZP_ENTRY() and
   RADIX_DAX_EMPTY_ENTRY(), and instead just pass arbitrary flags to
   radix_dax_entry().
 - Re-ordered the arguments to dax_wake_mapping_entry_waiter() to be more
   consistent with the rest of the code. (Jan)
 - Moved radix_dax_order() inside of the #ifdef CONFIG_FS_DAX_PMD block.
   This was causing a build error on various systems that don't define
   PMD_SHIFT.
 - Patch 5 fixes what I believe is a missing error return in
   ext2_iomap_end().
 - Fixed the page_start calculation for PMDs that was previously found in
   dax_entry_start().  (Jan)  This code is now included directly in
   dax_entry_waitqueue().  (Christoph)
 - dax_entry_waitqueue() now sets up the struct exceptional_entry_key() of
   the caller as a service to reduce code duplication. (Christoph)
 - In grab_mapping_entry() we now hold the radix tree entry lock for PMD
   downgrades while we release the tree_lock and do an
   unmap_mapping_range().  (Jan)
 - Removed our last BUG_ON() in dax.c, replacing it with a WARN_ON_ONCE()
   and an error return.
 - The dax_iomap_fault() and dax_iomap_pmd_fault() handlers both now call
   ops->iomap_end() to ensure that we properly balance the
   ops->iomap_begin() calls with respect to locking, allocations, etc.
   (Jan)
 - Removed __GFP_FS from the vmf.gfp_mask used in dax_iomap_pmd_fault().
   (Jan)

Thank you again to Jan, Christoph and Dave for their review feedback.

Here are some related things that are not included in this patch set, but
which I plan on doing in the near future:
 - Add tracepoint support for the PTE and PMD based DAX fault handlers.
   (Dave)
 - Move the DAX 4k zero page handling to use a single 4k zero page instead
   of allocating pages on demand.  This will mirror the way that things are
   done for the 2 MiB case, and will reduce the amount of memory we use
   when reading 4k holes in DAX.
 - Change the API to the PMD fault hanlder so it takes a vmf, and at a
   layer above DAX make sure that the vmf.gfp_mask given to DAX for both
   PMD and PTE faults doesn't include __GFP_FS. (Jan)

These work items will happen after review & integration with Jan's patch
set for DAX radix tree cleaning.

This series was built upon xfs/xfs-4.9-reflink with PMD performance fixes
from Toshi Kani and Dan Williams.  Dan's patch has already been merged for
v4.8, and Toshi's patches are currently queued in Andrew Morton's mm tree
for v4.9 inclusion.  These patches are not needed for correct operation,
only for good performance.

Here is a tree containing my changes:
https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_pmd_v5

This tree has passed xfstests for ext2, ext4 and XFS both with and without
DAX, and has passed targeted testing where I inserted, removed and flushed
DAX PTEs and PMDs in every combination I could think of.

Previously reported performance numbers:

In some simple mmap I/O testing with FIO the use of PMD faults more than
doubles I/O performance as compared with PTE faults.  Here is the FIO
script I used for my testing:

  [global]
  bs=4k
  size=2G
  directory=/mnt/pmem0
  ioengine=mmap
  [randrw]
  rw=randrw

Here are the performance results with XFS using only pte faults:
   READ: io=1022.7MB, aggrb=557610KB/s, minb=557610KB/s, maxb=557610KB/s, mint=1878msec, maxt=1878msec
  WRITE: io=1025.4MB, aggrb=559084KB/s, minb=559084KB/s, maxb=559084KB/s, mint=1878msec, maxt=1878msec

Here are performance numbers for that same test using PMD faults:
   READ: io=1022.7MB, aggrb=1406.7MB/s, minb=1406.7MB/s, maxb=1406.7MB/s, mint=727msec, maxt=727msec
  WRITE: io=1025.4MB, aggrb=1410.4MB/s, minb=1410.4MB/s, maxb=1410.4MB/s, mint=727msec, maxt=727msec

This was done on a random lab machine with a PMEM device made from memmap'd
RAM.  To get XFS to use PMD faults, I did the following:

  mkfs.xfs -f -d su=2m,sw=1 /dev/pmem0
  mount -o dax /dev/pmem0 /mnt/pmem0
  xfs_io -c "extsize 2m" /mnt/pmem0

Ross Zwisler (17):
  ext4: allow DAX writeback for hole punch
  ext4: tell DAX the size of allocation holes
  dax: remove buffer_size_valid()
  ext2: remove support for DAX PMD faults
  ext2: return -EIO on ext2_iomap_end() failure
  dax: make 'wait_table' global variable static
  dax: remove the last BUG_ON() from fs/dax.c
  dax: consistent variable naming for DAX entries
  dax: coordinate locking for offsets in PMD range
  dax: remove dax_pmd_fault()
  dax: correct dax iomap code namespace
  dax: add dax_iomap_sector() helper function
  dax: dax_iomap_fault() needs to call iomap_end()
  dax: move RADIX_DAX_* defines to dax.h
  dax: add struct iomap based DAX PMD support
  xfs: use struct iomap based DAX PMD fault path
  dax: remove "depends on BROKEN" from FS_DAX_PMD

 fs/Kconfig          |   1 -
 fs/dax.c            | 718 ++++++++++++++++++++++++++++------------------------
 fs/ext2/file.c      |  35 +--
 fs/ext2/inode.c     |   4 +-
 fs/ext4/inode.c     |   7 +-
 fs/xfs/xfs_aops.c   |  26 +-
 fs/xfs/xfs_aops.h   |   3 -
 fs/xfs/xfs_file.c   |  10 +-
 include/linux/dax.h |  60 ++++-
 mm/filemap.c        |   6 +-
 10 files changed, 466 insertions(+), 404 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
