Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 789586B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 08:18:15 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so11323153wev.27
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:18:14 -0700 (PDT)
Received: from mail-we0-f178.google.com (mail-we0-f178.google.com [74.125.82.178])
        by mx.google.com with ESMTPS id e16si2002888wjr.27.2014.08.13.05.18.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 05:18:14 -0700 (PDT)
Received: by mail-we0-f178.google.com with SMTP id w61so11378449wes.9
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 05:18:13 -0700 (PDT)
Message-ID: <53EB5783.5020103@plexistor.com>
Date: Wed, 13 Aug 2014 15:18:11 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [RFC 6/9] SQUASHME: prd: Let each prd-device manage private memory
 region
References: <53EB5536.8020702@gmail.com>
In-Reply-To: <53EB5536.8020702@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

From: Boaz Harrosh <boaz@plexistor.com>

This patch removes any global memory information. And lets
each prd-device manage it's own memory region.

prd_alloc() Now receives phys_addr and disk_size and will
map that region, also prd_free will do the unmaping.

This is so we can support multiple discontinuous memory regions
in the next patch

Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 drivers/block/prd.c | 125 ++++++++++++++++++++++++++++++++--------------------
 1 file changed, 78 insertions(+), 47 deletions(-)

diff --git a/drivers/block/prd.c b/drivers/block/prd.c
index c4aeba7..6d96e6c 100644
--- a/drivers/block/prd.c
+++ b/drivers/block/prd.c
@@ -33,14 +33,6 @@
 #define PAGE_SECTORS_SHIFT	(PAGE_SHIFT - SECTOR_SHIFT)
 #define PAGE_SECTORS		(1 << PAGE_SECTORS_SHIFT)
 
