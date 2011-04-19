Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AE9D4900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:58:58 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V6 07/10] Add per-memcg zone "unreclaimable"
Date: Mon, 18 Apr 2011 20:57:43 -0700
Message-Id: <1303185466-2532-8-git-send-email-yinghan@google.com>
In-Reply-To: <1303185466-2532-1-git-send-email-yinghan@google.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

After reclaiming each node per memcg, it checks mem_cgroup_watermark_ok()
and breaks the priority loop if it returns true. The per-memcg zone will
be marked as "unreclaimable" if the scanning rate is much greater than the
reclaiming rate on the per-memcg LRU. The bit is cleared when there is a
page charged to the memcg being freed. Kswapd breaks the priority loop if
all the zones are marked as "unreclaimable".

changelog v6..v5:
1. make global zone_unreclaimable use the ZONE_MEMCG_RECLAIMABLE_RATE.
2. add comment on the zone_unreclaimable

changelog v5..v4:
1. reduce the frequency of updating mz->unreclaimable bit by using the existing
memcg batch in task struct.
2. add new function mem_cgroup_mz_clear_unreclaimable() for recoganizing zone.

changelog v4..v3:
1. split off from the per-memcg background reclaim patch in V3.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   40 +++++++++++++++
 include/linux/sched.h      |    1 +
 include/linux/swap.h       |    2 +
 mm/memcontrol.c            |  118 +++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                |   25 +++++++++-
 5 files changed, 184 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a4747b0..29bbca2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -157,6 +157,14 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
+bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, struct zone *zone);
+bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
+void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
+void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page *page);
+void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,
+					struct zone *zone);
+void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
+					unsigned long nr_scanned);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
@@ -354,6 +362,38 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 {
 }
 
+static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem,
+					       struct zone *zone)
+{
+	return false;
+}
+
+static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
+						struct zone *zone)
+{
+	return false;
+}
+
+static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem,
+							struct zone *zone)
+{
+}
+
+static inline void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem,
+							struct page *page)
+{
+}
+
+static inline void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,
+							struct zone *zone);
+{
+}
+static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem,
+						struct zone *zone,
+						unsigned long nr_scanned)
+{
+}
+
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 					    gfp_t gfp_mask)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 98fc7ed..3370c5a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1526,6 +1526,7 @@ struct task_struct {
 		struct mem_cgroup *memcg; /* target memcg of uncharge */
 		unsigned long nr_pages;	/* uncharged usage */
 		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
+		struct zone *zone; /* a zone page is last uncharged */
 	} memcg_batch;
 #endif
 };
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 17e0511..319b800 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -160,6 +160,8 @@ enum {
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
 
+#define ZONE_RECLAIMABLE_RATE 6
+
 #define SWAP_CLUSTER_MAX 32
 #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7490147..0dfdf27 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -133,7 +133,10 @@ struct mem_cgroup_per_zone {
 	bool			on_tree;
 	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
 						/* use container_of	   */
+	unsigned long		pages_scanned;	/* since last reclaim */
+	bool			all_unreclaimable;	/* All pages pinned */
 };
+
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
 
@@ -1154,6 +1157,103 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	return &mz->reclaim_stat;
 }
 
+void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone *zone,
+						unsigned long nr_scanned)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+
+	if (!mem)
+		return;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (mz)
+		mz->pages_scanned += nr_scanned;
+}
+
+bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, struct zone *zone)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+
+	if (!mem)
+		return 0;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (mz)
+		return mz->pages_scanned <
+				mem_cgroup_zone_reclaimable_pages(mem, zone) *
+				ZONE_RECLAIMABLE_RATE;
+	return 0;
+}
+
+bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+
+	if (!mem)
+		return false;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (mz)
+		return mz->all_unreclaimable;
+
+	return false;
+}
+
+void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+
+	if (!mem)
+		return;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (mz)
+		mz->all_unreclaimable = true;
+}
+
+void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,
+				       struct zone *zone)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+	int nid = zone_to_nid(zone);
+	int zid = zone_idx(zone);
+
+	if (!mem)
+		return;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (mz) {
+		mz->pages_scanned = 0;
+		mz->all_unreclaimable = false;
+	}
+
+	return;
+}
+
+void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page *page)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+
+	if (!mem)
+		return;
+
+	mz = page_cgroup_zoneinfo(mem, page);
+	if (mz) {
+		mz->pages_scanned = 0;
+		mz->all_unreclaimable = false;
+	}
+
+	return;
+}
+
 unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
 					struct list_head *dst,
 					unsigned long *scanned, int order,
