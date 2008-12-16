Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6E36B0075
	for <linux-mm@kvack.org>; Tue, 16 Dec 2008 06:35:28 -0500 (EST)
Message-Id: <20081216113653.090278000@menage.corp.google.com>
References: <20081216113055.713856000@menage.corp.google.com>
Date: Tue, 16 Dec 2008 03:30:57 -0800
From: menage@google.com
Subject: [PATCH 2/3] CGroups: Use hierarchy_mutex in memory controller
Content-Disposition: inline; filename=mm-destroy-fix.patch
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch updates the memory controller to use its hierarchy_mutex
rather than calling cgroup_lock() to protected against
cgroup_mkdir()/cgroup_rmdir() from occurring in its hierarchy.

Signed-off-by: Paul Menage <menage@google.com>

---
 mm/memcontrol.c |   14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

Index: hierarchy_lock-mmotm-2008-12-09/mm/memcontrol.c
===================================================================
--- hierarchy_lock-mmotm-2008-12-09.orig/mm/memcontrol.c
+++ hierarchy_lock-mmotm-2008-12-09/mm/memcontrol.c
@@ -154,7 +154,7 @@ struct mem_cgroup {
 
 	/*
 	 * While reclaiming in a hiearchy, we cache the last child we
-	 * reclaimed from. Protected by cgroup_lock()
+	 * reclaimed from. Protected by hierarchy_mutex
 	 */
 	struct mem_cgroup *last_scanned_child;
 	/*
@@ -529,7 +529,7 @@ unsigned long mem_cgroup_isolate_pages(u
 
 /*
  * This routine finds the DFS walk successor. This routine should be
- * called with cgroup_mutex held
+ * called with hierarchy_mutex held
  */
 static struct mem_cgroup *
 mem_cgroup_get_next_node(struct mem_cgroup *curr, struct mem_cgroup *root_mem)
@@ -598,7 +598,7 @@ mem_cgroup_get_first_node(struct mem_cgr
 	/*
 	 * Scan all children under the mem_cgroup mem
 	 */
-	cgroup_lock();
+	mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
 	if (list_empty(&root_mem->css.cgroup->children)) {
 		ret = root_mem;
 		goto done;
@@ -619,7 +619,7 @@ mem_cgroup_get_first_node(struct mem_cgr
 
 done:
 	root_mem->last_scanned_child = ret;
-	cgroup_unlock();
+	mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
 	return ret;
 }
 
@@ -683,18 +683,16 @@ static int mem_cgroup_hierarchical_recla
 	while (next_mem != root_mem) {
 		if (next_mem->obsolete) {
 			mem_cgroup_put(next_mem);
-			cgroup_lock();
 			next_mem = mem_cgroup_get_first_node(root_mem);
-			cgroup_unlock();
 			continue;
 		}
 		ret = try_to_free_mem_cgroup_pages(next_mem, gfp_mask, noswap,
 						   get_swappiness(next_mem));
 		if (mem_cgroup_check_under_limit(root_mem))
 			return 0;
-		cgroup_lock();
+		mutex_lock(&mem_cgroup_subsys.hierarchy_mutex);
 		next_mem = mem_cgroup_get_next_node(next_mem, root_mem);
-		cgroup_unlock();
+		mutex_unlock(&mem_cgroup_subsys.hierarchy_mutex);
 	}
 	return ret;
 }

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
