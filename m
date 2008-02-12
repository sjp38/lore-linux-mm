Date: Tue, 12 Feb 2008 14:31:20 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Fastpath prototype?
In-Reply-To: <Pine.LNX.4.64.0802121208150.2120@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0802121426060.9829@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
 <20080211235607.GA27320@wotan.suse.de> <Pine.LNX.4.64.0802112205150.26977@schroedinger.engr.sgi.com>
 <200802121140.12040.ak@suse.de> <Pine.LNX.4.64.0802121208150.2120@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

Here is a patch to remove the pcp lists (just in case someone wants to toy 
around with these things too). It hits tbench/SLUB badly because that 
relies heavily on effective caching by the page allocator.

tbench/SLUB:  726.25 MB/sec

Even adding the fast path prototype (covers only slab allocs >=4K 
allocs) yields only 1825.68 MB/sec

I guess these results indicate that tbench would improve even more if we 
had a better fastpath.

A lot of the ugly NUMA stuff (page draining etc) would go away with the 
pcps. Also we could likely simplify NUMA bootstrap.


---
 include/linux/gfp.h    |    5 
 include/linux/mmzone.h |    8 -
 kernel/sysctl.c        |   12 --
 mm/page_alloc.c        |  272 +------------------------------------------------
 mm/vmstat.c            |   39 -------
 5 files changed, 12 insertions(+), 324 deletions(-)

Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2008-02-12 14:06:48.883814096 -0800
+++ linux-2.6/include/linux/gfp.h	2008-02-12 14:25:11.185781673 -0800
@@ -227,8 +227,7 @@ extern void FASTCALL(free_cold_page(stru
 #define free_page(addr) free_pages((addr),0)
 
 void page_alloc_init(void);
-void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
-void drain_all_pages(void);
-void drain_local_pages(void *dummy);
+static inline void drain_all_pages(void) {}
+static inline void drain_local_pages(void *dummy) {}
 
 #endif /* __LINUX_GFP_H */
Index: linux-2.6/include/linux/mmzone.h
===================================================================
--- linux-2.6.orig/include/linux/mmzone.h	2008-02-07 23:28:11.328553973 -0800
+++ linux-2.6/include/linux/mmzone.h	2008-02-12 14:06:53.599840561 -0800
@@ -105,15 +105,7 @@ enum zone_stat_item {
 #endif
 	NR_VM_ZONE_STAT_ITEMS };
 
-struct per_cpu_pages {
-	int count;		/* number of pages in the list */
-	int high;		/* high watermark, emptying needed */
-	int batch;		/* chunk size for buddy add/remove */
-	struct list_head list;	/* the list of pages */
-};
-
 struct per_cpu_pageset {
-	struct per_cpu_pages pcp;
 #ifdef CONFIG_NUMA
 	s8 expire;
 #endif
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2008-02-12 14:06:48.895814167 -0800
+++ linux-2.6/mm/page_alloc.c	2008-02-12 14:25:11.213781917 -0800
@@ -475,35 +475,6 @@ static inline int free_pages_check(struc
 	return PageReserved(page);
 }
 
-/*
- * Frees a list of pages. 
- * Assumes all pages on list are in same zone, and of same order.
- * count is the number of pages to free.
- *
- * If the zone was previously in an "all pages pinned" state then look to
- * see if this freeing clears that state.
- *
- * And clear the zone's pages_scanned counter, to hold off the "all pages are
- * pinned" detection logic.
- */
-static void free_pages_bulk(struct zone *zone, int count,
-					struct list_head *list, int order)
-{
-	spin_lock(&zone->lock);
-	zone_clear_flag(zone, ZONE_ALL_UNRECLAIMABLE);
-	zone->pages_scanned = 0;
-	while (count--) {
-		struct page *page;
-
-		VM_BUG_ON(list_empty(list));
-		page = list_entry(list->prev, struct page, lru);
-		/* have to delete it as __free_one_page list manipulates */
-		list_del(&page->lru);
-		__free_one_page(page, zone, order);
-	}
-	spin_unlock(&zone->lock);
-}
-
 static void free_one_page(struct zone *zone, struct page *page, int order)
 {
 	spin_lock(&zone->lock);
@@ -832,110 +803,6 @@ static struct page *__rmqueue(struct zon
 	return page;
 }
 
-/* 
- * Obtain a specified number of elements from the buddy allocator, all under
- * a single hold of the lock, for efficiency.  Add them to the supplied list.
- * Returns the number of new pages which were placed at *list.
- */
-static int rmqueue_bulk(struct zone *zone, unsigned int order, 
-			unsigned long count, struct list_head *list,
-			int migratetype)
-{
-	int i;
-	
-	spin_lock(&zone->lock);
-	for (i = 0; i < count; ++i) {
-		struct page *page = __rmqueue(zone, order, migratetype);
-		if (unlikely(page == NULL))
-			break;
-
-		/*
-		 * Split buddy pages returned by expand() are received here
-		 * in physical page order. The page is added to the callers and
-		 * list and the list head then moves forward. From the callers
-		 * perspective, the linked list is ordered by page number in
-		 * some conditions. This is useful for IO devices that can
-		 * merge IO requests if the physical pages are ordered
-		 * properly.
-		 */
-		list_add(&page->lru, list);
-		set_page_private(page, migratetype);
-		list = &page->lru;
-	}
-	spin_unlock(&zone->lock);
-	return i;
-}
-
-#ifdef CONFIG_NUMA
-/*
- * Called from the vmstat counter updater to drain pagesets of this
- * currently executing processor on remote nodes after they have
- * expired.
- *
- * Note that this function must be called with the thread pinned to
- * a single processor.
- */
-void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
-{
-	unsigned long flags;
-	int to_drain;
-
-	local_irq_save(flags);
-	if (pcp->count >= pcp->batch)
-		to_drain = pcp->batch;
-	else
-		to_drain = pcp->count;
-	free_pages_bulk(zone, to_drain, &pcp->list, 0);
-	pcp->count -= to_drain;
-	local_irq_restore(flags);
-}
-#endif
-
-/*
- * Drain pages of the indicated processor.
- *
- * The processor must either be the current processor and the
- * thread pinned to the current processor or a processor that
- * is not online.
- */
-static void drain_pages(unsigned int cpu)
-{
-	unsigned long flags;
-	struct zone *zone;
-
-	for_each_zone(zone) {
-		struct per_cpu_pageset *pset;
-		struct per_cpu_pages *pcp;
-
-		if (!populated_zone(zone))
-			continue;
-
-		pset = zone_pcp(zone, cpu);
-
-		pcp = &pset->pcp;
-		local_irq_save(flags);
-		free_pages_bulk(zone, pcp->count, &pcp->list, 0);
-		pcp->count = 0;
-		local_irq_restore(flags);
-	}
-}
-
-/*
- * Spill all of this CPU's per-cpu pages back into the buddy allocator.
- */
-void drain_local_pages(void *arg)
-{
-	drain_pages(smp_processor_id());
-}
-
-/*
- * Spill all the per-cpu pages from all CPUs back into the buddy allocator
- */
-void drain_all_pages(void)
-{
-	on_each_cpu(drain_local_pages, NULL, 0, 1);
-}
-
 #ifdef CONFIG_HIBERNATION
 
 void mark_free_pages(struct zone *zone)
@@ -978,7 +845,6 @@ void mark_free_pages(struct zone *zone)
 static void free_hot_cold_page(struct page *page, int cold)
 {
 	struct zone *zone = page_zone(page);
-	struct per_cpu_pages *pcp;
 	unsigned long flags;
 
 	if (PageAnon(page))
@@ -992,21 +858,11 @@ static void free_hot_cold_page(struct pa
 	arch_free_page(page, 0);
 	kernel_map_pages(page, 1, 0);
 
-	pcp = &zone_pcp(zone, get_cpu())->pcp;
 	local_irq_save(flags);
 	__count_vm_event(PGFREE);
-	if (cold)
-		list_add_tail(&page->lru, &pcp->list);
-	else
-		list_add(&page->lru, &pcp->list);
 	set_page_private(page, get_pageblock_migratetype(page));
-	pcp->count++;
-	if (pcp->count >= pcp->high) {
-		free_pages_bulk(zone, pcp->batch, &pcp->list, 0);
-		pcp->count -= pcp->batch;
-	}
+	free_one_page(zone, page, 0);
 	local_irq_restore(flags);
-	put_cpu();
 }
 
 void free_hot_page(struct page *page)
@@ -1047,56 +903,18 @@ static struct page *buffered_rmqueue(str
 {
 	unsigned long flags;
 	struct page *page;
-	int cold = !!(gfp_flags & __GFP_COLD);
-	int cpu;
 	int migratetype = allocflags_to_migratetype(gfp_flags);
 
 again:
-	cpu  = get_cpu();
-	if (likely(order == 0)) {
-		struct per_cpu_pages *pcp;
-
-		pcp = &zone_pcp(zone, cpu)->pcp;
-		local_irq_save(flags);
-		if (!pcp->count) {
-			pcp->count = rmqueue_bulk(zone, 0,
-					pcp->batch, &pcp->list, migratetype);
-			if (unlikely(!pcp->count))
-				goto failed;
-		}
-
-		/* Find a page of the appropriate migrate type */
-		if (cold) {
-			list_for_each_entry_reverse(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
-					break;
-		} else {
-			list_for_each_entry(page, &pcp->list, lru)
-				if (page_private(page) == migratetype)
-					break;
-		}
-
-		/* Allocate more to the pcp list if necessary */
-		if (unlikely(&page->lru == &pcp->list)) {
-			pcp->count += rmqueue_bulk(zone, 0,
-					pcp->batch, &pcp->list, migratetype);
-			page = list_entry(pcp->list.next, struct page, lru);
-		}
-
-		list_del(&page->lru);
-		pcp->count--;
-	} else {
-		spin_lock_irqsave(&zone->lock, flags);
-		page = __rmqueue(zone, order, migratetype);
-		spin_unlock(&zone->lock);
-		if (!page)
-			goto failed;
-	}
+	spin_lock_irqsave(&zone->lock, flags);
+	page = __rmqueue(zone, order, migratetype);
+	spin_unlock(&zone->lock);
+	if (!page)
+		goto failed;
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(zonelist, zone);
 	local_irq_restore(flags);
-	put_cpu();
 
 	VM_BUG_ON(bad_range(zone, page));
 	if (prep_new_page(page, order, gfp_flags))
@@ -1786,7 +1604,6 @@ void si_meminfo_node(struct sysinfo *val
  */
 void show_free_areas(void)
 {
-	int cpu;
 	struct zone *zone;
 
 	for_each_zone(zone) {
@@ -1794,17 +1611,6 @@ void show_free_areas(void)
 			continue;
 
 		show_node(zone);
-		printk("%s per-cpu:\n", zone->name);
-
-		for_each_online_cpu(cpu) {
-			struct per_cpu_pageset *pageset;
-
-			pageset = zone_pcp(zone, cpu);
-
-			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
-			       cpu, pageset->pcp.high,
-			       pageset->pcp.batch, pageset->pcp.count);
-		}
 	}
 
 	printk("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu\n"
@@ -2597,37 +2403,11 @@ static int zone_batchsize(struct zone *z
 	return batch;
 }
 
-inline void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
+inline void setup_pageset(struct per_cpu_pageset *p)
 {
-	struct per_cpu_pages *pcp;
-
 	memset(p, 0, sizeof(*p));
-
-	pcp = &p->pcp;
-	pcp->count = 0;
-	pcp->high = 6 * batch;
-	pcp->batch = max(1UL, 1 * batch);
-	INIT_LIST_HEAD(&pcp->list);
 }
 
-/*
- * setup_pagelist_highmark() sets the high water mark for hot per_cpu_pagelist
- * to the value high for the pageset p.
- */
-
-static void setup_pagelist_highmark(struct per_cpu_pageset *p,
-				unsigned long high)
-{
-	struct per_cpu_pages *pcp;
-
-	pcp = &p->pcp;
-	pcp->high = high;
-	pcp->batch = max(1UL, high/4);
-	if ((high/4) > (PAGE_SHIFT * 8))
-		pcp->batch = PAGE_SHIFT * 8;
-}
-
-
 #ifdef CONFIG_NUMA
 /*
  * Boot pageset table. One per cpu which is going to be used for all
@@ -2669,11 +2449,7 @@ static int __cpuinit process_zones(int c
 		if (!zone_pcp(zone, cpu))
 			goto bad;
 
-		setup_pageset(zone_pcp(zone, cpu), zone_batchsize(zone));
-
-		if (percpu_pagelist_fraction)
-			setup_pagelist_highmark(zone_pcp(zone, cpu),
-			 	(zone->present_pages / percpu_pagelist_fraction));
+		setup_pageset(zone_pcp(zone, cpu));
 	}
 
 	return 0;
@@ -2798,9 +2574,9 @@ static __meminit void zone_pcp_init(stru
 #ifdef CONFIG_NUMA
 		/* Early boot. Slab allocator not functional yet */
 		zone_pcp(zone, cpu) = &boot_pageset[cpu];
-		setup_pageset(&boot_pageset[cpu],0);
+		setup_pageset(&boot_pageset[cpu]);
 #else
-		setup_pageset(zone_pcp(zone,cpu), batch);
+		setup_pageset(zone_pcp(zone,cpu));
 #endif
 	}
 	if (zone->present_pages)
@@ -3971,8 +3747,6 @@ static int page_alloc_cpu_notify(struct 
 	int cpu = (unsigned long)hcpu;
 
 	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
-		drain_pages(cpu);
-
 		/*
 		 * Spill the event counters of the dead processor
 		 * into the current processors event counters.
@@ -4236,32 +4010,6 @@ int lowmem_reserve_ratio_sysctl_handler(
 	return 0;
 }
 
-/*
- * percpu_pagelist_fraction - changes the pcp->high for each zone on each
- * cpu.  It is the fraction of total pages in each zone that a hot per cpu pagelist
- * can have before it gets flushed back to buddy allocator.
- */
-
-int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
-	struct file *file, void __user *buffer, size_t *length, loff_t *ppos)
-{
-	struct zone *zone;
-	unsigned int cpu;
-	int ret;
-
-	ret = proc_dointvec_minmax(table, write, file, buffer, length, ppos);
-	if (!write || (ret == -EINVAL))
-		return ret;
-	for_each_zone(zone) {
-		for_each_online_cpu(cpu) {
-			unsigned long  high;
-			high = zone->present_pages / percpu_pagelist_fraction;
-			setup_pagelist_highmark(zone_pcp(zone, cpu), high);
-		}
-	}
-	return 0;
-}
-
 int hashdist = HASHDIST_DEFAULT;
 
 #ifdef CONFIG_NUMA
Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2008-02-07 23:28:12.596577762 -0800
+++ linux-2.6/mm/vmstat.c	2008-02-12 14:06:53.619840675 -0800
@@ -317,37 +317,7 @@ void refresh_cpu_vm_stats(int cpu)
 				local_irq_restore(flags);
 				atomic_long_add(v, &zone->vm_stat[i]);
 				global_diff[i] += v;
-#ifdef CONFIG_NUMA
-				/* 3 seconds idle till flush */
-				p->expire = 3;
-#endif
 			}
-#ifdef CONFIG_NUMA
-		/*
-		 * Deal with draining the remote pageset of this
-		 * processor
-		 *
-		 * Check if there are pages remaining in this pageset
-		 * if not then there is nothing to expire.
-		 */
-		if (!p->expire || !p->pcp.count)
-			continue;
-
-		/*
-		 * We never drain zones local to this processor.
-		 */
-		if (zone_to_nid(zone) == numa_node_id()) {
-			p->expire = 0;
-			continue;
-		}
-
-		p->expire--;
-		if (p->expire)
-			continue;
-
-		if (p->pcp.count)
-			drain_zone_pages(zone, &p->pcp);
-#endif
 	}
 
 	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
@@ -685,15 +655,6 @@ static void zoneinfo_show_print(struct s
 		struct per_cpu_pageset *pageset;
 
 		pageset = zone_pcp(zone, i);
-		seq_printf(m,
-			   "\n    cpu: %i"
-			   "\n              count: %i"
-			   "\n              high:  %i"
-			   "\n              batch: %i",
-			   i,
-			   pageset->pcp.count,
-			   pageset->pcp.high,
-			   pageset->pcp.batch);
 #ifdef CONFIG_SMP
 		seq_printf(m, "\n  vm stats threshold: %d",
 				pageset->stat_threshold);
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c	2008-02-12 14:11:38.553441536 -0800
+++ linux-2.6/kernel/sysctl.c	2008-02-12 14:11:56.161540376 -0800
@@ -75,7 +75,6 @@ extern int pid_max;
 extern int min_free_kbytes;
 extern int pid_max_min, pid_max_max;
 extern int sysctl_drop_caches;
-extern int percpu_pagelist_fraction;
 extern int compat_log;
 extern int maps_protect;
 extern int sysctl_stat_interval;
@@ -100,7 +99,6 @@ static int one_hundred = 100;
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
 static int minolduid;
-static int min_percpu_pagelist_fract = 8;
 
 static int ngroups_max = NGROUPS_MAX;
 
@@ -1012,16 +1010,6 @@ static struct ctl_table vm_table[] = {
 		.strategy	= &sysctl_intvec,
 		.extra1		= &zero,
 	},
-	{
-		.ctl_name	= VM_PERCPU_PAGELIST_FRACTION,
-		.procname	= "percpu_pagelist_fraction",
-		.data		= &percpu_pagelist_fraction,
-		.maxlen		= sizeof(percpu_pagelist_fraction),
-		.mode		= 0644,
-		.proc_handler	= &percpu_pagelist_fraction_sysctl_handler,
-		.strategy	= &sysctl_intvec,
-		.extra1		= &min_percpu_pagelist_fract,
-	},
 #ifdef CONFIG_MMU
 	{
 		.ctl_name	= VM_MAX_MAP_COUNT,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
