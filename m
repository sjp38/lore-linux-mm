Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 314EB6B0038
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 10:12:08 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d186so49991488lfg.7
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 07:12:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sl19si17891488wjb.283.2016.10.13.07.12.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 07:12:04 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC 7/4] mm, page_alloc: count movable pages when stealing
Date: Thu, 13 Oct 2016 16:11:55 +0200
Message-Id: <20161013141155.29034-1-vbabka@suse.cz>
In-Reply-To: <20160929210548.26196-1-vbabka@suse.cz>
References: <20160929210548.26196-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Vlastimil Babka <vbabka@suse.cz>

When stealing pages from pageblock of a different migratetype, we count how
many free pages were stolen, and change the pageblock's migratetype if more
than half of the pageblock was free. This might be too conservative, as there
might be other pages that are not free, but were allocated with the same
migratetype as our allocation requested.

While we cannot determine the migratetype of allocated pages precisely (at
least without the page_owner functionality enabled), we can count pages that
compaction would try to isolate for migration - those are either on LRU or
__PageMovable(). The rest can be assumed to be MIGRATE_RECLAIMABLE or
MIGRATE_UNMOVABLE, which we cannot easily distinguish. This counting can be
done as part of free page stealing with little additional overhead.

The page stealing code is changed so that it considers free pages plus pages
of the "good" migratetype for the decision whether to change pageblock's
migratetype. For changing pageblock to MIGRATE_MOVABLE, we require that all
pages are either free or appear to be movable, otherwise we use MIGRATE_MIXED.

The result should be more accurate migratetype of pageblocks wrt the actual
pages in the pageblocks, when stealing from semi-occupied pageblocks. This
should help with page grouping by mobility.

Not-yet-signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/page-isolation.h |  5 +--
 mm/page_alloc.c                | 73 +++++++++++++++++++++++++++++-------------
 mm/page_isolation.c            |  5 +--
 3 files changed, 54 insertions(+), 29 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 047d64706f2a..d4cd2014fa6f 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -33,10 +33,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 			 bool skip_hwpoisoned_pages);
 void set_pageblock_migratetype(struct page *page, int migratetype);
 int move_freepages_block(struct zone *zone, struct page *page,
-				int migratetype);
-int move_freepages(struct zone *zone,
-			  struct page *start_page, struct page *end_page,
-			  int migratetype);
+				int migratetype, int *num_movable);
 
 /*
  * Changes migrate type in [start_pfn, end_pfn) to be MIGRATE_ISOLATE.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6c5bc6a7858c..29e44364a02d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1842,9 +1842,9 @@ static inline struct page *__rmqueue_cma_fallback(struct zone *zone,
  * Note that start_page and end_pages are not aligned on a pageblock
  * boundary. If alignment is required, use move_freepages_block()
  */
