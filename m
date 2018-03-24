Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01EB46B0024
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 12:09:37 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id l188so2198736ywd.6
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 09:09:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p11-v6sor2952874ybc.158.2018.03.24.09.09.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 09:09:35 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 2/3] mm: memcontrol: Use cgroup_rstat for stat accounting
Date: Sat, 24 Mar 2018 09:09:00 -0700
Message-Id: <20180324160901.512135-3-tj@kernel.org>
In-Reply-To: <20180324160901.512135-1-tj@kernel.org>
References: <20180324160901.512135-1-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com
Cc: guro@fb.com, riel@surriel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>

To fix scalability issue, a983b5ebee57 ("mm: memcontrol: fix excessive
complexity in memory.stat reporting") made the per-cpu counters
batch-overflow into the global one instead of summing them up on
reads.

The approach didn't for events and the previous patch switched event
accounting to cgroup_rstat.  Unlike events, it works for stat
accounting but switching to cgroup_rstat has the following benefits
while keeping computational complexity low.

* More accurate accounting.  The accumulated per-cpu errors with the
  batch approach could add up and cause unintended results with
  extreme configurations (e.g. balance_dirty_pages misbehavior with
  very low dirty ratio in a cgroup with a low memory limit).

* Consistency with event accounting.

* Cheaper and simpler access to hierarchical stats.

This patch converts stat accounting to use cgroup_rstat.

* mem_cgroup_stat_cpu->last_count[] and mem_cgroup->pending_stat[] are
  added to track propagation.  As memcg makes use of both local and
  hierarchical stats, mem_cgroup->tree_stat[] is added to track
  hierarchical numbers.

* An rstat flush wrapper, memcg_stat_flush(), is added for memcg stat
  consumers outside memcg proper.

* Accessors are updated / added.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memcontrol.h | 74 +++++++++++++++++++++++++++++---------
 mm/memcontrol.c            | 90 +++++++++++++++++++++++++---------------------
 mm/vmscan.c                |  4 ++-
 3 files changed, 110 insertions(+), 58 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f1afbf6..0cf6d5a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -93,6 +93,7 @@ struct mem_cgroup_stat_cpu {
 	unsigned long targets[MEM_CGROUP_NTARGETS];
 
 	/* for cgroup rstat delta calculation */
+	unsigned long last_count[MEMCG_NR_STAT];
 	unsigned long last_events[MEMCG_NR_EVENTS];
 };
 
@@ -235,9 +236,12 @@ struct mem_cgroup {
 	unsigned long		move_lock_flags;
 
 	struct mem_cgroup_stat_cpu __percpu *stat_cpu;
-	atomic_long_t		stat[MEMCG_NR_STAT];
 
-	/* events is managed by cgroup rstat */
+	/* stat and events are managed by cgroup rstat */
+	long			stat[MEMCG_NR_STAT];		/* local */
+	long			tree_stat[MEMCG_NR_STAT];	/* subtree */
+	long			pending_stat[MEMCG_NR_STAT];	/* propagation */
+
 	unsigned long long	events[MEMCG_NR_EVENTS];	/* local */
 	unsigned long long	tree_events[MEMCG_NR_EVENTS];	/* subtree */
 	unsigned long long	pending_events[MEMCG_NR_EVENTS];/* propagation */
@@ -497,11 +501,32 @@ struct mem_cgroup *lock_page_memcg(struct page *page);
 void __unlock_page_memcg(struct mem_cgroup *memcg);
 void unlock_page_memcg(struct page *page);
 
-/* idx can be of type enum memcg_stat_item or node_stat_item */
-static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
-					     int idx)
+/**
+ * memcg_stat_flush - flush stat in a memcg's subtree
+ * @memcg: target memcg
+ *
+ * Flush cgroup_rstat statistics in @memcg's subtree.  This brings @memcg's
+ * statistics up-to-date.
+ */
+static inline void memcg_stat_flush(struct mem_cgroup *memcg)
 {
-	long x = atomic_long_read(&memcg->stat[idx]);
+	if (!memcg)
+		memcg = root_mem_cgroup;
+	cgroup_rstat_flush(memcg->css.cgroup);
+}
+
+/**
+ * __memcg_page_state - read page state counter without brininging it up-to-date
+ * @memcg: target memcg
+ * @idx: page state item to read
+ *
+ * Read a memcg page state counter.  @idx can be of type enum
+ * memcg_stat_item or node_stat_item.  The caller must haved flushed by
+ * calling memcg_stat_flush() to bring the counter up-to-date.
+ */
+static inline unsigned long __memcg_page_state(struct mem_cgroup *memcg, int idx)
+{
+	long x = READ_ONCE(memcg->stat[idx]);
 #ifdef CONFIG_SMP
 	if (x < 0)
 		x = 0;
@@ -509,21 +534,30 @@ static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
 	return x;
 }
 
+/**
+ * memcg_page_state - read page state counter after bringing it up-to-date
+ * @memcg: target memcg
+ * @idx: page state item to read
+ *
+ * __memcg_page_state() with implied flushing.  When reading multiple
+ * counters in sequence, flushing explicitly and using __memcg_page_state()
+ * is cheaper.
+ */
+static inline unsigned long memcg_page_state(struct mem_cgroup *memcg, int idx)
+{
+	memcg_stat_flush(memcg);
+	return __memcg_page_state(memcg, idx);
+}
+
 /* idx can be of type enum memcg_stat_item or node_stat_item */
 static inline void __mod_memcg_state(struct mem_cgroup *memcg,
 				     int idx, int val)
 {
-	long x;
-
 	if (mem_cgroup_disabled())
 		return;
 
-	x = val + __this_cpu_read(memcg->stat_cpu->count[idx]);
-	if (unlikely(abs(x) > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &memcg->stat[idx]);
-		x = 0;
-	}
-	__this_cpu_write(memcg->stat_cpu->count[idx], x);
+	__this_cpu_add(memcg->stat_cpu->count[idx], val);
+	cgroup_rstat_updated(memcg->css.cgroup, smp_processor_id());
 }
 
 /* idx can be of type enum memcg_stat_item or node_stat_item */
@@ -895,8 +929,16 @@ static inline bool mem_cgroup_oom_synchronize(bool wait)
 	return false;
 }
 
