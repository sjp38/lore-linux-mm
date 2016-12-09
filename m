Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0E26B0253
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 04:38:17 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id s63so4606857wms.7
        for <linux-mm@kvack.org>; Fri, 09 Dec 2016 01:38:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f1si33185336wjl.229.2016.12.09.01.38.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Dec 2016 01:38:15 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/2] mm, page_alloc: don't convert pfn to idx when merging
Date: Fri,  9 Dec 2016 10:37:53 +0100
Message-Id: <20161209093754.3515-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

In __free_one_page() we do the buddy merging arithmetics on "page/buddy index",
which is just the lower MAX_ORDER bits of pfn. The operations we do that affect
the higher bits are bitwise AND and subtraction (in that order), where the
final result will be the same with the higher bits left unmasked, as long as
these bits are equal for both buddies - which must be true by the definition of
a buddy.

We can therefore use pfn's directly instead of "index" and skip the zeroing of
>MAX_ORDER bits. This can help a bit by itself, although compiler might be
smart enough already. It also helps the next patch to avoid page_to_pfn() for
memory hole checks.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/internal.h   |  4 ++--
 mm/page_alloc.c | 33 +++++++++++++++------------------
 2 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 537ac9951f5f..6d20f0e52b74 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -131,9 +131,9 @@ struct alloc_context {
  * Assumption: *_mem_map is contiguous at least up to MAX_ORDER
  */
 static inline unsigned long
-__find_buddy_index(unsigned long page_idx, unsigned int order)
+__find_buddy_pfn(unsigned long page_pfn, unsigned int order)
 {
-	return page_idx ^ (1 << order);
+	return page_pfn ^ (1 << order);
 }
 
 extern struct page *__pageblock_pfn_to_page(unsigned long start_pfn,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440e3ae2..812475bff8f3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -783,13 +783,12 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  */
 
 static inline void __free_one_page(struct page *page,
-		unsigned long pfn,
+		unsigned long page_pfn,
 		struct zone *zone, unsigned int order,
 		int migratetype)
 {
-	unsigned long page_idx;
-	unsigned long combined_idx;
-	unsigned long uninitialized_var(buddy_idx);
+	unsigned long combined_pfn;
+	unsigned long uninitialized_var(buddy_pfn);
 	struct page *buddy;
 	unsigned int max_order;
 
@@ -802,15 +801,13 @@ static inline void __free_one_page(struct page *page,
 	if (likely(!is_migrate_isolate(migratetype)))
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 
-	page_idx = pfn & ((1 << MAX_ORDER) - 1);
-
-	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
+	VM_BUG_ON_PAGE(page_pfn & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 
 continue_merging:
 	while (order < max_order - 1) {
-		buddy_idx = __find_buddy_index(page_idx, order);
-		buddy = page + (buddy_idx - page_idx);
+		buddy_pfn = __find_buddy_pfn(page_pfn, order);
+		buddy = page + (buddy_pfn - page_pfn);
 		if (!page_is_buddy(page, buddy, order))
 			goto done_merging;
 		/*
@@ -824,9 +821,9 @@ static inline void __free_one_page(struct page *page,
 			zone->free_area[order].nr_free--;
 			rmv_page_order(buddy);
 		}
-		combined_idx = buddy_idx & page_idx;
-		page = page + (combined_idx - page_idx);
-		page_idx = combined_idx;
+		combined_pfn = buddy_pfn & page_pfn;
+		page = page + (combined_pfn - page_pfn);
+		page_pfn = combined_pfn;
 		order++;
 	}
 	if (max_order < MAX_ORDER) {
@@ -841,8 +838,8 @@ static inline void __free_one_page(struct page *page,
 		if (unlikely(has_isolate_pageblock(zone))) {
 			int buddy_mt;
 
-			buddy_idx = __find_buddy_index(page_idx, order);
-			buddy = page + (buddy_idx - page_idx);
+			buddy_pfn = __find_buddy_pfn(page_pfn, order);
+			buddy = page + (buddy_pfn - page_pfn);
 			buddy_mt = get_pageblock_migratetype(buddy);
 
 			if (migratetype != buddy_mt
@@ -867,10 +864,10 @@ static inline void __free_one_page(struct page *page,
 	 */
 	if ((order < MAX_ORDER-2) && pfn_valid_within(page_to_pfn(buddy))) {
 		struct page *higher_page, *higher_buddy;
-		combined_idx = buddy_idx & page_idx;
-		higher_page = page + (combined_idx - page_idx);
-		buddy_idx = __find_buddy_index(combined_idx, order + 1);
-		higher_buddy = higher_page + (buddy_idx - combined_idx);
+		combined_pfn = buddy_pfn & page_pfn;
+		higher_page = page + (combined_pfn - page_pfn);
+		buddy_pfn = __find_buddy_pfn(combined_pfn, order + 1);
+		higher_buddy = higher_page + (buddy_pfn - combined_pfn);
 		if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
 			list_add_tail(&page->lru,
 				&zone->free_area[order].free_list[migratetype]);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
