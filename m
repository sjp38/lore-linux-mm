Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0CDCC6B02A5
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 06:14:19 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6GAEHf9006686
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 16 Jul 2010 19:14:17 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 310E145DE5D
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:14:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 055E245DE4F
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:14:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BE97B1DB803F
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:14:16 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 60A171DB803C
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:14:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 2/7] memcg: mem_cgroup_shrink_node_zone() doesn't need sc.nodemask
In-Reply-To: <20100716191006.7369.A69D9226@jp.fujitsu.com>
References: <20100716191006.7369.A69D9226@jp.fujitsu.com>
Message-Id: <20100716191334.736F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 16 Jul 2010 19:14:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Currently mem_cgroup_shrink_node_zone() call shrink_zone() directly.
thus it doesn't need to initialize sc.nodemask. shrink_zone() doesn't
use it at all.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/swap.h |    3 +--
 mm/memcontrol.c      |    3 +--
 mm/vmscan.c          |    8 ++------
 3 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index ff4acea..bf4eb62 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -244,8 +244,7 @@ extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 extern unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						unsigned int swappiness,
-						struct zone *zone,
-						int nid);
+						struct zone *zone);
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index aba4310..01f38ff 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1307,8 +1307,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 		/* we use swappiness of local cgroup */
 		if (check_soft)
 			ret = mem_cgroup_shrink_node_zone(victim, gfp_mask,
-				noswap, get_swappiness(victim), zone,
-				zone->zone_pgdat->node_id);
+				noswap, get_swappiness(victim), zone);
 		else
 			ret = try_to_free_mem_cgroup_pages(victim, gfp_mask,
 						noswap, get_swappiness(victim));
diff --git a/mm/vmscan.c b/mm/vmscan.c
index bd1d035..be860a0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1929,7 +1929,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						unsigned int swappiness,
-						struct zone *zone, int nid)
+						struct zone *zone)
 {
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
@@ -1940,13 +1940,9 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.order = 0,
 		.mem_cgroup = mem,
 	};
-	nodemask_t nm  = nodemask_of_node(nid);
-
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
-	sc.nodemask = &nm;
-	sc.nr_reclaimed = 0;
-	sc.nr_scanned = 0;
+
 	/*
 	 * NOTE: Although we can get the priority field, using it
 	 * here is not a good idea, since it limits the pages we can scan.
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
