Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C71990010B
	for <linux-mm@kvack.org>; Tue, 10 May 2011 06:13:46 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 5B4863EE0B5
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:13:43 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4184E45DEE6
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:13:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 259D245DF48
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:13:43 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 15E02E08001
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:13:43 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA4431DB8038
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:13:42 +0900 (JST)
Date: Tue, 10 May 2011 19:07:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/7] memcg: export memcg swappiness
Message-Id: <20110510190702.7283a81c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110510190216.f4eefef7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

From: Ying Han <yinghan@google.com>
change mem_cgroup's swappiness interface.

Now, memcg's swappiness interface is defined as 'static' and
the value is passed as an argument to try_to_free_xxxx...

This patch adds an function mem_cgroup_swappiness() and export it,
reduce arguments. This interface will be used in async reclaim, later.

I think an function is better than passing arguments because it's
clearer where the swappiness comes from to scan_control.

Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    1 +
 include/linux/swap.h       |    4 +---
 mm/memcontrol.c            |   14 ++++++--------
 mm/vmscan.c                |    9 ++++-----
 4 files changed, 12 insertions(+), 16 deletions(-)

Index: mmotm-May6/include/linux/memcontrol.h
===================================================================
--- mmotm-May6.orig/include/linux/memcontrol.h
+++ mmotm-May6/include/linux/memcontrol.h
@@ -111,6 +111,7 @@ int mem_cgroup_inactive_file_is_low(stru
 unsigned long
 mem_cgroup_zone_reclaimable_pages(struct mem_cgroup *memcg, int nid, int zid);
 int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
+unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru);
Index: mmotm-May6/mm/memcontrol.c
===================================================================
--- mmotm-May6.orig/mm/memcontrol.c
+++ mmotm-May6/mm/memcontrol.c
@@ -1321,7 +1321,7 @@ static unsigned long mem_cgroup_margin(s
 	return margin >> PAGE_SHIFT;
 }
 
-static unsigned int get_swappiness(struct mem_cgroup *memcg)
+unsigned int mem_cgroup_swappiness(struct mem_cgroup *memcg)
 {
 	struct cgroup *cgrp = memcg->css.cgroup;
 
@@ -1704,14 +1704,13 @@ static int mem_cgroup_hierarchical_recla
 		/* we use swappiness of local cgroup */
 		if (check_soft) {
 			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
-				noswap, get_swappiness(victim), zone,
-				&nr_scanned);
+				noswap, zone, &nr_scanned);
 			*total_scanned += nr_scanned;
 			mem_cgroup_soft_steal(victim, is_kswapd, ret);
 			mem_cgroup_soft_scan(victim, is_kswapd, nr_scanned);
 		} else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
-						noswap, get_swappiness(victim));
+					noswap);
 		css_put(&victim->css);
 		/*
 		 * At shrinking usage, we can't check we should stop here or
@@ -3748,8 +3747,7 @@ try_to_free:
 			ret = -EINTR;
 			goto out;
 		}
-		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
-						false, get_swappiness(mem));
+		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL, false);
 		if (!progress) {
 			nr_retries--;
 			/* maybe some writeback is necessary */
@@ -4181,7 +4179,7 @@ static u64 mem_cgroup_swappiness_read(st
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
 
-	return get_swappiness(memcg);
+	return mem_cgroup_swappiness(memcg);
 }
 
 static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
@@ -4867,7 +4865,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	INIT_LIST_HEAD(&mem->oom_notify);
 
 	if (parent)
-		mem->swappiness = get_swappiness(parent);
+		mem->swappiness = mem_cgroup_swappiness(parent);
 	atomic_set(&mem->refcnt, 1);
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
Index: mmotm-May6/include/linux/swap.h
===================================================================
--- mmotm-May6.orig/include/linux/swap.h
+++ mmotm-May6/include/linux/swap.h
@@ -252,11 +252,9 @@ static inline void lru_cache_add_file(st
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
-						  gfp_t gfp_mask, bool noswap,
-						  unsigned int swappiness);
+						  gfp_t gfp_mask, bool noswap);
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
-						unsigned int swappiness,
 						struct zone *zone,
 						unsigned long *nr_scanned);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
Index: mmotm-May6/mm/vmscan.c
===================================================================
--- mmotm-May6.orig/mm/vmscan.c
+++ mmotm-May6/mm/vmscan.c
@@ -2178,7 +2178,6 @@ unsigned long try_to_free_pages(struct z
 
 unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
-						unsigned int swappiness,
 						struct zone *zone,
 						unsigned long *nr_scanned)
 {
@@ -2188,7 +2187,6 @@ unsigned long mem_cgroup_shrink_node_zon
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
 		.may_swap = !noswap,
-		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem,
 	};
@@ -2196,6 +2194,8 @@ unsigned long mem_cgroup_shrink_node_zon
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 
+	sc.swappiness = mem_cgroup_swappiness(mem);
+
 	trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
 						      sc.may_writepage,
 						      sc.gfp_mask);
@@ -2217,8 +2217,7 @@ unsigned long mem_cgroup_shrink_node_zon
 
 unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
 					   gfp_t gfp_mask,
-					   bool noswap,
-					   unsigned int swappiness)
+					   bool noswap)
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
@@ -2228,7 +2227,6 @@ unsigned long try_to_free_mem_cgroup_pag
 		.may_unmap = 1,
 		.may_swap = !noswap,
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
-		.swappiness = swappiness,
 		.order = 0,
 		.mem_cgroup = mem_cont,
 		.nodemask = NULL, /* we don't care the placement */
@@ -2245,6 +2243,7 @@ unsigned long try_to_free_mem_cgroup_pag
 	 * scan does not need to be the current node.
 	 */
 	nid = mem_cgroup_select_victim_node(mem_cont);
+	sc.swappiness = mem_cgroup_swappiness(mem_cont);
 
 	zonelist = NODE_DATA(nid)->node_zonelists;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
