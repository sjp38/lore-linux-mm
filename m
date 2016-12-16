Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F9E26B0069
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:00:28 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id hb5so34411945wjc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 04:00:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x127si3005687wmg.118.2016.12.16.04.00.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 16 Dec 2016 04:00:26 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 1/2] mm, page_alloc: don't convert pfn to idx when merging
Date: Fri, 16 Dec 2016 13:00:08 +0100
Message-Id: <20161216120009.20064-1-vbabka@suse.cz>
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
Acked-by: Mel Gorman <mgorman@techsingularity.net>
---
Changes since v1:
o rebase to mmotm-2016-12-14-16-01
o fix mm/page_isolation.c
o don't rename 'pfn' to 'page_pfn'

 mm/internal.h       |  4 ++--
 mm/page_alloc.c     | 31 ++++++++++++++-----------------
 mm/page_isolation.c |  8 ++++----
 3 files changed, 20 insertions(+), 23 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 44d68895a9b9..ebb3cbd21937 100644
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
index f6d5b73e1d7c..771fc8e18736 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -787,9 +787,8 @@ static inline void __free_one_page(struct page *page,
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
+	VM_BUG_ON_PAGE(pfn & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
 
 continue_merging:
 	while (order < max_order - 1) {
-		buddy_idx = __find_buddy_index(page_idx, order);
-		buddy = page + (buddy_idx - page_idx);
+		buddy_pfn = __find_buddy_pfn(pfn, order);
+		buddy = page + (buddy_pfn - pfn);
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
+		combined_pfn = buddy_pfn & pfn;
+		page = page + (combined_pfn - pfn);
+		pfn = combined_pfn;
 		order++;
 	}
 	if (max_order < MAX_ORDER) {
@@ -841,8 +838,8 @@ static inline void __free_one_page(struct page *page,
 		if (unlikely(has_isolate_pageblock(zone))) {
 			int buddy_mt;
 
-			buddy_idx = __find_buddy_index(page_idx, order);
-			buddy = page + (buddy_idx - page_idx);
+			buddy_pfn = __find_buddy_pfn(pfn, order);
+			buddy = page + (buddy_pfn - pfn);
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
+		combined_pfn = buddy_pfn & pfn;
+		higher_page = page + (combined_pfn - pfn);
+		buddy_pfn = __find_buddy_pfn(combined_pfn, order + 1);
+		higher_buddy = higher_page + (buddy_pfn - combined_pfn);
 		if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
 			list_add_tail(&page->lru,
 				&zone->free_area[order].free_list[migratetype]);
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index a5594bfcc5ed..dadb7e74d7d6 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -83,7 +83,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	unsigned long flags, nr_pages;
 	bool isolated_page = false;
 	unsigned int order;
-	unsigned long page_idx, buddy_idx;
+	unsigned long pfn, buddy_pfn;
 	struct page *buddy;
 
 	zone = page_zone(page);
@@ -102,9 +102,9 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	if (PageBuddy(page)) {
 		order = page_order(page);
 		if (order >= pageblock_order) {
-			page_idx = page_to_pfn(page) & ((1 << MAX_ORDER) - 1);
-			buddy_idx = __find_buddy_index(page_idx, order);
-			buddy = page + (buddy_idx - page_idx);
+			pfn = page_to_pfn(page);
+			buddy_pfn = __find_buddy_pfn(pfn, order);
+			buddy = page + (buddy_pfn - pfn);
 
 			if (pfn_valid_within(page_to_pfn(buddy)) &&
 			    !is_migrate_isolate_page(buddy)) {
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
