Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 25CF46B039F
	for <linux-mm@kvack.org>; Tue,  4 Apr 2017 18:01:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c67so2919564wmi.19
        for <linux-mm@kvack.org>; Tue, 04 Apr 2017 15:01:56 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id e79si21538199wmc.103.2017.04.04.15.01.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Apr 2017 15:01:54 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 2/4] mm: memcontrol: re-use global VM event enum
Date: Tue,  4 Apr 2017 18:01:46 -0400
Message-Id: <20170404220148.28338-2-hannes@cmpxchg.org>
In-Reply-To: <20170404220148.28338-1-hannes@cmpxchg.org>
References: <20170404220148.28338-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

The current duplication is a high-maintenance mess, and it's painful
to add new items.

This increases the size of the event array, but we'll eventually want
most of the VM events tracked on a per-cgroup basis anyway.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/memcontrol.h | 45 ++++++++++++---------------------------
 mm/memcontrol.c            | 53 ++++++++++++++++++++++++----------------------
 2 files changed, 42 insertions(+), 56 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bc0c16e284c0..0bb5f055bd26 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -69,20 +69,6 @@ struct mem_cgroup_reclaim_cookie {
 	unsigned int generation;
 };
 
-enum mem_cgroup_events_index {
-	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
-	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
-	MEM_CGROUP_EVENTS_PGFAULT,	/* # of page-faults */
-	MEM_CGROUP_EVENTS_PGMAJFAULT,	/* # of major page-faults */
-	MEM_CGROUP_EVENTS_NSTATS,
-	/* default hierarchy events */
-	MEMCG_LOW = MEM_CGROUP_EVENTS_NSTATS,
-	MEMCG_HIGH,
-	MEMCG_MAX,
-	MEMCG_OOM,
-	MEMCG_NR_EVENTS,
-};
-
 /*
  * Per memcg event counter is incremented at every pagein/pageout. With THP,
  * it will be incremated by the number of pages. This counter is used for
@@ -106,6 +92,15 @@ struct mem_cgroup_id {
 	atomic_t ref;
 };
 
+/* Cgroup-specific events, on top of universal VM events */
+enum memcg_event_item {
+	MEMCG_LOW = NR_VM_EVENT_ITEMS,
+	MEMCG_HIGH,
+	MEMCG_MAX,
+	MEMCG_OOM,
+	MEMCG_NR_EVENTS,
+};
+
 struct mem_cgroup_stat_cpu {
 	long count[MEMCG_NR_STAT];
 	unsigned long events[MEMCG_NR_EVENTS];
@@ -288,9 +283,9 @@ static inline bool mem_cgroup_disabled(void)
 }
 
 static inline void mem_cgroup_event(struct mem_cgroup *memcg,
-				    enum mem_cgroup_events_index idx)
+				    enum memcg_event_item event)
 {
-	this_cpu_inc(memcg->stat->events[idx]);
+	this_cpu_inc(memcg->stat->events[event]);
 	cgroup_file_notify(&memcg->events_file);
 }
 
@@ -575,20 +570,8 @@ static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
 
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
-	if (unlikely(!memcg))
-		goto out;
-
-	switch (idx) {
-	case PGFAULT:
-		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGFAULT]);
-		break;
-	case PGMAJFAULT:
-		this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
-		break;
-	default:
-		BUG();
-	}
-out:
+	if (likely(memcg))
+		this_cpu_inc(memcg->stat->events[idx]);
 	rcu_read_unlock();
 }
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -608,7 +591,7 @@ static inline bool mem_cgroup_disabled(void)
 }
 
 static inline void mem_cgroup_event(struct mem_cgroup *memcg,
-				    enum mem_cgroup_events_index idx)
+				    enum memcg_event_item event)
 {
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1ffa3ad201ea..6b42887e5f14 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -111,13 +111,6 @@ static const char * const mem_cgroup_stat_names[] = {
 	"swap",
 };
 
-static const char * const mem_cgroup_events_names[] = {
-	"pgpgin",
-	"pgpgout",
-	"pgfault",
-	"pgmajfault",
-};
-
 static const char * const mem_cgroup_lru_names[] = {
 	"inactive_anon",
 	"active_anon",
@@ -571,13 +564,13 @@ mem_cgroup_largest_soft_limit_node(struct mem_cgroup_tree_per_node *mctz)
  */
 
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
-					    enum mem_cgroup_events_index idx)
+					    enum memcg_event_item event)
 {
 	unsigned long val = 0;
 	int cpu;
 
 	for_each_possible_cpu(cpu)
-		val += per_cpu(memcg->stat->events[idx], cpu);
+		val += per_cpu(memcg->stat->events[event], cpu);
 	return val;
 }
 
