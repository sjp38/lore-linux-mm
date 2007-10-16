From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: [patch][rfc] rewrite ramdisk
Date: Tue, 16 Oct 2007 17:47:12 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <m1abqjirmd.fsf@ebiederm.dsl.xmission.com> <200710161808.06405.nickpiggin@yahoo.com.au>
In-Reply-To: <200710161808.06405.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_AyGFHyNPjuikPep"
Message-Id: <200710161747.12968.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

--Boundary-00=_AyGFHyNPjuikPep
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 16 October 2007 18:08, Nick Piggin wrote:
> On Tuesday 16 October 2007 14:57, Eric W. Biederman wrote:

> > > What magic restrictions on page allocations? Actually we have
> > > fewer restrictions on page allocations because we can use
> > > highmem!
> >
> > With the proposed rewrite yes.

Here's a quick first hack...

Comments?

--Boundary-00=_AyGFHyNPjuikPep
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="rd2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="rd2.patch"

This is a rewrite of the ramdisk block device driver.

The old one is really difficult because it effectively implements a block
device which serves data out of its own buffer cache. This makes it crap.

The new one is more like a regular block device driver. It has no idea
about vm/vfs stuff. It's backing store is similar to the buffer cache
(a simple radix-tree of pages), but it doesn't know anything about page
cache (the pages in the radix tree are not pagecache pages).

