Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7F36B0036
	for <linux-mm@kvack.org>; Wed,  7 May 2014 02:04:40 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so673915pab.22
        for <linux-mm@kvack.org>; Tue, 06 May 2014 23:04:40 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ps1si1280408pbc.422.2014.05.06.23.04.38
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 23:04:39 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 07/10] slab: use the lock on alien_cache, instead of the lock on array_cache
Date: Wed,  7 May 2014 15:06:17 +0900
Message-Id: <1399442780-28748-8-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Now, we have separate alien_cache structure, so it'd be better to hold
the lock on alien_cache while manipulating alien_cache. After that,
we don't need the lock on array_cache, so remove it.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 41b7651..889957b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -191,7 +191,6 @@ struct array_cache {
 	unsigned int limit;
 	unsigned int batchcount;
 	unsigned int touched;
-	spinlock_t lock;
 	void *entry[];	/*
 			 * Must have this definition in here for the proper
 			 * alignment of array_cache. Also simplifies accessing
@@ -484,7 +483,7 @@ static void slab_set_lock_classes(struct kmem_cache *cachep,
 		return;
 	for_each_node(r) {
 		if (alc[r])
-			lockdep_set_class(&(alc[r]->ac.lock), alc_key);
+			lockdep_set_class(&(alc[r]->lock), alc_key);
 	}
 }
 
@@ -761,7 +760,6 @@ static void init_arraycache(struct array_cache *ac, int limit, int batch)
 		ac->limit = limit;
 		ac->batchcount = batch;
 		ac->touched = 0;
-		spin_lock_init(&ac->lock);
 	}
 }
 
@@ -957,6 +955,7 @@ static struct alien_cache *__alloc_alien_cache(int node, int entries,
 
 	alc = kmalloc_node(memsize, gfp, node);
 	init_arraycache(&alc->ac, entries, batch);
+	spin_lock_init(&alc->lock);
 	return alc;
 }
 
@@ -1033,9 +1032,9 @@ static void reap_alien(struct kmem_cache *cachep, struct kmem_cache_node *n)
 
 		if (alc) {
 			ac = &alc->ac;
-			if (ac->avail && spin_trylock_irq(&ac->lock)) {
+			if (ac->avail && spin_trylock_irq(&alc->lock)) {
 				__drain_alien_cache(cachep, ac, node);
-				spin_unlock_irq(&ac->lock);
+				spin_unlock_irq(&alc->lock);
 			}
 		}
 	}
@@ -1053,9 +1052,9 @@ static void drain_alien_cache(struct kmem_cache *cachep,
 		alc = alien[i];
 		if (alc) {
 			ac = &alc->ac;
-			spin_lock_irqsave(&ac->lock, flags);
+			spin_lock_irqsave(&alc->lock, flags);
 			__drain_alien_cache(cachep, ac, i);
-			spin_unlock_irqrestore(&ac->lock, flags);
+			spin_unlock_irqrestore(&alc->lock, flags);
 		}
 	}
 }
@@ -1083,13 +1082,13 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 	if (n->alien && n->alien[nodeid]) {
 		alien = n->alien[nodeid];
 		ac = &alien->ac;
-		spin_lock(&ac->lock);
+		spin_lock(&alien->lock);
 		if (unlikely(ac->avail == ac->limit)) {
 			STATS_INC_ACOVERFLOW(cachep);
 			__drain_alien_cache(cachep, ac, nodeid);
 		}
 		ac_put_obj(cachep, ac, objp);
-		spin_unlock(&ac->lock);
+		spin_unlock(&alien->lock);
 	} else {
 		spin_lock(&(cachep->node[nodeid])->list_lock);
 		free_block(cachep, &objp, 1, nodeid, &list);
@@ -1558,10 +1557,6 @@ void __init kmem_cache_init(void)
 
 		memcpy(ptr, cpu_cache_get(kmem_cache),
 		       sizeof(struct arraycache_init));
-		/*
-		 * Do not assume that spinlocks can be initialized via memcpy:
-		 */
-		spin_lock_init(&ptr->lock);
 
 		kmem_cache->array[smp_processor_id()] = ptr;
 
@@ -1571,10 +1566,6 @@ void __init kmem_cache_init(void)
 		       != &initarray_generic.cache);
 		memcpy(ptr, cpu_cache_get(kmalloc_caches[INDEX_AC]),
 		       sizeof(struct arraycache_init));
-		/*
-		 * Do not assume that spinlocks can be initialized via memcpy:
-		 */
-		spin_lock_init(&ptr->lock);
 
 		kmalloc_caches[INDEX_AC]->array[smp_processor_id()] = ptr;
 	}
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
