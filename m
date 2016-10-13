Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58AD76B025E
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 04:08:16 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id gg9so70236497pac.6
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:16 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id h64si1798135pfh.83.2016.10.13.01.08.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Oct 2016 01:08:15 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id os4so378273pac.3
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 01:08:15 -0700 (PDT)
From: js1304@gmail.com
Subject: [RFC PATCH 1/5] mm/page_alloc: always add freeing page at the tail of the buddy list
Date: Thu, 13 Oct 2016 17:08:18 +0900
Message-Id: <1476346102-26928-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, freeing page can stay longer in the buddy list if next higher
order page is in the buddy list in order to help coalescence. However,
it doesn't work for the simplest sequential free case. For example, think
about the situation that 8 consecutive pages are freed in sequential
order.

page 0: attached at the head of order 0 list
page 1: merged with page 0, attached at the head of order 1 list
page 2: attached at the tail of order 0 list
page 3: merged with page 2 and then merged with page 0, attached at
 the head of order 2 list
page 4: attached at the head of order 0 list
page 5: merged with page 4, attached at the tail of order 1 list
page 6: attached at the tail of order 0 list
page 7: merged with page 6 and then merged with page 4. Lastly, merged
 with page 0 and we get order 3 freepage.

With excluding page 0 case, there are three cases that freeing page is
attached at the head of buddy list in this example and if just one
corresponding ordered allocation request comes at that moment, this page
in being a high order page will be allocated and we would fail to make
order-3 freepage.

Allocation usually happens in sequential order and free also does. So, it
would be important to detect such a situation and to give some chance
to be coalesced.

I think that simple and effective heuristic about this case is just
attaching freeing page at the tail of the buddy list unconditionally.
If freeing isn't merged during one rotation, it would be actual
fragmentation and we don't need to care about it for coalescence.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/page_alloc.c | 25 ++-----------------------
 1 file changed, 2 insertions(+), 23 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1790391..c4f7d05 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -858,29 +858,8 @@ static inline void __free_one_page(struct page *page,
 done_merging:
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
-	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
-out:
+	list_add_tail(&page->lru,
+		&zone->free_area[order].free_list[migratetype]);
 	zone->free_area[order].nr_free++;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
