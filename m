Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1D51C6B0036
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 04:22:34 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id v10so9714678pde.12
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 01:22:33 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id g6si26094345pat.154.2014.07.01.01.22.32
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 01:22:33 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 3/9] slab: defer slab_destroy in free_block()
Date: Tue,  1 Jul 2014 17:27:32 +0900
Message-Id: <1404203258-8923-4-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In free_block(), if freeing object makes new free slab and number of
free_objects exceeds free_limit, we start to destroy this new free slab
with holding the kmem_cache node lock. Holding the lock is useless and,
generally, holding a lock as least as possible is good thing. I never
measure performance effect of this, but we'd be better not to hold the lock
as much as possible.

Commented by Christoph:
  This is also good because kmem_cache_free is no longer called while
  holding the node lock. So we avoid one case of recursion.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |   63 +++++++++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 43 insertions(+), 20 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 19e2136..59b9a4c 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -242,7 +242,8 @@ static struct kmem_cache_node __initdata init_kmem_cache_node[NUM_INIT_LISTS];
 static int drain_freelist(struct kmem_cache *cache,
 			struct kmem_cache_node *n, int tofree);
 static void free_block(struct kmem_cache *cachep, void **objpp, int len,
-			int node);
+			int node, struct list_head *list);
+static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list);
 static int enable_cpucache(struct kmem_cache *cachep, gfp_t gfp);
 static void cache_reap(struct work_struct *unused);
 
@@ -1030,6 +1031,7 @@ static void __drain_alien_cache(struct kmem_cache *cachep,
 				struct array_cache *ac, int node)
 {
 	struct kmem_cache_node *n = get_node(cachep, node);
+	LIST_HEAD(list);
 
 	if (ac->avail) {
 		spin_lock(&n->list_lock);
@@ -1041,9 +1043,10 @@ static void __drain_alien_cache(struct kmem_cache *cachep,
 		if (n->shared)
 			transfer_objects(n->shared, ac, ac->limit);
 
-		free_block(cachep, ac->entry, ac->avail, node);
+		free_block(cachep, ac->entry, ac->avail, node, &list);
 		ac->avail = 0;
 		spin_unlock(&n->list_lock);
+		slabs_destroy(cachep, &list);
 	}
 }
 
@@ -1087,6 +1090,7 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 	struct kmem_cache_node *n;
 	struct array_cache *alien = NULL;
 	int node;
+	LIST_HEAD(list);
 
 	node = numa_mem_id();
 
@@ -1111,8 +1115,9 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 	} else {
 		n = get_node(cachep, nodeid);
 		spin_lock(&n->list_lock);
-		free_block(cachep, &objp, 1, nodeid);
+		free_block(cachep, &objp, 1, nodeid, &list);
 		spin_unlock(&n->list_lock);
+		slabs_destroy(cachep, &list);
 	}
 	return 1;
 }
@@ -1184,6 +1189,7 @@ static void cpuup_canceled(long cpu)
 		struct array_cache *nc;
 		struct array_cache *shared;
 		struct array_cache **alien;
+		LIST_HEAD(list);
 
 		/* cpu is dead; no one can alloc from it. */
 		nc = cachep->array[cpu];
@@ -1199,7 +1205,7 @@ static void cpuup_canceled(long cpu)
 		if (!memcg_cache_dead(cachep))
 			n->free_limit -= cachep->batchcount;
 		if (nc)
-			free_block(cachep, nc->entry, nc->avail, node);
+			free_block(cachep, nc->entry, nc->avail, node, &list);
 
 		if (!cpumask_empty(mask)) {
 			spin_unlock_irq(&n->list_lock);
@@ -1209,7 +1215,7 @@ static void cpuup_canceled(long cpu)
 		shared = n->shared;
 		if (shared) {
 			free_block(cachep, shared->entry,
-				   shared->avail, node);
+				   shared->avail, node, &list);
 			n->shared = NULL;
 		}
 
@@ -1224,6 +1230,7 @@ static void cpuup_canceled(long cpu)
 			free_alien_cache(alien);
 		}
 free_array_cache:
+		slabs_destroy(cachep, &list);
 		kfree(nc);
 	}
 	/*
@@ -2062,6 +2069,16 @@ static void slab_destroy(struct kmem_cache *cachep, struct page *page)
 		kmem_cache_free(cachep->freelist_cache, freelist);
 }
 
+static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list)
+{
+	struct page *page, *n;
+
+	list_for_each_entry_safe(page, n, list, lru) {
+		list_del(&page->lru);
+		slab_destroy(cachep, page);
+	}
+}
+
 /**
  * calculate_slab_order - calculate size (page order) of slabs
  * @cachep: pointer to the cache that is being created
@@ -2465,6 +2482,7 @@ static void do_drain(void *arg)
 	struct array_cache *ac;
 	int node = numa_mem_id();
 	struct kmem_cache_node *n;
+	LIST_HEAD(list);
 
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
@@ -2473,8 +2491,9 @@ static void do_drain(void *arg)
 
 	n = get_node(cachep, node);
 	spin_lock(&n->list_lock);
-	free_block(cachep, ac->entry, ac->avail, node);
+	free_block(cachep, ac->entry, ac->avail, node, &list);
 	spin_unlock(&n->list_lock);
+	slabs_destroy(cachep, &list);
 	ac->avail = 0;
 	if (memcg_cache_dead(cachep)) {
 		cachep->array[smp_processor_id()] = NULL;
@@ -3413,8 +3432,8 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 /*
  * Caller needs to acquire correct kmem_cache_node's list_lock
  */
