Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED806B0256
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 15:49:20 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id yy13so17332849pab.3
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 12:49:20 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 29si7283898pft.41.2016.02.10.12.49.17
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 12:49:17 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 2/2] dax: move writeback calls into the filesystems
Date: Wed, 10 Feb 2016 13:48:56 -0700
Message-Id: <1455137336-28720-3-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com, Jan Kara <jack@suse.cz>

Previously calls to dax_writeback_mapping_range() for all DAX filesystems
(ext2, ext4 & xfs) were centralized in filemap_write_and_wait_range().
dax_writeback_mapping_range() needs a struct block_device, and it used to
get that from inode->i_sb->s_bdev.  This is correct for normal inodes
mounted on ext2, ext4 and XFS filesystems, but is incorrect for DAX raw
block devices and for XFS real-time files.

Instead, call dax_writeback_mapping_range() directly from the filesystem
->writepages function so that it can supply us with a valid block
device. This also fixes DAX code to properly flush caches in response to
sync(2).

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/block_dev.c      | 16 +++++++++++++++-
 fs/dax.c            | 13 ++++++++-----
 fs/ext2/inode.c     | 11 +++++++++++
 fs/ext4/inode.c     |  7 +++++++
 fs/xfs/xfs_aops.c   |  9 +++++++++
 include/linux/dax.h |  6 ++++--
 mm/filemap.c        | 12 ++++--------
 7 files changed, 58 insertions(+), 16 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 39b3a17..fc01e43 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1693,13 +1693,27 @@ static int blkdev_releasepage(struct page *page, gfp_t wait)
 	return try_to_free_buffers(page);
 }
 
+static int blkdev_writepages(struct address_space *mapping,
+			     struct writeback_control *wbc)
+{
+	if (dax_mapping(mapping)) {
+		struct block_device *bdev = I_BDEV(mapping->host);
+		int error;
+
+		error = dax_writeback_mapping_range(mapping, bdev, wbc);
+		if (error)
+			return error;
+	}
+	return generic_writepages(mapping, wbc);
+}
+
 static const struct address_space_operations def_blk_aops = {
 	.readpage	= blkdev_readpage,
 	.readpages	= blkdev_readpages,
 	.writepage	= blkdev_writepage,
 	.write_begin	= blkdev_write_begin,
 	.write_end	= blkdev_write_end,
-	.writepages	= generic_writepages,
+	.writepages	= blkdev_writepages,
 	.releasepage	= blkdev_releasepage,
 	.direct_IO	= blkdev_direct_IO,
 	.is_dirty_writeback = buffer_check_dirty_writeback,
diff --git a/fs/dax.c b/fs/dax.c
index 9a173dd..034dd02 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -484,11 +484,10 @@ static int dax_writeback_one(struct block_device *bdev,
  * end]. This is required by data integrity operations to ensure file data is
  * on persistent storage prior to completion of the operation.
  */
-int dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
-		loff_t end)
+int dax_writeback_mapping_range(struct address_space *mapping,
+		struct block_device *bdev, struct writeback_control *wbc)
 {
 	struct inode *inode = mapping->host;
-	struct block_device *bdev = inode->i_sb->s_bdev;
 	pgoff_t start_index, end_index, pmd_index;
 	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
@@ -496,11 +495,15 @@ int dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
 	int i, ret = 0;
 	void *entry;
 
+
+	if (!mapping->nrexceptional || wbc->sync_mode != WB_SYNC_ALL)
+		return 0;
+
 	if (WARN_ON_ONCE(inode->i_blkbits != PAGE_SHIFT))
 		return -EIO;
 
-	start_index = start >> PAGE_CACHE_SHIFT;
-	end_index = end >> PAGE_CACHE_SHIFT;
+	start_index = wbc->range_start >> PAGE_CACHE_SHIFT;
+	end_index = wbc->range_end >> PAGE_CACHE_SHIFT;
 	pmd_index = DAX_PMD_INDEX(start_index);
 
 	rcu_read_lock();
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index b6b965b..7e44fc3 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -876,6 +876,17 @@ ext2_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
 static int
 ext2_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
+#ifdef CONFIG_FS_DAX
+	if (dax_mapping(mapping)) {
+		int error;
+
+		error = dax_writeback_mapping_range(mapping,
+				mapping->host->i_sb->s_bdev, wbc);
+		if (error)
+			return error;
+	}
+#endif
+
 	return mpage_writepages(mapping, wbc, ext2_get_block);
 }
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 83bc8bf..8c42020 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2450,6 +2450,13 @@ static int ext4_writepages(struct address_space *mapping,
 
 	trace_ext4_writepages(inode, wbc);
 
+	if (dax_mapping(mapping)) {
+		ret = dax_writeback_mapping_range(mapping, inode->i_sb->s_bdev,
+						   wbc);
+		if (ret)
+			goto out_writepages;
+	}
+
 	/*
 	 * No pages to write? This is mainly a kludge to avoid starting
 	 * a transaction for special inodes like journal inode on last iput()
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index fc20518..1139ecd 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1208,6 +1208,15 @@ xfs_vm_writepages(
 	struct writeback_control *wbc)
 {
 	xfs_iflags_clear(XFS_I(mapping->host), XFS_ITRUNCATED);
+	if (dax_mapping(mapping)) {
+		int error;
+
+		error = dax_writeback_mapping_range(mapping,
+				xfs_find_bdev_for_inode(mapping->host), wbc);
+		if (error)
+			return error;
+	}
+
 	return generic_writepages(mapping, wbc);
 }
 
diff --git a/include/linux/dax.h b/include/linux/dax.h
index 7b6bced..636dd59 100644
--- a/include/linux/dax.h
+++ b/include/linux/dax.h
@@ -52,6 +52,8 @@ static inline bool dax_mapping(struct address_space *mapping)
 {
 	return mapping->host && IS_DAX(mapping->host);
 }
-int dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
-		loff_t end);
+
+struct writeback_control;
+int dax_writeback_mapping_range(struct address_space *mapping,
+		struct block_device *bdev, struct writeback_control *wbc);
 #endif
diff --git a/mm/filemap.c b/mm/filemap.c
index bc94386..a829779 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -446,7 +446,8 @@ int filemap_write_and_wait(struct address_space *mapping)
 {
 	int err = 0;
 
-	if (mapping->nrpages) {
+	if (mapping->nrpages ||
+	    (dax_mapping(mapping) && mapping->nrexceptional)) {
 		err = filemap_fdatawrite(mapping);
 		/*
 		 * Even if the above returned error, the pages may be
@@ -482,13 +483,8 @@ int filemap_write_and_wait_range(struct address_space *mapping,
 {
 	int err = 0;
 
-	if (dax_mapping(mapping) && mapping->nrexceptional) {
-		err = dax_writeback_mapping_range(mapping, lstart, lend);
-		if (err)
-			return err;
-	}
-
-	if (mapping->nrpages) {
+	if (mapping->nrpages ||
+	    (dax_mapping(mapping) && mapping->nrexceptional)) {
 		err = __filemap_fdatawrite_range(mapping, lstart, lend,
 						 WB_SYNC_ALL);
 		/* See comment of filemap_write_and_wait() */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
