Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 05A679000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 03:57:59 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 456763EE0C5
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:57:55 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C2B945DE5A
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:57:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C8DC45DE56
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:57:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E639CEF8001
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:57:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A874E1DB8042
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 16:57:54 +0900 (JST)
Date: Wed, 27 Apr 2011 16:51:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCHv2] memcg: reclaim memory from node in round-robin
Message-Id: <20110427165120.a60c6609.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Ying Han <yinghan@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

I changed the logic a little and add a filter for skipping nodes.
With large NUMA, tasks may under cpuset or mempolicy and the usage of memory
can be unbalanced. So, I think a filter is required.

==
Now, memory cgroup's direct reclaim frees memory from the current node.
But this has some troubles. In usual, when a set of threads works in
cooperative way, they are tend to on the same node. So, if they hit
limits under memcg, it will reclaim memory from themselves, it may be
active working set.

For example, assume 2 node system which has Node 0 and Node 1
and a memcg which has 1G limit. After some work, file cacne remains and
and usages are
   Node 0:  1M
   Node 1:  998M.

and run an application on Node 0, it will eats its foot before freeing
unnecessary file caches.

This patch adds round-robin for NUMA and adds equal pressure to each
node. When using cpuset's spread memory feature, this will work very well.


From: Ying Han <yinghan@google.com>
Signed-off-by: Ying Han <yinghan@google.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Changelog v1->v2:
  - fixed comments.
  - added a logic to avoid scanning unused node.

---
 include/linux/memcontrol.h |    1 
 mm/memcontrol.c            |   98 ++++++++++++++++++++++++++++++++++++++++++---
 mm/vmscan.c                |    9 +++-
 3 files changed, 101 insertions(+), 7 deletions(-)

Index: memcg/include/linux/memcontrol.h
===================================================================
--- memcg.orig/include/linux/memcontrol.h
+++ memcg/include/linux/memcontrol.h
@@ -108,6 +108,7 @@ extern void mem_cgroup_end_migration(str
  */
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
+int mem_cgroup_select_victim_node(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
 				       struct zone *zone,
 				       enum lru_list lru);
Index: memcg/mm/memcontrol.c
===================================================================
--- memcg.orig/mm/memcontrol.c
+++ memcg/mm/memcontrol.c
@@ -237,6 +237,11 @@ struct mem_cgroup {
 	 * reclaimed from.
 	 */
 	int last_scanned_child;
+	int last_scanned_node;
+#if MAX_NUMNODES > 1
+	nodemask_t	scan_nodes;
+	unsigned long   next_scan_node_update;
+#endif
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
@@ -650,18 +655,27 @@ static void mem_cgroup_soft_scan(struct 
 	this_cpu_add(mem->stat->events[MEM_CGROUP_EVENTS_SOFT_SCAN], val);
 }
 
+static unsigned long
+mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum lru_list idx)
+{
+	struct mem_cgroup_per_zone *mz;
+	u64 total;
+	int zid;
+
+	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
+		mz = mem_cgroup_zoneinfo(mem, nid, zid);
+		total += MEM_CGROUP_ZSTAT(mz, idx);
+	}
+	return total;
+}
 static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
 					enum lru_list idx)
 {
-	int nid, zid;
-	struct mem_cgroup_per_zone *mz;
+	int nid;
 	u64 total = 0;
 
 	for_each_online_node(nid)
-		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
-			mz = mem_cgroup_zoneinfo(mem, nid, zid);
-			total += MEM_CGROUP_ZSTAT(mz, idx);
-		}
+		total += mem_cgroup_get_zonestat_node(mem, nid, idx);
 	return total;
 }
 
@@ -1471,6 +1485,77 @@ mem_cgroup_select_victim(struct mem_cgro
 	return ret;
 }
 
+#if MAX_NUMNODES > 1
+
+/*
+ * Update nodemask always is not very good. Even if we have empty
+ * list, or wrong list here, we can start from some node and traverse all nodes
+ * based on zonelist. So, update the list loosely once in 10 secs.
+ *
+ */
+static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
+{
+	int nid;
+
+	if (time_after(mem->next_scan_node_update, jiffies))
+		return;
+
+	mem->next_scan_node_update = jiffies + 10*HZ;
+	/* make a nodemask where this memcg uses memory from */
+	mem->scan_nodes = node_states[N_HIGH_MEMORY];
+
+	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
+
+		if (mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_FILE) ||
+		    mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_FILE))
+			continue;
+
+		if (total_swap_pages &&
+		    (mem_cgroup_get_zonestat_node(mem, nid, LRU_INACTIVE_ANON) ||
+		     mem_cgroup_get_zonestat_node(mem, nid, LRU_ACTIVE_ANON)))
+			continue;
+		node_clear(nid, mem->scan_nodes);
+	}
+
+}
+
+/*
+ * Selecting a node where we start reclaim from. Because what we need is just
+ * reducing usage counter, start from anywhere is O,K. Considering
+ * memory reclaim from current node, there are pros. and cons.
+ *
+ * Freeing memory from current node means freeing memory from a node which
+ * we'll use or we've used. So, it may make LRU bad. And if several threads
+ * hit limits, it will see a contention on a node. But freeing from remote
+ * node means more costs for memory reclaim because of memory latency.
+ *
+ * Now, we use round-robin. Better algorithm is welcomed.
+ */
+int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
+{
+	int node;
+
+	mem_cgroup_may_update_nodemask(mem);
+	node = mem->last_scanned_node;
+
+	node = next_node(node, mem->scan_nodes);
+	if (node == MAX_NUMNODES) {
+		node = first_node(mem->scan_nodes);
+		if (unlikely(node == MAX_NUMNODES))
+			node = numa_node_id();
+	}
+
+	mem->last_scanned_node = node;
+	return node;
+}
+
+#else
+int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
+{
+	return 0;
+}
+#endif
+
 /*
  * Scan the hierarchy if needed to reclaim memory. We remember the last child
  * we reclaimed from, so that we don't end up penalizing one child extensively
@@ -4678,6 +4763,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		res_counter_init(&mem->memsw, NULL);
 	}
 	mem->last_scanned_child = 0;
+	mem->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&mem->oom_notify);
 
 	if (parent)
Index: memcg/mm/vmscan.c
===================================================================
--- memcg.orig/mm/vmscan.c
+++ memcg/mm/vmscan.c
@@ -2198,6 +2198,7 @@ unsigned long try_to_free_mem_cgroup_pag
 {
 	struct zonelist *zonelist;
 	unsigned long nr_reclaimed;
+	int nid;
 	struct scan_control sc = {
 		.may_writepage = !laptop_mode,
 		.may_unmap = 1,
@@ -2208,10 +2209,16 @@ unsigned long try_to_free_mem_cgroup_pag
 		.mem_cgroup = mem_cont,
 		.nodemask = NULL, /* we don't care the placement */
 	};
+	/*
+	 * Unlike direct reclaim via alloc_pages(), memcg's reclaim
+	 * don't take care of from where we get pages . So, the node where
+	 * we start scan is not needed to be current node.
+	 */
+	nid = mem_cgroup_select_victim_node(mem_cont);
 
 	sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
 			(GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
-	zonelist = NODE_DATA(numa_node_id())->node_zonelists;
+	zonelist = NODE_DATA(nid)->node_zonelists;
 
 	trace_mm_vmscan_memcg_reclaim_begin(0,
 					    sc.may_writepage,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