@@ -608,9 +601,9 @@ static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
 
 	/* pagein of a big page is an event. So, ignore page size */
 	if (nr_pages > 0)
-		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGIN]);
+		__this_cpu_inc(memcg->stat->events[PGPGIN]);
 	else {
-		__this_cpu_inc(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT]);
+		__this_cpu_inc(memcg->stat->events[PGPGOUT]);
 		nr_pages = -nr_pages; /* for event */
 	}
 
@@ -3119,6 +3112,21 @@ static int memcg_numa_stat_show(struct seq_file *m, void *v)
 }
 #endif /* CONFIG_NUMA */
 
+/* Universal VM events cgroup1 shows, original sort order */
+unsigned int memcg1_events[] = {
+	PGPGIN,
+	PGPGOUT,
+	PGFAULT,
+	PGMAJFAULT,
+};
+
+static const char *const memcg1_event_names[] = {
+	"pgpgin",
+	"pgpgout",
+	"pgfault",
+	"pgmajfault",
+};
+
 static int memcg_stat_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
@@ -3128,8 +3136,6 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 
 	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_stat_names) !=
 		     MEM_CGROUP_STAT_NSTATS);
-	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_events_names) !=
-		     MEM_CGROUP_EVENTS_NSTATS);
 	BUILD_BUG_ON(ARRAY_SIZE(mem_cgroup_lru_names) != NR_LRU_LISTS);
 
 	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
@@ -3139,9 +3145,9 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 			   mem_cgroup_read_stat(memcg, i) * PAGE_SIZE);
 	}
 
-	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++)
-		seq_printf(m, "%s %lu\n", mem_cgroup_events_names[i],
-			   mem_cgroup_read_events(memcg, i));
+	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++)
+		seq_printf(m, "%s %lu\n", memcg1_event_names[i],
+			   mem_cgroup_read_events(memcg, memcg1_events[i]));
 
 	for (i = 0; i < NR_LRU_LISTS; i++)
 		seq_printf(m, "%s %lu\n", mem_cgroup_lru_names[i],
@@ -3169,13 +3175,12 @@ static int memcg_stat_show(struct seq_file *m, void *v)
 		seq_printf(m, "total_%s %llu\n", mem_cgroup_stat_names[i], val);
 	}
 
-	for (i = 0; i < MEM_CGROUP_EVENTS_NSTATS; i++) {
+	for (i = 0; i < ARRAY_SIZE(memcg1_events); i++) {
 		unsigned long long val = 0;
 
 		for_each_mem_cgroup_tree(mi, memcg)
-			val += mem_cgroup_read_events(mi, i);
-		seq_printf(m, "total_%s %llu\n",
-			   mem_cgroup_events_names[i], val);
+			val += mem_cgroup_read_events(mi, memcg1_events[i]);
+		seq_printf(m, "total_%s %llu\n", memcg1_event_names[i], val);
 	}
 
 	for (i = 0; i < NR_LRU_LISTS; i++) {
@@ -5222,10 +5227,8 @@ static int memory_stat_show(struct seq_file *m, void *v)
 
 	/* Accumulated memory events */
 
-	seq_printf(m, "pgfault %lu\n",
-		   events[MEM_CGROUP_EVENTS_PGFAULT]);
-	seq_printf(m, "pgmajfault %lu\n",
-		   events[MEM_CGROUP_EVENTS_PGMAJFAULT]);
+	seq_printf(m, "pgfault %lu\n", events[PGFAULT]);
+	seq_printf(m, "pgmajfault %lu\n", events[PGMAJFAULT]);
 
 	seq_printf(m, "workingset_refault %lu\n",
 		   stat[MEMCG_WORKINGSET_REFAULT]);
@@ -5493,7 +5496,7 @@ static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
 	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_CACHE], nr_file);
 	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE], nr_huge);
 	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_SHMEM], nr_shmem);
-	__this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGPGOUT], pgpgout);
+	__this_cpu_add(memcg->stat->events[PGPGOUT], pgpgout);
 	__this_cpu_add(memcg->stat->nr_page_events, nr_pages);
 	memcg_check_events(memcg, dummy_page);
 	local_irq_restore(flags);
-- 
2.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
