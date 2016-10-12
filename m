Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id F13EE6B0038
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 18:50:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h24so2915425pfh.0
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 15:50:28 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m6si9442179pab.331.2016.10.12.15.50.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 15:50:28 -0700 (PDT)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v6 00/17] re-enable DAX PMD support
Date: Wed, 12 Oct 2016 16:50:05 -0600
Message-Id: <20161012225022.15507-1-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-xfs@vger.kernel.org

DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
locking.  This series allows DAX PMDs to participate in the DAX radix tree
based locking scheme so that they can be re-enabled.

For now I'm still using the same baseline for this series as I did with v5.
I'll update the baseline once v4.9-rc1 is released, dropping whatever patches
have already been merged.

Changes since v5:
 - Reworked the way that DAX radix tree flags were handled. The old
   handling was correct but a bit hard for the reader to parse.  Hopefully
   this new way is more readable & maintainable.  (Jan & Christoph)
 - Made the definition of dax_radix_order() conditional based on
   CONFIG_FS_DAX_PMD.  This was necessary because PMD_SHIFT isn't defined
   on all systems. (kbuild)
 - Dropped the incorrect patch "ext2: return -EIO on ext2_iomap_end()
   failure".  (Jan)
 - A few error path fixes in grab_mapping_entry().  (Jan)
 - A few more comments in grab_mapping_entry(),
   dax_wake_mapping_entry_waiter() and dax_insert_mapping_entry(). (Jan)
 - Removed the 'inline' keyword from dax_iomap_sector().  (Dan)
 - Cleaned up the path through ops->iomap_end() in both dax_iomap_fault()
   and dax_iomap_pmd_fault().  We now pass 0 for the 'written' argument on
   error conditions.  (Jan & Christoph)
 - Improved the naming of 'size' to 'max_pgoff' in dax_iomap_pmd_fault().
   (Jan)

Thank you to Jan and Christoph for their review feedback.

Here is a tree containing my changes:
https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_pmd_v6

This tree has passed xfstests for ext2, ext4 and XFS both with and without
DAX, and has passed targeted testing where I inserted, removed and flushed
DAX PTEs and PMDs in every combination I could think of.

Ross Zwisler (17):
  ext4: allow DAX writeback for hole punch
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
 fs/dax.c            | 825 +++++++++++++++++++++++++++++-----------------------
 fs/ext2/file.c      |  35 +--
 fs/ext4/inode.c     |   7 +-
 fs/xfs/xfs_aops.c   |  26 +-
 fs/xfs/xfs_aops.h   |   3 -
 fs/xfs/xfs_file.c   |  10 +-
 include/linux/dax.h |  58 +++-
 mm/filemap.c        |   5 +-
 9 files changed, 538 insertions(+), 432 deletions(-)

-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
