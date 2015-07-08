Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id BC9496B0257
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 07:33:07 -0400 (EDT)
Received: by pdbqm3 with SMTP id qm3so1012508pdb.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 04:33:07 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id ed4si3652162pbc.132.2015.07.08.04.33.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 04:33:06 -0700 (PDT)
Received: by pddu5 with SMTP id u5so56912005pdd.3
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 04:33:06 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v7 5/7] zsmalloc/zram: introduce zs_pool_stats api
Date: Wed,  8 Jul 2015 20:31:51 +0900
Message-Id: <1436355113-12417-6-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436355113-12417-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

`zs_compact_control' accounts the number of migrated objects but
it has a limited lifespan -- we lose it as soon as zs_compaction()
returns back to zram. It worked fine, because (a) zram had it's own
counter of migrated objects and (b) only zram could trigger
compaction. However, this does not work for automatic pool
compaction (not issued by zram). To account objects migrated
during auto-compaction (issued by the shrinker) we need to store
this number in zs_pool.

Define a new `struct zs_pool_stats' structure to keep zs_pool's
stats there. It provides only `num_migrated', as of this writing,
but it surely can be extended.

A new zsmalloc zs_pool_stats() symbol exports zs_pool's stats
back to caller.

Use zs_pool_stats() in zram and remove `num_migrated' from
zram_stats.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org>
---
 drivers/block/zram/zram_drv.c | 15 +++++++++------
 drivers/block/zram/zram_drv.h |  1 -
 include/linux/zsmalloc.h      |  6 ++++++
 mm/zsmalloc.c                 | 29 +++++++++++++++--------------
 4 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index fb655e8..a73a7ed 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -388,7 +388,6 @@ static ssize_t comp_algorithm_store(struct device *dev,
 static ssize_t compact_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t len)
 {
-	unsigned long nr_migrated;
 	struct zram *zram = dev_to_zram(dev);
 	struct zram_meta *meta;
 
@@ -399,8 +398,7 @@ static ssize_t compact_store(struct device *dev,
 	}
 
 	meta = zram->meta;
-	nr_migrated = zs_compact(meta->mem_pool);
-	atomic64_add(nr_migrated, &zram->stats.num_migrated);
+	zs_compact(meta->mem_pool);
 	up_read(&zram->init_lock);
 
 	return len;
@@ -428,26 +426,31 @@ static ssize_t mm_stat_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
 	struct zram *zram = dev_to_zram(dev);
+	struct zs_pool_stats pool_stats;
 	u64 orig_size, mem_used = 0;
 	long max_used;
 	ssize_t ret;
 
+	memset(&pool_stats, 0x00, sizeof(struct zs_pool_stats));
+
 	down_read(&zram->init_lock);
-	if (init_done(zram))
+	if (init_done(zram)) {
 		mem_used = zs_get_total_pages(zram->meta->mem_pool);
+		zs_pool_stats(zram->meta->mem_pool, &pool_stats);
+	}
 
 	orig_size = atomic64_read(&zram->stats.pages_stored);
 	max_used = atomic_long_read(&zram->stats.max_used_pages);
 
 	ret = scnprintf(buf, PAGE_SIZE,
-			"%8llu %8llu %8llu %8lu %8ld %8llu %8llu\n",
+			"%8llu %8llu %8llu %8lu %8ld %8llu %8lu\n",
 			orig_size << PAGE_SHIFT,
 			(u64)atomic64_read(&zram->stats.compr_data_size),
 			mem_used << PAGE_SHIFT,
 			zram->limit_pages << PAGE_SHIFT,
 			max_used << PAGE_SHIFT,
 			(u64)atomic64_read(&zram->stats.zero_pages),
-			(u64)atomic64_read(&zram->stats.num_migrated));
+			pool_stats.num_migrated);
 	up_read(&zram->init_lock);
 
 	return ret;
