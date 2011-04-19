Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2102F900087
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 23:58:59 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V6 05/10] Implement the select_victim_node within memcg.
Date: Mon, 18 Apr 2011 20:57:41 -0700
Message-Id: <1303185466-2532-6-git-send-email-yinghan@google.com>
In-Reply-To: <1303185466-2532-1-git-send-email-yinghan@google.com>
References: <1303185466-2532-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: linux-mm@kvack.org

This add the mechanism for background reclaim which we remember the
last scanned node and always starting from the next one each time.
The simple round-robin fasion provide the fairness between nodes for
each memcg.

changelog v6..v5:
1. fix the correct comment style.

changelog v5..v4:
1. initialize the last_scanned_node to MAX_NUMNODES.

changelog v4..v3:
1. split off from the per-memcg background reclaim patch.

Signed-off-by: Ying Han <yinghan@google.com>
---
 include/linux/memcontrol.h |    3 +++
 mm/memcontrol.c            |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index f7ffd1f..d4ff7f2 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -88,6 +88,9 @@ extern int mem_cgroup_init_kswapd(struct mem_cgroup *mem,
 				  struct kswapd *kswapd_p);
 extern void mem_cgroup_clear_kswapd(struct mem_cgroup *mem);
 extern wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem);
+extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
+extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
+					const nodemask_t *nodes);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8761a6f..06fddd2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -279,6 +279,12 @@ struct mem_cgroup {
 	u64 high_wmark_distance;
 	u64 low_wmark_distance;
 
+	/*
+	 * While doing per cgroup background reclaim, we cache the
+	 * last node we reclaimed from
+	 */
+	int last_scanned_node;
+
 	wait_queue_head_t *kswapd_wait;
 };
 
@@ -1536,6 +1542,27 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 }
 
 /*
+ * Visit the first node after the last_scanned_node of @mem and use that to
+ * reclaim free pages from.
+ */
+int
+mem_cgroup_select_victim_node(struct mem_cgroup *mem, const nodemask_t *nodes)
+{
+	int next_nid;
+	int last_scanned;
+
+	last_scanned = mem->last_scanned_node;
+	next_nid = next_node(last_scanned, *nodes);
+
+	if (next_nid == MAX_NUMNODES)
+		next_nid = first_node(*nodes);
+
+	mem->last_scanned_node = next_nid;
+
+	return next_nid;
+}
+
+/*
  * Check OOM-Killer is already running under our hierarchy.
  * If someone is running, return false.
  */
@@ -4699,6 +4726,14 @@ wait_queue_head_t *mem_cgroup_kswapd_wait(struct mem_cgroup *mem)
 	return mem->kswapd_wait;
 }
 
+int mem_cgroup_last_scanned_node(struct mem_cgroup *mem)
+{
+	if (!mem)
+		return -1;
+
+	return mem->last_scanned_node;
+}
+
 static int mem_cgroup_soft_limit_tree_init(void)
 {
 	struct mem_cgroup_tree_per_node *rtpn;
@@ -4774,6 +4809,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 		res_counter_init(&mem->memsw, NULL);
 	}
 	mem->last_scanned_child = 0;
+	mem->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&mem->oom_notify);
 
 	if (parent)
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
