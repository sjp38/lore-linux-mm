Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id B88A86B003D
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 09:22:56 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id el20so1539280lab.1
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 06:22:55 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id x1si10752966laa.24.2014.06.06.06.22.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jun 2014 06:22:55 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 8/8] slab: make dead memcg caches discard free slabs immediately
Date: Fri, 6 Jun 2014 17:22:45 +0400
Message-ID: <27a202c6084d6bb19cc3e417793f05104b908ded.1402060096.git.vdavydov@parallels.com>
In-Reply-To: <cover.1402060096.git.vdavydov@parallels.com>
References: <cover.1402060096.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Since a dead memcg cache is destroyed only after the last slab allocated
to it is freed, we must disable caching of empty slabs for such caches,
otherwise they will be hanging around forever.

This patch makes SLAB discard dead memcg caches' slabs as soon as they
become empty. To achieve that, it disables per cpu free object arrays by
setting array_cache->limit to 0 on each cpu and sets per node free_limit
to 0 in order to zap slabs_free lists. This is done on kmem_cache_shrink
(in do_drain, drain_array, drain_alien_cache, and drain_freelist to be
more exact), which is always called on memcg offline (see
memcg_unregister_all_caches)

Note, since array_cache->limit and kmem_cache_node->free_limit are per
cpu/node and, as a result, they may be updated on cpu/node
online/offline, we have to patch every place where the limits are
initialized.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 mm/slab.c |   83 +++++++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 62 insertions(+), 21 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 9ca3b87edabc..80117a13b899 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -740,7 +740,8 @@ static void start_cpu_timer(int cpu)
 	}
 }
 
