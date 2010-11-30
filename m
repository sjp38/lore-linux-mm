Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D9C456B0085
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 01:50:25 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 4/4] Add more per memcg stats.
Date: Mon, 29 Nov 2010 22:49:45 -0800
Message-Id: <1291099785-5433-5-git-send-email-yinghan@google.com>
In-Reply-To: <1291099785-5433-1-git-send-email-yinghan@google.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A bunch of statistics are added in memory.stat to monitor per cgroup
kswapd performance.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   81 +++++++++++++++++++++++++
 mm/memcontrol.c            |  140 ++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |   33 +++++++++-
 3 files changed, 250 insertions(+), 4 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index dbed45d..893ca62 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -127,6 +127,19 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
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
+void mem_cgroup_balance_wmark_ok(struct mem_cgroup *memcg, int val);
+void mem_cgroup_balance_swap_max(struct mem_cgroup *memcg, int val);
+void mem_cgroup_kswapd_shrink_zone(struct mem_cgroup *memcg, int val);
+void mem_cgroup_kswapd_may_writepage(struct mem_cgroup *memcg, int val);
+
 void mem_cgroup_clear_unreclaimable(struct page *page, struct zone *zone);
 bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid);
 bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
@@ -337,6 +350,74 @@ u64 mem_cgroup_get_limit(struct mem_cgroup *mem)
 	return 0;
 }
 
+/* background reclaim stats */
+static inline void mem_cgroup_kswapd_steal(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pg_steal(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_kswapd_pgscan(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pg_pgscan(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pgrefill(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_pg_outrun(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_alloc_stall(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_balance_wmark_ok(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_balance_swap_max(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
+static inline void mem_cgroup_kswapd_shrink_zone(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
+
+static inline void mem_cgroup_kswapd_may_writepage(struct mem_cgroup *memcg,
+								int val)
+{
+	return 0;
+}
+
 static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid,
 								int zid)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 1d39b65..97df6dd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -91,6 +91,21 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
+	MEM_CGROUP_STAT_KSWAPD_INVOKE, /* # of times invokes kswapd */
+	MEM_CGROUP_STAT_KSWAPD_STEAL, /* # of pages reclaimed from kswapd */
+	MEM_CGROUP_STAT_PG_PGSTEAL, /* # of pages reclaimed from ttfp */
+	MEM_CGROUP_STAT_KSWAPD_PGSCAN, /* # of pages scanned from kswapd */
+	MEM_CGROUP_STAT_PG_PGSCAN, /* # of pages scanned from ttfp */
+	MEM_CGROUP_STAT_PGREFILL, /* # of pages scanned on active list */
+	MEM_CGROUP_STAT_WMARK_LOW_OK,
+	MEM_CGROUP_STAT_KSWAP_CREAT,
+	MEM_CGROUP_STAT_PGOUTRUN,
+	MEM_CGROUP_STAT_ALLOCSTALL,
+	MEM_CGROUP_STAT_BALANCE_WMARK_OK,
+	MEM_CGROUP_STAT_BALANCE_SWAP_MAX,
+	MEM_CGROUP_STAT_WAITQUEUE,
+	MEM_CGROUP_STAT_KSWAPD_SHRINK_ZONE,
+	MEM_CGROUP_STAT_KSWAPD_MAY_WRITEPAGE,
 	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
 	/* incremented at every  pagein/pageout */
 	MEM_CGROUP_EVENTS = MEM_CGROUP_STAT_DATA,
@@ -619,6 +634,62 @@ static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
 	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_SWAPOUT], val);
 }
 
+void mem_cgroup_kswapd_steal(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_KSWAPD_STEAL], val);
+}
+
+void mem_cgroup_pg_steal(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_PG_PGSTEAL], val);
+}
+
+void mem_cgroup_kswapd_pgscan(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_KSWAPD_PGSCAN], val);
+}
+
+void mem_cgroup_pg_pgscan(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_PG_PGSCAN], val);
+}
+
+void mem_cgroup_pgrefill(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_PGREFILL], val);
+}
+
+void mem_cgroup_pg_outrun(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_PGOUTRUN], val);
+}
+
+void mem_cgroup_alloc_stall(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_ALLOCSTALL], val);
+}
+
+void mem_cgroup_balance_wmark_ok(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_BALANCE_WMARK_OK], val);
+}
+
+void mem_cgroup_balance_swap_max(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_BALANCE_SWAP_MAX], val);
+}
+
+void mem_cgroup_kswapd_shrink_zone(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_KSWAPD_SHRINK_ZONE], val);
+}
+
+void mem_cgroup_kswapd_may_writepage(struct mem_cgroup *mem, int val)
+{
+	this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_KSWAPD_MAY_WRITEPAGE],
+			val);
+}
+
 static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
 					 struct page_cgroup *pc,
 					 bool charge)
