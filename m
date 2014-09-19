Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6BFF66B0036
	for <linux-mm@kvack.org>; Fri, 19 Sep 2014 17:11:06 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id q5so228761wiv.7
        for <linux-mm@kvack.org>; Fri, 19 Sep 2014 14:11:05 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c10si3280388wix.55.2014.09.19.14.11.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Sep 2014 14:11:04 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: convert reclaim iterator to simple css refcounting
Date: Fri, 19 Sep 2014 17:10:59 -0400
Message-Id: <1411161059-16552-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The memcg reclaim iterators use a complicated weak reference scheme to
prevent pinning cgroups indefinitely in the absence of memory pressure.

However, during the ongoing cgroup core rework, css lifetime has been
decoupled such that a pinned css no longer interferes with removal of
the user-visible cgroup, and all this complexity is now unnecessary.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memcontrol.c | 200 ++++++++++----------------------------------------------
 1 file changed, 33 insertions(+), 167 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index dfd3b15a57e8..5daa1d3dd9d5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -253,18 +253,6 @@ struct mem_cgroup_stat_cpu {
 	unsigned long targets[MEM_CGROUP_NTARGETS];
 };
 
-struct mem_cgroup_reclaim_iter {
-	/*
-	 * last scanned hierarchy member. Valid only if last_dead_count
-	 * matches memcg->dead_count of the hierarchy root group.
-	 */
-	struct mem_cgroup *last_visited;
-	int last_dead_count;
-
-	/* scan generation, increased every round-trip */
-	unsigned int generation;
-};
-
 /*
  * per-zone information in memory controller.
  */
@@ -272,7 +260,7 @@ struct mem_cgroup_per_zone {
 	struct lruvec		lruvec;
 	unsigned long		lru_size[NR_LRU_LISTS];
 
-	struct mem_cgroup_reclaim_iter reclaim_iter[DEF_PRIORITY + 1];
+	struct mem_cgroup	*reclaim_iter[DEF_PRIORITY + 1];
 
 	struct rb_node		tree_node;	/* RB tree node */
 	unsigned long		usage_in_excess;/* Set to the value by which */
@@ -1174,111 +1162,6 @@ static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 	return memcg;
 }
 
