Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id EE2A86B0260
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 09:55:29 -0400 (EDT)
Received: by lahg1 with SMTP id g1so57447514lah.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:55:29 -0700 (PDT)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com. [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id m7si9238942lbd.21.2015.09.14.06.55.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 06:55:28 -0700 (PDT)
Received: by lbcjc2 with SMTP id jc2so67727601lbc.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 06:55:27 -0700 (PDT)
Date: Mon, 14 Sep 2015 15:55:21 +0200
From: Vitaly Wool <vitalywool@gmail.com>
Subject: [PATCH 3/3] zram: use common zpool interface
Message-Id: <20150914155521.8b5ccc16b09e09d885a9ce5a@gmail.com>
In-Reply-To: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
References: <20150914154901.92c5b7b24e15f04d8204de18@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, sergey.senozhatsky@gmail.com, ddstreet@ieee.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Update zram driver to use common zpool API instead of calling
zsmalloc functions directly. This patch also adds a parameter
that allows for changing underlying compressor storage to zbud.

Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
---
 drivers/block/zram/Kconfig    |  3 ++-
 drivers/block/zram/zram_drv.c | 44 ++++++++++++++++++++++++-------------------
 drivers/block/zram/zram_drv.h |  4 ++--
 3 files changed, 29 insertions(+), 22 deletions(-)

diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
index 386ba3d..4831d0a 100644
--- a/drivers/block/zram/Kconfig
+++ b/drivers/block/zram/Kconfig
@@ -1,6 +1,7 @@
 config ZRAM
 	tristate "Compressed RAM block device support"
-	depends on BLOCK && SYSFS && ZSMALLOC
+	depends on BLOCK && SYSFS
+	select ZPOOL
 	select LZO_COMPRESS
 	select LZO_DECOMPRESS
 	default n
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index 49d5a65..2829c3d 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -44,6 +44,9 @@ static const char *default_compressor = "lzo";
 static unsigned int num_devices = 1;
 static size_t max_zpage_size = PAGE_SIZE / 4 * 3;
 
+#define ZRAM_ZPOOL_DEFAULT "zsmalloc"
+static char *pool_type = ZRAM_ZPOOL_DEFAULT;
+
 static inline void deprecated_attr_warn(const char *name)
 {
 	pr_warn_once("%d (%s) Attribute %s (and others) will be removed. %s\n",
@@ -229,11 +232,11 @@ static ssize_t mem_used_total_show(struct device *dev,
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
@@ -298,7 +301,7 @@ static ssize_t mem_used_max_store(struct device *dev,
 	if (init_done(zram)) {
 		struct zram_meta *meta = zram->meta;
 		atomic_long_set(&zram->stats.max_used_pages,
-				zs_get_total_pages(meta->mem_pool));
+			zpool_get_total_size(meta->mem_pool) >> PAGE_SHIFT);
 	}
 	up_read(&zram->init_lock);
 
@@ -399,7 +402,7 @@ static ssize_t compact_store(struct device *dev,
 	}
 
 	meta = zram->meta;
-	zs_compact(meta->mem_pool);
+	zpool_compact(meta->mem_pool, NULL);
 	up_read(&zram->init_lock);
 
 	return len;
@@ -436,8 +439,8 @@ static ssize_t mm_stat_show(struct device *dev,
 
 	down_read(&zram->init_lock);
 	if (init_done(zram)) {
-		mem_used = zs_get_total_pages(zram->meta->mem_pool);
-		zs_pool_stats(zram->meta->mem_pool, &pool_stats);
+		mem_used = zpool_get_total_size(zram->meta->mem_pool);
+		zpool_stats(zram->meta->mem_pool, &pool_stats);
 	}
 
 	orig_size = atomic64_read(&zram->stats.pages_stored);
@@ -447,7 +450,7 @@ static ssize_t mm_stat_show(struct device *dev,
 			"%8llu %8llu %8llu %8lu %8ld %8llu %8lu\n",
 			orig_size << PAGE_SHIFT,
 			(u64)atomic64_read(&zram->stats.compr_data_size),
-			mem_used << PAGE_SHIFT,
+			mem_used,
 			zram->limit_pages << PAGE_SHIFT,
 			max_used << PAGE_SHIFT,
 			(u64)atomic64_read(&zram->stats.zero_pages),
@@ -492,10 +495,10 @@ static void zram_meta_free(struct zram_meta *meta, u64 disksize)
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
@@ -515,7 +518,8 @@ static struct zram_meta *zram_meta_alloc(char *pool_name, u64 disksize)
 		goto out_error;
 	}
 
-	meta->mem_pool = zs_create_pool(pool_name, GFP_NOIO | __GFP_HIGHMEM);
+	meta->mem_pool = zpool_create_pool(pool_type, pool_name,
+			GFP_NOIO | __GFP_HIGHMEM, NULL);
 	if (!meta->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		goto out_error;
@@ -551,7 +555,7 @@ static void zram_free_page(struct zram *zram, size_t index)
 		return;
 	}
 
-	zs_free(meta->mem_pool, handle);
+	zpool_free(meta->mem_pool, handle);
 
 	atomic64_sub(zram_get_obj_size(meta, index),
 			&zram->stats.compr_data_size);
@@ -579,12 +583,12 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
 		return 0;
 	}
 
-	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
+	cmem = zpool_map_handle(meta->mem_pool, handle, ZPOOL_MM_RO);
 	if (size == PAGE_SIZE)
 		copy_page(mem, cmem);
 	else
 		ret = zcomp_decompress(zram->comp, cmem, size, mem);
-	zs_unmap_object(meta->mem_pool, handle);
+	zpool_unmap_handle(meta->mem_pool, handle);
 	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
 
 	/* Should NEVER happen. Return bio error if it does. */
@@ -718,24 +722,24 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 			src = uncmem;
 	}
 
-	handle = zs_malloc(meta->mem_pool, clen);
-	if (!handle) {
+	if (zpool_malloc(meta->mem_pool, clen, __GFP_IO | __GFP_NOWARN,
+			&handle) != 0) {
 		pr_err("Error allocating memory for compressed page: %u, size=%zu\n",
 			index, clen);
 		ret = -ENOMEM;
 		goto out;
 	}
 
-	alloced_pages = zs_get_total_pages(meta->mem_pool);
+	alloced_pages = zpool_get_total_size(meta->mem_pool) >> PAGE_SHIFT;
 	if (zram->limit_pages && alloced_pages > zram->limit_pages) {
-		zs_free(meta->mem_pool, handle);
+		zpool_free(meta->mem_pool, handle);
 		ret = -ENOMEM;
 		goto out;
 	}
 
 	update_used_max(zram, alloced_pages);
 
-	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
+	cmem = zpool_map_handle(meta->mem_pool, handle, ZPOOL_MM_WO);
 
 	if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
 		src = kmap_atomic(page);
@@ -747,7 +751,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 
 	zcomp_strm_release(zram->comp, zstrm);
 	zstrm = NULL;
-	zs_unmap_object(meta->mem_pool, handle);
+	zpool_unmap_handle(meta->mem_pool, handle);
 
 	/*
 	 * Free memory associated with this sector
@@ -1457,6 +1461,8 @@ module_param(num_devices, uint, 0);
 MODULE_PARM_DESC(num_devices, "Number of pre-created zram devices");
 module_param(max_zpage_size, ulong, 0);
 MODULE_PARM_DESC(max_zpage_size, "Threshold for storing compressed pages");
+module_param_named(zpool_type, pool_type, charp, 0444);
+MODULE_PARM_DESC(zpool_type, "zpool implementation selection (zsmalloc vs zbud)");
 
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_AUTHOR("Nitin Gupta <ngupta@vflare.org>");
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 3a29c33..9a64b94 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -16,7 +16,7 @@
 #define _ZRAM_DRV_H_
 
 #include <linux/spinlock.h>
-#include <linux/zsmalloc.h>
+#include <linux/zpool.h>
 
 #include "zcomp.h"
 
@@ -73,7 +73,7 @@ struct zram_stats {
 
 struct zram_meta {
 	struct zram_table_entry *table;
-	struct zs_pool *mem_pool;
+	struct zpool *mem_pool;
 };
 
 struct zram {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