-static struct array_cache *alloc_arraycache(int node, int entries,
+static struct array_cache *alloc_arraycache(struct kmem_cache *cachep,
+					    int node, int entries,
 					    int batchcount, gfp_t gfp)
 {
 	int memsize = sizeof(void *) * entries + sizeof(struct array_cache);
@@ -757,7 +758,7 @@ static struct array_cache *alloc_arraycache(int node, int entries,
 	kmemleak_no_scan(nc);
 	if (nc) {
 		nc->avail = 0;
-		nc->limit = entries;
+		nc->limit = memcg_cache_dead(cachep) ? 0 : entries;
 		nc->batchcount = batchcount;
 		nc->touched = 0;
 		spin_lock_init(&nc->lock);
@@ -909,7 +910,8 @@ static int transfer_objects(struct array_cache *to,
 #define drain_alien_cache(cachep, alien) do { } while (0)
 #define reap_alien(cachep, n) do { } while (0)
 
-static inline struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
+static inline struct array_cache **
+alloc_alien_cache(struct kmem_cache *cachep, int node, int limit, gfp_t gfp)
 {
 	return (struct array_cache **)BAD_ALIEN_MAGIC;
 }
@@ -940,7 +942,8 @@ static inline void *____cache_alloc_node(struct kmem_cache *cachep,
 static void *____cache_alloc_node(struct kmem_cache *, gfp_t, int);
 static void *alternate_node_alloc(struct kmem_cache *, gfp_t);
 
-static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
+static struct array_cache **alloc_alien_cache(struct kmem_cache *cachep,
+					      int node, int limit, gfp_t gfp)
 {
 	struct array_cache **ac_ptr;
 	int memsize = sizeof(void *) * nr_node_ids;
@@ -953,7 +956,8 @@ static struct array_cache **alloc_alien_cache(int node, int limit, gfp_t gfp)
 		for_each_node(i) {
 			if (i == node || !node_online(i))
 				continue;
-			ac_ptr[i] = alloc_arraycache(node, limit, 0xbaadf00d, gfp);
+			ac_ptr[i] = alloc_arraycache(cachep, node, limit,
+						     0xbaadf00d, gfp);
 			if (!ac_ptr[i]) {
 				for (i--; i >= 0; i--)
 					kfree(ac_ptr[i]);
@@ -1026,6 +1030,8 @@ static void drain_alien_cache(struct kmem_cache *cachep,
 		if (ac) {
 			spin_lock_irqsave(&ac->lock, flags);
 			__drain_alien_cache(cachep, ac, i);
+			if (memcg_cache_dead(cachep))
+				ac->limit = 0;
 			spin_unlock_irqrestore(&ac->lock, flags);
 		}
 	}
@@ -1037,6 +1043,7 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 	struct kmem_cache_node *n;
 	struct array_cache *alien = NULL;
 	int node;
+	bool freed_alien = false;
 
 	node = numa_mem_id();
 
@@ -1053,12 +1060,18 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 		alien = n->alien[nodeid];
 		spin_lock(&alien->lock);
 		if (unlikely(alien->avail == alien->limit)) {
+			if (!alien->limit)
+				goto out;
 			STATS_INC_ACOVERFLOW(cachep);
 			__drain_alien_cache(cachep, alien, nodeid);
 		}
 		ac_put_obj(cachep, alien, objp);
+		freed_alien = true;
+out:
 		spin_unlock(&alien->lock);
-	} else {
+	}
+
+	if (!freed_alien) {
 		spin_lock(&(cachep->node[nodeid])->list_lock);
 		free_block(cachep, &objp, 1, nodeid);
 		spin_unlock(&(cachep->node[nodeid])->list_lock);
@@ -1067,6 +1080,13 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 }
 #endif
 
+static void init_cache_node_free_limit(struct kmem_cache *cachep,
+				       struct kmem_cache_node *n, int node)
+{
+	n->free_limit = memcg_cache_dead(cachep) ? 0 :
+		(1 + nr_cpus_node(node)) * cachep->batchcount + cachep->num;
+}
+
 /*
  * Allocates and initializes node for a node on each slab cache, used for
  * either memory or cpu hotplug.  If memory is being hot-added, the kmem_cache_node
@@ -1105,9 +1125,7 @@ static int init_cache_node_node(int node)
 		}
 
 		spin_lock_irq(&cachep->node[node]->list_lock);
-		cachep->node[node]->free_limit =
-			(1 + nr_cpus_node(node)) *
-			cachep->batchcount + cachep->num;
+		init_cache_node_free_limit(cachep, cachep->node[node], node);
 		spin_unlock_irq(&cachep->node[node]->list_lock);
 	}
 	return 0;
@@ -1142,7 +1160,8 @@ static void cpuup_canceled(long cpu)
 		spin_lock_irq(&n->list_lock);
 
 		/* Free limit for this kmem_cache_node */
-		n->free_limit -= cachep->batchcount;
+		if (n->free_limit >= cachep->batchcount)
+			n->free_limit -= cachep->batchcount;
 		if (nc)
 			free_block(cachep, nc->entry, nc->avail, node);
 
@@ -1210,12 +1229,12 @@ static int cpuup_prepare(long cpu)
 		struct array_cache *shared = NULL;
 		struct array_cache **alien = NULL;
 
-		nc = alloc_arraycache(node, cachep->limit,
+		nc = alloc_arraycache(cachep, node, cachep->limit,
 					cachep->batchcount, GFP_KERNEL);
 		if (!nc)
 			goto bad;
 		if (cachep->shared) {
-			shared = alloc_arraycache(node,
+			shared = alloc_arraycache(cachep, node,
 				cachep->shared * cachep->batchcount,
 				0xbaadf00d, GFP_KERNEL);
 			if (!shared) {
@@ -1224,7 +1243,8 @@ static int cpuup_prepare(long cpu)
 			}
 		}
 		if (use_alien_caches) {
-			alien = alloc_alien_cache(node, cachep->limit, GFP_KERNEL);
+			alien = alloc_alien_cache(cachep, node,
+						  cachep->limit, GFP_KERNEL);
 			if (!alien) {
 				kfree(shared);
 				kfree(nc);
@@ -2415,6 +2435,9 @@ static void do_drain(void *arg)
 	free_block(cachep, ac->entry, ac->avail, node);
 	spin_unlock(&cachep->node[node]->list_lock);
 	ac->avail = 0;
+
+	if (memcg_cache_dead(cachep))
+		ac->limit = 0;
 }
 
 static void drain_cpu_caches(struct kmem_cache *cachep)
@@ -2450,6 +2473,12 @@ static int drain_freelist(struct kmem_cache *cache,
 	int nr_freed;
 	struct page *page;
 
+	if (memcg_cache_dead(cache) && n->free_limit) {
+		spin_lock_irq(&n->list_lock);
+		n->free_limit = 0;
+		spin_unlock_irq(&n->list_lock);
+	}
+
 	nr_freed = 0;
 	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
 
@@ -3468,9 +3497,16 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
 
 	if (likely(ac->avail < ac->limit)) {
 		STATS_INC_FREEHIT(cachep);
-	} else {
+	} else if (ac->limit) {
 		STATS_INC_FREEMISS(cachep);
 		cache_flusharray(cachep, ac);
+	} else {
+		int nodeid = page_to_nid(virt_to_page(objp));
+
+		spin_lock(&(cachep->node[nodeid])->list_lock);
+		free_block(cachep, &objp, 1, nodeid);
+		spin_unlock(&(cachep->node[nodeid])->list_lock);
+		return;
 	}
 
 	ac_put_obj(cachep, ac, objp);
@@ -3698,14 +3734,15 @@ static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
 	for_each_online_node(node) {
 
                 if (use_alien_caches) {
-                        new_alien = alloc_alien_cache(node, cachep->limit, gfp);
+                        new_alien = alloc_alien_cache(cachep, node,
+						      cachep->limit, gfp);
                         if (!new_alien)
                                 goto fail;
                 }
 
 		new_shared = NULL;
 		if (cachep->shared) {
-			new_shared = alloc_arraycache(node,
+			new_shared = alloc_arraycache(cachep, node,
 				cachep->shared*cachep->batchcount,
 					0xbaadf00d, gfp);
 			if (!new_shared) {
@@ -3729,8 +3766,7 @@ static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
 				n->alien = new_alien;
 				new_alien = NULL;
 			}
-			n->free_limit = (1 + nr_cpus_node(node)) *
-					cachep->batchcount + cachep->num;
+			init_cache_node_free_limit(cachep, n, node);
 			spin_unlock_irq(&n->list_lock);
 			kfree(shared);
 			free_alien_cache(new_alien);
@@ -3748,8 +3784,7 @@ static int alloc_kmem_cache_node(struct kmem_cache *cachep, gfp_t gfp)
 				((unsigned long)cachep) % REAPTIMEOUT_NODE;
 		n->shared = new_shared;
 		n->alien = new_alien;
-		n->free_limit = (1 + nr_cpus_node(node)) *
-					cachep->batchcount + cachep->num;
+		init_cache_node_free_limit(cachep, n, node);
 		cachep->node[node] = n;
 	}
 	return 0;
@@ -3803,7 +3838,7 @@ static int __do_tune_cpucache(struct kmem_cache *cachep, int limit,
 		return -ENOMEM;
 
 	for_each_online_cpu(i) {
-		new->new[i] = alloc_arraycache(cpu_to_mem(i), limit,
+		new->new[i] = alloc_arraycache(cachep, cpu_to_mem(i), limit,
 						batchcount, gfp);
 		if (!new->new[i]) {
 			for (i--; i >= 0; i--)
@@ -3937,6 +3972,12 @@ static void drain_array(struct kmem_cache *cachep, struct kmem_cache_node *n,
 {
 	int tofree;
 
+	if (memcg_cache_dead(cachep) && ac && ac->limit) {
+		spin_lock_irq(&n->list_lock);
+		ac->limit = 0;
+		spin_unlock_irq(&n->list_lock);
+	}
+
 	if (!ac || !ac->avail)
 		return;
 	if (ac->touched && !force) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
