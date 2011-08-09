Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2DF056B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 06:15:55 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6E9503EE0BC
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:15:52 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 539F645DE5A
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:15:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 308E545DE58
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:15:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 402DE1DB8053
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:15:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C4BA81DB804F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 19:15:48 +0900 (JST)
Date: Tue, 9 Aug 2011 19:08:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH v5 1/6]  memg: better numa scanning
Message-Id: <20110809190824.99347a0f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110809190450.16d7f845.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>


Making memcg numa's scanning information update by schedule_work().

Now, memcg's numa information is updated under a thread doing
memory reclaim. It's not very heavy weight now. But upcoming updates
around numa scanning will add more works. This patch makes
the update be done by schedule_work() and reduce latency caused
by this updates.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   42 ++++++++++++++++++++++++++++++------------
 1 file changed, 30 insertions(+), 12 deletions(-)

Index: mmotm-Aug3/mm/memcontrol.c
===================================================================
--- mmotm-Aug3.orig/mm/memcontrol.c
+++ mmotm-Aug3/mm/memcontrol.c
@@ -285,6 +285,7 @@ struct mem_cgroup {
 	nodemask_t	scan_nodes;
 	atomic_t	numainfo_events;
 	atomic_t	numainfo_updating;
+	struct work_struct	numainfo_update_work;
 #endif
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
@@ -1567,6 +1568,23 @@ static bool test_mem_cgroup_node_reclaim
 }
 #if MAX_NUMNODES > 1
 
+static void mem_cgroup_numainfo_update_work(struct work_struct *work)
+{
+	struct mem_cgroup *memcg;
+	int nid;
+
+	memcg = container_of(work, struct mem_cgroup, numainfo_update_work);
+
+	memcg->scan_nodes = node_states[N_HIGH_MEMORY];
+	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
+		if (!test_mem_cgroup_node_reclaimable(memcg, nid, false))
+			node_clear(nid, memcg->scan_nodes);
+	}
+	atomic_set(&memcg->numainfo_updating, 0);
+	css_put(&memcg->css);
+}
+
+
 /*
  * Always updating the nodemask is not very good - even if we have an empty
  * list or the wrong list here, we can start from some node and traverse all
@@ -1575,7 +1593,6 @@ static bool test_mem_cgroup_node_reclaim
  */
 static void mem_cgroup_may_update_nodemask(struct mem_cgroup *mem)
 {
-	int nid;
 	/*
 	 * numainfo_events > 0 means there was at least NUMAINFO_EVENTS_TARGET
 	 * pagein/pageout changes since the last update.
@@ -1584,18 +1601,9 @@ static void mem_cgroup_may_update_nodema
 		return;
 	if (atomic_inc_return(&mem->numainfo_updating) > 1)
 		return;
-
-	/* make a nodemask where this memcg uses memory from */
-	mem->scan_nodes = node_states[N_HIGH_MEMORY];
-
-	for_each_node_mask(nid, node_states[N_HIGH_MEMORY]) {
-
-		if (!test_mem_cgroup_node_reclaimable(mem, nid, false))
-			node_clear(nid, mem->scan_nodes);
-	}
-
 	atomic_set(&mem->numainfo_events, 0);
-	atomic_set(&mem->numainfo_updating, 0);
+	css_get(&mem->css);
+	schedule_work(&mem->numainfo_update_work);
 }
 
 /*
@@ -1668,6 +1676,12 @@ bool mem_cgroup_reclaimable(struct mem_c
 	return false;
 }
 
+static void mem_cgroup_numascan_init(struct mem_cgroup *memcg)
+{
+	INIT_WORK(&memcg->numainfo_update_work,
+		mem_cgroup_numainfo_update_work);
+}
+
 #else
 int mem_cgroup_select_victim_node(struct mem_cgroup *mem)
 {
@@ -1678,6 +1692,9 @@ bool mem_cgroup_reclaimable(struct mem_c
 {
 	return test_mem_cgroup_node_reclaimable(mem, 0, noswap);
 }
+static void mem_cgroup_numascan_init(struct mem_cgroup *memcg)
+{
+}
 #endif
 
 static void __mem_cgroup_record_scanstat(unsigned long *stats,
@@ -5097,6 +5114,7 @@ mem_cgroup_create(struct cgroup_subsys *
 	mem->move_charge_at_immigrate = 0;
 	mutex_init(&mem->thresholds_lock);
 	spin_lock_init(&mem->scanstat.lock);
+	mem_cgroup_numascan_init(mem);
 	return &mem->css;
 free_out:
 	__mem_cgroup_free(mem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