@@ -2000,8 +2071,14 @@ static int __mem_cgroup_do_charge(struct mem_cgroup *mem, gfp_t gfp_mask,
 		ret = res_counter_charge(&mem->res, csize, CHARGE_WMARK_LOW,
 					&fail_res);
 		if (likely(!ret)) {
+			this_cpu_add(
+				mem->stat->count[MEM_CGROUP_STAT_WMARK_LOW_OK],
+				1);
 			return CHARGE_OK;
 		} else {
+			this_cpu_add(
+				mem->stat->count[MEM_CGROUP_STAT_KSWAPD_INVOKE],
+				1);
 			mem_over_limit = mem_cgroup_from_res_counter(fail_res,
 									res);
 			wake_memcg_kswapd(mem_over_limit);
@@ -3723,6 +3800,21 @@ enum {
 	MCS_PGPGIN,
 	MCS_PGPGOUT,
 	MCS_SWAP,
+	MCS_KSWAPD_INVOKE,
+	MCS_KSWAPD_STEAL,
+	MCS_PG_PGSTEAL,
+	MCS_KSWAPD_PGSCAN,
+	MCS_PG_PGSCAN,
+	MCS_PGREFILL,
+	MCS_WMARK_LOW_OK,
+	MCS_KSWAP_CREAT,
+	MCS_PGOUTRUN,
+	MCS_ALLOCSTALL,
+	MCS_BALANCE_WMARK_OK,
+	MCS_BALANCE_SWAP_MAX,
+	MCS_WAITQUEUE,
+	MCS_KSWAPD_SHRINK_ZONE,
+	MCS_KSWAPD_MAY_WRITEPAGE,
 	MCS_INACTIVE_ANON,
 	MCS_ACTIVE_ANON,
 	MCS_INACTIVE_FILE,
@@ -3745,6 +3837,21 @@ struct {
 	{"pgpgin", "total_pgpgin"},
 	{"pgpgout", "total_pgpgout"},
 	{"swap", "total_swap"},
+	{"kswapd_invoke", "total_kswapd_invoke"},
+	{"kswapd_steal", "total_kswapd_steal"},
+	{"pg_pgsteal", "total_pg_pgsteal"},
+	{"kswapd_pgscan", "total_kswapd_pgscan"},
+	{"pg_scan", "total_pg_scan"},
+	{"pgrefill", "total_pgrefill"},
+	{"wmark_low_ok", "total_wmark_low_ok"},
+	{"kswapd_create", "total_kswapd_create"},
+	{"pgoutrun", "total_pgoutrun"},
+	{"allocstall", "total_allocstall"},
+	{"balance_wmark_ok", "total_balance_wmark_ok"},
+	{"balance_swap_max", "total_balance_swap_max"},
+	{"waitqueue", "total_waitqueue"},
+	{"kswapd_shrink_zone", "total_kswapd_shrink_zone"},
+	{"kswapd_may_writepage", "total_kswapd_may_writepage"},
 	{"inactive_anon", "total_inactive_anon"},
 	{"active_anon", "total_active_anon"},
 	{"inactive_file", "total_inactive_file"},
@@ -3773,6 +3880,37 @@ mem_cgroup_get_local_stat(struct mem_cgroup *mem, struct mcs_total_stat *s)
 		val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_SWAPOUT);
 		s->stat[MCS_SWAP] += val * PAGE_SIZE;
 	}
+	/* kswapd stat */
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAPD_INVOKE);
+	s->stat[MCS_KSWAPD_INVOKE] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAPD_STEAL);
+	s->stat[MCS_KSWAPD_STEAL] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PG_PGSTEAL);
+	s->stat[MCS_PG_PGSTEAL] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAPD_PGSCAN);
+	s->stat[MCS_KSWAPD_PGSCAN] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PG_PGSCAN);
+	s->stat[MCS_PG_PGSCAN] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGREFILL);
+	s->stat[MCS_PGREFILL] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WMARK_LOW_OK);
+	s->stat[MCS_WMARK_LOW_OK] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAP_CREAT);
+	s->stat[MCS_KSWAP_CREAT] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_PGOUTRUN);
+	s->stat[MCS_PGOUTRUN] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_ALLOCSTALL);
+	s->stat[MCS_ALLOCSTALL] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_BALANCE_WMARK_OK);
+	s->stat[MCS_BALANCE_WMARK_OK] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_BALANCE_SWAP_MAX);
+	s->stat[MCS_BALANCE_SWAP_MAX] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_WAITQUEUE);
+	s->stat[MCS_WAITQUEUE] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAPD_SHRINK_ZONE);
+	s->stat[MCS_KSWAPD_SHRINK_ZONE] += val;
+	val = mem_cgroup_read_stat(mem, MEM_CGROUP_STAT_KSWAPD_MAY_WRITEPAGE);
+	s->stat[MCS_KSWAPD_MAY_WRITEPAGE] += val;
 
 	/* per zone stat */
 	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
