Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id A6E176B0038
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:57:28 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa1so11959306pad.28
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:57:28 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id i8si4655249pav.132.2014.02.13.22.57.26
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:57:27 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 4/9] slab: defer slab_destroy in free_block()
Date: Fri, 14 Feb 2014 15:57:18 +0900
Message-Id: <1392361043-22420-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

In free_block(), if freeing object makes new free slab and number of
free_objects exceeds free_limit, we start to destroy this new free slab
with holding the kmem_cache node lock. Holding the lock is useless and,
generally, holding a lock as least as possible is good thing. I never
measure performance effect of this, but we'd be better not to hold the lock
as much as possible.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 53d1a36..551d503 100644
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
 
@@ -979,6 +980,7 @@ static void free_alien_cache(struct array_cache **ac_ptr)
 static void __drain_alien_cache(struct kmem_cache *cachep,
 				struct array_cache *ac, int node)
 {
+	LIST_HEAD(list);
 	struct kmem_cache_node *n = cachep->node[node];
 
 	if (ac->avail) {
@@ -991,9 +993,10 @@ static void __drain_alien_cache(struct kmem_cache *cachep,
 		if (n->shared)
 			transfer_objects(n->shared, ac, ac->limit);
 
-		free_block(cachep, ac->entry, ac->avail, node);
+		free_block(cachep, ac->entry, ac->avail, node, &list);
 		ac->avail = 0;
 		spin_unlock(&n->list_lock);
+		slabs_destroy(cachep, &list);
 	}
 }
 
@@ -1037,6 +1040,7 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 	struct kmem_cache_node *n;
 	struct array_cache *alien = NULL;
 	int node;
+	LIST_HEAD(list);
 
 	node = numa_mem_id();
 
@@ -1060,8 +1064,9 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 		spin_unlock(&alien->lock);
 	} else {
 		spin_lock(&(cachep->node[nodeid])->list_lock);
-		free_block(cachep, &objp, 1, nodeid);
+		free_block(cachep, &objp, 1, nodeid, &list);
 		spin_unlock(&(cachep->node[nodeid])->list_lock);
+		slabs_destroy(cachep, &list);
 	}
 	return 1;
 }
@@ -1130,6 +1135,7 @@ static void cpuup_canceled(long cpu)
 		struct array_cache *nc;
 		struct array_cache *shared;
 		struct array_cache **alien;
+		LIST_HEAD(list);
 
 		/* cpu is dead; no one can alloc from it. */
 		nc = cachep->array[cpu];
@@ -1144,7 +1150,7 @@ static void cpuup_canceled(long cpu)
 		/* Free limit for this kmem_cache_node */
 		n->free_limit -= cachep->batchcount;
 		if (nc)
-			free_block(cachep, nc->entry, nc->avail, node);
+			free_block(cachep, nc->entry, nc->avail, node, &list);
 
 		if (!cpumask_empty(mask)) {
 			spin_unlock_irq(&n->list_lock);
@@ -1154,7 +1160,7 @@ static void cpuup_canceled(long cpu)
 		shared = n->shared;
 		if (shared) {
 			free_block(cachep, shared->entry,
-				   shared->avail, node);
+				   shared->avail, node, &list);
 			n->shared = NULL;
 		}
 
@@ -1162,6 +1168,7 @@ static void cpuup_canceled(long cpu)
 		n->alien = NULL;
 
 		spin_unlock_irq(&n->list_lock);
+		slabs_destroy(cachep, &list);
 
 		kfree(shared);
 		if (alien) {
@@ -1999,6 +2006,15 @@ static void slab_destroy(struct kmem_cache *cachep, struct page *page)
 		kmem_cache_free(cachep->freelist_cache, freelist);
 }
 
+static void slabs_destroy(struct kmem_cache *cachep, struct list_head *list)
+{
+	struct page *page, *n;
+	list_for_each_entry_safe(page, n, list, lru) {
+		list_del(&page->lru);
+		slab_destroy(cachep, page);
+	}
+}
+
 /**
  * calculate_slab_order - calculate size (page order) of slabs
  * @cachep: pointer to the cache that is being created
@@ -2399,12 +2415,14 @@ static void do_drain(void *arg)
 	struct kmem_cache *cachep = arg;
 	struct array_cache *ac;
 	int node = numa_mem_id();
+	LIST_HEAD(list);
 
 	check_irq_off();
 	ac = cpu_cache_get(cachep);
 	spin_lock(&cachep->node[node]->list_lock);
-	free_block(cachep, ac->entry, ac->avail, node);
+	free_block(cachep, ac->entry, ac->avail, node, &list);
 	spin_unlock(&cachep->node[node]->list_lock);
+	slabs_destroy(cachep, &list);
 	ac->avail = 0;
 }
 
@@ -3355,8 +3373,8 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 /*
  * Caller needs to acquire correct kmem_list's list_lock
  */
-static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
-		       int node)
+static void free_block(struct kmem_cache *cachep, void **objpp,
+			int nr_objects, int node, struct list_head *list)
 {
 	int i;
 	struct kmem_cache_node *n;
@@ -3379,13 +3397,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
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
+				list_add(&page->lru, list);
 			} else {
 				list_add(&page->lru, &n->slabs_free);
 			}
@@ -3404,6 +3416,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 	int batchcount;
 	struct kmem_cache_node *n;
 	int node = numa_mem_id();
+	LIST_HEAD(list);
 
 	batchcount = ac->batchcount;
 #if DEBUG
@@ -3425,7 +3438,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 		}
 	}
 
-	free_block(cachep, ac->entry, batchcount, node);
+	free_block(cachep, ac->entry, batchcount, node, &list);
 free_done:
 #if STATS
 	{
@@ -3446,6 +3459,7 @@ free_done:
 	}
 #endif
 	spin_unlock(&n->list_lock);
+	slabs_destroy(cachep, &list);
 	ac->avail -= batchcount;
 	memmove(ac->entry, &(ac->entry[batchcount]), sizeof(void *)*ac->avail);
 }
@@ -3731,12 +3745,13 @@ static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
 		n = cachep->node[node];
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
@@ -3746,6 +3761,7 @@ static int alloc_kmemlist(struct kmem_cache *cachep, gfp_t gfp)
 			n->free_limit = (1 + nr_cpus_node(node)) *
 					cachep->batchcount + cachep->num;
 			spin_unlock_irq(&n->list_lock);
+			slabs_destroy(cachep, &list);
 			kfree(shared);
 			free_alien_cache(new_alien);
 			continue;
@@ -3836,12 +3852,15 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 	cachep->shared = shared;
 
 	for_each_online_cpu(i) {
+		LIST_HEAD(list);
 		struct array_cache *ccold = new->new[i];
 		if (!ccold)
 			continue;
 		spin_lock_irq(&cachep->node[cpu_to_mem(i)]->list_lock);
-		free_block(cachep, ccold->entry, ccold->avail, cpu_to_mem(i));
+		free_block(cachep, ccold->entry, ccold->avail,
+						cpu_to_mem(i), &list);
 		spin_unlock_irq(&cachep->node[cpu_to_mem(i)]->list_lock);
+		slabs_destroy(cachep, &list);
 		kfree(ccold);
 	}
 	kfree(new);
@@ -3949,6 +3968,7 @@ skip_setup:
 static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
 			 struct array_cache *ac, int force, int node)
 {
+	LIST_HEAD(list);
 	int tofree;
 
 	if (!ac || !ac->avail)
@@ -3961,12 +3981,13 @@ static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
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
