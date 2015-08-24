Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id DDAE382F5F
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 08:29:37 -0400 (EDT)
Received: by wijp15 with SMTP id p15so76235534wij.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:29:37 -0700 (PDT)
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id t1si31762685wjx.99.2015.08.24.05.29.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 05:29:36 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 29FDE990E3
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 12:29:35 +0000 (UTC)
Date: Mon, 24 Aug 2015 13:29:32 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 10/12] mm, page_alloc: Remove MIGRATE_RESERVE
Message-ID: <20150824122932.GH12432@techsingularity.net>
References: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1440418191-10894-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

MIGRATE_RESERVE preserves an old property of the buddy allocator that existed
prior to fragmentation avoidance -- min_free_kbytes worth of pages tended to
remain contiguous until the only alternative was to fail the allocation. At the
time it was discovered that high-order atomic allocations relied on this
property so MIGRATE_RESERVE was introduced. A later patch will introduce
an alternative MIGRATE_HIGHATOMIC so this patch deletes MIGRATE_RESERVE
and supporting code so it'll be easier to review. Note that this patch
in isolation may look like a false regression if someone was bisecting
high-order atomic allocation failures.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mmzone.h |  10 +---
 mm/huge_memory.c       |   2 +-
 mm/page_alloc.c        | 148 +++----------------------------------------------
 mm/vmstat.c            |   1 -
 4 files changed, 11 insertions(+), 150 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index aef62cc11c80..cf643539d640 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -39,8 +39,6 @@ enum {
 	MIGRATE_UNMOVABLE,
 	MIGRATE_MOVABLE,
 	MIGRATE_RECLAIMABLE,
-	MIGRATE_PCPTYPES,	/* the number of types on the pcp lists */
-	MIGRATE_RESERVE = MIGRATE_PCPTYPES,
 #ifdef CONFIG_CMA
 	/*
 	 * MIGRATE_CMA migration type is designed to mimic the way
@@ -63,6 +61,8 @@ enum {
 	MIGRATE_TYPES
 };
 
+#define MIGRATE_PCPTYPES (MIGRATE_RECLAIMABLE+1)
+
 #ifdef CONFIG_CMA
 #  define is_migrate_cma(migratetype) unlikely((migratetype) == MIGRATE_CMA)
 #else
@@ -425,12 +425,6 @@ struct zone {
 
 	const char		*name;
 
-	/*
-	 * Number of MIGRATE_RESERVE page block. To maintain for just
-	 * optimization. Protected by zone->lock.
-	 */
-	int			nr_migrate_reserve_block;
-
 #ifdef CONFIG_MEMORY_ISOLATION
 	/*
 	 * Number of isolated pageblock. It is used to solve incorrect
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 36efda9ff8f1..56cfb17169d2 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -113,7 +113,7 @@ static int set_recommended_min_free_kbytes(void)
 	for_each_populated_zone(zone)
 		nr_zones++;
 
-	/* Make sure at least 2 hugepages are free for MIGRATE_RESERVE */
+	/* Ensure 2 pageblocks are free to assist fragmentation avoidance */
 	recommended_min = pageblock_nr_pages * nr_zones * 2;
 
 	/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index aa52a91a7d44..d5ce050ebe4f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -792,7 +792,6 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			if (unlikely(has_isolate_pageblock(zone)))
 				mt = get_pageblock_migratetype(page);
 
-			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
 			__free_one_page(page, page_to_pfn(page), zone, 0, mt);
 			trace_mm_page_pcpu_drain(page, 0, mt);
 		} while (--to_free && --batch_free && !list_empty(list));
@@ -1390,15 +1389,14 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
  * the free lists for the desirable migrate type are depleted
  */
 static int fallbacks[MIGRATE_TYPES][4] = {
-	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,     MIGRATE_RESERVE },
-	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,     MIGRATE_RESERVE },
-	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE,   MIGRATE_RESERVE },
+	[MIGRATE_UNMOVABLE]   = { MIGRATE_RECLAIMABLE, MIGRATE_MOVABLE,   MIGRATE_TYPES },
+	[MIGRATE_RECLAIMABLE] = { MIGRATE_UNMOVABLE,   MIGRATE_MOVABLE,   MIGRATE_TYPES },
+	[MIGRATE_MOVABLE]     = { MIGRATE_RECLAIMABLE, MIGRATE_UNMOVABLE, MIGRATE_TYPES },
 #ifdef CONFIG_CMA