-static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
-		       int node)
+static void free_block(struct kmem_cache *cachep, void **objpp,
+			int nr_objects, int node, struct list_head *list)
 {
 	int i;
 	struct kmem_cache_node *n = get_node(cachep, node);
@@ -3437,13 +3456,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
 		if (page->active == 0) {
 			if (n->free_objects > n->free_limit) {
 				n->free_objects -= cachep->num;
-				/* No need to drop any previously held
-				 * lock here, even if we have a off-slab slab
-				 * descriptor it is guaranteed to come from
-				 * a different cache, refer to comments before
-				 * alloc_slabmgmt.
-				 */
-				slab_destroy(cachep, page);
+				list_add_tail(&page->lru, list);
 			} else {
 				list_add(&page->lru, &n->slabs_free);
 			}
@@ -3462,6 +3475,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 	int batchcount;
 	struct kmem_cache_node *n;
 	int node = numa_mem_id();
+	LIST_HEAD(list);
 
 	batchcount = ac->batchcount;
 #if DEBUG
@@ -3483,7 +3497,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 		}
 	}
 
-	free_block(cachep, ac->entry, batchcount, node);
+	free_block(cachep, ac->entry, batchcount, node, &list);
 free_done:
 #if STATS
 	{
@@ -3504,6 +3518,7 @@ free_done:
 	}
 #endif
 	spin_unlock(&n->list_lock);
+	slabs_destroy(cachep, &list);
 	ac->avail -= batchcount;
 	memmove(ac->entry, &(ac->entry[batchcount]), sizeof(void *)*ac->avail);
 }
@@ -3531,11 +3546,13 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 
 #ifdef CONFIG_MEMCG_KMEM
 	if (unlikely(!ac)) {
+		LIST_HEAD(list);
 		int nodeid = page_to_nid(virt_to_page(objp));
 
 		spin_lock(&cachep->node[nodeid]->list_lock);
-		free_block(cachep, &objp, 1, nodeid);
+		free_block(cachep, &objp, 1, nodeid, &list);
 		spin_unlock(&cachep->node[nodeid]->list_lock);
+		slabs_destroy(cachep, &list);
 		return;
 	}
 #endif
@@ -3801,12 +3818,13 @@ static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
 		n = get_node(cachep, node);
 		if (n) {
 			struct array_cache *shared = n->shared;
+			LIST_HEAD(list);
 
 			spin_lock_irq(&n->list_lock);
 
 			if (shared)
 				free_block(cachep, shared->entry,
-						shared->avail, node);
+						shared->avail, node, &list);
 
 			n->shared = new_shared;
 			if (!n->alien) {
@@ -3816,6 +3834,7 @@ static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
 			n->free_limit = (1 + nr_cpus_node(node)) *
 					cachep->batchcount + cachep->num;
 			spin_unlock_irq(&n->list_lock);
+			slabs_destroy(cachep, &list);
 			kfree(shared);
 			free_alien_cache(new_alien);
 			continue;
@@ -3908,6 +3927,7 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 	cachep->shared = shared;
 
 	for_each_online_cpu(i) {
+		LIST_HEAD(list);
 		struct array_cache *ccold = new->new[i];
 		int node;
 		struct kmem_cache_node *n;
@@ -3918,8 +3938,9 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 		node = cpu_to_mem(i);
 		n = get_node(cachep, node);
 		spin_lock_irq(&n->list_lock);
-		free_block(cachep, ccold->entry, ccold->avail, node);
+		free_block(cachep, ccold->entry, ccold->avail, node, &list);
 		spin_unlock_irq(&n->list_lock);
+		slabs_destroy(cachep, &list);
 		kfree(ccold);
 	}
 	kfree(new);
@@ -4027,6 +4048,7 @@ skip_setup:
 static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
 			 struct array_cache *ac, int force, int node)
 {
+	LIST_HEAD(list);
 	int tofree;
 
 	if (!ac || !ac->avail)
@@ -4039,12 +4061,13 @@ static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
 			tofree = force ? ac->avail : (ac->limit + 4) / 5;
 			if (tofree > ac->avail)
 				tofree = (ac->avail + 1) / 2;
-			free_block(cachep, ac->entry, tofree, node);
+			free_block(cachep, ac->entry, tofree, node, &list);
 			ac->avail -= tofree;
 			memmove(ac->entry, &(ac->entry[tofree]),
 				sizeof(void *) * ac->avail);
 		}
 		spin_unlock_irq(&n->list_lock);
+		slabs_destroy(cachep, &list);
 	}
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
