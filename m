Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5ABA46B0036
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 20:44:57 -0400 (EDT)
Received: by mail-qa0-f53.google.com with SMTP id bs12so48841qab.12
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 17:44:56 -0700 (PDT)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Date: Mon,  3 Jun 2013 17:44:39 -0700
Message-Id: <1370306679-13129-4-git-send-email-tj@kernel.org>
In-Reply-To: <1370306679-13129-1-git-send-email-tj@kernel.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz, hannes@cmpxchg.org, bsingharora@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com, Tejun Heo <tj@kernel.org>

mem_cgroup_iter() shares mem_cgroup_reclaim_iters among multiple
reclaimers to prevent multiple reclaimers banging on the same cgroups.
To achieve this, mem_cgroup_reclaim_iter remembers the last visited
cgroup.  Before the recent changes, cgroup_next_descendant_pre()
required that the current cgroup is alive or RCU grace period hasn't
passed after its removal as ->sibling.next couldn't be trusted
otherwise.

As bumping cgroup_subsys_state reference doesn't prevent the cgroup
from being removed, instead of pinning the current cgroup,
mem_cgroup_reclaim_iter tracks the number of cgroup removal events in
the subtree and resets the iteration if any removal has happened since
caching the current cgroup.  This scheme involves an overly elaborate
and hard-to-follow synchronization scheme as it needs to game cgroup
removal RCU grace period.

Now that cgroup_next_descendant_pre() can return the next sibling
reliably regardless of the state of the current cgroup, this can be
implemented in a much simpler and more conventional way.
mem_cgroup_reclaim_iter can pin the current cgroup and use
__mem_cgroup_iter_next() on it for the next iteration.  The whole
thing becomes normal RCU synchronization.  Updating the cursor to the
next position is slightly more involved as multiple tasks could be
trying to update it at the same time; however, it can be easily
implemented using xchg().

This replaces the overly elaborate synchronization scheme along with
->dead_count management with a more conventional RCU usage.  As an
added bonus, the new implementation doesn't reset the cursor everytime
a cgroup is deleted in the subtree.  It safely continues the
iteration.

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 mm/memcontrol.c | 89 ++++++++++++++-------------------------------------------
 1 file changed, 21 insertions(+), 68 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 99e7357..4057730 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -155,12 +155,8 @@ struct mem_cgroup_stat_cpu {
 };
 
 struct mem_cgroup_reclaim_iter {
-	/*
-	 * last scanned hierarchy member. Valid only if last_dead_count
-	 * matches memcg->dead_count of the hierarchy root group.
-	 */
-	struct mem_cgroup *last_visited;
-	unsigned long last_dead_count;
+	/* last scanned hierarchy member, pinned */
+	struct mem_cgroup __rcu *last_visited;
 
 	/* scan generation, increased every round-trip */
 	unsigned int generation;
@@ -1172,6 +1168,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	struct mem_cgroup *memcg = NULL;
 	struct mem_cgroup_per_zone *mz;
 	struct mem_cgroup_reclaim_iter *iter;
+	struct mem_cgroup *last_visited;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1195,63 +1192,25 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 
 	/*
 	 * @reclaim specified - find and share the per-zone-priority
-	 * iterator.
+	 * iterator.  Because @iter->last_visited holds the reference and
+	 * css's are RCU protected, it's guaranteed that last_visited will
+	 * remain accessible while we're holding RCU read lock.
 	 */
 	mz = mem_cgroup_zoneinfo(root, zone_to_nid(reclaim->zone),
 				 zone_idx(reclaim->zone));
 	iter = &mz->reclaim_iter[reclaim->priority];
+	last_visited = rcu_dereference(iter->last_visited);
 
 	while (true) {
-		struct mem_cgroup *last_visited;
-		unsigned long dead_count;
-
 		/*
 		 * If this caller already iterated through some and @iter
 		 * wrapped since, finish this the iteration.
 		 */
-		if (prev && reclaim->generation != iter->generation) {
-			iter->last_visited = NULL;
+		if (prev && reclaim->generation != iter->generation)
 			break;
-		}
-
-		/*
-		 * If the dead_count mismatches, a destruction has happened
-		 * or is happening concurrently.  If the dead_count
-		 * matches, a destruction might still happen concurrently,
-		 * but since we checked under RCU, that destruction won't
-		 * free the object until we release the RCU reader lock.
-		 * Thus, the dead_count check verifies the pointer is still
-		 * valid, css_tryget() verifies the cgroup pointed to is
-		 * alive.
-		 */
-		dead_count = atomic_read(&root->dead_count);
-
-		last_visited = iter->last_visited;
-		if (last_visited) {
-			/*
-			 * Paired with smp_wmb() below in this function.
-			 * The pair guarantee that last_visited is more
-			 * current than last_dead_count, which may lead to
-			 * spurious iteration resets but guarantees
-			 * reliable detection of dead condition.
-			 */
-			smp_rmb();
-			if ((dead_count != iter->last_dead_count) ||
-			    !css_tryget(&last_visited->css)) {
-				last_visited = NULL;
-			}
-		}
 
 		memcg = __mem_cgroup_iter_next(root, last_visited);
 
-		if (last_visited)
-			css_put(&last_visited->css);
-
-		iter->last_visited = memcg;
-		/* paired with smp_rmb() above in this function */
-		smp_wmb();
-		iter->last_dead_count = dead_count;
-
 		/* if successful, sync the generation number and return */
 		if (likely(memcg)) {
 			reclaim->generation = iter->generation;
@@ -1267,7 +1226,20 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			break;
 
 		iter->generation++;
+		last_visited = NULL;
 	}
+
+	/*
+	 * Update @iter to the new position.  As multiple tasks could be
+	 * executing this path, atomically swap the new and old.  We want
+	 * RCU assignment here but there's no rcu_xchg() and the plain
+	 * xchg() has enough memory barrier semantics.
+	 */
+	if (memcg)
+		css_get(&memcg->css);
+	last_visited = xchg(&iter->last_visited, memcg);
+	if (last_visited)
+		css_put(&last_visited->css);
 out_unlock:
 	rcu_read_unlock();
 out_css_put:
@@ -6324,29 +6296,10 @@ mem_cgroup_css_online(struct cgroup *cont)
 	return error;
 }
 
-/*
- * Announce all parents that a group from their hierarchy is gone.
- */
-static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
-{
-	struct mem_cgroup *parent = memcg;
-
-	while ((parent = parent_mem_cgroup(parent)))
-		atomic_inc(&parent->dead_count);
-
-	/*
-	 * if the root memcg is not hierarchical we have to check it
-	 * explicitely.
-	 */
-	if (!root_mem_cgroup->use_hierarchy)
-		atomic_inc(&root_mem_cgroup->dead_count);
-}
-
 static void mem_cgroup_css_offline(struct cgroup *cont)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
 
-	mem_cgroup_invalidate_reclaim_iterators(memcg);
 	mem_cgroup_reparent_charges(memcg);
 	mem_cgroup_destroy_all_caches(memcg);
 }
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
