Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id A2B696B009A
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 10:31:22 -0500 (EST)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC 4/5] memcg: clean up mem_cgroup_iter
Date: Tue, 13 Nov 2012 16:30:38 +0100
Message-Id: <1352820639-13521-5-git-send-email-mhocko@suse.cz>
In-Reply-To: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
References: <1352820639-13521-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Tejun Heo <htejun@gmail.com>, Glauber Costa <glommer@parallels.com>

Get rid of while(!memcg) loop as it is no longer needed because there
will always be at least one group that should be visited (root).

This patch doesn't add any change to the implementation but it is
separate to make a review easier.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c |  120 +++++++++++++++++++++++++++----------------------------
 1 file changed, 60 insertions(+), 60 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index dd84094..b924f27 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1063,6 +1063,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				   struct mem_cgroup *prev,
 				   struct mem_cgroup_reclaim_cookie *reclaim)
 {
+	struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
 	struct mem_cgroup *memcg = NULL,
 			  *last_visited = NULL;
 
@@ -1084,76 +1085,75 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		return root;
 	}
 
-	while (!memcg) {
-		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
-
-		if (reclaim) {
-			int nid = zone_to_nid(reclaim->zone);
-			int zid = zone_idx(reclaim->zone);
-			struct mem_cgroup_per_zone *mz;
-
-			mz = mem_cgroup_zoneinfo(root, nid, zid);
-			iter = &mz->reclaim_iter[reclaim->priority];
-			spin_lock(&iter->iter_lock);
-			last_visited = iter->last_visited;
-			if (prev && reclaim->generation != iter->generation) {
-				if (last_visited) {
-					mem_cgroup_put(last_visited);
-					iter->last_visited = NULL;
-				}
-				spin_unlock(&iter->iter_lock);
-				return NULL;
+	if (reclaim) {
+		int nid = zone_to_nid(reclaim->zone);
+		int zid = zone_idx(reclaim->zone);
+		struct mem_cgroup_per_zone *mz;
+
+		mz = mem_cgroup_zoneinfo(root, nid, zid);
+		iter = &mz->reclaim_iter[reclaim->priority];
+		spin_lock(&iter->iter_lock);
+		last_visited = iter->last_visited;
+		if (prev && reclaim->generation != iter->generation) {
+			if (last_visited) {
+				mem_cgroup_put(last_visited);
+				iter->last_visited = NULL;
 			}
+			spin_unlock(&iter->iter_lock);
+			return NULL;
 		}
+	}
 
-		rcu_read_lock();
+	rcu_read_lock();
+	/*
+	 * Root is not visited by cgroup iterators so it needs a special
+	 * treatment.
+	 */
+	if (!last_visited) {
+		memcg = root;
+	} else {
+		struct cgroup *next_cgroup,
+			      *pos = last_visited->css.cgroup;
+skip_node:
+		next_cgroup = cgroup_next_descendant_pre(
+				pos,
+				root->css.cgroup);
 		/*
-		 * Root is not visited by cgroup iterators so it needs a special
-		 * treatment.
+		 * Even if we find a group we have to make sure it is
+		 * alive. If not we, should skip the node.
 		 */
-		if (!last_visited) {
-			memcg = root;
-		} else {
-			struct cgroup *next_cgroup,
-				      *pos = last_visited->css.cgroup;
-skip_node:
-			next_cgroup = cgroup_next_descendant_pre(
-					pos,
-					root->css.cgroup);
-			/*
-			 * Even if we find a group we have to make sure it is
-			 * alive. If not we, should skip the node.
-			 */
-			if (next_cgroup) {
-				struct mem_cgroup *mem = mem_cgroup_from_cont(
-						next_cgroup);
-				if (css_tryget(&mem->css))
-					memcg = mem;
-				else {
-					pos = next_cgroup;
-					goto skip_node;
-				}
+		if (next_cgroup) {
+			struct mem_cgroup *mem = mem_cgroup_from_cont(
+					next_cgroup);
+			if (css_tryget(&mem->css))
+				memcg = mem;
+			else {
+				pos = next_cgroup;
+				goto skip_node;
 			}
 		}
+	}
 
-		if (reclaim) {
-			if (last_visited)
-				mem_cgroup_put(last_visited);
-			if (memcg)
-				mem_cgroup_get(memcg);
-			iter->last_visited = memcg;
-
-			if (!memcg)
-				iter->generation++;
-			else if (!prev && memcg)
-				reclaim->generation = iter->generation;
-			spin_unlock(&iter->iter_lock);
-		}
-		rcu_read_unlock();
+	if (reclaim) {
+		if (last_visited)
+			mem_cgroup_put(last_visited);
+		if (memcg)
+			mem_cgroup_get(memcg);
+		iter->last_visited = memcg;
 
-		if (prev && !memcg)
-			return NULL;
+		if (!memcg)
+			iter->generation++;
+		else if (!prev && memcg)
+			reclaim->generation = iter->generation;
+		spin_unlock(&iter->iter_lock);
 	}
+	rcu_read_unlock();
+
+	/*
+	 * At least root has to be visited
+	 */
+	VM_BUG_ON(!prev && !memcg);
+
 	return memcg;
 }
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
