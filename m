Date: Mon, 21 Jun 2004 10:30:00 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: [PATCH] make __free_pages_bulk more comprehensible
Message-ID: <51370000.1087839000@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

I find __free_pages_bulk very hard to understand ... (I was trying to mod
it for the non MAX_ORDER aligned zones, and cleaned it up first). This 
should make it much more comprehensible to mortal man ... I benchmarked
the changes on the big 16x and it's no slower (actually it's about 0.5%
faster, but that's within experimental error).

I moved the creation of mask into __free_pages_bulk from the caller - it
seems to really belong inside there. Then instead of doing wierd limbo
dances with mask, I made it use order instead where it's more intuitive.
Personally I find this makes the whole thing a damned sight easier to
understand ... if you do too, please apply. Only thing that I think needs
to be double-checked is the while loop limit, but I'm pretty sure it's
correct?

M.

diff -purN -X /home/mbligh/.diff.exclude virgin/mm/page_alloc.c free_pages_bulk/mm/page_alloc.c
--- virgin/mm/page_alloc.c	Wed Jun 16 08:19:27 2004
+++ free_pages_bulk/mm/page_alloc.c	Fri Jun 18 14:20:37 2004
@@ -176,20 +176,20 @@ static void destroy_compound_page(struct
  */
 
 static inline void __free_pages_bulk (struct page *page, struct page *base,
-		struct zone *zone, struct free_area *area, unsigned long mask,
-		unsigned int order)
+		struct zone *zone, struct free_area *area, unsigned int order)
 {
-	unsigned long page_idx, index;
+	unsigned long page_idx, index, mask;
 
 	if (order)
 		destroy_compound_page(page, order);
+	mask = (~0UL) << order;
 	page_idx = page - base;
 	if (page_idx & ~mask)
 		BUG();
 	index = page_idx >> (1 + order);
 
-	zone->free_pages -= mask;
-	while (mask + (1 << (MAX_ORDER-1))) {
+	zone->free_pages += 1 << order;
+	while (order < MAX_ORDER-1) {
 		struct page *buddy1, *buddy2;
 
 		BUG_ON(area >= zone->free_area + MAX_ORDER);
@@ -198,17 +198,15 @@ static inline void __free_pages_bulk (st
 			 * the buddy page is still allocated.
 			 */
 			break;
-		/*
-		 * Move the buddy up one level.
-		 * This code is taking advantage of the identity:
-		 * 	-mask = 1+~mask
-		 */
-		buddy1 = base + (page_idx ^ -mask);
+
+		/* Move the buddy up one level. */
+		buddy1 = base + (page_idx ^ (1 << order));
 		buddy2 = base + page_idx;
 		BUG_ON(bad_range(zone, buddy1));
 		BUG_ON(bad_range(zone, buddy2));
 		list_del(&buddy1->lru);
 		mask <<= 1;
+		order++;
 		area++;
 		index >>= 1;
 		page_idx &= mask;
@@ -252,12 +250,11 @@ static int
 free_pages_bulk(struct zone *zone, int count,
 		struct list_head *list, unsigned int order)
 {
-	unsigned long mask, flags;
+	unsigned long flags;
 	struct free_area *area;
 	struct page *base, *page = NULL;
 	int ret = 0;
 
-	mask = (~0UL) << order;
 	base = zone->zone_mem_map;
 	area = zone->free_area + order;
 	spin_lock_irqsave(&zone->lock, flags);
@@ -267,7 +264,7 @@ free_pages_bulk(struct zone *zone, int c
 		page = list_entry(list->prev, struct page, lru);
 		/* have to delete it as __free_pages_bulk list manipulates */
 		list_del(&page->lru);
-		__free_pages_bulk(page, base, zone, area, mask, order);
+		__free_pages_bulk(page, base, zone, area, order);
 		ret++;
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
