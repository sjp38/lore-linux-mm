Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C75886B0008
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 04:53:49 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p9so598992pfk.5
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 01:53:49 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l185si925211pgd.108.2018.03.20.01.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 01:53:48 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH v2 1/4] mm/page_alloc: use helper functions to add/remove a page to/from buddy
Date: Tue, 20 Mar 2018 16:54:49 +0800
Message-Id: <20180320085452.24641-2-aaron.lu@intel.com>
In-Reply-To: <20180320085452.24641-1-aaron.lu@intel.com>
References: <20180320085452.24641-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>

There are multiple places that add/remove a page into/from buddy,
introduce helper functions for them.

This also makes it easier to add code when a page is added/removed
to/from buddy.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 mm/page_alloc.c | 65 ++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 39 insertions(+), 26 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3db9cfb2265b..3cdf1e10d412 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -736,12 +736,41 @@ static inline void set_page_order(struct page *page, unsigned int order)
 	__SetPageBuddy(page);
 }
 
+static inline void add_to_buddy_common(struct page *page, struct zone *zone,
+					unsigned int order, int mt)
+{
+	set_page_order(page, order);
+	zone->free_area[order].nr_free++;
+}
+
+static inline void add_to_buddy_head(struct page *page, struct zone *zone,
+					unsigned int order, int mt)
+{
+	add_to_buddy_common(page, zone, order, mt);
+	list_add(&page->lru, &zone->free_area[order].free_list[mt]);
+}
+
+static inline void add_to_buddy_tail(struct page *page, struct zone *zone,
+					unsigned int order, int mt)
+{
+	add_to_buddy_common(page, zone, order, mt);
+	list_add_tail(&page->lru, &zone->free_area[order].free_list[mt]);
+}
+
 static inline void rmv_page_order(struct page *page)
 {
 	__ClearPageBuddy(page);
 	set_page_private(page, 0);
 }
 
+static inline void remove_from_buddy(struct page *page, struct zone *zone,
+					unsigned int order)
+{
+	list_del(&page->lru);
+	zone->free_area[order].nr_free--;
+	rmv_page_order(page);
+}
+
 /*
  * This function checks whether a page is free && is the buddy
  * we can do coalesce a page and its buddy if
@@ -845,13 +874,10 @@ static inline void __free_one_page(struct page *page,
 		 * Our buddy is free or it is CONFIG_DEBUG_PAGEALLOC guard page,
 		 * merge with it and move up one order.
 		 */
-		if (page_is_guard(buddy)) {
+		if (page_is_guard(buddy))
 			clear_page_guard(zone, buddy, order, migratetype);
-		} else {
-			list_del(&buddy->lru);
-			zone->free_area[order].nr_free--;
-			rmv_page_order(buddy);
-		}
+		else
+			remove_from_buddy(buddy, zone, order);
 		combined_pfn = buddy_pfn & pfn;
 		page = page + (combined_pfn - pfn);
 		pfn = combined_pfn;
@@ -883,8 +909,6 @@ static inline void __free_one_page(struct page *page,
 	}
 
 done_merging:
-	set_page_order(page, order);
-
 	/*
 	 * If this is not the largest possible page, check if the buddy
 	 * of the next-highest order is free. If it is, it's possible
@@ -901,15 +925,12 @@ static inline void __free_one_page(struct page *page,
 		higher_buddy = higher_page + (buddy_pfn - combined_pfn);
 		if (pfn_valid_within(buddy_pfn) &&
 		    page_is_buddy(higher_page, higher_buddy, order + 1)) {
-			list_add_tail(&page->lru,
-				&zone->free_area[order].free_list[migratetype]);
-			goto out;
+			add_to_buddy_tail(page, zone, order, migratetype);
+			return;
 		}
 	}
 
-	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
-out:
-	zone->free_area[order].nr_free++;
+	add_to_buddy_head(page, zone, order, migratetype);
 }
 
 /*
@@ -1731,9 +1752,7 @@ static inline void expand(struct zone *zone, struct page *page,
 		if (set_page_guard(zone, &page[size], high, migratetype))
 			continue;
 
-		list_add(&page[size].lru, &area->free_list[migratetype]);
-		area->nr_free++;
-		set_page_order(&page[size], high);
+		add_to_buddy_head(&page[size], zone, high, migratetype);
 	}
 }
 
@@ -1877,9 +1896,7 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 							struct page, lru);
 		if (!page)
 			continue;
-		list_del(&page->lru);
-		rmv_page_order(page);
-		area->nr_free--;
+		remove_from_buddy(page, zone, current_order);
 		expand(zone, page, order, current_order, area, migratetype);
 		set_pcppage_migratetype(page, migratetype);
 		return page;
@@ -2795,9 +2812,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 	}
 
 	/* Remove page from free list */
-	list_del(&page->lru);
-	zone->free_area[order].nr_free--;
-	rmv_page_order(page);
+	remove_from_buddy(page, zone, order);
 
 	/*
 	 * Set the pageblock if the isolated page is at least half of a
@@ -7886,9 +7901,7 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
 #endif
-		list_del(&page->lru);
-		rmv_page_order(page);
-		zone->free_area[order].nr_free--;
+		remove_from_buddy(page, zone, order);
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
-- 
2.14.3
