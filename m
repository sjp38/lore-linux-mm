Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 166606B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 06:19:24 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 980333EE0B5
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:19:21 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7625C45DEAD
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:19:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F36F45DE9E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:19:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 522201DB803C
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:19:21 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0059B1DB8038
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:19:21 +0900 (JST)
Date: Tue, 9 Aug 2011 19:12:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v5 5/6]  memg: vmscan select victim node by weight
Message-Id: <20110809191202.955d9101.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>


This patch implements a node selection logic based on each node's weight.

This patch adds a new array of nodescan_tickets[]. This array holds
each node's scan weight in a tuple of 2 values. as

    for (i = 0, total_weight = 0; i < nodes; i++) {
        weight = node->weight;
        nodescan_tickets[i].start = total_weight;
        nodescan_tickets[i].length = weight;
    }

After this, a lottery logic as 'ticket = random32()/total_weight'
will make a ticket and bserach(ticket, nodescan_tickets[])
will find a node which holds [start, length] contains ticket.
(This is a lottery scheduling.)

By this, node will be selected in fair manner proportinal to
its weight.

This patch improve the scan time. Following is a test result
ot kernel-make on 4-node fake-numa under 500M limit, with 8cpus.
2cpus per node.

[Before patch]
 772.52user 305.67system 4:11.48elapsed 428%CPU
 (0avgtext+0avgdata 1457264maxresident)k
 4797592inputs+5483240outputs (12550major+35707629minor)pagefaults 0swaps

[After patch]
 773.73user 305.09system 3:51.28elapsed 466%CPU
 (0avgtext+0avgdata 1458464maxresident)k
 4400264inputs+4797056outputs (5578major+35690202minor)pagefaults 0swaps

elapsed time and major faults are reduced.

Here, vmscan_stat shows

[Before patch]
  scanned_pages_by_limit 3926782
  scanned_anon_pages_by_limit 1511090
  scanned_file_pages_by_limit 2415692
  elapsed_ns_by_limit 69528714562

[After patch]
  scanned_pages_by_limit 4326462
  scanned_anon_pages_by_limit 1310619
  scanned_file_pages_by_limit 3015843
  elapsed_ns_by_limit 42495200307

This patch helps to scan file caches rather than scanning anon.
and elapsed time is much reduced.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    3 
 mm/memcontrol.c            |  150 ++++++++++++++++++++++++++++++++++++++-------
 mm/vmscan.c                |    4 -
 3 files changed, 131 insertions(+), 26 deletions(-)

Index: mmotm-Aug3/mm/memcontrol.c
===================================================================
--- mmotm-Aug3.orig/mm/memcontrol.c
+++ mmotm-Aug3/mm/memcontrol.c
@@ -49,6 +49,9 @@
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
 #include <linux/oom.h>
+#include <linux/random.h>
+#include <linux/bsearch.h>
+#include <linux/cpuset.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -151,6 +154,11 @@ struct mem_cgroup_lru_info {
 	struct mem_cgroup_per_node *nodeinfo[MAX_NUMNODES];
 };
 
+struct numascan_ticket {
+	int nid;
+	unsigned int start, tickets;
+};
+
 /*
  * Cgroups above their limits are maintained in a RB-Tree, independent of
  * their hierarchy representation
@@ -287,7 +295,10 @@ struct mem_cgroup {
 	atomic_t	numainfo_events;
 	atomic_t	numainfo_updating;
 	struct work_struct	numainfo_update_work;
-	unsigned long total_weight;
+	unsigned long	total_weight;
+	int		numascan_generation;
+	int		numascan_tickets_num[2];
+	struct numascan_ticket *numascan_tickets[2];
 #endif
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
@@ -1660,6 +1671,46 @@ mem_cgroup_calc_numascan_weight(struct m
 }
 
 /*
+ * For lottery scheduling, this routine disributes "ticket" for
+ * scanning to each node. ticket will be recored into numascan_ticket
+ * array and this array will be used for scheduling, lator.
+ * For make lottery wair, we limit the sum of tickets almost 0xffff.
+ * Later, random() & 0xffff will do proportional fair lottery.
+ */
+#define NUMA_TICKET_SHIFT	(16)
+#define NUMA_TICKET_FACTOR	((1 << NUMA_TICKET_SHIFT) - 1)
+static void mem_cgroup_update_numascan_tickets(struct mem_cgroup *memcg)
+{
+	struct numascan_ticket *nt;
+	unsigned int node_ticket, assigned_tickets;
+	u64 weight;
+	int nid, assigned_num, generation;
+
+	/* update ticket information by double buffering */
+	generation = memcg->numascan_generation ^ 0x1;
+
+	nt = memcg->numascan_tickets[generation];
+	assigned_tickets = 0;
+	assigned_num = 0;
+	for_each_node_mask(nid, memcg->scan_nodes) {
+		weight = memcg->info.nodeinfo[nid]->weight;
+		node_ticket = div64_u64(weight << NUMA_TICKET_SHIFT,
+					memcg->total_weight + 1);
+		if (!node_ticket)
+			node_ticket = 1;
+		nt->nid = nid;
+		nt->start = assigned_tickets;
+		nt->tickets = node_ticket;
+		assigned_tickets += node_ticket;
+		nt++;
+		assigned_num++;
+	}
+	memcg->numascan_tickets_num[generation] = assigned_num;
+	smp_wmb();
+	memcg->numascan_generation = generation;
+}
+
+/*
  * Update all node's scan weight in background.
  */
 static void mem_cgroup_numainfo_update_work(struct work_struct *work)
