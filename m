Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id D544A6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:10:36 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so11194440wes.7
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:10:36 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
        by mx.google.com with ESMTPS id xt5si1309867wjc.36.2014.08.13.05.10.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 05:10:34 -0700 (PDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so679058wib.16
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:10:34 -0700 (PDT)
Message-ID: <53EB55B8.3000004@plexistor.com>
Date: Wed, 13 Aug 2014 15:10:32 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 1/9] prd: Initial version of Persistent RAM Driver
References: <53EB5536.8020702@gmail.com>
In-Reply-To: <53EB5536.8020702@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

From: Ross Zwisler <ross.zwisler@linux.intel.com>

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 drivers/block/Kconfig  |  41 +++++
 drivers/block/Makefile |   1 +
 drivers/block/prd.c    | 398 +++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 440 insertions(+)
 create mode 100644 drivers/block/prd.c

diff --git a/drivers/block/Kconfig b/drivers/block/Kconfig
index 014a1cf..463c45e 100644
--- a/drivers/block/Kconfig
+++ b/drivers/block/Kconfig
@@ -403,6 +403,47 @@ config BLK_DEV_XIP
 	  will prevent RAM block device backing store memory from being
 	  allocated from highmem (only a problem for highmem systems).
 
+config BLK_DEV_PMEM
+	tristate "Persistent memory block device support"
+	help
+	  Saying Y here will allow you to use a contiguous range of reserved
+	  memory as one or more block devices.  Memory for PRD should be
+	  reserved using the "memmap" kernel parameter.
+
+	  To compile this driver as a module, choose M here: the module will be
+	  called prd.
+
+	  Most normal users won't need this functionality, and can thus say N
+	  here.
+
+config BLK_DEV_PMEM_START
+	int "Offset in GiB of where to start claiming space"
+	default "0"
+	depends on BLK_DEV_PMEM
+	help
+	  Starting offset in GiB that PRD should use when claiming memory.  This
+	  memory needs to be reserved from the OS at boot time using the
+	  "memmap" kernel parameter.
+
+	  If you provide PRD with volatile memory it will act as a volatile
+	  RAM disk and your data will not be persistent.
+
+config BLK_DEV_PMEM_COUNT
+	int "Default number of PMEM disks"
+	default "4"
+	depends on BLK_DEV_PMEM
+	help
+	  Number of equal sized block devices that PRD should create.
+
+config BLK_DEV_PMEM_SIZE
+	int "Size in GiB of space to claim"
+	depends on BLK_DEV_PMEM
+	default "0"
+	help
+	  Amount of memory in GiB that PRD should use when creating block
+	  devices.  This memory needs to be reserved from the OS at
+	  boot time using the "memmap" kernel parameter.
+
 config CDROM_PKTCDVD
 	tristate "Packet writing on CD/DVD media"
 	depends on !UML
diff --git a/drivers/block/Makefile b/drivers/block/Makefile
index 02b688d..6e94c61 100644
--- a/drivers/block/Makefile
+++ b/drivers/block/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_PS3_VRAM)		+= ps3vram.o
 obj-$(CONFIG_ATARI_FLOPPY)	+= ataflop.o
 obj-$(CONFIG_AMIGA_Z2RAM)	+= z2ram.o
 obj-$(CONFIG_BLK_DEV_RAM)	+= brd.o
+obj-$(CONFIG_BLK_DEV_PMEM)	+= prd.o
 obj-$(CONFIG_BLK_DEV_LOOP)	+= loop.o
 obj-$(CONFIG_BLK_CPQ_DA)	+= cpqarray.o
 obj-$(CONFIG_BLK_CPQ_CISS_DA)  += cciss.o
