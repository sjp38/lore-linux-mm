Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3255F6B025D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:51:38 -0400 (EDT)
Received: by lagj9 with SMTP id j9so88318086lag.2
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:51:37 -0700 (PDT)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com. [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id m6si9772912lah.100.2015.09.14.06.51.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:51:36 -0700 (PDT)
Received: by lanb10 with SMTP id b10so86833840lan.3
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:51:36 -0700 (PDT)
Date: Mon, 14 Sep 2015 15:51:34 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 2/3] zpool/zsmalloc/zbud: align on interfaces
Message-Id: <20150914155134.032ebb89e287bd0db59ba603@gmail.com>
In-Reply-To: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, sergey.senozhatsky@gmail.com, ddstreet@ieee.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

As a preparation step for zram to be able to use common zpool API,
there has to be some alignment done on it. This patch adds
functions that correspond to zsmalloc-specific API to the common
zpool API and takes care of the callbacks that have to be
introduced, too.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 drivers/block/zram/zram_drv.c |  4 ++--
 include/linux/zpool.h         | 14 ++++++++++++++
 include/linux/zsmalloc.h      |  8 ++------
 mm/zbud.c                     | 12 ++++++++++++
 mm/zpool.c                    | 22 ++++++++++++++++++++++
 mm/zsmalloc.c                 | 23 ++++++++++++++++++++---
 6 files changed, 72 insertions(+), 11 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 6d9f1d1..49d5a65 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -427,12 +427,12 @@ static ssize_t mm_stat_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
 	struct zram *zram = dev_to_zram(dev);
-	struct zs_pool_stats pool_stats;
+	struct zpool_stats pool_stats;
 	u64 orig_size, mem_used = 0;
 	long max_used;
 	ssize_t ret;
 
-	memset(&pool_stats, 0x00, sizeof(struct zs_pool_stats));
+	memset(&pool_stats, 0x00, sizeof(struct zpool_stats));
 
 	down_read(&zram->init_lock);
 	if (init_done(zram)) {
diff --git a/include/linux/zpool.h b/include/linux/zpool.h
index 42f8ec9..f64cf86 100644
--- a/include/linux/zpool.h
+++ b/include/linux/zpool.h
@@ -17,6 +17,11 @@ struct zpool_ops {
 	int (*evict)(struct zpool *pool, unsigned long handle);
 };
 
+struct zpool_stats {
+	/* How many pages were migrated (freed) */
+	unsigned long pages_compacted;
+};
+
 /*
  * Control how a handle is mapped.  It will be ignored if the
  * implementation does not support it.  Its use is optional.
@@ -58,6 +63,10 @@ void *zpool_map_handle(struct zpool *pool, unsigned long handle,
 
 void zpool_unmap_handle(struct zpool *pool, unsigned long handle);
 
+int zpool_compact(struct zpool *pool, unsigned long *compacted);
+
+void zpool_stats(struct zpool *pool, struct zpool_stats *zstats);
+
 u64 zpool_get_total_size(struct zpool *pool);
 
 
@@ -72,6 +81,8 @@ u64 zpool_get_total_size(struct zpool *pool);
  * @shrink:	shrink the pool.
  * @map:	map a handle.
  * @unmap:	unmap a handle.
+ * @compact:	try to run compaction for the pool
+ * @stats:	get statistics for the pool
  * @total_size:	get total size of a pool.
  *
  * This is created by a zpool implementation and registered
@@ -98,6 +109,9 @@ struct zpool_driver {
 				enum zpool_mapmode mm);
 	void (*unmap)(void *pool, unsigned long handle);
 
+	int (*compact)(void *pool, unsigned long *compacted);
+	void (*stats)(void *pool, struct zpool_stats *stats);
+
 	u64 (*total_size)(void *pool);
 };
 
diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 6398dfa..5aee1c7 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -15,6 +15,7 @@
 #define _ZS_MALLOC_H_
 
 #include <linux/types.h>
+#include <linux/zpool.h>
 
 /*
  * zsmalloc mapping modes
@@ -34,11 +35,6 @@ enum zs_mapmode {
 	 */
 };
 
-struct zs_pool_stats {
-	/* How many pages were migrated (freed) */
-	unsigned long pages_compacted;
-};
-
 struct zs_pool;
 
 struct zs_pool *zs_create_pool(char *name, gfp_t flags);
