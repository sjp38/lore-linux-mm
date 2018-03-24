Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f197.google.com (mail-yb0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7E7EE6B0012
	for <linux-mm@kvack.org>; Sat, 24 Mar 2018 12:09:33 -0400 (EDT)
Received: by mail-yb0-f197.google.com with SMTP id 126-v6so4338715ybd.18
        for <linux-mm@kvack.org>; Sat, 24 Mar 2018 09:09:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c21sor4199036ywb.438.2018.03.24.09.09.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 24 Mar 2018 09:09:32 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/3] mm: memcontrol: Use cgroup_rstat for event accounting
Date: Sat, 24 Mar 2018 09:08:59 -0700
Message-Id: <20180324160901.512135-2-tj@kernel.org>
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

While the approach works for statistics which don't care about
controlled errors, it doesn't work for events.  For example, when a
process in a cgroup is oom killed, a notification is generated on the
memory.events file.  A user reading the file after receiving the
notification must be able to see the increased oom_kill event counter
but often won't be able to due to the per-cpu batching.

The problem the original commit tried to fix was avoiding excessively
high complexity on reads.  This can be solved using cgroup_rstat
instead which has the following properties.

* Per-cpu stat updates with a small bookkeeping overhead.

* Lazy, accurate and on-demand hierarchical stat propagation with the
  complexity of O(number of cgroups which have been active in the
  subtree since last read).

This patch converts event accounting to use cgroup_rstat.

* mem_cgroup_stat_cpu->last_events[] and mem_cgroup->pending_events[]
  are added to track propagation.  As memcg makes use of both local
  and hierarchical stats, mem_cgroup->tree_events[] is added to track
  hierarchical numbers.

* The per-cpu counters are unsigned long and the collected counters
  are unsigned long long.  This makes stat updates simple while
  avoiding overflows in the collected counters on 32bit machines.  The
  existing code used unsigned long longs in some places but didn't
  cover enough to avoid overflows.

* memcg_sum_events() and tree_events() are replaced with direct
  accesses to mem_cgroup->events[] and ->tree_events[].  The accesses
  are wrapped between cgroup_rstat_flush_hold() and
  cgroup_rstat_flush_release().

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Roman Gushchin <guro@fb.com>
Cc: Rik van Riel <riel@surriel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memcontrol.h |  19 ++++----
 mm/memcontrol.c            | 114 ++++++++++++++++++++++++---------------------
 2 files changed, 70 insertions(+), 63 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c46016b..f1afbf6 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -91,6 +91,9 @@ struct mem_cgroup_stat_cpu {
 	unsigned long events[MEMCG_NR_EVENTS];
 	unsigned long nr_page_events;
 	unsigned long targets[MEM_CGROUP_NTARGETS];
+
+	/* for cgroup rstat delta calculation */
+	unsigned long last_events[MEMCG_NR_EVENTS];
 };
 
 struct mem_cgroup_reclaim_iter {
@@ -233,7 +236,11 @@ struct mem_cgroup {
 
 	struct mem_cgroup_stat_cpu __percpu *stat_cpu;
 	atomic_long_t		stat[MEMCG_NR_STAT];
-	atomic_long_t		events[MEMCG_NR_EVENTS];
+
+	/* events is managed by cgroup rstat */
+	unsigned long long	events[MEMCG_NR_EVENTS];	/* local */
+	unsigned long long	tree_events[MEMCG_NR_EVENTS];	/* subtree */
+	unsigned long long	pending_events[MEMCG_NR_EVENTS];/* propagation */
 
 	unsigned long		socket_pressure;
 
@@ -649,17 +656,11 @@ unsigned long mem_cgroup_soft_limit_reclaim(pg_data_t *pgdat, int order,
 static inline void __count_memcg_events(struct mem_cgroup *memcg,
 					int idx, unsigned long count)
 {
-	unsigned long x;
-
 	if (mem_cgroup_disabled())
 		return;
 
-	x = count + __this_cpu_read(memcg->stat_cpu->events[idx]);
-	if (unlikely(x > MEMCG_CHARGE_BATCH)) {
-		atomic_long_add(x, &memcg->events[idx]);
-		x = 0;
-	}
-	__this_cpu_write(memcg->stat_cpu->events[idx], x);
+	__this_cpu_add(memcg->stat_cpu->events[idx], count);
+	cgroup_rstat_updated(memcg->css.cgroup, smp_processor_id());
 }
 
 static inline void count_memcg_events(struct mem_cgroup *memcg,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 670e99b..82cb532 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -542,12 +542,6 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_node *mctz)
 	return mz;
 }
 
-static unsigned long memcg_sum_events(struct mem_cgroup *memcg,
-				      int event)
-{
-	return atomic_long_read(&memcg->events[event]);
-}
-
 static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 					 struct page *page,
 					 bool compound, int nr_pages)
@@ -1838,14 +1832,6 @@ static int memcg_hotplug_cpu_dead(unsigned int cpu)
 					atomic_long_add(x, &pn->lruvec_stat[i]);
 			}
 		}