diff --git a/drivers/block/zram/zram_drv.h b/drivers/block/zram/zram_drv.h
index 6dbe2df..8e92339 100644
--- a/drivers/block/zram/zram_drv.h
+++ b/drivers/block/zram/zram_drv.h
@@ -78,7 +78,6 @@ struct zram_stats {
 	atomic64_t compr_data_size;	/* compressed size of pages stored */
 	atomic64_t num_reads;	/* failed + successful */
 	atomic64_t num_writes;	/* --do-- */
-	atomic64_t num_migrated;	/* no. of migrated object */
 	atomic64_t failed_reads;	/* can happen when memory is too low */
 	atomic64_t failed_writes;	/* can happen when memory is too low */
 	atomic64_t invalid_io;	/* non-page-aligned I/O requests */
diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 1338190..ad3d232 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -34,6 +34,11 @@ enum zs_mapmode {
 	 */
 };
 
+struct zs_pool_stats {
+	/* How many objects were migrated */
+	unsigned long num_migrated;
+};
+
 struct zs_pool;
 
 struct zs_pool *zs_create_pool(char *name, gfp_t flags);
@@ -49,4 +54,5 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 unsigned long zs_get_total_pages(struct zs_pool *pool);
 unsigned long zs_compact(struct zs_pool *pool);
 
+void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats);
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 7ed726a..a0d38bc 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -245,6 +245,7 @@ struct zs_pool {
 	gfp_t flags;	/* allocation flags used when growing pool */
 	atomic_long_t pages_allocated;
 
+	struct zs_pool_stats stats;
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry *stat_dentry;
 #endif
@@ -1587,7 +1588,7 @@ struct zs_compact_control {
 	 /* Starting object index within @s_page which used for live object
 	  * in the subpage. */
 	int index;
-	/* how many of objects are migrated */
+	/* How many of objects were migrated */
 	int nr_migrated;
 };
 
@@ -1599,7 +1600,6 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 	struct page *s_page = cc->s_page;
 	struct page *d_page = cc->d_page;
 	unsigned long index = cc->index;
-	int nr_migrated = 0;
 	int ret = 0;
 
 	while (1) {
@@ -1626,13 +1626,12 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		record_obj(handle, free_obj);
 		unpin_tag(handle);
 		obj_free(pool, class, used_obj);
-		nr_migrated++;
+		cc->nr_migrated++;
 	}
 
 	/* Remember last position in this iteration */
 	cc->s_page = s_page;
 	cc->index = index;
-	cc->nr_migrated = nr_migrated;
 
 	return ret;
 }
@@ -1708,14 +1707,13 @@ static unsigned long zs_can_compact(struct size_class *class)
 	return obj_wasted * get_pages_per_zspage(class->size);
 }
 
-static unsigned long __zs_compact(struct zs_pool *pool,
-				struct size_class *class)
+static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 {
 	struct zs_compact_control cc;
 	struct page *src_page;
 	struct page *dst_page = NULL;
-	unsigned long nr_total_migrated = 0;
 
+	cc.nr_migrated = 0;
 	spin_lock(&class->lock);
 	while ((src_page = isolate_source_page(class))) {
 
@@ -1737,7 +1735,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 				break;
 
 			putback_zspage(pool, class, dst_page);
-			nr_total_migrated += cc.nr_migrated;
 		}
 
 		/* Stop if we couldn't find slot */
@@ -1747,7 +1744,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 		putback_zspage(pool, class, dst_page);
 		putback_zspage(pool, class, src_page);
 		spin_unlock(&class->lock);
-		nr_total_migrated += cc.nr_migrated;
 		cond_resched();
 		spin_lock(&class->lock);
 	}
@@ -1755,15 +1751,14 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 	if (src_page)
 		putback_zspage(pool, class, src_page);
 
-	spin_unlock(&class->lock);
+	pool->stats.num_migrated += cc.nr_migrated;
 
-	return nr_total_migrated;
+	spin_unlock(&class->lock);
 }
 
 unsigned long zs_compact(struct zs_pool *pool)
 {
 	int i;
-	unsigned long nr_migrated = 0;
 	struct size_class *class;
 
 	for (i = zs_size_classes - 1; i >= 0; i--) {
@@ -1772,13 +1767,19 @@ unsigned long zs_compact(struct zs_pool *pool)
 			continue;
 		if (class->index != i)
 			continue;
-		nr_migrated += __zs_compact(pool, class);
+		__zs_compact(pool, class);
 	}
 
-	return nr_migrated;
+	return pool->stats.num_migrated;
 }
 EXPORT_SYMBOL_GPL(zs_compact);
 
+void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats)
+{
+	memcpy(stats, &pool->stats, sizeof(struct zs_pool_stats));
+}
+EXPORT_SYMBOL_GPL(zs_pool_stats);
+
 /**
  * zs_create_pool - Creates an allocation pool to work from.
  * @flags: allocation flags used to allocate pool metadata
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
