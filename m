Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 562616B0268
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 17:15:36 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e128so96161wmg.1
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 14:15:36 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 107si3914051wrb.80.2017.11.30.14.15.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 14:15:34 -0800 (PST)
Date: Thu, 30 Nov 2017 14:15:31 -0800
From: akpm@linux-foundation.org
Subject: [patch 07/15] mm: memcontrol: fix excessive complexity in
 memory.stat reporting
Message-ID: <5a208303.hxMsAOT0gjSsd0Gf%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.com, vdavydov.dev@gmail.com

From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mm: memcontrol: fix excessive complexity in memory.stat reporting

We've seen memory.stat reads in top-level cgroups take up to fourteen
seconds during a userspace bug that created tens of thousands of ghost
cgroups pinned by lingering page cache.

Even with a more reasonable number of cgroups, aggregating memory.stat is
unnecessarily heavy.  The complexity is this:

	nr_cgroups * nr_stat_items * nr_possible_cpus

where the stat items are ~70 at this point.  With 128 cgroups and 128 CPUs
- decent, not enormous setups - reading the top-level memory.stat has to
aggregate over a million per-cpu counters.  This doesn't scale.

Instead of spreading the source of truth across all CPUs, use the per-cpu
counters merely to batch updates to shared atomic counters.

This is the same as the per-cpu stocks we use for charging memory to the
shared atomic page_counters, and also the way the global vmstat counters
are implemented.

Vmstat has elaborate spilling thresholds that depend on the number of
CPUs, amount of memory, and memory pressure - carefully balancing the cost
of counter updates with the amount of per-cpu error.  That's because the
vmstat counters are system-wide, but also used for decisions inside the
kernel (e.g.  NR_FREE_PAGES in the allocator).  Neither is true for the
memory controller.

Use the same static batch size we already use for page_counter updates
during charging.  The per-cpu error in the stats will be 128k, which is an
acceptable ratio of cores to memory accounting granularity.

Link: http://lkml.kernel.org/r/20171103153336.24044-3-hannes@cmpxchg.org
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/memcontrol.h |   96 +++++++++++++++++++++------------
 mm/memcontrol.c            |  101 +++++++++++++++++------------------
 2 files changed, 113 insertions(+), 84 deletions(-)

