Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id F15906B0035
	for <linux-mm@kvack.org>; Thu, 14 Aug 2014 09:07:17 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id n3so2261970wiv.13
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 06:07:17 -0700 (PDT)
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
        by mx.google.com with ESMTPS id hk5si6313175wjb.112.2014.08.14.06.07.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 Aug 2014 06:07:15 -0700 (PDT)
Received: by mail-we0-f175.google.com with SMTP id t60so1071306wes.20
        for <linux-mm@kvack.org>; Thu, 14 Aug 2014 06:07:15 -0700 (PDT)
Message-ID: <53ECB480.4060104@plexistor.com>
Date: Thu, 14 Aug 2014 16:07:12 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: [PATCH 5/9 v2] SQUASHME: prd: Last fixes for partitions
References: <53EB5536.8020702@gmail.com> <53EB5709.4090401@plexistor.com>
In-Reply-To: <53EB5709.4090401@plexistor.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

From: Boaz Harrosh <boaz@plexistor.com>

This streamlines prd with the latest brd code.

In prd we do not allocate new devices dynamically on devnod
access, because we need parameterization of each device. So
the dynamic allocation in prd_init_one is removed.

Therefor prd_init_one only called from prd_prob is moved
there, now that it is small.

And other small fixes regarding partitions

Signed-off-by: Boaz Harrosh <boaz@plexistor.com>
---
 drivers/block/prd.c | 47 ++++++++++++++++++++++++-----------------------
 1 file changed, 24 insertions(+), 23 deletions(-)

diff --git a/drivers/block/prd.c b/drivers/block/prd.c
index 62af81e..f117ca5 100644
--- a/drivers/block/prd.c
+++ b/drivers/block/prd.c
@@ -218,13 +218,13 @@ static long prd_direct_access(struct block_device *bdev, sector_t sector,
 {
 	struct prd_device *prd = bdev->bd_disk->private_data;
 
-	if (!prd)
+	if (unlikely(!prd))
 		return -ENODEV;
 
 	*kaddr = prd_lookup_pg_addr(prd, sector);
 	*pfn = prd_lookup_pfn(prd, sector);
 
-	return size;
+	return min_t(long, size, prd->size - (sector << SECTOR_SHIFT));
 }
 
 static const struct block_device_operations prd_fops = {
@@ -279,6 +279,12 @@ static struct prd_device *prd_alloc(int i)
 	blk_queue_max_hw_sectors(prd->prd_queue, 1024);
 	blk_queue_bounce_limit(prd->prd_queue, BLK_BOUNCE_ANY);
 
+	/* This is so fdisk will align partitions on 4k, because of
+	 * direct_access API needing 4k alignment, returning a PFN
+	 */
+	blk_queue_physical_block_size(prd->prd_queue, PAGE_SIZE);
+	prd->prd_queue->limits.io_min = 512; /* Don't use the accessor */
+
 	disk = prd->prd_disk = alloc_disk(0);
 	if (!disk)
 		goto out_free_queue;
@@ -308,24 +314,6 @@ static void prd_free(struct prd_device *prd)
 	kfree(prd);
 }
 
-static struct prd_device *prd_init_one(int i)
-{
-	struct prd_device *prd;
-
-	list_for_each_entry(prd, &prd_devices, prd_list) {
-		if (prd->prd_number == i)
-			goto out;
-	}
-
-	prd = prd_alloc(i);
-	if (prd) {
-		add_disk(prd->prd_disk);
-		list_add_tail(&prd->prd_list, &prd_devices);
-	}
-out:
-	return prd;
-}
-
 static void prd_del_one(struct prd_device *prd)
 {
 	list_del(&prd->prd_list);
@@ -333,16 +321,27 @@ static void prd_del_one(struct prd_device *prd)
 	prd_free(prd);
 }
 
+/*FIXME: Actually in our driver prd_probe is never used. Can be removed */
 static struct kobject *prd_probe(dev_t dev, int *part, void *data)
 {
 	struct prd_device *prd;
 	struct kobject *kobj;
+	int number = MINOR(dev);
 
 	mutex_lock(&prd_devices_mutex);
-	prd = prd_init_one(MINOR(dev));
-	kobj = prd ? get_disk(prd->prd_disk) : NULL;
-	mutex_unlock(&prd_devices_mutex);
 
+	list_for_each_entry(prd, &prd_devices, prd_list) {
+		if (prd->prd_number == number) {
+			kobj = get_disk(prd->prd_disk);
+			goto out;
+		}
+	}
+
+	pr_err("prd: prd_probe: Unexpected parameter=%d\n", number);
+	kobj = NULL;
+
+out:
+	mutex_unlock(&prd_devices_mutex);
 	return kobj;
 }
 
@@ -424,5 +423,7 @@ static void __exit prd_exit(void)
 
 MODULE_AUTHOR("Ross Zwisler <ross.zwisler@linux.intel.com>");
 MODULE_LICENSE("GPL");
+MODULE_ALIAS("pmem");
+
 module_init(prd_init);
 module_exit(prd_exit);
-- 
1.9.3


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
