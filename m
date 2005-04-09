Message-ID: <4257D74C.3010703@yahoo.com.au>
Date: Sat, 09 Apr 2005 23:23:24 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [patch 1/4] pcp: zonequeues
Content-Type: multipart/mixed;
 boundary="------------000604080806030103050904"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000604080806030103050904
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jack,
Was thinking about some problems in this area, and I hacked up
a possible implementation to improve things.

1/4 switches the per cpu pagesets in struct zone to a single list
of zone pagesets for each CPU.

2/4 changes the per cpu list of pagesets to a list of pointers to
pagesets, and allocates them dynamically.

3/4 changes the code to allow NULL pagesets. In that case, a single
per-zone pageset is used, which is protected by the zone's spinlock.

4/4 changes setup so non local zones don't have associated pagesets.

It still needs some work - in particular, many NUMA systems probably
don't want this. I guess benchmarks should be done, and maybe we
could look at disabling the overhead of 3/4 and functional change of
4/4 depending on a CONFIG_ option.

Also, you say you might want "close" remote nodes to have pagesets,
but 4/4 only does local nodes. I added a comment with patch 4/4
marked with XXX which should allow you to do this quite easily.

Not tested (only compiled) on a NUMA system, but the NULL pagesets
logic appears to work OK. Boots on a small UMA SMP system. So just
be careful with it.

Comments?

-- 
SUSE Labs, Novell Inc.