diff -puN include/linux/memcontrol.h~mm-memcontrol-fix-excessive-complexity-in-memorystat-reporting include/linux/memcontrol.h
--- a/include/linux/memcontrol.h~mm-memcontrol-fix-excessive-complexity-in-memorystat-reporting
+++ a/include/linux/memcontrol.h
@@ -108,7 +108,10 @@ struct lruvec_stat {
  */
 struct mem_cgroup_per_node {
 	struct lruvec		lruvec;
-	struct lruvec_stat __percpu *lruvec_stat;
+
+	struct lruvec_stat __percpu *lruvec_stat_cpu;
+	atomic_long_t		lruvec_stat[NR_VM_NODE_STAT_ITEMS];
+
 	unsigned long		lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
 
 	struct mem_cgroup_reclaim_iter	iter[DEF_PRIORITY + 1];
@@ -227,10 +230,10 @@ struct mem_cgroup {
 	spinlock_t		move_lock;
 	struct task_struct	*move_lock_task;
 	unsigned long		move_lock_flags;
-	/*
-	 * percpu counter.
-	 */
-	struct mem_cgroup_stat_cpu __percpu *stat;
+
+	struct mem_cgroup_stat_cpu __percpu *stat_cpu;
+	atomic_long_t		stat[MEMCG_NR_STAT];
+	atomic_long_t		events[MEMCG_NR_EVENTS];
 
 	unsigned long		socket_pressure;
 
@@ -265,6 +268,12 @@ struct mem_cgroup {
 	/* WARNING: nodeinfo must be the last member here */
 };
 
+/*
+ * size of first charge trial. "32" comes from vmscan.c's magic value.
+ * TODO: maybe necessary to use big numbers in big irons.
+ */
+#define MEMCG_CHARGE_BATCH 32U
+
 extern struct mem_cgroup *root_mem_cgroup;
 
 static inline bool mem_cgroup_disabled(void)
@@ -485,32 +494,38 @@ void unlock_page_memcg(struct page *page
 static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
 					     int idx)
 {
-	long val = 0;
-	int cpu;
-
-	for_each_possible_cpu(cpu)
-		val += per_cpu(memcg->stat->count[idx], cpu);
-
-	if (val < 0)
-		val = 0;
-
-	return val;
+	long x = atomic_long_read(&memcg->stat[idx]);
+#ifdef CONFIG_SMP
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
 }
 
 /* idx can be of type enum memcg_stat_item or node_stat_item */
 static inline void __mod_memcg_state(struct mem_cgroup *memcg,
 				     int idx, int val)
 {
-	if (!mem_cgroup_disabled())
-		__this_cpu_add(memcg->stat->count[idx], val);
+	long x;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	x = val + __this_cpu_read(memcg->stat_cpu->count[idx]);
+	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
+		atomic_long_add(x, &memcg->stat[idx]);
+		x = 0;
+	}
+	__this_cpu_write(memcg->stat_cpu->count[idx], x);
 }
 
 /* idx can be of type enum memcg_stat_item or node_stat_item */
 static inline void mod_memcg_state(struct mem_cgroup *memcg,
 				   int idx, int val)
 {
-	if (!mem_cgroup_disabled())
-		this_cpu_add(memcg->stat->count[idx], val);
+	preempt_disable();
+	__mod_memcg_state(memcg, idx, val);
+	preempt_enable();
 }
 
 /**
@@ -548,26 +563,25 @@ static inline unsigned long lruvec_page_
 					      enum node_stat_item idx)
 {
 	struct mem_cgroup_per_node *pn;
-	long val = 0;
-	int cpu;
+	long x;
 
 	if (mem_cgroup_disabled())
 		return node_page_state(lruvec_pgdat(lruvec), idx);
 
 	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
-	for_each_possible_cpu(cpu)
-		val += per_cpu(pn->lruvec_stat->count[idx], cpu);
-
-	if (val < 0)
-		val = 0;
-
-	return val;
+	x = atomic_long_read(&pn->lruvec_stat[idx]);
+#ifdef CONFIG_SMP
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
 }
 
 static inline void __mod_lruvec_state(struct lruvec *lruvec,
 				      enum node_stat_item idx, int val)
 {
 	struct mem_cgroup_per_node *pn;
+	long x;
 
 	/* Update node */
 	__mod_node_page_state(lruvec_pgdat(lruvec), idx, val);
@@ -581,7 +595,12 @@ static inline void __mod_lruvec_state(st
 	__mod_memcg_state(pn->memcg, idx, val);
 
 	/* Update lruvec */
-	__this_cpu_add(pn->lruvec_stat->count[idx], val);
+	x = val + __this_cpu_read(pn->lruvec_stat_cpu->count[idx]);
+	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
+		atomic_long_add(x, &pn->lruvec_stat[idx]);
+		x = 0;
+	}
+	__this_cpu_write(pn->lruvec_stat_cpu->count[idx], x);
 }
 
 static inline void mod_lruvec_state(struct lruvec *lruvec,
@@ -624,16 +643,25 @@ unsigned long mem_cgroup_soft_limit_recl
 static inline void __count_memcg_events(struct mem_cgroup *memcg,
 					int idx, unsigned long count)
 {
-	if (!mem_cgroup_disabled())
-		__this_cpu_add(memcg->stat->events[idx], count);
+	unsigned long x;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	x = count + __this_cpu_read(memcg->stat_cpu->events[idx]);
+	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
+		atomic_long_add(x, &memcg->events[idx]);
+		x = 0;
+	}
+	__this_cpu_write(memcg->stat_cpu->events[idx], x);
 }
 
-/* idx can be of type enum memcg_event_item or vm_event_item */
 static inline void count_memcg_events(struct mem_cgroup *memcg,
 				      int idx, unsigned long count)
 {
-	if (!mem_cgroup_disabled())
-		this_cpu_add(memcg->stat->events[idx], count);
+	preempt_disable();
+	__count_memcg_events(memcg, idx, count);
+	preempt_enable();
 }
 
 /* idx can be of type enum memcg_event_item or vm_event_item */
diff -puN mm/memcontrol.c~mm-memcontrol-fix-excessive-complexity-in-memorystat-reporting mm/memcontrol.c
--- a/mm/memcontrol.c~mm-memcontrol-fix-excessive-complexity-in-memorystat-reporting
+++ a/mm/memcontrol.c
@@ -542,39 +542,10 @@ mem_cgroup_largest_soft_limit_node(struc
 	return mz;
 }
 
-/*
- * Return page count for single (non recursive) @memcg.
- *
- * Implementation Note: reading percpu statistics for memcg.
- *
- * Both of vmstat[] and percpu_counter has threshold and do periodic
- * synchronization to implement "quick" read. There are trade-off between
- * reading cost and precision of value. Then, we may have a chance to implement
- * a periodic synchronization of counter in memcg's counter.
- *
- * But this _read() function is used for user interface now. The user accounts
- * memory usage by memory cgroup and he _always_ requires exact value because
- * he accounts memory. Even if we provide quick-and-fuzzy read, we always
- * have to visit all online cpus and make sum. So, for now, unnecessary
- * synchronization is not implemented. (just implemented for cpu hotplug)
- *
- * If there are kernel internal actions which can make use of some not-exact
- * value, and reading all cpu value can be performance bottleneck in some
- * common workload, threshold and synchronization as vmstat[] should be
- * implemented.
- *
- * The parameter idx can be of type enum memcg_event_item or vm_event_item.
- */
-
 static unsigned long memcg_sum_events(struct mem_cgroup *memcg,
 				      int event)
 {
-	unsigned long val = 0;
-	int cpu;
-
-	for_each_possible_cpu(cpu)
-		val += per_cpu(memcg->stat->events[event], cpu);
-	return val;
+	return atomic_long_read(&memcg->events[event]);
 }
 
 static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
@@ -606,7 +577,7 @@ static void mem_cgroup_charge_statistics
 		nr_pages = -nr_pages; /* for event */
 	}
 
