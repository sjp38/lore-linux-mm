Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 29E4F6B005D
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:00:07 -0500 (EST)
Received: by mail-yx0-f201.google.com with SMTP id q10so62509yen.2
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 16:00:06 -0800 (PST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 3/3] memcg: track reclaim stats in memory.vmscan_stat
Date: Tue,  6 Dec 2011 15:59:59 -0800
Message-Id: <1323215999-29164-4-git-send-email-yinghan@google.com>
In-Reply-To: <1323215999-29164-1-git-send-email-yinghan@google.com>
References: <1323215999-29164-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>
Cc: linux-mm@kvack.org

Not asking for inclusion, only for testing purpose.

The API tracks the number of scanned and freed pages during page reclaim
as well as the total time taken to shrink_zone().  Counts are broken
down by context (system vs. limit, under hierarchy) and by type.

"_by_limit": per-memcg reclaim and memcg is the target
"_by_system": global reclaim and memcg is the target

"_by_limit_under_hierarchy": per-memcg reclaim and memcg is under the hierarchy
"_by_system_under_hierarchy": global reclaim and memcg is under the hierarchy

Sample output:
$ cat /.../memory.vmscan_stat
...
scanned_pages_by_limit 3954818
scanned_anon_pages_by_limit 0
scanned_file_pages_by_limit 3954818
freed_pages_by_limit 3929770
freed_anon_pages_by_limit 0
freed_file_pages_by_limit 3929770
elapsed_ns_by_limit 3386358102
...

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   18 +++++
 mm/memcontrol.c            |  153 +++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                |   35 ++++++++++-
 3 files changed, 203 insertions(+), 3 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 25c4170..4afc144 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -38,6 +38,12 @@ struct mem_cgroup_reclaim_cookie {
 	unsigned int generation;
 };
 
+struct memcg_scan_record {
+	unsigned long nr_scanned[2]; /* the number of scanned pages */
+	unsigned long nr_freed[2]; /* the number of freed pages */
+	unsigned long elapsed; /* nsec of time elapsed while scanning */
+};
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 /*
  * All "charge" functions with gfp_mask should use GFP_KERNEL or
@@ -126,6 +132,10 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 
+void mem_cgroup_record_scanstat(struct mem_cgroup *mem,
+				struct memcg_scan_record *rec,
+				bool global, bool hierarchy);
+
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 extern int do_swap_account;
 #endif
@@ -378,6 +388,14 @@ static inline
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 }
+
+static inline void
+mem_cgroup_record_scanstat(struct mem_cgroup *mem,
+			   struct memcg_scan_record *rec,
+			   bool global, bool hierarchy)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 35bf664..894e0d2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -112,10 +112,30 @@ enum mem_cgroup_events_target {
 #define THRESHOLDS_EVENTS_TARGET (128)
 #define NUMAINFO_EVENTS_TARGET	(1024)
 
+enum mem_cgroup_scan_context {
+	SCAN_BY_SYSTEM,
+	SCAN_BY_SYSTEM_UNDER_HIERARCHY,
+	SCAN_BY_LIMIT,
+	SCAN_BY_LIMIT_UNDER_HIERARCHY,
+	NR_SCAN_CONTEXT,
+};
+
+enum mem_cgroup_scan_stat {
+	SCANNED,
+	SCANNED_ANON,
+	SCANNED_FILE,
+	FREED,
+	FREED_ANON,
+	FREED_FILE,
+	ELAPSED,
+	NR_SCAN_STAT,
+};
+
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
 	unsigned long events[MEM_CGROUP_EVENTS_NSTATS];
 	unsigned long targets[MEM_CGROUP_NTARGETS];
+	unsigned long scanstats[NR_SCAN_CONTEXT][NR_SCAN_STAT];
 };
 
 struct mem_cgroup_reclaim_iter {
@@ -542,6 +562,58 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
 		preempt_enable();
 }
 
+void mem_cgroup_record_scanstat(struct mem_cgroup *mem,
+				struct memcg_scan_record *rec,
+				bool global, bool hierarchy)
+{
+	int context;
+
+	if (mem_cgroup_disabled())
+		return;
+
+	if (global)
+		context = SCAN_BY_SYSTEM;
+	else
+		context = SCAN_BY_LIMIT;
+	if (hierarchy)
+		context++;
+
+	this_cpu_add(mem->stat->scanstats[context][SCANNED],
+		     rec->nr_scanned[0] + rec->nr_scanned[1]);
+	this_cpu_add(mem->stat->scanstats[context][SCANNED_ANON],
+		     rec->nr_scanned[0]);
+	this_cpu_add(mem->stat->scanstats[context][SCANNED_FILE],
+		     rec->nr_scanned[1]);
+
+	this_cpu_add(mem->stat->scanstats[context][FREED],
+		     rec->nr_freed[0] + rec->nr_freed[1]);
+	this_cpu_add(mem->stat->scanstats[context][FREED_ANON],
+		     rec->nr_freed[0]);
+	this_cpu_add(mem->stat->scanstats[context][FREED_FILE],
+		     rec->nr_freed[1]);
+
+	this_cpu_add(mem->stat->scanstats[context][ELAPSED],
+		     rec->elapsed);
+}
+
+static long mem_cgroup_read_scan_stat(struct mem_cgroup *mem,
+				      int context, int stat)
+{
+	long val = 0;
+	int cpu;
+
+	get_online_cpus();
+	for_each_online_cpu(cpu)
+		val += per_cpu(mem->stat->scanstats[context][stat], cpu);
+#ifdef CONFIG_HOTPLUG_CPU
+	spin_lock(&mem->pcp_counter_lock);
+	val += mem->nocpu_base.scanstats[context][stat];
+	spin_unlock(&mem->pcp_counter_lock);
+#endif
+	put_online_cpus();
+	return val;
+}
+
 static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
 {
 	return container_of(cgroup_subsys_state(cont,
@@ -3672,10 +3744,12 @@ struct mcs_total_stat {
 	s64 stat[NR_MCS_STAT];
 };
 
-struct {
+struct mem_cgroup_stat_name {
 	char *local_name;
 	char *total_name;
-} memcg_stat_strings[NR_MCS_STAT] = {
+};
+
+struct mem_cgroup_stat_name memcg_stat_strings[NR_MCS_STAT] = {
 	{"cache", "total_cache"},
 	{"rss", "total_rss"},
 	{"mapped_file", "total_mapped_file"},
@@ -4234,6 +4308,77 @@ static int mem_control_numa_stat_open(struct inode *unused, struct file *file)
 }
 #endif /* CONFIG_NUMA */
 
