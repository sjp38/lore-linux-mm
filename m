Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id EA07B6B006E
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 10:03:14 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] mm: memcg: per-memcg reclaim statistics
Date: Tue, 10 Jan 2012 16:02:51 +0100
Message-Id: <1326207772-16762-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

With the single per-zone LRU gone and global reclaim scanning
individual memcgs, it's straight-forward to collect meaningful and
accurate per-memcg reclaim statistics.

This adds the following items to memory.stat:

pgreclaim
pgscan

  Number of pages reclaimed/scanned from that memcg due to its own
  hard limit (or physical limit in case of the root memcg) by the
  allocating task.

kswapd_pgreclaim
kswapd_pgscan

  Reclaim activity from kswapd due to the memcg's own limit.  Only
  applicable to the root memcg for now since kswapd is only triggered
  by physical limits, but kswapd-style reclaim based on memcg hard
  limits is being developped.

hierarchy_pgreclaim
hierarchy_pgscan
hierarchy_kswapd_pgreclaim
hierarchy_kswapd_pgscan

  Reclaim activity due to limitations in one of the memcg's parents.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroups/memory.txt |    4 ++
 include/linux/memcontrol.h       |   10 +++++
 mm/memcontrol.c                  |   84 +++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                      |    7 +++
 4 files changed, 103 insertions(+), 2 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index cc0ebc5..eb9e982 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -389,6 +389,10 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
 pgpgin		- # of pages paged in (equivalent to # of charging events).
 pgpgout		- # of pages paged out (equivalent to # of uncharging events).
 swap		- # of bytes of swap usage
+pgreclaim	- # of pages reclaimed due to this memcg's limit
+pgscan		- # of pages scanned due to this memcg's limit
+kswapd_*	- # reclaim activity by background daemon due to this memcg's limit
+hierarchy_*	- # reclaim activity due to pressure from parental memcg
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
 		LRU list.
 active_anon	- # of bytes of anonymous and swap cache memory on active
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index bd3b102..6c1d69e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -121,6 +121,8 @@ struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
 						      struct zone *zone);
 struct zone_reclaim_stat*
 mem_cgroup_get_reclaim_stat_from_page(struct page *page);
+void mem_cgroup_account_reclaim(struct mem_cgroup *, struct mem_cgroup *,
+				unsigned long, unsigned long, bool);
 extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
 					struct task_struct *p);
 extern void mem_cgroup_replace_page_cache(struct page *oldpage,
@@ -347,6 +349,14 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	return NULL;
 }
 
+static inline void mem_cgroup_account_reclaim(struct mem_cgroup *root,
+					      struct mem_cgroup *memcg,
+					      unsigned long nr_reclaimed,
+					      unsigned long nr_scanned,
+					      bool kswapd)
+{
+}
+
 static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8e2a80d..170dff4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -91,12 +91,23 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_NSTATS,
 };
 
+#define MEM_CGROUP_EVENTS_KSWAPD 2
+#define MEM_CGROUP_EVENTS_HIERARCHY 4
+
 enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
 	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
 	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
 	MEM_CGROUP_EVENTS_PGFAULT,	/* # of page-faults */
 	MEM_CGROUP_EVENTS_PGMAJFAULT,	/* # of major page-faults */
