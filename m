Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB2036B0253
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:42:44 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e189so43118840pfa.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 07:42:44 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id wl5si15197051pab.81.2016.06.15.07.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 07:42:44 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id hf6so1698166pac.2
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 07:42:43 -0700 (PDT)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] zram: update zram to use zpool
Date: Wed, 15 Jun 2016 22:42:07 +0800
Message-Id: <efcf047e747d9d1e80af16ebfc51ea1964a7a621.1466000844.git.geliangtang@gmail.com>
In-Reply-To: <cover.1466000844.git.geliangtang@gmail.com>
References: <cover.1466000844.git.geliangtang@gmail.com>
In-Reply-To: <cover.1466000844.git.geliangtang@gmail.com>
References: <cover.1466000844.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Vitaly Wool <vitalywool@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Change zram to use the zpool api instead of directly using zsmalloc.
The zpool api doesn't have zs_compact() and zs_pool_stats() functions.
I did the following two things to fix it.
1) I replace zs_compact() with zpool_shrink(), use zpool_shrink() to
   call zs_compact() in zsmalloc.
2) The 'pages_compacted' attribute is showed in zram by calling
   zs_pool_stats(). So in order not to call zs_pool_state() I move the
   attribute to zsmalloc.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/block/zram/Kconfig    |  3 ++-
 drivers/block/zram/zram_drv.c | 59 ++++++++++++++++++++++---------------------
 drivers/block/zram/zram_drv.h |  4 +--
 mm/zsmalloc.c                 | 12 +++++----
 4 files changed, 41 insertions(+), 37 deletions(-)

diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
index b8ecba6..6389a5a 100644
--- a/drivers/block/zram/Kconfig
+++ b/drivers/block/zram/Kconfig
@@ -1,6 +1,7 @@
 config ZRAM
 	tristate "Compressed RAM block device support"
-	depends on BLOCK && SYSFS && ZSMALLOC && CRYPTO
+	depends on BLOCK && SYSFS && ZPOOL && CRYPTO
+	select ZSMALLOC
 	select CRYPTO_LZO
 	default n
 	help
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 7454cf1..7ee9050 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -39,6 +39,7 @@ static DEFINE_MUTEX(zram_index_mutex);
 
 static int zram_major;
 static const char *default_compressor = "lzo";
+static char *default_zpool_type = "zsmalloc";
 
 /* Module params (documentation at end) */
 static unsigned int num_devices = 1;
@@ -228,11 +229,11 @@ static ssize_t mem_used_total_show(struct device *dev,
 	down_read(&zram->init_lock);
 	if (init_done(zram)) {
 		struct zram_meta *meta = zram->meta;
-		val = zs_get_total_pages(meta->mem_pool);
+		val = zpool_get_total_size(meta->mem_pool);
 	}
 	up_read(&zram->init_lock);
 
-	return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
+	return scnprintf(buf, PAGE_SIZE, "%llu\n", val);
 }
 
 static ssize_t mem_limit_show(struct device *dev,
@@ -297,7 +298,7 @@ static ssize_t mem_used_max_store(struct device *dev,
 	if (init_done(zram)) {
 		struct zram_meta *meta = zram->meta;
 		atomic_long_set(&zram->stats.max_used_pages,
-				zs_get_total_pages(meta->mem_pool));
+			zpool_get_total_size(meta->mem_pool) >> PAGE_SHIFT);
 	}
 	up_read(&zram->init_lock);
 
@@ -379,7 +380,7 @@ static ssize_t compact_store(struct device *dev,
 	}
 
 	meta = zram->meta;
-	zs_compact(meta->mem_pool);
+	zpool_shrink(meta->mem_pool, 0, NULL);
 	up_read(&zram->init_lock);
 
 	return len;
@@ -407,31 +408,25 @@ static ssize_t mm_stat_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
 	struct zram *zram = dev_to_zram(dev);
-	struct zs_pool_stats pool_stats;
 	u64 orig_size, mem_used = 0;
 	long max_used;
 	ssize_t ret;
 
-	memset(&pool_stats, 0x00, sizeof(struct zs_pool_stats));
-
 	down_read(&zram->init_lock);
-	if (init_done(zram)) {
-		mem_used = zs_get_total_pages(zram->meta->mem_pool);
-		zs_pool_stats(zram->meta->mem_pool, &pool_stats);
-	}
+	if (init_done(zram))
+		mem_used = zpool_get_total_size(zram->meta->mem_pool);
 
 	orig_size = atomic64_read(&zram->stats.pages_stored);
 	max_used = atomic_long_read(&zram->stats.max_used_pages);
 
 	ret = scnprintf(buf, PAGE_SIZE,
-			"%8llu %8llu %8llu %8lu %8ld %8llu %8lu\n",
+			"%8llu %8llu %8llu %8lu %8ld %8llu\n",
 			orig_size << PAGE_SHIFT,
 			(u64)atomic64_read(&zram->stats.compr_data_size),
-			mem_used << PAGE_SHIFT,
+			mem_used,
 			zram->limit_pages << PAGE_SHIFT,
 			max_used << PAGE_SHIFT,
-			(u64)atomic64_read(&zram->stats.zero_pages),
-			pool_stats.pages_compacted);
+			(u64)atomic64_read(&zram->stats.zero_pages));
 	up_read(&zram->init_lock);
 
 	return ret;