+struct scan_stat {
+	unsigned long stats[NR_SCAN_CONTEXT][NR_SCAN_STAT];
+};
+
+struct mem_cgroup_stat_name scan_stat_strings[NR_SCAN_STAT] = {
+	{"scanned_pages", "total_scanned_pages"},
+	{"scanned_anon_pages", "total_scanned_anon_pages"},
+	{"scanned_file_pages", "total_scanned_file_pages"},
+	{"freed_pages", "total_freed_pages"},
+	{"freed_anon_pages", "total_freed_anon_pages"},
+	{"freed_file_pages", "total_freed_file_pages"},
+	{"elapsed_ns", "total_elapsed_ns"},
+};
+
+static const char *scan_context_strings[NR_SCAN_CONTEXT] = {
+	"_by_system",
+	"_by_system_under_hierarchy",
+	"_by_limit",
+	"_by_limit_under_hierarchy",
+};
+
+static void mem_cgroup_get_scan_stat(struct mem_cgroup *mem,
+				     struct scan_stat *s)
+{
+	int i, j;
+
+	for (i = 0; i < NR_SCAN_CONTEXT; i++)
+		for (j = 0; j < NR_SCAN_STAT; j++)
+			s->stats[i][j] += mem_cgroup_read_scan_stat(mem, i, j);
+}
+
+static void mem_cgroup_get_total_scan_stat(struct mem_cgroup *mem,
+					   struct scan_stat *s)
+{
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, mem)
+		mem_cgroup_get_scan_stat(iter, s);
+}
+
+static int mem_cgroup_scan_stat_show(struct cgroup *cont, struct cftype *cft,
+				     struct cgroup_map_cb *cb)
+{
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct scan_stat s;
+	char string[64];
+	int i, j;
+
+	memset(&s, 0, sizeof(s));
+	mem_cgroup_get_scan_stat(mem, &s);
+	for (i = 0; i < NR_SCAN_CONTEXT; i++) {
+		for (j = 0; j < NR_SCAN_STAT; j++) {
+			strcpy(string, scan_stat_strings[j].local_name);
+			strcat(string, scan_context_strings[i]);
+			cb->fill(cb, string, s.stats[i][j]);
+		}
+	}
+
+	memset(&s, 0, sizeof(s));
+	mem_cgroup_get_total_scan_stat(mem, &s);
+	for (i = 0; i < NR_SCAN_CONTEXT; i++) {
+		for (j = 0; j < NR_SCAN_STAT; j++) {
+			strcpy(string, scan_stat_strings[j].total_name);
+			strcat(string, scan_context_strings[i]);
+			cb->fill(cb, string, s.stats[i][j]);
+		}
+	}
+
+	return 0;
+}
+
 static struct cftype mem_cgroup_files[] = {
 	{
 		.name = "usage_in_bytes",
@@ -4304,6 +4449,10 @@ static struct cftype mem_cgroup_files[] = {
 		.mode = S_IRUGO,
 	},
 #endif
+	{
+		.name = "vmscan_stat",
+		.read_map = mem_cgroup_scan_stat_show,
+	},
 };
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b5e81b7..669d8c4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -110,6 +110,11 @@ struct scan_control {
 	struct mem_cgroup *target_mem_cgroup;
 
 	/*
+	 * Stats tracked during page reclaim.
+	 */
+	struct memcg_scan_record *memcg_record;
+
+	/*
 	 * Nodemask of nodes allowed by the caller. If NULL, all nodes
 	 * are scanned.
 	 */
@@ -1522,6 +1527,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 	nr_taken = isolate_pages(nr_to_scan, mz, &page_list,
 				 &nr_scanned, sc->order,
 				 reclaim_mode, 0, file);
+
+	sc->memcg_record->nr_scanned[file] += nr_scanned;
+
 	if (global_reclaim(sc)) {
 		zone->pages_scanned += nr_scanned;
 		if (current_is_kswapd())
@@ -1551,6 +1559,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct mem_cgroup_zone *mz,
 					priority, &nr_dirty, &nr_writeback);
 	}
 
+	sc->memcg_record->nr_freed[file] += nr_reclaimed;
+
 	local_irq_disable();
 	if (current_is_kswapd())
 		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
@@ -1675,6 +1685,9 @@ static void shrink_active_list(unsigned long nr_pages,
 				 &pgscanned, sc->order,
 				 reclaim_mode, 1, file);
 
+	if (sc->memcg_record)
+		sc->memcg_record->nr_scanned[file] += pgscanned;
+
 	if (global_reclaim(sc))
 		zone->pages_scanned += pgscanned;
 
@@ -2111,6 +2124,9 @@ static void shrink_zone(int priority, struct zone *zone,
 		.priority = priority,
 	};
 	struct mem_cgroup *memcg;
+	struct memcg_scan_record rec;
+
+	sc->memcg_record = &rec;
 
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
@@ -2119,9 +2135,21 @@ static void shrink_zone(int priority, struct zone *zone,
 			.zone = zone,
 		};
 
-		if (should_reclaim_mem_cgroup(sc, memcg, priority))
+		if (should_reclaim_mem_cgroup(sc, memcg, priority)) {
+			unsigned long start, end;
+
+			memset(&rec, 0, sizeof(rec));
+			start = sched_clock();
+
 			shrink_mem_cgroup_zone(priority, &mz, sc);
 
+			end = sched_clock();
+			rec.elapsed = end - start;
+			mem_cgroup_record_scanstat(memcg, &rec,
+						   global_reclaim(sc),
+						   root != memcg);
+		}
+
 		/*
 		 * Limit reclaim has historically picked one memcg and
 		 * scanned it with decreasing priority levels until
@@ -2355,6 +2383,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.order = order,
 		.target_mem_cgroup = NULL,
 		.nodemask = nodemask,
+		.memcg_record = NULL,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -2390,6 +2419,7 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 		.nodemask = NULL, /* we don't care the placement */
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
+		.memcg_record = NULL,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -2558,6 +2588,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order,
 		.nr_to_reclaim = ULONG_MAX,
 		.order = order,
 		.target_mem_cgroup = NULL,
+		.memcg_record = NULL,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -3029,6 +3060,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
 		.nr_to_reclaim = nr_to_reclaim,
 		.hibernation_mode = 1,
 		.order = 0,
+		.memcg_record = NULL,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
@@ -3215,6 +3247,7 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 				       SWAP_CLUSTER_MAX),
 		.gfp_mask = gfp_mask,
 		.order = order,
+		.memcg_record = NULL,
 	};
 	struct shrink_control shrink = {
 		.gfp_mask = sc.gfp_mask,
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