+	MEM_CGROUP_EVENTS_PGRECLAIM,
+	MEM_CGROUP_EVENTS_PGSCAN,
+	MEM_CGROUP_EVENTS_KSWAPD_PGRECLAIM,
+	MEM_CGROUP_EVENTS_KSWAPD_PGSCAN,
+	MEM_CGROUP_EVENTS_HIERARCHY_PGRECLAIM,
+	MEM_CGROUP_EVENTS_HIERARCHY_PGSCAN,
+	MEM_CGROUP_EVENTS_HIERARCHY_KSWAPD_PGRECLAIM,
+	MEM_CGROUP_EVENTS_HIERARCHY_KSWAPD_PGSCAN,
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 /*
@@ -889,6 +900,38 @@ static inline bool mem_cgroup_is_root(struct mem_cgroup *memcg)
 	return (memcg == root_mem_cgroup);
 }
 
+/**
+ * mem_cgroup_account_reclaim - update per-memcg reclaim statistics
+ * @root: memcg that triggered reclaim
+ * @memcg: memcg that is actually being scanned
+ * @nr_reclaimed: number of pages reclaimed from @memcg
+ * @nr_scanned: number of pages scanned from @memcg
+ * @kswapd: whether reclaiming task is kswapd or allocator itself
+ */
+void mem_cgroup_account_reclaim(struct mem_cgroup *root,
+				struct mem_cgroup *memcg,
+				unsigned long nr_reclaimed,
+				unsigned long nr_scanned,
+				bool kswapd)
+{
+	unsigned int offset = 0;
+
+	if (!root)
+		root = root_mem_cgroup;
+
+	if (kswapd)
+		offset += MEM_CGROUP_EVENTS_KSWAPD;
+	if (root != memcg)
+		offset += MEM_CGROUP_EVENTS_HIERARCHY;
+
+	preempt_disable();
+	__this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGRECLAIM + offset],
+		       nr_reclaimed);
+	__this_cpu_add(memcg->stat->events[MEM_CGROUP_EVENTS_PGSCAN + offset],
+		       nr_scanned);
+	preempt_enable();
+}
+
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 	struct mem_cgroup *memcg;
@@ -1662,6 +1705,8 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 	excess = res_counter_soft_limit_excess(&root_memcg->res) >> PAGE_SHIFT;
 
 	while (1) {
+		unsigned long nr_reclaimed;
+
 		victim = mem_cgroup_iter(root_memcg, victim, &reclaim);
 		if (!victim) {
 			loop++;
@@ -1687,8 +1732,11 @@ static int mem_cgroup_soft_reclaim(struct mem_cgroup *root_memcg,
 		}
 		if (!mem_cgroup_reclaimable(victim, false))
 			continue;
-		total += mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
-						     zone, &nr_scanned);
+		nr_reclaimed = mem_cgroup_shrink_node_zone(victim, gfp_mask, false,
+							   zone, &nr_scanned);
+		mem_cgroup_account_reclaim(root_mem_cgroup, victim, nr_reclaimed,
+					   nr_scanned, current_is_kswapd());
+		total += nr_reclaimed;
 		*total_scanned += nr_scanned;
 		if (!res_counter_soft_limit_excess(&root_memcg->res))
 			break;
@@ -4023,6 +4071,14 @@ enum {
 	MCS_SWAP,
 	MCS_PGFAULT,
 	MCS_PGMAJFAULT,
+	MCS_PGRECLAIM,
+	MCS_PGSCAN,
+	MCS_KSWAPD_PGRECLAIM,
+	MCS_KSWAPD_PGSCAN,
+	MCS_HIERARCHY_PGRECLAIM,
+	MCS_HIERARCHY_PGSCAN,
+	MCS_HIERARCHY_KSWAPD_PGRECLAIM,
+	MCS_HIERARCHY_KSWAPD_PGSCAN,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -4047,6 +4103,14 @@ struct {
 	{"swap", "total_swap"},
 	{"pgfault", "total_pgfault"},
 	{"pgmajfault", "total_pgmajfault"},
+	{"pgreclaim", "total_pgreclaim"},
+	{"pgscan", "total_pgscan"},
+	{"kswapd_pgreclaim", "total_kswapd_pgreclaim"},
+	{"kswapd_pgscan", "total_kswapd_pgscan"},
+	{"hierarchy_pgreclaim", "total_hierarchy_pgreclaim"},
+	{"hierarchy_pgscan", "total_hierarchy_pgscan"},
+	{"hierarchy_kswapd_pgreclaim", "total_hierarchy_kswapd_pgreclaim"},
+	{"hierarchy_kswapd_pgscan", "total_hierarchy_kswapd_pgscan"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -4079,6 +4143,22 @@ mem_cgroup_get_local_stat(struct mem_cgroup *memcg, struct mcs_total_stat *s)
 	s->stat[MCS_PGFAULT] += val;
 	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGMAJFAULT);
 	s->stat[MCS_PGMAJFAULT] += val;
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGRECLAIM);
+	s->stat[MCS_PGRECLAIM] += val;
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_PGSCAN);
+	s->stat[MCS_PGSCAN] += val;
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_KSWAPD_PGRECLAIM);
+	s->stat[MCS_KSWAPD_PGRECLAIM] += val;
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_KSWAPD_PGSCAN);
+	s->stat[MCS_KSWAPD_PGSCAN] += val;
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_HIERARCHY_PGRECLAIM);
+	s->stat[MCS_HIERARCHY_PGRECLAIM] += val;
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_HIERARCHY_PGSCAN);
+	s->stat[MCS_HIERARCHY_PGSCAN] += val;
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_HIERARCHY_KSWAPD_PGRECLAIM);
+	s->stat[MCS_HIERARCHY_KSWAPD_PGRECLAIM] += val;
+	val = mem_cgroup_read_events(memcg, MEM_CGROUP_EVENTS_HIERARCHY_KSWAPD_PGSCAN);
+	s->stat[MCS_HIERARCHY_KSWAPD_PGSCAN] += val;
 
 	/* per zone stat */
 	val = mem_cgroup_nr_lru_pages(memcg, BIT(LRU_INACTIVE_ANON));
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c631234..e3fd8a7 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2115,12 +2115,19 @@ static void shrink_zone(int priority, struct zone *zone,
 
 	memcg = mem_cgroup_iter(root, NULL, &reclaim);
 	do {
+		unsigned long nr_reclaimed = sc->nr_reclaimed;
+		unsigned long nr_scanned = sc->nr_scanned;
 		struct mem_cgroup_zone mz = {
 			.mem_cgroup = memcg,
 			.zone = zone,
 		};
 
 		shrink_mem_cgroup_zone(priority, &mz, sc);
+
+		mem_cgroup_account_reclaim(root, memcg,
+					   sc->nr_reclaimed - nr_reclaimed,
+					   sc->nr_scanned - nr_scanned,
+					   current_is_kswapd());
 		/*
 		 * Limit reclaim has historically picked one memcg and
 		 * scanned it with decreasing priority levels until
-- 
1.7.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