-
-		for (i = 0; i < MEMCG_NR_EVENTS; i++) {
-			long x;
-
-			x = this_cpu_xchg(memcg->stat_cpu->events[i], 0);
-			if (x)
-				atomic_long_add(x, &memcg->events[i]);
-		}
 	}
 
 	return 0;
@@ -2683,19 +2669,6 @@ static void tree_stat(struct mem_cgroup *memcg, unsigned long *stat)
 	}
 }
 
-static void tree_events(struct mem_cgroup *memcg, unsigned long *events)
-{
-	struct mem_cgroup *iter;
-	int i;
-
-	memset(events, 0, sizeof(*events) * MEMCG_NR_EVENTS);
-
-	for_each_mem_cgroup_tree(iter, memcg) {
-		for (i = 0; i < MEMCG_NR_EVENTS; i++)
-			events[i] += memcg_sum_events(iter, i);
-	}
-}
-
 static unsigned long mem_cgroup_usage(struct mem_cgroup *memcg, bool swap)
 {
 	unsigned long val = 0;
@@ -3107,6 +3080,8 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 	BUILD_BUG_ON(ARRAY_SIZE(memcg1_stat_names) != ARRAY_SIZE(memcg1_stats));
 	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
 
+	cgroup_rstat_flush_hold(memcg->css.cgroup);
+
 	for (i = 0; i < ARRAY_SIZE(memcg1_stats); i++) {
 		if (memcg1_stats[i] == MEMCG_SWAP && !do_memsw_account())
 			continue;
@@ -3116,8 +3091,8 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 	}
 
 	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
-		seq_printf(m, "%s %lu\n", memcg1_event_names[i],
-			   memcg_sum_events(memcg, memcg1_events[i]));
+		seq_printf(m, "%s %llu\n", memcg1_event_names[i],
+			   memcg->events[memcg1_events[i]]);
 
 	for (i = 0; i < NR_LRU_LISTS; i++)
 		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i],
@@ -3146,13 +3121,9 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		seq_printf(m, "total_%s %llu\n", memcg1_stat_names[i], val);
 	}
 
-	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++) {
-		unsigned long long val = 0;
-
-		for_each_mem_cgroup_tree(mi, memcg)
-			val += memcg_sum_events(mi, memcg1_events[i]);
-		seq_printf(m, "total_%s %llu\n", memcg1_event_names[i], val);
-	}
+	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
+		seq_printf(m, "total_%s %llu\n", memcg1_event_names[i],
+			   memcg->tree_events[memcg1_events[i]]);
 
 	for (i = 0; i < NR_LRU_LISTS; i++) {
 		unsigned long long val = 0;
@@ -3185,7 +3156,7 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		seq_printf(m, "recent_scanned_file %lu\n", recent_scanned[1]);
 	}
 #endif
-
+	cgroup_rstat_flush_release();
 	return 0;
 }
 
@@ -3538,9 +3509,13 @@ static int mem_cgroup_oom_control_read(struct seq_file *sf, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(sf));
 
+	cgroup_rstat_flush_hold(memcg->css.cgroup);
+
 	seq_printf(sf, "oom_kill_disable %d\n", memcg->oom_kill_disable);
 	seq_printf(sf, "under_oom %d\n", (bool)memcg->under_oom);
-	seq_printf(sf, "oom_kill %lu\n", memcg_sum_events(memcg, OOM_KILL));
+	seq_printf(sf, "oom_kill %llu\n", memcg->events[OOM_KILL]);
+
+	cgroup_rstat_flush_release();
 	return 0;
 }
 
@@ -4327,6 +4302,32 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 	memcg_wb_domain_size_changed(memcg);
 }
 
+static void mem_cgroup_css_rstat_flush(struct cgroup_subsys_state *css, int cpu)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
+	struct mem_cgroup_stat_cpu *statc = per_cpu_ptr(memcg->stat_cpu, cpu);
+	unsigned long v, delta;
+	int i;
+
+	for (i = 0; i < MEMCG_NR_EVENTS; i++) {
+		/* calculate the delta to propagate and add to local stat */
+		v = READ_ONCE(statc->events[i]);
+		delta = v - statc->last_events[i];
+		statc->last_events[i] = v;
+		memcg->events[i] += delta;
+
+		/* transfer the pending stat into delta */
+		delta += memcg->pending_events[i];
+		memcg->pending_events[i] = 0;
+
+		/* propagate delta into tree stat and parent's pending */
+		memcg->tree_events[i] += delta;
+		if (parent)
+			parent->pending_events[i] += delta;
+	}
+}
+
 #ifdef CONFIG_MMU
 /* Handlers for move charge at task migration. */
 static int mem_cgroup_do_precharge(unsigned long count)
