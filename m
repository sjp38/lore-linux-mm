Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id D1C9E6B0075
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 12:54:48 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v3 5/7] memcg: simplify mem_cgroup_iter
Date: Thu,  3 Jan 2013 18:54:19 +0100
Message-Id: <1357235661-29564-6-git-send-email-mhocko@suse.cz>
In-Reply-To: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
References: <1357235661-29564-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>, Li Zefan <lizefan@huawei.com>

Current implementation of mem_cgroup_iter has to consider both css and
memcg to find out whether no group has been found (css==NULL - aka the
loop is completed) and that no memcg is associated with the found node
(!memcg - aka css_tryget failed because the group is no longer alive).
This leads to awkward tweaks like tests for css && !memcg to skip the
current node.

It will be much easier if we got rid off css variable altogether and
only rely on memcg. In order to do that the iteration part has to skip
dead nodes. This sounds natural to me and as a nice side effect we will
get a simple invariant that memcg is always alive when non-NULL and all
nodes have been visited otherwise.

We could get rid of the surrounding while loop but keep it in for now to
make review easier. It will go away in the following patch.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   56 +++++++++++++++++++++++++++----------------------------
 1 file changed, 27 insertions(+), 29 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4f81abd..d8c6e5e 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1152,7 +1152,6 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	rcu_read_lock();
 	while (!memcg) {
 		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
-		struct cgroup_subsys_state *css = NULL;
 
 		if (reclaim) {
 			int nid = zone_to_nid(reclaim->zone);
@@ -1178,53 +1177,52 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		 * explicit visit.
 		 */
 		if (!last_visited) {
-			css = &root->css;
+			memcg = root;
 		} else {
 			struct cgroup *prev_cgroup, *next_cgroup;
 
 			prev_cgroup = (last_visited == root) ? NULL
 				: last_visited->css.cgroup;
-			next_cgroup = cgroup_next_descendant_pre(prev_cgroup,
-					root->css.cgroup);
-			if (next_cgroup)
-				css = cgroup_subsys_state(next_cgroup,
-						mem_cgroup_subsys_id);
-		}
+skip_node:
+			next_cgroup = cgroup_next_descendant_pre(
+					prev_cgroup, root->css.cgroup);
 
-		/*
-		 * Even if we found a group we have to make sure it is alive.
-		 * css && !memcg means that the groups should be skipped and
-		 * we should continue the tree walk.
-		 * last_visited css is safe to use because it is protected by
-		 * css_get and the tree walk is rcu safe.
-		 */
-		if (css == &root->css || (css && css_tryget(css)))
-			memcg = mem_cgroup_from_css(css);
+			/*
+			 * Even if we found a group we have to make sure it is
+			 * alive. css && !memcg means that the groups should be
+			 * skipped and we should continue the tree walk.
+			 * last_visited css is safe to use because it is
+			 * protected by css_get and the tree walk is rcu safe.
+			 */
+			if (next_cgroup) {
+				struct mem_cgroup *mem = mem_cgroup_from_cont(
+						next_cgroup);
+				if (css_tryget(&mem->css))
+					memcg = mem;
+				else {
+					prev_cgroup = next_cgroup;
+					goto skip_node;
+				}
+			}
+		}
 
 		if (reclaim) {
-			struct mem_cgroup *curr = memcg;
-
 			if (last_visited)
 				css_put(&last_visited->css);
 
-			if (css && !memcg)
-				curr = mem_cgroup_from_css(css);
-
 			/* make sure that the cached memcg is not removed */
-			if (curr)
-				css_get(&curr->css);
-			iter->last_visited = curr;
+			if (memcg)
+				css_get(&memcg->css);
+			iter->last_visited = memcg;
 
-			if (!css)
+			if (!memcg)
 				iter->generation++;
 			else if (!prev && memcg)
 				reclaim->generation = iter->generation;
 			spin_unlock(&iter->iter_lock);
-		} else if (css && !memcg) {
-			last_visited = mem_cgroup_from_css(css);
 		}
 
-		if (prev && !css)
+		if (prev && !memcg)
 			goto out_unlock;
 	}
 out_unlock:
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