-	[MIGRATE_CMA]         = { MIGRATE_RESERVE }, /* Never used */
+	[MIGRATE_CMA]         = { MIGRATE_TYPES }, /* Never used */
 #endif
-	[MIGRATE_RESERVE]     = { MIGRATE_RESERVE }, /* Never used */
 #ifdef CONFIG_MEMORY_ISOLATION
-	[MIGRATE_ISOLATE]     = { MIGRATE_RESERVE }, /* Never used */
+	[MIGRATE_ISOLATE]     = { MIGRATE_TYPES }, /* Never used */
 #endif
 };
 
@@ -1572,7 +1570,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 	*can_steal = false;
 	for (i = 0;; i++) {
 		fallback_mt = fallbacks[migratetype][i];
-		if (fallback_mt == MIGRATE_RESERVE)
+		if (fallback_mt == MIGRATE_TYPES)
 			break;
 
 		if (list_empty(&area->free_list[fallback_mt]))
@@ -1651,25 +1649,13 @@ static struct page *__rmqueue(struct zone *zone, unsigned int order,
 {
 	struct page *page;
 
-retry_reserve:
 	page = __rmqueue_smallest(zone, order, migratetype);
-
-	if (unlikely(!page) && migratetype != MIGRATE_RESERVE) {
+	if (unlikely(!page)) {
 		if (migratetype == MIGRATE_MOVABLE)
 			page = __rmqueue_cma_fallback(zone, order);
 
 		if (!page)
 			page = __rmqueue_fallback(zone, order, migratetype);
-
-		/*
-		 * Use MIGRATE_RESERVE rather than fail an allocation. goto
-		 * is used because __rmqueue_smallest is an inline function
-		 * and we want just one call site
-		 */
-		if (!page) {
-			migratetype = MIGRATE_RESERVE;
-			goto retry_reserve;
-		}
 	}
 
 	trace_mm_page_alloc_zone_locked(page, order, migratetype);
@@ -3462,7 +3448,6 @@ static void show_migration_types(unsigned char type)
 		[MIGRATE_UNMOVABLE]	= 'U',
 		[MIGRATE_RECLAIMABLE]	= 'E',
 		[MIGRATE_MOVABLE]	= 'M',
-		[MIGRATE_RESERVE]	= 'R',
 #ifdef CONFIG_CMA
 		[MIGRATE_CMA]		= 'C',
 #endif
@@ -4273,120 +4258,6 @@ static inline unsigned long wait_table_bits(unsigned long size)
 }
 
 /*
- * Check if a pageblock contains reserved pages
- */
-static int pageblock_is_reserved(unsigned long start_pfn, unsigned long end_pfn)
-{
-	unsigned long pfn;
-
-	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
-		if (!pfn_valid_within(pfn) || PageReserved(pfn_to_page(pfn)))
-			return 1;
-	}
-	return 0;
-}
-
-/*
- * Mark a number of pageblocks as MIGRATE_RESERVE. The number
- * of blocks reserved is based on min_wmark_pages(zone). The memory within
- * the reserve will tend to store contiguous free pages. Setting min_free_kbytes
- * higher will lead to a bigger reserve which will get freed as contiguous
- * blocks as reclaim kicks in
- */
-static void setup_zone_migrate_reserve(struct zone *zone)
-{
-	unsigned long start_pfn, pfn, end_pfn, block_end_pfn;
-	struct page *page;
-	unsigned long block_migratetype;
-	int reserve;
-	int old_reserve;
-
-	/*
-	 * Get the start pfn, end pfn and the number of blocks to reserve
-	 * We have to be careful to be aligned to pageblock_nr_pages to
-	 * make sure that we always check pfn_valid for the first page in
-	 * the block.
-	 */
-	start_pfn = zone->zone_start_pfn;
-	end_pfn = zone_end_pfn(zone);
-	start_pfn = roundup(start_pfn, pageblock_nr_pages);
-	reserve = roundup(min_wmark_pages(zone), pageblock_nr_pages) >>
-							pageblock_order;
-
-	/*
-	 * Reserve blocks are generally in place to help high-order atomic
-	 * allocations that are short-lived. A min_free_kbytes value that
-	 * would result in more than 2 reserve blocks for atomic allocations
-	 * is assumed to be in place to help anti-fragmentation for the
-	 * future allocation of hugepages at runtime.
-	 */
-	reserve = min(2, reserve);
-	old_reserve = zone->nr_migrate_reserve_block;
-
-	/* When memory hot-add, we almost always need to do nothing */
-	if (reserve == old_reserve)
-		return;
-	zone->nr_migrate_reserve_block = reserve;
-
-	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
-		if (!early_page_nid_uninitialised(pfn, zone_to_nid(zone)))
-			return;
-
-		if (!pfn_valid(pfn))
-			continue;
-		page = pfn_to_page(pfn);
-
-		/* Watch out for overlapping nodes */
-		if (page_to_nid(page) != zone_to_nid(zone))
-			continue;
-
-		block_migratetype = get_pageblock_migratetype(page);
-
-		/* Only test what is necessary when the reserves are not met */
-		if (reserve > 0) {
-			/*
-			 * Blocks with reserved pages will never free, skip
-			 * them.
-			 */
-			block_end_pfn = min(pfn + pageblock_nr_pages, end_pfn);
-			if (pageblock_is_reserved(pfn, block_end_pfn))
-				continue;
-
-			/* If this block is reserved, account for it */
-			if (block_migratetype == MIGRATE_RESERVE) {
-				reserve--;
-				continue;
-			}
-
-			/* Suitable for reserving if this block is movable */
-			if (block_migratetype == MIGRATE_MOVABLE) {
-				set_pageblock_migratetype(page,
-							MIGRATE_RESERVE);
-				move_freepages_block(zone, page,
-							MIGRATE_RESERVE);
-				reserve--;
-				continue;
-			}
-		} else if (!old_reserve) {
-			/*
-			 * At boot time we don't need to scan the whole zone
-			 * for turning off MIGRATE_RESERVE.
-			 */
-			break;
-		}
-
-		/*
-		 * If the reserve is met and this is a previous reserved block,
-		 * take it back
-		 */
-		if (block_migratetype == MIGRATE_RESERVE) {
-			set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-			move_freepages_block(zone, page, MIGRATE_MOVABLE);
-		}
-	}
-}
-
-/*
  * Initially all pages are reserved - free ones are freed
  * up by free_all_bootmem() once the early boot process is
  * done. Non-atomic initialization, single-pass.
@@ -4425,9 +4296,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		 * movable at startup. This will force kernel allocations
 		 * to reserve their blocks rather than leaking throughout
 		 * the address space during boot when many long-lived
-		 * kernel allocations are made. Later some blocks near
-		 * the start are marked MIGRATE_RESERVE by
-		 * setup_zone_migrate_reserve()
+		 * kernel allocations are made.
 		 *
 		 * bitmap is created for zone's valid pfn range. but memmap
 		 * can be created for invalid pages (for alignment)
@@ -5985,7 +5854,6 @@ static void __setup_per_zone_wmarks(void)
 			high_wmark_pages(zone) - low_wmark_pages(zone) -
 			atomic_long_read(&zone->vm_stat[NR_ALLOC_BATCH]));
 
-		setup_zone_migrate_reserve(zone);
 		spin_unlock_irqrestore(&zone->lock, flags);
 	}
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 4f5cd974e11a..49963aa2dff3 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -901,7 +901,6 @@ static char * const migratetype_names[MIGRATE_TYPES] = {
 	"Unmovable",
 	"Reclaimable",
 	"Movable",
-	"Reserve",
 #ifdef CONFIG_CMA
 	"CMA",
 #endif
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