@@ -54,5 +50,5 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 unsigned long zs_get_total_pages(struct zs_pool *pool);
 unsigned long zs_compact(struct zs_pool *pool);
 
-void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats);
+void zs_pool_stats(struct zs_pool *pool, struct zpool_stats *stats);
 #endif
diff --git a/mm/zbud.c b/mm/zbud.c
index fa48bcdf..0963342 100644
--- a/mm/zbud.c
+++ b/mm/zbud.c
@@ -195,6 +195,16 @@ static void zbud_zpool_unmap(void *pool, unsigned long handle)
 	zbud_unmap(pool, handle);
 }
 
+static int zbud_zpool_compact(void *pool, unsigned long *compacted)
+{
+	return -EINVAL;
+}
+
+static void zbud_zpool_stats(void *pool, struct zpool_stats *stats)
+{
+	/* no-op */
+}
+
 static u64 zbud_zpool_total_size(void *pool)
 {
 	return zbud_get_pool_size(pool) * PAGE_SIZE;
@@ -210,6 +220,8 @@ static struct zpool_driver zbud_zpool_driver = {
 	.shrink =	zbud_zpool_shrink,
 	.map =		zbud_zpool_map,
 	.unmap =	zbud_zpool_unmap,
+	.compact =	zbud_zpool_compact,
+	.stats =	zbud_zpool_stats,
 	.total_size =	zbud_zpool_total_size,
 };
 
diff --git a/mm/zpool.c b/mm/zpool.c
index 8f670d3..15a171a 100644
--- a/mm/zpool.c
+++ b/mm/zpool.c
@@ -341,6 +341,28 @@ void zpool_unmap_handle(struct zpool *zpool, unsigned long handle)
 }
 
 /**
+ * zpool_compact() - try to run compaction over zpool
+ * @pool	The zpool to compact
+ * @compacted	The number of migrated pages
+ *
+ * Returns: 0 on success, error code otherwise
+ */
+int zpool_compact(struct zpool *zpool, unsigned long *compacted)
+{
+	return zpool->driver->compact(zpool->pool, compacted);
+}
+
+/**
+ * zpool_stats() - obtain zpool statistics
+ * @pool	The zpool to get statistics for
+ * @zstats	stats to fill in
+ */
+void zpool_stats(struct zpool *zpool, struct zpool_stats *zstats)
+{
+	zpool->driver->stats(zpool->pool, zstats);
+}
+
+/**
  * zpool_get_total_size() - The total size of the pool
  * @pool	The zpool to check
  *
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f135b1b..f002f57 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -245,7 +245,7 @@ struct zs_pool {
 	gfp_t flags;	/* allocation flags used when growing pool */
 	atomic_long_t pages_allocated;
 
-	struct zs_pool_stats stats;
+	struct zpool_stats stats;
 
 	/* Compact classes */
 	struct shrinker shrinker;
@@ -365,6 +365,21 @@ static void zs_zpool_unmap(void *pool, unsigned long handle)
 	zs_unmap_object(pool, handle);
 }
 
+static int zs_zpool_compact(void *pool, unsigned long *compacted)
+{
+	unsigned long c = zs_compact(pool);
+
+	if (compacted)
+		*compacted = c;
+	return 0;
+}
+
+
+static void zs_zpool_stats(void *pool, struct zpool_stats *stats)
+{
+	zs_pool_stats(pool, stats);
+}
+
 static u64 zs_zpool_total_size(void *pool)
 {
 	return zs_get_total_pages(pool) << PAGE_SHIFT;
@@ -380,6 +395,8 @@ static struct zpool_driver zs_zpool_driver = {
 	.shrink =	zs_zpool_shrink,
 	.map =		zs_zpool_map,
 	.unmap =	zs_zpool_unmap,
+	.compact =	zs_zpool_compact,
+	.stats =	zs_zpool_stats,
 	.total_size =	zs_zpool_total_size,
 };
 
@@ -1789,9 +1806,9 @@ unsigned long zs_compact(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_compact);
 
-void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats)
+void zs_pool_stats(struct zs_pool *pool, struct zpool_stats *stats)
 {
-	memcpy(stats, &pool->stats, sizeof(struct zs_pool_stats));
+	memcpy(stats, &pool->stats, sizeof(struct zpool_stats));
 }
 EXPORT_SYMBOL_GPL(zs_pool_stats);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