diff --git a/drivers/block/prd.c b/drivers/block/prd.c
new file mode 100644
index 0000000..7684197
--- /dev/null
+++ b/drivers/block/prd.c
@@ -0,0 +1,398 @@
+/*
+ * Persistent RAM Driver
+ * Copyright (c) 2014, Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * This driver is heavily based on drivers/block/brd.c.
+ * Copyright (C) 2007 Nick Piggin
+ * Copyright (C) 2007 Novell Inc.
+ */
+
+#include <linux/bio.h>
+#include <linux/blkdev.h>
+#include <linux/fs.h>
+#include <linux/highmem.h>
+#include <linux/init.h>
+#include <linux/major.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/mutex.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+
+#define SECTOR_SHIFT		9
+#define PAGE_SECTORS_SHIFT	(PAGE_SHIFT - SECTOR_SHIFT)
+#define PAGE_SECTORS		(1 << PAGE_SECTORS_SHIFT)
+
+/*
+ * driver-wide physical address and total_size - one single, contiguous memory
+ * region that we divide up in to same-sized devices
+ */
+phys_addr_t	phys_addr;
+void		*virt_addr;
+size_t		total_size;
+
+struct prd_device {
+	int			prd_number;
+
+	struct request_queue	*prd_queue;
+	struct gendisk		*prd_disk;
+	struct list_head	prd_list;
+
+	phys_addr_t		phys_addr;
+	void			*virt_addr;
+	size_t			size;
+};
+
+/*
+ * direct translation from (prd,sector) => void*
+ * We do not require that sector be page aligned.
+ * The return value will point to the beginning of the page containing the
+ * given sector, not to the sector itself.
+ */
+static void *prd_lookup_pg_addr(struct prd_device *prd, sector_t sector)
+{
+	size_t page_offset = sector >> PAGE_SECTORS_SHIFT;
+	size_t offset = page_offset << PAGE_SHIFT;
+
+	BUG_ON(offset >= prd->size);
+	return prd->virt_addr + offset;
+}
+
+/* sector must be page aligned */
+static unsigned long prd_lookup_pfn(struct prd_device *prd, sector_t sector)
+{
+	size_t page_offset = sector >> PAGE_SECTORS_SHIFT;
+
+	BUG_ON(sector & (PAGE_SECTORS - 1));
+	return (prd->phys_addr >> PAGE_SHIFT) + page_offset;
+}
+
+/*
+ * sector is not required to be page aligned.
+ * n is at most a single page, but could be less.
+ */
+static void copy_to_prd(struct prd_device *prd, const void *src,
+			sector_t sector, size_t n)
+{
+	void *dst;
+	unsigned int offset = (sector & (PAGE_SECTORS - 1)) << SECTOR_SHIFT;
+	size_t copy;
+
+	BUG_ON(n > PAGE_SIZE);
+
+	copy = min_t(size_t, n, PAGE_SIZE - offset);
+	dst = prd_lookup_pg_addr(prd, sector);
+	memcpy(dst + offset, src, copy);
+
+	if (copy < n) {
+		src += copy;
+		sector += copy >> SECTOR_SHIFT;
+		copy = n - copy;
+		dst = prd_lookup_pg_addr(prd, sector);
+		memcpy(dst, src, copy);
+	}
+}
+
+/*
+ * sector is not required to be page aligned.
+ * n is at most a single page, but could be less.
+ */
+static void copy_from_prd(void *dst, struct prd_device *prd,
+			  sector_t sector, size_t n)
+{
+	void *src;
+	unsigned int offset = (sector & (PAGE_SECTORS - 1)) << SECTOR_SHIFT;
+	size_t copy;
+
+	BUG_ON(n > PAGE_SIZE);
+
+	copy = min_t(size_t, n, PAGE_SIZE - offset);
+	src = prd_lookup_pg_addr(prd, sector);
+
+	memcpy(dst, src + offset, copy);
+
+	if (copy < n) {
+		dst += copy;
+		sector += copy >> SECTOR_SHIFT;
+		copy = n - copy;
+		src = prd_lookup_pg_addr(prd, sector);
+		memcpy(dst, src, copy);
+	}
+}
+
+static void prd_do_bvec(struct prd_device *prd, struct page *page,
+			unsigned int len, unsigned int off, int rw,
+			sector_t sector)
+{
+	void *mem = kmap_atomic(page);
+
+	if (rw == READ) {
+		copy_from_prd(mem + off, prd, sector, len);
+		flush_dcache_page(page);
+	} else {
+		/*
+		 * FIXME: Need more involved flushing to ensure that writes to
+		 * NVDIMMs are actually durable before returning.
+		 */
+		flush_dcache_page(page);
+		copy_to_prd(prd, mem + off, sector, len);
+	}
+
+	kunmap_atomic(mem);
+}
+
+static void prd_make_request(struct request_queue *q, struct bio *bio)
+{
+	struct block_device *bdev = bio->bi_bdev;
+	struct prd_device *prd = bdev->bd_disk->private_data;
+	int rw;
+	struct bio_vec bvec;
+	sector_t sector;
+	struct bvec_iter iter;
+	int err = 0;
+
+	sector = bio->bi_iter.bi_sector;
+	if (bio_end_sector(bio) > get_capacity(bdev->bd_disk)) {
+		err = -EIO;
+		goto out;
+	}
+
+	BUG_ON(bio->bi_rw & REQ_DISCARD);
+
+	rw = bio_rw(bio);
+	if (rw == READA)
+		rw = READ;
+
+	bio_for_each_segment(bvec, bio, iter) {
+		unsigned int len = bvec.bv_len;
+
+		BUG_ON(len > PAGE_SIZE);
+		prd_do_bvec(prd, bvec.bv_page, len,
+			    bvec.bv_offset, rw, sector);
+		sector += len >> SECTOR_SHIFT;
+	}
+
+out:
+	bio_endio(bio, err);
+}
+
+static long prd_direct_access(struct block_device *bdev, sector_t sector,
+			      void **kaddr, unsigned long *pfn, long size)
+{
+	struct prd_device *prd = bdev->bd_disk->private_data;
+
+	if (!prd)
+		return -ENODEV;
+
+	*kaddr = prd_lookup_pg_addr(prd, sector);
+	*pfn = prd_lookup_pfn(prd, sector);
+
+	return size;
+}
+
+static const struct block_device_operations prd_fops = {
+	.owner =		THIS_MODULE,
+	.direct_access =	prd_direct_access,
+};
+
+/* Kernel module stuff */
+static int prd_start_gb = CONFIG_BLK_DEV_PMEM_START;
+module_param(prd_start_gb, int, S_IRUGO);
+MODULE_PARM_DESC(prd_start_gb, "Offset in GB of where to start claiming space");
+
+static int prd_size_gb = CONFIG_BLK_DEV_PMEM_SIZE;
+module_param(prd_size_gb,  int, S_IRUGO);
+MODULE_PARM_DESC(prd_size_gb,  "Total size in GB of space to claim for all disks");
+
+static int prd_major;
+module_param(prd_major, int, 0);
+MODULE_PARM_DESC(prd_major,  "Major number to request for this driver");
+
+static int prd_count = CONFIG_BLK_DEV_PMEM_COUNT;
+module_param(prd_count, int, S_IRUGO);
+MODULE_PARM_DESC(prd_count, "Number of prd devices to evenly split allocated space");
+
+static LIST_HEAD(prd_devices);
+static DEFINE_MUTEX(prd_devices_mutex);
+
+/* FIXME: move phys_addr, virt_addr, size calls up to caller */
+static struct prd_device *prd_alloc(int i)
+{
+	struct prd_device *prd;
+	struct gendisk *disk;
+	size_t disk_size = total_size / prd_count;
+	size_t disk_sectors =  disk_size / 512;
+
+	prd = kzalloc(sizeof(*prd), GFP_KERNEL);
+	if (!prd)
+		goto out;
+
+	prd->prd_number	= i;
+	prd->phys_addr = phys_addr + i * disk_size;
+	prd->virt_addr = virt_addr + i * disk_size;
+	prd->size = disk_size;
+
+	prd->prd_queue = blk_alloc_queue(GFP_KERNEL);
+	if (!prd->prd_queue)
+		goto out_free_dev;
+
+	blk_queue_make_request(prd->prd_queue, prd_make_request);
+	blk_queue_max_hw_sectors(prd->prd_queue, 1024);
+	blk_queue_bounce_limit(prd->prd_queue, BLK_BOUNCE_ANY);
+
+	disk = prd->prd_disk = alloc_disk(0);
+	if (!disk)
+		goto out_free_queue;
+	disk->major		= prd_major;
+	disk->first_minor	= 0;
+	disk->fops		= &prd_fops;
+	disk->private_data	= prd;
+	disk->queue		= prd->prd_queue;
+	disk->flags		= GENHD_FL_EXT_DEVT;
+	sprintf(disk->disk_name, "pmem%d", i);
+	set_capacity(disk, disk_sectors);
+
+	return prd;
+
+out_free_queue:
+	blk_cleanup_queue(prd->prd_queue);
+out_free_dev:
+	kfree(prd);
+out:
+	return NULL;
+}
+
+static void prd_free(struct prd_device *prd)
+{
+	put_disk(prd->prd_disk);
+	blk_cleanup_queue(prd->prd_queue);
+	kfree(prd);
+}
+
+static struct prd_device *prd_init_one(int i)
+{
+	struct prd_device *prd;
+
+	list_for_each_entry(prd, &prd_devices, prd_list) {
+		if (prd->prd_number == i)
+			goto out;
+	}
+
+	prd = prd_alloc(i);
+	if (prd) {
+		add_disk(prd->prd_disk);
+		list_add_tail(&prd->prd_list, &prd_devices);
+	}
+out:
+	return prd;
+}
+
+static void prd_del_one(struct prd_device *prd)
+{
+	list_del(&prd->prd_list);
+	del_gendisk(prd->prd_disk);
+	prd_free(prd);
+}
+
+static struct kobject *prd_probe(dev_t dev, int *part, void *data)
+{
+	struct prd_device *prd;
+	struct kobject *kobj;
+
+	mutex_lock(&prd_devices_mutex);
+	prd = prd_init_one(MINOR(dev));
+	kobj = prd ? get_disk(prd->prd_disk) : NULL;
+	mutex_unlock(&prd_devices_mutex);
+
+	return kobj;
+}
+
+static int __init prd_init(void)
+{
+	int result, i;
+	struct resource *res_mem;
+	struct prd_device *prd, *next;
+
+	phys_addr  = (phys_addr_t) prd_start_gb * 1024 * 1024 * 1024;
+	total_size = (size_t)	   prd_size_gb  * 1024 * 1024 * 1024;
+
+	res_mem = request_mem_region_exclusive(phys_addr, total_size, "prd");
+	if (!res_mem)
+		return -ENOMEM;
+
+	virt_addr = ioremap_cache(phys_addr, total_size);
+
+	if (!virt_addr) {
+		result = -ENOMEM;
+		goto out_release;
+	}
+
+	result = register_blkdev(prd_major, "prd");
+	if (result < 0) {
+		result = -EIO;
+		goto out_unmap;
+	} else if (result > 0)
+		prd_major = result;
+
+	for (i = 0; i < prd_count; i++) {
+		prd = prd_alloc(i);
+		if (!prd) {
+			result = -ENOMEM;
+			goto out_free;
+		}
+		list_add_tail(&prd->prd_list, &prd_devices);
+	}
+
+	list_for_each_entry(prd, &prd_devices, prd_list)
+		add_disk(prd->prd_disk);
+
+	blk_register_region(MKDEV(prd_major, 0), 0,
+				  THIS_MODULE, prd_probe, NULL, NULL);
+
+	pr_info("prd: module loaded\n");
+	return 0;
+
+out_free:
+	list_for_each_entry_safe(prd, next, &prd_devices, prd_list) {
+		list_del(&prd->prd_list);
+		prd_free(prd);
+	}
+	unregister_blkdev(prd_major, "prd");
+
+out_unmap:
+	iounmap(virt_addr);
+
+out_release:
+	release_mem_region(phys_addr, total_size);
+	return result;
+}
+
+static void __exit prd_exit(void)
+{
+	struct prd_device *prd, *next;
+
+	blk_unregister_region(MKDEV(prd_major, 0), 0);
+
+	list_for_each_entry_safe(prd, next, &prd_devices, prd_list)
+		prd_del_one(prd);
+
+	unregister_blkdev(prd_major, "prd");
+	iounmap(virt_addr);
+	release_mem_region(phys_addr, total_size);
+
+	pr_info("prd: module unloaded\n");
+}
+
+MODULE_AUTHOR("Ross Zwisler <ross.zwisler@linux.intel.com>");
+MODULE_LICENSE("GPL");
+module_init(prd_init);
+module_exit(prd_exit);
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
