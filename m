Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8C1FD6B0078
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 11:01:44 -0500 (EST)
Received: by mail-wg0-f48.google.com with SMTP id y19so9459324wgg.7
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 08:01:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dh10si3255916wib.80.2014.12.12.08.01.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 08:01:41 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/3] mm: always steal split buddies in fallback allocations
Date: Fri, 12 Dec 2014 17:01:24 +0100
Message-Id: <1418400085-3622-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1418400085-3622-1-git-send-email-vbabka@suse.cz>
References: <1418400085-3622-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

When allocation falls back to another migratetype, it will steal a page with
highest available order, and (depending on this order and desired migratetype),
it might also steal the rest of free pages from the same pageblock.

Given the preference of highest available order, it is likely that it will be
higher than the desired order, and result in the stolen buddy page being split.
The remaining pages after split are currently stolen only when the rest of the
free pages are stolen. This can however lead to situations where for MOVABLE
allocations we split e.g. order-4 fallback UNMOVABLE page, but steal only
order-0 page. Then on the next MOVABLE allocation (which may be batched to
fill the pcplists) we split another order-3 or higher page, etc. By stealing
all pages that we have split, we can avoid further stealing.

This patch therefore adjusts the page stealing so that buddy pages created by
split are always stolen. This has effect only on MOVABLE allocations, as
RECLAIMABLE and UNMOVABLE allocations already always do that in addition to
stealing the rest of free pages from the pageblock. The change also allows
to simplify try_to_steal_freepages() and factor out CMA handling.

According to Mel, it has been intended since the beginning that buddy pages
after split would be stolen always, but it doesn't seem like it was ever the
case until commit 47118af076f6 ("mm: mmzone: MIGRATE_CMA migration type
added"). The commit has unintentionally introduced this behavior, but was
reverted by commit 0cbef29a7821 ("mm: __rmqueue_fallback() should respect
pageblock type"). Neither included evaluation.

My evaluation with stress-highalloc from mmtests shows about 2.5x reduction
of page stealing events for MOVABLE allocations, without affecting the page
stealing events for other allocation migratetypes.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Acked-by: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/page_alloc.c | 62 +++++++++++++++++++++++++++------------------------------
 1 file changed, 29 insertions(+), 33 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c32cb64..2cfd5d9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1067,33 +1067,18 @@ static void change_pageblock_range(struct page *pageblock_page,
 /*
  * If breaking a large block of pages, move all free pages to the preferred
  * allocation list. If falling back for a reclaimable kernel allocation, be
- * more aggressive about taking ownership of free pages.
- *
- * On the other hand, never change migration type of MIGRATE_CMA pageblocks
- * nor move CMA pages to different free lists. We don't want unmovable pages
- * to be allocated from MIGRATE_CMA areas.
- *
- * Returns the allocation migratetype if free pages were stolen, or the
- * fallback migratetype if it was decided not to steal.
+ * more aggressive about taking ownership of free pages. If we claim more than
+ * half of the pageblock, change pageblock's migratetype as well.
  */
-static int try_to_steal_freepages(struct zone *zone, struct page *page,
+static void try_to_steal_freepages(struct zone *zone, struct page *page,
 				  int start_type, int fallback_type)
 {
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
 		change_pageblock_range(page, current_order, start_type);
-		return start_type;
+		return;
 	}
 
 	if (current_order >= pageblock_order / 2 ||
@@ -1107,11 +1092,7 @@ static int try_to_steal_freepages(struct zone *zone, struct page *page,
 		if (pages >= (1 << (pageblock_order-1)) ||
 				page_group_by_mobility_disabled)
 			set_pageblock_migratetype(page, start_type);
-
-		return start_type;
 	}
-
-	return fallback_type;
 }
 
 /* Remove an element from the buddy allocator from the fallback list */
@@ -1121,14 +1102,15 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 	struct free_area *area;
 	unsigned int current_order;
 	struct page *page;
-	int migratetype, new_type, i;
 
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1;
 				current_order >= order && current_order <= MAX_ORDER-1;
 				--current_order) {
+		int i;
 		for (i = 0;; i++) {
-			migratetype = fallbacks[start_migratetype][i];
+			int migratetype = fallbacks[start_migratetype][i];
+			int buddy_type = start_migratetype;
 
 			/* MIGRATE_RESERVE handled later if necessary */
 			if (migratetype == MIGRATE_RESERVE)
@@ -1142,22 +1124,36 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 					struct page, lru);
 			area->nr_free--;
 
-			new_type = try_to_steal_freepages(zone, page,
-							  start_migratetype,
-							  migratetype);
+			if (!is_migrate_cma(migratetype)) {
+				try_to_steal_freepages(zone, page,
+							start_migratetype,
+							migratetype);
+			} else {
+				/*
+				 * When borrowing from MIGRATE_CMA, we need to
+				 * release the excess buddy pages to CMA
+				 * itself, and we do not try to steal extra
+				 * free pages.
+				 */
+				buddy_type = migratetype;
+			}
 
 			/* Remove the page from the freelists */
 			list_del(&page->lru);
 			rmv_page_order(page);
 
 			expand(zone, page, order, current_order, area,
-			       new_type);
-			/* The freepage_migratetype may differ from pageblock's
+					buddy_type);
+
+			/*
+			 * The freepage_migratetype may differ from pageblock's
 			 * migratetype depending on the decisions in
-			 * try_to_steal_freepages. This is OK as long as it does
-			 * not differ for MIGRATE_CMA type.
+			 * try_to_steal_freepages(). This is OK as long as it
+			 * does not differ for MIGRATE_CMA pageblocks. For CMA
+			 * we need to make sure unallocated pages flushed from
+			 * pcp lists are returned to the correct freelist.
 			 */
-			set_freepage_migratetype(page, new_type);
+			set_freepage_migratetype(page, buddy_type);
 
 			trace_mm_page_alloc_extfrag(page, order, current_order,
 				start_migratetype, migratetype);
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
