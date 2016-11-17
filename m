Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9A6D6B0315
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 20:32:36 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so176138221pgc.2
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:32:36 -0800 (PST)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id 126si585094pgb.180.2016.11.16.17.32.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 17:32:35 -0800 (PST)
Received: by mail-pg0-x236.google.com with SMTP id x23so82511437pgx.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:32:35 -0800 (PST)
Date: Wed, 16 Nov 2016 17:32:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] mm, zone: track number of pages in free area by
 migratetype
Message-ID: <alpine.DEB.2.10.1611161731350.17379@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Each zone's free_area tracks the number of free pages for all free lists.
This does not allow the number of free pages for a specific migratetype
to be determined without iterating its free list.

An upcoming change will use this information to preclude doing async
memory compaction when the number of MIGRATE_UNMOVABLE pageblocks is
below a certain threshold.

The total number of free pages is still tracked, however, to not make
zone_watermark_ok() more expensive.  Reading /proc/pagetypeinfo, however,
is faster.

This patch introduces no functional change and increases the amount of
per-zone metadata at worst by 48 bytes per memory zone (when CONFIG_CMA
and CONFIG_MEMORY_ISOLATION are enabled).

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mmzone.h |  3 ++-
 mm/compaction.c        |  4 ++--
 mm/page_alloc.c        | 47 ++++++++++++++++++++++++++++-------------------
 mm/vmstat.c            | 18 +++++-------------
 4 files changed, 37 insertions(+), 35 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -89,7 +89,8 @@ extern int page_group_by_mobility_disabled;
 
 struct free_area {
 	struct list_head	free_list[MIGRATE_TYPES];
-	unsigned long		nr_free;
+	unsigned long		nr_free[MIGRATE_TYPES];
+	unsigned long		total_free;
 };
 
 struct pglist_data;
diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1320,13 +1320,13 @@ static enum compact_result __compact_finished(struct zone *zone, struct compact_
 		bool can_steal;
 
 		/* Job done if page is free of the right migratetype */
-		if (!list_empty(&area->free_list[migratetype]))
+		if (area->nr_free[migratetype])
 			return COMPACT_SUCCESS;
 
 #ifdef CONFIG_CMA
 		/* MIGRATE_MOVABLE can fallback on MIGRATE_CMA */
 		if (migratetype == MIGRATE_MOVABLE &&
-			!list_empty(&area->free_list[MIGRATE_CMA]))
+						area->nr_free[MIGRATE_CMA])
 			return COMPACT_SUCCESS;
 #endif
 		/*
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -821,7 +821,8 @@ static inline void __free_one_page(struct page *page,
 			clear_page_guard(zone, buddy, order, migratetype);
 		} else {
 			list_del(&buddy->lru);
-			zone->free_area[order].nr_free--;
+			zone->free_area[order].nr_free[migratetype]--;
+			zone->free_area[order].total_free--;
 			rmv_page_order(buddy);
 		}
 		combined_idx = buddy_idx & page_idx;
@@ -880,7 +881,8 @@ static inline void __free_one_page(struct page *page,
 
 	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
 out:
-	zone->free_area[order].nr_free++;
+	zone->free_area[order].nr_free[migratetype]++;
+	zone->free_area[order].total_free++;
 }
 
 /*
@@ -1648,7 +1650,8 @@ static inline void expand(struct zone *zone, struct page *page,
 			continue;
 
 		list_add(&page[size].lru, &area->free_list[migratetype]);
-		area->nr_free++;
+		area->nr_free[migratetype]++;
+		area->total_free++;
 		set_page_order(&page[size], high);
 	}
 }
@@ -1802,7 +1805,8 @@ struct page *__rmqueue_smallest(struct zone *zone, unsigned int order,
 			continue;
 		list_del(&page->lru);
 		rmv_page_order(page);
-		area->nr_free--;
+		area->nr_free[migratetype]--;
+		area->total_free--;
 		expand(zone, page, order, current_order, area, migratetype);
 		set_pcppage_migratetype(page, migratetype);
 		return page;
@@ -1991,7 +1995,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 	int i;
 	int fallback_mt;
 
-	if (area->nr_free == 0)
+	if (!area->total_free)
 		return -1;
 
 	*can_steal = false;
@@ -2000,7 +2004,7 @@ int find_suitable_fallback(struct free_area *area, unsigned int order,
 		if (fallback_mt == MIGRATE_TYPES)
 			break;
 
-		if (list_empty(&area->free_list[fallback_mt]))
+		if (!area->nr_free[fallback_mt])
 			continue;
 
 		if (can_steal_fallback(order, migratetype))
@@ -2163,7 +2167,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 			steal_suitable_fallback(zone, page, start_migratetype);
 
 		/* Remove the page from the freelists */
