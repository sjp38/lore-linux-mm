Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id E86AB6B0038
	for <linux-mm@kvack.org>; Fri, 26 Sep 2014 02:52:40 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so11020284pde.34
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 23:52:40 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id qe5si7782631pdb.2.2014.09.25.23.52.37
        for <linux-mm@kvack.org>;
        Thu, 25 Sep 2014 23:52:38 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 2/2] zram: make afmalloc as zram's backend memory allocator
Date: Fri, 26 Sep 2014 15:53:15 +0900
Message-Id: <1411714395-18115-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1411714395-18115-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1411714395-18115-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 drivers/block/zram/Kconfig    |    2 +-
 drivers/block/zram/zram_drv.c |   40 ++++++++++++----------------------------
 drivers/block/zram/zram_drv.h |    4 ++--
 3 files changed, 15 insertions(+), 31 deletions(-)

diff --git a/drivers/block/zram/Kconfig b/drivers/block/zram/Kconfig
index 6489c0f..1c09a11 100644
--- a/drivers/block/zram/Kconfig
+++ b/drivers/block/zram/Kconfig
@@ -1,6 +1,6 @@
 config ZRAM
 	tristate "Compressed RAM block device support"
-	depends on BLOCK && SYSFS && ZSMALLOC
+	depends on BLOCK && SYSFS && ANTI_FRAGMENTATION_MALLOC
 	select LZO_COMPRESS
 	select LZO_DECOMPRESS
 	default n
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index bc20fe1..545e43f 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -103,7 +103,7 @@ static ssize_t mem_used_total_show(struct device *dev,
 
 	down_read(&zram->init_lock);
 	if (init_done(zram))
-		val = zs_get_total_pages(meta->mem_pool);
+		val = afmalloc_get_used_pages(meta->mem_pool);
 	up_read(&zram->init_lock);
 
 	return scnprintf(buf, PAGE_SIZE, "%llu\n", val << PAGE_SHIFT);
@@ -173,16 +173,12 @@ static ssize_t mem_used_max_store(struct device *dev,
 	int err;
 	unsigned long val;
 	struct zram *zram = dev_to_zram(dev);
-	struct zram_meta *meta = zram->meta;
 
 	err = kstrtoul(buf, 10, &val);
 	if (err || val != 0)
 		return -EINVAL;
 
 	down_read(&zram->init_lock);
-	if (init_done(zram))
-		atomic_long_set(&zram->stats.max_used_pages,
-				zs_get_total_pages(meta->mem_pool));
 	up_read(&zram->init_lock);
 
 	return len;
@@ -309,7 +305,7 @@ static inline int valid_io_request(struct zram *zram, struct bio *bio)
 
 static void zram_meta_free(struct zram_meta *meta)
 {
-	zs_destroy_pool(meta->mem_pool);
+	afmalloc_destroy_pool(meta->mem_pool);
 	vfree(meta->table);
 	kfree(meta);
 }
@@ -328,7 +324,8 @@ static struct zram_meta *zram_meta_alloc(u64 disksize)
 		goto free_meta;
 	}
 
-	meta->mem_pool = zs_create_pool(GFP_NOIO | __GFP_HIGHMEM);
+	meta->mem_pool = afmalloc_create_pool(AFMALLOC_MAX_LEVEL,
+						disksize, GFP_NOIO);
 	if (!meta->mem_pool) {
 		pr_err("Error creating memory pool\n");
 		goto free_table;
@@ -405,7 +402,7 @@ static void zram_free_page(struct zram *zram, size_t index)
 		return;
 	}
 
-	zs_free(meta->mem_pool, handle);
+	afmalloc_free(meta->mem_pool, handle);
 
 	atomic64_sub(zram_get_obj_size(meta, index),
 			&zram->stats.compr_data_size);
@@ -434,12 +431,12 @@ static int zram_decompress_page(struct zram *zram, char *mem, u32 index)
 		return 0;
 	}
 
-	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_RO);
+	cmem = afmalloc_map_handle(meta->mem_pool, handle, size, true);
 	if (size == PAGE_SIZE)
 		copy_page(mem, cmem);
 	else
 		ret = zcomp_decompress(zram->comp, cmem, size, mem);
-	zs_unmap_object(meta->mem_pool, handle);
+	afmalloc_unmap_handle(meta->mem_pool, handle);
 	bit_spin_unlock(ZRAM_ACCESS, &meta->table[index].value);
 
 	/* Should NEVER happen. Return bio error if it does. */
@@ -523,11 +520,10 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 	size_t clen;
 	unsigned long handle;
 	struct page *page;
-	unsigned char *user_mem, *cmem, *src, *uncmem = NULL;
+	unsigned char *user_mem, *src, *uncmem = NULL;
 	struct zram_meta *meta = zram->meta;
 	struct zcomp_strm *zstrm;
 	bool locked = false;
-	unsigned long alloced_pages;
 
 	page = bvec->bv_page;
 	if (is_partial_io(bvec)) {
@@ -589,7 +585,7 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 			src = uncmem;
 	}
 
-	handle = zs_malloc(meta->mem_pool, clen);
+	handle = afmalloc_alloc(meta->mem_pool, clen);
 	if (!handle) {
 		pr_info("Error allocating memory for compressed page: %u, size=%zu\n",
 			index, clen);
@@ -597,28 +593,16 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec, u32 index,
 		goto out;
 	}
 
-	alloced_pages = zs_get_total_pages(meta->mem_pool);
-	if (zram->limit_pages && alloced_pages > zram->limit_pages) {
-		zs_free(meta->mem_pool, handle);
-		ret = -ENOMEM;
-		goto out;
-	}
-
-	update_used_max(zram, alloced_pages);
-
-	cmem = zs_map_object(meta->mem_pool, handle, ZS_MM_WO);
-
 	if ((clen == PAGE_SIZE) && !is_partial_io(bvec)) {
 		src = kmap_atomic(page);
-		copy_page(cmem, src);
+		afmalloc_store(meta->mem_pool, handle, src, clen);
 		kunmap_atomic(src);
 	} else {
-		memcpy(cmem, src, clen);
+		afmalloc_store(meta->mem_pool, handle, src, clen);
 	}
 
 	zcomp_strm_release(zram->comp, zstrm);
 	locked = false;
-	zs_unmap_object(meta->mem_pool, handle);
 
 	/*
 	 * Free memory associated with this sector
@@ -725,7 +709,7 @@ static void zram_reset_device(struct zram *zram, bool reset_capacity)
 		if (!handle)
 			continue;
 
-		zs_free(meta->mem_pool, handle);
+		afmalloc_free(meta->mem_pool, handle);
 	}
 
 	zcomp_destroy(zram->comp);
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index c6ee271..1a116c0 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -16,7 +16,7 @@
 #define _ZRAM_DRV_H_
 
 #include <linux/spinlock.h>
-#include <linux/zsmalloc.h>
+#include <linux/afmalloc.h>
 
 #include "zcomp.h"
 
@@ -95,7 +95,7 @@ struct zram_stats {
 
 struct zram_meta {
 	struct zram_table_entry *table;
-	struct zs_pool *mem_pool;
+	struct afmalloc_pool *mem_pool;
 };
 
 struct zram {
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