-/*
- * driver-wide physical address and total_size - one single, contiguous memory
- * region that we divide up in to same-sized devices
- */
-phys_addr_t	phys_addr;
-void		*virt_addr;
-size_t		total_size;
-
 struct prd_device {
 	int			prd_number;
 
@@ -48,6 +40,7 @@ struct prd_device {
 	struct gendisk		*prd_disk;
 	struct list_head	prd_list;
 
+	/* One contiguous memory region per device */
 	phys_addr_t		phys_addr;
 	void			*virt_addr;
 	size_t			size;
@@ -254,27 +247,71 @@ MODULE_PARM_DESC(prd_count, "Number of prd devices to evenly split allocated spa
 static LIST_HEAD(prd_devices);
 static DEFINE_MUTEX(prd_devices_mutex);
 
-/* FIXME: move phys_addr, virt_addr, size calls up to caller */
-static struct prd_device *prd_alloc(int i)
+/* prd->phys_addr and prd->size need to be set.
+ * Will then set virt_addr if successful.
+ */
+int prd_mem_map(struct prd_device *prd)
+{
+	struct resource *res_mem;
+	int err;
+
+	res_mem = request_mem_region_exclusive(prd->phys_addr, prd->size,
+					       "pmem");
+	if (!res_mem) {
+		pr_warn("prd: request_mem_region_exclusive phys=0x%llx size=0x%zx failed\n",
+			   prd->phys_addr, prd->size);
+		return -EINVAL;
+	}
+
+	prd->virt_addr = ioremap_cache(prd->phys_addr, prd->size);
+	if (unlikely(!prd->virt_addr)) {
+		err = -ENOMEM;
+		goto out_release;
+	}
+	return 0;
+
+out_release:
+	release_mem_region(prd->phys_addr, prd->size);
+	return err;
+}
+
+void prd_mem_unmap(struct prd_device *prd)
+{
+	if (unlikely(!prd->virt_addr))
+		return;
+
+	iounmap(prd->virt_addr);
+	release_mem_region(prd->phys_addr, prd->size);
+	prd->virt_addr = NULL;
+}
+
+static struct prd_device *prd_alloc(phys_addr_t phys_addr, size_t disk_size,
+				    int i)
 {
 	struct prd_device *prd;
 	struct gendisk *disk;
-	size_t disk_size = total_size / prd_count;
-	size_t disk_sectors =  disk_size / 512;
+	int err;
 
 	prd = kzalloc(sizeof(*prd), GFP_KERNEL);
-	if (!prd)
+	if (unlikely(!prd)) {
+		err = -ENOMEM;
 		goto out;
+	}
 
 	prd->prd_number	= i;
-	prd->phys_addr = phys_addr + i * disk_size;
-	prd->virt_addr = virt_addr + i * disk_size;
+	prd->phys_addr = phys_addr;
 	prd->size = disk_size;
 
-	prd->prd_queue = blk_alloc_queue(GFP_KERNEL);
-	if (!prd->prd_queue)
+	err = prd_mem_map(prd);
+	if (unlikely(err))
 		goto out_free_dev;
 
+	prd->prd_queue = blk_alloc_queue(GFP_KERNEL);
+	if (unlikely(!prd->prd_queue)) {
+		err = -ENOMEM;
+		goto out_unmap;
+	}
+
 	blk_queue_make_request(prd->prd_queue, prd_make_request);
 	blk_queue_max_hw_sectors(prd->prd_queue, 1024);
 	blk_queue_bounce_limit(prd->prd_queue, BLK_BOUNCE_ANY);
@@ -285,9 +322,11 @@ static struct prd_device *prd_alloc(int i)
 	blk_queue_physical_block_size(prd->prd_queue, PAGE_SIZE);
 	prd->prd_queue->limits.io_min = 512; /* Don't use the accessor */
 
-	disk = prd->prd_disk = alloc_disk(0);
-	if (!disk)
+	disk = alloc_disk(0);
+	if (unlikely(!disk)) {
+		err = -ENOMEM;
 		goto out_free_queue;
+	}
 	disk->major		= prd_major;
 	disk->first_minor	= 0;
 	disk->fops		= &prd_fops;
@@ -295,22 +334,26 @@ static struct prd_device *prd_alloc(int i)
 	disk->queue		= prd->prd_queue;
 	disk->flags		= GENHD_FL_EXT_DEVT;
 	sprintf(disk->disk_name, "pmem%d", i);
-	set_capacity(disk, disk_sectors);
+	set_capacity(disk, disk_size >> SECTOR_SHIFT);
+	prd->prd_disk = disk;
 
 	return prd;
 
 out_free_queue:
 	blk_cleanup_queue(prd->prd_queue);
+out_unmap:
+	prd_mem_unmap(prd);
 out_free_dev:
 	kfree(prd);
 out:
-	return NULL;
+	return ERR_PTR(err);
 }
 
 static void prd_free(struct prd_device *prd)
 {
 	put_disk(prd->prd_disk);
 	blk_cleanup_queue(prd->prd_queue);
+	prd_mem_unmap(prd);
 	kfree(prd);
 }
 
@@ -348,34 +391,30 @@ out:
 static int __init prd_init(void)
 {
 	int result, i;
-	struct resource *res_mem;
 	struct prd_device *prd, *next;
+	phys_addr_t phys_addr;
+	size_t total_size, disk_size;
 
-	phys_addr  = (phys_addr_t) prd_start_gb * 1024 * 1024 * 1024;
-	total_size = (size_t)	   prd_size_gb  * 1024 * 1024 * 1024;
-
-	res_mem = request_mem_region_exclusive(phys_addr, total_size, "prd");
-	if (!res_mem)
-		return -ENOMEM;
-
-	virt_addr = ioremap_cache(phys_addr, total_size);
-
-	if (!virt_addr) {
-		result = -ENOMEM;
-		goto out_release;
+	if (unlikely(!prd_start_gb || !prd_size_gb || !prd_count)) {
+		pr_err("prd: prd_start_gb || prd_size_gb || prd_count are 0!!\n");
+		return -EINVAL;
 	}
 
+	phys_addr = (phys_addr_t) prd_start_gb * 1024 * 1024 * 1024;
+	total_size = (size_t)	   prd_size_gb  * 1024 * 1024 * 1024;
+	disk_size = total_size / prd_count;
+
 	result = register_blkdev(prd_major, "prd");
 	if (result < 0) {
 		result = -EIO;
-		goto out_unmap;
+		goto out;
 	} else if (result > 0)
 		prd_major = result;
 
 	for (i = 0; i < prd_count; i++) {
-		prd = prd_alloc(i);
-		if (!prd) {
-			result = -ENOMEM;
+		prd = prd_alloc(phys_addr + i * disk_size, disk_size, i);
+		if (IS_ERR(prd)) {
+			result = PTR_ERR(prd);
 			goto out_free;
 		}
 		list_add_tail(&prd->prd_list, &prd_devices);
@@ -396,12 +435,7 @@ out_free:
 		prd_free(prd);
 	}
 	unregister_blkdev(prd_major, "prd");
-
-out_unmap:
-	iounmap(virt_addr);
-
-out_release:
-	release_mem_region(phys_addr, total_size);
+out:
 	return result;
 }
 
@@ -415,9 +449,6 @@ static void __exit prd_exit(void)
 		prd_del_one(prd);
 
 	unregister_blkdev(prd_major, "prd");
-	iounmap(virt_addr);
-	release_mem_region(phys_addr, total_size);
-
 	pr_info("prd: module unloaded\n");
 }
 
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
