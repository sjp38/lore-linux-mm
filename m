Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E2A25900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 08:05:15 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so49379509pab.3
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:05:15 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com. [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id py3si10620864pac.177.2015.06.05.05.05.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 05:05:15 -0700 (PDT)
Received: by pdbnf5 with SMTP id nf5so52386819pdb.2
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 05:05:14 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCHv2 8/8] zsmalloc: register a shrinker to trigger auto-compaction
Date: Fri,  5 Jun 2015 21:03:58 +0900
Message-Id: <1433505838-23058-9-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1433505838-23058-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

Perform automatic pool compaction by a shrinker when system
is getting tight on memory.

Demonstration (this output is merely to show auto-compaction
effectiveness and is not part of the code):
[..]
[ 4283.803766] zram0 zs_shrinker_scan freed 364
[ 4285.398937] zram0 zs_shrinker_scan freed 471
[ 4286.044095] zram0 zs_shrinker_scan freed 273
[ 4286.951824] zram0 zs_shrinker_scan freed 312
[ 4287.583563] zram0 zs_shrinker_scan freed 222
[ 4289.360971] zram0 zs_shrinker_scan freed 343
[ 4289.884653] zram0 zs_shrinker_scan freed 210
[ 4291.204705] zram0 zs_shrinker_scan freed 175
[ 4292.043656] zram0 zs_shrinker_scan freed 425
[ 4292.273397] zram0 zs_shrinker_scan freed 109
[ 4292.513351] zram0 zs_shrinker_scan freed 191
[..]

cat /sys/block/zram0/mm_stat
 2908798976 2061913167 2091438080        0 2128449536      868     6074

Compaction now has a relatively quick pool scan so we are able to
estimate the number of pages that will be freed easily, which makes it
possible to call this function from a shrinker->count_objects() callback.
We also abort compaction as soon as we detect that we can't free any
pages any more, preventing wasteful objects migrations. In the example
above, "6074 objects were migrated" implies that we actually released
zspages back to system.

The initial patch was triggering compaction from zs_free() for
every ZS_ALMOST_EMPTY page. Minchan Kim proposed to use a slab
shrinker.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Reported-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 81 +++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 71 insertions(+), 10 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index a81e75b..f262d8d 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -247,7 +247,9 @@ struct zs_pool {
 	atomic_long_t		pages_allocated;
 	/* How many objects were migrated */
 	unsigned long		num_migrated;
-
+	/* Compact classes */
+	struct shrinker		shrinker;
+	bool			shrinker_enabled;
 #ifdef CONFIG_ZSMALLOC_STAT
 	struct dentry		*stat_dentry;
 #endif
@@ -1728,12 +1730,9 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 
 		while ((dst_page = isolate_target_page(class))) {
 			cc.d_page = dst_page;
-			/*
-			 * If there is no more space in dst_page, resched
-			 * and see if anyone had allocated another zspage.
-			 */
+
 			if (!migrate_zspage(pool, class, &cc))
-				break;
+				goto out;
 
 			putback_zspage(pool, class, dst_page);
 		}
@@ -1744,11 +1743,10 @@ static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 
 		putback_zspage(pool, class, dst_page);
 		putback_zspage(pool, class, src_page);
-		spin_unlock(&class->lock);
-		cond_resched();
-		spin_lock(&class->lock);
 	}
-
+out:
+	if (dst_page)
+		putback_zspage(pool, class, dst_page);
 	if (src_page)
 		putback_zspage(pool, class, src_page);
 
@@ -1772,6 +1770,65 @@ unsigned long zs_compact(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_compact);
 
+static unsigned long zs_shrinker_scan(struct shrinker *shrinker,
+		struct shrink_control *sc)
+{
+	unsigned long freed;
+	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
+			shrinker);
+
+	freed = pool->num_migrated;
+	/* Compact classes and calculate compaction delta */
+	freed = zs_compact(pool) - freed;
+
+	return freed ? freed : SHRINK_STOP;
+}
+
+static unsigned long zs_shrinker_count(struct shrinker *shrinker,
+		struct shrink_control *sc)
+{
+	int i;
+	struct size_class *class;
+	unsigned long to_free = 0;
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
+		to_free += zs_can_compact(class);
+		spin_unlock(&class->lock);
+	}
+
+	return to_free;
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
@@ -1857,6 +1914,9 @@ struct zs_pool *zs_create_pool(char *name, gfp_t flags)
 	if (zs_pool_stat_create(name, pool))
 		goto err;
 
+	/* Not critical, we still can use the pool */
+	if (zs_register_shrinker(pool) == 0)
+		pool->shrinker_enabled = true;
 	return pool;
 
 err:
@@ -1869,6 +1929,7 @@ void zs_destroy_pool(struct zs_pool *pool)
 {
 	int i;
 
+	zs_unregister_shrinker(pool);
 	zs_pool_stat_destroy(pool);
 
 	for (i = 0; i < zs_size_classes; i++) {
-- 
2.4.2.387.gf86f31a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
