Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 054678D004D
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 00:26:28 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH V7 6/9] Implement the select_victim_node within memcg.
Date: Thu, 21 Apr 2011 21:24:17 -0700
Message-Id: <1303446260-21333-7-git-send-email-yinghan@google.com>
In-Reply-To: <1303446260-21333-1-git-send-email-yinghan@google.com>
References: <1303446260-21333-1-git-send-email-yinghan@google.com>
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
index 9157c4d..7444738 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -83,6 +83,9 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
+extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
+extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
+					const nodemask_t *nodes);
 
 bool mem_cgroup_kswapd_can_sleep(void);
 struct mem_cgroup *mem_cgroup_get_shrink_target(void);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 527ad9a..4696fd8 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -288,6 +288,12 @@ struct mem_cgroup {
 	 */
 	u64 high_wmark_distance;
 	u64 low_wmark_distance;
+
+	/*
+	 * While doing per cgroup background reclaim, we cache the
+	 * last node we reclaimed from
+	 */
+	int last_scanned_node;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -1544,6 +1550,27 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
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
@@ -4753,6 +4780,14 @@ int mem_cgroup_watermark_ok(struct mem_cgroup *mem,
 	return ret;
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
@@ -4828,6 +4863,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
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
