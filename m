Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 02F1D6B00FD
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 15:09:00 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kq14so4474159pab.24
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 12:09:00 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id zw7si3963436pac.29.2014.03.23.12.08.59
        for <linux-mm@kvack.org>;
        Sun, 23 Mar 2014 12:09:00 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v7 04/22] Change direct_access calling convention
Date: Sun, 23 Mar 2014 15:08:30 -0400
Message-Id: <214af2a38d840d0b8e983d39d03711d1292bc2d6.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1395591795.git.matthew.r.wilcox@intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, willy@linux.intel.com

In order to support accesses to larger chunks of memory, pass in a
'size' parameter (counted in bytes), and return the amount available at
that address.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 Documentation/filesystems/xip.txt | 15 +++++++++------
 arch/powerpc/sysdev/axonram.c     |  6 +++---
 drivers/block/brd.c               |  8 +++++---
 drivers/s390/block/dcssblk.c      | 19 ++++++++++---------
 fs/ext2/xip.c                     | 30 +++++++++++++-----------------
 include/linux/blkdev.h            |  4 ++--
 6 files changed, 42 insertions(+), 40 deletions(-)

diff --git a/Documentation/filesystems/xip.txt b/Documentation/filesystems/xip.txt
index 0466ee5..b62eabf 100644
--- a/Documentation/filesystems/xip.txt
+++ b/Documentation/filesystems/xip.txt
@@ -28,12 +28,15 @@ Implementation
 Execute-in-place is implemented in three steps: block device operation,
 address space operation, and file operations.
 
-A block device operation named direct_access is used to retrieve a
-reference (pointer) to a block on-disk. The reference is supposed to be
-cpu-addressable, physical address and remain valid until the release operation
-is performed. A struct block_device reference is used to address the device,
-and a sector_t argument is used to identify the individual block. As an
-alternative, memory technology devices can be used for this.
+A block device operation named direct_access is used to translate the
+block device sector number to a page frame number (pfn) that identifies
+the physical page for the memory.  It also returns a kernel virtual
+address that can be used to access the memory.
+
+The direct_access method takes a 'size' parameter that indicates the
+number of bytes being requested.  The function should return the number
+of bytes that it can provide, although it must not exceed the number of
+bytes requested.  It may also return a negative errno if an error occurs.
 
 The block device operation is optional, these block devices support it as of
 today:
diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index 830edc8..1697e29 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -139,9 +139,9 @@ axon_ram_make_request(struct request_queue *queue, struct bio *bio)
  * axon_ram_direct_access - direct_access() method for block device
  * @device, @sector, @data: see block_device_operations method
  */
-static int
+static long
 axon_ram_direct_access(struct block_device *device, sector_t sector,
-		       void **kaddr, unsigned long *pfn)
+		       void **kaddr, unsigned long *pfn, long size)
 {
 	struct axon_ram_bank *bank = device->bd_disk->private_data;
 	loff_t offset;
@@ -158,7 +158,7 @@ axon_ram_direct_access(struct block_device *device, sector_t sector,
 	*kaddr = (void *)(bank->ph_addr + offset);
 	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
 
-	return 0;
+	return min_t(unsigned long, size, bank->size - offset);
 }
 
 static const struct block_device_operations axon_ram_devops = {
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index e73b85c..00da60d 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -361,8 +361,8 @@ out:
 }
 
 #ifdef CONFIG_BLK_DEV_XIP
-static int brd_direct_access(struct block_device *bdev, sector_t sector,
-			void **kaddr, unsigned long *pfn)
+static long brd_direct_access(struct block_device *bdev, sector_t sector,
+			void **kaddr, unsigned long *pfn, long size)
 {
 	struct brd_device *brd = bdev->bd_disk->private_data;
 	struct page *page;
@@ -379,7 +379,9 @@ static int brd_direct_access(struct block_device *bdev, sector_t sector,
 	*kaddr = page_address(page);
 	*pfn = page_to_pfn(page);
 
-	return 0;
+	/* Could optimistically check to see if the next page in the
+	 * file is mapped to the next page of physical RAM */
+	return PAGE_SIZE;
 }
 #endif
 
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index ebf41e2..da914b2 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -28,8 +28,8 @@
 static int dcssblk_open(struct block_device *bdev, fmode_t mode);
 static void dcssblk_release(struct gendisk *disk, fmode_t mode);
 static void dcssblk_make_request(struct request_queue *q, struct bio *bio);
-static int dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
-				 void **kaddr, unsigned long *pfn);
+static long dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
+				 void **kaddr, unsigned long *pfn, long size);
 
 static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
 
