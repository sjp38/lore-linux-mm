Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BC24B6B026B
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 13:59:50 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id fy10so95331688pac.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 10:59:50 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id af6si41329226pad.226.2016.02.22.10.59.45
        for <linux-mm@kvack.org>;
        Mon, 22 Feb 2016 10:59:45 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v4 5/5] dax: move writeback calls into the filesystems
Date: Mon, 22 Feb 2016 11:59:22 -0700
Message-Id: <1456167562-28576-6-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1456167562-28576-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1456167562-28576-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, Jens Axboe <axboe@kernel.dk>, Matthew Wilcox <willy@linux.intel.com>, linux-block@vger.kernel.org, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org, xfs@oss.sgi.com, Jan Kara <jack@suse.cz>

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
 fs/block_dev.c      | 13 ++++++++++++-
 fs/dax.c            | 12 +++++++-----
 fs/ext2/inode.c     |  8 ++++++++
 fs/ext4/inode.c     |  4 ++++
 fs/xfs/xfs_aops.c   |  4 ++++
 include/linux/dax.h |  6 ++++--
 mm/filemap.c        | 12 ++++--------
 7 files changed, 43 insertions(+), 16 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 31c6d10..826b164 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -1697,13 +1697,24 @@ static int blkdev_releasepage(struct page *page, gfp_t wait)
 	return try_to_free_buffers(page);
 }
 
+static int blkdev_writepages(struct address_space *mapping,
+			     struct writeback_control *wbc)
+{
+	if (dax_mapping(mapping)) {
+		struct block_device *bdev = I_BDEV(mapping->host);
+
+		return dax_writeback_mapping_range(mapping, bdev, wbc);
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
index 9a173dd..7111724 100644
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
@@ -499,8 +498,11 @@ int dax_writeback_mapping_range(struct address_space *mapping, loff_t start,
 	if (WARN_ON_ONCE(inode->i_blkbits != PAGE_SHIFT))
 		return -EIO;
 
-	start_index = start >> PAGE_CACHE_SHIFT;
-	end_index = end >> PAGE_CACHE_SHIFT;
+	if (!mapping->nrexceptional || wbc->sync_mode != WB_SYNC_ALL)
+		return 0;
+
+	start_index = wbc->range_start >> PAGE_CACHE_SHIFT;
+	end_index = wbc->range_end >> PAGE_CACHE_SHIFT;
 	pmd_index = DAX_PMD_INDEX(start_index);
 
 	rcu_read_lock();
diff --git a/fs/ext2/inode.c b/fs/ext2/inode.c
index 4467cbd..6bd58e6 100644
--- a/fs/ext2/inode.c
+++ b/fs/ext2/inode.c
@@ -876,6 +876,14 @@ ext2_direct_IO(struct kiocb *iocb, struct iov_iter *iter, loff_t offset)
 static int
 ext2_writepages(struct address_space *mapping, struct writeback_control *wbc)
 {
+#ifdef CONFIG_FS_DAX
+	if (dax_mapping(mapping)) {
+		return dax_writeback_mapping_range(mapping,
+						   mapping->host->i_sb->s_bdev,
+						   wbc);
+	}
+#endif
+
 	return mpage_writepages(mapping, wbc, ext2_get_block);
 }
 
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index 5708e68..aee960b 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -2478,6 +2478,10 @@ static int ext4_writepages(struct address_space *mapping,
 
 	trace_ext4_writepages(inode, wbc);
 
+	if (dax_mapping(mapping))
+		return dax_writeback_mapping_range(mapping, inode->i_sb->s_bdev,
+						   wbc);
+
 	/*
 	 * No pages to write? This is mainly a kludge to avoid starting
 	 * a transaction for special inodes like journal inode on last iput()
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index fc20518..a9ebabfe 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -1208,6 +1208,10 @@ xfs_vm_writepages(
 	struct writeback_control *wbc)
 {
 	xfs_iflags_clear(XFS_I(mapping->host), XFS_ITRUNCATED);
+	if (dax_mapping(mapping))
+		return dax_writeback_mapping_range(mapping,
+				xfs_find_bdev_for_inode(mapping->host), wbc);
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
index 23edcce..3461d97 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -446,7 +446,8 @@ int filemap_write_and_wait(struct address_space *mapping)
 {
 	int err = 0;
 
-	if (mapping->nrpages) {
+	if ((!dax_mapping(mapping) && mapping->nrpages) ||
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
+	if ((!dax_mapping(mapping) && mapping->nrpages) ||
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
