Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 4715F6B004A
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 09:15:00 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] kernel: cgroup: push rcu read locking from css_is_ancestor() to callsite
Date: Tue, 28 Feb 2012 15:14:48 +0100
Message-Id: <1330438489-21909-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Library functions should not grab locks when the callsites can do it,
even if the lock nests like the rcu read-side lock does.

Push the rcu_read_lock() from css_is_ancestor() to its single user,
mem_cgroup_same_or_subtree() in preparation for another user that may
already hold the rcu read-side lock.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 kernel/cgroup.c |   20 ++++++++++----------
 mm/memcontrol.c |   14 +++++++++-----
 2 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 4be474d..9003bd8 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -4841,7 +4841,7 @@ EXPORT_SYMBOL_GPL(css_depth);
  * @root: the css supporsed to be an ancestor of the child.
  *
  * Returns true if "root" is an ancestor of "child" in its hierarchy. Because
- * this function reads css->id, this use rcu_dereference() and rcu_read_lock().
+ * this function reads css->id, the caller must hold rcu_read_lock().
  * But, considering usual usage, the csses should be valid objects after test.
  * Assuming that the caller will do some action to the child if this returns
  * returns true, the caller must take "child";s reference count.
@@ -4853,18 +4853,18 @@ bool css_is_ancestor(struct cgroup_subsys_state *child,
 {
 	struct css_id *child_id;
 	struct css_id *root_id;
-	bool ret = true;
 
-	rcu_read_lock();
 	child_id  = rcu_dereference(child->id);
+	if (!child_id)
+		return false;
 	root_id = rcu_dereference(root->id);
-	if (!child_id
-	    || !root_id
-	    || (child_id->depth < root_id->depth)
-	    || (child_id->stack[root_id->depth] != root_id->id))
-		ret = false;
-	rcu_read_unlock();
-	return ret;
+	if (!root_id)
+		return false;
+	if (child_id->depth < root_id->depth)
+		return false;
+	if (child_id->stack[root_id->depth] != root_id->id)
+		return false;
+	return true;
 }
 
 void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e4be95a..b4622fb 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1047,12 +1047,16 @@ struct lruvec *mem_cgroup_lru_move_lists(struct zone *zone,
 static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 		struct mem_cgroup *memcg)
 {
-	if (root_memcg != memcg) {
-		return (root_memcg->use_hierarchy &&
-			css_is_ancestor(&memcg->css, &root_memcg->css));
-	}
+	bool ret;
 
-	return true;
+	if (root_memcg == memcg)
+		return true;
+	if (!root_memcg->use_hierarchy)
+		return false;
+	rcu_read_lock();
+	ret = css_is_ancestor(&memcg->css, &root_memcg->css);
+	rcu_read_unlock();
+	return ret;
 }
 
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
