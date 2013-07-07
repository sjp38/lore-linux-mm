Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 1D04B6B005A
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 11:57:27 -0400 (EDT)
Received: by mail-lb0-f173.google.com with SMTP id v1so3106951lbd.32
        for <linux-mm@kvack.org>; Sun, 07 Jul 2013 08:57:25 -0700 (PDT)
From: Glauber Costa <glommer@gmail.com>
Subject: [PATCH v10 10/16] memcg: scan cache objects hierarchically
Date: Sun,  7 Jul 2013 11:56:50 -0400
Message-Id: <1373212616-11713-11-git-send-email-glommer@openvz.org>
In-Reply-To: <1373212616-11713-1-git-send-email-glommer@openvz.org>
References: <1373212616-11713-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, akpm@linux-foundation.org, Glauber Costa <glommer@openvz.org>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>

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
 include/linux/memcontrol.h |  6 +++++
 mm/memcontrol.c            | 13 ++++++++++
 mm/vmscan.c                | 65 ++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 73 insertions(+), 11 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index a8c5493..dcf21ca 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -440,6 +440,7 @@ static inline bool memcg_kmem_enabled(void)
 	return static_key_false(&memcg_kmem_enabled_key);
 }
 
+bool memcg_kmem_should_reclaim(struct mem_cgroup *memcg);
 bool memcg_kmem_is_active(struct mem_cgroup *memcg);
 
 /*
@@ -583,6 +584,11 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
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
index 1f13480..cce8a22 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2976,6 +2976,19 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
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
index 74653ed..f1ff892 100644
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
@@ -340,12 +340,35 @@ shrink_slab_node(struct shrink_control *shrinkctl, struct shrinker *shrinker,
  *
  * Returns the number of slab objects which we shrunk.
  */
+static unsigned long
+shrink_slab_one(struct shrink_control *shrinkctl, struct shrinker *shrinker,
+		unsigned long nr_pages_scanned, unsigned long lru_pages)
+{
+	unsigned long freed = 0;
+
+	for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
+		if (!node_online(shrinkctl->nid))
+			continue;
+
+		if (!(shrinker->flags & SHRINKER_NUMA_AWARE) &&
+		    (shrinkctl->nid != 0))
+			break;
+
+		freed += shrink_slab_node(shrinkctl, shrinker,
+			 nr_pages_scanned, lru_pages);
+
+	}
+
+	return freed;
+}
+
 unsigned long shrink_slab(struct shrink_control *shrinkctl,
 			  unsigned long nr_pages_scanned,
 			  unsigned long lru_pages)
 {
 	struct shrinker *shrinker;
 	unsigned long freed = 0;
+	struct mem_cgroup *root = shrinkctl->target_mem_cgroup;
 
 	if (nr_pages_scanned == 0)
 		nr_pages_scanned = SWAP_CLUSTER_MAX;
@@ -370,19 +393,39 @@ unsigned long shrink_slab(struct shrink_control *shrinkctl,
 		if (shrinkctl->target_mem_cgroup &&
 		    !(shrinker->flags & SHRINKER_MEMCG_AWARE))
 			continue;
+		/*
+		 * In a hierarchical chain, it might be that not all memcgs are
+		 * kmem active. kmemcg design mandates that when one memcg is
+		 * active, its children will be active as well. But it is
+		 * perfectly possible that its parent is not.
+		 *
+		 * We also need to make sure we scan at least once, for the
+		 * global case. So if we don't have a target memcg (saved in
+		 * root), we proceed normally and expect to break in the next
+		 * round.
+		 */
+		do {
+			struct mem_cgroup *memcg = shrinkctl->target_mem_cgroup;
 
-		for_each_node_mask(shrinkctl->nid, shrinkctl->nodes_to_scan) {
-			if (!node_online(shrinkctl->nid))
-				continue;
-
-			if (!(shrinker->flags & SHRINKER_NUMA_AWARE) &&
-			    (shrinkctl->nid != 0))
+			if (!memcg || memcg_kmem_is_active(memcg))
+				freed += shrink_slab_one(shrinkctl, shrinker,
+					 nr_pages_scanned, lru_pages);
+			/*
+			 * For non-memcg aware shrinkers, we will arrive here
+			 * at first pass because we need to scan the root
+			 * memcg.  We need to bail out, since exactly because
+			 * they are not memcg aware, instead of noticing they
+			 * have nothing to shrink, they will just shrink again,
+			 * and deplete too many objects.
+			 */
+			if (!(shrinker->flags & SHRINKER_MEMCG_AWARE))
 				break;
+			shrinkctl->target_mem_cgroup =
+				mem_cgroup_iter(root, memcg, NULL);
+		} while (shrinkctl->target_mem_cgroup);
 
-			freed += shrink_slab_node(shrinkctl, shrinker,
-				 nr_pages_scanned, lru_pages);
-
-		}
+		/* restore original state */
+		shrinkctl->target_mem_cgroup = root;
 	}
 	up_read(&shrinker_rwsem);
 out:
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