-/*
- * Returns a next (in a pre-order walk) alive memcg (with elevated css
- * ref. count) or NULL if the whole root's subtree has been visited.
- *
- * helper function to be used by mem_cgroup_iter
- */
-static struct mem_cgroup *__mem_cgroup_iter_next(struct mem_cgroup *root,
-		struct mem_cgroup *last_visited)
-{
-	struct cgroup_subsys_state *prev_css, *next_css;
-
-	prev_css = last_visited ? &last_visited->css : NULL;
-skip_node:
-	next_css = css_next_descendant_pre(prev_css, &root->css);
-
-	/*
-	 * Even if we found a group we have to make sure it is
-	 * alive. css && !memcg means that the groups should be
-	 * skipped and we should continue the tree walk.
-	 * last_visited css is safe to use because it is
-	 * protected by css_get and the tree walk is rcu safe.
-	 *
-	 * We do not take a reference on the root of the tree walk
-	 * because we might race with the root removal when it would
-	 * be the only node in the iterated hierarchy and mem_cgroup_iter
-	 * would end up in an endless loop because it expects that at
-	 * least one valid node will be returned. Root cannot disappear
-	 * because caller of the iterator should hold it already so
-	 * skipping css reference should be safe.
-	 */
-	if (next_css) {
-		if ((next_css == &root->css) ||
-		    ((next_css->flags & CSS_ONLINE) &&
-		     css_tryget_online(next_css)))
-			return mem_cgroup_from_css(next_css);
-
-		prev_css = next_css;
-		goto skip_node;
-	}
-
-	return NULL;
-}
-
-static void mem_cgroup_iter_invalidate(struct mem_cgroup *root)
-{
-	/*
-	 * When a group in the hierarchy below root is destroyed, the
-	 * hierarchy iterator can no longer be trusted since it might
-	 * have pointed to the destroyed group.  Invalidate it.
-	 */
-	atomic_inc(&root->dead_count);
-}
-
-static struct mem_cgroup *
-mem_cgroup_iter_load(struct mem_cgroup_reclaim_iter *iter,
-		     struct mem_cgroup *root,
-		     int *sequence)
-{
-	struct mem_cgroup *position = NULL;
-	/*
-	 * A cgroup destruction happens in two stages: offlining and
-	 * release.  They are separated by a RCU grace period.
-	 *
-	 * If the iterator is valid, we may still race with an
-	 * offlining.  The RCU lock ensures the object won't be
-	 * released, tryget will fail if we lost the race.
-	 */
-	*sequence = atomic_read(&root->dead_count);
-	if (iter->last_dead_count == *sequence) {
-		smp_rmb();
-		position = iter->last_visited;
-
-		/*
-		 * We cannot take a reference to root because we might race
-		 * with root removal and returning NULL would end up in
-		 * an endless loop on the iterator user level when root
-		 * would be returned all the time.
-		 */
-		if (position && position != root &&
-		    !css_tryget_online(&position->css))
-			position = NULL;
-	}
-	return position;
-}
-
-static void mem_cgroup_iter_update(struct mem_cgroup_reclaim_iter *iter,
-				   struct mem_cgroup *last_visited,
-				   struct mem_cgroup *new_position,
-				   struct mem_cgroup *root,
-				   int sequence)
-{
-	/* root reference counting symmetric to mem_cgroup_iter_load */
-	if (last_visited && last_visited != root)
-		css_put(&last_visited->css);
-	/*
-	 * We store the sequence count from the time @last_visited was
-	 * loaded successfully instead of rereading it here so that we
-	 * don't lose destruction events in between.  We could have
-	 * raced with the destruction of @new_position after all.
-	 */
-	iter->last_visited = new_position;
-	smp_wmb();
-	iter->last_dead_count = sequence;
-}
-
 /**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
@@ -1300,8 +1183,11 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				   struct mem_cgroup *prev,
 				   struct mem_cgroup_reclaim_cookie *reclaim)
 {
+	struct mem_cgroup_per_zone *uninitialized_var(mz);
+	struct cgroup_subsys_state *css = NULL;
+	int uninitialized_var(priority);
 	struct mem_cgroup *memcg = NULL;
-	struct mem_cgroup *last_visited = NULL;
+	struct mem_cgroup *pos = NULL;
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1310,50 +1196,50 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 		root = root_mem_cgroup;
 
 	if (prev && !reclaim)
-		last_visited = prev;
+		pos = prev;
 
 	if (!root->use_hierarchy && root != root_mem_cgroup) {
 		if (prev)
-			goto out_css_put;
+			goto out;
 		return root;
 	}
 
 	rcu_read_lock();
-	while (!memcg) {
-		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
-		int uninitialized_var(seq);
 
-		if (reclaim) {
-			struct mem_cgroup_per_zone *mz;
+	if (reclaim) {
+		mz = mem_cgroup_zone_zoneinfo(root, reclaim->zone);
+		priority = reclaim->priority;
 
-			mz = mem_cgroup_zone_zoneinfo(root, reclaim->zone);
-			iter = &mz->reclaim_iter[reclaim->priority];
-			if (prev && reclaim->generation != iter->generation) {
-				iter->last_visited = NULL;
-				goto out_unlock;
-			}
-
-			last_visited = mem_cgroup_iter_load(iter, root, &seq);
-		}
-
-		memcg = __mem_cgroup_iter_next(root, last_visited);
+		do {
+			pos = ACCESS_ONCE(mz->reclaim_iter[priority]);
+		} while (!css_tryget(&pos->css));
+	}
 
-		if (reclaim) {
-			mem_cgroup_iter_update(iter, last_visited, memcg, root,
-					seq);
+	if (pos)
+		css = &pos->css;
 
-			if (!memcg)
-				iter->generation++;
-			else if (!prev && memcg)
-				reclaim->generation = iter->generation;
+	for (;;) {
+		css = css_next_descendant_pre(css, &root->css);
+		if (!css) {
+			if (prev)
+				goto out_unlock;
+			continue;
+		}
+		if (css == &root->css || css_tryget_online(css)) {
+			memcg = mem_cgroup_from_css(css);
+			break;
 		}
+	}
 
-		if (prev && !memcg)
-			goto out_unlock;
+	if (reclaim) {
+		if (cmpxchg(&mz->reclaim_iter[priority], pos, memcg) == pos)
+			css_get(&memcg->css);
+		css_put(&pos->css);
 	}
+
 out_unlock:
 	rcu_read_unlock();
-out_css_put:
+out:
 	if (prev && prev != root)
 		css_put(&prev->css);
 
@@ -5526,24 +5412,6 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 	return memcg_init_kmem(memcg, &memory_cgrp_subsys);
 }
 
-/*
- * Announce all parents that a group from their hierarchy is gone.
- */
-static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
-{
-	struct mem_cgroup *parent = memcg;
-
-	while ((parent = parent_mem_cgroup(parent)))
-		mem_cgroup_iter_invalidate(parent);
-
-	/*
-	 * if the root memcg is not hierarchical we have to check it
-	 * explicitely.
-	 */
-	if (!root_mem_cgroup->use_hierarchy)
-		mem_cgroup_iter_invalidate(root_mem_cgroup);
-}
-
 static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
@@ -5564,8 +5432,6 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
 
 	kmem_cgroup_css_offline(memcg);
 
-	mem_cgroup_invalidate_reclaim_iterators(memcg);
-
 	/*
 	 * This requires that offlining is serialized.  Right now that is
 	 * guaranteed because css_killed_work_fn() holds the cgroup_mutex.
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
