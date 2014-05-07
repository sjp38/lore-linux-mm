Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id AD94C6B0055
	for <linux-mm@kvack.org>; Wed,  7 May 2014 02:04:41 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so615435pdi.30
        for <linux-mm@kvack.org>; Tue, 06 May 2014 23:04:41 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id pq7si13169155pac.399.2014.05.06.23.04.39
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 23:04:40 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 09/10] slab: remove a useless lockdep annotation
Date: Wed,  7 May 2014 15:06:19 +0900
Message-Id: <1399442780-28748-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, there is no code to hold two lock simultaneously, since
we don't call slab_destroy() with holding any lock. So, lockdep
annotation is useless now. Remove it.

v2: don't remove BAD_ALIEN_MAGIC in this patch. It will be removed
    in the following patch.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 3bb5e11..4030a89 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -439,141 +439,6 @@ static struct kmem_cache kmem_cache_boot = {
 
 #define BAD_ALIEN_MAGIC 0x01020304ul
 
-#ifdef CONFIG_LOCKDEP
-
-/*
- * Slab sometimes uses the kmalloc slabs to store the slab headers
- * for other slabs "off slab".
- * The locking for this is tricky in that it nests within the locks
- * of all other slabs in a few places; to deal with this special
- * locking we put on-slab caches into a separate lock-class.
- *
- * We set lock class for alien array caches which are up during init.
- * The lock annotation will be lost if all cpus of a node goes down and
- * then comes back up during hotplug
- */
-static struct lock_class_key on_slab_l3_key;
-static struct lock_class_key on_slab_alc_key;
-
-static struct lock_class_key debugobj_l3_key;
-static struct lock_class_key debugobj_alc_key;
-
-static void slab_set_lock_classes(struct kmem_cache *cachep,
-		struct lock_class_key *l3_key, struct lock_class_key *alc_key,
-		int q)
-{
-	struct alien_cache **alc;
-	struct kmem_cache_node *n;
-	int r;
-
-	n = cachep->node[q];
-	if (!n)
-		return;
-
-	lockdep_set_class(&n->list_lock, l3_key);
-	alc = n->alien;
-	/*
-	 * FIXME: This check for BAD_ALIEN_MAGIC
-	 * should go away when common slab code is taught to
-	 * work even without alien caches.
-	 * Currently, non NUMA code returns BAD_ALIEN_MAGIC
-	 * for alloc_alien_cache,
-	 */
-	if (!alc || (unsigned long)alc == BAD_ALIEN_MAGIC)
-		return;
-	for_each_node(r) {
-		if (alc[r])
-			lockdep_set_class(&(alc[r]->lock), alc_key);
-	}
-}
-
-static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep, int node)
-{
-	slab_set_lock_classes(cachep, &debugobj_l3_key, &debugobj_alc_key, node);
-}
-
-static void slab_set_debugobj_lock_classes(struct kmem_cache *cachep)
-{
-	int node;
-
-	for_each_online_node(node)
-		slab_set_debugobj_lock_classes_node(cachep, node);
-}
-
-static void init_node_lock_keys(int q)
-{
-	int i;
-
-	if (slab_state < UP)
-		return;
-
-	for (i = 1; i <= KMALLOC_SHIFT_HIGH; i++) {
-		struct kmem_cache_node *n;
-		struct kmem_cache *cache = kmalloc_caches[i];
-
-		if (!cache)
-			continue;
-
-		n = cache->node[q];
-		if (!n || OFF_SLAB(cache))
-			continue;
-
-		slab_set_lock_classes(cache, &on_slab_l3_key,
-				&on_slab_alc_key, q);
-	}
-}
-
-static void on_slab_lock_classes_node(struct kmem_cache *cachep, int q)
-{
-	if (!cachep->node[q])
-		return;
-
-	slab_set_lock_classes(cachep, &on_slab_l3_key,
-			&on_slab_alc_key, q);
-}
-
-static inline void on_slab_lock_classes(struct kmem_cache *cachep)
-{
-	int node;
-
-	VM_BUG_ON(OFF_SLAB(cachep));
-	for_each_node(node)
-		on_slab_lock_classes_node(cachep, node);
-}
-
-static inline void init_lock_keys(void)
-{
-	int node;
-
-	for_each_node(node)
-		init_node_lock_keys(node);
-}
-#else
-static void init_node_lock_keys(int q)
-{
-}
-
-static inline void init_lock_keys(void)
-{
-}
-
-static inline void on_slab_lock_classes(struct kmem_cache *cachep)
-{
-}
-
-static inline void on_slab_lock_classes_node(struct kmem_cache *cachep, int node)
-{
-}
-
-static void slab_set_debugobj_lock_classes_node(struct kmem_cache *cachep, int node)
-{
-}
-
-static void slab_set_debugobj_lock_classes(struct kmem_cache *cachep)
-{
-}
-#endif
-
 static DEFINE_PER_CPU(struct delayed_work, slab_reap_work);
 
 static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
@@ -1293,13 +1158,7 @@ static int cpuup_prepare(long cpu)
 		spin_unlock_irq(&n->list_lock);
 		kfree(shared);
 		free_alien_cache(alien);
-		if (cachep->flags & SLAB_DEBUG_OBJECTS)
-			slab_set_debugobj_lock_classes_node(cachep, node);
-		else if (!OFF_SLAB(cachep) &&
-			 !(cachep->flags & SLAB_DESTROY_BY_RCU))
-			on_slab_lock_classes_node(cachep, node);
 	}
-	init_node_lock_keys(node);
 
 	return 0;
 bad:
@@ -1608,9 +1467,6 @@ void __init kmem_cache_init_late(void)
 			BUG();
 	mutex_unlock(&slab_mutex);
 
-	/* Annotate slab for lockdep -- annotate the malloc caches */
-	init_lock_keys();
-
 	/* Done! */
 	slab_state = FULL;
 
@@ -2386,17 +2242,6 @@ __kmem_cache_create (struct kmem_cache *cachep, unsigned long flags)
 		return err;
 	}
 
-	if (flags & SLAB_DEBUG_OBJECTS) {
-		/*
-		 * Would deadlock through slab_destroy()->call_rcu()->
-		 * debug_object_activate()->kmem_cache_alloc().
-		 */
-		WARN_ON_ONCE(flags & SLAB_DESTROY_BY_RCU);
-
-		slab_set_debugobj_lock_classes(cachep);
-	} else if (!OFF_SLAB(cachep) && !(flags & SLAB_DESTROY_BY_RCU))
-		on_slab_lock_classes(cachep);
-
 	return 0;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
