Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E7776B007E
	for <linux-mm@kvack.org>; Wed,  8 Jun 2016 05:39:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so4001210pfa.1
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 02:39:33 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id yr6si464808pab.245.2016.06.08.02.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 02:39:32 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id t190so241945pfb.2
        for <linux-mm@kvack.org>; Wed, 08 Jun 2016 02:39:32 -0700 (PDT)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] zram: add zpool support
Date: Wed,  8 Jun 2016 17:39:18 +0800
Message-Id: <d2a7edd5e1f37d9daf4536927d1439df6f9dbd0a.1465378622.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch adds zpool support for zram, it will allow us to use both
the zpool api and directly zsmalloc api in zram.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/block/zram/zram_drv.c | 97 +++++++++++++++++++++++++++++++++++++++++++
 drivers/block/zram/zram_drv.h |  5 +++
 2 files changed, 102 insertions(+)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 9e2a83c..1f90bd0 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -43,6 +43,11 @@ static const char *default_compressor = "lzo";
 /* Module params (documentation at end) */
 static unsigned int num_devices = 1;
 
+#ifdef CONFIG_ZPOOL
+/* Compressed storage zpool to use */
+#define ZRAM_ZPOOL_DEFAULT "zsmalloc"
+#endif
+
 static inline void deprecated_attr_warn(const char *name)
 {
 	pr_warn_once("%d (%s) Attribute %s (and others) will be removed. %s\n",
@@ -228,7 +233,11 @@ static ssize_t mem_used_total_show(struct device *dev,
 	down_read(&zram->init_lock);
 	if (init_done(zram)) {
 		struct zram_meta *meta = zram->meta;
+#ifdef CONFIG_ZPOOL
+		val = zpool_get_total_size(meta->mem_pool) >> PAGE_SHIFT;
+#else
 		val = zs_get_total_pages(meta->mem_pool);
+#endif
 	}
 	up_read(&zram->init_lock);
 
@@ -296,8 +305,14 @@ static ssize_t mem_used_max_store(struct device *dev,
 	down_read(&zram->init_lock);
 	if (init_done(zram)) {
 		struct zram_meta *meta = zram->meta;
+#ifdef CONFIG_ZPOOL
+		atomic_long_set(&zram->stats.max_used_pages,
+				zpool_get_total_size(meta->mem_pool)
+				>> PAGE_SHIFT);
+#else
 		atomic_long_set(&zram->stats.max_used_pages,
 				zs_get_total_pages(meta->mem_pool));
+#endif
 	}
 	up_read(&zram->init_lock);
 
@@ -366,6 +381,18 @@ static ssize_t comp_algorithm_store(struct device *dev,
 	return len;
 }
 
+#ifdef CONFIG_ZPOOL
+static void zpool_compact(void *pool)
+{
+	zs_compact(pool);
+}
+
+static void zpool_stats(void *pool, struct zs_pool_stats *stats)
+{
+	zs_pool_stats(pool, stats);
+}
+#endif
+
 static ssize_t compact_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
 {
@@ -379,7 +406,11 @@ static ssize_t compact_store(struct device *dev,
 	}
 
 	meta = zram->meta;
+#ifdef CONFIG_ZPOOL
+	zpool_compact(meta->mem_pool);
+#else
 	zs_compact(meta->mem_pool);
+#endif
 	up_read(&zram->init_lock);
 
 	return len;
@@ -416,8 +447,14 @@ static ssize_t mm_stat_show(struct device *dev,
 
 	down_read(&zram->init_lock);
 	if (init_done(zram)) {
+#ifdef CONFIG_ZPOOL
+		mem_used = zpool_get_total_size(zram->meta->mem_pool)
+				>> PAGE_SHIFT;
+		zpool_stats(zram->meta->mem_pool, &pool_stats);
+#else
 		mem_used = zs_get_total_pages(zram->meta->mem_pool);
 		zs_pool_stats(zram->meta->mem_pool, &pool_stats);
+#endif
 	}
 
 	orig_size = atomic64_read(&zram->stats.pages_stored);
@@ -490,10 +527,18 @@ static void zram_meta_free(struct zram_meta *meta, u64 disksize)
 		if (!handle)
 			continue;
 
+#ifdef CONFIG_ZPOOL
+		zpool_free(meta->mem_pool, handle);
+#else
 		zs_free(meta->mem_pool, handle);
+#endif
 	}
 
+#ifdef CONFIG_ZPOOL
+	zpool_destroy_pool(meta->mem_pool);
+#else
 	zs_destroy_pool(meta->mem_pool);
+#endif
 	vfree(meta->table);
 	kfree(meta);
 }
@@ -513,7 +558,17 @@ static struct zram_meta *zram_meta_alloc(char *pool_name, u64 disksize)
 		goto out_error;
 	}
 
+#ifdef CONFIG_ZPOOL
+	if (!zpool_has_pool(ZRAM_ZPOOL_DEFAULT)) {
+		pr_err("zpool %s not available\n", ZRAM_ZPOOL_DEFAULT);
+		goto out_error;
+	}
+
+	meta->mem_pool = zpool_create_pool(ZRAM_ZPOOL_DEFAULT,
+					pool_name, 0, NULL);
+#else
 	meta->mem_pool = zs_create_pool(pool_name);
+#endif
 	if (!meta->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		goto out_error;
@@ -549,7 +604,11 @@ static void zram_free_page(struct zram *zram, size_t index)
 		return;
 	}
 
+#ifdef CONFIG_ZPOOL
+	zpool_free(meta->mem_pool, handle);
+#else
 	zs_free(meta->mem_pool, handle);
+#endif
 
 	atomic64_sub(zram_get_obj_size(meta, index),
 			&zram->stats.compr_data_size);
@@ -577,7 +636,11 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
 		return 0;
 	}
 
+#ifdef CONFIG_ZPOOL
+	cmem = zpool_map_handle(meta->mem_pool, handle, ZPOOL_MM_RO);
+#else
 	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
+#endif
 	if (size == PAGE_SIZE) {
 		copy_page(mem, cmem);
 	} else {
@@ -586,7 +649,11 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
 		ret = zcomp_decompress(zstrm, cmem, size, mem);
 		zcomp_stream_put(zram->comp);
 	}
+#ifdef CONFIG_ZPOOL
+	zpool_unmap_handle(meta->mem_pool, handle);
+#else
 	zs_unmap_object(meta->mem_pool, handle);
+#endif
 	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
 
 	/* Should NEVER happen. Return bio error if it does. */
@@ -735,20 +802,34 @@ compress_again:
 	 * from the slow path and handle has already been allocated.
 	 */
 	if (!handle)
+#ifdef CONFIG_ZPOOL
+		ret = zpool_malloc(meta->mem_pool, clen,
+				__GFP_KSWAPD_RECLAIM |
+				__GFP_NOWARN |
+				__GFP_HIGHMEM |
+				__GFP_MOVABLE, &handle);
+#else
 		handle = zs_malloc(meta->mem_pool, clen,
 				__GFP_KSWAPD_RECLAIM |
 				__GFP_NOWARN |
 				__GFP_HIGHMEM |
 				__GFP_MOVABLE);
+#endif
 	if (!handle) {
 		zcomp_stream_put(zram->comp);
 		zstrm = NULL;
 
 		atomic64_inc(&zram->stats.writestall);
 
+#ifdef CONFIG_ZPOOL
+		ret = zpool_malloc(meta->mem_pool, clen,
+				GFP_NOIO | __GFP_HIGHMEM |
+				__GFP_MOVABLE, &handle);
+#else
 		handle = zs_malloc(meta->mem_pool, clen,
 				GFP_NOIO | __GFP_HIGHMEM |
 				__GFP_MOVABLE);
+#endif
 		if (handle)
 			goto compress_again;
 
@@ -758,16 +839,28 @@ compress_again:
 		goto out;
 	}
 
+#ifdef CONFIG_ZPOOL
+	alloced_pages = zpool_get_total_size(meta->mem_pool) >> PAGE_SHIFT;
+#else
 	alloced_pages = zs_get_total_pages(meta->mem_pool);
+#endif
 	update_used_max(zram, alloced_pages);
 
 	if (zram->limit_pages && alloced_pages > zram->limit_pages) {
+#ifdef CONFIG_ZPOOL
+		zpool_free(meta->mem_pool, handle);
+#else
 		zs_free(meta->mem_pool, handle);
+#endif
 		ret = -ENOMEM;
 		goto out;
 	}
 
+#ifdef CONFIG_ZPOOL
+	cmem = zpool_map_handle(meta->mem_pool, handle, ZPOOL_MM_WO);
+#else
 	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
+#endif
 
 	if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
 		src = kmap_atomic(page);
@@ -779,7 +872,11 @@ compress_again:
 
 	zcomp_stream_put(zram->comp);
 	zstrm = NULL;
+#ifdef CONFIG_ZPOOL
+	zpool_unmap_handle(meta->mem_pool, handle);
+#else
 	zs_unmap_object(meta->mem_pool, handle);
+#endif
 
 	/*
 	 * Free memory associated with this sector
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 74fcf10..68f1222 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -17,6 +17,7 @@
 
 #include <linux/rwsem.h>
 #include <linux/zsmalloc.h>
+#include <linux/zpool.h>
 #include <linux/crypto.h>
 
 #include "zcomp.h"
@@ -91,7 +92,11 @@ struct zram_stats {
 
 struct zram_meta {
 	struct zram_table_entry *table;
+#ifdef CONFIG_ZPOOL
+	struct zpool *mem_pool;
+#else
 	struct zs_pool *mem_pool;
+#endif
 };
 
 struct zram {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
