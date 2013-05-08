Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 4F1286B013B
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:16 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 08/22] mm: page allocator: Remove the per-cpu page allocator
Date: Wed,  8 May 2013 17:02:53 +0100
Message-Id: <1368028987-8369-9-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch removes the per-cpu page allocator in preparation for placing
a different order-0 allocator in front of the buddy allocator. This is to
simplify review.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/gfp.h         |   3 -
 include/linux/mm.h          |   3 -
 include/linux/mmzone.h      |  12 -
 include/trace/events/kmem.h |  11 -
 init/main.c                 |   1 -
 kernel/power/snapshot.c     |   2 -
 kernel/sysctl.c             |  10 -
 mm/memory-failure.c         |   1 -
 mm/memory_hotplug.c         |  11 +-
 mm/page_alloc.c             | 581 ++------------------------------------------
 mm/page_isolation.c         |   2 -
 mm/vmstat.c                 |  39 +--
 12 files changed, 29 insertions(+), 647 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 66e45e7..edf3184 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -374,9 +374,6 @@ extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
 #define free_page(addr) free_pages((addr), 0)
 
 void page_alloc_init(void);
-void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
-void drain_all_pages(void);
-void drain_local_pages(void *dummy);
 
 /*
  * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e2091b8..04cb6b4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1367,9 +1367,6 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...);
 
 extern void setup_per_cpu_pageset(void);
 
-extern void zone_pcp_update(struct zone *zone);
-extern void zone_pcp_reset(struct zone *zone);
-
 /* page_alloc.c */
 extern int min_free_kbytes;
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 57f03b3..3ee9b27 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -235,17 +235,7 @@ enum zone_watermarks {
 #define low_wmark_pages(z) (z->watermark[WMARK_LOW])
 #define high_wmark_pages(z) (z->watermark[WMARK_HIGH])
 
-struct per_cpu_pages {
-	int count;		/* number of pages in the list */
-	int high;		/* high watermark, emptying needed */
-	int batch;		/* chunk size for buddy add/remove */
-
-	/* Lists of pages, one per migrate type stored on the pcp-lists */
-	struct list_head lists[MIGRATE_PCPTYPES];
-};
-
 struct per_cpu_pageset {
-	struct per_cpu_pages pcp;
 #ifdef CONFIG_NUMA
 	s8 expire;
 #endif
@@ -900,8 +890,6 @@ int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
 extern int sysctl_lowmem_reserve_ratio[MAX_NR_ZONES-1];
 int lowmem_reserve_ratio_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
-int percpu_pagelist_fraction_sysctl_handler(struct ctl_table *, int,
-					void __user *, size_t *, loff_t *);
 int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 6bc943e..0a5501a 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -253,17 +253,6 @@ DEFINE_EVENT(mm_page, mm_page_alloc_zone_locked,
 	TP_ARGS(page, order, migratetype)
 );
 
-DEFINE_EVENT_PRINT(mm_page, mm_page_pcpu_drain,
-
-	TP_PROTO(struct page *page, unsigned int order, int migratetype),
-
-	TP_ARGS(page, order, migratetype),
-
-	TP_printk("page=%p pfn=%lu order=%d migratetype=%d",
-		__entry->page, page_to_pfn(__entry->page),
-		__entry->order, __entry->migratetype)
-);
-
 TRACE_EVENT(mm_page_alloc_extfrag,
 
 	TP_PROTO(struct page *page,
diff --git a/init/main.c b/init/main.c
index 63534a1..8d0bbce 100644
--- a/init/main.c
+++ b/init/main.c
@@ -597,7 +597,6 @@ asmlinkage void __init start_kernel(void)
 	page_cgroup_init();
 	debug_objects_mem_init();
 	kmemleak_init();
-	setup_per_cpu_pageset();
 	numa_policy_init();
 	if (late_time_init)
 		late_time_init();
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 0de2857..08b2766 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -1582,7 +1582,6 @@ asmlinkage int swsusp_save(void)
 
 	printk(KERN_INFO "PM: Creating hibernation image:\n");
 
-	drain_local_pages(NULL);
 	nr_pages = count_data_pages();
 	nr_highmem = count_highmem_pages();
 	printk(KERN_INFO "PM: Need to copy %u pages\n", nr_pages + nr_highmem);
@@ -1600,7 +1599,6 @@ asmlinkage int swsusp_save(void)
 	/* During allocating of suspend pagedir, new cold pages may appear.
 	 * Kill them.
 	 */
-	drain_local_pages(NULL);
 	copy_data_pages(&copy_bm, &orig_bm);
 
 	/*
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index afc1dc6..ce38025 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -107,7 +107,6 @@ extern unsigned int core_pipe_limit;
 extern int pid_max;
 extern int pid_max_min, pid_max_max;
 extern int sysctl_drop_caches;
-extern int percpu_pagelist_fraction;
 extern int compat_log;
 extern int latencytop_enabled;
 extern int sysctl_nr_open_min, sysctl_nr_open_max;
@@ -140,7 +139,6 @@ static unsigned long dirty_bytes_min = 2 * PAGE_SIZE;
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
 static int minolduid;
-static int min_percpu_pagelist_fract = 8;
 
 static int ngroups_max = NGROUPS_MAX;
 static const int cap_last_cap = CAP_LAST_CAP;
@@ -1266,14 +1264,6 @@ static struct ctl_table vm_table[] = {
 		.proc_handler	= min_free_kbytes_sysctl_handler,
 		.extra1		= &zero,
 	},
-	{
-		.procname	= "percpu_pagelist_fraction",
-		.data		= &percpu_pagelist_fraction,
-		.maxlen		= sizeof(percpu_pagelist_fraction),
-		.mode		= 0644,
-		.proc_handler	= percpu_pagelist_fraction_sysctl_handler,
-		.extra1		= &min_percpu_pagelist_fract,
-	},
 #ifdef CONFIG_MMU
 	{
 		.procname	= "max_map_count",
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index df0694c..3175ffd 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -237,7 +237,6 @@ void shake_page(struct page *p, int access)
 		lru_add_drain_all();
 		if (PageLRU(p))
 			return;
-		drain_all_pages();
 		if (PageLRU(p) || is_free_buddy_page(p))
 			return;
 	}
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index ee37657..63f473c 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -970,8 +970,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
 		online_pages_range);
 	if (ret) {
-		if (need_zonelists_rebuild)
-			zone_pcp_reset(zone);
 		mutex_unlock(&zonelists_mutex);
 		printk(KERN_DEBUG "online_pages [mem %#010llx-%#010llx] failed\n",
 		       (unsigned long long) pfn << PAGE_SHIFT,
@@ -989,8 +987,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
 		node_states_set_node(zone_to_nid(zone), &arg);
 		if (need_zonelists_rebuild)
 			build_all_zonelists(NULL, NULL);
-		else
-			zone_pcp_update(zone);
 	}
 
 	mutex_unlock(&zonelists_mutex);
@@ -1530,7 +1526,6 @@ repeat:
 	if (drain) {
 		lru_add_drain_all();
 		cond_resched();
-		drain_all_pages();
 	}
 
 	pfn = scan_lru_pages(start_pfn, end_pfn);
@@ -1551,8 +1546,6 @@ repeat:
 	/* drain all zone's lru pagevec, this is asynchronous... */
 	lru_add_drain_all();
 	yield();
-	/* drain pcp pages, this is synchronous. */
-	drain_all_pages();
 	/* check again */
 	offlined_pages = check_pages_isolated(start_pfn, end_pfn);
 	if (offlined_pages < 0) {
@@ -1574,12 +1567,10 @@ repeat:
 	init_per_zone_wmark_min();
 
 	if (!populated_zone(zone)) {
-		zone_pcp_reset(zone);
 		mutex_lock(&zonelists_mutex);
 		build_all_zonelists(NULL, NULL);
 		mutex_unlock(&zonelists_mutex);
-	} else
-		zone_pcp_update(zone);
+	}
 
 	node_states_clear_node(node, &arg);
 	if (arg.status_change_nid >= 0)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8867937..cd64c27 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -109,7 +109,6 @@ unsigned long totalreserve_pages __read_mostly;
  */
 unsigned long dirty_balance_reserve __read_mostly;
 
-int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
 
 #ifdef CONFIG_PM_SLEEP
@@ -620,70 +619,6 @@ static inline int free_pages_check(struct page *page)
 	return 0;
 }
 
-/*
- * Frees a number of pages from the PCP lists
- * Assumes all pages on list are in same zone, and of same order.
- * count is the number of pages to free.
- *
- * If the zone was previously in an "all pages pinned" state then look to
- * see if this freeing clears that state.
- *
- * And clear the zone's pages_scanned counter, to hold off the "all pages are
- * pinned" detection logic.
- */
-static void free_pcppages_bulk(struct zone *zone, int count,
-					struct per_cpu_pages *pcp)
-{
-	int migratetype = 0;
-	int batch_free = 0;
-	int to_free = count;
-
-	spin_lock(&zone->lock);
-	zone->all_unreclaimable = 0;
-	zone->pages_scanned = 0;
-
-	while (to_free) {
-		struct page *page;
-		struct list_head *list;
-
-		/*
-		 * Remove pages from lists in a round-robin fashion. A
-		 * batch_free count is maintained that is incremented when an
-		 * empty list is encountered.  This is so more pages are freed
-		 * off fuller lists instead of spinning excessively around empty
-		 * lists
-		 */
-		do {
-			batch_free++;
-			if (++migratetype == MIGRATE_PCPTYPES)
-				migratetype = 0;
-			list = &pcp->lists[migratetype];
-		} while (list_empty(list));
-
-		/* This is the only non-empty list. Free them all. */
-		if (batch_free == MIGRATE_PCPTYPES)
-			batch_free = to_free;
-
-		do {
-			int mt;	/* migratetype of the to-be-freed page */
-
-			page = list_entry(list->prev, struct page, lru);
-			/* must delete as __free_one_page list manipulates */
-			list_del(&page->lru);
-			mt = get_freepage_migratetype(page);
-			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
-			__free_one_page(page, zone, 0, mt);
-			trace_mm_page_pcpu_drain(page, 0, mt);
-			if (likely(!is_migrate_isolate_page(zone, page))) {
-				__mod_zone_page_state(zone, NR_FREE_PAGES, 1);
-				if (is_migrate_cma(mt))
-					__mod_zone_page_state(zone, NR_FREE_CMA_PAGES, 1);
-			}
-		} while (--to_free && --batch_free && !list_empty(list));
-	}
-	spin_unlock(&zone->lock);
-}
-
 static void free_one_page(struct zone *zone, struct page *page,
 				unsigned int order,
 				int migratetype)
@@ -1121,159 +1056,6 @@ retry_reserve:
 	return page;
 }
 
-/*
- * Obtain a specified number of elements from the buddy allocator, all under
- * a single hold of the lock, for efficiency.  Add them to the supplied list.
- * Returns the number of new pages which were placed at *list.
- */
-static int rmqueue_bulk(struct zone *zone, unsigned int order,
-			unsigned long count, struct list_head *list,
-			int migratetype, int cold)
-{
-	int mt = migratetype, i;
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
-		if (likely(cold == 0))
-			list_add(&page->lru, list);
-		else
-			list_add_tail(&page->lru, list);
-		if (IS_ENABLED(CONFIG_CMA)) {
-			mt = get_pageblock_migratetype(page);
-			if (!is_migrate_cma(mt) && !is_migrate_isolate(mt))
-				mt = migratetype;
-		}
-		set_freepage_migratetype(page, mt);
-		list = &page->lru;
-		if (is_migrate_cma(mt))
-			__mod_zone_page_state(zone, NR_FREE_CMA_PAGES,
-					      -(1 << order));
-	}
-	__mod_zone_page_state(zone, NR_FREE_PAGES, -(i << order));
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
-	if (to_drain > 0) {
-		free_pcppages_bulk(zone, to_drain, pcp);
-		pcp->count -= to_drain;
-	}
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
-	for_each_populated_zone(zone) {
-		struct per_cpu_pageset *pset;
-		struct per_cpu_pages *pcp;
-
-		local_irq_save(flags);
-		pset = per_cpu_ptr(zone->pageset, cpu);
-
-		pcp = &pset->pcp;
-		if (pcp->count) {
-			free_pcppages_bulk(zone, pcp->count, pcp);
-			pcp->count = 0;
-		}
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
- * Spill all the per-cpu pages from all CPUs back into the buddy allocator.
- *
- * Note that this code is protected against sending an IPI to an offline
- * CPU but does not guarantee sending an IPI to newly hotplugged CPUs:
- * on_each_cpu_mask() blocks hotplug and won't talk to offlined CPUs but
- * nothing keeps CPUs from showing up after we populated the cpumask and
- * before the call to on_each_cpu_mask().
- */
-void drain_all_pages(void)
-{
-	int cpu;
-	struct per_cpu_pageset *pcp;
-	struct zone *zone;
-
-	/*
-	 * Allocate in the BSS so we wont require allocation in
-	 * direct reclaim path for CONFIG_CPUMASK_OFFSTACK=y
-	 */
-	static cpumask_t cpus_with_pcps;
-
-	/*
-	 * We don't care about racing with CPU hotplug event
-	 * as offline notification will cause the notified
-	 * cpu to drain that CPU pcps and on_each_cpu_mask
-	 * disables preemption as part of its processing
-	 */
-	for_each_online_cpu(cpu) {
-		bool has_pcps = false;
-		for_each_populated_zone(zone) {
-			pcp = per_cpu_ptr(zone->pageset, cpu);
-			if (pcp->pcp.count) {
-				has_pcps = true;
-				break;
-			}
-		}
-		if (has_pcps)
-			cpumask_set_cpu(cpu, &cpus_with_pcps);
-		else
-			cpumask_clear_cpu(cpu, &cpus_with_pcps);
-	}
-	on_each_cpu_mask(&cpus_with_pcps, drain_local_pages, NULL, 1);
-}
-
 #ifdef CONFIG_HIBERNATION
 
 void mark_free_pages(struct zone *zone)
@@ -1317,8 +1099,6 @@ void mark_free_pages(struct zone *zone)
 void free_hot_cold_page(struct page *page, bool cold)
 {
 	struct zone *zone = page_zone(page);
-	struct per_cpu_pages *pcp;
-	unsigned long flags;
 	int migratetype;
 
 	if (!free_pages_prepare(page, 0))
@@ -1326,37 +1106,7 @@ void free_hot_cold_page(struct page *page, bool cold)
 
 	migratetype = get_pageblock_migratetype(page);
 	set_freepage_migratetype(page, migratetype);
-
-	/*
-	 * We only track unmovable, reclaimable and movable on pcp lists.
-	 * Free ISOLATE pages back to the allocator because they are being
-	 * offlined but treat RESERVE as movable pages so we can get those
-	 * areas back if necessary. Otherwise, we may have to free
-	 * excessively into the page allocator
-	 */
-	if (migratetype >= MIGRATE_PCPTYPES) {
-		if (unlikely(is_migrate_isolate(migratetype))) {
-			free_one_page(zone, page, 0, migratetype);
-			return;
-		}
-		migratetype = MIGRATE_MOVABLE;
-	}
-
-	local_irq_save(flags);
-	__count_vm_event(PGFREE);
-
-	pcp = &this_cpu_ptr(zone->pageset)->pcp;
-	if (cold)
-		list_add_tail(&page->lru, &pcp->lists[migratetype]);
-	else
-		list_add(&page->lru, &pcp->lists[migratetype]);
-	pcp->count++;
-	if (pcp->count >= pcp->high) {
-		free_pcppages_bulk(zone, pcp->batch, pcp);
-		pcp->count -= pcp->batch;
-	}
-
-	local_irq_restore(flags);
+	free_one_page(zone, page, 0, migratetype);
 }
 
 /*
@@ -1478,54 +1228,30 @@ struct page *buffered_rmqueue(struct zone *preferred_zone,
 {
 	unsigned long flags;
 	struct page *page;
-	int cold = !!(gfp_flags & __GFP_COLD);
-
-again:
-	if (likely(order == 0)) {
-		struct per_cpu_pages *pcp;
-		struct list_head *list;
-
-		local_irq_save(flags);
-		pcp = &this_cpu_ptr(zone->pageset)->pcp;
-		list = &pcp->lists[migratetype];
-		if (list_empty(list)) {
-			pcp->count += rmqueue_bulk(zone, 0,
-					pcp->batch, list,
-					migratetype, cold);
-			if (unlikely(list_empty(list)))
-				goto failed;
-		}
 
-		if (cold)
-			page = list_entry(list->prev, struct page, lru);
-		else
-			page = list_entry(list->next, struct page, lru);
-
-		list_del(&page->lru);
-		pcp->count--;
-	} else {
-		if (unlikely(gfp_flags & __GFP_NOFAIL)) {
-			/*
-			 * __GFP_NOFAIL is not to be used in new code.
-			 *
-			 * All __GFP_NOFAIL callers should be fixed so that they
-			 * properly detect and handle allocation failures.
-			 *
-			 * We most definitely don't want callers attempting to
-			 * allocate greater than order-1 page units with
-			 * __GFP_NOFAIL.
-			 */
-			WARN_ON_ONCE(order > 1);
-		}
-		spin_lock_irqsave(&zone->lock, flags);
-		page = __rmqueue(zone, order, migratetype);
-		spin_unlock(&zone->lock);
-		if (!page)
-			goto failed;
-		__mod_zone_freepage_state(zone, -(1 << order),
-					  get_freepage_migratetype(page));
+	if (unlikely(gfp_flags & __GFP_NOFAIL)) {
+		/*
+		 * __GFP_NOFAIL is not to be used in new code.
+		 *
+		 * All __GFP_NOFAIL callers should be fixed so that they
+		 * properly detect and handle allocation failures.
+		 *
+		 * We most definitely don't want callers attempting to
+		 * allocate greater than order-1 page units with
+		 * __GFP_NOFAIL.
+		 */
+		WARN_ON_ONCE(order > 1);
 	}
 
+again:
+	spin_lock_irqsave(&zone->lock, flags);
+	page = __rmqueue(zone, order, migratetype);
+	spin_unlock(&zone->lock);
+	if (!page)
+		goto failed;
+	__mod_zone_freepage_state(zone, -(1 << order),
+				  get_freepage_migratetype(page));
+
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
 	zone_statistics(preferred_zone, zone, gfp_flags);
 	local_irq_restore(flags);
@@ -2151,10 +1877,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	if (*did_some_progress != COMPACT_SKIPPED) {
 		struct page *page;
 
-		/* Page migration frees to the PCP lists but we want merging */
-		drain_pages(get_cpu());
-		put_cpu();
-
 		page = get_page_from_freelist(gfp_mask, nodemask,
 				order, zonelist, high_zoneidx,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
@@ -2237,7 +1959,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	int migratetype, unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
-	bool drained = false;
 
 	*did_some_progress = __perform_reclaim(gfp_mask, order, zonelist,
 					       nodemask);
@@ -2248,22 +1969,11 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	if (IS_ENABLED(CONFIG_NUMA))
 		zlc_clear_zones_full(zonelist);
 
-retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
 					zonelist, high_zoneidx,
 					alloc_flags & ~ALLOC_NO_WATERMARKS,
 					preferred_zone, migratetype);
 
-	/*
-	 * If an allocation failed after direct reclaim, it could be because
-	 * pages are pinned on the per-cpu lists. Drain them and try again
-	 */
-	if (!page && !drained) {
-		drain_all_pages();
-		drained = true;
-		goto retry;
-	}
-
 	return page;
 }
 
@@ -2950,24 +2660,12 @@ static void show_migration_types(unsigned char type)
  */
 void show_free_areas(unsigned int filter)
 {
-	int cpu;
 	struct zone *zone;
 
 	for_each_populated_zone(zone) {
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
 			continue;
 		show_node(zone);
-		printk("%s per-cpu:\n", zone->name);
-
-		for_each_online_cpu(cpu) {
-			struct per_cpu_pageset *pageset;
-
-			pageset = per_cpu_ptr(zone->pageset, cpu);
-
-			printk("CPU %4d: hi:%5d, btch:%4d usd:%4d\n",
-			       cpu, pageset->pcp.high,
-			       pageset->pcp.batch, pageset->pcp.count);
-		}
 	}
 
 	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
@@ -3580,25 +3278,6 @@ static void build_zonelist_cache(pg_data_t *pgdat)
 #endif	/* CONFIG_NUMA */
 
 /*
- * Boot pageset table. One per cpu which is going to be used for all
- * zones and all nodes. The parameters will be set in such a way
- * that an item put on a list will immediately be handed over to
- * the buddy list. This is safe since pageset manipulation is done
- * with interrupts disabled.
- *
- * The boot_pagesets must be kept even after bootup is complete for
- * unused processors and/or zones. They do play a role for bootstrapping
- * hotplugged processors.
- *
- * zoneinfo_show() and maybe other functions do
- * not check if the processor is online before following the pageset pointer.
- * Other parts of the kernel may not check if the zone is available.
- */
-static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch);
-static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
-static void setup_zone_pageset(struct zone *zone);
-
-/*
  * Global mutex to protect against size modification of zonelists
  * as well as to serialize pageset setup for the new populated zone.
  */
@@ -3641,8 +3320,6 @@ static int __build_all_zonelists(void *data)
 	 * (a chicken-egg dilemma).
 	 */
 	for_each_possible_cpu(cpu) {
-		setup_pageset(&per_cpu(boot_pageset, cpu), 0);
-
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
 		/*
 		 * We now know the "local memory node" for each node--
@@ -3675,10 +3352,6 @@ void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
 	} else {
 		/* we have to stop all cpus to guarantee there is no user
 		   of zonelist */
-#ifdef CONFIG_MEMORY_HOTPLUG
-		if (zone)
-			setup_zone_pageset(zone);
-#endif
 		stop_machine(__build_all_zonelists, pgdat, NULL);
 		/* cpuset refresh routine should be here */
 	}
@@ -3950,118 +3623,6 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	memmap_init_zone((size), (nid), (zone), (start_pfn), MEMMAP_EARLY)
 #endif
 
-static int __meminit zone_batchsize(struct zone *zone)
-{
-#ifdef CONFIG_MMU
-	int batch;
-
-	/*
-	 * The per-cpu-pages pools are set to around 1000th of the
-	 * size of the zone.  But no more than 1/2 of a meg.
-	 *
-	 * OK, so we don't know how big the cache is.  So guess.
-	 */
-	batch = zone->managed_pages / 1024;
-	if (batch * PAGE_SIZE > 512 * 1024)
-		batch = (512 * 1024) / PAGE_SIZE;
-	batch /= 4;		/* We effectively *= 4 below */
-	if (batch < 1)
-		batch = 1;
-
-	/*
-	 * Clamp the batch to a 2^n - 1 value. Having a power
-	 * of 2 value was found to be more likely to have
-	 * suboptimal cache aliasing properties in some cases.
-	 *
-	 * For example if 2 tasks are alternately allocating
-	 * batches of pages, one task can end up with a lot
-	 * of pages of one half of the possible page colors
-	 * and the other with pages of the other colors.
-	 */
-	batch = rounddown_pow_of_two(batch + batch/2) - 1;
-
-	return batch;
-
-#else
-	/* The deferral and batching of frees should be suppressed under NOMMU
-	 * conditions.
-	 *
-	 * The problem is that NOMMU needs to be able to allocate large chunks
-	 * of contiguous memory as there's no hardware page translation to
-	 * assemble apparent contiguous memory from discontiguous pages.
-	 *
-	 * Queueing large contiguous runs of pages for batching, however,
-	 * causes the pages to actually be freed in smaller chunks.  As there
-	 * can be a significant delay between the individual batches being
-	 * recycled, this leads to the once large chunks of space being
-	 * fragmented and becoming unavailable for high-order allocations.
-	 */
-	return 0;
-#endif
-}
-
-static void setup_pageset(struct per_cpu_pageset *p, unsigned long batch)
-{
-	struct per_cpu_pages *pcp;
-	int migratetype;
-
-	memset(p, 0, sizeof(*p));
-
-	pcp = &p->pcp;
-	pcp->count = 0;
-	pcp->high = 6 * batch;
-	pcp->batch = max(1UL, 1 * batch);
-	for (migratetype = 0; migratetype < MIGRATE_PCPTYPES; migratetype++)
-		INIT_LIST_HEAD(&pcp->lists[migratetype]);
-}
-
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
-static void __meminit setup_zone_pageset(struct zone *zone)
-{
-	int cpu;
-
-	zone->pageset = alloc_percpu(struct per_cpu_pageset);
-
-	for_each_possible_cpu(cpu) {
-		struct per_cpu_pageset *pcp = per_cpu_ptr(zone->pageset, cpu);
-
-		setup_pageset(pcp, zone_batchsize(zone));
-
-		if (percpu_pagelist_fraction)
-			setup_pagelist_highmark(pcp,
-				(zone->managed_pages /
-					percpu_pagelist_fraction));
-	}
-}
-
-/*
- * Allocate per cpu pagesets and initialize them.
- * Before this call only boot pagesets were available.
- */
-void __init setup_per_cpu_pageset(void)
-{
-	struct zone *zone;
-
-	for_each_populated_zone(zone)
-		setup_zone_pageset(zone);
-}
-
 static noinline __init_refok
 int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 {
@@ -4105,21 +3666,6 @@ int zone_wait_table_init(struct zone *zone, unsigned long zone_size_pages)
 	return 0;
 }
 
-static __meminit void zone_pcp_init(struct zone *zone)
-{
-	/*
-	 * per cpu subsystem is not up at this point. The following code
-	 * relies on the ability of the linker to provide the
-	 * offset of a (static) per cpu variable into the per cpu area.
-	 */
-	zone->pageset = &boot_pageset;
-
-	if (zone->present_pages)
-		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%u\n",
-			zone->name, zone->present_pages,
-					 zone_batchsize(zone));
-}
-
 int __meminit init_currently_empty_zone(struct zone *zone,
 					unsigned long zone_start_pfn,
 					unsigned long size,
@@ -4621,7 +4167,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
-		zone_pcp_init(zone);
+		if (zone->present_pages)
+			printk(KERN_DEBUG "  %s zone: %lu pages\n",
+				zone->name, zone->present_pages);
+
 		lruvec_init(&zone->lruvec);
 		if (!size)
 			continue;
@@ -5138,7 +4687,6 @@ static int page_alloc_cpu_notify(struct notifier_block *self,
 
 	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
 		lru_add_drain_cpu(cpu);
-		drain_pages(cpu);
 
 		/*
 		 * Spill the event counters of the dead processor
@@ -5465,33 +5013,6 @@ int lowmem_reserve_ratio_sysctl_handler(ctl_table *table, int write,
 	return 0;
 }
 
-/*
- * percpu_pagelist_fraction - changes the pcp->high for each zone on each
- * cpu.  It is the fraction of total pages in each zone that a hot per cpu pagelist
- * can have before it gets flushed back to buddy allocator.
- */
-
-int percpu_pagelist_fraction_sysctl_handler(ctl_table *table, int write,
-	void __user *buffer, size_t *length, loff_t *ppos)
-{
-	struct zone *zone;
-	unsigned int cpu;
-	int ret;
-
-	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
-	if (!write || (ret < 0))
-		return ret;
-	for_each_populated_zone(zone) {
-		for_each_possible_cpu(cpu) {
-			unsigned long  high;
-			high = zone->managed_pages / percpu_pagelist_fraction;
-			setup_pagelist_highmark(
-				per_cpu_ptr(zone->pageset, cpu), high);
-		}
-	}
-	return 0;
-}
-
 int hashdist = HASHDIST_DEFAULT;
 
 #ifdef CONFIG_NUMA
@@ -5922,7 +5443,6 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	 */
 
 	lru_add_drain_all();
-	drain_all_pages();
 
 	order = 0;
 	outer_start = start;
@@ -5976,55 +5496,6 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 }
 #endif
 
-#ifdef CONFIG_MEMORY_HOTPLUG
-static int __meminit __zone_pcp_update(void *data)
-{
-	struct zone *zone = data;
-	int cpu;
-	unsigned long batch = zone_batchsize(zone), flags;
-
-	for_each_possible_cpu(cpu) {
-		struct per_cpu_pageset *pset;
-		struct per_cpu_pages *pcp;
-
-		pset = per_cpu_ptr(zone->pageset, cpu);
-		pcp = &pset->pcp;
-
-		local_irq_save(flags);
-		if (pcp->count > 0)
-			free_pcppages_bulk(zone, pcp->count, pcp);
-		drain_zonestat(zone, pset);
-		setup_pageset(pset, batch);
-		local_irq_restore(flags);
-	}
-	return 0;
-}
-
-void __meminit zone_pcp_update(struct zone *zone)
-{
-	stop_machine(__zone_pcp_update, zone, NULL);
-}
-#endif
-
-void zone_pcp_reset(struct zone *zone)
-{
-	unsigned long flags;
-	int cpu;
-	struct per_cpu_pageset *pset;
-
-	/* avoid races with drain_pages()  */
-	local_irq_save(flags);
-	if (zone->pageset != &boot_pageset) {
-		for_each_online_cpu(cpu) {
-			pset = per_cpu_ptr(zone->pageset, cpu);
-			drain_zonestat(zone, pset);
-		}
-		free_percpu(zone->pageset);
-		zone->pageset = &boot_pageset;
-	}
-	local_irq_restore(flags);
-}
-
 #ifdef CONFIG_MEMORY_HOTREMOVE
 /*
  * All pages in the range must be isolated before calling this.
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 9f0c068..af79199 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -65,8 +65,6 @@ out:
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
-	if (!ret)
-		drain_all_pages();
 	return ret;
 }
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index e1d8ed1..45e699c 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -462,32 +462,6 @@ void refresh_cpu_vm_stats(int cpu)
 #endif
 			}
 		cond_resched();
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
@@ -1028,24 +1002,15 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	seq_printf(m,
 		   ")"
 		   "\n  pagesets");
+#ifdef CONFIG_SMP
 	for_each_online_cpu(i) {
 		struct per_cpu_pageset *pageset;
 
 		pageset = per_cpu_ptr(zone->pageset, i);
-		seq_printf(m,
-			   "\n    cpu: %i"
-			   "\n              count: %i"
-			   "\n              high:  %i"
-			   "\n              batch: %i",
-			   i,
-			   pageset->pcp.count,
-			   pageset->pcp.high,
-			   pageset->pcp.batch);
-#ifdef CONFIG_SMP
 		seq_printf(m, "\n  vm stats threshold: %d",
 				pageset->stat_threshold);
-#endif
 	}
+#endif
 	seq_printf(m,
 		   "\n  all_unreclaimable: %u"
 		   "\n  start_pfn:         %lu"
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
