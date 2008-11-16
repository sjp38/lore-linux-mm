Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp02.au.ibm.com (8.13.1/8.13.1) with ESMTP id mAG8BhiS015135
	for <linux-mm@kvack.org>; Sun, 16 Nov 2008 19:11:43 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mAG8B1OA045474
	for <linux-mm@kvack.org>; Sun, 16 Nov 2008 19:11:15 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mAG8B0Uf024780
	for <linux-mm@kvack.org>; Sun, 16 Nov 2008 19:11:00 +1100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Sun, 16 Nov 2008 13:40:55 +0530
Message-Id: <20081116081055.25166.85066.sendpatchset@balbir-laptop>
In-Reply-To: <20081116081034.25166.7586.sendpatchset@balbir-laptop>
References: <20081116081034.25166.7586.sendpatchset@balbir-laptop>
Subject: [mm] [PATCH 3/4] Memory cgroup hierarchical reclaim (v4)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

This patch introduces hierarchical reclaim. When an ancestor goes over its
limit, the charging routine points to the parent that is above its limit.
The reclaim process then starts from the last scanned child of the ancestor
and reclaims until the ancestor goes below its limit.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/memcontrol.c |  170 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 167 insertions(+), 3 deletions(-)

diff -puN mm/memcontrol.c~memcg-hierarchical-reclaim mm/memcontrol.c
--- linux-2.6.28-rc4/mm/memcontrol.c~memcg-hierarchical-reclaim	2008-11-16 13:17:33.000000000 +0530
+++ linux-2.6.28-rc4-balbir/mm/memcontrol.c	2008-11-16 13:17:33.000000000 +0530
@@ -142,6 +142,13 @@ struct mem_cgroup {
 	struct mem_cgroup_lru_info info;
 
 	int	prev_priority;	/* for recording reclaim priority */
+
+	/*
+	 * While reclaiming in a hiearchy, we cache the last child we
+	 * reclaimed from. Protected by cgroup_lock()
+	 */
+	struct mem_cgroup *last_scanned_child;
+
 	int		obsolete;
 	atomic_t	refcnt;
 	/*
@@ -460,6 +467,153 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
+static struct mem_cgroup *
+mem_cgroup_from_res_counter(struct res_counter *counter)
+{
+	return container_of(counter, struct mem_cgroup, res);
+}
+
+/*
+ * This routine finds the DFS walk successor. This routine should be
+ * called with cgroup_mutex held
+ */
+static struct mem_cgroup *
+mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
+{
+	struct cgroup *cgroup, *curr_cgroup, *root_cgroup;
+
+	curr_cgroup = curr->css.cgroup;
+	root_cgroup = root_mem->css.cgroup;
+
+	if (!list_empty(&curr_cgroup->children)) {
+		/*
+		 * Walk down to children
+		 */
+		mem_cgroup_put(curr);
+		cgroup = list_entry(curr_cgroup->children.next,
+						struct cgroup, sibling);
+		curr = mem_cgroup_from_cont(cgroup);
+		mem_cgroup_get(curr);
+		goto done;
+	}
+
+visit_parent:
+	if (curr_cgroup == root_cgroup) {
+		mem_cgroup_put(curr);
+		curr = root_mem;
+		mem_cgroup_get(curr);
+		goto done;
+	}
+
+	/*
+	 * Goto next sibling
+	 */
+	if (curr_cgroup->sibling.next != &curr_cgroup->parent->children) {
+		mem_cgroup_put(curr);
+		cgroup = list_entry(curr_cgroup->sibling.next, struct cgroup,
+						sibling);
+		curr = mem_cgroup_from_cont(cgroup);
+		mem_cgroup_get(curr);
+		goto done;
+	}
+
+	/*
+	 * Go up to next parent and next parent's sibling if need be
+	 */
+	curr_cgroup = curr_cgroup->parent;
+	goto visit_parent;
+
+done:
+	root_mem->last_scanned_child = curr;
+	return curr;
+}
+
+/*
+ * Visit the first child (need not be the first child as per the ordering
+ * of the cgroup list, since we track last_scanned_child) of @mem and use
+ * that to reclaim free pages from.
+ */
+static struct mem_cgroup *
+mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
+{
+	struct cgroup *cgroup;
+	struct mem_cgroup *ret;
+	bool obsolete = (root_mem->last_scanned_child &&
+				root_mem->last_scanned_child->obsolete);
+
+	/*
+	 * Scan all children under the mem_cgroup mem
+	 */
+	cgroup_lock();
+	if (list_empty(&root_mem->css.cgroup->children)) {
+		ret = root_mem;
+		goto done;
+	}
+
+	if (!root_mem->last_scanned_child || obsolete) {
+
+		if (obsolete)
+			mem_cgroup_put(root_mem->last_scanned_child);
+
+		cgroup = list_first_entry(&root_mem->css.cgroup->children,
+				struct cgroup, sibling);
+		ret = mem_cgroup_from_cont(cgroup);
+		mem_cgroup_get(ret);
+	} else
+		ret = mem_cgroup_get_next_node(root_mem->last_scanned_child,
+						root_mem);
+
+done:
+	root_mem->last_scanned_child = ret;
+	cgroup_unlock();
+	return ret;
+}
+
+/*
+ * Dance down the hierarchy if needed to reclaim memory. We remember the
+ * last child we reclaimed from, so that we don't end up penalizing
+ * one child extensively based on its position in the children list.
+ *
+ * root_mem is the original ancestor that we've been reclaim from.
+ */
+static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
+						gfp_t gfp_mask, bool noswap)
+{
+	struct mem_cgroup *next_mem;
+	int ret = 0;
+
+	/*
+	 * Reclaim unconditionally and don't check for return value.
+	 * We need to reclaim in the current group and down the tree.
+	 * One might think about checking for children before reclaiming,
+	 * but there might be left over accounting, even after children
+	 * have left.
+	 */
+	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
+	if (res_counter_check_under_limit(&root_mem->res))
+		return 0;
+
+	next_mem = mem_cgroup_get_first_node(root_mem);
+
+	while (next_mem != root_mem) {
+		if (next_mem->obsolete) {
+			mem_cgroup_put(next_mem);
+			cgroup_lock();
+			next_mem = mem_cgroup_get_first_node(root_mem);
+			cgroup_unlock();
+			continue;
+		}
+		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
+		if (res_counter_check_under_limit(&root_mem->res)) {
+			return 0;
+		}
+		cgroup_lock();
+		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
+		cgroup_unlock();
+	}
+	return ret;
+}
+
 /*
  * Unlike exported interface, "oom" parameter is added. if oom==true,
  * oom-killer can be invoked.
@@ -468,7 +622,7 @@ static int __mem_cgroup_try_charge(struc
 			gfp_t gfp_mask, struct mem_cgroup **memcg,
 			bool oom)
 {
-	struct mem_cgroup *mem;
+	struct mem_cgroup *mem, *mem_over_limit;
 	int nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
 	struct res_counter *fail_res;
 	/*
@@ -514,8 +668,16 @@ static int __mem_cgroup_try_charge(struc
 		if (!(gfp_mask & __GFP_WAIT))
 			goto nomem;
 
-		if (try_to_free_mem_cgroup_pages(mem, gfp_mask, noswap))
-			continue;
+		/*
+		 * Is one of our ancestors over their limit?
+		 */
+		if (fail_res)
+			mem_over_limit = mem_cgroup_from_res_counter(fail_res);
+		else
+			mem_over_limit = mem;
+
+		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
+							noswap);
 
 		/*
 		 * try_to_free_mem_cgroup_pages() might not give us a full
@@ -1710,6 +1872,8 @@ mem_cgroup_create(struct cgroup_subsys *
 	res_counter_init(&mem->memsw, parent ? &parent->memsw : NULL);
 
 
+	mem->last_scanned_child = NULL;
+
 	return &mem->css;
 free_out:
 	for_each_node_state(node, N_POSSIBLE)
_

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
