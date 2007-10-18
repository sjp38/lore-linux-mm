From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [RFC][PATCH] block: Isolate the buffer cache in it's own mappings.
References: <200710151028.34407.borntraeger@de.ibm.com>
	<m1zlykj8zl.fsf_-_@ebiederm.dsl.xmission.com>
	<200710160956.58061.borntraeger@de.ibm.com>
	<200710171814.01717.borntraeger@de.ibm.com>
	<m1sl49ei8x.fsf@ebiederm.dsl.xmission.com>
	<1192648456.15717.7.camel@think.oraclecorp.com>
	<m17illeb8f.fsf@ebiederm.dsl.xmission.com>
	<1192654481.15717.16.camel@think.oraclecorp.com>
	<m1ve95ctuc.fsf@ebiederm.dsl.xmission.com>
	<1192661889.15717.27.camel@think.oraclecorp.com>
	<m16415cocs.fsf@ebiederm.dsl.xmission.com>
	<1192665785.15717.34.camel@think.oraclecorp.com>
Date: Wed, 17 Oct 2007 21:59:02 -0600
In-Reply-To: <1192665785.15717.34.camel@think.oraclecorp.com> (Chris Mason's
	message of "Wed, 17 Oct 2007 20:03:05 -0400")
Message-ID: <m1tzopaxa1.fsf_-_@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

If filesystems care at all they want absolute control over the buffer
cache.  Controlling which buffers are dirty and when.  Because we
keep the buffer cache in the page cache for the block device we have
not quite been giving filesystems that control leading to really weird
bugs.

In addition this tieing of the implemetation of block device caching
and the buffer cache has resulted in a much more complicated and
limited implementation then necessary.  Block devices for example
don't need buffer_heads, and it is perfectly reasonable to cache
block devices in high memory.

To start untangling the worst of this mess this patch introduces a
second block device inode for the buffer cache.  All buffer cache
operations are diverted to that use the new bd_metadata_inode, which
keeps the weirdness of the metadata requirements isolated in their
own little world.

This should enable future cleanups to diverge and simplify the
address_space_operations of the buffer cache and block device
page cache.

As a side effect of this cleanup the current ramdisk code should
be safe from dropping pages because we never place any buffer heads
on ramdisk pages.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/block_dev.c     |   45 ++++++++++++++++++++++++++++++++-------------
 fs/buffer.c        |   17 ++++++++++++-----
 fs/ext3/dir.c      |    2 +-
 fs/ext4/dir.c      |    2 +-
 fs/fat/inode.c     |    2 +-
 include/linux/fs.h |    1 +
 6 files changed, 48 insertions(+), 21 deletions(-)

diff --git a/fs/block_dev.c b/fs/block_dev.c
index 379a446..87a5760 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -59,10 +59,12 @@ static sector_t max_block(struct block_device *bdev)
 /* Kill _all_ buffers and pagecache , dirty or not.. */
 static void kill_bdev(struct block_device *bdev)
 {
-	if (bdev->bd_inode->i_mapping->nrpages == 0)
-		return;
-	invalidate_bh_lrus();
-	truncate_inode_pages(bdev->bd_inode->i_mapping, 0);
+	if (bdev->bd_inode->i_mapping->nrpages) 
+		truncate_inode_pages(bdev->bd_inode->i_mapping, 0);
+	if (bdev->bd_metadata_inode->i_mapping->nrpages) {
+		truncate_inode_pages(bdev->bd_metadata_inode->i_mapping, 0);
+		invalidate_bh_lrus();
+	}
 }	
 
 int set_blocksize(struct block_device *bdev, int size)
@@ -80,6 +82,7 @@ int set_blocksize(struct block_device *bdev, int size)
 		sync_blockdev(bdev);
 		bdev->bd_block_size = size;
 		bdev->bd_inode->i_blkbits = blksize_bits(size);
+		bdev->bd_metadata_inode->i_blkbits = blksize_bits(size);
 		kill_bdev(bdev);
 	}
 	return 0;