@@ -4579,9 +4717,11 @@ void wake_memcg_kswapd(struct mem_cgroup *mem)
 				0);
 		else
 			kswapd_p->kswapd_task = thr;
+		this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_KSWAP_CREAT], 1);
 	}
 
 	if (!waitqueue_active(wait)) {
+		this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_WAITQUEUE], 1);
 		return;
 	}
 	wake_up_interruptible(wait);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index f8430c4..5b0c349 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1389,10 +1389,15 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 					ISOLATE_INACTIVE : ISOLATE_BOTH,
 			zone, sc->mem_cgroup,
 			0, file);
+		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, nr_scanned);
 		/*
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
 		 */
+		if (current_is_kswapd())
+			mem_cgroup_kswapd_pgscan(sc->mem_cgroup, nr_scanned);
+		else
+			mem_cgroup_pg_pgscan(sc->mem_cgroup, nr_scanned);
 	}
 
 	if (nr_taken == 0) {
@@ -1413,9 +1418,16 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
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
 
@@ -1508,11 +1520,16 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
 		 */
+		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, pgscanned);
 	}
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
-	__count_zone_vm_events(PGREFILL, zone, pgscanned);
+	if (scanning_global_lru(sc))
+		__count_zone_vm_events(PGREFILL, zone, pgscanned);
+	else
+		mem_cgroup_pgrefill(sc->mem_cgroup, pgscanned);
+
 	if (file)
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
 	else
@@ -1955,6 +1972,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 	if (scanning_global_lru(sc))
 		count_vm_event(ALLOCSTALL);
+	else
+		mem_cgroup_alloc_stall(sc->mem_cgroup, 1);
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc->nr_scanned = 0;
@@ -2444,6 +2463,8 @@ scan:
 			priority != DEF_PRIORITY)
 			continue;
 
+		mem_cgroup_kswapd_shrink_zone(mem_cont, 1);
+
 		sc->nr_scanned = 0;
 		shrink_zone(priority, zone, sc);
 		total_scanned += sc->nr_scanned;
@@ -2462,6 +2483,7 @@ scan:
 		if (total_scanned > SWAP_CLUSTER_MAX * 2 &&
 		    total_scanned > sc->nr_reclaimed + sc->nr_reclaimed / 2) {
 			sc->may_writepage = 1;
+			mem_cgroup_kswapd_may_writepage(mem_cont, 1);
 		}
 	}
 
@@ -2504,6 +2526,8 @@ loop_again:
 	sc.nr_reclaimed = 0;
 	total_scanned = 0;
 
+	mem_cgroup_pg_outrun(mem_cont, 1);
+
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		sc.priority = priority;
 
@@ -2544,6 +2568,7 @@ loop_again:
 				wmark_ok = 0;
 
 			if (wmark_ok) {
+				mem_cgroup_balance_wmark_ok(sc.mem_cgroup, 1);
 				goto out;
 			}
 		}
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
