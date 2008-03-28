Message-Id: <20080328015422.234049000@nick.local0.net>
References: <20080328015238.519230000@nick.local0.net>
Date: Fri, 28 Mar 2008 12:52:42 +1100
From: npiggin@suse.de
Subject: [patch 4/7] return pfn from direct_access, for XIP
Content-Disposition: inline; filename=xip-direct_access-pfn.patch
Sender: owner-linux-mm@kvack.org
From: Jared Hulbert <jaredeh@gmail.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alter the block device ->direct_access() API to work with the new
get_xip_mem() API (that requires both kaddr and pfn are returned).

Some architectures will not do the right thing in their virt_to_page()
for use by XIP (to translate from the kernel virtual address returned
by direct_access(), to a user mappable pfn in XIP's page fault handler.

However, we can't switch it to just return the pfn and not the kaddr,
because we have no good way to get a kva from a pfn, and XIP requires
the kva for its read(2) and write(2) handlers. So we have to return
both.

Signed-off-by: Jared Hulbert <jaredeh@gmail.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
Cc: Carsten Otte <cotte@de.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org
---
Index: linux-2.6/arch/powerpc/sysdev/axonram.c
===================================================================
--- linux-2.6.orig/arch/powerpc/sysdev/axonram.c
+++ linux-2.6/arch/powerpc/sysdev/axonram.c
@@ -143,7 +143,7 @@ axon_ram_make_request(struct request_que
  */
 static int
 axon_ram_direct_access(struct block_device *device, sector_t sector,
-		       unsigned long *data)
+		       void **kaddr, unsigned long *pfn)
 {
 	struct axon_ram_bank *bank = device->bd_disk->private_data;
 	loff_t offset;
@@ -154,7 +154,8 @@ axon_ram_direct_access(struct block_devi
 		return -ERANGE;
 	}
 
-	*data = bank->ph_addr + offset;
+	*kaddr = (void *)(bank->ph_addr + offset);
+	*pfn = virt_to_phys(kaddr) >> PAGE_SHIFT;
 
 	return 0;
 }
Index: linux-2.6/drivers/block/brd.c
===================================================================
--- linux-2.6.orig/drivers/block/brd.c
+++ linux-2.6/drivers/block/brd.c
@@ -319,7 +319,7 @@ out:
 
 #ifdef CONFIG_BLK_DEV_XIP
 static int brd_direct_access (struct block_device *bdev, sector_t sector,
-			unsigned long *data)
+			void **kaddr, unsigned long *pfn)
 {
 	struct brd_device *brd = bdev->bd_disk->private_data;
 	struct page *page;
@@ -333,7 +333,8 @@ static int brd_direct_access (struct blo
 	page = brd_insert_page(brd, sector);
 	if (!page)
 		return -ENOMEM;
-	*data = (unsigned long)page_address(page);
+	*kaddr = page_address(page);
+	*pfn = page_to_pfn(page);
 
 	return 0;
 }
Index: linux-2.6/drivers/s390/block/dcssblk.c
===================================================================
--- linux-2.6.orig/drivers/s390/block/dcssblk.c
+++ linux-2.6/drivers/s390/block/dcssblk.c
@@ -36,7 +36,7 @@ static int dcssblk_open(struct inode *in
 static int dcssblk_release(struct inode *inode, struct file *filp);
 static int dcssblk_make_request(struct request_queue *q, struct bio *bio);
 static int dcssblk_direct_access(struct block_device *bdev, sector_t secnum,
-				 unsigned long *data);
+				 void **kaddr, unsigned long *pfn);
 
 static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
 
@@ -687,7 +687,7 @@ fail:
 
 static int
 dcssblk_direct_access (struct block_device *bdev, sector_t secnum,
-			unsigned long *data)
+			void **kaddr, unsigned long *pfn)
 {
 	struct dcssblk_dev_info *dev_info;
 	unsigned long pgoff;
@@ -700,7 +700,9 @@ dcssblk_direct_access (struct block_devi
 	pgoff = secnum / (PAGE_SIZE / 512);
 	if ((pgoff+1)*PAGE_SIZE-1 > dev_info->end - dev_info->start)
 		return -ERANGE;
-	*data = (unsigned long) (dev_info->start+pgoff*PAGE_SIZE);
+	*kaddr = (void *) (dev_info->start+pgoff*PAGE_SIZE);
+	*pfn = virt_to_phys(*kaddr) >> PAGE_SHIFT;
+
 	return 0;
 }
 
Index: linux-2.6/include/linux/fs.h
===================================================================
--- linux-2.6.orig/include/linux/fs.h
+++ linux-2.6/include/linux/fs.h
@@ -1178,7 +1178,8 @@ struct block_device_operations {
 	int (*ioctl) (struct inode *, struct file *, unsigned, unsigned long);
 	long (*unlocked_ioctl) (struct file *, unsigned, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned, unsigned long);
-	int (*direct_access) (struct block_device *, sector_t, unsigned long *);
+	int (*direct_access) (struct block_device *, sector_t,
+						void **, unsigned long *);
 	int (*media_changed) (struct gendisk *);
 	int (*revalidate_disk) (struct gendisk *);
 	int (*getgeo)(struct block_device *, struct hd_geometry *);
Index: linux-2.6/fs/ext2/xip.c
===================================================================
--- linux-2.6.orig/fs/ext2/xip.c
+++ linux-2.6/fs/ext2/xip.c
@@ -16,11 +16,13 @@
 
 static inline int
 __inode_direct_access(struct inode *inode, sector_t sector,
-		      unsigned long *data)
+		      void **kaddr, unsigned long *pfn)
 {
-	BUG_ON(!inode->i_sb->s_bdev->bd_disk->fops->direct_access);
-	return inode->i_sb->s_bdev->bd_disk->fops
-		->direct_access(inode->i_sb->s_bdev,sector,data);
+	struct block_device *bdev = inode->i_sb->s_bdev;
+	struct block_device_operations *ops = bdev->bd_disk->fops;
+
+	BUG_ON(!ops->direct_access);
+	return ops->direct_access(bdev, sector, kaddr, pfn);
 }
 
 static inline int
@@ -48,12 +50,13 @@ int
 ext2_clear_xip_target(struct inode *inode, int block)
 {
 	sector_t sector = block * (PAGE_SIZE/512);
-	unsigned long data;
+	void *kaddr;
+	unsigned long pfn;
 	int rc;
 
-	rc = __inode_direct_access(inode, sector, &data);
+	rc = __inode_direct_access(inode, sector, &kaddr, &pfn);
 	if (!rc)
-		clear_page((void*)data);
+		clear_page(kaddr);
 	return rc;
 }
 
@@ -74,7 +77,8 @@ ext2_get_xip_page(struct address_space *
 		   int create)
 {
 	int rc;
-	unsigned long data;
+	void *kaddr;
+	unsigned long pfn;
 	sector_t sector;
 
 	/* first, retrieve the sector number */
@@ -84,9 +88,9 @@ ext2_get_xip_page(struct address_space *
 
 	/* retrieve address of the target data */
 	rc = __inode_direct_access
-		(mapping->host, sector * (PAGE_SIZE/512), &data);
+		(mapping->host, sector * (PAGE_SIZE/512), &kaddr, &pfn);
 	if (!rc)
-		return virt_to_page(data);
+		return pfn_to_page(pfn);
 
  error:
 	return ERR_PTR(rc);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
