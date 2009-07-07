Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7849B6B0055
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 05:04:33 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n679m4mP008560
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 7 Jul 2009 18:48:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E4A3B45DE50
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:48:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BED4D45DE4F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:48:03 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 60738E0800A
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:48:03 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E7B4A1DB8042
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 18:48:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC PATCH 2/2] Don't continue reclaim if the system have plenty free memory
In-Reply-To: <20090707182947.0C6D.A69D9226@jp.fujitsu.com>
References: <20090707182947.0C6D.A69D9226@jp.fujitsu.com>
Message-Id: <20090707184714.0C73.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  7 Jul 2009 18:48:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Subject: [PATCH] Don't continue reclaim if the system have plenty free memory

On concurrent reclaim situation, if one reclaimer makes OOM, maybe other
reclaimer can stop reclaim because OOM killer makes enough free memory.

But current kernel doesn't have its logic. Then, we can face following accidental
2nd OOM scenario.

1. System memory is used by only one big process.
2. memory shortage occur and concurrent reclaim start.
3. One reclaimer makes OOM and OOM killer kill above big process.
4. Almost reclaimable page will be freed.
5. Another reclaimer can't find any reclaimable page because those pages are
   already freed.
6. Then, system makes accidental and unnecessary 2nd OOM killer.


Plus, nowaday datacenter system have badboy process monitoring system and
it kill too much memory consumption process.
But it don't stop other reclaimer and it makes accidental 2nd OOM by the
same reason.


This patch have one good side effect. it increase reclaim depended benchmark
performance.

e.g.
=====
% ./hackbench 140 process 100

before:
	Time: 93.361
after:
	Time: 28.799



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/buffer.c          |    2 +-
 include/linux/swap.h |    3 ++-
 mm/page_alloc.c      |    3 ++-
 mm/vmscan.c          |   29 ++++++++++++++++++++++++++++-
 4 files changed, 33 insertions(+), 4 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -87,6 +87,9 @@ struct scan_control {
 	 */
 	nodemask_t	*nodemask;
 
+	/* Caller's preferred zone. */
+	struct zone	*preferred_zone;
+
 	/* Pluggable isolate pages callback */
 	unsigned long (*isolate_pages)(unsigned long nr, struct list_head *dst,
 			unsigned long *scanned, int order, int mode,
@@ -1535,6 +1538,10 @@ static void shrink_zone(int priority, st
 	unsigned long nr_reclaimed = sc->nr_reclaimed;
 	unsigned long swap_cluster_max = sc->swap_cluster_max;
 	int noswap = 0;
+	int classzone_idx = 0;
+
+	if (sc->preferred_zone)
+		classzone_idx = zone_idx(sc->preferred_zone);
 
 	/* If we have no swap space, do not bother scanning anon pages. */
 	if (!sc->may_swap || (nr_swap_pages <= 0)) {
@@ -1583,6 +1590,20 @@ static void shrink_zone(int priority, st
 		if (nr_reclaimed > swap_cluster_max &&
 			priority < DEF_PRIORITY && !current_is_kswapd())
 			break;
+
+		/*
+		 * Now, we have plenty free memory.
+		 * Perhaps, big processes exited or they killed by OOM killer.
+		 * To continue reclaim doesn't make any sense.
+		 */
+		if (zone_page_state(zone, NR_FREE_PAGES) >
+		    zone_lru_pages(zone) &&
+		    zone_watermark_ok(zone, sc->order, high_wmark_pages(zone),
+				      classzone_idx, 0)) {
+			/* fake result for reclaim stop */
+			nr_reclaimed += swap_cluster_max;
+			break;
+		}
 	}
 
 	sc->nr_reclaimed = nr_reclaimed;
@@ -1767,7 +1788,8 @@ out:
 }
 
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-				gfp_t gfp_mask, nodemask_t *nodemask)
+				gfp_t gfp_mask, nodemask_t *nodemask,
+				struct zone *preferred_zone)
 {
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
@@ -1780,6 +1802,7 @@ unsigned long try_to_free_pages(struct z
 		.mem_cgroup = NULL,
 		.isolate_pages = isolate_pages_global,
 		.nodemask = nodemask,
+		.preferred_zone = preferred_zone,
 	};
 
 	return do_try_to_free_pages(zonelist, &sc);
@@ -1808,6 +1831,10 @@ unsigned long try_to_free_mem_cgroup_pag
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
 	zonelist = NODE_DATA(numa_node_id())->node_zonelists;
+	first_zones_zonelist(zonelist,
+			     gfp_zone(sc.gfp_mask), NULL,
+			     &sc.preferred_zone);
+
 	return do_try_to_free_pages(zonelist, &sc);
 }
 #endif
Index: b/fs/buffer.c
===================================================================
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -290,7 +290,7 @@ static void free_more_memory(void)
 						&zone);
 		if (zone)
 			try_to_free_pages(node_zonelist(nid, GFP_NOFS), 0,
-						GFP_NOFS, NULL);
+					  GFP_NOFS, NULL, zone);
 	}
 }
 
Index: b/include/linux/swap.h
===================================================================
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -213,7 +213,8 @@ static inline void lru_cache_add_active_
 
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
-					gfp_t gfp_mask, nodemask_t *mask);
+				       gfp_t gfp_mask, nodemask_t *mask,
+				       struct zone *preferred_zone);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 						  gfp_t gfp_mask, bool noswap,
 						  unsigned int swappiness);
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1629,7 +1629,8 @@ __alloc_pages_direct_reclaim(gfp_t gfp_m
 	reclaim_state.reclaimed_slab = 0;
 	p->reclaim_state = &reclaim_state;
 
-	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask, nodemask);
+	*did_some_progress = try_to_free_pages(zonelist, order, gfp_mask,
+					       nodemask, preferred_zone);
 
 	p->reclaim_state = NULL;
 	lockdep_clear_current_reclaim_state();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
