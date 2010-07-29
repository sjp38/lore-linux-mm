Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DC47E6B02A7
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 01:28:13 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6T5SBgP026847
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 29 Jul 2010 14:28:11 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 180C645DE57
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:28:11 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D63C845DE53
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:28:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 91CB71DB805F
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:28:10 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 355B91DB805A
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 14:28:10 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/5] memcg: mem_cgroup_shrink_node_zone() doesn't need sc.nodemask
In-Reply-To: <20100729140700.4AA2.A69D9226@jp.fujitsu.com>
References: <20100729140700.4AA2.A69D9226@jp.fujitsu.com>
Message-Id: <20100729142735.4AAE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 29 Jul 2010 14:28:09 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Currently mem_cgroup_shrink_node_zone() call shrink_zone() directly.
thus it doesn't need to initialize sc.nodemask because shrink_zone()
doesn't use it at all.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/swap.h |    3 +--
 mm/memcontrol.c      |    3 +--
 mm/vmscan.c          |    5 +----
 3 files changed, 3 insertions(+), 8 deletions(-)

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
index 2600776..fee5cfa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1282,8 +1282,7 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
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
index 102ee3a..5e37c84 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1932,7 +1932,7 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 						gfp_t gfp_mask, bool noswap,
 						unsigned int swappiness,
-						struct zone *zone, int nid)
+						struct zone *zone)
 {
 	struct scan_control sc = {
 		.nr_to_reclaim = SWAP_CLUSTER_MAX,
@@ -1943,11 +1943,8 @@ unsigned long mem_cgroup_shrink_node_zone(struct mem_cgroup *mem,
 		.order = 0,
 		.mem_cgroup = mem,
 	};
-	nodemask_t nm  = nodemask_of_node(nid);
-
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
-	sc.nodemask = &nm;
 
 	trace_mm_vmscan_memcg_softlimit_reclaim_begin(0,
 						      sc.may_writepage,
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
