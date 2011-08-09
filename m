Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 49D4C6B016C
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 06:17:39 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id DD8443EE0B5
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:17:36 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C204545DE58
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:17:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9EB1445DE55
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:17:36 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F3941DB804F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:17:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C1EC1DB8042
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:17:36 +0900 (JST)
Date: Tue, 9 Aug 2011 19:10:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v5 3/6]  memg: vmscan pass nodemask
Message-Id: <20110809191018.af81c55d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>


pass memcg's nodemask to try_to_free_pages().

try_to_free_pages can take nodemask as its argument but memcg
doesn't pass it. Considering memcg can be used with cpuset on
big NUMA, memcg should pass nodemask if available.

Now, memcg maintain nodemask with periodic updates. pass it.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Changelog:
 - fixed bugs to pass nodemask.
---
 include/linux/memcontrol.h |    2 +-
 mm/memcontrol.c            |    8 ++++++--
 mm/vmscan.c                |    4 ++--
 3 files changed, 9 insertions(+), 5 deletions(-)

Index: mmotm-Aug3/include/linux/memcontrol.h
===================================================================
--- mmotm-Aug3.orig/include/linux/memcontrol.h
+++ mmotm-Aug3/include/linux/memcontrol.h
@@ -118,7 +118,7 @@ extern void mem_cgroup_end_migration(str
  */
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
-int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
+int mem_cgroup_select_victim_node(struct mem_cgroup *memcg, nodemask_t **mask);
 unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
 					int nid, int zid, unsigned int lrumask);
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,
Index: mmotm-Aug3/mm/memcontrol.c
===================================================================
--- mmotm-Aug3.orig/mm/memcontrol.c
+++ mmotm-Aug3/mm/memcontrol.c
@@ -1618,10 +1618,11 @@ static void mem_cgroup_may_update_nodema
  *
  * Now, we use round-robin. Better algorithm is welcomed.
  */
-int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
+int mem_cgroup_select_victim_node(struct mem_cgroup *mem, nodemask_t **mask)
 {
 	int node;
 
+	*mask = NULL;
 	mem_cgroup_may_update_nodemask(mem);
 	node = mem->last_scanned_node;
 
@@ -1636,6 +1637,8 @@ int mem_cgroup_select_victim_node(struct
 	 */
 	if (unlikely(node == MAX_NUMNODES))
 		node = numa_node_id();
+	else
+		*mask = &mem->scan_nodes;
 
 	mem->last_scanned_node = node;
 	return node;
@@ -1683,8 +1686,9 @@ static void mem_cgroup_numascan_init(str
 }
 
 #else
-int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
+int mem_cgroup_select_victim_node(struct mem_cgroup *mem, nodemask_t **mask)
 {
+	*mask = NULL;
 	return 0;
 }
 
Index: mmotm-Aug3/mm/vmscan.c
===================================================================
--- mmotm-Aug3.orig/mm/vmscan.c
+++ mmotm-Aug3/mm/vmscan.c
@@ -2354,7 +2354,7 @@ unsigned long try_to_free_mem_cgroup_pag
 		.order = 0,
 		.mem_cgroup = mem_cont,
 		.memcg_record = rec,
-		.nodemask = NULL, /* we don't care the placement */
+		.nodemask = NULL,
 		.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 				(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK),
 	};
@@ -2368,7 +2368,7 @@ unsigned long try_to_free_mem_cgroup_pag
 	 * take care of from where we get pages. So the node where we start the
 	 * scan does not need to be the current node.
 	 */
-	nid = mem_cgroup_select_victim_node(mem_cont);
+	nid = mem_cgroup_select_victim_node(mem_cont, &sc.nodemask);
 
 	zonelist = NODE_DATA(nid)->node_zonelists;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
