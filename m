Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id 983C26B0035
	for <linux-mm@kvack.org>; Tue, 19 Aug 2014 03:54:34 -0400 (EDT)
Received: by mail-we0-f180.google.com with SMTP id w61so6055656wes.11
        for <linux-mm@kvack.org>; Tue, 19 Aug 2014 00:54:34 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id i3si28738594wjx.132.2014.08.19.00.54.31
        for <linux-mm@kvack.org>;
        Tue, 19 Aug 2014 00:54:32 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 1/4] zsmalloc: move pages_allocated to zs_pool
Date: Tue, 19 Aug 2014 16:54:44 +0900
Message-Id: <1408434887-16387-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1408434887-16387-1-git-send-email-minchan@kernel.org>
References: <1408434887-16387-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, ds2horner@gmail.com, Minchan Kim <minchan@kernel.org>

Pages_allocated has counted in size_class structure and when user
want to see total_size_bytes, it gathers all of value from each
size_class to report the sum.

It's not bad if user don't see the value often but if user start
to see the value frequently, it would be not a good deal for
performance POV.

This patch moves the variable from size_class to zs_pool so it would
reduce memory footprint (from [255 * 8byte] to [sizeof(atomic_t)])
but it adds new locking overhead but it wouldn't be severe because
it's not a hot path in zs_malloc(ie, it is called only when new
zspage is created, not a object).

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 94f38fac5e81..a65924255763 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -199,9 +199,6 @@ struct size_class {
 
 	spinlock_t lock;
 
-	/* stats */
-	u64 pages_allocated;
-
 	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
 };
 
@@ -217,9 +214,12 @@ struct link_free {
 };
 
 struct zs_pool {
+	spinlock_t stat_lock;
+
 	struct size_class size_class[ZS_SIZE_CLASSES];
 
 	gfp_t flags;	/* allocation flags used when growing pool */
+	unsigned long pages_allocated;
 };
 
 /*
@@ -967,6 +967,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 
 	}
 
+	spin_lock_init(&pool->stat_lock);
 	pool->flags = flags;
 
 	return pool;
@@ -1028,8 +1029,10 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 			return 0;
 
 		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
+		spin_lock(&pool->stat_lock);
+		pool->pages_allocated += class->pages_per_zspage;
+		spin_unlock(&pool->stat_lock);
 		spin_lock(&class->lock);
-		class->pages_allocated += class->pages_per_zspage;
 	}
 
 	obj = (unsigned long)first_page->freelist;
@@ -1082,14 +1085,14 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
 
 	first_page->inuse--;
 	fullness = fix_fullness_group(pool, first_page);
-
-	if (fullness == ZS_EMPTY)
-		class->pages_allocated -= class->pages_per_zspage;
-
 	spin_unlock(&class->lock);
 
-	if (fullness == ZS_EMPTY)
+	if (fullness == ZS_EMPTY) {
+		spin_lock(&pool->stat_lock);
+		pool->pages_allocated -= class->pages_per_zspage;
+		spin_unlock(&pool->stat_lock);
 		free_zspage(first_page);
+	}
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
@@ -1185,12 +1188,11 @@ EXPORT_SYMBOL_GPL(zs_unmap_object);
 
 u64 zs_get_total_size_bytes(struct zs_pool *pool)
 {
-	int i;
-	u64 npages = 0;
-
-	for (i = 0; i < ZS_SIZE_CLASSES; i++)
-		npages += pool->size_class[i].pages_allocated;
+	u64 npages;
 
+	spin_lock(&pool->stat_lock);
+	npages = pool->pages_allocated;
+	spin_unlock(&pool->stat_lock);
 	return npages << PAGE_SHIFT;
 }
 EXPORT_SYMBOL_GPL(zs_get_total_size_bytes);
-- 
2.0.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