--------------000604080806030103050904
Content-Type: text/plain;
 name="pcp-zonequeues.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="pcp-zonequeues.patch"

Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2005-04-09 22:35:25.000000000 +1000
+++ linux-2.6/include/linux/mmzone.h	2005-04-09 22:44:48.000000000 +1000
@@ -53,14 +53,15 @@ struct per_cpu_pages {
 
 struct per_cpu_pageset {
 	struct per_cpu_pages pcp[2];	/* 0: hot.  1: cold */
-#ifdef CONFIG_NUMA
+};
+
+struct per_cpu_zone_stats {
 	unsigned long numa_hit;		/* allocated in intended node */
 	unsigned long numa_miss;	/* allocated in non intended node */
 	unsigned long numa_foreign;	/* was intended here, hit elsewhere */
 	unsigned long interleave_hit; 	/* interleaver prefered this zone */
 	unsigned long local_node;	/* allocation from local node */
 	unsigned long other_node;	/* allocation from other node */
-#endif
 } ____cacheline_aligned_in_smp;
 
 #define ZONE_DMA		0
@@ -113,16 +114,19 @@ struct zone {
 	unsigned long		free_pages;
 	unsigned long		pages_min, pages_low, pages_high;
 	/*
-	 * We don't know if the memory that we're going to allocate will be freeable
-	 * or/and it will be released eventually, so to avoid totally wasting several
-	 * GB of ram we must reserve some of the lower zone memory (otherwise we risk
-	 * to run OOM on the lower zones despite there's tons of freeable ram
-	 * on the higher zones). This array is recalculated at runtime if the
-	 * sysctl_lowmem_reserve_ratio sysctl changes.
+	 * We don't know if the memory that we're going to allocate will be
+	 * freeable or/and it will be released eventually, so to avoid totally
+	 * wasting several GB of ram we must reserve some of the lower zone
+	 * memory (otherwise we risk to run OOM on the lower zones despite
+	 * there's tons of freeable ram on the higher zones). This array is
+	 * recalculated at runtime if the sysctl_lowmem_reserve_ratio sysctl
+	 * changes.
 	 */
 	unsigned long		lowmem_reserve[MAX_NR_ZONES];
 
-	struct per_cpu_pageset	pageset[NR_CPUS];
+#ifdef CONFIG_NUMA
+	struct per_cpu_zone_stats stats[NR_CPUS];
+#endif
 
 	/*
 	 * free areas of different sizes
@@ -220,6 +224,8 @@ struct zone {
  */
 #define DEF_PRIORITY 12
 
+#define TOTAL_ZONES (MAX_NUMNODES * MAX_NR_ZONES)
+
 /*
  * One allocation request operates on a zonelist. A zonelist
  * is a list of zones, the first one is the 'goal' of the
@@ -232,10 +238,9 @@ struct zone {
  * footprint of this construct is very small.
  */
 struct zonelist {
-	struct zone *zones[MAX_NUMNODES * MAX_NR_ZONES + 1]; // NULL delimited
+	struct zone *zones[TOTAL_ZONES + 1]; // NULL delimited
 };
 
-
 /*
  * The pg_data_t structure is used in machines with CONFIG_DISCONTIGMEM
  * (mostly NUMA machines?) to denote a higher-level memory zone than the
@@ -275,6 +280,7 @@ void __get_zone_counts(unsigned long *ac
 void get_zone_counts(unsigned long *active, unsigned long *inactive,
 			unsigned long *free);
 void build_all_zonelists(void);
+void build_percpu_pagelists(void);
 void wakeup_kswapd(struct zone *zone, int order);
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		int alloc_type, int can_try_harder, int gfp_high);
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2005-04-09 22:35:25.000000000 +1000
+++ linux-2.6/mm/page_alloc.c	2005-04-09 22:44:55.000000000 +1000
@@ -69,6 +69,28 @@ EXPORT_SYMBOL(nr_swap_pages);
 struct zone *zone_table[1 << (ZONES_SHIFT + NODES_SHIFT)];
 EXPORT_SYMBOL(zone_table);
 
+struct zone_pagesets {
+	struct per_cpu_pageset p[TOTAL_ZONES];
+};
+
+#define this_zone_pagesets()	(&__get_cpu_var(zone_pagesets))
+#define cpu_zone_pagesets(cpu)	(&per_cpu(zone_pagesets, (cpu)))
+
+#define zone_pagesets_idx(zone)		\
+	(NODEZONE((zone)->zone_pgdat->node_id, zone_idx(zone)))
+
+#define zone_pageset(zp, zone)		\
+	(&zp->p[zone_pagesets_idx(zone)])
+
+/*
+ * List of pointers to per_cpu_pagesets for each zone.
+ * XXX: put this comment in a future patch that actually enables NULLs here
+ * It is used as a per-CPU set. A value of NULL in any pointer indicates
+ * this CPU doesn't have a pageset for this zone, and should use the public
+ * pageset.
+ */
+static DEFINE_PER_CPU(struct zone_pagesets, zone_pagesets);
+
 static char *zone_names[MAX_NR_ZONES] = { "DMA", "Normal", "HighMem" };
 int min_free_kbytes = 1024;
 
@@ -512,13 +534,14 @@ static int rmqueue_bulk(struct zone *zon
 #if defined(CONFIG_PM) || defined(CONFIG_HOTPLUG_CPU)
 static void __drain_pages(unsigned int cpu)
 {
+	struct zone_pagesets *zp = cpu_zone_pagesets(cpu);
 	struct zone *zone;
 	int i;
 
+	/* XXX: this can be a for i = 0 .. TOTAL_ZONES loop */
 	for_each_zone(zone) {
-		struct per_cpu_pageset *pset;
+		struct per_cpu_pageset *pset = zone_pageset(zp, zone);
 
-		pset = &zone->pageset[cpu];
 		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
 			struct per_cpu_pages *pcp;
 
@@ -577,21 +600,22 @@ static void zone_statistics(struct zonel
 	int cpu;
 	pg_data_t *pg = z->zone_pgdat;
 	pg_data_t *orig = zonelist->zones[0]->zone_pgdat;
-	struct per_cpu_pageset *p;
+	struct per_cpu_zone_stats *stats;
 
 	local_irq_save(flags);
 	cpu = smp_processor_id();
-	p = &z->pageset[cpu];
+	stats = &z->stats[cpu];
+
 	if (pg == orig) {
-		z->pageset[cpu].numa_hit++;
+		stats->numa_hit++;
 	} else {
-		p->numa_miss++;
-		zonelist->zones[0]->pageset[cpu].numa_foreign++;
+		stats->numa_miss++;
+		zonelist->zones[0]->stats[cpu].numa_foreign++;
 	}
 	if (pg == NODE_DATA(numa_node_id()))
-		p->local_node++;
+		stats->local_node++;
 	else
-		p->other_node++;
+		stats->other_node++;
 	local_irq_restore(flags);
 #endif
 }
@@ -602,6 +626,7 @@ static void zone_statistics(struct zonel
 static void FASTCALL(free_hot_cold_page(struct page *page, int cold));
 static void fastcall free_hot_cold_page(struct page *page, int cold)
 {
+	struct zone_pagesets *zp;
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
 	unsigned long flags;
@@ -613,14 +638,17 @@ static void fastcall free_hot_cold_page(
 	if (PageAnon(page))
 		page->mapping = NULL;
 	free_pages_check(__FUNCTION__, page);
-	pcp = &zone->pageset[get_cpu()].pcp[cold];
+
+	preempt_disable();
+	zp = this_zone_pagesets();
+	pcp = &zone_pageset(zp, zone)->pcp[cold];
 	local_irq_save(flags);
 	if (pcp->count >= pcp->high)
 		pcp->count -= free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
 	list_add(&page->lru, &pcp->list);
 	pcp->count++;
 	local_irq_restore(flags);
-	put_cpu();
+	preempt_enable();
 }
 
 void fastcall free_hot_page(struct page *page)
@@ -655,9 +683,13 @@ buffered_rmqueue(struct zone *zone, int 
 	int cold = !!(gfp_flags & __GFP_COLD);
 
 	if (order == 0) {
+		struct zone_pagesets *zp;
 		struct per_cpu_pages *pcp;
 
-		pcp = &zone->pageset[get_cpu()].pcp[cold];
+		preempt_disable();
+		zp = this_zone_pagesets();
+		pcp = &zone_pageset(zp, zone)->pcp[cold];
+
 		local_irq_save(flags);
 		if (pcp->count <= pcp->low)
 			pcp->count += rmqueue_bulk(zone, 0,
@@ -668,7 +700,7 @@ buffered_rmqueue(struct zone *zone, int 
 			pcp->count--;
 		}
 		local_irq_restore(flags);
-		put_cpu();
+		preempt_enable();
 	}
 
 	if (page == NULL) {
@@ -1225,13 +1257,15 @@ void show_free_areas(void)
 		} else
 			printk("\n");
 
-		for (cpu = 0; cpu < NR_CPUS; ++cpu) {
+		for_each_cpu(cpu) {
+			struct zone_pagesets *zp;
 			struct per_cpu_pageset *pageset;
 
 			if (!cpu_possible(cpu))
 				continue;
 
-			pageset = zone->pageset + cpu;
+			zp = cpu_zone_pagesets(cpu);
+			pageset = zone_pageset(zp, zone);
 
 			for (temperature = 0; temperature < 2; temperature++)
 				printk("cpu %d %s: low %d, high %d, batch %d\n",
@@ -1511,6 +1545,62 @@ void __init build_all_zonelists(void)
 	cpuset_init_current_mems_allowed();
 }
 
+void __init build_percpu_pagelists(void)
+{
+	pg_data_t *pgdat;
+
+	for_each_pgdat(pgdat) {
+		int j;
+		int nid = pgdat->node_id;
+
+		for (j = 0; j < MAX_NR_ZONES; j++) {
+			struct zone *zone = pgdat->node_zones + j;
+			int cpu;
+			unsigned long batch;
+		
+			/*
+			 * The per-cpu-pages pools are set to around 1000th of
+			 * the size of the zone.  But no more than 1/4 of a meg
+			 * - there's no point in going beyond the size of L2
+			 *   cache.
+			 *
+			 * OK, so we don't know how big the cache is.  So guess.
+			 */
+			batch = zone->present_pages / 1024;
+			if (batch * PAGE_SIZE > 256 * 1024)
+				batch = (256 * 1024) / PAGE_SIZE;
+			batch /= 4;		/* We effectively *= 4 below */
+			if (batch < 1)
+				batch = 1;
+
+			for (cpu = 0; cpu < NR_CPUS; cpu++) {
+				struct zone_pagesets *zp;
+				struct per_cpu_pageset *pageset;
+				struct per_cpu_pages *pcp;
+			
+				zp = cpu_zone_pagesets(cpu);
+				pageset = &zp->p[NODEZONE(nid, j)];
+
+				pcp = &pageset->pcp[0];	/* hot */
+				pcp->count = 0;
+				pcp->low = 2 * batch;
+				pcp->high = 6 * batch;
+				pcp->batch = 1 * batch;
+				INIT_LIST_HEAD(&pcp->list);
+
+				pcp = &pageset->pcp[1];	/* cold */
+				pcp->count = 0;
+				pcp->low = 0;
+				pcp->high = 2 * batch;
+				pcp->batch = 1 * batch;
+				INIT_LIST_HEAD(&pcp->list);
+			}
+			printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
+					zone_names[j], zone->present_pages, batch);
+		}
+	}
+}
+
 /*
  * Helper functions to size the waitqueue hash table.
  * Essentially these want to choose hash table sizes sufficiently
@@ -1626,7 +1716,7 @@ static void __init free_area_init_core(s
 {
 	unsigned long i, j;
 	const unsigned long zone_required_alignment = 1UL << (MAX_ORDER-1);
-	int cpu, nid = pgdat->node_id;
+	int nid = pgdat->node_id;
 	unsigned long zone_start_pfn = pgdat->node_start_pfn;
 
 	pgdat->nr_zones = 0;
@@ -1636,7 +1726,6 @@ static void __init free_area_init_core(s
 	for (j = 0; j < MAX_NR_ZONES; j++) {
 		struct zone *zone = pgdat->node_zones + j;
 		unsigned long size, realsize;
-		unsigned long batch;
 
 		zone_table[NODEZONE(nid, j)] = zone;
 		realsize = size = zones_size[j];
@@ -1657,39 +1746,6 @@ static void __init free_area_init_core(s
 
 		zone->temp_priority = zone->prev_priority = DEF_PRIORITY;
 
-		/*
-		 * The per-cpu-pages pools are set to around 1000th of the
-		 * size of the zone.  But no more than 1/4 of a meg - there's
-		 * no point in going beyond the size of L2 cache.
-		 *
-		 * OK, so we don't know how big the cache is.  So guess.
-		 */
-		batch = zone->present_pages / 1024;
-		if (batch * PAGE_SIZE > 256 * 1024)
-			batch = (256 * 1024) / PAGE_SIZE;
-		batch /= 4;		/* We effectively *= 4 below */
-		if (batch < 1)
-			batch = 1;
-
-		for (cpu = 0; cpu < NR_CPUS; cpu++) {
-			struct per_cpu_pages *pcp;
-
-			pcp = &zone->pageset[cpu].pcp[0];	/* hot */
-			pcp->count = 0;
-			pcp->low = 2 * batch;
-			pcp->high = 6 * batch;
-			pcp->batch = 1 * batch;
-			INIT_LIST_HEAD(&pcp->list);
-
-			pcp = &zone->pageset[cpu].pcp[1];	/* cold */
-			pcp->count = 0;
-			pcp->low = 0;
-			pcp->high = 2 * batch;
-			pcp->batch = 1 * batch;
-			INIT_LIST_HEAD(&pcp->list);
-		}
-		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%lu\n",
-				zone_names[j], realsize, batch);
 		INIT_LIST_HEAD(&zone->active_list);
 		INIT_LIST_HEAD(&zone->inactive_list);
 		zone->nr_scan_active = 0;
@@ -1720,7 +1776,6 @@ static void __init free_area_init_core(s
 
 		if ((zone_start_pfn) & (zone_required_alignment-1))
 			printk(KERN_CRIT "BUG: wrong zone alignment, it will crash\n");
-
 		memmap_init(size, nid, j, zone_start_pfn);
 
 		zone_start_pfn += size;
Index: linux-2.6/init/main.c
===================================================================
--- linux-2.6.orig/init/main.c	2005-04-09 22:35:25.000000000 +1000
+++ linux-2.6/init/main.c	2005-04-09 22:35:44.000000000 +1000
@@ -454,6 +454,7 @@ asmlinkage void __init start_kernel(void
 	 */
 	preempt_disable();
 	build_all_zonelists();
+	build_percpu_pagelists();
 	page_alloc_init();
 	printk(KERN_NOTICE "Kernel command line: %s\n", saved_command_line);
 	parse_early_param();
Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c	2005-04-09 22:35:25.000000000 +1000
+++ linux-2.6/mm/mempolicy.c	2005-04-09 22:35:44.000000000 +1000
@@ -721,7 +721,7 @@ static struct page *alloc_page_interleav
 	zl = NODE_DATA(nid)->node_zonelists + (gfp & GFP_ZONEMASK);
 	page = __alloc_pages(gfp, order, zl);
 	if (page && page_zone(page) == zl->zones[0]) {
-		zl->zones[0]->pageset[get_cpu()].interleave_hit++;
+		zl->zones[0]->stats[get_cpu()].interleave_hit++;
 		put_cpu();
 	}
 	return page;

--------------000604080806030103050904--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
