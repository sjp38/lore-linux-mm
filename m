Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB9BAEEZ022991
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Dec 2008 20:10:14 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BD1045DD84
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:10:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FD8A45DD7C
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:10:12 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6746E1DB8048
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:10:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id ACD3A1DB804B
	for <linux-mm@kvack.org>; Tue,  9 Dec 2008 20:10:10 +0900 (JST)
Date: Tue, 9 Dec 2008 20:09:15 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 4/6] Flat hierarchical reclaim by ID
Message-Id: <20081209200915.41917722.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Implement hierarchy reclaim by cgroup_id.

What changes:
	- Page reclaim is not done by tree-walk algorithm
	- mem_cgroup->last_schan_child is changed to be ID, not pointer.
	- no cgroup_lock, done under RCU.
	- scanning order is just defined by ID's order.
	  (Scan by round-robin logic.)

Changelog: v3 -> v4
	- adjusted to changes in base kernel.
	- is_acnestor() is moved to other patch.

Changelog: v2 -> v3
	- fixed use_hierarchy==0 case

Changelog: v1 -> v2
	- make use of css_tryget();
	- count # of loops rather than remembering position.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>


 mm/memcontrol.c |  274 +++++++++++++++++++++++++++-----------------------------
 1 file changed, 134 insertions(+), 140 deletions(-)

---
Index: mmotm-2.6.28-Dec08/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec08.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec08/mm/memcontrol.c
@@ -158,9 +158,10 @@ struct mem_cgroup {
 
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
@@ -170,7 +171,6 @@ struct mem_cgroup {
 
 	unsigned int	swappiness;
 
-
 	unsigned int inactive_ratio;
 
 	/*
@@ -550,102 +550,70 @@ unsigned long mem_cgroup_isolate_pages(u
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
 
-/*
- * Visit the first child (need not be the first child as per the ordering
- * of the cgroup list, since we track last_scanned_child) of @mem and use
- * that to reclaim free pages from.
- */
+#define mem_cgroup_from_res_counter(counter, member)	\
+	container_of(counter, struct mem_cgroup, member)
+
 static struct mem_cgroup *
-mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
+mem_cgroup_select_victim(struct mem_cgroup *root_mem)
 {
-	struct cgroup *cgroup;
-	struct mem_cgroup *ret;
-	bool obsolete =	memcg_is_obsolete(root_mem->last_scanned_child);
+	struct cgroup *cgroup, *root_cgroup;
+	int nextid, rootid, depth, found;
+	struct mem_cgroup *ret = NULL;
 		
+	root_cgroup = root_mem->css.cgroup;
+	rootid = cgroup_id(root_cgroup);
+	depth = cgroup_depth(root_cgroup);
 
-	/*
-	 * Scan all children under the mem_cgroup mem
-	 */
-	cgroup_lock();
-	if (list_empty(&root_mem->css.cgroup->children)) {
+	/* If no hierarchy, "root_mem" is always victim */
+	if (!root_mem->use_hierarchy) {
+		spin_lock(&root_mem->reclaim_param_lock);
+		root_mem->scan_age++;
+		spin_unlock(&root_mem->reclaim_param_lock);
+		css_get(&root_mem->css);
 		ret = root_mem;
-		goto done;
 	}
+	while (!ret) {
+		rcu_read_lock();
+		/* ID:0 is unsued */
+		nextid = root_mem->last_scanned_child + 1;
+		cgroup = cgroup_get_next(nextid, rootid, depth, &found);
 
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
+		spin_lock(&root_mem->reclaim_param_lock);
+		if (cgroup)
+			root_mem->last_scanned_child = found;
+		else {
+			root_mem->scan_age++;
+			root_mem->last_scanned_child = 0;
+		}
+		spin_unlock(&root_mem->reclaim_param_lock);
 
-done:
-	root_mem->last_scanned_child = ret;
-	cgroup_unlock();
+		if (cgroup) {
+			ret = mem_cgroup_from_cont(cgroup);
+			css_get(&ret->css);
+			/* avoid to block rmdir() */
+			if (memcg_is_obsolete(ret)) {
+				css_put(&ret->css);
+				ret = NULL;
+			}
+		}
+		rcu_read_unlock();
+	}
 	return ret;
 }
 
@@ -661,22 +629,6 @@ static bool mem_cgroup_check_under_limit
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
-
 /*
  * Dance down the hierarchy if needed to reclaim memory. We remember the
  * last child we reclaimed from, so that we don't end up penalizing
@@ -687,41 +639,26 @@ static unsigned int get_swappiness(struc
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
+	start_age = root_mem->scan_age;
 
-	next_mem = mem_cgroup_get_first_node(root_mem);
+	/* Allows 2 vists to "root_mem" */
+	while (time_after(start_age + 2UL, root_mem->scan_age)) {
 
-	while (next_mem != root_mem) {
-		if (memcg_is_obsolete(next_mem)) {
-			mem_cgroup_put(next_mem);
-			cgroup_lock();
-			next_mem = mem_cgroup_get_first_node(root_mem);
-			cgroup_unlock();
-			continue;
-		}
-		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
-						   get_swappiness(next_mem));
+		victim = mem_cgroup_select_victim(root_mem);
+		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap,
+						   get_swappiness(victim));
+		css_put(&victim->css);
 		if (mem_cgroup_check_under_limit(root_mem))
-			return 0;
-		cgroup_lock();
-		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
-		cgroup_unlock();
+			return 1;
+		total += ret;
 	}
+	ret = total;
+
 	return ret;
 }
 
@@ -2149,7 +2086,8 @@ mem_cgroup_create(struct cgroup_subsys *
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