@@ -866,25 +866,26 @@ fail:
 	bio_io_error(bio);
 }
 
-static int
+static long
 dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
-			void **kaddr, unsigned long *pfn)
+			void **kaddr, unsigned long *pfn, long size)
 {
 	struct dcssblk_dev_info *dev_info;
-	unsigned long pgoff;
+	unsigned long offset, dev_sz;
 
 	dev_info = bdev->bd_disk->private_data;
 	if (!dev_info)
 		return -ENODEV;
+	dev_sz = dev_info->end - dev_info->start;
 	if (secnum % (PAGE_SIZE/512))
 		return -EINVAL;
-	pgoff = secnum / (PAGE_SIZE / 512);
-	if ((pgoff+1)*PAGE_SIZE-1 > dev_info->end - dev_info->start)
+	offset = secnum * 512;
+	if (offset > dev_sz)
 		return -ERANGE;
-	*kaddr = (void *) (dev_info->start+pgoff*PAGE_SIZE);
+	*kaddr = (void *) (dev_info->start + offset);
 	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
 
-	return 0;
+	return min_t(unsigned long, size, dev_sz - offset);
 }
 
 static void
diff --git a/fs/ext2/xip.c b/fs/ext2/xip.c
index e98171a..fa40091 100644
--- a/fs/ext2/xip.c
+++ b/fs/ext2/xip.c
@@ -13,18 +13,13 @@
 #include "ext2.h"
 #include "xip.h"
 
-static inline int
-__inode_direct_access(struct inode *inode, sector_t block,
-		      void **kaddr, unsigned long *pfn)
+static inline long __inode_direct_access(struct inode *inode, sector_t block,
+				void **kaddr, unsigned long *pfn, long size)
 {
 	struct block_device *bdev = inode->i_sb->s_bdev;
 	const struct block_device_operations *ops = bdev->bd_disk->fops;
-	sector_t sector;
-
-	sector = block * (PAGE_SIZE / 512); /* ext2 block to bdev sector */
-
-	BUG_ON(!ops->direct_access);
-	return ops->direct_access(bdev, sector, kaddr, pfn);
+	sector_t sector = block * (PAGE_SIZE / 512);
+	return ops->direct_access(bdev, sector, kaddr, pfn, size);
 }
 
 static inline int
@@ -53,12 +48,13 @@ ext2_clear_xip_target(struct inode *inode, sector_t block)
 {
 	void *kaddr;
 	unsigned long pfn;
-	int rc;
+	long size;
 
-	rc = __inode_direct_access(inode, block, &kaddr, &pfn);
-	if (!rc)
-		clear_page(kaddr);
-	return rc;
+	size = __inode_direct_access(inode, block, &kaddr, &pfn, PAGE_SIZE);
+	if (size < 0)
+		return size;
+	clear_page(kaddr);
+	return 0;
 }
 
 void ext2_xip_verify_sb(struct super_block *sb)
@@ -77,7 +73,7 @@ void ext2_xip_verify_sb(struct super_block *sb)
 int ext2_get_xip_mem(struct address_space *mapping, pgoff_t pgoff, int create,
 				void **kmem, unsigned long *pfn)
 {
-	int rc;
+	long rc;
 	sector_t block;
 
 	/* first, retrieve the sector number */
@@ -86,6 +82,6 @@ int ext2_get_xip_mem(struct address_space *mapping, pgoff_t pgoff, int create,
 		return rc;
 
 	/* retrieve address of the target data */
-	rc = __inode_direct_access(mapping->host, block, kmem, pfn);
-	return rc;
+	rc = __inode_direct_access(mapping->host, block, kmem, pfn, PAGE_SIZE);
+	return (rc < 0) ? rc : 0;
 }
diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
index 4afa4f8..c6f6210 100644
--- a/include/linux/blkdev.h
+++ b/include/linux/blkdev.h
@@ -1560,8 +1560,8 @@ struct block_device_operations {
 	void (*release) (struct gendisk *, fmode_t);
 	int (*ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
 	int (*compat_ioctl) (struct block_device *, fmode_t, unsigned, unsigned long);
-	int (*direct_access) (struct block_device *, sector_t,
-						void **, unsigned long *);
+	long (*direct_access) (struct block_device *, sector_t,
+					void **, unsigned long *pfn, long size);
 	unsigned int (*check_events) (struct gendisk *disk,
 				      unsigned int clearing);
 	/* ->media_changed() is DEPRECATED, use ->check_events() instead */
-- 
1.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