@@ -2701,6 +2801,7 @@ void mem_cgroup_cancel_charge_swapin(struct mem_cgroup *mem)
 
 static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
 				   unsigned int nr_pages,
+				   struct page *page,
 				   const enum charge_type ctype)
 {
 	struct memcg_batch_info *batch = NULL;
@@ -2718,6 +2819,10 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
 	 */
 	if (!batch->memcg)
 		batch->memcg = mem;
+
+	if (!batch->zone)
+		batch->zone = page_zone(page);
+
 	/*
 	 * do_batch > 0 when unmapping pages or inode invalidate/truncate.
 	 * In those cases, all pages freed continously can be expected to be in
@@ -2739,12 +2844,17 @@ static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
 	 */
 	if (batch->memcg != mem)
 		goto direct_uncharge;
+
+	if (batch->zone != page_zone(page))
+		mem_cgroup_mz_clear_unreclaimable(mem, page_zone(page));
+
 	/* remember freed charge and uncharge it later */
 	batch->nr_pages++;
 	if (uncharge_memsw)
 		batch->memsw_nr_pages++;
 	return;
 direct_uncharge:
+	mem_cgroup_mz_clear_unreclaimable(mem, page_zone(page));
 	res_counter_uncharge(&mem->res, nr_pages * PAGE_SIZE);
 	if (uncharge_memsw)
 		res_counter_uncharge(&mem->memsw, nr_pages * PAGE_SIZE);
@@ -2826,7 +2936,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 		mem_cgroup_get(mem);
 	}
 	if (!mem_cgroup_is_root(mem))
-		mem_cgroup_do_uncharge(mem, nr_pages, ctype);
+		mem_cgroup_do_uncharge(mem, nr_pages, page, ctype);
 
 	return mem;
 
@@ -2894,6 +3004,10 @@ void mem_cgroup_uncharge_end(void)
 	if (batch->memsw_nr_pages)
 		res_counter_uncharge(&batch->memcg->memsw,
 				     batch->memsw_nr_pages * PAGE_SIZE);
+	if (batch->zone)
+		mem_cgroup_mz_clear_unreclaimable(batch->memcg, batch->zone);
+	batch->zone = NULL;
+
 	memcg_oom_recover(batch->memcg);
 	/* forget this pointer (for sanity check) */
 	batch->memcg = NULL;
@@ -4589,6 +4703,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = mem;
+		mz->pages_scanned = 0;
+		mz->all_unreclaimable = false;
 	}
 	return 0;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2a5c734..ed4622b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1414,6 +1414,9 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 					ISOLATE_BOTH : ISOLATE_INACTIVE,
 			zone, sc->mem_cgroup,
 			0, file);
+
+		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, nr_scanned);
+
 		/*
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
@@ -1533,6 +1536,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
 		 */
+		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, pgscanned);
 	}
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
@@ -1989,7 +1993,8 @@ static void shrink_zones(int priority, struct zonelist *zonelist,
 
 static bool zone_reclaimable(struct zone *zone)
 {
-	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
+	return zone->pages_scanned < zone_reclaimable_pages(zone) *
+					ZONE_RECLAIMABLE_RATE;
 }
 
 /*
@@ -2656,10 +2661,20 @@ static void balance_pgdat_node(pg_data_t *pgdat, int order,
 		if (!scan)
 			continue;
 
+		if (mem_cgroup_mz_unreclaimable(mem_cont, zone) &&
+			priority != DEF_PRIORITY)
+			continue;
+
 		sc->nr_scanned = 0;
 		shrink_zone(priority, zone, sc);
 		total_scanned += sc->nr_scanned;
 
+		if (mem_cgroup_mz_unreclaimable(mem_cont, zone))
+			continue;
+
+		if (!mem_cgroup_zone_reclaimable(mem_cont, zone))
+			mem_cgroup_mz_set_unreclaimable(mem_cont, zone);
+
 		/*
 		 * If we've done a decent amount of scanning and
 		 * the reclaim ratio is low, start doing writepage
@@ -2736,11 +2751,19 @@ loop_again:
 			balance_pgdat_node(pgdat, order, &sc);
 			total_scanned += sc.nr_scanned;
 
+			/*
+			 * Set the node which has at least one reclaimable
+			 * zone
+			 */
 			for (i = pgdat->nr_zones - 1; i >= 0; i--) {
 				struct zone *zone = pgdat->node_zones + i;
 
 				if (!populated_zone(zone))
 					continue;
+
+				if (!mem_cgroup_mz_unreclaimable(mem_cont,
+								zone))
+					break;
 			}
 			if (i < 0)
 				node_clear(nid, do_nodes);
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
