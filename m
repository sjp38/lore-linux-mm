Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 443946B0036
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 18:53:57 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/2] mm: memcontrol: factor out reclaim iterator loading and updating
Date: Wed,  5 Jun 2013 18:53:46 -0400
Message-Id: <1370472826-29959-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1370472826-29959-1-git-send-email-hannes@cmpxchg.org>
References: <1370472826-29959-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

mem_cgroup_iter() is too hard to follow.  Factor out the lockless
reclaim iterator loading and updating so it's easier to follow the big
picture.

Also document the iterator invalidation mechanism a bit more
extensively.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 86 ++++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 57 insertions(+), 29 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e2cbb44..23a9236 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1148,6 +1148,58 @@ skip_node:
 	return NULL;
 }
 
+static void mem_cgroup_iter_invalidate(struct mem_cgroup *root)
+{
+	/*
+	 * When a group in the hierarchy below root is destroyed, the
+	 * hierarchy iterator can no longer be trusted since it might
+	 * have pointed to the destroyed group.  Invalidate it.
+	 */
+	atomic_inc(&root->dead_count);
+}
+
+static struct mem_cgroup *
+mem_cgroup_iter_load(struct mem_cgroup_reclaim_iter *iter,
+		     struct mem_cgroup *root,
+		     int *sequence)
+{
+	struct mem_cgroup *position = NULL;
+	/*
+	 * A cgroup destruction happens in two stages: offlining and
+	 * release.  They are separated by a RCU grace period.
+	 *
+	 * If the iterator is valid, we may still race with an
+	 * offlining.  The RCU lock ensures the object won't be
+	 * released, tryget will fail if we lost the race.
+	 */
+	*sequence = atomic_read(&root->dead_count);
+	if (iter->last_dead_count == *sequence) {
+		smp_rmb();
+		position = iter->last_visited;
+		if (position && !css_tryget(&position->css))
+			position = NULL;
+	}
+	return position;
+}
+
+static void mem_cgroup_iter_update(struct mem_cgroup_reclaim_iter *iter,
+				   struct mem_cgroup *last_visited,
+				   struct mem_cgroup *new_position,
+				   int sequence)
+{
+	if (last_visited)
+		css_put(&last_visited->css);
+	/*
+	 * We store the sequence count from the time @last_visited was
+	 * loaded successfully instead of rereading it here so that we
+	 * don't lose destruction events in between.  We could have
+	 * raced with the destruction of @new_position after all.
+	 */
+	iter->last_visited = new_position;
+	smp_wmb();
+	iter->last_dead_count = sequence;
+}
+
 /**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
@@ -1171,7 +1223,6 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 {
 	struct mem_cgroup *memcg = NULL;
 	struct mem_cgroup *last_visited = NULL;
-	unsigned long uninitialized_var(dead_count);
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1191,6 +1242,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	rcu_read_lock();
 	while (!memcg) {
 		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
+		int uninitialized_var(seq);
 
 		if (reclaim) {
 			int nid = zone_to_nid(reclaim->zone);
@@ -1204,37 +1256,13 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				goto out_unlock;
 			}
 
-			/*
-			 * If the dead_count mismatches, a destruction
-			 * has happened or is happening concurrently.
-			 * If the dead_count matches, a destruction
-			 * might still happen concurrently, but since
-			 * we checked under RCU, that destruction
-			 * won't free the object until we release the
-			 * RCU reader lock.  Thus, the dead_count
-			 * check verifies the pointer is still valid,
-			 * css_tryget() verifies the cgroup pointed to
-			 * is alive.
-			 */
-			dead_count = atomic_read(&root->dead_count);
-			if (dead_count == iter->last_dead_count) {
-				smp_rmb();
-				last_visited = iter->last_visited;
-				if (last_visited &&
-				    !css_tryget(&last_visited->css))
-					last_visited = NULL;
-			}
+			last_visited = mem_cgroup_iter_load(iter, root, &seq);
 		}
 
 		memcg = __mem_cgroup_iter_next(root, last_visited);
 
 		if (reclaim) {
-			if (last_visited)
-				css_put(&last_visited->css);
-
-			iter->last_visited = memcg;
-			smp_wmb();
-			iter->last_dead_count = dead_count;
+			mem_cgroup_iter_update(iter, last_visited, memcg, seq);
 
 			if (!memcg)
 				iter->generation++;
@@ -6319,14 +6347,14 @@ static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
 	struct mem_cgroup *parent = memcg;
 
 	while ((parent = parent_mem_cgroup(parent)))
-		atomic_inc(&parent->dead_count);
+		mem_cgroup_iter_invalidate(parent);
 
 	/*
 	 * if the root memcg is not hierarchical we have to check it
 	 * explicitely.
 	 */
 	if (!root_mem_cgroup->use_hierarchy)
-		atomic_inc(&root_mem_cgroup->dead_count);
+		mem_cgroup_iter_invalidate(root_mem_cgroup);
 }
 
 static void mem_cgroup_css_offline(struct cgroup *cont)
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