@@ -5191,12 +5192,15 @@ static int memory_events_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 
-	seq_printf(m, "low %lu\n", memcg_sum_events(memcg, MEMCG_LOW));
-	seq_printf(m, "high %lu\n", memcg_sum_events(memcg, MEMCG_HIGH));
-	seq_printf(m, "max %lu\n", memcg_sum_events(memcg, MEMCG_MAX));
-	seq_printf(m, "oom %lu\n", memcg_sum_events(memcg, MEMCG_OOM));
-	seq_printf(m, "oom_kill %lu\n", memcg_sum_events(memcg, OOM_KILL));
+	cgroup_rstat_flush_hold(memcg->css.cgroup);
+
+	seq_printf(m, "low %llu\n", memcg->events[MEMCG_LOW]);
+	seq_printf(m, "high %llu\n", memcg->events[MEMCG_HIGH]);
+	seq_printf(m, "max %llu\n", memcg->events[MEMCG_MAX]);
+	seq_printf(m, "oom %llu\n", memcg->events[MEMCG_OOM]);
+	seq_printf(m, "oom_kill %llu\n", memcg->events[OOM_KILL]);
 
+	cgroup_rstat_flush_release();
 	return 0;
 }
 
@@ -5204,7 +5208,7 @@ static int memory_stat_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 	unsigned long stat[MEMCG_NR_STAT];
-	unsigned long events[MEMCG_NR_EVENTS];
+	unsigned long long *events = memcg->tree_events;
 	int i;
 
 	/*
@@ -5219,7 +5223,7 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	 */
 
 	tree_stat(memcg, stat);
-	tree_events(memcg, events);
+	cgroup_rstat_flush_hold(memcg->css.cgroup);
 
 	seq_printf(m, "anon %llu\n",
 		   (u64)stat[MEMCG_RSS] * PAGE_SIZE);
@@ -5259,18 +5263,18 @@ static int memory_stat_show(struct seq_file *m, void *v)
 
 	/* Accumulated memory events */
 
-	seq_printf(m, "pgfault %lu\n", events[PGFAULT]);
-	seq_printf(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
+	seq_printf(m, "pgfault %llu\n", events[PGFAULT]);
+	seq_printf(m, "pgmajfault %llu\n", events[PGMAJFAULT]);
 
-	seq_printf(m, "pgrefill %lu\n", events[PGREFILL]);
-	seq_printf(m, "pgscan %lu\n", events[PGSCAN_KSWAPD] +
+	seq_printf(m, "pgrefill %llu\n", events[PGREFILL]);
+	seq_printf(m, "pgscan %llu\n", events[PGSCAN_KSWAPD] +
 		   events[PGSCAN_DIRECT]);
-	seq_printf(m, "pgsteal %lu\n", events[PGSTEAL_KSWAPD] +
+	seq_printf(m, "pgsteal %llu\n", events[PGSTEAL_KSWAPD] +
 		   events[PGSTEAL_DIRECT]);
-	seq_printf(m, "pgactivate %lu\n", events[PGACTIVATE]);
-	seq_printf(m, "pgdeactivate %lu\n", events[PGDEACTIVATE]);
-	seq_printf(m, "pglazyfree %lu\n", events[PGLAZYFREE]);
-	seq_printf(m, "pglazyfreed %lu\n", events[PGLAZYFREED]);
+	seq_printf(m, "pgactivate %llu\n", events[PGACTIVATE]);
+	seq_printf(m, "pgdeactivate %llu\n", events[PGDEACTIVATE]);
+	seq_printf(m, "pglazyfree %llu\n", events[PGLAZYFREE]);
+	seq_printf(m, "pglazyfreed %llu\n", events[PGLAZYFREED]);
 
 	seq_printf(m, "workingset_refault %lu\n",
 		   stat[WORKINGSET_REFAULT]);
@@ -5279,6 +5283,7 @@ static int memory_stat_show(struct seq_file *m, void *v)
 	seq_printf(m, "workingset_nodereclaim %lu\n",
 		   stat[WORKINGSET_NODERECLAIM]);
 
+	cgroup_rstat_flush_release();
 	return 0;
 }
 
@@ -5327,6 +5332,7 @@ struct cgroup_subsys memory_cgrp_subsys = {
 	.css_released = mem_cgroup_css_released,
 	.css_free = mem_cgroup_css_free,
 	.css_reset = mem_cgroup_css_reset,
+	.css_rstat_flush = mem_cgroup_css_rstat_flush,
 	.can_attach = mem_cgroup_can_attach,
 	.cancel_attach = mem_cgroup_cancel_attach,
 	.post_attach = mem_cgroup_move_task,
-- 
2.9.5