There is one slight downside -- direct block device access and filesystem
metadata access goes through an extra copy and gets stored in RAM twice.
However, this downside is only slight, because the real buffercache of the
device is now reclaimable (because we're not playing crazy games with it),
so under memory intensive situations, footprint should effectively be the
same -- maybe even a slight advantage to the new driver because it can also
reclaim buffer heads.

The fact that it now goes through all the regular vm/fs paths makes it
much more useful for testing, too.

---
Index: linux-2.6/drivers/block/Kconfig
===================================================================
--- linux-2.6.orig/drivers/block/Kconfig
+++ linux-2.6/drivers/block/Kconfig
@@ -329,6 +329,7 @@ config BLK_DEV_UB
 
 config BLK_DEV_RAM
 	tristate "RAM disk support"
+	depends on !BLK_DEV_BRD
 	---help---
 	  Saying Y here will allow you to use a portion of your RAM memory as
 	  a block device, so that you can make file systems on it, read and
@@ -346,10 +347,24 @@ config BLK_DEV_RAM
 	  Most normal users won't need the RAM disk functionality, and can
 	  thus say N here.
 
+config BLK_DEV_BRD
+	tristate "RAM block device support"
+	---help---
+	  This is a new  based block driver that replaces BLK_DEV_RAM.
+
+	  Note that the kernel command line option "ramdisk=XX" is now
+	  obsolete. For details, read <file:Documentation/ramdisk.txt>.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called rd.
+
+	  Most normal users won't need the RAM disk functionality, and can
+	  thus say N here.
+
 config BLK_DEV_RAM_COUNT
 	int "Default number of RAM disks"
 	default "16"
-	depends on BLK_DEV_RAM
+	depends on BLK_DEV_RAM || BLK_DEV_BRD
 	help
 	  The default value is 16 RAM disks. Change this if you know what
 	  are doing. If you boot from a filesystem that needs to be extracted
@@ -357,7 +372,7 @@ config BLK_DEV_RAM_COUNT
 
 config BLK_DEV_RAM_SIZE
 	int "Default RAM disk size (kbytes)"
-	depends on BLK_DEV_RAM
+	depends on BLK_DEV_RAM || BLK_DEV_BRD
 	default "4096"
 	help
 	  The default value is 4096 kilobytes. Only change this if you know
Index: linux-2.6/drivers/block/Makefile
===================================================================
--- linux-2.6.orig/drivers/block/Makefile
+++ linux-2.6/drivers/block/Makefile
@@ -12,6 +12,7 @@ obj-$(CONFIG_PS3_DISK)		+= ps3disk.o
 obj-$(CONFIG_ATARI_FLOPPY)	+= ataflop.o
 obj-$(CONFIG_AMIGA_Z2RAM)	+= z2ram.o
 obj-$(CONFIG_BLK_DEV_RAM)	+= rd.o
+obj-$(CONFIG_BLK_DEV_BRD)	+= brd.o
 obj-$(CONFIG_BLK_DEV_LOOP)	+= loop.o
 obj-$(CONFIG_BLK_DEV_PS2)	+= ps2esdi.o
 obj-$(CONFIG_BLK_DEV_XD)	+= xd.o
Index: linux-2.6/drivers/block/brd.c
===================================================================
--- /dev/null
+++ linux-2.6/drivers/block/brd.c
@@ -0,0 +1,467 @@
+/*
+ * Ram backed block device driver.
+ *
+ * Copyright (C) 2007 Nick Piggin
+ * Copyright (C) 2007 Novell Inc.
+ *
+ * Parts derived from drivers/block/rd.c, and drivers/block/loop.c.
+ */
+
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/major.h>
+#include <linux/blkdev.h>
+#include <linux/bio.h>
+#include <linux/highmem.h>
+#include <linux/gfp.h>
+#include <linux/radix-tree.h>
+
+#include <asm/uaccess.h>
+
+#define PAGE_SECTORS (1 << (PAGE_SHIFT - 9))
+
+struct brd_device {
+	int		brd_number;
+	int		brd_refcnt;
+	loff_t		brd_offset;
+	loff_t		brd_sizelimit;
+	unsigned	brd_blocksize;
+
+	struct request_queue	*brd_queue;
+	struct gendisk		*brd_disk;
+
+	spinlock_t		brd_lock;
+	struct radix_tree_root	brd_pages;
+
+	struct list_head	brd_list;
+};
+
+static struct page *brd_lookup_page(struct brd_device *brd, sector_t sector)
+{
+	unsigned long idx;
+	struct page *page;
+
+	rcu_read_lock();
+	idx = sector >> (PAGE_SHIFT - 9);
+	page = radix_tree_lookup(&brd->brd_pages, idx);
+	rcu_read_unlock();
+
+	BUG_ON(page && page->index != idx);
+
+	return page;
+}
+
+static struct page *brd_insert_page(struct brd_device *brd, sector_t sector)
+{
+	unsigned long idx;
+	struct page *page;
+
+	page = brd_lookup_page(brd, sector);
+	if (page)
+		return page;
+
+	page = alloc_page(GFP_NOIO | __GFP_HIGHMEM | __GFP_ZERO);
+	if (!page)
+		return NULL;
+
+	if (radix_tree_preload(GFP_NOIO)) {
+		__free_page(page);
+		return NULL;
+	}
+
+	spin_lock(&brd->brd_lock);
+	idx = sector >> (PAGE_SHIFT - 9);
+	if (radix_tree_insert(&brd->brd_pages, idx, page)) {
+		__free_page(page);
+		page = radix_tree_lookup(&brd->brd_pages, idx);
+		BUG_ON(!page);
+		BUG_ON(page->index != idx);
+	} else
+		page->index = idx;
+	spin_unlock(&brd->brd_lock);
+
+	radix_tree_preload_end();
+
+	return page;
+}
+
+#define FREE_BATCH 16
+static void brd_free_pages(struct brd_device *brd)
+{
+	unsigned long pos = 0;
+	struct page *pages[FREE_BATCH];
+	int nr_pages;
+
+	do {
+		int i;
+
+		nr_pages = radix_tree_gang_lookup(&brd->brd_pages,
+				(void **)pages, pos, FREE_BATCH);
+
+		for (i = 0; i < nr_pages; i++) {
+			BUG_ON(pages[i]->index < pos);
+			pos = pages[i]->index+1;
+			__free_page(pages[i]);
+		}
+
+	} while (nr_pages == FREE_BATCH);
+}
+
+static int copy_to_brd_setup(struct brd_device *brd, sector_t sector, size_t n)
+{
+	unsigned int offset = (sector & (PAGE_SECTORS-1)) << 9;
+	size_t copy;
+
+	copy = min((unsigned long)n, PAGE_SIZE - offset);
+	if (!brd_insert_page(brd, sector))
+		return -ENOMEM;
+	if (copy < n) {
+		if (!brd_insert_page(brd, sector))
+			return -ENOMEM;
+	}
+	return 0;
+}
+
+static void copy_to_brd(struct brd_device *brd, const void *src, sector_t sector, size_t n)
+{
+	struct page *page;
+	void *dst;
+	unsigned int offset = (sector & (PAGE_SECTORS-1)) << 9;
+	size_t copy;
+
+	copy = min((unsigned long)n, PAGE_SIZE - offset);
+	page = brd_lookup_page(brd, sector);
+	BUG_ON(!page);
+
+	dst = kmap_atomic(page, KM_USER1);
+	memcpy(dst + offset, src, copy);
+	kunmap_atomic(dst, KM_USER1);
+
+	if (copy < n) {
+		copy = n - copy;
+		page = brd_lookup_page(brd, sector);
+		BUG_ON(!page);
+
+		dst = kmap_atomic(page, KM_USER1);
+		memcpy(dst, src, copy);
+		kunmap_atomic(dst, KM_USER1);
+	}
+}
+
+static void copy_from_brd(void *dst, struct brd_device *brd, sector_t sector, size_t n)
+{
+	struct page *page;
+	const void *src;
+	unsigned int offset = (sector & (PAGE_SECTORS-1)) << 9;
+	size_t copy;
+
+	copy = min((unsigned long)n, PAGE_SIZE - offset);
+	page = brd_lookup_page(brd, sector);
+	if (page) {
+		src = kmap_atomic(page, KM_USER1);
+		memcpy(dst, src + offset, copy);
+		kunmap_atomic(src, KM_USER1);
+	} else
+		memset(dst, 0, copy);
+
+	if (copy < n) {
+		copy = n - copy;
+		page = brd_lookup_page(brd, sector);
+		if (page) {
+			src = kmap_atomic(page, KM_USER1);
+			memcpy(dst, src, copy);
+			kunmap_atomic(src, KM_USER1);
+		} else
+			memset(dst, 0, copy);
+	}
+}
+
+static int brd_do_bvec(struct brd_device *brd, struct page *page, unsigned int len, unsigned int off, int rw, sector_t sector)
+{
+	void *mem;
+	int err = 0;
+
+	if (rw != READ) {
+		err = copy_to_brd_setup(brd, sector, len);
+		if (err)
+			goto out;
+	}
+
+	mem = kmap_atomic(page, KM_USER0);
+	if (rw == READ) {
+		copy_from_brd(mem + off, brd, sector, len);
+		flush_dcache_page(page);
+	} else
+		copy_to_brd(brd, mem + off, sector, len);
+	kunmap_atomic(mem, KM_USER0);
+
+out:
+	return err;
+}
+
+static int brd_make_request(struct request_queue *q, struct bio *bio)
+{
+	struct block_device *bdev = bio->bi_bdev;
+	struct brd_device *brd = bdev->bd_disk->private_data;
+	int rw;
+	struct bio_vec *bvec;
+	sector_t sector;
+	int i;
+	int err = -EIO;
+
+	sector = bio->bi_sector;
+	if (sector + (bio->bi_size >> 9) > get_capacity(bdev->bd_disk))
+		goto out;
+
+	rw = bio_rw(bio);
+	if (rw == READA)
+		rw = READ;
+
+	bio_for_each_segment(bvec, bio, i) {
+		unsigned int len = bvec->bv_len;
+		err = brd_do_bvec(brd, bvec->bv_page, len, bvec->bv_offset, rw, sector);
+		if (err)
+			break;
+		sector += len >> 9;
+	}
+
+out:
+	bio_endio(bio, err);
+
+	return 0;
+}
+
+static int brd_ioctl(struct inode *inode, struct file *file,
+			unsigned int cmd, unsigned long arg)
+{
+	int error;
+	struct block_device *bdev = inode->i_bdev;
+	struct brd_device *brd = bdev->bd_disk->private_data;
+
+	if (cmd != BLKFLSBUF)
+		return -ENOTTY;
+
+	/*
+	 * ram device BLKFLSBUF has special semantics, we want to actually
+	 * release and destroy the ramdisk data.
+	 */
+	mutex_lock(&bdev->bd_mutex);
+	error = -EBUSY;
+	if (bdev->bd_openers <= 1) {
+		brd_free_pages(brd);
+		error = 0;
+	}
+	mutex_unlock(&bdev->bd_mutex);
+
+	return error;
+}
+
+static struct block_device_operations brd_fops = {
+	.owner =	THIS_MODULE,
+	.ioctl =	brd_ioctl,
+};
+
+/*
+ * And now the modules code and kernel interface.
+ */
+static int rd_nr;
+static int rd_size = CONFIG_BLK_DEV_RAM_SIZE;
+module_param(rd_nr, int, 0);
+MODULE_PARM_DESC(rd_nr, "Maximum number of brd devices");
+module_param(rd_size, int, 0);
+MODULE_PARM_DESC(rd_size, "Size of each RAM disk in kbytes.");
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_BLOCKDEV_MAJOR(RAMDISK_MAJOR);
+
+/* options - nonmodular */
+#ifndef MODULE
+static int __init ramdisk_size(char *str)
+{
+	rd_size = simple_strtol(str,NULL,0);
+	return 1;
+}
+static int __init ramdisk_size2(char *str)
+{
+	return ramdisk_size(str);
+}
+static int __init rd_nr(char *str)
+{
+	rd_nr = simple_strtol(str, NULL, 0);
+	return 1;
+}
+__setup("ramdisk=", ramdisk_size);
+__setup("ramdisk_size=", ramdisk_size2);
+__setup("rd_nr=", rd_nr);
+#endif
+
+
+static LIST_HEAD(brd_devices);
+static DEFINE_MUTEX(brd_devices_mutex);
+
+static struct brd_device *brd_alloc(int i)
+{
+	struct brd_device *brd;
+	struct gendisk *disk;
+
+	brd = kzalloc(sizeof(*brd), GFP_KERNEL);
+	if (!brd)
+		goto out;
+	brd->brd_number		= i;
+	spin_lock_init(&brd->brd_lock);
+	INIT_RADIX_TREE(&brd->brd_pages, GFP_ATOMIC);
+
+	brd->brd_queue = blk_alloc_queue(GFP_KERNEL);
+	if (!brd->brd_queue)
+		goto out_free_dev;
+	blk_queue_make_request(brd->brd_queue, brd_make_request);
+	blk_queue_max_sectors(brd->brd_queue, 1024);
+	blk_queue_bounce_limit(brd->brd_queue, BLK_BOUNCE_ANY);
+
+	disk = brd->brd_disk = alloc_disk(1);
+	if (!disk)
+		goto out_free_queue;
+	disk->major		= RAMDISK_MAJOR;
+	disk->first_minor	= i;
+	disk->fops		= &brd_fops;
+	disk->private_data	= brd;
+	disk->queue		= brd->brd_queue;
+	sprintf(disk->disk_name, "ram%d", i);
+	set_capacity(disk, rd_size * 2);
+
+	return brd;
+
+out_free_queue:
+	blk_cleanup_queue(brd->brd_queue);
+out_free_dev:
+	kfree(brd);
+out:
+	return NULL;
+}
+
+static void brd_free(struct brd_device *brd)
+{
+	put_disk(brd->brd_disk);
+	blk_cleanup_queue(brd->brd_queue);
+	brd_free_pages(brd);
+	kfree(brd);
+}
+
+static struct brd_device *brd_init_one(int i)
+{
+	struct brd_device *brd;
+
+	list_for_each_entry(brd, &brd_devices, brd_list) {
+		if (brd->brd_number == i)
+			goto out;
+	}
+
+	brd = brd_alloc(i);
+	if (brd) {
+		add_disk(brd->brd_disk);
+		list_add_tail(&brd->brd_list, &brd_devices);
+	}
+out:
+	return brd;
+}
+
+static void brd_del_one(struct brd_device *brd)
+{
+	list_del(&brd->brd_list);
+	del_gendisk(brd->brd_disk);
+	brd_free(brd);
+}
+
+static struct kobject *brd_probe(dev_t dev, int *part, void *data)
+{
+	struct brd_device *brd;
+	struct kobject *kobj;
+
+	mutex_lock(&brd_devices_mutex);
+	brd = brd_init_one(dev & MINORMASK);
+	kobj = brd ? get_disk(brd->brd_disk) : ERR_PTR(-ENOMEM);
+	mutex_unlock(&brd_devices_mutex);
+
+	*part = 0;
+	return kobj;
+}
+
+static int __init brd_init(void)
+{
+	int i, nr;
+	unsigned long range;
+	struct brd_device *brd, *next;
+
+	/*
+	 * brd module now has a feature to instantiate underlying device
+	 * structure on-demand, provided that there is an access dev node.
+	 * However, this will not work well with user space tool that doesn't
+	 * know about such "feature".  In order to not break any existing
+	 * tool, we do the following:
+	 *
+	 * (1) if rd_nr is specified, create that many upfront, and this
+	 *     also becomes a hard limit.
+	 * (2) if rd_nr is not specified, create 1 rd device on module
+	 *     load, user can further extend brd device by create dev node
+	 *     themselves and have kernel automatically instantiate actual
+	 *     device on-demand.
+	 */
+	if (rd_nr > 1UL << MINORBITS)
+		return -EINVAL;
+
+	if (rd_nr) {
+		nr = rd_nr;
+		range = rd_nr;
+	} else {
+		nr = CONFIG_BLK_DEV_RAM_COUNT;
+		range = 1UL << MINORBITS;
+	}
+
+	if (register_blkdev(RAMDISK_MAJOR, "ramdisk"))
+		return -EIO;
+
+	for (i = 0; i < nr; i++) {
+		brd = brd_alloc(i);
+		if (!brd)
+			goto out_free;
+		list_add_tail(&brd->brd_list, &brd_devices);
+	}
+
+	/* point of no return */
+
+	list_for_each_entry(brd, &brd_devices, brd_list)
+		add_disk(brd->brd_disk);
+
+	blk_register_region(MKDEV(RAMDISK_MAJOR, 0), range,
+				  THIS_MODULE, brd_probe, NULL, NULL);
+
+	printk(KERN_INFO "brd: module loaded\n");
+	return 0;
+
+out_free:
+	list_for_each_entry_safe(brd, next, &brd_devices, brd_list) {
+		list_del(&brd->brd_list);
+		brd_free(brd);
+	}
+
+	unregister_blkdev(RAMDISK_MAJOR, "brd");
+	return -ENOMEM;
+}
+
+static void __exit brd_exit(void)
+{
+	unsigned long range;
+	struct brd_device *brd, *next;
+
+	range = rd_nr ? rd_nr :  1UL << MINORBITS;
+
+	list_for_each_entry_safe(brd, next, &brd_devices, brd_list)
+		brd_del_one(brd);
+
+	blk_unregister_region(MKDEV(RAMDISK_MAJOR, 0), range);
+	unregister_blkdev(RAMDISK_MAJOR, "ramdisk");
+}
+
+module_init(brd_init);
+module_exit(brd_exit);
+

--Boundary-00=_AyGFHyNPjuikPep--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