@@ -114,7 +117,7 @@ static int
 blkdev_get_block(struct inode *inode, sector_t iblock,
 		struct buffer_head *bh, int create)
 {
-	if (iblock >= max_block(I_BDEV(inode))) {
+	if (iblock >= max_block(inode->i_bdev)) {
 		if (create)
 			return -EIO;
 
@@ -126,7 +129,7 @@ blkdev_get_block(struct inode *inode, sector_t iblock,
 		 */
 		return 0;
 	}
-	bh->b_bdev = I_BDEV(inode);
+	bh->b_bdev = inode->i_bdev;
 	bh->b_blocknr = iblock;
 	set_buffer_mapped(bh);
 	return 0;
@@ -136,7 +139,7 @@ static int
 blkdev_get_blocks(struct inode *inode, sector_t iblock,
 		struct buffer_head *bh, int create)
 {
-	sector_t end_block = max_block(I_BDEV(inode));
+	sector_t end_block = max_block(inode->i_bdev);
 	unsigned long max_blocks = bh->b_size >> inode->i_blkbits;
 
 	if ((iblock + max_blocks) > end_block) {
@@ -152,7 +155,7 @@ blkdev_get_blocks(struct inode *inode, sector_t iblock,
 		}
 	}
 
-	bh->b_bdev = I_BDEV(inode);
+	bh->b_bdev = inode->i_bdev;
 	bh->b_blocknr = iblock;
 	bh->b_size = max_blocks << inode->i_blkbits;
 	if (max_blocks)
@@ -167,7 +170,7 @@ blkdev_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
 	struct file *file = iocb->ki_filp;
 	struct inode *inode = file->f_mapping->host;
 
-	return blockdev_direct_IO_no_locking(rw, iocb, inode, I_BDEV(inode),
+	return blockdev_direct_IO_no_locking(rw, iocb, inode, inode->i_bdev,
 				iov, offset, nr_segs, blkdev_get_blocks, NULL);
 }
 
@@ -244,7 +247,7 @@ blkdev_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
 		 loff_t pos, unsigned long nr_segs)
 {
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
-	unsigned blkbits = blksize_bits(bdev_hardsect_size(I_BDEV(inode)));
+	unsigned blkbits = blksize_bits(bdev_hardsect_size(inode->i_bdev);
 	unsigned blocksize_mask = (1 << blkbits) - 1;
 	unsigned long seg = 0;	/* iov segment iterator */
 	unsigned long nvec;	/* number of bio vec needed */
@@ -292,7 +295,7 @@ blkdev_direct_IO(int rw, struct kiocb *iocb, const struct iovec *iov,
 
 		/* bio_alloc should not fail with GFP_KERNEL flag */
 		bio = bio_alloc(GFP_KERNEL, nvec);
-		bio->bi_bdev = I_BDEV(inode);
+		bio->bi_bdev = inode->i_bdev;
 		bio->bi_end_io = blk_end_aio;
 		bio->bi_private = iocb;
 		bio->bi_sector = pos >> blkbits;
@@ -498,6 +501,8 @@ static void bdev_clear_inode(struct inode *inode)
 	}
 	list_del_init(&bdev->bd_list);
 	spin_unlock(&bdev_lock);
+	iput(bdev->bd_metadata_inode);
+	bdev->bd_metadata_inode = NULL;
 }
 
 static const struct super_operations bdev_sops = {
@@ -566,7 +571,7 @@ static LIST_HEAD(all_bdevs);
 struct block_device *bdget(dev_t dev)
 {
 	struct block_device *bdev;
-	struct inode *inode;
+	struct inode *inode, *md_inode;
 
 	inode = iget5_locked(bd_mnt->mnt_sb, hash(dev),
 			bdev_test, bdev_set, &dev);
@@ -574,6 +579,11 @@ struct block_device *bdget(dev_t dev)
 	if (!inode)
 		return NULL;
 
+	/* Get an anonymous inode for the filesystem metadata cache */
+	md_inode = new_inode(bd_mnt->mnt_sb);
+	if (!md_inode)
+		return NULL;
+
 	bdev = &BDEV_I(inode)->bdev;
 
 	if (inode->i_state & I_NEW) {
@@ -582,12 +592,19 @@ struct block_device *bdget(dev_t dev)
 		bdev->bd_block_size = (1 << inode->i_blkbits);
 		bdev->bd_part_count = 0;
 		bdev->bd_invalidated = 0;
+		bdev->bd_metadata_inode = md_inode;
 		inode->i_mode = S_IFBLK;
 		inode->i_rdev = dev;
 		inode->i_bdev = bdev;
 		inode->i_data.a_ops = &def_blk_aops;
 		mapping_set_gfp_mask(&inode->i_data, GFP_USER);
 		inode->i_data.backing_dev_info = &default_backing_dev_info;
+		md_inode->i_mode = S_IFBLK;
+		md_inode->i_rdev = dev;
+		md_inode->i_bdev = bdev;
+		md_inode->i_data.a_ops = &def_blk_aops;
+		mapping_set_gfp_mask(&md_inode->i_data, GFP_USER);
+		md_inode->i_data.backing_dev_info = &default_backing_dev_info;
 		spin_lock(&bdev_lock);
 		list_add(&bdev->bd_list, &all_bdevs);
 		spin_unlock(&bdev_lock);
@@ -604,7 +621,7 @@ long nr_blockdev_pages(void)
 	long ret = 0;
 	spin_lock(&bdev_lock);
 	list_for_each_entry(bdev, &all_bdevs, bd_list) {
-		ret += bdev->bd_inode->i_mapping->nrpages;
+		ret += bdev->bd_metadata_inode->i_mapping->nrpages;
 	}
 	spin_unlock(&bdev_lock);
 	return ret;
@@ -1099,6 +1116,7 @@ void bd_set_size(struct block_device *bdev, loff_t size)
 	unsigned bsize = bdev_hardsect_size(bdev);
 
 	bdev->bd_inode->i_size = size;
+	bdev->bd_metadata_inode->i_size = size;
 	while (bsize < PAGE_CACHE_SIZE) {
 		if (size & bsize)
 			break;
@@ -1106,6 +1124,7 @@ void bd_set_size(struct block_device *bdev, loff_t size)
 	}
 	bdev->bd_block_size = bsize;
 	bdev->bd_inode->i_blkbits = blksize_bits(bsize);
+	bdev->bd_metadata_inode->i_blkbits = blksize_bits(bsize);
 }
 EXPORT_SYMBOL(bd_set_size);
 
diff --git a/fs/buffer.c b/fs/buffer.c
index faceb5e..2c044b6 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -166,8 +166,11 @@ int sync_blockdev(struct block_device *bdev)
 {
 	int ret = 0;
 
-	if (bdev)
+	if (bdev) {
 		ret = filemap_write_and_wait(bdev->bd_inode->i_mapping);
+		if (!ret)
+			ret = filemap_write_and_wait(bdev->bd_metadata_inode->i_mapping);
+	}
 	return ret;
 }
 EXPORT_SYMBOL(sync_blockdev);
@@ -261,7 +264,7 @@ EXPORT_SYMBOL(thaw_bdev);
 static struct buffer_head *
 __find_get_block_slow(struct block_device *bdev, sector_t block)
 {
-	struct inode *bd_inode = bdev->bd_inode;
+	struct inode *bd_inode = bdev->bd_metadata_inode;
 	struct address_space *bd_mapping = bd_inode->i_mapping;
 	struct buffer_head *ret = NULL;
 	pgoff_t index;
@@ -347,12 +350,16 @@ out:
 void invalidate_bdev(struct block_device *bdev)
 {
 	struct address_space *mapping = bdev->bd_inode->i_mapping;
+	struct address_space *meta_mapping = bdev->bd_metadata_inode->i_mapping;
 
-	if (mapping->nrpages == 0)
+	if (mapping->nrpages)
+		invalidate_mapping_pages(mapping, 0, -1);
+	
+	if (meta_mapping->nrpages == 0)
 		return;
 
 	invalidate_bh_lrus();
-	invalidate_mapping_pages(mapping, 0, -1);
+	invalidate_mapping_pages(meta_mapping, 0, -1);
 }
 
 /*
@@ -1009,7 +1016,7 @@ static struct page *
 grow_dev_page(struct block_device *bdev, sector_t block,
 		pgoff_t index, int size)
 {
-	struct inode *inode = bdev->bd_inode;
+	struct inode *inode = bdev->bd_metadata_inode;
 	struct page *page;
 	struct buffer_head *bh;
 
diff --git a/fs/ext3/dir.c b/fs/ext3/dir.c
index c2c3491..a46305e 100644
--- a/fs/ext3/dir.c
+++ b/fs/ext3/dir.c
@@ -140,7 +140,7 @@ static int ext3_readdir(struct file * filp,
 					(PAGE_CACHE_SHIFT - inode->i_blkbits);
 			if (!ra_has_index(&filp->f_ra, index))
 				page_cache_sync_readahead(
-					sb->s_bdev->bd_inode->i_mapping,
+					sb->s_bdev->bd_metadata_inode->i_mapping,
 					&filp->f_ra, filp,
 					index, 1);
 			filp->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
index e11890a..eaab1db 100644
--- a/fs/ext4/dir.c
+++ b/fs/ext4/dir.c
@@ -139,7 +139,7 @@ static int ext4_readdir(struct file * filp,
 					(PAGE_CACHE_SHIFT - inode->i_blkbits);
 			if (!ra_has_index(&filp->f_ra, index))
 				page_cache_sync_readahead(
-					sb->s_bdev->bd_inode->i_mapping,
+					sb->s_bdev->bd_metadata_inode->i_mapping,
 					&filp->f_ra, filp,
 					index, 1);
 			filp->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
diff --git a/fs/fat/inode.c b/fs/fat/inode.c
index 46b8a67..a8485b6 100644
--- a/fs/fat/inode.c
+++ b/fs/fat/inode.c
@@ -1484,7 +1484,7 @@ int fat_flush_inodes(struct super_block *sb, struct inode *i1, struct inode *i2)
 	if (!ret && i2)
 		ret = writeback_inode(i2);
 	if (!ret) {
-		struct address_space *mapping = sb->s_bdev->bd_inode->i_mapping;
+		struct address_space *mapping = sb->s_bdev->bd_metadata_inode->i_mapping;
 		ret = filemap_flush(mapping);
 	}
 	return ret;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f70d52c..aeac9d3 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -519,6 +519,7 @@ struct address_space {
 struct block_device {
 	dev_t			bd_dev;  /* not a kdev_t - it's a search key */
 	struct inode *		bd_inode;	/* will die */
+	struct inode *		bd_metadata_inode;
 	int			bd_openers;
 	struct mutex		bd_mutex;	/* open/close mutex */
 	struct semaphore	bd_mount_sem;
-- 
1.5.3.rc6.17.g1911

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
