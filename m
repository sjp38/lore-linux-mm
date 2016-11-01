Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3125C6B02AB
	for <linux-mm@kvack.org>; Tue,  1 Nov 2016 15:54:28 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gg9so119320071pac.6
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 12:54:28 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id ys9si6556151pab.266.2016.11.01.12.54.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 12:54:27 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v9 00/16] re-enable DAX PMD support
Date: Tue,  1 Nov 2016 13:54:02 -0600
Message-Id: <1478030058-1422-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
locking.  This series allows DAX PMDs to participate in the DAX radix tree
based locking scheme so that they can be re-enabled.

Previously we had talked about this series going through the XFS tree, but
Jan has a patch set that will need to build on this series and it heavily
modifies the MM code.  I think he would prefer that series to go through
Andrew Morton's -MM tree, so it probably makes sense for this series to go
through that same tree.

For reference, here is the series from Jan that I was talking about:
https://marc.info/?l=linux-mm&m=147499252322902&w=2

Andrew, can you please pick this up for the v4.10 merge window?
This series is currently based on v4.9-rc3.  I tried to rebase onto a -mm
branch or tag, but couldn't find one that contained the DAX iomap changes
that were merged as part of the v4.9 merge window.  I'm happy to rebase &
test on a v4.9-rc* based -MM branch or tag whenever they are available.

Changes since v8:
- Rebased onto v4.9-rc3.
- Updated the DAX PMD fault path so that on fallback we always check to see
  if we are dealing with a transparent huge page, and if we are we will
  split it.  This was already happening for one of the fallback cases via a
  patch from Toshi, and Jan hit a deadlock in another fallback case where
  the same splitting was needed.  (Jan & Toshi)

This series has passed all my xfstests testing, including the test that was
hitting the deadlock with v8.

Here is a tree containing my changes:
https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_pmd_v9

Ross Zwisler (16):
  ext4: tell DAX the size of allocation holes
  dax: remove buffer_size_valid()
  ext2: remove support for DAX PMD faults
  dax: make 'wait_table' global variable static
  dax: remove the last BUG_ON() from fs/dax.c
  dax: consistent variable naming for DAX entries
  dax: coordinate locking for offsets in PMD range
  dax: remove dax_pmd_fault()
  dax: correct dax iomap code namespace
  dax: add dax_iomap_sector() helper function
  dax: dax_iomap_fault() needs to call iomap_end()
  dax: move RADIX_DAX_* defines to dax.h
  dax: move put_(un)locked_mapping_entry() in dax.c
  dax: add struct iomap based DAX PMD support
  xfs: use struct iomap based DAX PMD fault path
  dax: remove "depends on BROKEN" from FS_DAX_PMD

 fs/Kconfig          |   1 -
 fs/dax.c            | 826 +++++++++++++++++++++++++++++-----------------------
 fs/ext2/file.c      |  35 +--
 fs/ext4/inode.c     |   3 +
 fs/xfs/xfs_aops.c   |  26 +-
 fs/xfs/xfs_aops.h   |   3 -
 fs/xfs/xfs_file.c   |  10 +-
 include/linux/dax.h |  58 +++-
 mm/filemap.c        |   5 +-
 9 files changed, 537 insertions(+), 430 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