-	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
+	__this_cpu_add(memcg->stat_cpu->nr_page_events, nr_pages);
 }
 
 unsigned long mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
@@ -642,8 +613,8 @@ static bool mem_cgroup_event_ratelimit(s
 {
 	unsigned long val, next;
 
-	val = __this_cpu_read(memcg->stat->nr_page_events);
-	next = __this_cpu_read(memcg->stat->targets[target]);
+	val = __this_cpu_read(memcg->stat_cpu->nr_page_events);
+	next = __this_cpu_read(memcg->stat_cpu->targets[target]);
 	/* from time_after() in jiffies.h */
 	if ((long)(next - val) < 0) {
 		switch (target) {
@@ -659,7 +630,7 @@ static bool mem_cgroup_event_ratelimit(s
 		default:
 			break;
 		}
-		__this_cpu_write(memcg->stat->targets[target], next);
+		__this_cpu_write(memcg->stat_cpu->targets[target], next);
 		return true;
 	}
 	return false;
@@ -1707,11 +1678,6 @@ void unlock_page_memcg(struct page *page
 }
 EXPORT_SYMBOL(unlock_page_memcg);
 
-/*
- * size of first charge trial. "32" comes from vmscan.c's magic value.
- * TODO: maybe necessary to use big numbers in big irons.
- */
-#define CHARGE_BATCH	32U
 struct memcg_stock_pcp {
 	struct mem_cgroup *cached; /* this never be root cgroup */
 	unsigned int nr_pages;
@@ -1739,7 +1705,7 @@ static bool consume_stock(struct mem_cgr
 	unsigned long flags;
 	bool ret = false;
 
-	if (nr_pages > CHARGE_BATCH)
+	if (nr_pages > MEMCG_CHARGE_BATCH)
 		return ret;
 
 	local_irq_save(flags);
@@ -1808,7 +1774,7 @@ static void refill_stock(struct mem_cgro
 	}
 	stock->nr_pages += nr_pages;
 
-	if (stock->nr_pages > CHARGE_BATCH)
+	if (stock->nr_pages > MEMCG_CHARGE_BATCH)
 		drain_stock(stock);
 
 	local_irq_restore(flags);
@@ -1858,9 +1824,44 @@ static void drain_all_stock(struct mem_c
 static int memcg_hotplug_cpu_dead(unsigned int cpu)
 {
 	struct memcg_stock_pcp *stock;
+	struct mem_cgroup *memcg;
 
 	stock = &per_cpu(memcg_stock, cpu);
 	drain_stock(stock);
+
+	for_each_mem_cgroup(memcg) {
+		int i;
+
+		for (i = 0; i < MEMCG_NR_STAT; i++) {
+			int nid;
+			long x;
+
+			x = __this_cpu_xchg(memcg->stat_cpu->count[i], 0);
+			if (x)
+				atomic_long_add(x, &memcg->stat[i]);
+
+			if (i >= NR_VM_NODE_STAT_ITEMS)
+				continue;
+
+			for_each_node(nid) {
+				struct mem_cgroup_per_node *pn;
+
+				pn = mem_cgroup_nodeinfo(memcg, nid);
+				x = __this_cpu_xchg(pn->lruvec_stat_cpu->count[i], 0);
+				if (x)
+					atomic_long_add(x, &pn->lruvec_stat[i]);
+			}
+		}
+
+		for (i = 0; i < MEMCG_NR_EVENTS; i++) {
+			long x;
+
+			x = __this_cpu_xchg(memcg->stat_cpu->events[i], 0);
+			if (x)
+				atomic_long_add(x, &memcg->events[i]);
+		}
+	}
+
 	return 0;
 }
 
@@ -1881,7 +1882,7 @@ static void high_work_func(struct work_s
 	struct mem_cgroup *memcg;
 
 	memcg = container_of(work, struct mem_cgroup, high_work);
-	reclaim_high(memcg, CHARGE_BATCH, GFP_KERNEL);
+	reclaim_high(memcg, MEMCG_CHARGE_BATCH, GFP_KERNEL);
 }
 
 /*
@@ -1905,7 +1906,7 @@ void mem_cgroup_handle_over_high(void)
 static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 		      unsigned int nr_pages)
 {
-	unsigned int batch = max(CHARGE_BATCH, nr_pages);
+	unsigned int batch = max(MEMCG_CHARGE_BATCH, nr_pages);
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct mem_cgroup *mem_over_limit;
 	struct page_counter *counter;
@@ -4161,8 +4162,8 @@ static int alloc_mem_cgroup_per_node_inf
 	if (!pn)
 		return 1;
 
-	pn->lruvec_stat = alloc_percpu(struct lruvec_stat);
-	if (!pn->lruvec_stat) {
+	pn->lruvec_stat_cpu = alloc_percpu(struct lruvec_stat);
+	if (!pn->lruvec_stat_cpu) {
 		kfree(pn);
 		return 1;
 	}
@@ -4180,7 +4181,7 @@ static void free_mem_cgroup_per_node_inf
 {
 	struct mem_cgroup_per_node *pn = memcg->nodeinfo[node];
 
-	free_percpu(pn->lruvec_stat);
+	free_percpu(pn->lruvec_stat_cpu);
 	kfree(pn);
 }
 
@@ -4190,7 +4191,7 @@ static void __mem_cgroup_free(struct mem
 
 	for_each_node(node)
 		free_mem_cgroup_per_node_info(memcg, node);
-	free_percpu(memcg->stat);
+	free_percpu(memcg->stat_cpu);
 	kfree(memcg);
 }
 
@@ -4219,8 +4220,8 @@ static struct mem_cgroup *mem_cgroup_all
 	if (memcg->id.id < 0)
 		goto fail;
 
-	memcg->stat = alloc_percpu(struct mem_cgroup_stat_cpu);
-	if (!memcg->stat)
+	memcg->stat_cpu = alloc_percpu(struct mem_cgroup_stat_cpu);
+	if (!memcg->stat_cpu)
 		goto fail;
 
 	for_each_node(node)
@@ -5638,7 +5639,7 @@ static void uncharge_batch(const struct
 	__mod_memcg_state(ug->memcg, MEMCG_RSS_HUGE, -ug->nr_huge);
 	__mod_memcg_state(ug->memcg, NR_SHMEM, -ug->nr_shmem);
 	__count_memcg_events(ug->memcg, PGPGOUT, ug->pgpgout);
-	__this_cpu_add(ug->memcg->stat->nr_page_events, nr_pages);
+	__this_cpu_add(ug->memcg->stat_cpu->nr_page_events, nr_pages);
 	memcg_check_events(ug->memcg, ug->dummy_page);
 	local_irq_restore(flags);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