-		area->nr_free--;
+		area->nr_free[fallback_mt]--;
+		area->total_free--;
 		list_del(&page->lru);
 		rmv_page_order(page);
 
@@ -2549,7 +2554,8 @@ int __isolate_free_page(struct page *page, unsigned int order)
 
 	/* Remove page from free list */
 	list_del(&page->lru);
-	zone->free_area[order].nr_free--;
+	zone->free_area[order].nr_free[mt]--;
+	zone->free_area[order].total_free--;
 	rmv_page_order(page);
 
 	/*
@@ -2808,22 +2814,19 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 		struct free_area *area = &z->free_area[o];
 		int mt;
 
-		if (!area->nr_free)
+		if (!area->total_free)
 			continue;
 
 		if (alloc_harder)
 			return true;
 
-		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++) {
-			if (!list_empty(&area->free_list[mt]))
+		for (mt = 0; mt < MIGRATE_PCPTYPES; mt++)
+			if (area->nr_free[mt])
 				return true;
-		}
 
 #ifdef CONFIG_CMA
-		if ((alloc_flags & ALLOC_CMA) &&
-		    !list_empty(&area->free_list[MIGRATE_CMA])) {
+		if ((alloc_flags & ALLOC_CMA) && area->nr_free[MIGRATE_CMA])
 			return true;
-		}
 #endif
 	}
 	return false;
@@ -4431,12 +4434,12 @@ void show_free_areas(unsigned int filter)
 			struct free_area *area = &zone->free_area[order];
 			int type;
 
-			nr[order] = area->nr_free;
+			nr[order] = area->total_free;
 			total += nr[order] << order;
 
 			types[order] = 0;
 			for (type = 0; type < MIGRATE_TYPES; type++) {
-				if (!list_empty(&area->free_list[type]))
+				if (area->nr_free[type])
 					types[order] |= 1 << type;
 			}
 		}
@@ -5100,8 +5103,10 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	unsigned int order, t;
 	for_each_migratetype_order(order, t) {
 		INIT_LIST_HEAD(&zone->free_area[order].free_list[t]);
-		zone->free_area[order].nr_free = 0;
+		zone->free_area[order].nr_free[t] = 0;
 	}
+	for (order = 0; order < MAX_ORDER; order++)
+		zone->free_area[order].total_free = 0;
 }
 
 #ifndef __HAVE_ARCH_MEMMAP_INIT
@@ -7416,6 +7421,8 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 	spin_lock_irqsave(&zone->lock, flags);
 	pfn = start_pfn;
 	while (pfn < end_pfn) {
+		int migratetype;
+
 		if (!pfn_valid(pfn)) {
 			pfn++;
 			continue;
@@ -7438,9 +7445,11 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 		pr_info("remove from free list %lx %d %lx\n",
 			pfn, 1 << order, end_pfn);
 #endif
+		migratetype = get_pageblock_migratetype(page);
 		list_del(&page->lru);
 		rmv_page_order(page);
-		zone->free_area[order].nr_free--;
+		zone->free_area[order].nr_free[migratetype]--;
+		zone->free_area[order].total_free--;
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);
diff --git a/mm/vmstat.c b/mm/vmstat.c
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -846,7 +846,7 @@ static void fill_contig_page_info(struct zone *zone,
 		unsigned long blocks;
 
 		/* Count number of free blocks */
-		blocks = zone->free_area[order].nr_free;
+		blocks = zone->free_area[order].total_free;
 		info->free_blocks_total += blocks;
 
 		/* Count free base pages */
@@ -1146,7 +1146,7 @@ static void frag_show_print(struct seq_file *m, pg_data_t *pgdat,
 
 	seq_printf(m, "Node %d, zone %8s ", pgdat->node_id, zone->name);
 	for (order = 0; order < MAX_ORDER; ++order)
-		seq_printf(m, "%6lu ", zone->free_area[order].nr_free);
+		seq_printf(m, "%6lu ", zone->free_area[order].total_free);
 	seq_putc(m, '\n');
 }
 
@@ -1170,17 +1170,9 @@ static void pagetypeinfo_showfree_print(struct seq_file *m,
 					pgdat->node_id,
 					zone->name,
 					migratetype_names[mtype]);
-		for (order = 0; order < MAX_ORDER; ++order) {
-			unsigned long freecount = 0;
-			struct free_area *area;
-			struct list_head *curr;
-
-			area = &(zone->free_area[order]);
-
-			list_for_each(curr, &area->free_list[mtype])
-				freecount++;
-			seq_printf(m, "%6lu ", freecount);
-		}
+		for (order = 0; order < MAX_ORDER; ++order)
+			seq_printf(m, "%6lu ",
+				   zone->free_area[order].nr_free[mtype]);
 		seq_putc(m, '\n');
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