@@ -490,10 +485,10 @@ static void zram_meta_free(struct zram_meta *meta, u64 disksize)
 		if (!handle)
 			continue;
 
-		zs_free(meta->mem_pool, handle);
+		zpool_free(meta->mem_pool, handle);
 	}
 
-	zs_destroy_pool(meta->mem_pool);
+	zpool_destroy_pool(meta->mem_pool);
 	vfree(meta->table);
 	kfree(meta);
 }
@@ -513,7 +508,13 @@ static struct zram_meta *zram_meta_alloc(char *pool_name, u64 disksize)
 		goto out_error;
 	}
 
-	meta->mem_pool = zs_create_pool(pool_name);
+	if (!zpool_has_pool(default_zpool_type)) {
+		pr_err("zpool %s not available\n", default_zpool_type);
+		goto out_error;
+	}
+
+	meta->mem_pool = zpool_create_pool(default_zpool_type,
+					   pool_name, 0, NULL);
 	if (!meta->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		goto out_error;
@@ -549,7 +550,7 @@ static void zram_free_page(struct zram *zram, size_t index)
 		return;
 	}
 
-	zs_free(meta->mem_pool, handle);
+	zpool_free(meta->mem_pool, handle);
 
 	atomic64_sub(zram_get_obj_size(meta, index),
 			&zram->stats.compr_data_size);
@@ -577,7 +578,7 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
 		return 0;
 	}
 
-	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
+	cmem = zpool_map_handle(meta->mem_pool, handle, ZPOOL_MM_RO);
 	if (size == PAGE_SIZE) {
 		copy_page(mem, cmem);
 	} else {
@@ -586,7 +587,7 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
 		ret = zcomp_decompress(zstrm, cmem, size, mem);
 		zcomp_stream_put(zram->comp);
 	}
-	zs_unmap_object(meta->mem_pool, handle);
+	zpool_unmap_handle(meta->mem_pool, handle);
 	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
 
 	/* Should NEVER happen. Return bio error if it does. */
@@ -735,20 +736,20 @@ compress_again:
 	 * from the slow path and handle has already been allocated.
 	 */
 	if (!handle)
