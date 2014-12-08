Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 19E516B006E
	for <linux-mm@kvack.org>; Mon,  8 Dec 2014 02:12:44 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so4653368pab.5
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 23:12:43 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id yl4si58501169pbc.151.2014.12.07.23.12.40
        for <linux-mm@kvack.org>;
        Sun, 07 Dec 2014 23:12:41 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 2/4] mm/page_alloc: expands broken freepage to proper buddy list when steal
Date: Mon,  8 Dec 2014 16:16:18 +0900
Message-Id: <1418022980-4584-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1418022980-4584-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is odd behaviour when we steal freepages from other migratetype
buddy list. In try_to_steal_freepages(), we move all freepages in
the pageblock that founded freepage is belong to to the request
migratetype in order to mitigate fragmentation. If the number of moved
pages are enough to change pageblock migratetype, there is no problem. If
not enough, we don't change pageblock migratetype and add broken freepages
to the original migratetype buddy list rather than request migratetype
one. For me, this is odd, because we already moved all freepages in this
pageblock to the request migratetype. This patch fixes this situation to
add broken freepages to the request migratetype buddy list in this case.

This patch introduce new function that can help to decide if we can
steal the page without resulting in fragmentation. It will be used in
following patch for compaction finish criteria.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/trace/events/kmem.h |    7 +++--
 mm/page_alloc.c             |   72 +++++++++++++++++++++++++------------------
 2 files changed, 46 insertions(+), 33 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index aece134..4ad10ba 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -268,11 +268,11 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 
 	TP_PROTO(struct page *page,
 		int alloc_order, int fallback_order,
-		int alloc_migratetype, int fallback_migratetype, int new_migratetype),
+		int alloc_migratetype, int fallback_migratetype),
 
 	TP_ARGS(page,
 		alloc_order, fallback_order,
-		alloc_migratetype, fallback_migratetype, new_migratetype),
+		alloc_migratetype, fallback_migratetype),
 
 	TP_STRUCT__entry(
 		__field(	struct page *,	page			)
@@ -289,7 +289,8 @@ TRACE_EVENT(mm_page_alloc_extfrag,
 		__entry->fallback_order		= fallback_order;
 		__entry->alloc_migratetype	= alloc_migratetype;
 		__entry->fallback_migratetype	= fallback_migratetype;
-		__entry->change_ownership	= (new_migratetype == alloc_migratetype);
+		__entry->change_ownership	= (alloc_migratetype ==
+					get_pageblock_migratetype(page));
 	),
 
 	TP_printk("page=%p pfn=%lu alloc_order=%d fallback_order=%d pageblock_order=%d alloc_migratetype=%d fallback_migratetype=%d fragmenting=%d change_ownership=%d",
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7c46d0f..7b4c9aa 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1139,44 +1139,50 @@ static void change_pageblock_range(struct page *pageblock_page,
  * Returns the new migratetype of the pageblock (or the same old migratetype
  * if it was unchanged).
  */
-static int try_to_steal_freepages(struct zone *zone, struct page *page,
-				  int start_type, int fallback_type)
+static void try_to_steal_freepages(struct zone *zone, struct page *page,
+							int target_mt)
 {
+	int pages;
 	int current_order = page_order(page);
 
-	/*
-	 * When borrowing from MIGRATE_CMA, we need to release the excess
-	 * buddy pages to CMA itself. We also ensure the freepage_migratetype
-	 * is set to CMA so it is returned to the correct freelist in case
-	 * the page ends up being not actually allocated from the pcp lists.
-	 */
-	if (is_migrate_cma(fallback_type))
-		return fallback_type;
-
 	/* Take ownership for orders >= pageblock_order */
 	if (current_order >= pageblock_order) {
-		change_pageblock_range(page, current_order, start_type);
-		return start_type;
+		change_pageblock_range(page, current_order, target_mt);
+		return;
 	}
 
-	if (current_order >= pageblock_order / 2 ||
-	    start_type == MIGRATE_RECLAIMABLE ||
-	    page_group_by_mobility_disabled) {
-		int pages;
+	pages = move_freepages_block(zone, page, target_mt);
 
-		pages = move_freepages_block(zone, page, start_type);
+	/* Claim the whole block if over half of it is free */
+	if (pages >= (1 << (pageblock_order-1)) ||
+			page_group_by_mobility_disabled) {
 
-		/* Claim the whole block if over half of it is free */
-		if (pages >= (1 << (pageblock_order-1)) ||
-				page_group_by_mobility_disabled) {
+		set_pageblock_migratetype(page, target_mt);
+	}
+}
 
-			set_pageblock_migratetype(page, start_type);
-			return start_type;
-		}
+static bool can_steal_freepages(unsigned int order,
+			int start_mt, int fallback_mt)
+{
+	/*
+	 * When borrowing from MIGRATE_CMA, we need to release the excess
+	 * buddy pages to CMA itself. We also ensure the freepage_migratetype
+	 * is set to CMA so it is returned to the correct freelist in case
+	 * the page ends up being not actually allocated from the pcp lists.
+	 */
+	if (is_migrate_cma(fallback_mt))
+		return false;
 
-	}
+	/* Can take ownership for orders >= pageblock_order */
+	if (order >= pageblock_order)
+		return true;
+
+	if (order >= pageblock_order / 2 ||
+		start_mt == MIGRATE_RECLAIMABLE ||
+		page_group_by_mobility_disabled)
+		return true;
 
-	return fallback_type;
+	return false;
 }
 
 /* Remove an element from the buddy allocator from the fallback list */
@@ -1187,6 +1193,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 	unsigned int current_order;
 	struct page *page;
 	int migratetype, new_type, i;
+	bool can_steal;
 
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1;
@@ -1194,6 +1201,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 				--current_order) {
 		for (i = 0;; i++) {
 			migratetype = fallbacks[start_migratetype][i];
+			new_type = migratetype;
 
 			/* MIGRATE_RESERVE handled later if necessary */
 			if (migratetype == MIGRATE_RESERVE)
@@ -1207,9 +1215,13 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 					struct page, lru);
 			area->nr_free--;
 
-			new_type = try_to_steal_freepages(zone, page,
-							  start_migratetype,
-							  migratetype);
+			can_steal = can_steal_freepages(current_order,
+					start_migratetype, migratetype);
+			if (can_steal) {
+				new_type = start_migratetype;
+				try_to_steal_freepages(zone, page,
+							start_migratetype);
+			}
 
 			/* Remove the page from the freelists */
 			list_del(&page->lru);
@@ -1225,7 +1237,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 			set_freepage_migratetype(page, new_type);
 
 			trace_mm_page_alloc_extfrag(page, order, current_order,
-				start_migratetype, migratetype, new_type);
+					start_migratetype, migratetype);
 
 			return page;
 		}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
