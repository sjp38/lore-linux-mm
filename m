Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB35FDAb032353
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 14:15:13 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C7FAC45DD7F
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:15:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A32E445DD7E
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:15:12 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8470F1DB8040
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:15:12 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 32FF01DB803C
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 14:15:12 +0900 (JST)
Date: Wed, 3 Dec 2008 14:14:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Experimental][PATCH  21/21] memcg-new-hierarchical-reclaim.patch
Message-Id: <20081203141423.6f747990.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Implement hierarchy reclaim by cgroup_id.

What changes:
	- reclaim is not done by tree-walk algorithm
	- mem_cgroup->last_schan_child is ID, not pointer.
	- no cgroup_lock.
	- scanning order is just defined by ID's order.
	  (Scan by round-robin logic.)

Changelog: v1 -> v2
	- make use of css_tryget();
	- count # of loops rather than remembering position.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>


 mm/memcontrol.c |  214 +++++++++++++++++++-------------------------------------
 1 file changed, 75 insertions(+), 139 deletions(-)

Index: mmotm-2.6.28-Dec02/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec02.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec02/mm/memcontrol.c
@@ -153,9 +153,10 @@ struct mem_cgroup {
 
 	/*
 	 * While reclaiming in a hiearchy, we cache the last child we
-	 * reclaimed from. Protected by cgroup_lock()
+	 * reclaimed from.
 	 */
-	struct mem_cgroup *last_scanned_child;
+	int	last_scanned_child;
+	unsigned long	scan_age;
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
@@ -521,108 +522,72 @@ unsigned long mem_cgroup_isolate_pages(u
 	return nr_taken;
 }
 
-#define mem_cgroup_from_res_counter(counter, member)	\
-	container_of(counter, struct mem_cgroup, member)
-
-/*
- * This routine finds the DFS walk successor. This routine should be
- * called with cgroup_mutex held
- */
-static struct mem_cgroup *
-mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
+static unsigned int get_swappiness(struct mem_cgroup *memcg)
 {
-	struct cgroup *cgroup, *curr_cgroup, *root_cgroup;
-
-	curr_cgroup = curr->css.cgroup;
-	root_cgroup = root_mem->css.cgroup;
-
-	if (!list_empty(&curr_cgroup->children)) {
-		/*
-		 * Walk down to children
-		 */
-		mem_cgroup_put(curr);
-		cgroup = list_entry(curr_cgroup->children.next,
-						struct cgroup, sibling);
-		curr = mem_cgroup_from_cont(cgroup);
-		mem_cgroup_get(curr);
-		goto done;
-	}
-
-visit_parent:
-	if (curr_cgroup == root_cgroup) {
-		mem_cgroup_put(curr);
-		curr = root_mem;
-		mem_cgroup_get(curr);
-		goto done;
-	}
+	struct cgroup *cgrp = memcg->css.cgroup;
+	unsigned int swappiness;
 
-	/*
-	 * Goto next sibling
-	 */
-	if (curr_cgroup->sibling.next != &curr_cgroup->parent->children) {
-		mem_cgroup_put(curr);
-		cgroup = list_entry(curr_cgroup->sibling.next, struct cgroup,
-						sibling);
-		curr = mem_cgroup_from_cont(cgroup);
-		mem_cgroup_get(curr);
-		goto done;
-	}
+	/* root ? */
+	if (cgrp->parent == NULL)
+		return vm_swappiness;
 
-	/*
-	 * Go up to next parent and next parent's sibling if need be
-	 */
-	curr_cgroup = curr_cgroup->parent;
-	goto visit_parent;
+	spin_lock(&memcg->reclaim_param_lock);
+	swappiness = memcg->swappiness;
+	spin_unlock(&memcg->reclaim_param_lock);
 
-done:
-	root_mem->last_scanned_child = curr;
-	return curr;
+	return swappiness;
 }
 
+#define mem_cgroup_from_res_counter(counter, member)	\
+	container_of(counter, struct mem_cgroup, member)
+
 /*
- * Visit the first child (need not be the first child as per the ordering
- * of the cgroup list, since we track last_scanned_child) of @mem and use
- * that to reclaim free pages from.
+ * This routine select next memcg by ID. Using RCU and tryget().
+ * No cgroup_mutex is required.
  */
 static struct mem_cgroup *
-mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
+mem_cgroup_select_victim(struct mem_cgroup *root_mem)
 {
-	struct cgroup *cgroup;
+	struct cgroup *cgroup, *root_cgroup;
 	struct mem_cgroup *ret;
-	struct mem_cgroup *last_scan = root_mem->last_scanned_child;
-	bool obsolete = false;
+	int nextid, rootid, depth, found;
 
-	if (last_scan) {
-		if (css_under_removal(&last_scan->css))
-			obsolete = true;
-	} else
-		obsolete = true;
+	root_cgroup = root_mem->css.cgroup;
+	rootid = cgroup_id(root_cgroup);
+	depth = cgroup_depth(root_cgroup);
+	found = 0;
+	ret = NULL;
 
-	/*
-	 * Scan all children under the mem_cgroup mem
-	 */
-	cgroup_lock();
-	if (list_empty(&root_mem->css.cgroup->children)) {
-		ret = root_mem;
-		goto done;
+	rcu_read_lock();
+	if (!root_mem->use_hierarchy) {
+		spin_lock(&root_mem->reclaim_param_lock);
+		root_mem->scan_age++;
+		spin_unlock(&root_mem->reclaim_param_lock);
+		css_get(&root_mem->css);
+		goto out;
 	}
 
-	if (!root_mem->last_scanned_child || obsolete) {
-
-		if (obsolete)
-			mem_cgroup_put(root_mem->last_scanned_child);
-
-		cgroup = list_first_entry(&root_mem->css.cgroup->children,
-				struct cgroup, sibling);
-		ret = mem_cgroup_from_cont(cgroup);
-		mem_cgroup_get(ret);
-	} else
-		ret = mem_cgroup_get_next_node(root_mem->last_scanned_child,
-						root_mem);
+	while (!ret) {
+		/* ID:0 is not used by cgroup-id */
+		nextid = root_mem->last_scanned_child + 1;
+		cgroup = cgroup_get_next(nextid, rootid, depth, &found);
+		if (cgroup) {
+			spin_lock(&root_mem->reclaim_param_lock);
+			root_mem->last_scanned_child = found;
+			spin_unlock(&root_mem->reclaim_param_lock);
+			ret = mem_cgroup_from_cont(cgroup);
+			if (!css_tryget(&ret->css))
+				ret = NULL;
+		} else {
+			spin_lock(&root_mem->reclaim_param_lock);
+			root_mem->scan_age++;
+			root_mem->last_scanned_child = 0;
+			spin_unlock(&root_mem->reclaim_param_lock);
+		}
+	}
+out:
+	rcu_read_unlock();
 
-done:
-	root_mem->last_scanned_child = ret;
-	cgroup_unlock();
 	return ret;
 }
 
@@ -638,67 +603,34 @@ static bool mem_cgroup_check_under_limit
 	return false;
 }
 
-static unsigned int get_swappiness(struct mem_cgroup *memcg)
-{
-	struct cgroup *cgrp = memcg->css.cgroup;
-	unsigned int swappiness;
-
-	/* root ? */
-	if (cgrp->parent == NULL)
-		return vm_swappiness;
-
-	spin_lock(&memcg->reclaim_param_lock);
-	swappiness = memcg->swappiness;
-	spin_unlock(&memcg->reclaim_param_lock);
-
-	return swappiness;
-}
 
 /*
- * Dance down the hierarchy if needed to reclaim memory. We remember the
- * last child we reclaimed from, so that we don't end up penalizing
- * one child extensively based on its position in the children list.
- *
  * root_mem is the original ancestor that we've been reclaim from.
  */
 static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 						gfp_t gfp_mask, bool noswap)
 {
-	struct mem_cgroup *next_mem;
+	struct mem_cgroup *victim;
+	unsigned long start_age;
 	int ret = 0;
+	int total = 0;
 
-	/*
-	 * Reclaim unconditionally and don't check for return value.
-	 * We need to reclaim in the current group and down the tree.
-	 * One might think about checking for children before reclaiming,
-	 * but there might be left over accounting, even after children
-	 * have left.
-	 */
-	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap,
-					   get_swappiness(root_mem));
-	if (mem_cgroup_check_under_limit(root_mem))
-		return 0;
-	if (!root_mem->use_hierarchy)
-		return ret;
-
-	next_mem = mem_cgroup_get_first_node(root_mem);
-
-	while (next_mem != root_mem) {
-		if (css_under_removal(&next_mem->css)) {
-			mem_cgroup_put(next_mem);
-			cgroup_lock();
-			next_mem = mem_cgroup_get_first_node(root_mem);
-			cgroup_unlock();
-			continue;
-		}
-		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
-						   get_swappiness(next_mem));
+	start_age = root_mem->scan_age;
+	/* allows 2 times of loops */
+	while (time_after((start_age + 2UL), root_mem->scan_age)) {
+		victim = mem_cgroup_select_victim(root_mem);
+		ret = try_to_free_mem_cgroup_pages(victim,
+				gfp_mask, noswap, get_swappiness(victim));
+		css_put(&victim->css);
 		if (mem_cgroup_check_under_limit(root_mem))
-			return 0;
-		cgroup_lock();
-		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
-		cgroup_unlock();
+			return 1;
+		total += ret;
 	}
+
+	ret = total;
+	if (mem_cgroup_check_under_limit(root_mem))
+		ret = 1;
+
 	return ret;
 }
 
@@ -787,6 +719,8 @@ static int __mem_cgroup_try_charge(struc
 
 		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
 							noswap);
+		if (ret)
+			continue;
 
 		/*
 		 * try_to_free_mem_cgroup_pages() might not give us a full
@@ -2161,7 +2095,8 @@ mem_cgroup_create(struct cgroup_subsys *
 		res_counter_init(&mem->memsw, NULL);
 	}
 	mem_cgroup_set_inactive_ratio(mem);
-	mem->last_scanned_child = NULL;
+	mem->last_scanned_child = 0;
+	mem->scan_age = 0;
 	spin_lock_init(&mem->reclaim_param_lock);
 
 	if (parent)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
