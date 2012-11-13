Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 83F1E6B0095
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 10:31:21 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 3/5] memcg: simplify mem_cgroup_iter
Date: Tue, 13 Nov 2012 16:30:37 +0100
Message-Id: <1352820639-13521-4-git-send-email-mhocko@suse.cz>
In-Reply-To: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

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

We could get rid of the surrounding while loop but keep it for now for
an easier review. It will go away in the next patch.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |   52 ++++++++++++++++++++++++----------------------------
 1 file changed, 24 insertions(+), 28 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5da1e58..dd84094 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1086,7 +1086,6 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 
 	while (!memcg) {
 		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
-		struct cgroup_subsys_state *css = NULL;
 
 		if (reclaim) {
 			int nid = zone_to_nid(reclaim->zone);
@@ -1113,49 +1112,46 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		 * treatment.
 		 */
 		if (!last_visited) {
-			css = &root->css;
+			memcg = root;
 		} else {
-			struct cgroup *next_cgroup;
-
+			struct cgroup *next_cgroup,
+				      *pos = last_visited->css.cgroup;
+skip_node:
 			next_cgroup = cgroup_next_descendant_pre(
-					last_visited->css.cgroup,
+					pos,
 					root->css.cgroup);
-			if (next_cgroup)
-				css = cgroup_subsys_state(next_cgroup,
-						mem_cgroup_subsys_id);
+			/*
+			 * Even if we find a group we have to make sure it is
+			 * alive. If not we, should skip the node.
+			 */
+			if (next_cgroup) {
+				struct mem_cgroup *mem = mem_cgroup_from_cont(
+						next_cgroup);
+				if (css_tryget(&mem->css))
+					memcg = mem;
+				else {
+					pos = next_cgroup;
+					goto skip_node;
+				}
+			}
 		}
 
-		/*
-		 * Even if we find a group we have to make sure it is alive.
-		 * css && !memcg means that the groups should be skipped and
-		 * we should continue the tree walk.
-		 */
-		if (css == &root->css || (css && css_tryget(css)))
-			memcg = mem_cgroup_from_css(css);
-
 		if (reclaim) {
-			struct mem_cgroup *curr = memcg;
-
 			if (last_visited)
 				mem_cgroup_put(last_visited);
+			if (memcg)
+				mem_cgroup_get(memcg);
+			iter->last_visited = memcg;
 
-			if (css && !memcg)
-				curr = mem_cgroup_from_css(css);
-			if (curr)
-				mem_cgroup_get(curr);
-			iter->last_visited = curr;
-
-			if (!css)
+			if (!memcg)
 				iter->generation++;
 			else if (!prev && memcg)
 				reclaim->generation = iter->generation;
 			spin_unlock(&iter->iter_lock);
-		} else if (css && !memcg) {
-			last_visited = mem_cgroup_from_css(css);
 		}
 		rcu_read_unlock();
 
-		if (prev && !css)
+		if (prev && !memcg)
 			return NULL;
 	}
 	return memcg;
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