-int move_freepages(struct zone *zone,
+static int move_freepages(struct zone *zone,
 			  struct page *start_page, struct page *end_page,
-			  int migratetype)
+			  int migratetype, int *num_movable)
 {
 	struct page *page;
 	unsigned int order;
@@ -1861,6 +1861,9 @@ int move_freepages(struct zone *zone,
 	VM_BUG_ON(page_zone(start_page) != page_zone(end_page));
 #endif
 
+	if (num_movable)
+		*num_movable = 0;
+
 	for (page = start_page; page <= end_page;) {
 		/* Make sure we are not inadvertently changing nodes */
 		VM_BUG_ON_PAGE(page_to_nid(page) != zone_to_nid(zone), page);
@@ -1870,23 +1873,33 @@ int move_freepages(struct zone *zone,
 			continue;
 		}
 
-		if (!PageBuddy(page)) {
-			page++;
+		if (PageBuddy(page)) {
+			order = page_order(page);
+			list_move(&page->lru,
+				  &zone->free_area[order].free_list[migratetype]);
+			page += 1 << order;
+			pages_moved += 1 << order;
 			continue;
 		}
 
-		order = page_order(page);
-		list_move(&page->lru,
-			  &zone->free_area[order].free_list[migratetype]);
-		page += 1 << order;
-		pages_moved += 1 << order;
+		page++;
+		if (!num_movable)
+			continue;
+
+		/*
+		 * We assume that pages that could be isolated for migration are
+		 * movable. But we don't actually try isolating, as that would be
+		 * expensive.
+		 */
+		if (PageLRU(page) || __PageMovable(page))
+			(*num_movable)++;
 	}
 
 	return pages_moved;
 }
 
 int move_freepages_block(struct zone *zone, struct page *page,
-				int migratetype)
+				int migratetype, int *num_movable)
 {
 	unsigned long start_pfn, end_pfn;
 	struct page *start_page, *end_page;
@@ -1903,7 +1916,8 @@ int move_freepages_block(struct zone *zone, struct page *page,
 	if (!zone_spans_pfn(zone, end_pfn))
 		return 0;
 
-	return move_freepages(zone, start_page, end_page, migratetype);
+	return move_freepages(zone, start_page, end_page, migratetype,
+								num_movable);
 }
 
 static void change_pageblock_range(struct page *pageblock_page,
@@ -1961,7 +1975,7 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 {
 	unsigned int current_order = page_order(page);
 	struct free_area *area;
-	int pages;
+	int free_pages, good_pages;
 	int old_block_type, new_block_type;
 
 	/* Take ownership for orders >= pageblock_order */
@@ -1976,24 +1990,37 @@ static void steal_suitable_fallback(struct zone *zone, struct page *page,
 	if (!whole_block) {
 		area = &zone->free_area[current_order];
 		list_move(&page->lru, &area->free_list[start_type]);
-		pages = 1 << current_order;
+		free_pages = 1 << current_order;
+		/* We didn't scan the block, so be pessimistic */
+		good_pages = 0;
 	} else {
-		pages = move_freepages_block(zone, page, start_type);
+		free_pages = move_freepages_block(zone, page, start_type,
+							&good_pages);
+		/*
+		 * good_pages is now the number of movable pages, but if we
+		 * want MOVABLE or RECLAIMABLE, we consider all non-movable as
+		 * good (but we can't fully distinguish them)
+		 */
+		if (start_type != MIGRATE_MOVABLE)
+			good_pages = pageblock_nr_pages - free_pages -
+								good_pages;
 	}
 
 	new_block_type = old_block_type = get_pageblock_migratetype(page);
 	if (page_group_by_mobility_disabled)
 		new_block_type = start_type;
 
-	if (pages >= (1 << (pageblock_order-1))) {
+	if (free_pages + good_pages >= (1 << (pageblock_order-1))) {
 		/*
-		 * Claim the whole block if over half of it is free. The
-		 * exception is the transition to MIGRATE_MOVABLE where we
-		 * require it to be fully free so that MIGRATE_MOVABLE
-		 * pageblocks consist of purely movable pages. So if we steal
-		 * less than whole pageblock, mark it as MIGRATE_MIXED.
+		 * Claim the whole block if over half of it is free or of a good
+		 * type. The exception is the transition to MIGRATE_MOVABLE
+		 * where we require it to be fully free/good so that
+		 * MIGRATE_MOVABLE pageblocks consist of purely movable pages.
+		 * So if we steal less than whole pageblock, mark it as
+		 * MIGRATE_MIXED.
 		 */
-		if (start_type == MIGRATE_MOVABLE)
+		if ((start_type == MIGRATE_MOVABLE) &&
+				free_pages + good_pages < pageblock_nr_pages)
 			new_block_type = MIGRATE_MIXED;
 		else
 			new_block_type = start_type;
@@ -2079,7 +2106,7 @@ static void reserve_highatomic_pageblock(struct page *page, struct zone *zone,
 			!is_migrate_isolate(mt) && !is_migrate_cma(mt)) {
 		zone->nr_reserved_highatomic += pageblock_nr_pages;
 		set_pageblock_migratetype(page, MIGRATE_HIGHATOMIC);
-		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC);
+		move_freepages_block(zone, page, MIGRATE_HIGHATOMIC, NULL);
 	}
 
 out_unlock:
@@ -2136,7 +2163,7 @@ static void unreserve_highatomic_pageblock(const struct alloc_context *ac)
 			 * may increase.
 			 */
 			set_pageblock_migratetype(page, ac->migratetype);
-			move_freepages_block(zone, page, ac->migratetype);
+			move_freepages_block(zone, page, ac->migratetype, NULL);
 			spin_unlock_irqrestore(&zone->lock, flags);
 			return;
 		}
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index a5594bfcc5ed..29c2f9b9aba7 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -66,7 +66,8 @@ static int set_migratetype_isolate(struct page *page,
 
 		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
 		zone->nr_isolate_pageblock++;
-		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE);
+		nr_pages = move_freepages_block(zone, page, MIGRATE_ISOLATE,
+									NULL);
 
 		__mod_zone_freepage_state(zone, -nr_pages, migratetype);
 	}
@@ -120,7 +121,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 	 * pageblock scanning for freepage moving.
 	 */
 	if (!isolated_page) {
-		nr_pages = move_freepages_block(zone, page, migratetype);
+		nr_pages = move_freepages_block(zone, page, migratetype, NULL);
 		__mod_zone_freepage_state(zone, nr_pages, migratetype);
 	}
 	set_pageblock_migratetype(page, migratetype);
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
