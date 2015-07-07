Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 537699003C7
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 07:58:25 -0400 (EDT)
Received: by pddu5 with SMTP id u5so37303057pdd.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 04:58:25 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id k9si23953534pbq.98.2015.07.07.04.58.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 04:58:24 -0700 (PDT)
Received: by pacgz10 with SMTP id gz10so38678395pac.3
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 04:58:23 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH v6 7/7] zsmalloc: use shrinker to trigger auto-compaction
Date: Tue,  7 Jul 2015 20:57:01 +0900
Message-Id: <1436270221-17844-8-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1436270221-17844-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Perform automatic pool compaction by a shrinker when system
is getting tight on memory.

User-space has a very little knowledge regarding zsmalloc fragmentation
and basically has no mechanism to tell whether compaction will result
in any memory gain. Another issue is that user space is not always
aware of the fact that system is getting tight on memory. Which leads
to very uncomfortable scenarios when user space may start issuing
compaction 'randomly' or from crontab (for example). Fragmentation
is not always necessarily bad, allocated and unused objects, after all,
may be filled with the data later, w/o the need of allocating a new
zspage. On the other hand, we obviously don't want to waste memory
when the system needs it.

Compaction now has a relatively quick pool scan so we are able to
estimate the number of pages that will be freed easily, which makes it
possible to call this function from a shrinker->count_objects() callback.
We also abort compaction as soon as we detect that we can't free any
pages any more, preventing wasteful objects migrations.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Suggested-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 74 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 74 insertions(+)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 13f2c4a..83b2e97 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -247,6 +247,10 @@ struct zs_pool {
 	atomic_long_t		pages_allocated;
 
 	struct zs_pool_stats	stats;
+
+	/* Compact classes */
+	struct shrinker		shrinker;
+	bool			shrinker_enabled;
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry		*stat_dentry;
 #endif
@@ -1787,6 +1791,69 @@ void zs_pool_stats(struct zs_pool *pool, struct zs_pool_stats *stats)
 }
 EXPORT_SYMBOL_GPL(zs_pool_stats);
 
+static unsigned long zs_shrinker_scan(struct shrinker *shrinker,
+		struct shrink_control *sc)
+{
+	unsigned long pages_freed;
+	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
+			shrinker);
+
+	pages_freed = pool->stats.pages_compacted;
+	/*
+	 * Compact classes and calculate compaction delta.
+	 * Can run concurrently with a manually triggered
+	 * (by user) compaction.
+	 */
+	pages_freed = zs_compact(pool) - pages_freed;
+
+	return pages_freed ? pages_freed : SHRINK_STOP;
+}
+
+static unsigned long zs_shrinker_count(struct shrinker *shrinker,
+		struct shrink_control *sc)
+{
+	int i;
+	struct size_class *class;
+	unsigned long pages_to_free = 0;
+	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
+			shrinker);
+
+	if (!pool->shrinker_enabled)
+		return 0;
+
+	for (i = zs_size_classes - 1; i >= 0; i--) {
+		class = pool->size_class[i];
+		if (!class)
+			continue;
+		if (class->index != i)
+			continue;
+
+		spin_lock(&class->lock);
+		pages_to_free += zs_can_compact(class);
+		spin_unlock(&class->lock);
+	}
+
+	return pages_to_free;
+}
+
+static void zs_unregister_shrinker(struct zs_pool *pool)
+{
+	if (pool->shrinker_enabled) {
+		unregister_shrinker(&pool->shrinker);
+		pool->shrinker_enabled = false;
+	}
+}
+
+static int zs_register_shrinker(struct zs_pool *pool)
+{
+	pool->shrinker.scan_objects = zs_shrinker_scan;
+	pool->shrinker.count_objects = zs_shrinker_count;
+	pool->shrinker.batch = 0;
+	pool->shrinker.seeks = DEFAULT_SEEKS;
+
+	return register_shrinker(&pool->shrinker);
+}
+
 /**
  * zs_create_pool - Creates an allocation pool to work from.
  * @flags: allocation flags used to allocate pool metadata
@@ -1872,6 +1939,12 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
 	if (zs_pool_stat_create(name, pool))
 		goto err;
 
+	/*
+	 * Not critical, we still can use the pool
+	 * and user can trigger compaction manually.
+	 */
+	if (zs_register_shrinker(pool) == 0)
+		pool->shrinker_enabled = true;
 	return pool;
 
 err:
@@ -1884,6 +1957,7 @@ void zs_destroy_pool(struct zs_pool *pool)
 {
 	int i;
 
+	zs_unregister_shrinker(pool);
 	zs_pool_stat_destroy(pool);
 
 	for (i = 0; i < zs_size_classes; i++) {
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
