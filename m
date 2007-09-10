From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070910112332.3097.65532.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 10/13] Bias the location of pages freed for min_free_kbytes in the same pageblock_nr_pages areas
Date: Mon, 10 Sep 2007 12:23:32 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Subject: Bias the location of pages freed for min_free_kbytes in the same pageblock_nr_pages areas
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The standard buddy allocator always favours splitting the smallest block of
pages. The effect of this is that the pages free to satisfy min_free_kbytes
tends to be preserved since boot time at the same location of memory for a
very long time, remaining contiguous.  When an administrator sets the
reserve at 16384 at boot time, it tends to be the same MAX_ORDER blocks
that remain free.  This allows the occasional high atomic allocation
to succeed up until the point the blocks are split.  In practice, it is
difficult to split these blocks but when they do split, the benefit of
having min_free_kbytes for contiguous blocks disappears.  Additionally,
increasing min_free_kbytes once the system has been running for some time
has no guarantee of creating contiguous blocks.

On the other hand, grouping pages by mobility favours the splitting of large
blocks when there are no free pages of the appropriate type available.  A
side-effect of this is that all blocks in memory tends to be used up and
the contiguous free blocks from boot time are not preserved like in the
vanilla allocator.  This can cause a problem if a new caller is unwilling
to reclaim or does not reclaim for long enough.

A failure scenario was found for a wireless network device allocating
order-1 atomic allocations but the allocations were not intense or frequent
enough for a whole block of pages to be preserved for MIGRATE_HIGHALLOC.
This was reproduced on a desktop by booting with mem=256mb, forcing the
driver to allocate at order-1, running a bittorrent client (downloading a
debian ISO) and building a kernel with -j2.

This patch addresses the problem on the desktop machine booted with mem=256mb.
It works by setting aside a reserve of pageblock_nr_pages blocks, the
number of which depends on the value of min_free_kbytes.  These blocks are
only fallen back to when there is no other free pages.  Then the smallest
possible page is used just like the normal buddy allocator instead of the
largest possible page to preserve contiguous pages. The pages in free lists
in the reserve blocks are never taken for another migrate type.  The results
is that even if min_free_kbytes is set to a low value, contiguous blocks
will be preserved in the MIGRATE_RESERVE blocks as the pages will become
contiguous again on free.

This works better than the vanilla allocator because if min_free_kbytes is
increased, a new reserve block will be chosen based on the location of
reclaimable pages and the block will free up as contiguous pages.  In the
vanilla allocator, no effort is made to target a block of pages to free as
contiguous pages and min_free_kbytes pages are scattered randomly.

This effect has been observed on the test machine.  min_free_kbytes was
set initially low but it was kept as a contiguous free block within
MIGRATE_RESERVE.  min_free_kbytes was then set to a higher value and
over a period of time, the free contiguous memory was found within the
reserve blocks.  How long it takes to free up depends on how quickly the
LRU is rotating.  Amusingly, this means that more activity will free the
blocks faster.

Credit to Mariusz Kozlowski for discovering the problem, describing the
failure scenario and testing patches and scenarios.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
[akpm@linux-foundation.org: cleanups]
Acked-by: Andy Whitcroft <apw@shadowen.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/mmzone.h |    3 -
 mm/page_alloc.c        |  129 +++++++++++++++++++++++++++++++++++---------
 2 files changed, 105 insertions(+), 27 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-009-do-not-group-pages-by-mobility-type-on-low-memory-systems/include/linux/mmzone.h linux-2.6.23-rc5-010-bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks/include/linux/mmzone.h
--- linux-2.6.23-rc5-009-do-not-group-pages-by-mobility-type-on-low-memory-systems/include/linux/mmzone.h	2007-09-02 16:21:10.000000000 +0100
+++ linux-2.6.23-rc5-010-bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks/include/linux/mmzone.h	2007-09-02 16:22:04.000000000 +0100
@@ -36,7 +36,8 @@
 #define MIGRATE_UNMOVABLE     0
 #define MIGRATE_RECLAIMABLE   1
 #define MIGRATE_MOVABLE       2
-#define MIGRATE_TYPES         3
+#define MIGRATE_RESERVE       3
+#define MIGRATE_TYPES         4
 
 #define for_each_migratetype_order(order, type) \
 	for (order = 0; order < MAX_ORDER; order++) \
diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.23-rc5-009-do-not-group-pages-by-mobility-type-on-low-memory-systems/mm/page_alloc.c linux-2.6.23-rc5-010-bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks/mm/page_alloc.c
--- linux-2.6.23-rc5-009-do-not-group-pages-by-mobility-type-on-low-memory-systems/mm/page_alloc.c	2007-09-02 16:21:30.000000000 +0100
+++ linux-2.6.23-rc5-010-bias-the-location-of-pages-freed-for-min_free_kbytes-in-the-same-max_order_nr_pages-blocks/mm/page_alloc.c	2007-09-02 16:22:04.000000000 +0100
@@ -662,13 +662,44 @@ static int prep_new_page(struct page *pa
 }
 
 /*
+ * Go through the free lists for the given migratetype and remove
+ * the smallest available page from the freelists
+ */
+static struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
+						int migratetype)
+{
+	unsigned int current_order;
+	struct free_area *area;
+	struct page *page;
+
+	/* Find a page of the appropriate size in the preferred list */
+	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
+		area = &(zone->free_area[current_order]);
+		if (list_empty(&area->free_list[migratetype]))
+			continue;
+
+		page = list_entry(area->free_list[migratetype].next,
+							struct page, lru);
+		list_del(&page->lru);
+		rmv_page_order(page);
+		area->nr_free--;
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+		expand(zone, page, order, current_order, area, migratetype);
+		return page;
+	}
+
+	return NULL;
+}
+
+/*
  * This array describes the order lists are fallen back to when
  * the free lists for the desirable migrate type are depleted
  */
 static int fallbacks[MIGRATE_TYPES][MIGRATE_TYPES-1] = {
-	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE   },
-	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE   },
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE },
+	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_RESERVE },
+	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_RESERVE },
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_RESERVE },
+	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE,     MIGRATE_RESERVE,   MIGRATE_RESERVE }, /* Never used */
 };
 
 /*
@@ -752,6 +783,10 @@ static struct page *__rmqueue_fallback(s
 		for (i = 0; i < MIGRATE_TYPES - 1; i++) {
 			migratetype = fallbacks[start_migratetype][i];
 
+			/* MIGRATE_RESERVE handled later if necessary */
+			if (migratetype == MIGRATE_RESERVE)
+				continue;
+
 			area = &(zone->free_area[current_order]);
 			if (list_empty(&area->free_list[migratetype]))
 				continue;
