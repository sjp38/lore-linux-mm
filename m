Message-Id: <20070507212408.471311513@sgi.com>
References: <20070507212240.254911542@sgi.com>
Date: Mon, 07 May 2007 14:22:45 -0700
From: clameter@sgi.com
Subject: [patch 05/17] Move remote node draining out of slab allocators
Content-Disposition: inline; filename=newdrain
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently the slab allocators contain callbacks into the page allocator
to perform the draining of pagesets on remote nodes. This requires SLUB
to have a whole subsystem in order to be compatible with SLAB. Moving
node draining out of the slab allocators avoids a section of code in SLUB.

Move the node draining so that is is done when the vm statistics are updated.
At that point we are already touching all the cachelines with the pagesets
of a processor.

Add a expire counter there. If we have to update per zone or global vm
statistics then assume that the pageset will require subsequent draining.

The expire counter will be decremented on each vm stats update pass until
it reaches zero. Then we will drain one batch from the pageset. The
draining will cause vm counter updates which will then cause another
expiration until the pcp is empty. So we will drain a batch every 3 seconds.

Note that remote node draining is a somewhat esoteric feature that is
required on large NUMA systems because otherwise significant portions of
system memory can become trapped in pcp queues. The number of pcp is
determined by the number of processors and nodes in a system.
A system with 4 processors and 2 nodes has 8 pcps which is okay.
But a system with 1024 processors and 512 nodes has 512k pcps with a high
potential for large amount of memory being caught in them.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/gfp.h    |    6 ---
 include/linux/mmzone.h |    3 +
 mm/page_alloc.c        |   45 ++++++++------------------
 mm/slab.c              |    6 ---
 mm/slub.c              |   84 -------------------------------------------------
 mm/vmstat.c            |   54 ++++++++++++++++++++++++++++---
 6 files changed, 67 insertions(+), 131 deletions(-)

