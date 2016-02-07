Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 0EC388309B
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 02:19:33 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id w123so92838277pfb.0
        for <linux-mm@kvack.org>; Sat, 06 Feb 2016 23:19:33 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id u16si37154327pfa.217.2016.02.06.23.19.32
        for <linux-mm@kvack.org>;
        Sat, 06 Feb 2016 23:19:32 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 1/2] dax: pass bdev argument to dax_clear_blocks()
Date: Sun,  7 Feb 2016 00:19:12 -0700
Message-Id: <1454829553-29499-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1454829553-29499-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com

dax_clear_blocks() needs a valid struct block_device and previously it was
using inode->i_sb->s_bdev in all cases.  This is correct for normal inodes
on mounted ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
block devices and for XFS real-time devices.

Instead, have the caller pass in a struct block_device pointer which it
knows to be correct.

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 fs/dax.c               | 4 ++--
 fs/ext2/inode.c        | 5 +++--
 fs/xfs/xfs_aops.c      | 2 +-
 fs/xfs/xfs_aops.h      | 1 +
 fs/xfs/xfs_bmap_util.c | 4 +++-
 include/linux/dax.h    | 3 ++-
 6 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 227974a..4592241 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -83,9 +83,9 @@ struct page *read_dax_sector(struct block_device *bdev, sector_t n)
  * and hence this means the stack from this point must follow GFP_NOFS
  * semantics for all operations.
  */
-int dax_clear_blocks(struct inode *inode, sector_t block, long _size)
+int dax_clear_blocks(struct inode *inode, struct block_device *bdev,
+		sector_t block, long _size)
 {
-	struct block_device *bdev = inode->i_sb->s_bdev;
 	struct blk_dax_ctl dax = {
 		.sector = block << (inode->i_blkbits - 9),
 		.size = _size,
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 338eefd..277a32b 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -737,8 +737,9 @@ static int ext2_get_blocks(struct inode *inode,
 		 * so that it's not found by another thread before it's
 		 * initialised
 		 */
-		err = dax_clear_blocks(inode, le32_to_cpu(chain[depth-1].key),
-						1 << inode->i_blkbits);
+		err = dax_clear_blocks(inode, inode->i_sb->s_bdev,
+				le32_to_cpu(chain[depth-1].key),
+				1 << inode->i_blkbits);
 		if (err) {
 			mutex_unlock(&ei->truncate_mutex);
 			goto cleanup;
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 379c089..fc20518 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -55,7 +55,7 @@ xfs_count_page_state(
 	} while ((bh = bh->b_this_page) != head);
 }
 
-STATIC struct block_device *
+struct block_device *
 xfs_find_bdev_for_inode(
 	struct inode		*inode)
 {
diff --git a/fs/xfs/xfs_aops.h b/fs/xfs/xfs_aops.h
index f6ffc9a..a4343c6 100644
--- a/fs/xfs/xfs_aops.h
+++ b/fs/xfs/xfs_aops.h
@@ -62,5 +62,6 @@ int	xfs_get_blocks_dax_fault(struct inode *inode, sector_t offset,
 			         struct buffer_head *map_bh, int create);
 
 extern void xfs_count_page_state(struct page *, int *, int *);
+extern struct block_device *xfs_find_bdev_for_inode(struct inode *);
 
 #endif /* __XFS_AOPS_H__ */
diff --git a/fs/xfs/xfs_bmap_util.c b/fs/xfs/xfs_bmap_util.c
index 07ef29b..f722ba2 100644
--- a/fs/xfs/xfs_bmap_util.c
+++ b/fs/xfs/xfs_bmap_util.c
@@ -73,9 +73,11 @@ xfs_zero_extent(
 	xfs_daddr_t	sector = xfs_fsb_to_db(ip, start_fsb);
 	sector_t	block = XFS_BB_TO_FSBT(mp, sector);
 	ssize_t		size = XFS_FSB_TO_B(mp, count_fsb);
+	struct inode	*inode = VFS_I(ip);
 
 	if (IS_DAX(VFS_I(ip)))
-		return dax_clear_blocks(VFS_I(ip), block, size);
+		return dax_clear_blocks(inode, xfs_find_bdev_for_inode(inode),
+				block, size);
 
 	/*
 	 * let the block layer decide on the fastest method of
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 8204c3d..bad27b0 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -7,7 +7,8 @@
 
 ssize_t dax_do_io(struct kiocb *, struct inode *, struct iov_iter *, loff_t,
 		  get_block_t, dio_iodone_t, int flags);
-int dax_clear_blocks(struct inode *, sector_t block, long size);
+int dax_clear_blocks(struct inode *inode, struct block_device *bdev,
+		sector_t block, long _size);
 int dax_zero_page_range(struct inode *, loff_t from, unsigned len, get_block_t);
 int dax_truncate_page(struct inode *, loff_t from, get_block_t);
 int dax_fault(struct vm_area_struct *, struct vm_fault *, get_block_t,
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
