From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] rd: Use a private inode for backing storage
References: <200710151028.34407.borntraeger@de.ibm.com>
	<200710172348.23113.borntraeger@de.ibm.com>
	<m1myuhcrfu.fsf@ebiederm.dsl.xmission.com>
	<200710181126.10559.borntraeger@de.ibm.com>
Date: Fri, 19 Oct 2007 16:51:42 -0600
In-Reply-To: <200710181126.10559.borntraeger@de.ibm.com> (Christian
	Borntraeger's message of "Thu, 18 Oct 2007 11:26:10 +0200")
Message-ID: <m1lk9yen0h.fsf_-_@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Currently the ramdisk tries to keep the block device page cache pages
from being marked clean and dropped from memory.  That fails for
filesystems that use the buffer cache because the buffer cache is not
an ordinary buffer cache user and depends on the generic block device
address space operations being used. 

To fix all of those associated problems this patch allocates a private
inode to store the ramdisk pages in.

The result is slightly more memory used for metadata, an extra copying
when reading or writing directly to the block device, and changing the
software block size does not loose the contents of the ramdisk.  Most
of all this ensures we don't loose data during normal use of the
ramdisk.

I deliberately avoid the cleanup that is now possible because this
patch is intended to be a bug fix.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/block/rd.c |   19 ++++++++++++++++---
 1 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/drivers/block/rd.c b/drivers/block/rd.c
index 08176d2..a52f153 100644
--- a/drivers/block/rd.c
+++ b/drivers/block/rd.c
@@ -62,6 +62,7 @@
 /* Various static variables go here.  Most are used only in the RAM disk code.
  */
 
+static struct inode *rd_inode[CONFIG_BLK_DEV_RAM_COUNT];
 static struct gendisk *rd_disks[CONFIG_BLK_DEV_RAM_COUNT];
 static struct block_device *rd_bdev[CONFIG_BLK_DEV_RAM_COUNT];/* Protected device data */
 static struct request_queue *rd_queue[CONFIG_BLK_DEV_RAM_COUNT];
@@ -267,7 +268,7 @@ static int rd_blkdev_pagecache_IO(int rw, struct bio_vec *vec, sector_t sector,
 static int rd_make_request(struct request_queue *q, struct bio *bio)
 {
 	struct block_device *bdev = bio->bi_bdev;
-	struct address_space * mapping = bdev->bd_inode->i_mapping;
+	struct address_space * mapping = rd_inode[MINOR(bdev->bd_dev)]->i_mapping;
 	sector_t sector = bio->bi_sector;
 	unsigned long len = bio->bi_size >> 9;
 	int rw = bio_data_dir(bio);
@@ -312,6 +313,7 @@ static int rd_ioctl(struct inode *inode, struct file *file,
 	mutex_lock(&bdev->bd_mutex);
 	if (bdev->bd_openers <= 2) {
 		truncate_inode_pages(bdev->bd_inode->i_mapping, 0);
+		truncate_inode_pages(rd_inode[iminor(inode)]->i_mapping, 0);
 		error = 0;
 	}
 	mutex_unlock(&bdev->bd_mutex);
@@ -344,20 +346,30 @@ static int rd_open(struct inode *inode, struct file *filp)
 	unsigned unit = iminor(inode);
 
 	if (rd_bdev[unit] == NULL) {
+		struct inode *ramdisk_inode;
 		struct block_device *bdev = inode->i_bdev;
 		struct address_space *mapping;
 		unsigned bsize;
 		gfp_t gfp_mask;
 
+		ramdisk_inode = new_inode(bdev->bd_inode->i_sb);
+		if (!ramdisk_inode)
+			return -ENOMEM;
+
 		inode = igrab(bdev->bd_inode);
 		rd_bdev[unit] = bdev;
+		rd_inode[unit] = ramdisk_inode;
 		bdev->bd_openers++;
 		bsize = bdev_hardsect_size(bdev);
 		bdev->bd_block_size = bsize;
 		inode->i_blkbits = blksize_bits(bsize);
 		inode->i_size = get_capacity(bdev->bd_disk)<<9;
 
-		mapping = inode->i_mapping;
+		ramdisk_inode->i_mode = S_IFBLK;
+		ramdisk_inode->i_bdev = bdev;
+		ramdisk_inode->i_rdev = bdev->bd_dev;
+
+		mapping = ramdisk_inode->i_mapping;
 		mapping->a_ops = &ramdisk_aops;
 		mapping->backing_dev_info = &rd_backing_dev_info;
 		bdev->bd_inode_backing_dev_info = &rd_file_backing_dev_info;
@@ -377,7 +389,7 @@ static int rd_open(struct inode *inode, struct file *filp)
 		 * for the page allocator emergency pools to keep the ramdisk
 		 * driver happy.
 		 */
-		gfp_mask = mapping_gfp_mask(mapping);
+		gfp_mask = GFP_USER;
 		gfp_mask &= ~(__GFP_FS|__GFP_IO);
 		gfp_mask |= __GFP_HIGH;
 		mapping_set_gfp_mask(mapping, gfp_mask);
@@ -409,6 +421,7 @@ static void __exit rd_cleanup(void)
 		del_gendisk(rd_disks[i]);
 		put_disk(rd_disks[i]);
 		blk_cleanup_queue(rd_queue[i]);
+		iput(rd_inode[i]);
 	}
 	unregister_blkdev(RAMDISK_MAJOR, "ramdisk");
 
-- 
1.5.3.rc6.17.g1911

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
