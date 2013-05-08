Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 26C326B014A
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:22 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 16/22] mm: page allocator: Remove coalescing improvement heuristic during page free
Date: Wed,  8 May 2013 17:03:01 +0100
Message-Id: <1368028987-8369-17-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Commit 6dda9d55 ( page allocator: reduce fragmentation in buddy
allocator by adding buddies that are merging to the tail of the free
lists) classified pages according to their probability of being part of
a high order merge. This made sense when the number of pages being freed
was relatively small as part of a per-cpu list drain.

However, with the introduction of magazines, a drain of the magazines
frees larger number of pages in batch and the heuristic is less likely
to benefit but adds a lot of weight to the free path in the normal case.
The free path can be very hot for workloads with short-lived processes,
are fault intensive or work with many in-kernel short-lived buffers. As
THP is the main benefit of such a heuristic, it's too marginal a gain to
impact the free path so heavily, remove it.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 22 ----------------------
 1 file changed, 22 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b30abe8..6760e00 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -577,29 +577,7 @@ static inline void __free_one_page(struct page *page,
 	}
 	set_page_order(page, order);
 
-	/*
-	 * If this is not the largest possible page, check if the buddy
-	 * of the next-highest order is free. If it is, it's possible
-	 * that pages are being freed that will coalesce soon. In case,
-	 * that is happening, add the free page to the tail of the list
-	 * so it's less likely to be used soon and more likely to be merged
-	 * as a higher order page
-	 */
-	if ((order < MAX_ORDER-2) && pfn_valid_within(page_to_pfn(buddy))) {
-		struct page *higher_page, *higher_buddy;
-		combined_idx = buddy_idx & page_idx;
-		higher_page = page + (combined_idx - page_idx);
-		buddy_idx = __find_buddy_index(combined_idx, order + 1);
-		higher_buddy = higher_page + (buddy_idx - combined_idx);
-		if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
-			list_add_tail(&page->lru,
-				&zone->free_area[order].free_list[migratetype]);
-			goto out;
-		}
-	}
-
 	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
-out:
 	zone->free_area[order].nr_free++;
 }
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
