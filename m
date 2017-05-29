Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 756786B0292
	for <linux-mm@kvack.org>; Mon, 29 May 2017 05:40:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r203so12408710wmb.2
        for <linux-mm@kvack.org>; Mon, 29 May 2017 02:40:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y30si10330973edy.113.2017.05.29.02.40.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 May 2017 02:40:15 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH] mm, page_alloc: fallback to smallest page when not stealing whole pageblock
Date: Mon, 29 May 2017 11:39:47 +0200
Message-Id: <20170529093947.22618-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>

Since commit 3bc48f96cf11 ("mm, page_alloc: split smallest stolen page in
fallback") we pick the smallest (but sufficient) page of all that have been
stolen from a pageblock of different migratetype. However, there are cases when
we decide not to steal the whole pageblock. Practically in the current
implementation it means that we are trying to fallback for a MIGRATE_MOVABLE
allocation of order X, go through the freelists from MAX_ORDER-1 down to X, and
find free page of order Y. If Y is less than pageblock_order / 2, we decide not
to steal all pages from the pageblock. When Y > X, it means we are potentially
splitting a larger page than we need, as there might be other pages of order Z,
where X <= Z < Y. Since Y is already too small to steal whole pageblock,
picking smallest available Z will result in the same decision and we avoid
splitting a higher-order page in a MIGRATE_UNMOVABLE or MIGRATE_RECLAIMABLE
pageblock.

This patch therefore changes the fallback algorithm so that in the situation
described above, we switch the fallback search strategy to go from order X
upwards to find the smallest suitable fallback. In theory there shouldn't be
a downside of this change wrt fragmentation.

This has been tested with mmtests' stress-highalloc performing GFP_KERNEL
order-4 allocations, here is the relevant extfrag tracepoint statistics:

                                                      4.12.0-rc2      4.12.0-rc2
                                                       1-kernel4       2-kernel4
Page alloc extfrag event                                  25640976    69680977
Extfrag fragmenting                                       25621086    69661364
Extfrag fragmenting for unmovable                            74409       73204
Extfrag fragmenting unmovable placed with movable            69003       67684
Extfrag fragmenting unmovable placed with reclaim.            5406        5520
Extfrag fragmenting for reclaimable                           6398        8467
Extfrag fragmenting reclaimable placed with movable            869         884
Extfrag fragmenting reclaimable placed with unmov.            5529        7583
Extfrag fragmenting for movable                           25540279    69579693

Since we force movable allocations to steal the smallest available page (which
we then practially always split), we steal less per fallback, so the number of
fallbacks increases and steals potentially happen from different pageblocks.
This is however not an issue for movable pages that can be compacted.

Importantly, the "unmovable placed with movable" statistics is lower, which is
the result of less fragmentation in the unmovable pageblocks. The effect on
reclaimable allocation is a bit unclear.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/page_alloc.c | 53 ++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 44 insertions(+), 9 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f9e450c6b6e4..f1bb43cf2f4e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2203,7 +2203,11 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 	int fallback_mt;
 	bool can_steal;
 
-	/* Find the largest possible block of pages in the other list */
+	/*
+	 * Find the largest available free page in the other list. This roughly
+	 * approximates finding the pageblock with the most free pages, which
+	 * would be too costly to do exactly.
+	 */
 	for (current_order = MAX_ORDER-1;
 				current_order >= order && current_order <= MAX_ORDER-1;
 				--current_order) {
@@ -2213,19 +2217,50 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 		if (fallback_mt == -1)
 			continue;
 
-		page = list_first_entry(&area->free_list[fallback_mt],
-						struct page, lru);
+		/*
+		 * We cannot steal all free pages from the pageblock and the
+		 * requested migratetype is movable. In that case it's better to
+		 * steal and split the smallest available page instead of the
+		 * largest available page, because even if the next movable
+		 * allocation falls back into a different pageblock than this
+		 * one, it won't cause permanent fragmentation.
+		 */
+		if (!can_steal && start_migratetype == MIGRATE_MOVABLE
+					&& current_order > order)
+			goto find_smallest;
 
-		steal_suitable_fallback(zone, page, start_migratetype,
-								can_steal);
+		goto do_steal;
+	}
 
-		trace_mm_page_alloc_extfrag(page, order, current_order,
-			start_migratetype, fallback_mt);
+	return false;
 
-		return true;
+find_smallest:
+	for (current_order = order; current_order < MAX_ORDER;
+							current_order++) {
+		area = &(zone->free_area[current_order]);
+		fallback_mt = find_suitable_fallback(area, current_order,
+				start_migratetype, false, &can_steal);
+		if (fallback_mt != -1)
+			break;
 	}
 
-	return false;
+	/*
+	 * This should not happen - we already found a suitable fallback
+	 * when looking for the largest page.
+	 */
+	VM_BUG_ON(current_order == MAX_ORDER);
+
+do_steal:
+	page = list_first_entry(&area->free_list[fallback_mt],
+							struct page, lru);
+
+	steal_suitable_fallback(zone, page, start_migratetype, can_steal);
+
+	trace_mm_page_alloc_extfrag(page, order, current_order,
+		start_migratetype, fallback_mt);
+
+	return true;
+
 }
 
 /*
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