@@ -1672,6 +1723,8 @@ static void mem_cgroup_numainfo_update_w
 
 	memcg->total_weight = mem_cgroup_calc_numascan_weight(memcg);
 
+	synchronize_rcu();
+	mem_cgroup_update_numascan_tickets(memcg);
 	atomic_set(&memcg->numainfo_updating, 0);
 	css_put(&memcg->css);
 }
@@ -1698,6 +1751,18 @@ static void mem_cgroup_may_update_nodema
 	schedule_work(&mem->numainfo_update_work);
 }
 
+static int node_weight_compare(const void *key, const void *elt)
+{
+	unsigned long lottery = (unsigned long)key;
+	struct numascan_ticket *nt = (struct numascan_ticket *)elt;
+
+	if (lottery < nt->start)
+		return -1;
+	if (lottery > (nt->start + nt->tickets))
+		return 1;
+	return 0;
+}
+
 /*
  * Selecting a node where we start reclaim from. Because what we need is just
  * reducing usage counter, start from anywhere is O,K. Considering
@@ -1707,32 +1772,38 @@ static void mem_cgroup_may_update_nodema
  * we'll use or we've used. So, it may make LRU bad. And if several threads
  * hit limits, it will see a contention on a node. But freeing from remote
  * node means more costs for memory reclaim because of memory latency.
- *
- * Now, we use round-robin. Better algorithm is welcomed.
  */
-int mem_cgroup_select_victim_node(struct mem_cgroup *mem, nodemask_t **mask)
+int mem_cgroup_select_victim_node(struct mem_cgroup *memcg, nodemask_t **mask,
+				struct memcg_scanrecord *rec)
 {
-	int node;
+	int node = MAX_NUMNODES;
+	struct numascan_ticket *nt;
+	unsigned long lottery;
+	int generation;
 
+	if (rec->context == SCAN_BY_SHRINK)
+		goto out;
+
+	mem_cgroup_may_update_nodemask(memcg);
 	*mask = NULL;
-	mem_cgroup_may_update_nodemask(mem);
-	node = mem->last_scanned_node;
+	lottery = random32() & NUMA_TICKET_FACTOR;
 
-	node = next_node(node, mem->scan_nodes);
-	if (node == MAX_NUMNODES)
-		node = first_node(mem->scan_nodes);
-	/*
-	 * We call this when we hit limit, not when pages are added to LRU.
-	 * No LRU may hold pages because all pages are UNEVICTABLE or
-	 * memcg is too small and all pages are not on LRU. In that case,
-	 * we use curret node.
-	 */
-	if (unlikely(node == MAX_NUMNODES))
+	rcu_read_lock();
+	generation = memcg->numascan_generation;
+	nt = bsearch((void *)lottery,
+		memcg->numascan_tickets[generation],
+		memcg->numascan_tickets_num[generation],
+		sizeof(struct numascan_ticket), node_weight_compare);
+	rcu_read_unlock();
+	if (nt)
+		node = nt->nid;
+out:
+	if (unlikely(node == MAX_NUMNODES)) {
 		node = numa_node_id();
-	else
-		*mask = &mem->scan_nodes;
+		*mask = NULL;
+	} else
+		*mask = &memcg->scan_nodes;
 
-	mem->last_scanned_node = node;
 	return node;
 }
 
