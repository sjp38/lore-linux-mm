Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7772C6B009D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 05:44:39 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 29/35] Do not store the PCP high and batch watermarks in the per-cpu structure
Date: Mon, 16 Mar 2009 09:46:24 +0000
Message-Id: <1237196790-7268-30-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
References: <1237196790-7268-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

Currently, there are high and batch counters in the per-cpu structure.
This might have made sense when there was hot and cold per-cpu
structures but that is no longer the case. In practice, all the per-cpu
structures for a zone contain the same values and they are read-mostly.
This patch stores them in the zone with the watermarks which are also
read-mostly.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    8 ++++++--
 mm/page_alloc.c        |   43 +++++++++++++++++++++++--------------------
 mm/vmstat.c            |    4 ++--
 3 files changed, 31 insertions(+), 24 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index eed6867..b4fba09 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -166,8 +166,6 @@ static inline int is_unevictable_lru(enum lru_list l)
 
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
-	int high;		/* high watermark, emptying needed */
-	int batch;		/* chunk size for buddy add/remove */
 
 	/* Lists of pages, one per migrate type stored on the pcp-lists */
 	struct list_head lists[MIGRATE_PCPTYPES];
@@ -285,6 +283,12 @@ struct zone {
 		unsigned long pages_mark[3];
 	};
 
+	/* high watermark for per-cpu lists, emptying needed */
+	u16 pcp_high;
+
+	/* chunk size for buddy add/remove to per-cpu lists*/
+	u16 pcp_batch;
+
 	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index edadab1..77e9970 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -975,8 +975,8 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	int to_drain;
 
 	local_irq_save(flags);
-	if (pcp->count >= pcp->batch)
-		to_drain = pcp->batch;
+	if (pcp->count >= zone->pcp_batch)
+		to_drain = zone->pcp_batch;
 	else
 		to_drain = pcp->count;
 	free_pcppages_bulk(zone, to_drain, pcp, 0);
@@ -1119,8 +1119,8 @@ static void free_hot_cold_page(struct page *page, int order, int cold)
 	set_page_private(page, migratetype);
 	page->index = order;
 	add_pcp_page(pcp, page, cold);
-	if (pcp->count >= pcp->high)
-		free_pcppages_bulk(zone, pcp->batch, pcp, migratetype);
+	if (pcp->count >= zone->pcp_high)
+		free_pcppages_bulk(zone, zone->pcp_batch, pcp, migratetype);
 
 out:
 	local_irq_restore(flags);
@@ -1184,7 +1184,7 @@ again:
 
 		pcp = &zone_pcp(zone, cpu)->pcp;
 		list = &pcp->lists[migratetype];
-		batch = max(1, pcp->batch >> order);
+		batch = max(1, zone->pcp_batch >> order);
 		local_irq_save(flags);
 		if (list_empty(list)) {
 			delta = rmqueue_bulk(zone, order, batch,
@@ -2144,8 +2144,8 @@ void show_free_areas(void)
 			pageset = zone_pcp(zone, cpu);
 
 			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
-			       cpu, pageset->pcp.high,
-			       pageset->pcp.batch, pageset->pcp.count);
+			       cpu, zone->pcp_high,
+			       zone->pcp_batch, pageset->pcp.count);
 		}
 	}
 
@@ -2975,7 +2975,8 @@ static int zone_batchsize(struct zone *zone)
 	return batch;
 }
 
-static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
+static void setup_pageset(struct zone *zone,
+			struct per_cpu_pageset *p, unsigned long batch)
 {
 	struct per_cpu_pages *pcp;
 	int migratetype;
@@ -2984,8 +2985,8 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 
 	pcp = &p->pcp;
 	pcp->count = 0;
-	pcp->high = 6 * batch;
-	pcp->batch = max(1UL, 1 * batch);
+	zone->pcp_high = 6 * batch;
+	zone->pcp_batch = max(1UL, 1 * batch);
 	for (migratetype = 0; migratetype < MIGRATE_TYPES; migratetype++)
 		INIT_LIST_HEAD(&pcp->lists[migratetype]);
 }
@@ -2995,16 +2996,17 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
  * to the value high for the pageset p.
  */
 
-static void setup_pagelist_highmark(struct per_cpu_pageset *p,
+static void setup_pagelist_highmark(struct zone *zone,
+				struct per_cpu_pageset *p,
 				unsigned long high)
 {
 	struct per_cpu_pages *pcp;
 
 	pcp = &p->pcp;
-	pcp->high = high;
-	pcp->batch = max(1UL, high/4);
+	zone->pcp_high = high;
+	zone->pcp_batch = max(1UL, high/4);
 	if ((high/4) > (PAGE_SHIFT * 8))
-		pcp->batch = PAGE_SHIFT * 8;
+		zone->pcp_batch = PAGE_SHIFT * 8;
 }
 
 
@@ -3049,10 +3051,10 @@ static int __cpuinit process_zones(int cpu)
 		if (!zone_pcp(zone, cpu))
 			goto bad;
 
-		setup_pageset(zone_pcp(zone, cpu), zone_batchsize(zone));
+		setup_pageset(zone, zone_pcp(zone, cpu), zone_batchsize(zone));
 
 		if (percpu_pagelist_fraction)
-			setup_pagelist_highmark(zone_pcp(zone, cpu),
+			setup_pagelist_highmark(zone, zone_pcp(zone, cpu),
 			 	(zone->present_pages / percpu_pagelist_fraction));
 	}
 
@@ -3178,9 +3180,9 @@ static __meminit void zone_pcp_init(struct zone *zone)
 #ifdef CONFIG_NUMA
 		/* Early boot. Slab allocator not functional yet */
 		zone_pcp(zone, cpu) = &boot_pageset[cpu];
-		setup_pageset(&boot_pageset[cpu],0);
+		setup_pageset(zone, &boot_pageset[cpu], 0);
 #else
-		setup_pageset(zone_pcp(zone,cpu), batch);
+		setup_pageset(zone, zone_pcp(zone, cpu), batch);
 #endif
 	}
 	if (zone->present_pages)
@@ -4771,7 +4773,7 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
 }
 
 /*
- * percpu_pagelist_fraction - changes the pcp->high for each zone on each
+ * percpu_pagelist_fraction - changes the zone->pcp_high for each zone on each
  * cpu.  It is the fraction of total pages in each zone that a hot per cpu pagelist
  * can have before it gets flushed back to buddy allocator.
  */
@@ -4790,7 +4792,8 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 		for_each_online_cpu(cpu) {
 			unsigned long  high;
 			high = zone->present_pages / percpu_pagelist_fraction;
-			setup_pagelist_highmark(zone_pcp(zone, cpu), high);
+			setup_pagelist_highmark(zone, zone_pcp(zone, cpu),
+									high);
 		}
 	}
 	return 0;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9114974..3be59b1 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -766,8 +766,8 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 			   "\n              batch: %i",
 			   i,
 			   pageset->pcp.count,
-			   pageset->pcp.high,
-			   pageset->pcp.batch);
+			   zone->pcp_high,
+			   zone->pcp_batch);
 #ifdef CONFIG_SMP
 		seq_printf(m, "\n  vm stats threshold: %d",
 				pageset->stat_threshold);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
