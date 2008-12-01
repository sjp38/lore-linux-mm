Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB164tsL002874
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 1 Dec 2008 15:04:55 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 604EA45DE52
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 15:04:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E27745DD77
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 15:04:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 228FE1DB803E
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 15:04:55 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C74191DB803A
	for <linux-mm@kvack.org>; Mon,  1 Dec 2008 15:04:54 +0900 (JST)
Date: Mon, 1 Dec 2008 15:04:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 3/3] memcg: change hierarhcy managenemt to use scan by
 cgroup ID
Message-Id: <20081201150406.81b10fc4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081201145907.e6d63d61.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Implement hierarchy reclaim by cgroup_id.

TODO:
 	- memsw support isn't good. (maybe using Nishimura's patch is good.)

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


 mm/memcontrol.c |  176 +++++++++++++++++---------------------------------------
 1 file changed, 55 insertions(+), 121 deletions(-)

Index: mmotm-2.6.28-Nov29/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Nov29.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Nov29/mm/memcontrol.c
@@ -146,9 +146,11 @@ struct mem_cgroup {
 
 	/*
 	 * While reclaiming in a hiearchy, we cache the last child we
-	 * reclaimed from. Protected by cgroup_lock()
+	 * reclaimed from.
 	 */
-	struct mem_cgroup *last_scanned_child;
+	spinlock_t	scan_lock;
+	int	last_scan_child;
+	unsigned long	scan_age;
 	/*
 	 * Should the accounting and control be hierarchical, per subtree?
 	 */
@@ -475,104 +477,44 @@ unsigned long mem_cgroup_isolate_pages(u
 	container_of(counter, struct mem_cgroup, member)
 
 /*
- * This routine finds the DFS walk successor. This routine should be
- * called with cgroup_mutex held
+ * This routine select next memcg by ID. Using RCU and tryget().
+ * No cgroup_mutex is required.
  */
 static struct mem_cgroup *
-mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
+mem_cgroup_select_victim(struct mem_cgroup *root_mem)
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
-
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
-
-	/*
-	 * Go up to next parent and next parent's sibling if need be
-	 */
-	curr_cgroup = curr_cgroup->parent;
-	goto visit_parent;
-
-done:
-	root_mem->last_scanned_child = curr;
-	return curr;
-}
-
-/*
- * Visit the first child (need not be the first child as per the ordering
- * of the cgroup list, since we track last_scanned_child) of @mem and use
- * that to reclaim free pages from.
- */
-static struct mem_cgroup *
-mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
-{
-	struct cgroup *cgroup;
+	struct cgroup *cgroup, *root_cgroup;
 	struct mem_cgroup *ret;
-	struct mem_cgroup *last_scan = root_mem->last_scanned_child;
-	bool obsolete = false;
+	int nextid, rootid, depth, found;
+	unsigned long flags;
 
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
+	rcu_read_lock();
 
-	/*
-	 * Scan all children under the mem_cgroup mem
-	 */
-	cgroup_lock();
-	if (list_empty(&root_mem->css.cgroup->children)) {
-		ret = root_mem;
-		goto done;
+	while (!ret) {
+		/* ID:0 is not used by cgroup-id */
+		nextid = root_mem->last_scan_child + 1;
+		cgroup = cgroup_get_next(nextid, rootid, depth, &found);
+		if (cgroup) {
+			spin_lock_irqsave(&root_mem->scan_lock, flags);
+			root_mem->last_scan_child = found;
+			spin_unlock_irqrestore(&root_mem->scan_lock, flags);
+			ret = mem_cgroup_from_cont(cgroup);
+			if (!css_tryget(&ret->css))
+				ret = NULL;
+		} else {
+			spin_lock_irqsave(&root_mem->scan_lock, flags);
+			root_mem->scan_age++;
+			root_mem->last_scan_child = 0;
+			spin_unlock_irqrestore(&root_mem->scan_lock, flags);
+		}
 	}
+	rcu_read_unlock();
 
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
-
-done:
-	root_mem->last_scanned_child = ret;
-	cgroup_unlock();
 	return ret;
 }
 
@@ -586,37 +528,25 @@ done:
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
-	ret = try_to_free_mem_cgroup_pages(root_mem, gfp_mask, noswap);
-	if (res_counter_check_under_limit(&root_mem->res))
-		return 0;
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
-		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap);
+	start_age = root_mem->scan_age;
+	/* allows 2 times of loops */
+	while (time_after((start_age + 2UL), root_mem->scan_age)) {
+		victim = mem_cgroup_select_victim(root_mem);
+		ret = try_to_free_mem_cgroup_pages(victim, gfp_mask, noswap);
+		css_put(&victim->css);
 		if (res_counter_check_under_limit(&root_mem->res))
-			return 0;
-		cgroup_lock();
-		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
-		cgroup_unlock();
+			return 1;
+		total += ret;
 	}
+	ret = total;
+	if (res_counter_check_under_limit(&root_mem->res))
+		ret = 1;
+
 	return ret;
 }
 
@@ -705,6 +635,8 @@ static int __mem_cgroup_try_charge(struc
 
 		ret = mem_cgroup_hierarchical_reclaim(mem_over_limit, gfp_mask,
 							noswap);
+		if (ret)
+			continue;
 
 		/*
 		 * try_to_free_mem_cgroup_pages() might not give us a full
@@ -1981,8 +1913,9 @@ mem_cgroup_create(struct cgroup_subsys *
 		res_counter_init(&mem->res, NULL);
 		res_counter_init(&mem->memsw, NULL);
 	}
-
-	mem->last_scanned_child = NULL;
+	spin_lock_init(&mem->scan_lock);
+	mem->last_scan_child = 0;
+	mem->scan_age = 0;
 
 	return &mem->css;
 free_out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
