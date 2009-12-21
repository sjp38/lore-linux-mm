Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 39F5D6B0044
	for <linux-mm@kvack.org>; Sun, 20 Dec 2009 22:32:36 -0500 (EST)
Received: by pzk27 with SMTP id 27so973741pzk.12
        for <linux-mm@kvack.org>; Sun, 20 Dec 2009 19:32:33 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] mm : kill combined_idx
Date: Mon, 21 Dec 2009 11:32:27 +0800
Message-Id: <1261366347-19232-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mel@csn.ul.ie, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

In more then half of all the cases, `page' is head of the buddy pair
{page, buddy} in __free_one_page. That is because the allocation logic
always picks the head of a chunk, and puts the rest back to the buddy system.

So calculating the combined page is not needed but waste some cycles in
more then half of all the cases.Just do the calculation when `page' is
bigger then the `buddy'.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/page_alloc.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4e86965..42351bf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -464,7 +464,6 @@ static inline void __free_one_page(struct page *page,
 	VM_BUG_ON(bad_range(zone, page));
 
 	while (order < MAX_ORDER-1) {
-		unsigned long combined_idx;
 		struct page *buddy;
 
 		buddy = __page_find_buddy(page, page_idx, order);
@@ -475,9 +474,10 @@ static inline void __free_one_page(struct page *page,
 		list_del(&buddy->lru);
 		zone->free_area[order].nr_free--;
 		rmv_page_order(buddy);
-		combined_idx = __find_combined_index(page_idx, order);
-		page = page + (combined_idx - page_idx);
-		page_idx = combined_idx;
+		if (page > buddy) { /* keep `page' the head of the buddy pair */
+			page = buddy;
+			page_idx = __find_combined_index(page_idx, order);
+		}
 		order++;
 	}
 	set_page_order(page, order);
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
