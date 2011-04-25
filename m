Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 281208D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 05:43:09 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 37F063EE0AE
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:43:06 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1118745DE93
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:43:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EF40C45DE91
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:43:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E27101DB803C
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:43:05 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A429AE08002
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:43:05 +0900 (JST)
Date: Mon, 25 Apr 2011 18:36:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 5/7] memcg bgreclaim core.
Message-Id: <20110425183629.144d3f19.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

Following patch will chagnge the logic. This is a core.
==
This is the main loop of per-memcg background reclaim which is implemented in
function balance_mem_cgroup_pgdat().

The function performs a priority loop similar to global reclaim. During each
iteration it frees memory from a selected victim node.
After reclaiming enough pages or scanning enough pages, it returns and find
next work with round-robin.

changelog v8b..v7
1. reworked for using work_queue rather than threads.
2. changed shrink_mem_cgroup algorithm to fit workqueue. In short, avoid
   long running and allow quick round-robin and unnecessary write page.
   When a thread make pages dirty continuously, write back them by flusher
   is far faster than writeback by background reclaim. This detail will
   be fixed when dirty_ratio implemented. The logic around this will be
   revisited in following patche.

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |   11 ++++
 mm/memcontrol.c            |   44 ++++++++++++++---
 mm/vmscan.c                |  115 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 162 insertions(+), 8 deletions(-)

Index: memcg/include/linux/memcontrol.h
===================================================================
--- memcg.orig/include/linux/memcontrol.h
+++ memcg/include/linux/memcontrol.h
@@ -89,6 +89,8 @@ extern int mem_cgroup_last_scanned_node(
 extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
 					const nodemask_t *nodes);
 
+unsigned long shrink_mem_cgroup(struct mem_cgroup *mem);
+
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
 {
@@ -112,6 +114,9 @@ extern void mem_cgroup_end_migration(str
  */
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
+unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg);
+unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
+				int nid, int zone_idx);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru);
@@ -310,6 +315,12 @@ mem_cgroup_inactive_file_is_low(struct m
 }
 
 static inline unsigned long
+mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int zone_idx)
+{
+	return 0;
+}
+
+static inline unsigned long
 mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg, struct zone *zone,
 			 enum lru_list lru)
 {
Index: memcg/mm/memcontrol.c
===================================================================
--- memcg.orig/mm/memcontrol.c
+++ memcg/mm/memcontrol.c
@@ -1166,6 +1166,23 @@ int mem_cgroup_inactive_file_is_low(stru
 	return (active > inactive);
 }
 
+unsigned long mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg,
+						int nid, int zone_idx)
+{
+	int nr;
+	struct mem_cgroup_per_zone *mz =
+		mem_cgroup_zoneinfo(memcg, nid, zone_idx);
+
+	nr = MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_FILE) +
+	     MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_FILE);
+
+	if (nr_swap_pages > 0)
+		nr += MEM_CGROUP_ZSTAT(mz, NR_ACTIVE_ANON) +
+		      MEM_CGROUP_ZSTAT(mz, NR_INACTIVE_ANON);
+
+	return nr;
+}
+
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru)
@@ -1286,7 +1303,7 @@ static unsigned long mem_cgroup_margin(s
 	return margin >> PAGE_SHIFT;
 }
 
-static unsigned int get_swappiness(struct mem_cgroup *memcg)
+unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
 	struct cgroup *cgrp = memcg->css.cgroup;
 
@@ -1595,14 +1612,15 @@ static int mem_cgroup_hierarchical_recla
 		/* we use swappiness of local cgroup */
 		if (check_soft) {
 			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
-				noswap, get_swappiness(victim), zone,
+				noswap, mem_cgroup_swappiness(victim), zone,
 				&nr_scanned);
 			*total_scanned += nr_scanned;
 			mem_cgroup_soft_steal(victim, ret);
 			mem_cgroup_soft_scan(victim, nr_scanned);
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
-						noswap, get_swappiness(victim));
+						noswap,
+						mem_cgroup_swappiness(victim));
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -1628,15 +1646,25 @@ static int mem_cgroup_hierarchical_recla
 int
 mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t *nodes)
 {
-	int next_nid;
+	int next_nid, i;
 	int last_scanned;
 
 	last_scanned = mem->last_scanned_node;
-	next_nid = next_node(last_scanned, *nodes);
+	next_nid = last_scanned;
+rescan:
+	next_nid = next_node(next_nid, *nodes);
 
 	if (next_nid == MAX_NUMNODES)
 		next_nid = first_node(*nodes);
 
+	/* If no page on this node, skip */
+	for (i = 0; i < MAX_NR_ZONES; i++)
+		if (mem_cgroup_zone_reclaimable_pages(mem, next_nid, i))
+			break;
+
+	if (next_nid != last_scanned && (i == MAX_NR_ZONES))
+		goto rescan;
+
 	mem->last_scanned_node = next_nid;
 
 	return next_nid;
@@ -3649,7 +3677,7 @@ try_to_free:
 			goto out;
 		}
 		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
-						false, get_swappiness(mem));
+					false, mem_cgroup_swappiness(mem));
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -4073,7 +4101,7 @@ static u64 mem_cgroup_swappiness_read(st
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 
-	return get_swappiness(memcg);
+	return mem_cgroup_swappiness(memcg);
 }
 
 static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
