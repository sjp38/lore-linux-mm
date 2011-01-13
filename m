Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A97DE6B00E9
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 17:01:18 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 5/5] Add more per memcg stats.
Date: Thu, 13 Jan 2011 14:00:35 -0800
Message-Id: <1294956035-12081-6-git-send-email-yinghan@google.com>
In-Reply-To: <1294956035-12081-1-git-send-email-yinghan@google.com>
References: <1294956035-12081-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A bunch of statistics are added in memory.stat to monitor per cgroup
kswapd performance.

$cat /dev/cgroup/yinghan/memory.stat
kswapd_steal 12588994
pg_pgsteal 0
kswapd_pgscan 18629519
pg_scan 0
pgrefill 2893517
pgoutrun 5342267948
allocstall 0

Change log v2...v1:
1. change the stats using events instead of stats.
2. add the stats in the Documentation

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |   14 +++++++
 include/linux/memcontrol.h       |   64 +++++++++++++++++++++++++++++++++
 mm/memcontrol.c                  |   72 ++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                      |   28 ++++++++++++--
 4 files changed, 174 insertions(+), 4 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index bac328c..ee54684 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -385,6 +385,13 @@ mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
 pgpgin		- # of pages paged in (equivalent to # of charging events).
 pgpgout		- # of pages paged out (equivalent to # of uncharging events).
 swap		- # of bytes of swap usage
+kswapd_steal	- # of pages reclaimed from kswapd
+pg_pgsteal	- # of pages reclaimed from direct reclaim
+kswapd_pgscan	- # of pages scanned from kswapd
+pg_scan		- # of pages scanned frm direct reclaim
+pgrefill	- # of pages scanned on active list
+pgoutrun	- # of times triggering kswapd
+allocstall	- # of times triggering direct reclaim
 dirty		- # of bytes that are waiting to get written back to the disk.
 writeback	- # of bytes that are actively being written back to the disk.
 nfs_unstable	- # of bytes sent to the NFS server, but not yet committed to
@@ -410,6 +417,13 @@ total_mapped_file	- sum of all children's "cache"
 total_pgpgin		- sum of all children's "pgpgin"
 total_pgpgout		- sum of all children's "pgpgout"
 total_swap		- sum of all children's "swap"
+total_kswapd_steal	- sum of all children's "kswapd_steal"
+total_pg_pgsteal	- sum of all children's "pg_pgsteal"
+total_kswapd_pgscan	- sum of all children's "kswapd_pgscan"
+total_pg_scan		- sum of all children's "pg_scan"
+total_pgrefill		- sum of all children's "pgrefill"
+total_pgoutrun		- sum of all children's "pgoutrun"
+total_allocstall	- sum of all children's "allocstall"
 total_dirty		- sum of all children's "dirty"
 total_writeback		- sum of all children's "writeback"
 total_nfs_unstable	- sum of all children's "nfs_unstable"
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 69c6e41..9e7d93e 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -173,6 +173,15 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
 
+/* background reclaim stats */
+void mem_cgroup_kswapd_steal(struct mem_cgroup *memcg, int val);
+void mem_cgroup_pg_steal(struct mem_cgroup *memcg, int val);
+void mem_cgroup_kswapd_pgscan(struct mem_cgroup *memcg, int val);
+void mem_cgroup_pg_pgscan(struct mem_cgroup *memcg, int val);
+void mem_cgroup_pgrefill(struct mem_cgroup *memcg, int val);
+void mem_cgroup_pg_outrun(struct mem_cgroup *memcg, int val);
+void mem_cgroup_alloc_stall(struct mem_cgroup *memcg, int val);
+
 void mem_cgroup_clear_unreclaimable(struct page_cgroup *pc);
 bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid);
 bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
@@ -260,6 +269,23 @@ static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	return NULL;
 }
 
+static inline int
+mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags)
+{
+	return 0;
+}
+
+static inline int
+mem_cgroup_init_kswapd(struct mem_cgroup *mem, struct kswapd *kswapd_p)
+{
+	return 0;
+}
+
+static inline wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)
+{
+	return NULL;
+}
+
 static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
 {
 	return 1;
@@ -391,6 +417,7 @@ static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem,
 static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
 						struct zone *zone)
 {
+	return false;
 }
 
 static inline
@@ -411,6 +438,43 @@ static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid,
 {
 	return false;
 }
+
+/* background reclaim stats */
+static inline void mem_cgroup_kswapd_steal(struct mem_cgroup *memcg,
+					   int val)
+{
+}
+
+static inline void mem_cgroup_pg_steal(struct mem_cgroup *memcg,
+				       int val)
+{
+}
+
+static inline void mem_cgroup_kswapd_pgscan(struct mem_cgroup *memcg,
+					    int val)
+{
+}
+
+static inline void mem_cgroup_pg_pgscan(struct mem_cgroup *memcg,
+					int val)
+{
+}
+
+static inline void mem_cgroup_pgrefill(struct mem_cgroup *memcg,
+				       int val)
+{
+}
+
+static inline void mem_cgroup_pg_outrun(struct mem_cgroup *memcg,
+					int val)
+{
+}
+
+static inline void mem_cgroup_alloc_stall(struct mem_cgroup *memcg,
+					  int val)
+{
+}
+
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #endif /* _LINUX_MEMCONTROL_H */
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e716ece..c101b51 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -102,6 +102,13 @@ enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
 	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
 	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
