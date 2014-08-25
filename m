Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 20BD16B0036
	for <linux-mm@kvack.org>; Sun, 24 Aug 2014 20:05:28 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so19749824pad.23
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 17:05:27 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id e13si50739487pdk.78.2014.08.24.17.05.25
        for <linux-mm@kvack.org>;
        Sun, 24 Aug 2014 17:05:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v5 1/4] zsmalloc: move pages_allocated to zs_pool
Date: Mon, 25 Aug 2014 09:05:53 +0900
Message-Id: <1408925156-11733-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1408925156-11733-1-git-send-email-minchan@kernel.org>
References: <1408925156-11733-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com, seungho1.park@lge.com, Luigi Semenzato <semenzato@google.com>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjennings@variantweb.net>, Dan Streetman <ddstreet@ieee.org>, ds2horner@gmail.com, Minchan Kim <minchan@kernel.org>

pages_allocated has counted in size_class structure and when user
of zsmalloc want to see total_size_bytes, it should gather all of
count from each size_class to report the sum.

it's not bad if user don't see the value often but if user start
to see the value frequently, it would be not a good deal for
performance pov.

This patch moves the count from size_class to zs_pool so it could
reduce memory footprint (from [255 * 8byte] to
[sizeof(atomic_long_t)]).

Reviewed-by: Dan Streetman <ddstreet@ieee.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 94f38fac5e81..2a4acf400846 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -199,9 +199,6 @@ struct size_class {
 
 	spinlock_t lock;
 
-	/* stats */
-	u64 pages_allocated;
-
 	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
 };
 
@@ -220,6 +217,7 @@ struct zs_pool {
 	struct size_class size_class[ZS_SIZE_CLASSES];
 
 	gfp_t flags;	/* allocation flags used when growing pool */
+	atomic_long_t pages_allocated;
 };
 
 /*
@@ -1028,8 +1026,9 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
 			return 0;
 
 		set_zspage_mapping(first_page, class->index, ZS_EMPTY);
+		atomic_long_add(class->pages_per_zspage,
+					&pool->pages_allocated);
 		spin_lock(&class->lock);
-		class->pages_allocated += class->pages_per_zspage;
 	}
 
 	obj = (unsigned long)first_page->freelist;
@@ -1082,14 +1081,13 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
 
 	first_page->inuse--;
 	fullness = fix_fullness_group(pool, first_page);
-
-	if (fullness == ZS_EMPTY)
-		class->pages_allocated -= class->pages_per_zspage;
-
 	spin_unlock(&class->lock);
 
-	if (fullness == ZS_EMPTY)
+	if (fullness == ZS_EMPTY) {
+		atomic_long_sub(class->pages_per_zspage,
+				&pool->pages_allocated);
 		free_zspage(first_page);
+	}
 }
 EXPORT_SYMBOL_GPL(zs_free);
 
@@ -1185,12 +1183,7 @@ EXPORT_SYMBOL_GPL(zs_unmap_object);
 
 u64 zs_get_total_size_bytes(struct zs_pool *pool)
 {
-	int i;
-	u64 npages = 0;
-
-	for (i = 0; i < ZS_SIZE_CLASSES; i++)
-		npages += pool->size_class[i].pages_allocated;
-
+	u64 npages = atomic_long_read(&pool->pages_allocated);
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
