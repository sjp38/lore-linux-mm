Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BFA06900091
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 18:55:51 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V4 07/10] Add per-memcg zone "unreclaimable"
Date: Thu, 14 Apr 2011 15:54:26 -0700
Message-Id: <1302821669-29862-8-git-send-email-yinghan@google.com>
In-Reply-To: <1302821669-29862-1-git-send-email-yinghan@google.com>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
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

changelog v4..v3:
1. split off from the per-memcg background reclaim patch in V3.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   30 ++++++++++++++
 include/linux/swap.h       |    2 +
 mm/memcontrol.c            |   96 ++++++++++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                |   19 +++++++++
 4 files changed, 147 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index d4ff7f2..a8159f5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -155,6 +155,12 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 						gfp_t gfp_mask);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
+void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page *page);
+bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid);
+bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
+void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
+void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
+				unsigned long nr_scanned);
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
@@ -345,6 +351,25 @@ static inline void mem_cgroup_dec_page_stat(struct page *page,
 {
 }
 
+static inline void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem,
+						struct zone *zone,
+						unsigned long nr_scanned)
+{
+}
+
+static inline void mem_cgroup_clear_unreclaimable(struct page *page,
+							struct zone *zone)
+{
+}
+static inline void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem,
+		struct zone *zone)
+{
+}
+static inline bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem,
+						struct zone *zone)
+{
+}
+
 static inline
 unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
 					    gfp_t gfp_mask)
@@ -363,6 +388,11 @@ static inline void mem_cgroup_split_huge_fixup(struct page *head,
 {
 }
 
+static inline bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid,
+								int zid)
+{
+	return false;
+}
 #endif /* CONFIG_CGROUP_MEM_CONT */
 
 #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
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
index e22351a..da6a130 100644
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
 
@@ -1135,6 +1138,96 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	return &mz->reclaim_stat;
 }
 
+static unsigned long mem_cgroup_zone_reclaimable_pages(
+					struct mem_cgroup_per_zone *mz)
+{
+	int nr;
+	nr = MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_FILE) +
+		MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_FILE);
+
+	if (nr_swap_pages > 0)
+		nr += MEM_CGROUP_ZSTAT(mz, LRU_ACTIVE_ANON) +
+			MEM_CGROUP_ZSTAT(mz, LRU_INACTIVE_ANON);
+
+	return nr;
+}
+
+void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
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
+bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, int nid, int zid)
+{
+	struct mem_cgroup_per_zone *mz = NULL;
+
+	if (!mem)
+		return 0;
+
+	mz = mem_cgroup_zoneinfo(mem, nid, zid);
+	if (mz)
+		return mz->pages_scanned <
+				mem_cgroup_zone_reclaimable_pages(mz) *
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
@@ -2801,6 +2894,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	 * special functions.
 	 */
 
+	mem_cgroup_clear_unreclaimable(mem, page);
 	unlock_page_cgroup(pc);
 	/*
 	 * even after unlock, we have mem->res.usage here and this memcg
@@ -4569,6 +4663,8 @@ static int alloc_mem_cgroup_per_zone_info(struct mem_cgroup *mem, int node)
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = mem;
+		mz->pages_scanned = 0;
+		mz->all_unreclaimable = false;
 	}
 	return 0;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index b8345d2..c081112 100644
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
@@ -2648,6 +2652,7 @@ static void balance_pgdat_node(pg_data_t *pgdat, int order,
 	unsigned long total_scanned = 0;
 	struct mem_cgroup *mem_cont = sc->mem_cgroup;
 	int priority = sc->priority;
+	int nid = pgdat->node_id;
 
 	/*
 	 * Now scan the zone in the dma->highmem direction, and we scan
@@ -2664,10 +2669,20 @@ static void balance_pgdat_node(pg_data_t *pgdat, int order,
 		if (!populated_zone(zone))
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
+		if (!mem_cgroup_zone_reclaimable(mem_cont, nid, i))
+			mem_cgroup_mz_set_unreclaimable(mem_cont, zone);
+
 		/*
 		 * If we've done a decent amount of scanning and
 		 * the reclaim ratio is low, start doing writepage
@@ -2752,6 +2767,10 @@ loop_again:
 
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
