Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5CA6B0080
	for <linux-mm@kvack.org>; Tue, 30 Jun 2015 08:37:10 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so5103677pab.1
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:37:09 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id w13si6442050pbt.178.2015.06.30.05.37.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jun 2015 05:37:09 -0700 (PDT)
Received: by pdcu2 with SMTP id u2so5745224pdc.3
        for <linux-mm@kvack.org>; Tue, 30 Jun 2015 05:37:08 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv4 5/7] zsmalloc/zram: store compaction stats in zspool
Date: Tue, 30 Jun 2015 21:35:56 +0900
Message-Id: <1435667758-14075-6-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1435667758-14075-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

`zs_compact_control' accounts the number of migrated objects but
it has a limited lifespan -- we lose it as soon as zs_compaction()
returns back to zram. It was fine, because (a) zram had it's own
counter of migrated objects and (b) only zram could trigger
compaction. However, this does not work for automatic pool
compaction (not issued by zram). To account objects migrated
during auto-compaction (issued by the shrinker) we need to store
this number in zs_pool.

A new zsmalloc zs_get_num_migrated() symbol exports zs_pool's
->num_migrated counter, so we better start using it, rather than
continue keeping zram's own `num_migrated' copy in zram_stats.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 drivers/block/zram/zram_drv.c | 12 ++++++------
 drivers/block/zram/zram_drv.h |  1 -
 include/linux/zsmalloc.h      |  1 +
 mm/zsmalloc.c                 | 44 ++++++++++++++++++++++---------------------
 4 files changed, 30 insertions(+), 28 deletions(-)

diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index fb655e8..28ad3f8 100644
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
@@ -428,13 +426,15 @@ static ssize_t mm_stat_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
 	struct zram *zram = dev_to_zram(dev);
-	u64 orig_size, mem_used = 0;
+	u64 orig_size, mem_used = 0, num_migrated = 0;
 	long max_used;
 	ssize_t ret;
 
 	down_read(&zram->init_lock);
-	if (init_done(zram))
+	if (init_done(zram)) {
 		mem_used = zs_get_total_pages(zram->meta->mem_pool);
+		num_migrated = zs_get_num_migrated(zram->meta->mem_pool);
+	}
 
 	orig_size = atomic64_read(&zram->stats.pages_stored);
 	max_used = atomic_long_read(&zram->stats.max_used_pages);
@@ -447,7 +447,7 @@ static ssize_t mm_stat_show(struct device *dev,
 			zram->limit_pages << PAGE_SHIFT,
 			max_used << PAGE_SHIFT,
 			(u64)atomic64_read(&zram->stats.zero_pages),
-			(u64)atomic64_read(&zram->stats.num_migrated));
+			num_migrated);
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
index 1338190..e878875 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -47,6 +47,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 unsigned long zs_get_total_pages(struct zs_pool *pool);
+unsigned long zs_get_num_migrated(struct zs_pool *pool);
 unsigned long zs_compact(struct zs_pool *pool);
 
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index ce1484e..e0f508a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -237,16 +237,19 @@ struct link_free {
 };
 
 struct zs_pool {
-	char *name;
+	char			*name;
 
-	struct size_class **size_class;
-	struct kmem_cache *handle_cachep;
+	struct size_class	**size_class;
+	struct kmem_cache	*handle_cachep;
 
-	gfp_t flags;	/* allocation flags used when growing pool */
-	atomic_long_t pages_allocated;
+	/* Allocation flags used when growing pool */
+	gfp_t			flags;
+	atomic_long_t		pages_allocated;
+	/* How many objects were migrated */
+	unsigned long		num_migrated;
 
 #ifdef CONFIG_ZSMALLOC_STAT
-	struct dentry *stat_dentry;
+	struct dentry		*stat_dentry;
 #endif
 };
 
@@ -1221,6 +1224,12 @@ unsigned long zs_get_total_pages(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_get_total_pages);
 
+unsigned long zs_get_num_migrated(struct zs_pool *pool)
+{
+	return pool->num_migrated;
+}
+EXPORT_SYMBOL_GPL(zs_get_num_migrated);
+
 /**
  * zs_map_object - get address of allocated object from handle.
  * @pool: pool from which the object was allocated
@@ -1587,7 +1596,7 @@ struct zs_compact_control {
 	 /* Starting object index within @s_page which used for live object
 	  * in the subpage. */
 	int index;
-	/* how many of objects are migrated */
+	/* How many of objects were migrated */
 	int nr_migrated;
 };
 
@@ -1599,7 +1608,6 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 	struct page *s_page = cc->s_page;
 	struct page *d_page = cc->d_page;
 	unsigned long index = cc->index;
-	int nr_migrated = 0;
 	int ret = 0;
 
 	while (1) {
@@ -1626,13 +1634,12 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
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
@@ -1707,14 +1714,13 @@ static unsigned long zs_can_compact(struct size_class *class)
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
 
@@ -1736,7 +1742,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 				break;
 
 			putback_zspage(pool, class, dst_page);
-			nr_total_migrated += cc.nr_migrated;
 		}
 
 		/* Stop if we couldn't find slot */
@@ -1746,7 +1751,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 		putback_zspage(pool, class, dst_page);
 		putback_zspage(pool, class, src_page);
 		spin_unlock(&class->lock);
-		nr_total_migrated += cc.nr_migrated;
 		cond_resched();
 		spin_lock(&class->lock);
 	}
@@ -1754,15 +1758,14 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 	if (src_page)
 		putback_zspage(pool, class, src_page);
 
-	spin_unlock(&class->lock);
+	pool->num_migrated += cc.nr_migrated;
 
-	return nr_total_migrated;
+	spin_unlock(&class->lock);
 }
 
 unsigned long zs_compact(struct zs_pool *pool)
 {
 	int i;
-	unsigned long nr_migrated = 0;
 	struct size_class *class;
 
 	for (i = zs_size_classes - 1; i >= 0; i--) {
@@ -1771,10 +1774,9 @@ unsigned long zs_compact(struct zs_pool *pool)
 			continue;
 		if (class->index != i)
 			continue;
-		nr_migrated += __zs_compact(pool, class);
+		__zs_compact(pool, class);
 	}
-
-	return nr_migrated;
+	return pool->num_migrated;
 }
 EXPORT_SYMBOL_GPL(zs_compact);
 
-- 
2.5.0.rc0.3.g912bd49

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
