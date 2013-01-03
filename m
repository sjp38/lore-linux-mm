Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9C75B6B0070
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 12:54:46 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v3 3/7] memcg: rework mem_cgroup_iter to use cgroup iterators
Date: Thu,  3 Jan 2013 18:54:17 +0100
Message-Id: <1357235661-29564-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

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
cgroup is fully initialized in mem_cgroup_create and css reference
counting enforces that the group is alive for both the last seen cgroup
and the found one resp. it signals that the group is dead and it should
be skipped.

If the reclaim cookie is used we need to store the last visited group
into the iterator so we have to be careful that it doesn't disappear in
the mean time. Elevated reference count on the css keeps it alive even
though the group have been removed (parked waiting for the last dput so
that it can be freed).

V2
- use css_{get,put} for iter->last_visited rather than
  mem_cgroup_{get,put} because it is stronger wrt. cgroup life cycle
- cgroup_next_descendant_pre expects NULL pos for the first iterartion
  otherwise it might loop endlessly for intermediate node without any
  children.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   74 ++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 57 insertions(+), 17 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 90a3b1d..e9f5c47 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -144,8 +144,8 @@ struct mem_cgroup_stat_cpu {
 };
 
 struct mem_cgroup_reclaim_iter {
-	/* css_id of the last scanned hierarchy member */
-	int position;
+	/* last scanned hierarchy member with elevated css ref count */
+	struct mem_cgroup *last_visited;
 	/* scan generation, increased every round-trip */
 	unsigned int generation;
 	/* lock to protect the position and generation */
@@ -1132,7 +1132,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				   struct mem_cgroup_reclaim_cookie *reclaim)
 {
 	struct mem_cgroup *memcg = NULL;
-	int id = 0;
+	struct mem_cgroup *last_visited = NULL;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1141,7 +1141,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		root = root_mem_cgroup;
 
 	if (prev && !reclaim)
-		id = css_id(&prev->css);
+		last_visited = prev;
 
 	if (!root->use_hierarchy && root != root_mem_cgroup) {
 		if (prev)
@@ -1149,9 +1149,10 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		return root;
 	}
 
+	rcu_read_lock();
 	while (!memcg) {
 		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
-		struct cgroup_subsys_state *css;
+		struct cgroup_subsys_state *css = NULL;
 
 		if (reclaim) {
 			int nid = zone_to_nid(reclaim->zone);
@@ -1161,34 +1162,73 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			mz = mem_cgroup_zoneinfo(root, nid, zid);
 			iter = &mz->reclaim_iter[reclaim->priority];
 			spin_lock(&iter->iter_lock);
+			last_visited = iter->last_visited;
 			if (prev && reclaim->generation != iter->generation) {
+				if (last_visited) {
+					css_put(&last_visited->css);
+					iter->last_visited = NULL;
+				}
 				spin_unlock(&iter->iter_lock);
-				goto out_css_put;
+				goto out_unlock;
 			}
-			id = iter->position;
 		}
 
-		rcu_read_lock();
-		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
-		if (css) {
-			if (css == &root->css || css_tryget(css))
-				memcg = mem_cgroup_from_css(css);
-		} else
-			id = 0;
-		rcu_read_unlock();
+		/*
+		 * Root is not visited by cgroup iterators so it needs an
+		 * explicit visit.
+		 */
+		if (!last_visited) {
+			css = &root->css;
+		} else {
+			struct cgroup *prev_cgroup, *next_cgroup;
+
+			prev_cgroup = (last_visited == root) ? NULL
+				: last_visited->css.cgroup;
+			next_cgroup = cgroup_next_descendant_pre(prev_cgroup,
+					root->css.cgroup);
+			if (next_cgroup)
+				css = cgroup_subsys_state(next_cgroup,
+						mem_cgroup_subsys_id);
+		}
+
+		/*
+		 * Even if we found a group we have to make sure it is alive.
+		 * css && !memcg means that the groups should be skipped and
+		 * we should continue the tree walk.
+		 * last_visited css is safe to use because it is protected by
+		 * css_get and the tree walk is rcu safe.
+		 */
+		if (css == &root->css || (css && css_tryget(css)))
+			memcg = mem_cgroup_from_css(css);
 
 		if (reclaim) {
-			iter->position = id;
+			struct mem_cgroup *curr = memcg;
+
+			if (last_visited)
+				css_put(&last_visited->css);
+
+			if (css && !memcg)
+				curr = mem_cgroup_from_css(css);
+
+			/* make sure that the cached memcg is not removed */
+			if (curr)
+				css_get(&curr->css);
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
 
 		if (prev && !css)
-			goto out_css_put;
+			goto out_unlock;
 	}
+out_unlock:
+	rcu_read_unlock();
 out_css_put:
 	if (prev && prev != root)
 		css_put(&prev->css);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
