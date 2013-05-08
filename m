Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C3F176B00A4
	for <linux-mm@kvack.org>; Wed,  8 May 2013 16:23:58 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v5 26/31] memcg: scan cache objects hierarchically
Date: Thu,  9 May 2013 00:23:14 +0400
Message-Id: <1368044599-3383-27-git-send-email-glommer@openvz.org>
In-Reply-To: <1368044599-3383-1-git-send-email-glommer@openvz.org>
References: <1368044599-3383-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

When reaching shrink_slab, we should descent in children memcg searching
for objects that could be shrunk. This is true even if the memcg does
not have kmem limits on, since the kmem res_counter will also be billed
against the user res_counter of the parent.

It is possible that we will free objects and not free any pages, that
will just harm the child groups without helping the parent group at all.
But at this point, we basically are prepared to pay the price.

Signed-off-by: Glauber Costa <glommer@openvz.org>
Cc: Dave Chinner <dchinner@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 include/linux/memcontrol.h |   6 ++
 mm/memcontrol.c            |  13 +++
 mm/vmscan.c                | 239 ++++++++++++++++++++++++++-------------------
 3 files changed, 155 insertions(+), 103 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6dc1d7a..782dcbf 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -440,6 +440,7 @@ static inline bool memcg_kmem_enabled(void)
 	return static_key_false(&memcg_kmem_enabled_key);
 }
 
