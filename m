Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DF41A8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 05:38:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2F46B3EE0C5
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:38:17 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 17F8E45DE93
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:38:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EB22445DE91
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:38:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DBCC21DB803B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:38:16 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 996111DB8037
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 18:38:16 +0900 (JST)
Date: Mon, 25 Apr 2011 18:31:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/7] memcg: select victim node in round robin.
Message-Id: <20110425183140.57a6848c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>

Not changed from Ying's.
==
This add the mechanism for background reclaim which we remember the
last scanned node and always starting from the next one each time.
The simple round-robin fasion provide the fairness between nodes for
each memcg.

>From :  Ying Han <yinghan@google.com>
Signed-off-by: Ying Han <yinghan@google.com>
Sigend-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/memcontrol.h |    3 +++
 mm/memcontrol.c            |   36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 39 insertions(+)

Index: memcg/include/linux/memcontrol.h
===================================================================
--- memcg.orig/include/linux/memcontrol.h
+++ memcg/include/linux/memcontrol.h
@@ -85,6 +85,9 @@ int task_in_mem_cgroup(struct task_struc
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 extern int mem_cgroup_watermark_ok(struct mem_cgroup *mem, int charge_flags);
+extern int mem_cgroup_last_scanned_node(struct mem_cgroup *mem);
+extern int mem_cgroup_select_victim_node(struct mem_cgroup *mem,
+					const nodemask_t *nodes);
 
 static inline
 int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
Index: memcg/mm/memcontrol.c
===================================================================
--- memcg.orig/mm/memcontrol.c
+++ memcg/mm/memcontrol.c
@@ -283,6 +283,12 @@ struct mem_cgroup {
 	 * used to calculate the low/high_wmarks based on the limit_in_bytes.
 	 */
 	u64 high_wmark_distance;
+
+	/*
+	 * While doing per cgroup background reclaim, we cache the
+	 * last node we reclaimed from
+	 */
+	int last_scanned_node;
 };
 
 /* Stuffs for move charges at task migration. */
@@ -1611,6 +1617,27 @@ static int mem_cgroup_hierarchical_recla
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
@@ -4730,6 +4757,14 @@ int mem_cgroup_watermark_ok(struct mem_c
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
@@ -4805,6 +4840,7 @@ mem_cgroup_create(struct cgroup_subsys *
 		res_counter_init(&mem->memsw, NULL);
 	}
 	mem->last_scanned_child = 0;
+	mem->last_scanned_node = MAX_NUMNODES;
 	INIT_LIST_HEAD(&mem->oom_notify);
 
 	if (parent)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