+	MEM_CGROUP_EVENTS_KSWAPD_STEAL, /* # of pages reclaimed from kswapd */
+	MEM_CGROUP_EVENTS_PG_PGSTEAL, /* # of pages reclaimed from ttfp */
+	MEM_CGROUP_EVENTS_KSWAPD_PGSCAN, /* # of pages scanned from kswapd */
+	MEM_CGROUP_EVENTS_PG_PGSCAN, /* # of pages scanned from ttfp */
+	MEM_CGROUP_EVENTS_PGREFILL, /* # of pages scanned on active list */
+	MEM_CGROUP_EVENTS_PGOUTRUN,
+	MEM_CGROUP_EVENTS_ALLOCSTALL,
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 
@@ -640,6 +647,41 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
 	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
 }
 
+void mem_cgroup_kswapd_steal(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_KSWAPD_STEAL], val);
+}
+
+void mem_cgroup_pg_steal(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PG_PGSTEAL], val);
+}
+
+void mem_cgroup_kswapd_pgscan(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_KSWAPD_PGSCAN], val);
+}
+
+void mem_cgroup_pg_pgscan(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PG_PGSCAN], val);
+}
+
+void mem_cgroup_pgrefill(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGREFILL], val);
+}
+
+void mem_cgroup_pg_outrun(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_PGOUTRUN], val);
+}
+
+void mem_cgroup_alloc_stall(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_ALLOCSTALL], val);
+}
+
 static unsigned long mem_cgroup_read_events(struct mem_cgroup *mem,
 					    enum mem_cgroup_events_index idx)
 {
@@ -4076,6 +4118,13 @@ enum {
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
 	MCS_SWAP,
+	MCS_KSWAPD_STEAL,
+	MCS_PG_PGSTEAL,
+	MCS_KSWAPD_PGSCAN,
+	MCS_PG_PGSCAN,
+	MCS_PGREFILL,
+	MCS_PGOUTRUN,
+	MCS_ALLOCSTALL,
 	MCS_FILE_DIRTY,
 	MCS_WRITEBACK,
 	MCS_UNSTABLE_NFS,
@@ -4101,6 +4150,13 @@ struct {
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
 	{"swap", "total_swap"},
+	{"kswapd_steal", "total_kswapd_steal"},
+	{"pg_pgsteal", "total_pg_pgsteal"},
+	{"kswapd_pgscan", "total_kswapd_pgscan"},
+	{"pg_scan", "total_pg_scan"},
+	{"pgrefill", "total_pgrefill"},
+	{"pgoutrun", "total_pgoutrun"},
+	{"allocstall", "total_allocstall"},
 	{"dirty", "total_dirty"},
 	{"writeback", "total_writeback"},
 	{"nfs_unstable", "total_nfs_unstable"},
@@ -4133,6 +4189,22 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
 
+	/* kswapd stat */
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_KSWAPD_STEAL);
+	s->stat[MCS_KSWAPD_STEAL] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PG_PGSTEAL);
+	s->stat[MCS_PG_PGSTEAL] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_KSWAPD_PGSCAN);
+	s->stat[MCS_KSWAPD_PGSCAN] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PG_PGSCAN);
+	s->stat[MCS_PG_PGSCAN] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGREFILL);
+	s->stat[MCS_PGREFILL] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_PGOUTRUN);
+	s->stat[MCS_PGOUTRUN] += val;
+	val = mem_cgroup_read_events(mem, MEM_CGROUP_EVENTS_ALLOCSTALL);
+	s->stat[MCS_ALLOCSTALL] += val;
+
 	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_DIRTY);
 	s->stat[MCS_FILE_DIRTY] += val * PAGE_SIZE;
 	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_FILE_WRITEBACK);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 34f6165..11784cc 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1396,6 +1396,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
 		 */
+		if (current_is_kswapd())
+			mem_cgroup_kswapd_pgscan(sc->mem_cgroup, nr_scanned);
+		else
+			mem_cgroup_pg_pgscan(sc->mem_cgroup, nr_scanned);
 	}
 
 	if (nr_taken == 0) {
@@ -1416,9 +1420,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	}
 
 	local_irq_disable();
-	if (current_is_kswapd())
-		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
-	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
+	if (scanning_global_lru(sc)) {
+		if (current_is_kswapd())
+			__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
+		__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
+	} else {
+		if (current_is_kswapd())
+			mem_cgroup_kswapd_steal(sc->mem_cgroup, nr_reclaimed);
+		else
+			mem_cgroup_pg_steal(sc->mem_cgroup, nr_reclaimed);
+	}
 
 	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
 
@@ -1516,7 +1527,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
-	__count_zone_vm_events(PGREFILL, zone, pgscanned);
+	if (scanning_global_lru(sc))
+		__count_zone_vm_events(PGREFILL, zone, pgscanned);
+	else
+		mem_cgroup_pgrefill(sc->mem_cgroup, pgscanned);
+
+
 	if (file)
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
 	else
@@ -1959,6 +1975,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 	if (scanning_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
+	else
+		mem_cgroup_alloc_stall(sc->mem_cgroup, 1);
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
@@ -2503,6 +2521,8 @@ loop_again:
 	sc.nr_reclaimed = 0;
 	total_scanned = 0;
 
+	mem_cgroup_pg_outrun(mem_cont, 1);
+
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc.priority = priority;
 		wmark_ok = 0;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