+bool memcg_kmem_should_reclaim(struct mem_cgroup *memcg);
 bool memcg_kmem_is_active(struct mem_cgroup *memcg);
 
 /*
@@ -584,6 +585,11 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 }
 #else
 
+static inline bool memcg_kmem_should_reclaim(struct mem_cgroup *memcg)
+{
+	return false;
+}
+
 static inline bool memcg_kmem_is_active(struct mem_cgroup *memcg)
 {
 	return false;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4159b90..e6a7848 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2969,6 +2969,19 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 }
 
 #ifdef CONFIG_MEMCG_KMEM
+bool memcg_kmem_should_reclaim(struct mem_cgroup *memcg)
+{
+	struct mem_cgroup *iter;
+
+	for_each_mem_cgroup_tree(iter, memcg) {
+		if (memcg_kmem_is_active(iter)) {
+			mem_cgroup_iter_break(memcg, iter);
+			return true;
+		}
+	}
+	return false;
+}
+
 static inline bool memcg_can_account_kmem(struct mem_cgroup *memcg)
 {
 	return !mem_cgroup_disabled() && !mem_cgroup_is_root(memcg) &&
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 53f0dbd..f3e5086 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -148,7 +148,7 @@ static bool global_reclaim(struct scan_control *sc)
 static bool has_kmem_reclaim(struct scan_control *sc)
 {
 	return !sc->target_mem_cgroup ||
-		memcg_kmem_is_active(sc->target_mem_cgroup);
+		memcg_kmem_should_reclaim(sc->target_mem_cgroup);
 }
 
 static unsigned long
@@ -209,6 +209,118 @@ void unregister_shrinker(struct shrinker *shrinker)
 EXPORT_SYMBOL(unregister_shrinker);
 
 #define SHRINK_BATCH 128
+unsigned long
+shrink_slab_one(struct shrinker *shrinker, struct shrink_control *shrinkctl,
+		unsigned long nr_pages_scanned, unsigned long lru_pages)
+{
+	unsigned long freed = 0;
+	unsigned long long delta;
+	long total_scan;
+	long max_pass;
+	long nr;
+	long new_nr;
+	long batch_size = shrinker->batch ? shrinker->batch
+					  : SHRINK_BATCH;
+
+	max_pass = shrinker->count_objects(shrinker, shrinkctl);
+	WARN_ON(max_pass < 0);
+	if (max_pass <= 0)
+		return 0;
+
+	/*
+	 * copy the current shrinker scan count into a local variable
+	 * and zero it so that other concurrent shrinker invocations
+	 * don't also do this scanning work.
+	 */
+	nr = atomic_long_xchg(&shrinker->nr_in_batch, 0);
+
+	total_scan = nr;
+	delta = (4 * nr_pages_scanned) / shrinker->seeks;
+	delta *= max_pass;
+	do_div(delta, lru_pages + 1);
+	total_scan += delta;
+	if (total_scan < 0) {
+		printk(KERN_ERR
+		"shrink_slab: %pF negative objects to delete nr=%ld\n",
+		       shrinker->scan_objects, total_scan);
+		total_scan = max_pass;
+	}
+
+	/*
+	 * We need to avoid excessive windup on filesystem shrinkers
+	 * due to large numbers of GFP_NOFS allocations causing the
+	 * shrinkers to return -1 all the time. This results in a large
+	 * nr being built up so when a shrink that can do some work
+	 * comes along it empties the entire cache due to nr >>>
+	 * max_pass.  This is bad for sustaining a working set in
+	 * memory.
+	 *
+	 * Hence only allow the shrinker to scan the entire cache when
+	 * a large delta change is calculated directly.
+	 */
+	if (delta < max_pass / 4)
+		total_scan = min(total_scan, max_pass / 2);
+
+	/*
+	 * Avoid risking looping forever due to too large nr value:
+	 * never try to free more than twice the estimate number of
+	 * freeable entries.
+	 */
+	if (total_scan > max_pass * 2)
+		total_scan = max_pass * 2;
+
+	trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
+				nr_pages_scanned, lru_pages,
+				max_pass, delta, total_scan);
+
+	do {
+		long ret;
+		/*
+		 * When we are kswapd, there is no need for us to go
+		 * desperate and try to reclaim any number of objects
+		 * regardless of batch size. Direct reclaim, OTOH, may
+		 * benefit from freeing objects in any quantities. If
+		 * the workload is actually stressing those objects,
+		 * this may be the difference between succeeding or
+		 * failing an allocation.
+		 */
+		if ((total_scan < batch_size) && current_is_kswapd())
+			break;
+		/*
+		 * Differentiate between "few objects" and "no objects"
+		 * as returned by the count step.
+		 */
+		if (!total_scan)
+			break;
+
+		shrinkctl->nr_to_scan = min(batch_size, total_scan);
+		ret = shrinker->scan_objects(shrinker, shrinkctl);
+		if (ret == -1)
+			break;
+		freed += ret;
+
+		count_vm_events(SLABS_SCANNED, batch_size);
+		total_scan -= batch_size;
+
+		cond_resched();
+	} while (total_scan >= batch_size);
+
+	/*
+	 * move the unused scan count back into the shrinker in a
+	 * manner that handles concurrent updates. If we exhausted the
+	 * scan, there is no need to do an update.
+	 */
+	if (total_scan > 0)
+		new_nr = atomic_long_add_return(total_scan,
+				&shrinker->nr_in_batch);
+	else
+		new_nr = atomic_long_read(&shrinker->nr_in_batch);
+
+	trace_mm_shrink_slab_end(shrinker, freed, nr, new_nr);
+
+	return freed;
+}
+
 /*
  * Call the shrink functions to age shrinkable caches
  *
@@ -234,6 +346,7 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
+	struct mem_cgroup *root = shrinkctl->target_mem_cgroup;
 
 	if (nr_pages_scanned == 0)
 		nr_pages_scanned = SWAP_CLUSTER_MAX;
@@ -245,119 +358,39 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 	}
 
 	list_for_each_entry(shrinker, &shrinker_list, list) {
-		unsigned long long delta;
-		long total_scan;
-		long max_pass;
-		long nr;
-		long new_nr;
-		long batch_size = shrinker->batch ? shrinker->batch
-						  : SHRINK_BATCH;
-
+		struct mem_cgroup *memcg;
 		/*
 		 * If we don't have a target mem cgroup, we scan them all.
 		 * Otherwise we will limit our scan to shrinkers marked as
 		 * memcg aware
 		 */
-		if (shrinkctl->target_mem_cgroup && !shrinker->memcg_shrinker)
+		if (root && !shrinker->memcg_shrinker)
 			continue;
 
