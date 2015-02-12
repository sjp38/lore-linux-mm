Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id E34C66B0032
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 02:13:02 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id rd3so9565859pab.1
        for <linux-mm@kvack.org>; Wed, 11 Feb 2015 23:13:02 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id bm5si1032707pbd.217.2015.02.11.23.12.59
        for <linux-mm@kvack.org>;
        Wed, 11 Feb 2015 23:13:02 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v4 1/3] mm/cma: change fallback behaviour for CMA freepage
Date: Thu, 12 Feb 2015 16:15:03 +0900
Message-Id: <1423725305-3726-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Freepage with MIGRATE_CMA can be used only for MIGRATE_MOVABLE and
they should not be expanded to other migratetype buddy list
to protect them from unmovable/reclaimable allocation. Implementing
these requirements in __rmqueue_fallback(), that is, finding largest
possible block of freepage has bad effect that high order freepage
with MIGRATE_CMA are broken continually although there are suitable
order CMA freepage. Reason is that they are not be expanded to other
migratetype buddy list and next __rmqueue_fallback() invocation try to
finds another largest block of freepage and break it again. So,
MIGRATE_CMA fallback should be handled separately. This patch
introduces __rmqueue_cma_fallback(), that just wrapper of
__rmqueue_smallest() and call it before __rmqueue_fallback()
if migratetype == MIGRATE_MOVABLE.

This results in unintended behaviour change that MIGRATE_CMA freepage
is always used first rather than other migratetype as movable
allocation's fallback. But, as already mentioned above,
MIGRATE_CMA can be used only for MIGRATE_MOVABLE, so it is better
to use MIGRATE_CMA freepage first as much as possible. Otherwise,
we needlessly take up precious freepages with other migratetype and
increase chance of fragmentation.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c |   36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8d52ab1..e64b260 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1029,11 +1029,9 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
 	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
 #ifdef CONFIG_CMA
-	[MIGRATE_MOVABLE]     = { MIGRATE_CMA,         MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
 	[MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
-#else
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
 #endif
 	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
 #ifdef CONFIG_MEMORY_ISOLATION
@@ -1041,6 +1039,17 @@ static int fallbacks[MIGRATE_TYPES][4] = {
 #endif
 };
 
+#ifdef CONFIG_CMA
+static struct page *__rmqueue_cma_fallback(struct zone *zone,
+					unsigned int order)
+{
+	return __rmqueue_smallest(zone, order, MIGRATE_CMA);
+}
+#else
+static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
+					unsigned int order) { return NULL; }
+#endif
+
 /*
  * Move the free pages in a range to the free lists of the requested type.
  * Note that start_page and end_pages are not aligned on a pageblock
@@ -1192,19 +1201,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 					struct page, lru);
 			area->nr_free--;
 
-			if (!is_migrate_cma(migratetype)) {
-				try_to_steal_freepages(zone, page,
-							start_migratetype,
-							migratetype);
-			} else {
-				/*
-				 * When borrowing from MIGRATE_CMA, we need to
-				 * release the excess buddy pages to CMA
-				 * itself, and we do not try to steal extra
-				 * free pages.
-				 */
-				buddy_type = migratetype;
-			}
+			try_to_steal_freepages(zone, page, start_migratetype,
+								migratetype);
 
 			/* Remove the page from the freelists */
 			list_del(&page->lru);
@@ -1246,7 +1244,11 @@ retry_reserve:
 	page = __rmqueue_smallest(zone, order, migratetype);
 
 	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
-		page = __rmqueue_fallback(zone, order, migratetype);
+		if (migratetype == MIGRATE_MOVABLE)
+			page = __rmqueue_cma_fallback(zone, order);
+
+		if (!page)
+			page = __rmqueue_fallback(zone, order, migratetype);
 
 		/*
 		 * Use MIGRATE_RESERVE rather than fail an allocation. goto
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
