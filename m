Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 052E828025A
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 16:48:15 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id cg13so44754934pac.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 13:48:14 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id ez7si4297005pab.6.2016.09.27.13.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 13:48:13 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v3 00/11] re-enable DAX PMD support
Date: Tue, 27 Sep 2016 14:47:51 -0600
Message-Id: <1475009282-9818-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
locking.  This series allows DAX PMDs to participate in the DAX radix tree
based locking scheme so that they can be re-enabled.

Jan and Christoph, can you please help review these changes?

Andrew, when the time is right can you please push these changes to Linus via
the -mm tree?

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

Changes since v2:
- Removed the struct buffer_head + get_block_t based dax_pmd_fault() handler.
  All DAX PMD faults will now happen via the new struct iomap based
  iomap_dax_pmd_fault().
- Added a new struct iomap based PMD path which is now used by XFS.
- Now that it is using struct iomap, ext2 no longer needs to modified so that
  ext2_get_block() will give us the size of a hole.
- Remove support for DAX PMD faults for ext2.  I can't get them to reliably
  happen in my testing.
- Removed unused xfs_get_blocks_dax_fault() wrapper
- Added a bunch of comments around my changes in dax.c.

This was built upon xfs/for-next with PMD performance fixes from Toshi Kani and
Dan Williams.  Dan's patch has already been merged for v4.8, and Toshi's
patches are currently queued in Andrew Morton's mm tree for v4.9 inclusion.

Here is a tree containing my changes and all the fixes that I've been testing:
https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_pmd_v3

Ross Zwisler (11):
  ext4: allow DAX writeback for hole punch
  ext4: tell DAX the size of allocation holes
  dax: remove buffer_size_valid()
  ext2: remove support for DAX PMD faults
  dax: make 'wait_table' global variable static
  dax: consistent variable naming for DAX entries
  dax: coordinate locking for offsets in PMD range
  dax: remove dax_pmd_fault()
  dax: add struct iomap based DAX PMD support
  xfs: use struct iomap based DAX PMD fault path
  dax: remove "depends on BROKEN" from FS_DAX_PMD

 fs/Kconfig          |   1 -
 fs/dax.c            | 696 +++++++++++++++++++++++++++++-----------------------
 fs/ext2/file.c      |  24 +-
 fs/ext4/inode.c     |   7 +-
 fs/xfs/xfs_aops.c   |  25 +-
 fs/xfs/xfs_aops.h   |   3 -
 fs/xfs/xfs_file.c   |   2 +-
 include/linux/dax.h |  37 ++-
 mm/filemap.c        |   6 +-
 9 files changed, 434 insertions(+), 367 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
