Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 972718D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 05:46:58 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5D6973EE0BB
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:46:55 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F2C845DE58
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:46:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C22E45DE55
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:46:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 110FAEF8004
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:46:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B4BD6E08001
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:46:54 +0900 (JST)
Date: Mon, 25 Apr 2011 18:40:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 6/7] memcg add zone_all_unreclaimable.
Message-Id: <20110425184015.c1d97d33.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>


After reclaiming each node per memcg, it checks mem_cgroup_watermark_ok()
and breaks the priority loop if it returns true. The per-memcg zone will
be marked as "unreclaimable" if the scanning rate is much greater than the
reclaiming rate on the per-memcg LRU. The bit is cleared when there is a
page charged to the memcg being freed. Kswapd breaks the priority loop if
all the zones are marked as "unreclaimable".

changelog v8a..v7
  remove using priority.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |   40 ++++++++++++++
 include/linux/sched.h      |    1 
 include/linux/swap.h       |    2 
 mm/memcontrol.c            |  126 +++++++++++++++++++++++++++++++++++++++++++--
 mm/vmscan.c                |   13 ++++
 5 files changed, 177 insertions(+), 5 deletions(-)

Index: memcg/include/linux/memcontrol.h
===================================================================
--- memcg.orig/include/linux/memcontrol.h
+++ memcg/include/linux/memcontrol.h
@@ -158,6 +158,14 @@ unsigned long mem_cgroup_soft_limit_recl
 						unsigned long *total_scanned);
 u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
 u64 mem_cgroup_get_usage(struct mem_cgroup *mem);
+bool mem_cgroup_zone_reclaimable(struct mem_cgroup *mem, struct zone *zone);
+bool mem_cgroup_mz_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
+void mem_cgroup_mz_set_unreclaimable(struct mem_cgroup *mem, struct zone *zone);
+void mem_cgroup_clear_unreclaimable(struct mem_cgroup *mem, struct page *page);
+void mem_cgroup_mz_clear_unreclaimable(struct mem_cgroup *mem,
+					struct zone *zone);
+void mem_cgroup_mz_pages_scanned(struct mem_cgroup *mem, struct zone* zone,
+					unsigned long nr_scanned);
 
 void mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
@@ -355,6 +363,38 @@ static inline void mem_cgroup_dec_page_s
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
+							struct zone *zone)
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
 					    gfp_t gfp_mask,
Index: memcg/include/linux/sched.h
===================================================================
--- memcg.orig/include/linux/sched.h
+++ memcg/include/linux/sched.h
@@ -1540,6 +1540,7 @@ struct task_struct {
 		struct mem_cgroup *memcg; /* target memcg of uncharge */
 		unsigned long nr_pages;	/* uncharged usage */
 		unsigned long memsw_nr_pages; /* uncharged mem+swap usage */
+		struct zone *zone; /* a zone page is last uncharged */
 	} memcg_batch;
 #endif
 };
Index: memcg/include/linux/swap.h
===================================================================
--- memcg.orig/include/linux/swap.h
+++ memcg/include/linux/swap.h
@@ -152,6 +152,8 @@ enum {
 	SWP_SCANNING	= (1 << 8),	/* refcount in scan_swap_map */
 };
 
+#define ZONE_RECLAIMABLE_RATE 6
+
 #define SWAP_CLUSTER_MAX 32
 #define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
 
Index: memcg/mm/memcontrol.c
===================================================================
--- memcg.orig/mm/memcontrol.c
+++ memcg/mm/memcontrol.c
@@ -139,7 +139,10 @@ struct mem_cgroup_per_zone {
 	bool			on_tree;
 	struct mem_cgroup	*mem;		/* Back pointer, we cannot */
 						/* use container_of	   */
+	unsigned long		pages_scanned;	/* since last reclaim */
+	bool			all_unreclaimable;	/* All pages pinned */
 };
+
 /* Macro for accessing counter */
 #define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
 
@@ -1166,12 +1169,15 @@ int mem_cgroup_inactive_file_is_low(stru
 	return (active > inactive);
 }
 
-unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
+unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *mem,
 						int nid, int zone_idx)
 {
 	int nr;
-	struct mem_cgroup_per_zone *mz =
-		mem_cgroup_zoneinfo(memcg, nid, zone_idx);
+	struct mem_cgroup_per_zone *mz;
+
+	if (!mem)
+		return 0;
+	mz = mem_cgroup_zoneinfo(mem, nid, zone_idx);
 
 	nr = MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
 	     MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
@@ -1222,6 +1228,102 @@ mem_cgroup_get_reclaim_stat_from_page(st
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
+
+	return mz->pages_scanned <
+			mem_cgroup_zone_reclaimable_pages(mem, nid, zid) *
+			ZONE_RECLAIMABLE_RATE;
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
@@ -2791,6 +2893,7 @@ void mem_cgroup_cancel_charge_swapin(str
 
 static void mem_cgroup_do_uncharge(struct mem_cgroup *mem,
 				   unsigned int nr_pages,
+				   struct page *page,
 				   const enum charge_type ctype)
 {
 	struct memcg_batch_info *batch = NULL;
@@ -2808,6 +2911,10 @@ static void mem_cgroup_do_uncharge(struc
 	 */
 	if (!batch->memcg)
 		batch->memcg = mem;
+
+	if (!batch->zone)
+		batch->zone = page_zone(page);
+
 	/*
 	 * do_batch > 0 when unmapping pages or inode invalidate/truncate.
 	 * In those cases, all pages freed continuously can be expected to be in
@@ -2829,12 +2936,17 @@ static void mem_cgroup_do_uncharge(struc
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
@@ -2916,7 +3028,7 @@ __mem_cgroup_uncharge_common(struct page
 		mem_cgroup_get(mem);
 	}
 	if (!mem_cgroup_is_root(mem))
-		mem_cgroup_do_uncharge(mem, nr_pages, ctype);
+		mem_cgroup_do_uncharge(mem, nr_pages, page, ctype);
 
 	return mem;
 
@@ -2984,6 +3096,10 @@ void mem_cgroup_uncharge_end(void)
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
@@ -4659,6 +4775,8 @@ static int alloc_mem_cgroup_per_zone_inf
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->mem = mem;
+		mz->pages_scanned = 0;
+		mz->all_unreclaimable = false;
 	}
 	return 0;
 }
Index: memcg/mm/vmscan.c
===================================================================
--- memcg.orig/mm/vmscan.c
+++ memcg/mm/vmscan.c
@@ -1412,6 +1412,9 @@ shrink_inactive_list(unsigned long nr_to
 					ISOLATE_BOTH : ISOLATE_INACTIVE,
 			zone, sc->mem_cgroup,
 			0, file);
+
+		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, nr_scanned);
+
 		/*
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
@@ -1531,6 +1534,7 @@ static void shrink_active_list(unsigned 
 		 * mem_cgroup_isolate_pages() keeps track of
 		 * scanned pages on its own.
 		 */
+		mem_cgroup_mz_pages_scanned(sc->mem_cgroup, zone, pgscanned);
 	}
 
 	reclaim_stat->recent_scanned[file] += nr_taken;
@@ -1998,7 +2002,8 @@ static void shrink_zones(int priority, s
 
 static bool zone_reclaimable(struct zone *zone)
 {
-	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
+	return zone->pages_scanned < zone_reclaimable_pages(zone) *
+					ZONE_RECLAIMABLE_RATE;
 }
 
 /* All zones in zonelist are unreclaimable? */
@@ -2343,6 +2348,10 @@ shrink_memcg_node(int nid, int priority,
 		scan = mem_cgroup_zone_reclaimable_pages(mem_cont, nid, i);
 		if (!scan)
 			continue;
+		/* we would like to remove memory from where we can do easy */
+		if ((sc->nr_reclaimed >= total_scanned/4) &&
+		     mem_cgroup_mz_unreclaimable(mem_cont, zone))
+			continue;
 		/* If recent memory reclaim on this zone doesn't get good */
 		zrs = get_reclaim_stat(zone, sc);
 		scan = zrs->recent_scanned[0] + zrs->recent_scanned[1];
@@ -2355,6 +2364,8 @@ shrink_memcg_node(int nid, int priority,
 		shrink_zone(priority, zone, sc);
 		total_scanned += sc->nr_scanned;
 		sc->may_writepage = 0;
+		if (!mem_cgroup_zone_reclaimable(mem_cont, zone))
+			mem_cgroup_mz_set_unreclaimable(mem_cont, zone);
 	}
 	sc->nr_scanned = total_scanned;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