-		max_pass = shrinker->count_objects(shrinker, shrinkctl);
-		WARN_ON(max_pass < 0);
-		if (max_pass <= 0)
-			continue;
-
-		/*
-		 * copy the current shrinker scan count into a local variable
-		 * and zero it so that other concurrent shrinker invocations
-		 * don't also do this scanning work.
-		 */
-		nr = atomic_long_xchg(&shrinker->nr_in_batch, 0);
-
-		total_scan = nr;
-		delta = (4 * nr_pages_scanned) / shrinker->seeks;
-		delta *= max_pass;
-		do_div(delta, lru_pages + 1);
-		total_scan += delta;
-		if (total_scan < 0) {
-			printk(KERN_ERR
-			"shrink_slab: %pF negative objects to delete nr=%ld\n",
-			       shrinker->scan_objects, total_scan);
-			total_scan = max_pass;
-		}
-
-		/*
-		 * We need to avoid excessive windup on filesystem shrinkers
-		 * due to large numbers of GFP_NOFS allocations causing the
-		 * shrinkers to return -1 all the time. This results in a large
-		 * nr being built up so when a shrink that can do some work
-		 * comes along it empties the entire cache due to nr >>>
-		 * max_pass.  This is bad for sustaining a working set in
-		 * memory.
-		 *
-		 * Hence only allow the shrinker to scan the entire cache when
-		 * a large delta change is calculated directly.
-		 */
-		if (delta < max_pass / 4)
-			total_scan = min(total_scan, max_pass / 2);
-
-		/*
-		 * Avoid risking looping forever due to too large nr value:
-		 * never try to free more than twice the estimate number of
-		 * freeable entries.
-		 */
-		if (total_scan > max_pass * 2)
-			total_scan = max_pass * 2;
-
-		trace_mm_shrink_slab_start(shrinker, shrinkctl, nr,
-					nr_pages_scanned, lru_pages,
-					max_pass, delta, total_scan);
-
+		memcg = mem_cgroup_iter(root, NULL, NULL);
 		do {
-			long ret;
-
+			shrinkctl->target_mem_cgroup = memcg;
 			/*
-			 * When we are kswapd, there is no need for us to go
-			 * desperate and try to reclaim any number of objects
-			 * regardless of batch size. Direct reclaim, OTOH, may
-			 * benefit from freeing objects in any quantities. If
-			 * the workload is actually stressing those objects,
-			 * this may be the difference between succeeding or
-			 * failing an allocation.
-			 */
-			if ((total_scan < batch_size) && current_is_kswapd())
-				break;
-			/*
-			 * Differentiate between "few objects" and "no objects"
-			 * as returned by the count step.
+			 * In a hierarchical chain, it might be that not all
+			 * memcgs are kmem active. kmemcg design mandates that
+			 * when one memcg is active, its children will be
+			 * active as well. But it is perfectly possible that
+			 * its parent is not.
+			 *
+			 * We also need to make sure we scan at least once, for
+			 * the global case. So if we don't have a target memcg
+			 * (saved in root), we proceed normally and expect to
+			 * break in the next round.
 			 */
-			if (!total_scan)
-				break;
-
-			shrinkctl->nr_to_scan = min(batch_size, total_scan);
-			ret = shrinker->scan_objects(shrinker, shrinkctl);
-			if (ret == -1)
-				break;
-			freed += ret;
-
-			count_vm_events(SLABS_SCANNED, batch_size);
-			total_scan -= batch_size;
-
-			cond_resched();
-		} while (total_scan >= batch_size);
-
-		/*
-		 * move the unused scan count back into the shrinker in a
-		 * manner that handles concurrent updates. If we exhausted the
-		 * scan, there is no need to do an update.
-		 */
-		if (total_scan > 0)
-			new_nr = atomic_long_add_return(total_scan,
-					&shrinker->nr_in_batch);
-		else
-			new_nr = atomic_long_read(&shrinker->nr_in_batch);
-
-		trace_mm_shrink_slab_end(shrinker, freed, nr, new_nr);
+			if (!root || memcg_kmem_is_active(memcg))
+				freed += shrink_slab_one(shrinker, shrinkctl,
+						 nr_pages_scanned, lru_pages);
+			memcg = mem_cgroup_iter(root, memcg, NULL);
+		} while (memcg);
 	}
+
+	/* restore original state */
+	shrinkctl->target_mem_cgroup = root;
 	up_read(&shrinker_rwsem);
 out:
 	cond_resched();
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
