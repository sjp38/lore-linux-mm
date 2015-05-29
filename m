Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE8E6B0085
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:06:30 -0400 (EDT)
Received: by pdfh10 with SMTP id h10so55531541pdf.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:30 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id e3si8761045pdc.240.2015.05.29.08.06.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:06:29 -0700 (PDT)
Received: by padbw4 with SMTP id bw4so62563379pad.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:29 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 05/10] zsmalloc: add `num_migrated' to zs_pool
Date: Sat, 30 May 2015 00:05:23 +0900
Message-Id: <1432911928-14654-6-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

remove the number of migrated objects from `zs_compact_control'
and make it a `zs_pool' member. `zs_compact_control' has a limited
lifespan; we lose it when zs_compaction() returns back to zram. to
keep track of objects migrated during auto-compaction we need to
store this number in zs_pool.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 36 ++++++++++++++----------------------
 1 file changed, 14 insertions(+), 22 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index fa72a81..54eefc3 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -237,16 +237,19 @@ struct link_free {
 };
 
 struct zs_pool {
-	char *name;
+	char 			*name;
 
-	struct size_class **size_class;
-	struct kmem_cache *handle_cachep;
+	struct size_class	**size_class;
+	struct kmem_cache	*handle_cachep;
 
-	gfp_t flags;	/* allocation flags used when growing pool */
-	atomic_long_t pages_allocated;
+	/* allocation flags used when growing pool */
+	gfp_t 			flags;
+	atomic_long_t 		pages_allocated;
+	/* how many of objects were migrated */
+	unsigned long		num_migrated;
 
 #ifdef CONFIG_ZSMALLOC_STAT
-	struct dentry *stat_dentry;
+	struct dentry		*stat_dentry;
 #endif
 };
 
@@ -1576,8 +1579,6 @@ struct zs_compact_control {
 	 /* Starting object index within @s_page which used for live object
 	  * in the subpage. */
 	int index;
-	/* how many of objects are migrated */
-	int nr_migrated;
 };
 
 static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
@@ -1588,7 +1589,6 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 	struct page *s_page = cc->s_page;
 	struct page *d_page = cc->d_page;
 	unsigned long index = cc->index;
-	int nr_migrated = 0;
 	int ret = 0;
 
 	while (1) {
@@ -1615,13 +1615,12 @@ static int migrate_zspage(struct zs_pool *pool, struct size_class *class,
 		record_obj(handle, free_obj);
 		unpin_tag(handle);
 		obj_free(pool, class, used_obj);
-		nr_migrated++;
+		pool->num_migrated++;
 	}
 
 	/* Remember last position in this iteration */
 	cc->s_page = s_page;
 	cc->index = index;
-	cc->nr_migrated = nr_migrated;
 
 	return ret;
 }
@@ -1695,13 +1694,11 @@ static bool zs_can_compact(struct size_class *class)
 	return ret > 0;
 }
 
-static unsigned long __zs_compact(struct zs_pool *pool,
-				struct size_class *class)
+static void __zs_compact(struct zs_pool *pool, struct size_class *class)
 {
 	struct zs_compact_control cc;
 	struct page *src_page;
 	struct page *dst_page = NULL;
-	unsigned long nr_total_migrated = 0;
 
 	spin_lock(&class->lock);
 	while ((src_page = isolate_source_page(class))) {
@@ -1724,7 +1721,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 				break;
 
 			putback_zspage(pool, class, dst_page);
-			nr_total_migrated += cc.nr_migrated;
 		}
 
 		/* Stop if we couldn't find slot */
@@ -1734,7 +1730,6 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 		putback_zspage(pool, class, dst_page);
 		putback_zspage(pool, class, src_page);
 		spin_unlock(&class->lock);
-		nr_total_migrated += cc.nr_migrated;
 		cond_resched();
 		spin_lock(&class->lock);
 	}
@@ -1743,14 +1738,11 @@ static unsigned long __zs_compact(struct zs_pool *pool,
 		putback_zspage(pool, class, src_page);
 
 	spin_unlock(&class->lock);
-
-	return nr_total_migrated;
 }
 
 unsigned long zs_compact(struct zs_pool *pool)
 {
 	int i;
-	unsigned long nr_migrated = 0;
 	struct size_class *class;
 
 	for (i = zs_size_classes - 1; i >= 0; i--) {
@@ -1759,10 +1751,10 @@ unsigned long zs_compact(struct zs_pool *pool)
 			continue;
 		if (class->index != i)
 			continue;
-		nr_migrated += __zs_compact(pool, class);
+		__zs_compact(pool, class);
 	}
-
-	return nr_migrated;
+	/* can be a bit outdated */
+	return pool->num_migrated;
 }
 EXPORT_SYMBOL_GPL(zs_compact);
 
-- 
2.4.2.337.gfae46aa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