@@ -785,39 +820,23 @@ static struct page *__rmqueue_fallback(s
 		}
 	}
 
-	return NULL;
+	/* Use MIGRATE_RESERVE rather than fail an allocation */
+	return __rmqueue_smallest(zone, order, MIGRATE_RESERVE);
 }
 
-/* 
+/*
  * Do the hard work of removing an element from the buddy allocator.
  * Call me with the zone->lock already held.
  */
 static struct page *__rmqueue(struct zone *zone, unsigned int order,
 						int migratetype)
 {
-	struct free_area * area;
-	unsigned int current_order;
 	struct page *page;
 
-	/* Find a page of the appropriate size in the preferred list */
-	for (current_order = order; current_order < MAX_ORDER; ++current_order) {
-		area = &(zone->free_area[current_order]);
-		if (list_empty(&area->free_list[migratetype]))
-			continue;
-
-		page = list_entry(area->free_list[migratetype].next,
-							struct page, lru);
-		list_del(&page->lru);
-		rmv_page_order(page);
-		area->nr_free--;
-		__mod_zone_page_state(zone, NR_FREE_PAGES, - (1UL << order));
-		expand(zone, page, order, current_order, area, migratetype);
-		goto got_page;
-	}
-
-	page = __rmqueue_fallback(zone, order, migratetype);
+	page = __rmqueue_smallest(zone, order, migratetype);
 
-got_page:
+	if (unlikely(!page))
+		page = __rmqueue_fallback(zone, order, migratetype);
 
 	return page;
 }
@@ -2395,6 +2414,61 @@ static inline unsigned long wait_table_b
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))
 
 /*
+ * Mark a number of pageblocks as MIGRATE_RESERVE. The number
+ * of blocks reserved is based on zone->pages_min. The memory within the
+ * reserve will tend to store contiguous free pages. Setting min_free_kbytes
+ * higher will lead to a bigger reserve which will get freed as contiguous
+ * blocks as reclaim kicks in
+ */
+static void setup_zone_migrate_reserve(struct zone *zone)
+{
+	unsigned long start_pfn, pfn, end_pfn;
+	struct page *page;
+	unsigned long reserve, block_migratetype;
+
+	/* Get the start pfn, end pfn and the number of blocks to reserve */
+	start_pfn = zone->zone_start_pfn;
+	end_pfn = start_pfn + zone->spanned_pages;
+	reserve = roundup(zone->pages_min, pageblock_nr_pages) >>
+							pageblock_order;
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+
+		/* Blocks with reserved pages will never free, skip them. */
+		if (PageReserved(page))
+			continue;
+
+		block_migratetype = get_pageblock_migratetype(page);
+
+		/* If this block is reserved, account for it */
+		if (reserve > 0 && block_migratetype == MIGRATE_RESERVE) {
+			reserve--;
+			continue;
+		}
+
+		/* Suitable for reserving if this block is movable */
+		if (reserve > 0 && block_migratetype == MIGRATE_MOVABLE) {
+			set_pageblock_migratetype(page, MIGRATE_RESERVE);
+			move_freepages_block(zone, page, MIGRATE_RESERVE);
+			reserve--;
+			continue;
+		}
+
+		/*
+		 * If the reserve is met and this is a previous reserved block,
+		 * take it back
+		 */
+		if (block_migratetype == MIGRATE_RESERVE) {
+			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+			move_freepages_block(zone, page, MIGRATE_MOVABLE);
+		}
+	}
+}
+
+/*
  * Initially all pages are reserved - free ones are freed
  * up by free_all_bootmem() once the early boot process is
  * done. Non-atomic initialization, single-pass.
@@ -2429,7 +2503,9 @@ void __meminit memmap_init_zone(unsigned
 		 * movable at startup. This will force kernel allocations
 		 * to reserve their blocks rather than leaking throughout
 		 * the address space during boot when many long-lived
-		 * kernel allocations are made
+		 * kernel allocations are made. Later some blocks near
+		 * the start are marked MIGRATE_RESERVE by
+		 * setup_zone_migrate_reserve()
 		 */
 		if ((pfn & (pageblock_nr_pages-1)))
 			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
@@ -3961,6 +4037,7 @@ void setup_per_zone_pages_min(void)
 
 		zone->pages_low   = zone->pages_min + (tmp >> 2);
 		zone->pages_high  = zone->pages_min + (tmp >> 1);
+		setup_zone_migrate_reserve(zone);
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
