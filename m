Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 760766B003A
	for <linux-mm@kvack.org>; Sun, 21 Sep 2014 20:02:45 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id g10so2781822pdj.19
        for <linux-mm@kvack.org>; Sun, 21 Sep 2014 17:02:45 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id kq4si13357177pbc.97.2014.09.21.17.02.41
        for <linux-mm@kvack.org>;
        Sun, 21 Sep 2014 17:02:42 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v1 4/5] zram: add swap full hint
Date: Mon, 22 Sep 2014 09:03:10 +0900
Message-Id: <1411344191-2842-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1411344191-2842-1-git-send-email-minchan@kernel.org>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com, Minchan Kim <minchan@kernel.org>

This patch implement SWAP_FULL handler in zram so that VM can
know whether zram is full or not and use it to stop anonymous
page reclaim.

How to judge fullness is below,

fullness = (100 * used space / total space)

It means the higher fullness is, the slower we reach zram full.
Now, default of fullness is 80 so that it biased more momory
consumption rather than early OOM kill.

Above logic works only when used space of zram hit over the limit
but zram also pretend to be full once 32 consecutive allocation
fail happens. It's safe guard to prevent system hang caused by
fragment uncertainty.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 60 ++++++++++++++++++++++++++++++++++++++++---
 drivers/block/zram/zram_drv.h |  1 +
 2 files changed, 57 insertions(+), 4 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 22a37764c409..649cad9d0b1c 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -43,6 +43,20 @@ static const char *default_compressor = "lzo";
 /* Module params (documentation at end) */
 static unsigned int num_devices = 1;
 
+/*
+ * If (100 * used_pages / total_pages) >= ZRAM_FULLNESS_PERCENT),
+ * we regards it as zram-full. It means that the higher
+ * ZRAM_FULLNESS_PERCENT is, the slower we reach zram full.
+ */
+#define ZRAM_FULLNESS_PERCENT 80
+
+/*
+ * If zram fails to allocate memory consecutively up to this,
+ * we regard it as zram-full. It's safe guard to prevent too
+ * many swap write fail due to lack of fragmentation uncertainty.
+ */
+#define ALLOC_FAIL_MAX	32
+
 #define ZRAM_ATTR_RO(name)						\
 static ssize_t zram_attr_##name##_show(struct device *d,		\
 				struct device_attribute *attr, char *b)	\
@@ -148,6 +162,7 @@ static ssize_t mem_limit_store(struct device *dev,
 
 	down_write(&zram->init_lock);
 	zram->limit_pages = PAGE_ALIGN(limit) >> PAGE_SHIFT;
+	atomic_set(&zram->alloc_fail, 0);
 	up_write(&zram->init_lock);
 
 	return len;
@@ -410,6 +425,7 @@ static void zram_free_page(struct zram *zram, size_t index)
 	atomic64_sub(zram_get_obj_size(meta, index),
 			&zram->stats.compr_data_size);
 	atomic64_dec(&zram->stats.pages_stored);
+	atomic_set(&zram->alloc_fail, 0);
 
 	meta->table[index].handle = 0;
 	zram_set_obj_size(meta, index, 0);
@@ -597,10 +613,15 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	}
 
 	alloced_pages = zs_get_total_pages(meta->mem_pool);
-	if (zram->limit_pages && alloced_pages > zram->limit_pages) {
-		zs_free(meta->mem_pool, handle);
-		ret = -ENOMEM;
-		goto out;
+	if (zram->limit_pages) {
+		if (alloced_pages > zram->limit_pages) {
+			zs_free(meta->mem_pool, handle);
+			atomic_inc(&zram->alloc_fail);
+			ret = -ENOMEM;
+			goto out;
+		} else {
+			atomic_set(&zram->alloc_fail, 0);
+		}
 	}
 
 	update_used_max(zram, alloced_pages);
@@ -711,6 +732,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 	down_write(&zram->init_lock);
 
 	zram->limit_pages = 0;
+	atomic_set(&zram->alloc_fail, 0);
 
 	if (!init_done(zram)) {
 		up_write(&zram->init_lock);
@@ -944,6 +966,34 @@ static int zram_slot_free_notify(struct block_device *bdev,
 	return 0;
 }
 
+static int zram_full(struct block_device *bdev, void *arg)
+{
+	struct zram *zram;
+	struct zram_meta *meta;
+	unsigned long total_pages, compr_pages;
+
+	zram = bdev->bd_disk->private_data;
+	if (!zram->limit_pages)
+		return 0;
+
+	meta = zram->meta;
+	total_pages = zs_get_total_pages(meta->mem_pool);
+
+	if (total_pages >= zram->limit_pages) {
+
+		compr_pages = atomic64_read(&zram->stats.compr_data_size)
+					>> PAGE_SHIFT;
+		if ((100 * compr_pages / total_pages)
+			>= ZRAM_FULLNESS_PERCENT)
+			return 1;
+	}
+
+	if (atomic_read(&zram->alloc_fail) > ALLOC_FAIL_MAX)
+		return 1;
+
+	return 0;
+}
+
 static int zram_swap_hint(struct block_device *bdev,
 				unsigned int hint, void *arg)
 {
@@ -951,6 +1001,8 @@ static int zram_swap_hint(struct block_device *bdev,
 
 	if (hint == SWAP_FREE)
 		ret = zram_slot_free_notify(bdev, (unsigned long)arg);
+	else if (hint == SWAP_FULL)
+		ret = zram_full(bdev, arg);
 
 	return ret;
 }
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index c6ee271317f5..fcf3176a9f15 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -113,6 +113,7 @@ struct zram {
 	u64 disksize;	/* bytes */
 	int max_comp_streams;
 	struct zram_stats stats;
+	atomic_t alloc_fail;
 	/*
 	 * the number of pages zram can consume for storing compressed data
 	 */
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
