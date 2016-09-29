Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A44F6B0038
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 18:49:35 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n24so179225850pfb.0
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 15:49:35 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id d86si16422436pfe.90.2016.09.29.15.49.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 15:49:34 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 00/12] re-enable DAX PMD support
Date: Thu, 29 Sep 2016 16:49:18 -0600
Message-Id: <1475189370-31634-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
locking.  This series allows DAX PMDs to participate in the DAX radix tree
based locking scheme so that they can be re-enabled.

Ted, can you please take the ext2 + ext4 patches through your tree?  Dave,
can you please take the rest through the XFS tree?

Changes since v3:
 - Corrected dax iomap code namespace for functions defined in fs/dax.c.
   (Dave Chinner)
 - Added leading "dax" namespace to new static functions in fs/dax.c.
   (Dave Chinner)
 - Made all DAX PMD code in fs/dax.c conditionally compiled based on
   CONFIG_FS_DAX_PMD.  Otherwise a stub in include/linux/dax.h that just
   returns VM_FAULT_FALLBACK will be used.  (Dave Chinner)
 - Removed dynamic debugging messages from DAX PMD fault path.  Debugging
   tracepoints will be added later to both the PTE and PMD paths via a
   later patch set. (Dave Chinner)
 - Added a comment to ext2_dax_vm_ops explaining why we don't support DAX
   PMD faults in ext2. (Dave Chinner)

This was built upon xfs/for-next with PMD performance fixes from Toshi Kani
and Dan Williams.  Dan's patch has already been merged for v4.8, and
Toshi's patches are currently queued in Andrew Morton's mm tree for v4.9
inclusion.

Here is a tree containing my changes and all the fixes that I've been testing:
https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_pmd_v4

This tree has passed xfstests for ext2, ext4 and XFS both with and without DAX,
and has passed targeted testing where I inserted, removed and flushed DAX PTEs
and PMDs in every combination I could think of.

Previously reported performance numbers:

In some simple mmap I/O testing with FIO the use of PMD faults more than
doubles I/O performance as compared with PTE faults.  Here is the FIO script I
used for my testing:

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

Ross Zwisler (12):
  ext4: allow DAX writeback for hole punch
  ext4: tell DAX the size of allocation holes
  dax: remove buffer_size_valid()
  ext2: remove support for DAX PMD faults
  dax: make 'wait_table' global variable static
  dax: consistent variable naming for DAX entries
  dax: coordinate locking for offsets in PMD range
  dax: remove dax_pmd_fault()
  dax: correct dax iomap code namespace
  dax: add struct iomap based DAX PMD support
  xfs: use struct iomap based DAX PMD fault path
  dax: remove "depends on BROKEN" from FS_DAX_PMD

 fs/Kconfig          |   1 -
 fs/dax.c            | 650 +++++++++++++++++++++++++++-------------------------
 fs/ext2/file.c      |  35 +--
 fs/ext4/inode.c     |   7 +-
 fs/xfs/xfs_aops.c   |  25 +-
 fs/xfs/xfs_aops.h   |   3 -
 fs/xfs/xfs_file.c   |  10 +-
 include/linux/dax.h |  48 +++-
 mm/filemap.c        |   6 +-
 9 files changed, 402 insertions(+), 383 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
