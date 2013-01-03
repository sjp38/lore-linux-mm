Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 524086B0078
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 12:54:51 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v3 7/7] cgroup: remove css_get_next
Date: Thu,  3 Jan 2013 18:54:21 +0100
Message-Id: <1357235661-29564-8-git-send-email-mhocko@suse.cz>
In-Reply-To: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

Now that we have generic and well ordered cgroup tree walkers there is
no need to keep css_get_next in the place.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/cgroup.h |    7 -------
 kernel/cgroup.c        |   49 ------------------------------------------------
 2 files changed, 56 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 7d73905..a4d86b0 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -685,13 +685,6 @@ void free_css_id(struct cgroup_subsys *ss, struct cgroup_subsys_state *css);
 
 struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id);
 
-/*
- * Get a cgroup whose id is greater than or equal to id under tree of root.
- * Returning a cgroup_subsys_state or NULL.
- */
-struct cgroup_subsys_state *css_get_next(struct cgroup_subsys *ss, int id,
-		struct cgroup_subsys_state *root, int *foundid);
-
 /* Returns true if root is ancestor of cg */
 bool css_is_ancestor(struct cgroup_subsys_state *cg,
 		     const struct cgroup_subsys_state *root);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f34c41b..3013ec4 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5384,55 +5384,6 @@ struct cgroup_subsys_state *css_lookup(struct cgroup_subsys *ss, int id)
 }
 EXPORT_SYMBOL_GPL(css_lookup);
 
-/**
- * css_get_next - lookup next cgroup under specified hierarchy.
- * @ss: pointer to subsystem
- * @id: current position of iteration.
- * @root: pointer to css. search tree under this.
- * @foundid: position of found object.
- *
- * Search next css under the specified hierarchy of rootid. Calling under
- * rcu_read_lock() is necessary. Returns NULL if it reaches the end.
- */
-struct cgroup_subsys_state *
-css_get_next(struct cgroup_subsys *ss, int id,
-	     struct cgroup_subsys_state *root, int *foundid)
-{
-	struct cgroup_subsys_state *ret = NULL;
-	struct css_id *tmp;
-	int tmpid;
-	int rootid = css_id(root);
-	int depth = css_depth(root);
-
-	if (!rootid)
-		return NULL;
-
-	BUG_ON(!ss->use_id);
-	WARN_ON_ONCE(!rcu_read_lock_held());
-
-	/* fill start point for scan */
-	tmpid = id;
-	while (1) {
-		/*
-		 * scan next entry from bitmap(tree), tmpid is updated after
-		 * idr_get_next().
-		 */
-		tmp = idr_get_next(&ss->idr, &tmpid);
-		if (!tmp)
-			break;
-		if (tmp->depth >= depth && tmp->stack[depth] == rootid) {
-			ret = rcu_dereference(tmp->css);
-			if (ret) {
-				*foundid = tmpid;
-				break;
-			}
-		}
-		/* continue to scan from next id */
-		tmpid = tmpid + 1;
-	}
-	return ret;
-}
-
 /*
  * get corresponding css from file open on cgroupfs directory
  */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