@@ -4849,7 +4877,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	INIT_LIST_HEAD(&mem->oom_notify);
 
 	if (parent)
-		mem->swappiness = get_swappiness(parent);
+		mem->swappiness = mem_cgroup_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
Index: memcg/mm/vmscan.c
===================================================================
--- memcg.orig/mm/vmscan.c
+++ memcg/mm/vmscan.c
@@ -42,6 +42,7 @@
 #include <linux/delayacct.h>
 #include <linux/sysctl.h>
 #include <linux/oom.h>
+#include <linux/res_counter.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -2308,6 +2309,120 @@ static bool sleeping_prematurely(pg_data
 		return !all_zones_ok;
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/*
+ * The function is used for per-memcg LRU. It scanns all the zones of the
+ * node and returns the nr_scanned and nr_reclaimed.
+ */
+/*
+ * Limit of scanning per iteration. For round-robin.
+ */
+#define MEMCG_BGSCAN_LIMIT	(2048)
+
+static void
+shrink_memcg_node(int nid, int priority, struct scan_control *sc)
+{
+	unsigned long total_scanned = 0;
+	struct mem_cgroup *mem_cont = sc->mem_cgroup;
+	int i;
+
+	/*
+	 * This dma->highmem order is consistant with global reclaim.
+	 * We do this because the page allocator works in the opposite
+	 * direction although memcg user pages are mostly allocated at
+	 * highmem.
+	 */
+	for (i = 0;
+	     (i < NODE_DATA(nid)->nr_zones) &&
+	     (total_scanned < MEMCG_BGSCAN_LIMIT);
+	     i++) {
+		struct zone *zone = NODE_DATA(nid)->node_zones + i;
+		struct zone_reclaim_stat *zrs;
+		unsigned long scan, rotate;
+
+		if (!populated_zone(zone))
+			continue;
+		scan = mem_cgroup_zone_reclaimable_pages(mem_cont, nid, i);
+		if (!scan)
+			continue;
+		/* If recent memory reclaim on this zone doesn't get good */
+		zrs = get_reclaim_stat(zone, sc);
+		scan = zrs->recent_scanned[0] + zrs->recent_scanned[1];
+		rotate = zrs->recent_rotated[0] + zrs->recent_rotated[1];
+
+		if (rotate > scan/2)
+        		sc->may_writepage = 1;
+
+		sc->nr_scanned = 0;
+		shrink_zone(priority, zone, sc);
+		total_scanned += sc->nr_scanned;
+		sc->may_writepage = 0;
+	}
+	sc->nr_scanned = total_scanned;
+}
+
+/*
+ * Per cgroup background reclaim.
+ */
+unsigned long shrink_mem_cgroup(struct mem_cgroup *mem)
+{
+	int nid, priority, next_prio;
+	nodemask_t nodes;
+	unsigned long total_scanned;
+	struct scan_control sc = {
+		.gfp_mask = GFP_HIGHUSER_MOVABLE,
+		.may_unmap = 1,
+		.may_swap = 1,
+		.nr_to_reclaim = SWAP_CLUSTER_MAX,
+		.order = 0,
+		.mem_cgroup = mem,
+	};
+
+	sc.may_writepage = 0;
+	sc.nr_reclaimed = 0;
+	total_scanned = 0;
+	nodes = node_states[N_HIGH_MEMORY];
+	sc.swappiness = mem_cgroup_swappiness(mem);
+
+	current->flags |= PF_SWAPWRITE;
+	/*
+	 * Unlike kswapd, we need to traverse cgroups one by one. So, we don't
+	 * use full priority. Just scan small number of pages and visit next.
+	 * Now, we scan MEMCG_BGRECLAIM_SCAN_LIMIT pages per scan.
+	 * We use static priority 0.
+	 */
+	next_prio = min(SWAP_CLUSTER_MAX * num_node_state(N_HIGH_MEMORY),
+			MEMCG_BGSCAN_LIMIT/8);
+	priority = DEF_PRIORITY;
+	while ((total_scanned < MEMCG_BGSCAN_LIMIT) &&
+	       !nodes_empty(nodes) &&
+	       (sc.nr_to_reclaim > sc.nr_reclaimed)) {
+
+		nid = mem_cgroup_select_victim_node(mem, &nodes);
+		shrink_memcg_node(nid, priority, &sc);
+		/*
+		 * the node seems to have no pages.
+ 		 * skip this for a while
+ 		 */
+		if (!sc.nr_scanned)
+			node_clear(nid, nodes);
+		total_scanned += sc.nr_scanned;
+		if (mem_cgroup_watermark_ok(mem, CHARGE_WMARK_HIGH))
+			break;
+		/* emulate priority */
+		if (total_scanned > next_prio) {
+			priority--;
+			next_prio <<= 1;
+		}
+		if (sc.nr_scanned &&
+		    total_scanned > sc.nr_reclaimed * 2)
+			congestion_wait(WRITE, HZ/10);
+	}
+	current->flags &= ~PF_SWAPWRITE;
+	return sc.nr_reclaimed;
+}
+#endif
+
 /*
  * For kswapd, balance_pgdat() will work across all this node's zones until
  * they are all at high_wmark_pages(zone).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
