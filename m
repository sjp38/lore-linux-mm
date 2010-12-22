Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7695B6B0087
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 09:07:41 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [PATCH] mm: simple approach to calculate combined index of adjacent buddy lists
Date: Wed, 22 Dec 2010 22:46:34 +0900
Message-Id: <1293025594-15802-1-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: KyongHo Cho <pullip.cho@samsung.com>
List-ID: <linux-mm.kvack.org>

The previous approach of calucation of combined index was

page_idx & ~(1 << order))

but we have same result with

page_idx & buddy_idx.

I think this reduces instructions slightly as well as enhances readability.

(Sorry for duplicate patch in linux-mm.  failed to send this patch a bit ago.)

Signed-off-by: KyongHo Cho <pullip.cho@samsung.com>
---
 mm/page_alloc.c |   25 ++++++++++---------------
 1 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f12ad18..6033053 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -420,18 +420,10 @@ static inline void rmv_page_order(struct page *page)
  *
  * Assumption: *_mem_map is contiguous at least up to MAX_ORDER
  */
-static inline struct page *
-__page_find_buddy(struct page *page, unsigned long page_idx, unsigned int order)
-{
-	unsigned long buddy_idx = page_idx ^ (1 << order);
-
-	return page + (buddy_idx - page_idx);
-}
-
 static inline unsigned long
-__find_combined_index(unsigned long page_idx, unsigned int order)
+__find_buddy_index(unsigned long page_idx, unsigned int order)
 {
-	return (page_idx & ~(1 << order));
+	return page_idx ^ (1 << order);
 }
 
 /*
@@ -493,6 +485,7 @@ static inline void __free_one_page(struct page *page,
 {
 	unsigned long page_idx;
 	unsigned long combined_idx;
+	unsigned long buddy_idx;
 	struct page *buddy;
 
 	if (unlikely(PageCompound(page)))
@@ -507,7 +500,8 @@ static inline void __free_one_page(struct page *page,
 	VM_BUG_ON(bad_range(zone, page));
 
 	while (order < MAX_ORDER-1) {
-		buddy = __page_find_buddy(page, page_idx, order);
+		buddy_idx = __find_buddy_index(page_idx, order);
+		buddy = page + (buddy_idx - page_idx);
 		if (!page_is_buddy(page, buddy, order))
 			break;
 
@@ -515,7 +509,7 @@ static inline void __free_one_page(struct page *page,
 		list_del(&buddy->lru);
 		zone->free_area[order].nr_free--;
 		rmv_page_order(buddy);
-		combined_idx = __find_combined_index(page_idx, order);
+		combined_idx = buddy_idx & page_idx;
 		page = page + (combined_idx - page_idx);
 		page_idx = combined_idx;
 		order++;
@@ -532,9 +526,10 @@ static inline void __free_one_page(struct page *page,
 	 */
 	if ((order < MAX_ORDER-1) && pfn_valid_within(page_to_pfn(buddy))) {
 		struct page *higher_page, *higher_buddy;
-		combined_idx = __find_combined_index(page_idx, order);
-		higher_page = page + combined_idx - page_idx;
-		higher_buddy = __page_find_buddy(higher_page, combined_idx, order + 1);
+		combined_idx = buddy_idx & page_idx;
+		higher_page = page + (combined_idx - page_idx);
+		buddy_idx = __find_buddy_index(combined_idx, order + 1);
+		higher_buddy = page + (buddy_idx - combined_idx);
 		if (page_is_buddy(higher_page, higher_buddy, order + 1)) {
 			list_add_tail(&page->lru,
 				&zone->free_area[order].free_list[migratetype]);
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
