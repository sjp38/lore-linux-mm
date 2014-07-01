Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id E29586B003D
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 04:22:34 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so10087978pab.8
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 01:22:34 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id xx7si26157527pac.35.2014.07.01.01.22.32
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 01:22:33 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 5/9] slab: introduce alien_cache
Date: Tue,  1 Jul 2014 17:27:34 +0900
Message-Id: <1404203258-8923-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1404203258-8923-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Currently, we use array_cache for alien_cache. Although they are mostly
similar, there is one difference, that is, need for spinlock.
We don't need spinlock for array_cache itself, but to use array_cache for
alien_cache, array_cache structure should have spinlock. This is needless
overhead, so removing it would be better. This patch prepare it by
introducing alien_cache and using it. In the following patch,
we remove spinlock in array_cache.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |  108 ++++++++++++++++++++++++++++++++++++++-----------------------
 mm/slab.h |    2 +-
 2 files changed, 68 insertions(+), 42 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 00b6bbc..e1a473d 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -203,6 +203,11 @@ struct array_cache {
 			 */
 };
 
+struct alien_cache {
+	spinlock_t lock;
+	struct array_cache ac;
+};
+
 #define SLAB_OBJ_PFMEMALLOC	1
 static inline bool is_obj_pfmemalloc(void *objp)
 {
@@ -491,7 +496,7 @@ static void slab_set_lock_classes(struct kmem_cache *cachep,
 		struct lock_class_key *l3_key, struct lock_class_key *alc_key,
 		struct kmem_cache_node *n)
 {
-	struct array_cache **alc;
+	struct alien_cache **alc;
 	int r;
 
 	lockdep_set_class(&n->list_lock, l3_key);
@@ -507,7 +512,7 @@ static void slab_set_lock_classes(struct kmem_cache *cachep,
 		return;
 	for_each_node(r) {
 		if (alc[r])
-			lockdep_set_class(&alc[r]->lock, alc_key);
+			lockdep_set_class(&(alc[r]->ac.lock), alc_key);
 	}
 }
 
@@ -965,12 +970,13 @@ static int transfer_objects(struct array_cache *to,
 #define drain_alien_cache(cachep, alien) do { } while (0)
 #define reap_alien(cachep, n) do { } while (0)
 
-static inline struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
+static inline struct alien_cache **alloc_alien_cache(int node,
+						int limit, gfp_t gfp)
 {
-	return (struct array_cache **)BAD_ALIEN_MAGIC;
+	return (struct alien_cache **)BAD_ALIEN_MAGIC;
 }
 
-static inline void free_alien_cache(struct array_cache **ac_ptr)
+static inline void free_alien_cache(struct alien_cache **ac_ptr)
 {
 }
 
@@ -996,40 +1002,52 @@ static inline void *____cache_alloc_node(struct kmem_cache *cachep,
 static void *____cache_alloc_node(struct kmem_cache *, gfp_t, int);
 static void *alternate_node_alloc(struct kmem_cache *, gfp_t);
 
-static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
+static struct alien_cache *__alloc_alien_cache(int node, int entries,
+						int batch, gfp_t gfp)
+{
+	int memsize = sizeof(void *) * entries + sizeof(struct alien_cache);
+	struct alien_cache *alc = NULL;
+
+	alc = kmalloc_node(memsize, gfp, node);
+	init_arraycache(&alc->ac, entries, batch);
+	return alc;
+}
+
+static struct alien_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
 {
-	struct array_cache **ac_ptr;
+	struct alien_cache **alc_ptr;
 	int memsize = sizeof(void *) * nr_node_ids;
 	int i;
 
 	if (limit > 1)
 		limit = 12;
-	ac_ptr = kzalloc_node(memsize, gfp, node);
-	if (ac_ptr) {
-		for_each_node(i) {
-			if (i == node || !node_online(i))
-				continue;
-			ac_ptr[i] = alloc_arraycache(node, limit, 0xbaadf00d, gfp);
-			if (!ac_ptr[i]) {
-				for (i--; i >= 0; i--)
-					kfree(ac_ptr[i]);
-				kfree(ac_ptr);
-				return NULL;
-			}
+	alc_ptr = kzalloc_node(memsize, gfp, node);
+	if (!alc_ptr)
+		return NULL;
+
+	for_each_node(i) {
+		if (i == node || !node_online(i))
+			continue;
+		alc_ptr[i] = __alloc_alien_cache(node, limit, 0xbaadf00d, gfp);
+		if (!alc_ptr[i]) {
+			for (i--; i >= 0; i--)
+				kfree(alc_ptr[i]);
+			kfree(alc_ptr);
+			return NULL;
 		}
 	}
-	return ac_ptr;
+	return alc_ptr;
 }
 
-static void free_alien_cache(struct array_cache **ac_ptr)
+static void free_alien_cache(struct alien_cache **alc_ptr)
 {
 	int i;
 
-	if (!ac_ptr)
+	if (!alc_ptr)
 		return;
 	for_each_node(i)
-	    kfree(ac_ptr[i]);
-	kfree(ac_ptr);
+	    kfree(alc_ptr[i]);
+	kfree(alc_ptr);
 }
 
 static void __drain_alien_cache(struct kmem_cache *cachep,
@@ -1063,25 +1081,31 @@ static void reap_alien(struct kmem_cache *cachep, struct kmem_cache_node *n)
 	int node = __this_cpu_read(slab_reap_node);
 
 	if (n->alien) {
-		struct array_cache *ac = n->alien[node];
-
-		if (ac && ac->avail && spin_trylock_irq(&ac->lock)) {
-			__drain_alien_cache(cachep, ac, node);
-			spin_unlock_irq(&ac->lock);
+		struct alien_cache *alc = n->alien[node];
+		struct array_cache *ac;
+
+		if (alc) {
+			ac = &alc->ac;
+			if (ac->avail && spin_trylock_irq(&ac->lock)) {
+				__drain_alien_cache(cachep, ac, node);
+				spin_unlock_irq(&ac->lock);
+			}
 		}
 	}
 }
 
 static void drain_alien_cache(struct kmem_cache *cachep,
-				struct array_cache **alien)
+				struct alien_cache **alien)
 {
 	int i = 0;
+	struct alien_cache *alc;
 	struct array_cache *ac;
 	unsigned long flags;
 
 	for_each_online_node(i) {
-		ac = alien[i];
-		if (ac) {
+		alc = alien[i];
+		if (alc) {
+			ac = &alc->ac;
 			spin_lock_irqsave(&ac->lock, flags);
 			__drain_alien_cache(cachep, ac, i);
 			spin_unlock_irqrestore(&ac->lock, flags);
@@ -1093,7 +1117,8 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 {
 	int nodeid = page_to_nid(virt_to_page(objp));
 	struct kmem_cache_node *n;
-	struct array_cache *alien = NULL;
+	struct alien_cache *alien = NULL;
+	struct array_cache *ac;
 	int node;
 	LIST_HEAD(list);
 
@@ -1110,13 +1135,14 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 	STATS_INC_NODEFREES(cachep);
 	if (n->alien && n->alien[nodeid]) {
 		alien = n->alien[nodeid];
-		spin_lock(&alien->lock);
-		if (unlikely(alien->avail == alien->limit)) {
+		ac = &alien->ac;
+		spin_lock(&ac->lock);
+		if (unlikely(ac->avail == ac->limit)) {
 			STATS_INC_ACOVERFLOW(cachep);
-			__drain_alien_cache(cachep, alien, nodeid);
+			__drain_alien_cache(cachep, ac, nodeid);
 		}
-		ac_put_obj(cachep, alien, objp);
-		spin_unlock(&alien->lock);
+		ac_put_obj(cachep, ac, objp);
+		spin_unlock(&ac->lock);
 	} else {
 		n = get_node(cachep, nodeid);
 		spin_lock(&n->list_lock);
@@ -1193,7 +1219,7 @@ static void cpuup_canceled(long cpu)
 	list_for_each_entry(cachep, &slab_caches, list) {
 		struct array_cache *nc;
 		struct array_cache *shared;
-		struct array_cache **alien;
+		struct alien_cache **alien;
 		LIST_HEAD(list);
 
 		/* cpu is dead; no one can alloc from it. */
@@ -1275,7 +1301,7 @@ static int cpuup_prepare(long cpu)
 	list_for_each_entry(cachep, &slab_caches, list) {
 		struct array_cache *nc;
 		struct array_cache *shared = NULL;
-		struct array_cache **alien = NULL;
+		struct alien_cache **alien = NULL;
 
 		if (memcg_cache_dead(cachep))
 			continue;
@@ -3799,7 +3825,7 @@ static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
 	int node;
 	struct kmem_cache_node *n;
 	struct array_cache *new_shared;
-	struct array_cache **new_alien = NULL;
+	struct alien_cache **new_alien = NULL;
 
 	for_each_online_node(node) {
 
diff --git a/mm/slab.h b/mm/slab.h
index 4789ca4..84c160a 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -301,7 +301,7 @@ struct kmem_cache_node {
 	unsigned int free_limit;
 	unsigned int colour_next;	/* Per-node cache coloring */
 	struct array_cache *shared;	/* shared per node */
-	struct array_cache **alien;	/* on other nodes */
+	struct alien_cache **alien;	/* on other nodes */
 	unsigned long next_reap;	/* updated without locking */
 	int free_touched;		/* updated without locking */
 #endif
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