-static inline unsigned long memcg_page_state(struct mem_cgroup *memcg,
-					     int idx)
+static inline void memcg_stat_flush(struct mem_cgroup *memcg)
+{
+}
+
+static inline unsigned long __memcg_page_state(struct mem_cgroup *memcg, int idx)
+{
+	return 0;
+}
+
+static inline unsigned long memcg_page_state(struct mem_cgroup *memcg, int idx)
 {
 	return 0;
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 82cb532..03d1b30 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -307,6 +307,16 @@ struct workqueue_struct *memcg_kmem_cache_wq;
 
 #endif /* !CONFIG_SLOB */
 
+static unsigned long __memcg_tree_stat(struct mem_cgroup *memcg, int idx)
+{
+	long x = READ_ONCE(memcg->tree_stat[idx]);
+#ifdef CONFIG_SMP
+	if (x < 0)
+		x = 0;
+#endif
+	return x;
+}
+
 /**
  * mem_cgroup_css_from_page - css of the memcg associated with a page
  * @page: page of interest
@@ -1150,6 +1160,8 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 		K((u64)page_counter_read(&memcg->kmem)),
 		K((u64)memcg->kmem.limit), memcg->kmem.failcnt);
 
+	memcg_stat_flush(memcg);
+
 	for_each_mem_cgroup_tree(iter, memcg) {
 		pr_info("Memory cgroup stats for ");
 		pr_cont_cgroup_path(iter->css.cgroup);
@@ -1159,7 +1171,7 @@ void mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 			if (memcg1_stats[i] == MEMCG_SWAP && !do_swap_account)
 				continue;
 			pr_cont(" %s:%luKB", memcg1_stat_names[i],
-				K(memcg_page_state(iter, memcg1_stats[i])));
+				K(__memcg_page_state(iter, memcg1_stats[i])));
 		}
 
 		for (i = 0; i < NR_LRU_LISTS; i++)
@@ -1812,17 +1824,10 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 	for_each_mem_cgroup(memcg) {
 		int i;
 
-		for (i = 0; i < MEMCG_NR_STAT; i++) {
+		for (i = 0; i < NR_VM_NODE_STAT_ITEMS; i++) {
 			int nid;
 			long x;
 
-			x = this_cpu_xchg(memcg->stat_cpu->count[i], 0);
-			if (x)
-				atomic_long_add(x, &memcg->stat[i]);
-
-			if (i >= NR_VM_NODE_STAT_ITEMS)
-				continue;
-
 			for_each_node(nid) {
 				struct mem_cgroup_per_node *pn;
 
@@ -2656,32 +2661,16 @@ static int mem_cgroup_hierarchy_write(struct cgroup_subsys_state *css,
 	return retval;
 }
 
-static void tree_stat(struct mem_cgroup *memcg, unsigned long *stat)
-{
-	struct mem_cgroup *iter;
-	int i;
-
-	memset(stat, 0, sizeof(*stat) * MEMCG_NR_STAT);
-
-	for_each_mem_cgroup_tree(iter, memcg) {
-		for (i = 0; i < MEMCG_NR_STAT; i++)
-			stat[i] += memcg_page_state(iter, i);
-	}
-}
-
 static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
 	unsigned long val = 0;
 
 	if (mem_cgroup_is_root(memcg)) {
-		struct mem_cgroup *iter;
-
-		for_each_mem_cgroup_tree(iter, memcg) {
-			val += memcg_page_state(iter, MEMCG_CACHE);
-			val += memcg_page_state(iter, MEMCG_RSS);
-			if (swap)
-				val += memcg_page_state(iter, MEMCG_SWAP);
-		}
+		memcg_stat_flush(memcg);
+		val += __memcg_tree_stat(memcg, MEMCG_CACHE);
+		val += __memcg_tree_stat(memcg, MEMCG_RSS);
+		if (swap)
+			val += __memcg_tree_stat(memcg, MEMCG_SWAP);
 	} else {
 		if (!swap)
 			val = page_counter_read(&memcg->memory);
@@ -3086,7 +3075,7 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
 			continue;
 		seq_printf(m, "%s %lu\n", memcg1_stat_names[i],
-			   memcg_page_state(memcg, memcg1_stats[i]) *
+			   __memcg_page_state(memcg, memcg1_stats[i]) *
 			   PAGE_SIZE);
 	}
 
@@ -3111,14 +3100,11 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 			   (u64)memsw * PAGE_SIZE);
 
 	for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
-		unsigned long long val = 0;
-
 		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
 			continue;
-		for_each_mem_cgroup_tree(mi, memcg)
-			val += memcg_page_state(mi, memcg1_stats[i]) *
-			PAGE_SIZE;
-		seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i], val);
+		seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i],
+			   (u64)__memcg_tree_stat(memcg, memcg1_stats[i]) *
+			   PAGE_SIZE);
 	}
 
 	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
@@ -3592,10 +3578,16 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 	struct mem_cgroup *memcg = mem_cgroup_from_css(wb->memcg_css);
 	struct mem_cgroup *parent;
 
-	*pdirty = memcg_page_state(memcg, NR_FILE_DIRTY);
+	/*
+	 * This function is called under a spinlock.  Use the irq-safe
+	 * version instead of memcg_stat_flush().
+	 */
+	cgroup_rstat_flush_irqsafe(memcg->css.cgroup);
+
+	*pdirty = __memcg_page_state(memcg, NR_FILE_DIRTY);
 
 	/* this should eventually include NR_UNSTABLE_NFS */
-	*pwriteback = memcg_page_state(memcg, NR_WRITEBACK);
+	*pwriteback = __memcg_page_state(memcg, NR_WRITEBACK);
 	*pfilepages = mem_cgroup_nr_lru_pages(memcg, (1 << LRU_INACTIVE_FILE) |
 						     (1 << LRU_ACTIVE_FILE));
 	*pheadroom = PAGE_COUNTER_MAX;
@@ -4310,6 +4302,23 @@ static void mem_cgroup_css_rstat_flush(struct cgroup_subsys_state *css, int cpu)
 	unsigned long v, delta;
 	int i;
 
+	for (i = 0; i < MEMCG_NR_STAT; i++) {
+		/* calculate the delta to propagate and add to local stat */
+		v = READ_ONCE(statc->count[i]);
+		delta = v - statc->last_count[i];
+		statc->last_count[i] = v;
+		memcg->stat[i] += delta;
+
+		/* transfer the pending stat into delta */
+		delta += memcg->pending_stat[i];
+		memcg->pending_stat[i] = 0;
+
+		/* propagate delta into tree stat and parent's pending */
+		memcg->tree_stat[i] += delta;
+		if (parent)
+			parent->pending_stat[i] += delta;
+	}
+
 	for (i = 0; i < MEMCG_NR_EVENTS; i++) {
 		/* calculate the delta to propagate and add to local stat */
 		v = READ_ONCE(statc->events[i]);
@@ -5207,7 +5216,7 @@ static int memory_events_show(struct seq_file *m, void *v)
 static int memory_stat_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long stat[MEMCG_NR_STAT];
+	unsigned long *stat = memcg->tree_stat;
 	unsigned long long *events = memcg->tree_events;
 	int i;
 
@@ -5222,7 +5231,6 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	 * Current memory state:
 	 */
 
-	tree_stat(memcg, stat);
 	cgroup_rstat_flush_hold(memcg->css.cgroup);
 
 	seq_printf(m, "anon %llu\n",
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bee5349..29bf99f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2738,13 +2738,15 @@ static void snapshot_refaults(struct mem_cgroup *root_memcg, pg_data_t *pgdat)
 {
 	struct mem_cgroup *memcg;
 
+	memcg_stat_flush(root_memcg);
+
 	memcg = mem_cgroup_iter(root_memcg, NULL, NULL);
 	do {
 		unsigned long refaults;
 		struct lruvec *lruvec;
 
 		if (memcg)
-			refaults = memcg_page_state(memcg, WORKINGSET_ACTIVATE);
+			refaults = __memcg_page_state(memcg, WORKINGSET_ACTIVATE);
 		else
 			refaults = node_page_state(pgdat, WORKINGSET_ACTIVATE);
 
-- 
2.9.5
