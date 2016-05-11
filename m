Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 632576B025E
	for <linux-mm@kvack.org>; Wed, 11 May 2016 17:09:22 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id xm6so77612574pab.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 14:09:22 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id j9si12334420pan.36.2016.05.11.14.09.21
        for <linux-mm@kvack.org>;
        Wed, 11 May 2016 14:09:21 -0700 (PDT)
From: Vishal Verma <vishal.l.verma@intel.com>
Subject: [PATCH v7 3/6] dax: use sb_issue_zerout instead of calling dax_clear_sectors
Date: Wed, 11 May 2016 15:08:49 -0600
Message-Id: <1463000932-31680-4-git-send-email-vishal.l.verma@intel.com>
In-Reply-To: <1463000932-31680-1-git-send-email-vishal.l.verma@intel.com>
References: <1463000932-31680-1-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Boaz Harrosh <boaz@plexistor.com>, Vishal Verma <vishal.l.verma@intel.com>

From: Matthew Wilcox <matthew.r.wilcox@intel.com>

dax_clear_sectors() cannot handle poisoned blocks.  These must be
zeroed using the BIO interface instead.  Convert ext2 and XFS to use
only sb_issue_zerout().

Reviewed-by: Jeff Moyer <jmoyer@redhat.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
[vishal: Also remove the dax_clear_sectors function entirely]
Signed-off-by: Vishal Verma <vishal.l.verma@intel.com>
---
 fs/dax.c               | 32 --------------------------------
 fs/ext2/inode.c        |  7 +++----
 fs/xfs/xfs_bmap_util.c | 15 ++++-----------
 include/linux/dax.h    |  1 -
 4 files changed, 7 insertions(+), 48 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index d602410..0abbbb6 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -87,38 +87,6 @@ struct page *read_dax_sector(struct block_device *bdev, sector_t n)
 	return page;
 }
 
-/*
- * dax_clear_sectors() is called from within transaction context from XFS,
- * and hence this means the stack from this point must follow GFP_NOFS
- * semantics for all operations.
- */
-int dax_clear_sectors(struct block_device *bdev, sector_t _sector, long _size)
-{
-	struct blk_dax_ctl dax = {
-		.sector = _sector,
-		.size = _size,
-	};
-
-	might_sleep();
-	do {
-		long count, sz;
-
-		count = dax_map_atomic(bdev, &dax);
-		if (count < 0)
-			return count;
-		sz = min_t(long, count, SZ_128K);
-		clear_pmem(dax.addr, sz);
-		dax.size -= sz;
-		dax.sector += sz / 512;
-		dax_unmap_atomic(bdev, &dax);
-		cond_resched();
-	} while (dax.size);
-
-	wmb_pmem();
-	return 0;
-}
-EXPORT_SYMBOL_GPL(dax_clear_sectors);
-
 static bool buffer_written(struct buffer_head *bh)
 {
 	return buffer_mapped(bh) && !buffer_unwritten(bh);
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 1f07b75..35f2b0bf 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -26,6 +26,7 @@
 #include <linux/highuid.h>
 #include <linux/pagemap.h>
 #include <linux/dax.h>
+#include <linux/blkdev.h>
 #include <linux/quotaops.h>
 #include <linux/writeback.h>
 #include <linux/buffer_head.h>
@@ -737,10 +738,8 @@ static int ext2_get_blocks(struct inode *inode,
 		 * so that it's not found by another thread before it's
 		 * initialised
 		 */
-		err = dax_clear_sectors(inode->i_sb->s_bdev,
-				le32_to_cpu(chain[depth-1].key) <<
-				(inode->i_blkbits - 9),
-				1 << inode->i_blkbits);
+		err = sb_issue_zeroout(inode->i_sb,
+				le32_to_cpu(chain[depth-1].key), 1, GFP_NOFS);
 		if (err) {
 			mutex_unlock(&ei->truncate_mutex);
 			goto cleanup;
diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
index 3b63098..930ac6a 100644
--- a/fs/xfs/xfs_bmap_util.c
+++ b/fs/xfs/xfs_bmap_util.c
@@ -72,18 +72,11 @@ xfs_zero_extent(
 	struct xfs_mount *mp = ip->i_mount;
 	xfs_daddr_t	sector = xfs_fsb_to_db(ip, start_fsb);
 	sector_t	block = XFS_BB_TO_FSBT(mp, sector);
-	ssize_t		size = XFS_FSB_TO_B(mp, count_fsb);
-
-	if (IS_DAX(VFS_I(ip)))
-		return dax_clear_sectors(xfs_find_bdev_for_inode(VFS_I(ip)),
-				sector, size);
-
-	/*
-	 * let the block layer decide on the fastest method of
-	 * implementing the zeroing.
-	 */
-	return sb_issue_zeroout(mp->m_super, block, count_fsb, GFP_NOFS);
 
+	return blkdev_issue_zeroout(xfs_find_bdev_for_inode(VFS_I(ip)),
+		block << (mp->m_super->s_blocksize_bits - 9),
+		count_fsb << (mp->m_super->s_blocksize_bits - 9),
+		GFP_NOFS, true);
 }
 
 /*
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 7c45ac7..7f853ff 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -7,7 +7,6 @@
 
 ssize_t dax_do_io(struct kiocb *, struct inode *, struct iov_iter *, loff_t,
 		  get_block_t, dio_iodone_t, int flags);
-int dax_clear_sectors(struct block_device *bdev, sector_t _sector, long _size);
 int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
