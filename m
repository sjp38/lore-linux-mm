Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 069526B005A
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 07:16:03 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/3] page-allocator: Move pcp static fields for high and batch off-pcp and onto the zone
Date: Tue, 18 Aug 2009 12:16:02 +0100
Message-Id: <1250594162-17322-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1250594162-17322-1-git-send-email-mel@csn.ul.ie>
References: <1250594162-17322-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Linux Memory Management List <linux-mm@kvack.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Having multiple lists per PCPU increased the size of the per-pcpu
structure. Two of the fields, high and batch, do not change within a
zone making that information redundant. This patch moves those fields
off the PCP and onto the zone to reduce the size of the PCPU.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/mmzone.h |    9 +++++----
 mm/page_alloc.c        |   47 +++++++++++++++++++++++++----------------------
 mm/vmstat.c            |    4 ++--
 3 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6e0b624..57a3ef0 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -167,12 +167,10 @@ enum zone_watermarks {
 #define high_wmark_pages(z) (z->watermark[WMARK_HIGH])
 
 struct per_cpu_pages {
-	int count;		/* number of pages in the list */
-	int high;		/* high watermark, emptying needed */
-	int batch;		/* chunk size for buddy add/remove */
-
 	/* Lists of pages, one per migrate type stored on the pcp-lists */
 	struct list_head lists[MIGRATE_PCPTYPES];
+
+	int count;		/* number of pages in the list */
 };
 
 struct per_cpu_pageset {
@@ -284,6 +282,9 @@ struct zone {
 	/* zone watermarks, access with *_wmark_pages(zone) macros */
 	unsigned long watermark[NR_WMARK];
 
+	int pcp_high;		/* high watermark, emptying needed */
+	int pcp_batch;		/* chunk size for buddy add/remove */
+
 	/*
 	 * We don't know if the memory that we're going to allocate will be freeable
 	 * or/and it will be released eventually, so to avoid totally wasting several
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd3f306..65cdfbf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -988,8 +988,8 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 	int to_drain;
 
 	local_irq_save(flags);
-	if (pcp->count >= pcp->batch)
-		to_drain = pcp->batch;
+	if (pcp->count >= zone->pcp_batch)
+		to_drain = zone->pcp_batch;
 	else
 		to_drain = pcp->count;
 	free_pcppages_bulk(zone, to_drain, pcp);
@@ -1129,9 +1129,9 @@ static void free_hot_cold_page(struct page *page, int cold)
 	else
 		list_add(&page->lru, &pcp->lists[migratetype]);
 	pcp->count++;
-	if (pcp->count >= pcp->high) {
-		free_pcppages_bulk(zone, pcp->batch, pcp);
-		pcp->count -= pcp->batch;
+	if (pcp->count >= zone->pcp_high) {
+		free_pcppages_bulk(zone, zone->pcp_batch, pcp);
+		pcp->count -= zone->pcp_batch;
 	}
 
 out:
@@ -1199,7 +1199,7 @@ again:
 		local_irq_save(flags);
 		if (list_empty(list)) {
 			pcp->count += rmqueue_bulk(zone, 0,
-					pcp->batch, list,
+					zone->pcp_batch, list,
 					migratetype, cold);
 			if (unlikely(list_empty(list)))
 				goto failed;
@@ -2178,8 +2178,8 @@ void show_free_areas(void)
 			pageset = zone_pcp(zone, cpu);
 
 			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
-			       cpu, pageset->pcp.high,
-			       pageset->pcp.batch, pageset->pcp.count);
+			       cpu, zone->pcp_high,
+			       zone->pcp_batch, pageset->pcp.count);
 		}
 	}
 
@@ -3045,7 +3045,9 @@ static int zone_batchsize(struct zone *zone)
 #endif
 }
 
-static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
+static void setup_pageset(struct zone *zone,
+				struct per_cpu_pageset *p,
+				unsigned long batch)
 {
 	struct per_cpu_pages *pcp;
 	int migratetype;
@@ -3054,8 +3056,8 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
 
 	pcp = &p->pcp;
 	pcp->count = 0;
-	pcp->high = 6 * batch;
-	pcp->batch = max(1UL, 1 * batch);
+	zone->pcp_high = 6 * batch;
+	zone->pcp_batch = max(1UL, 1 * batch);
 	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
 		INIT_LIST_HEAD(&pcp->lists[migratetype]);
 }
@@ -3065,16 +3067,17 @@ static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
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
 
 
@@ -3115,10 +3118,10 @@ static int __cpuinit process_zones(int cpu)
 		if (!zone_pcp(zone, cpu))
 			goto bad;
 
-		setup_pageset(zone_pcp(zone, cpu), zone_batchsize(zone));
+		setup_pageset(zone, zone_pcp(zone, cpu), zone_batchsize(zone));
 
 		if (percpu_pagelist_fraction)
-			setup_pagelist_highmark(zone_pcp(zone, cpu),
+			setup_pagelist_highmark(zone, zone_pcp(zone, cpu),
 			 	(zone->present_pages / percpu_pagelist_fraction));
 	}
 
@@ -3250,7 +3253,7 @@ static int __zone_pcp_update(void *data)
 
 		local_irq_save(flags);
 		free_pcppages_bulk(zone, pcp->count, pcp);
-		setup_pageset(pset, batch);
+		setup_pageset(zone, pset, batch);
 		local_irq_restore(flags);
 	}
 	return 0;
@@ -3270,9 +3273,9 @@ static __meminit void zone_pcp_init(struct zone *zone)
 #ifdef CONFIG_NUMA
 		/* Early boot. Slab allocator not functional yet */
 		zone_pcp(zone, cpu) = &boot_pageset[cpu];
-		setup_pageset(&boot_pageset[cpu],0);
+		setup_pageset(zone, &boot_pageset[cpu],0);
 #else
-		setup_pageset(zone_pcp(zone,cpu), batch);
+		setup_pageset(zone, zone_pcp(zone,cpu), batch);
 #endif
 	}
 	if (zone->present_pages)
@@ -4781,7 +4784,7 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
 }
 
 /*
- * percpu_pagelist_fraction - changes the pcp->high for each zone on each
+ * percpu_pagelist_fraction - changes the zone->pcp_high for each zone on each
  * cpu.  It is the fraction of total pages in each zone that a hot per cpu pagelist
  * can have before it gets flushed back to buddy allocator.
  */
@@ -4800,7 +4803,7 @@ int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
 		for_each_online_cpu(cpu) {
 			unsigned long  high;
 			high = zone->present_pages / percpu_pagelist_fraction;
-			setup_pagelist_highmark(zone_pcp(zone, cpu), high);
+			setup_pagelist_highmark(zone, zone_pcp(zone, cpu), high);
 		}
 	}
 	return 0;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index c81321f..a9d23c3 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -746,8 +746,8 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
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
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
