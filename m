Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 26F4C6B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 15:49:17 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id e127so17653919pfe.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 12:49:17 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 29si7283898pft.41.2016.02.10.12.49.16
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 12:49:16 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 0/2] DAX bdev fixes - move flushing calls to FS
Date: Wed, 10 Feb 2016 13:48:54 -0700
Message-Id: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

During testing of raw block devices + DAX I noticed that the struct
block_device that we were using for DAX operations was incorrect.  For the
fault handlers, etc. we can just get the correct bdev via get_block(),
which is passed in as a function pointer, but for the *sync code and for
sector zeroing we don't have access to get_block().  This is also an issue
for XFS real-time devices, whenever we get those working.

Patch one of this series fixes the DAX sector zeroing code by explicitly
passing in a valid struct block_device.

Patch two of this series fixes DAX *sync support by moving calls to
dax_writeback_mapping_range() out of filemap_write_and_wait_range() and
into the filesystem/block device ->writepages function so that it can
supply us with a valid block device. This also fixes DAX code to properly
flush caches in response to sync(2).

Thanks to Jan Kara for his initial draft of patch 2:
https://lkml.org/lkml/2016/2/9/485

Here are the changes that I've made to that patch:

1) For DAX mappings, only return after calling
dax_writeback_mapping_range() if we encountered an error.  In the non-error
case we still need to write back normal pages, else we lose metadata
updates. 

2) In dax_writeback_mapping_range(), move the new check for 
        if (!mapping->nrexceptional || wbc->sync_mode != WB_SYNC_ALL)
above the i_blkbits check.  In my testing I found cases where
dax_writeback_mapping_range() was called for inodes with i_blkbits !=
PAGE_SHIFT - I'm assuming these are internal metadata inodes?  They have no
exceptional DAX entries to flush, so we have no work to do, but if we
return error from the i_blkbits check we will fail the overall writeback
operation.  Please let me know if it seems wrong for us to be seeing inodes
set to use DAX but with i_blkbits != PAGE_SHIFT and I'll get more info.

3) In filemap_write_and_wait() and filemap_write_and_wait_range(), continue
the writeback in the case that DAX is enabled but we only have a nonzero
mapping->nrpages.  As with 1) and 2), I believe this is necessary to
properly writeback metadata changes.  If this sounds wrong, please let me
know and I'll get more info.

A working tree can be found here:
https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=fsync_bdev_v2

Ross Zwisler (2):
  dax: supply DAX clearing code with correct bdev
  dax: move writeback calls into the filesystems

 fs/block_dev.c         | 16 +++++++++++++++-
 fs/dax.c               | 22 ++++++++++++----------
 fs/ext2/inode.c        | 17 +++++++++++++++--
 fs/ext4/inode.c        |  7 +++++++
 fs/xfs/xfs_aops.c      | 11 ++++++++++-
 fs/xfs/xfs_aops.h      |  1 +
 fs/xfs/xfs_bmap_util.c |  3 ++-
 include/linux/dax.h    |  8 +++++---
 mm/filemap.c           | 12 ++++--------
 9 files changed, 71 insertions(+), 26 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
