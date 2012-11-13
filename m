Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 782F46B0098
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 10:31:20 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 2/5] memcg: rework mem_cgroup_iter to use cgroup iterators
Date: Tue, 13 Nov 2012 16:30:36 +0100
Message-Id: <1352820639-13521-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

mem_cgroup_iter curently relies on css->id when walking down a group
hierarchy tree. This is really awkward because the tree walk depends on
the groups creation ordering. The only guarantee is that a parent node
is visited before its children.
Example
 1) mkdir -p a a/d a/b/c
 2) mkdir -a a/b/c a/d
Will create the same trees but the tree walks will be different:
 1) a, d, b, c
 2) a, b, c, d

574bd9f7 (cgroup: implement generic child / descendant walk macros) has
introduced generic cgroup tree walkers which provide either pre-order
or post-order tree walk. This patch converts css->id based iteration
to pre-order tree walk to keep the semantic with the original iterator
where parent is always visited before its subtree.

cgroup_for_each_descendant_pre suggests using post_create and
pre_destroy for proper synchronization with groups addidition resp.
removal. This implementation doesn't use those because a new memory
cgroup is fully initialized in mem_cgroup_create and css_tryget makes
sure that the group is alive when we encounter it by iterator.

If the reclaim cookie is used we need to store the last visited group
into the iterator so we have to be careful that it doesn't disappear in
the mean time. Elevated reference count on the memcg guarantees that
the group will not vanish even though it has been already removed from
the tree. In such a case css_tryget will fail and the iteration is
retried (groups are linked with RCU safe lists so the forward progress
is still possible). iter_lock will make sure that only one reclaimer
will see the last_visited group and the reference count game around it.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   64 ++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 49 insertions(+), 15 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0fe5177..5da1e58 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -142,8 +142,8 @@ struct mem_cgroup_stat_cpu {
 };
 
 struct mem_cgroup_reclaim_iter {
-	/* css_id of the last scanned hierarchy member */
-	int position;
+	/* last scanned hierarchy member with elevated ref count */
+	struct mem_cgroup *last_visited;
 	/* scan generation, increased every round-trip */
 	unsigned int generation;
 	/* lock to protect the position and generation */
@@ -1063,8 +1063,8 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				   struct mem_cgroup *prev,
 				   struct mem_cgroup_reclaim_cookie *reclaim)
 {
-	struct mem_cgroup *memcg = NULL;
-	int id = 0;
+	struct mem_cgroup *memcg = NULL,
+			  *last_visited = NULL;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1073,7 +1073,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		root = root_mem_cgroup;
 
 	if (prev && !reclaim)
-		id = css_id(&prev->css);
+		last_visited = prev;
 
 	if (prev && prev != root)
 		css_put(&prev->css);
@@ -1086,7 +1086,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 
 	while (!memcg) {
 		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
-		struct cgroup_subsys_state *css;
+		struct cgroup_subsys_state *css = NULL;
 
 		if (reclaim) {
 			int nid = zone_to_nid(reclaim->zone);
@@ -1096,30 +1096,64 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			mz = mem_cgroup_zoneinfo(root, nid, zid);
 			iter = &mz->reclaim_iter[reclaim->priority];
 			spin_lock(&iter->iter_lock);
+			last_visited = iter->last_visited;
 			if (prev && reclaim->generation != iter->generation) {
+				if (last_visited) {
+					mem_cgroup_put(last_visited);
+					iter->last_visited = NULL;
+				}
 				spin_unlock(&iter->iter_lock);
 				return NULL;
 			}
-			id = iter->position;
 		}
 
 		rcu_read_lock();
-		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
-		if (css) {
-			if (css == &root->css || css_tryget(css))
-				memcg = mem_cgroup_from_css(css);
-		} else
-			id = 0;
-		rcu_read_unlock();
+		/*
+		 * Root is not visited by cgroup iterators so it needs a special
+		 * treatment.
+		 */
+		if (!last_visited) {
+			css = &root->css;
+		} else {
+			struct cgroup *next_cgroup;
+
+			next_cgroup = cgroup_next_descendant_pre(
+					last_visited->css.cgroup,
+					root->css.cgroup);
+			if (next_cgroup)
+				css = cgroup_subsys_state(next_cgroup,
+						mem_cgroup_subsys_id);
+		}
+
+		/*
+		 * Even if we find a group we have to make sure it is alive.
+		 * css && !memcg means that the groups should be skipped and
+		 * we should continue the tree walk.
+		 */
+		if (css == &root->css || (css && css_tryget(css)))
+			memcg = mem_cgroup_from_css(css);
 
 		if (reclaim) {
-			iter->position = id;
+			struct mem_cgroup *curr = memcg;
+
+			if (last_visited)
+				mem_cgroup_put(last_visited);
+
+			if (css && !memcg)
+				curr = mem_cgroup_from_css(css);
+			if (curr)
+				mem_cgroup_get(curr);
+			iter->last_visited = curr;
+
 			if (!css)
 				iter->generation++;
 			else if (!prev && memcg)
 				reclaim->generation = iter->generation;
 			spin_unlock(&iter->iter_lock);
+		} else if (css && !memcg) {
+			last_visited = mem_cgroup_from_css(css);
 		}
+		rcu_read_unlock();
 
 		if (prev && !css)
 			return NULL;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
