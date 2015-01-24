Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E98D26B0032
	for <linux-mm@kvack.org>; Sat, 24 Jan 2015 08:46:08 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so2747209pac.13
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 05:46:08 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id xi3si5603031pab.118.2015.01.24.05.46.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 24 Jan 2015 05:46:08 -0800 (PST)
Received: by mail-pd0-f178.google.com with SMTP id y10so3200219pdj.9
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 05:46:07 -0800 (PST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH] zram: free meta table in zram_meta_free
Date: Sat, 24 Jan 2015 21:45:53 +0800
Message-Id: <1422107153-9701-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

zram_meta_alloc() and zram_meta_free() are a pair.
In zram_meta_alloc(), meta table is allocated. So it it better to free
it in zram_meta_free().

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c |   28 ++++++++++++++--------------
 drivers/block/zram/zram_drv.h |    1 +
 2 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 9bbc302..52fef1b 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -309,6 +309,18 @@ static inline int valid_io_request(struct zram *zram,
 
 static void zram_meta_free(struct zram_meta *meta)
 {
+	size_t index;
+
+	/* Free all pages that are still in this zram device */
+	for (index = 0; index < meta->num_pages; index++) {
+		unsigned long handle = meta->table[index].handle;
+
+		if (!handle)
+			continue;
+
+		zs_free(meta->mem_pool, handle);
+	}
+
 	zs_destroy_pool(meta->mem_pool);
 	vfree(meta->table);
 	kfree(meta);
@@ -316,14 +328,13 @@ static void zram_meta_free(struct zram_meta *meta)
 
 static struct zram_meta *zram_meta_alloc(int device_id, u64 disksize)
 {
-	size_t num_pages;
 	char pool_name[8];
 	struct zram_meta *meta = kmalloc(sizeof(*meta), GFP_KERNEL);
 	if (!meta)
 		goto out;
 
-	num_pages = disksize >> PAGE_SHIFT;
-	meta->table = vzalloc(num_pages * sizeof(*meta->table));
+	meta->num_pages = disksize >> PAGE_SHIFT;
+	meta->table = vzalloc(meta->num_pages * sizeof(*meta->table));
 	if (!meta->table) {
 		pr_err("Error allocating zram address table\n");
 		goto free_meta;
@@ -708,7 +719,6 @@ static void zram_bio_discard(struct zram *zram, u32 index,
 
 static void zram_reset_device(struct zram *zram, bool reset_capacity)
 {
-	size_t index;
 	struct zram_meta *meta;
 	struct zcomp *comp;
 
@@ -735,16 +745,6 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 
 	up_write(&zram->init_lock);
 
-	/* Free all pages that are still in this zram device */
-	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		unsigned long handle = meta->table[index].handle;
-
-		if (!handle)
-			continue;
-
-		zs_free(meta->mem_pool, handle);
-	}
-
 	zcomp_destroy(comp);
 	zram_meta_free(meta);
 
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index b05a816..e492f6b 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -96,6 +96,7 @@ struct zram_stats {
 struct zram_meta {
 	struct zram_table_entry *table;
 	struct zs_pool *mem_pool;
+	size_t num_pages;
 };
 
 struct zram {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
