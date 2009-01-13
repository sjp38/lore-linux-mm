Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id A64C46B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 05:39:30 -0500 (EST)
Date: Tue, 13 Jan 2009 18:49:58 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH 3/4] memcg: fix hierarchical reclaim
Message-Id: <20090113184958.4baf965c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

If root_mem has no children, last_scaned_child is set to root_mem itself.
But after some children added to root_mem, mem_cgroup_get_next_node can
mem_cgroup_put the root_mem although root_mem has not been mem_cgroup_get.

This patch fixes this behavior by:
- Set last_scanned_child to NULL if root_mem has no children or DFS search
  has returned to root_mem itself(root_mem is not a "child" of root_mem).
  Make mem_cgroup_get_first_node return root_mem in this case.
  There are no mem_cgroup_get/put for root_mem.
- Rename mem_cgroup_get_next_node to __mem_cgroup_get_next_node, and
  mem_cgroup_get_first_node to mem_cgroup_get_next_node.
  Make mem_cgroup_hierarchical_reclaim call only new mem_cgroup_get_next_node.

ChangeLog: RFC->v1
- add mem_cgroup_put of last_scanned_child at mem_cgroup_destroy.
ChangeLog: v1->v2
- cleanup. move all mem_cgroup_get/put to the end of mem_cgroup_get_next_node.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   68 +++++++++++++++++++++++++++++-------------------------
 1 files changed, 36 insertions(+), 32 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7be9b35..322625f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -633,7 +633,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
  * called with hierarchy_mutex held
  */
 static struct mem_cgroup *
-mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
+__mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
 {
 	struct cgroup *cgroup, *curr_cgroup, *root_cgroup;
 
@@ -644,19 +644,16 @@ mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
 		/*
 		 * Walk down to children
 		 */
-		mem_cgroup_put(curr);
 		cgroup = list_entry(curr_cgroup->children.next,
 						struct cgroup, sibling);
 		curr = mem_cgroup_from_cont(cgroup);
-		mem_cgroup_get(curr);
 		goto done;
 	}
 
 visit_parent:
 	if (curr_cgroup == root_cgroup) {
-		mem_cgroup_put(curr);
-		curr = root_mem;
-		mem_cgroup_get(curr);
+		/* caller handles NULL case */
+		curr = NULL;
 		goto done;
 	}
 
@@ -664,11 +661,9 @@ visit_parent:
 	 * Goto next sibling
 	 */
 	if (curr_cgroup->sibling.next != &curr_cgroup->parent->children) {
-		mem_cgroup_put(curr);
 		cgroup = list_entry(curr_cgroup->sibling.next, struct cgroup,
 						sibling);
 		curr = mem_cgroup_from_cont(cgroup);
-		mem_cgroup_get(curr);
 		goto done;
 	}
 
@@ -679,7 +674,6 @@ visit_parent:
 	goto visit_parent;
 
 done:
-	root_mem->last_scanned_child = curr;
 	return curr;
 }
 
@@ -689,40 +683,46 @@ done:
  * that to reclaim free pages from.
  */
 static struct mem_cgroup *
-mem_cgroup_get_first_node(struct mem_cgroup *root_mem)
+mem_cgroup_get_next_node(struct mem_cgroup *root_mem)
 {
 	struct cgroup *cgroup;
-	struct mem_cgroup *ret;
+	struct mem_cgroup *orig, *next;
 	bool obsolete;
 
-	obsolete = mem_cgroup_is_obsolete(root_mem->last_scanned_child);
-
 	/*
 	 * Scan all children under the mem_cgroup mem
 	 */
 	mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
+
+	orig = root_mem->last_scanned_child;
+	obsolete = mem_cgroup_is_obsolete(orig);
+
 	if (list_empty(&root_mem->css.cgroup->children)) {
-		ret = root_mem;
+		/*
+		 * root_mem might have children before and last_scanned_child
+		 * may point to one of them. We put it later.
+		 */
+		if (orig)
+			VM_BUG_ON(!obsolete);
+		next = NULL;
 		goto done;
 	}
 
-	if (!root_mem->last_scanned_child || obsolete) {
-
-		if (obsolete && root_mem->last_scanned_child)
-			mem_cgroup_put(root_mem->last_scanned_child);
-
+	if (!orig || obsolete) {
 		cgroup = list_first_entry(&root_mem->css.cgroup->children,
 				struct cgroup, sibling);
-		ret = mem_cgroup_from_cont(cgroup);
-		mem_cgroup_get(ret);
+		next = mem_cgroup_from_cont(cgroup);
 	} else
-		ret = mem_cgroup_get_next_node(root_mem->last_scanned_child,
-						root_mem);
+		next = __mem_cgroup_get_next_node(orig, root_mem);
 
 done:
-	root_mem->last_scanned_child = ret;
+	if (next)
+		mem_cgroup_get(next);
+	root_mem->last_scanned_child = next;
+	if (orig)
+		mem_cgroup_put(orig);
 	mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
-	return ret;
+	return (next) ? next : root_mem;
 }
 
 static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
@@ -780,21 +780,18 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
 	if (!root_mem->use_hierarchy)
 		return ret;
 
-	next_mem = mem_cgroup_get_first_node(root_mem);
+	next_mem = mem_cgroup_get_next_node(root_mem);
 
 	while (next_mem != root_mem) {
 		if (mem_cgroup_is_obsolete(next_mem)) {
-			mem_cgroup_put(next_mem);
-			next_mem = mem_cgroup_get_first_node(root_mem);
+			next_mem = mem_cgroup_get_next_node(root_mem);
 			continue;
 		}
 		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
 						   get_swappiness(next_mem));
 		if (mem_cgroup_check_under_limit(root_mem))
 			return 0;
-		mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
-		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
-		mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
+		next_mem = mem_cgroup_get_next_node(root_mem);
 	}
 	return ret;
 }
@@ -2254,7 +2251,14 @@ static void mem_cgroup_pre_destroy(struct cgroup_subsys *ss,
 static void mem_cgroup_destroy(struct cgroup_subsys *ss,
 				struct cgroup *cont)
 {
-	mem_cgroup_put(mem_cgroup_from_cont(cont));
+	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
+	struct mem_cgroup *last_scanned_child = mem->last_scanned_child;
+
+	if (last_scanned_child) {
+		VM_BUG_ON(!mem_cgroup_is_obsolete(last_scanned_child));
+		mem_cgroup_put(last_scanned_child);
+	}
+	mem_cgroup_put(mem);
 }
 
 static int mem_cgroup_populate(struct cgroup_subsys *ss,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
