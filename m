Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id CC0676B0032
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 03:15:53 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so24036492pab.11
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 00:15:53 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id yv1si4667503pab.240.2015.01.28.00.15.51
        for <linux-mm@kvack.org>;
        Wed, 28 Jan 2015 00:15:52 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] zram: free meta table in zram_meta_free
Date: Wed, 28 Jan 2015 17:15:44 +0900
Message-Id: <1422432945-6764-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, Minchan Kim <minchan@kernel.org>

From: Ganesh Mahendran <opensource.ganesh@gmail.com>

zram_meta_alloc() and zram_meta_free() are a pair.
In zram_meta_alloc(), meta table is allocated. So it it better to free
it in zram_meta_free().

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 30 ++++++++++++++----------------
 drivers/block/zram/zram_drv.h |  1 +
 2 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 9250b3f54a8f..a598ada817f0 100644
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
@@ -316,15 +328,14 @@ static void zram_meta_free(struct zram_meta *meta)
 
 static struct zram_meta *zram_meta_alloc(int device_id, u64 disksize)
 {
-	size_t num_pages;
 	char pool_name[8];
 	struct zram_meta *meta = kmalloc(sizeof(*meta), GFP_KERNEL);
 
 	if (!meta)
 		return NULL;
 
-	num_pages = disksize >> PAGE_SHIFT;
-	meta->table = vzalloc(num_pages * sizeof(*meta->table));
+	meta->num_pages = disksize >> PAGE_SHIFT;
+	meta->table = vzalloc(meta->num_pages * sizeof(*meta->table));
 	if (!meta->table) {
 		pr_err("Error allocating zram address table\n");
 		goto out_error;
@@ -706,9 +717,6 @@ static void zram_bio_discard(struct zram *zram, u32 index,
 
 static void zram_reset_device(struct zram *zram, bool reset_capacity)
 {
-	size_t index;
-	struct zram_meta *meta;
-
 	down_write(&zram->init_lock);
 
 	zram->limit_pages = 0;
@@ -718,16 +726,6 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 		return;
 	}
 
-	meta = zram->meta;
-	/* Free all pages that are still in this zram device */
-	for (index = 0; index < zram->disksize >> PAGE_SHIFT; index++) {
-		unsigned long handle = meta->table[index].handle;
-		if (!handle)
-			continue;
-
-		zs_free(meta->mem_pool, handle);
-	}
-
 	zcomp_destroy(zram->comp);
 	zram->max_comp_streams = 1;
 
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index b05a816b09ac..e492f6bf11f1 100644
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
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