-		handle = zs_malloc(meta->mem_pool, clen,
+		ret = zpool_malloc(meta->mem_pool, clen,
 				__GFP_KSWAPD_RECLAIM |
 				__GFP_NOWARN |
 				__GFP_HIGHMEM |
-				__GFP_MOVABLE);
+				__GFP_MOVABLE, &handle);
 	if (!handle) {
 		zcomp_stream_put(zram->comp);
 		zstrm = NULL;
 
 		atomic64_inc(&zram->stats.writestall);
 
-		handle = zs_malloc(meta->mem_pool, clen,
+		ret = zpool_malloc(meta->mem_pool, clen,
 				GFP_NOIO | __GFP_HIGHMEM |
-				__GFP_MOVABLE);
+				__GFP_MOVABLE, &handle);
 		if (handle)
 			goto compress_again;
 
@@ -758,16 +759,16 @@ compress_again:
 		goto out;
 	}
 
-	alloced_pages = zs_get_total_pages(meta->mem_pool);
+	alloced_pages = zpool_get_total_size(meta->mem_pool) >> PAGE_SHIFT;
 	update_used_max(zram, alloced_pages);
 
 	if (zram->limit_pages && alloced_pages > zram->limit_pages) {
-		zs_free(meta->mem_pool, handle);
+		zpool_free(meta->mem_pool, handle);
 		ret = -ENOMEM;
 		goto out;
 	}
 
-	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
+	cmem = zpool_map_handle(meta->mem_pool, handle, ZPOOL_MM_WO);
 
 	if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
 		src = kmap_atomic(page);
@@ -779,7 +780,7 @@ compress_again:
 
 	zcomp_stream_put(zram->comp);
 	zstrm = NULL;
-	zs_unmap_object(meta->mem_pool, handle);
+	zpool_unmap_handle(meta->mem_pool, handle);
 
 	/*
 	 * Free memory associated with this sector
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 74fcf10..de3e013 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -16,7 +16,7 @@
 #define _ZRAM_DRV_H_
 
 #include <linux/rwsem.h>
-#include <linux/zsmalloc.h>
+#include <linux/zpool.h>
 #include <linux/crypto.h>
 
 #include "zcomp.h"
@@ -91,7 +91,7 @@ struct zram_stats {
 
 struct zram_meta {
 	struct zram_table_entry *table;
-	struct zs_pool *mem_pool;
+	struct zpool *mem_pool;
 };
 
 struct zram {
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 6a58edc..56e6439 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -421,7 +421,8 @@ static void zs_zpool_free(void *pool, unsigned long handle)
 static int zs_zpool_shrink(void *pool, unsigned int pages,
 			unsigned int *reclaimed)
 {
-	return -EINVAL;
+	zs_compact(pool);
+	return 0;
 }
 
 static void *zs_zpool_map(void *pool, unsigned long handle,
@@ -609,10 +610,10 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 	unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
 	unsigned long total_freeable = 0;
 
-	seq_printf(s, " %5s %5s %11s %12s %13s %10s %10s %16s %8s\n",
+	seq_printf(s, " %5s %5s %11s %12s %13s %10s %10s %16s %8s %15s\n",
 			"class", "size", "almost_full", "almost_empty",
 			"obj_allocated", "obj_used", "pages_used",
-			"pages_per_zspage", "freeable");
+			"pages_per_zspage", "freeable", "pages_compacted");
 
 	for (i = 0; i < zs_size_classes; i++) {
 		class = pool->size_class[i];
@@ -648,10 +649,11 @@ static int zs_stats_size_show(struct seq_file *s, void *v)
 	}
 
 	seq_puts(s, "\n");
-	seq_printf(s, " %5s %5s %11lu %12lu %13lu %10lu %10lu %16s %8lu\n",
+	seq_printf(s, " %5s %5s %11lu %12lu %13lu %10lu %10lu %16s %8lu %15lu\n",
 			"Total", "", total_class_almost_full,
 			total_class_almost_empty, total_objs,
-			total_used_objs, total_pages, "", total_freeable);
+			total_used_objs, total_pages, "", total_freeable,
+			pool->stats.pages_compacted);
 
 	return 0;
 }
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