Index: linux-2.6.21-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.21-mm1.orig/include/linux/gfp.h	2007-05-05 09:58:56.000000000 -0700
+++ linux-2.6.21-mm1/include/linux/gfp.h	2007-05-05 10:10:41.000000000 -0700
@@ -197,10 +197,6 @@ extern void FASTCALL(free_cold_page(stru
 #define free_page(addr) free_pages((addr),0)
 
 void page_alloc_init(void);
-#ifdef CONFIG_NUMA
-void drain_node_pages(int node);
-#else
-static inline void drain_node_pages(int node) { };
-#endif
+void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
 
 #endif /* __LINUX_GFP_H */
Index: linux-2.6.21-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.21-mm1.orig/include/linux/mmzone.h	2007-05-05 09:58:56.000000000 -0700
+++ linux-2.6.21-mm1/include/linux/mmzone.h	2007-05-05 10:10:41.000000000 -0700
@@ -104,6 +104,9 @@ struct per_cpu_pages {
 
 struct per_cpu_pageset {
 	struct per_cpu_pages pcp[2];	/* 0: hot.  1: cold */
+#ifdef CONFIG_NUMA
+	s8 expire;
+#endif
 #ifdef CONFIG_SMP
 	s8 stat_threshold;
 	s8 vm_stat_diff[NR_VM_ZONE_STAT_ITEMS];
Index: linux-2.6.21-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/page_alloc.c	2007-05-05 09:58:56.000000000 -0700
+++ linux-2.6.21-mm1/mm/page_alloc.c	2007-05-05 10:10:41.000000000 -0700
@@ -933,43 +933,26 @@ static void __init setup_nr_node_ids(voi
 
 #ifdef CONFIG_NUMA
 /*
- * Called from the slab reaper to drain pagesets on a particular node that
- * belongs to the currently executing processor.
+ * Called from the vmstat counter updater to drain pagesets of this
+ * currently executing processor on remote nodes after they have
+ * expired.
+ *
  * Note that this function must be called with the thread pinned to
  * a single processor.
  */
-void drain_node_pages(int nodeid)
+void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp)
 {
-	int i;
-	enum zone_type z;
 	unsigned long flags;
+	int to_drain;
 
-	for (z = 0; z < MAX_NR_ZONES; z++) {
-		struct zone *zone = NODE_DATA(nodeid)->node_zones + z;
-		struct per_cpu_pageset *pset;
-
-		if (!populated_zone(zone))
-			continue;
-
-		pset = zone_pcp(zone, smp_processor_id());
-		for (i = 0; i < ARRAY_SIZE(pset->pcp); i++) {
-			struct per_cpu_pages *pcp;
-
-			pcp = &pset->pcp[i];
-			if (pcp->count) {
-				int to_drain;
-
-				local_irq_save(flags);
-				if (pcp->count >= pcp->batch)
-					to_drain = pcp->batch;
-				else
-					to_drain = pcp->count;
-				free_pages_bulk(zone, to_drain, &pcp->list, 0);
-				pcp->count -= to_drain;
-				local_irq_restore(flags);
-			}
-		}
-	}
+	local_irq_save(flags);
+	if (pcp->count >= pcp->batch)
+		to_drain = pcp->batch;
+	else
+		to_drain = pcp->count;
+	free_pages_bulk(zone, to_drain, &pcp->list, 0);
+	pcp->count -= to_drain;
+	local_irq_restore(flags);
 }
 #endif
 
Index: linux-2.6.21-mm1/mm/slab.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/slab.c	2007-05-05 09:58:56.000000000 -0700
+++ linux-2.6.21-mm1/mm/slab.c	2007-05-05 10:10:41.000000000 -0700
@@ -928,12 +928,6 @@ static void next_reap_node(void)
 {
 	int node = __get_cpu_var(reap_node);
 
-	/*
-	 * Also drain per cpu pages on remote zones
-	 */
-	if (node != numa_node_id())
-		drain_node_pages(node);
-
 	node = next_node(node, node_online_map);
 	if (unlikely(node >= MAX_NUMNODES))
 		node = first_node(node_online_map);
Index: linux-2.6.21-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/slub.c	2007-05-05 09:58:56.000000000 -0700
+++ linux-2.6.21-mm1/mm/slub.c	2007-05-05 10:10:41.000000000 -0700
@@ -2462,90 +2462,6 @@ static struct notifier_block __cpuinitda
 
 #endif
 
-#ifdef CONFIG_NUMA
-
-/*****************************************************************
- * Generic reaper used to support the page allocator
- * (the cpu slabs are reaped by a per slab workqueue).
- *
- * Maybe move this to the page allocator?
- ****************************************************************/
-
-static DEFINE_PER_CPU(unsigned long, reap_node);
-
-static void init_reap_node(int cpu)
-{
-	int node;
-
-	node = next_node(cpu_to_node(cpu), node_online_map);
-	if (node == MAX_NUMNODES)
-		node = first_node(node_online_map);
-
-	__get_cpu_var(reap_node) = node;
-}
-
-static void next_reap_node(void)
-{
-	int node = __get_cpu_var(reap_node);
-
-	/*
-	 * Also drain per cpu pages on remote zones
-	 */
-	if (node != numa_node_id())
-		drain_node_pages(node);
-
-	node = next_node(node, node_online_map);
-	if (unlikely(node >= MAX_NUMNODES))
-		node = first_node(node_online_map);
-	__get_cpu_var(reap_node) = node;
-}
-#else
-#define init_reap_node(cpu) do { } while (0)
-#define next_reap_node(void) do { } while (0)
-#endif
-
-#define REAPTIMEOUT_CPUC	(2*HZ)
-
-#ifdef CONFIG_SMP
-static DEFINE_PER_CPU(struct delayed_work, reap_work);
-
-static void cache_reap(struct work_struct *unused)
-{
-	next_reap_node();
-	schedule_delayed_work(&__get_cpu_var(reap_work),
-				      REAPTIMEOUT_CPUC);
-}
-
-static void __devinit start_cpu_timer(int cpu)
-{
-	struct delayed_work *reap_work = &per_cpu(reap_work, cpu);
-
-	/*
-	 * When this gets called from do_initcalls via cpucache_init(),
-	 * init_workqueues() has already run, so keventd will be setup
-	 * at that time.
-	 */
-	if (keventd_up() && reap_work->work.func == NULL) {
-		init_reap_node(cpu);
-		INIT_DELAYED_WORK(reap_work, cache_reap);
-		schedule_delayed_work_on(cpu, reap_work, HZ + 3 * cpu);
-	}
-}
-
-static int __init cpucache_init(void)
-{
-	int cpu;
-
-	/*
-	 * Register the timers that drain pcp pages and update vm statistics
-	 */
-	for_each_online_cpu(cpu)
-		start_cpu_timer(cpu);
-	return 0;
-}
-__initcall(cpucache_init);
-#endif
-
 #ifdef SLUB_RESILIENCY_TEST
 static unsigned long validate_slab_cache(struct kmem_cache *s);
 
Index: linux-2.6.21-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/vmstat.c	2007-05-05 09:58:56.000000000 -0700
+++ linux-2.6.21-mm1/mm/vmstat.c	2007-05-05 10:10:41.000000000 -0700
@@ -281,6 +281,17 @@ EXPORT_SYMBOL(dec_zone_page_state);
 
 /*
  * Update the zone counters for one cpu.
+ *
+ * Note that refresh_cpu_vm_stats strives to only access
+ * node local memory. The per cpu pagesets on remote zones are placed
+ * in the memory local to the processor using that pageset. So the
+ * loop over all zones will access a series of cachelines local to
+ * the processor.
+ *
+ * The call to zone_page_state_add updates the cachelines with the
+ * statistics in the remote zone struct as well as the global cachelines
+ * with the global counters. These could cause remote node cache line
+ * bouncing and will have to be only done when necessary.
  */
 void refresh_cpu_vm_stats(int cpu)
 {
@@ -289,21 +300,54 @@ void refresh_cpu_vm_stats(int cpu)
 	unsigned long flags;
 
 	for_each_zone(zone) {
-		struct per_cpu_pageset *pcp;
+		struct per_cpu_pageset *p;
 
 		if (!populated_zone(zone))
 			continue;
 
-		pcp = zone_pcp(zone, cpu);
+		p = zone_pcp(zone, cpu);
 
 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
-			if (pcp->vm_stat_diff[i]) {
+			if (p->vm_stat_diff[i]) {
 				local_irq_save(flags);
-				zone_page_state_add(pcp->vm_stat_diff[i],
+				zone_page_state_add(p->vm_stat_diff[i],
 					zone, i);
-				pcp->vm_stat_diff[i] = 0;
+				p->vm_stat_diff[i] = 0;
+#ifdef CONFIG_NUMA
+				/* 3 seconds idle till flush */
+				p->expire = 3;
+#endif
 				local_irq_restore(flags);
 			}
+#ifdef CONFIG_NUMA
+		/*
+		 * Deal with draining the remote pageset of this
+		 * processor
+		 *
+		 * Check if there are pages remaining in this pageset
+		 * if not then there is nothing to expire.
+		 */
+		if (!p->expire || (!p->pcp[0].count && !p->pcp[1].count))
+			continue;
+
+		/*
+		 * We never drain zones local to this processor.
+		 */
+		if (zone_to_nid(zone) == numa_node_id()) {
+			p->expire = 0;
+			continue;
+		}
+
+		p->expire--;
+		if (p->expire)
+			continue;
+
+		if (p->pcp[0].count)
+			drain_zone_pages(zone, p->pcp + 0);
+
+		if (p->pcp[1].count)
+			drain_zone_pages(zone, p->pcp + 1);
+#endif
 	}
 }
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