@@ -1771,14 +1842,42 @@ bool mem_cgroup_reclaimable(struct mem_c
 	return false;
 }
 
-static void mem_cgroup_numascan_init(struct mem_cgroup *memcg)
+static bool mem_cgroup_numascan_init(struct mem_cgroup *memcg)
 {
+	struct numascan_ticket *nt;
+	int nr_nodes;
+
 	INIT_WORK(&memcg->numainfo_update_work,
 		mem_cgroup_numainfo_update_work);
+
+	nr_nodes = num_possible_nodes();
+	nt = kmalloc(sizeof(struct numascan_ticket) * nr_nodes,
+			GFP_KERNEL);
+	if (!nt)
+		return false;
+	memcg->numascan_tickets[0] = nt;
+	nt = kmalloc(sizeof(struct numascan_ticket) * nr_nodes,
+			GFP_KERNEL);
+	if (!nt) {
+		kfree(memcg->numascan_tickets[0]);
+		memcg->numascan_tickets[0] = NULL;
+		return false;
+	}
+	memcg->numascan_tickets[1] = nt;
+	memcg->numascan_tickets_num[0] = 0;
+	memcg->numascan_tickets_num[1] = 0;
+	return true;
+}
+
+static void mem_cgroup_numascan_free(struct mem_cgroup *memcg)
+{
+	kfree(memcg->numascan_tickets[0]);
+	kfree(memcg->numascan_tickets[1]);
 }
 
 #else
-int mem_cgroup_select_victim_node(struct mem_cgroup *mem, nodemask_t **mask)
+int mem_cgroup_select_victim_node(struct mem_cgroup *mem, nodemask_t **mask,
+				struct memcg_scanrecord *rec)
 {
 	*mask = NULL;
 	return 0;
@@ -1791,6 +1890,9 @@ bool mem_cgroup_reclaimable(struct mem_c
 static void mem_cgroup_numascan_init(struct mem_cgroup *memcg)
 {
 }
+static bool mem_cgroup_numascan_free(struct mem_cgroup *memcg)
+{
+}
 #endif
 
 static void __mem_cgroup_record_scanstat(unsigned long *stats,
@@ -5080,6 +5182,7 @@ static void __mem_cgroup_free(struct mem
 	int node;
 
 	mem_cgroup_remove_from_trees(mem);
+	mem_cgroup_numascan_free(mem);
 	free_css_id(&mem_cgroup_subsys, &mem->css);
 
 	for_each_node_state(node, N_POSSIBLE)
@@ -5218,7 +5321,8 @@ mem_cgroup_create(struct cgroup_subsys *
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
 	spin_lock_init(&mem->scanstat.lock);
-	mem_cgroup_numascan_init(mem);
+	if (!mem_cgroup_numascan_init(mem))
+		goto free_out;
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);
Index: mmotm-Aug3/mm/vmscan.c
===================================================================
--- mmotm-Aug3.orig/mm/vmscan.c
+++ mmotm-Aug3/mm/vmscan.c
@@ -2378,9 +2378,9 @@ unsigned long try_to_free_mem_cgroup_pag
 	 * take care of from where we get pages. So the node where we start the
 	 * scan does not need to be the current node.
 	 */
-	nid = mem_cgroup_select_victim_node(mem_cont, &sc.nodemask);
+	nid = mem_cgroup_select_victim_node(mem_cont, &sc.nodemask, rec);
 
-	zonelist = NODE_DATA(nid)->node_zonelists;
+	zonelist = &NODE_DATA(nid)->node_zonelists[0];
 
 	trace_mm_vmscan_memcg_reclaim_begin(0,
 					    sc.may_writepage,
Index: mmotm-Aug3/include/linux/memcontrol.h
===================================================================
--- mmotm-Aug3.orig/include/linux/memcontrol.h
+++ mmotm-Aug3/include/linux/memcontrol.h
@@ -118,7 +118,8 @@ extern void mem_cgroup_end_migration(str
  */
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
-int mem_cgroup_select_victim_node(struct mem_cgroup *memcg, nodemask_t **mask);
+int mem_cgroup_select_victim_node(struct mem_cgroup *memcg, nodemask_t **mask,
+				struct memcg_scanrecord *rec);
 unsigned long mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg,
 					int nid, int zid, unsigned int lrumask);
 struct zone_reclaim_stat *mem_cgroup_get_reclaim_stat(struct mem_cgroup *memcg,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
