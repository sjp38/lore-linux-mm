Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7E3C56B0036
	for <linux-mm@kvack.org>; Wed,  7 May 2014 02:04:40 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so603311pdj.6
        for <linux-mm@kvack.org>; Tue, 06 May 2014 23:04:40 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id xt2si1278560pbb.154.2014.05.06.23.04.37
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 23:04:38 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 04/10] slab: defer slab_destroy in free_block()
Date: Wed,  7 May 2014 15:06:14 +0900
Message-Id: <1399442780-28748-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

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

diff --git a/mm/slab.c b/mm/slab.c
index 92d08e3..7647728 100644
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
 
@@ -976,6 +977,7 @@ static void free_alien_cache(struct array_cache **ac_ptr)
 static void __drain_alien_cache(struct kmem_cache *cachep,
 				struct array_cache *ac, int node)
 {
+	LIST_HEAD(list);
 	struct kmem_cache_node *n = cachep->node[node];
 
 	if (ac->avail) {
@@ -988,9 +990,10 @@ static void __drain_alien_cache(struct kmem_cache *cachep,
 		if (n->shared)
 			transfer_objects(n->shared, ac, ac->limit);
 
-		free_block(cachep, ac->entry, ac->avail, node);
+		free_block(cachep, ac->entry, ac->avail, node, &list);
 		ac->avail = 0;
 		spin_unlock(&n->list_lock);
+		slabs_destroy(cachep, &list);
 	}
 }
 
@@ -1034,6 +1037,7 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 	struct kmem_cache_node *n;
 	struct array_cache *alien = NULL;
 	int node;
+	LIST_HEAD(list);
 
 	node = numa_mem_id();
 
@@ -1057,8 +1061,9 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
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
@@ -1127,6 +1132,7 @@ static void cpuup_canceled(long cpu)
 		struct array_cache *nc;
 		struct array_cache *shared;
 		struct array_cache **alien;
+		LIST_HEAD(list);
 
 		/* cpu is dead; no one can alloc from it. */
 		nc = cachep->array[cpu];
@@ -1141,7 +1147,7 @@ static void cpuup_canceled(long cpu)
 		/* Free limit for this kmem_cache_node */
 		n->free_limit -= cachep->batchcount;
 		if (nc)
-			free_block(cachep, nc->entry, nc->avail, node);
+			free_block(cachep, nc->entry, nc->avail, node, &list);
 
 		if (!cpumask_empty(mask)) {
 			spin_unlock_irq(&n->list_lock);
@@ -1151,7 +1157,7 @@ static void cpuup_canceled(long cpu)
 		shared = n->shared;
 		if (shared) {
 			free_block(cachep, shared->entry,
-				   shared->avail, node);
+				   shared->avail, node, &list);
 			n->shared = NULL;
 		}
 
@@ -1159,6 +1165,7 @@ static void cpuup_canceled(long cpu)
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
 
@@ -3336,8 +3354,8 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 /*
  * Caller needs to acquire correct kmem_cache_node's list_lock
  */
-static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
-		       int node)
+static void free_block(struct kmem_cache *cachep, void **objpp,
+			int nr_objects, int node, struct list_head *list)
 {
 	int i;
 	struct kmem_cache_node *n = cachep->node[node];
@@ -3359,13 +3377,7 @@ static void free_block(struct kmem_cache *cachep, void **objpp, int nr_objects,
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
@@ -3384,6 +3396,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 	int batchcount;
 	struct kmem_cache_node *n;
 	int node = numa_mem_id();
+	LIST_HEAD(list);
 
 	batchcount = ac->batchcount;
 #if DEBUG
@@ -3405,7 +3418,7 @@ static void cache_flusharray(struct kmem_cache *cachep, struct array_cache *ac)
 		}
 	}
 
-	free_block(cachep, ac->entry, batchcount, node);
+	free_block(cachep, ac->entry, batchcount, node, &list);
 free_done:
 #if STATS
 	{
@@ -3426,6 +3439,7 @@ free_done:
 	}
 #endif
 	spin_unlock(&n->list_lock);
+	slabs_destroy(cachep, &list);
 	ac->avail -= batchcount;
 	memmove(ac->entry, &(ac->entry[batchcount]), sizeof(void *)*ac->avail);
 }
@@ -3706,12 +3720,13 @@ static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
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
@@ -3721,6 +3736,7 @@ static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
 			n->free_limit = (1 + nr_cpus_node(node)) *
 					cachep->batchcount + cachep->num;
 			spin_unlock_irq(&n->list_lock);
+			slabs_destroy(cachep, &list);
 			kfree(shared);
 			free_alien_cache(new_alien);
 			continue;
@@ -3811,12 +3827,15 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
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
@@ -3924,6 +3943,7 @@ skip_setup:
 static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
 			 struct array_cache *ac, int force, int node)
 {
+	LIST_HEAD(list);
 	int tofree;
 
 	if (!ac || !ac->avail)
@@ -3936,12 +3956,13 @@ static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
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
