Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DD11590008A
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:58:59 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V6 10/10] Add some per-memcg stats
Date: Mon, 18 Apr 2011 20:57:46 -0700
Message-Id: <1303185466-2532-11-git-send-email-yinghan@google.com>
In-Reply-To: <1303185466-2532-1-git-send-email-yinghan@google.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

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

changelog v2..v1:
1. change the stats using events instead of stats.
2. add the stats in the Documentation

Signed-off-by: Ying Han <yinghan@google.com>
---
 Documentation/cgroups/memory.txt |   14 +++++++
 include/linux/memcontrol.h       |   51 +++++++++++++++++++++++++++
 mm/memcontrol.c                  |   72 ++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                      |   28 ++++++++++++--
 4 files changed, 161 insertions(+), 4 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index b6ed61c..29dee73 100644
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
 inactive_anon	- # of bytes of anonymous memory and swap cache memory on
 		LRU list.
 active_anon	- # of bytes of anonymous and swap cache memory on active
@@ -406,6 +413,13 @@ total_mapped_file	- sum of all children's "cache"
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
 total_inactive_anon	- sum of all children's "inactive_anon"
 total_active_anon	- sum of all children's "active_anon"
 total_inactive_file	- sum of all children's "inactive_file"
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 29bbca2..3207dbf 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -166,6 +166,15 @@ void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,
 void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
 					unsigned long nr_scanned);
 
+/* background reclaim stats */
+void mem_cgroup_kswapd_steal(struct mem_cgroup *memcg, int val);
+void mem_cgroup_pg_steal(struct mem_cgroup *memcg, int val);
+void mem_cgroup_kswapd_pgscan(struct mem_cgroup *memcg, int val);
+void mem_cgroup_pg_pgscan(struct mem_cgroup *memcg, int val);
+void mem_cgroup_pgrefill(struct mem_cgroup *memcg, int val);
+void mem_cgroup_pg_outrun(struct mem_cgroup *memcg, int val);
+void mem_cgroup_alloc_stall(struct mem_cgroup *memcg, int val);
+
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
 #endif
@@ -412,6 +421,48 @@ static inline void mem_cgroup_split_huge_fixup(struct page *head,
 {
 }
 
+/* background reclaim stats */
+static inline void mem_cgroup_kswapd_steal(struct mem_cgroup *memcg,
+					   int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pg_steal(struct mem_cgroup *memcg,
+				       int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_kswapd_pgscan(struct mem_cgroup *memcg,
+					    int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pg_pgscan(struct mem_cgroup *memcg,
+					int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pgrefill(struct mem_cgroup *memcg,
+				       int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pg_outrun(struct mem_cgroup *memcg,
+					int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_alloc_stall(struct mem_cgroup *memcg,
+					  int val)
+{
+	return 0;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0b108b9..84208bb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -94,6 +94,13 @@ enum mem_cgroup_events_index {
 	MEM_CGROUP_EVENTS_PGPGIN,	/* # of pages paged in */
 	MEM_CGROUP_EVENTS_PGPGOUT,	/* # of pages paged out */
 	MEM_CGROUP_EVENTS_COUNT,	/* # of pages paged in/out */
+	MEM_CGROUP_EVENTS_KSWAPD_STEAL, /* # of pages reclaimed from kswapd */
+	MEM_CGROUP_EVENTS_PG_PGSTEAL, /* # of pages reclaimed from ttfp */
+	MEM_CGROUP_EVENTS_KSWAPD_PGSCAN, /* # of pages scanned from kswapd */
+	MEM_CGROUP_EVENTS_PG_PGSCAN, /* # of pages scanned from ttfp */
+	MEM_CGROUP_EVENTS_PGREFILL, /* # of pages scanned on active list */
+	MEM_CGROUP_EVENTS_PGOUTRUN, /* # of triggers of background reclaim */
+	MEM_CGROUP_EVENTS_ALLOCSTALL, /* # of triggers of direct reclaim */
 	MEM_CGROUP_EVENTS_NSTATS,
 };
 /*
@@ -612,6 +619,41 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
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
@@ -3980,6 +4022,13 @@ enum {
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
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -4002,6 +4051,13 @@ struct {
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
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -4031,6 +4087,22 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
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
 	/* per zone stat */
 	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
 	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index ed4622b..c8f4ce5 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1421,6 +1421,10 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
 		 */
+		if (current_is_kswapd())
+			mem_cgroup_kswapd_pgscan(sc->mem_cgroup, nr_scanned);
+		else
+			mem_cgroup_pg_pgscan(sc->mem_cgroup, nr_scanned);
 	}
 
 	if (nr_taken == 0) {
@@ -1441,9 +1445,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
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
 
@@ -1541,7 +1552,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 
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
@@ -2055,6 +2071,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 	if (scanning_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
+	else
+		mem_cgroup_alloc_stall(sc->mem_cgroup, 1);
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
@@ -2720,6 +2738,8 @@ loop_again:
 	sc.nr_reclaimed = 0;
 	total_scanned = 0;
 
+	mem_cgroup_pg_outrun(mem_cont, 1);
+
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc.priority = priority;
 		wmark_ok = false;
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
