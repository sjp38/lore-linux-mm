Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9DE946B0035
	for <linux-mm@kvack.org>; Wed,  7 May 2014 02:04:41 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id ar20so535625iec.5
        for <linux-mm@kvack.org>; Tue, 06 May 2014 23:04:41 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id gd2si1280008pbd.463.2014.05.06.23.04.39
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 23:04:40 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 08/10] slab: destroy a slab without holding any alien cache lock
Date: Wed,  7 May 2014 15:06:18 +0900
Message-Id: <1399442780-28748-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

I haven't heard that this alien cache lock is contended, but to reduce
chance of contention would be better generally. And with this change,
we can simplify complex lockdep annotation in slab code.
In the following patch, it will be implemented.

Acked-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 889957b..3bb5e11 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -997,9 +997,9 @@ static void free_alien_cache(struct alien_cache **alc_ptr)
 }
 
 static void __drain_alien_cache(struct kmem_cache *cachep,
-				struct array_cache *ac, int node)
+				struct array_cache *ac, int node,
+				struct list_head *list)
 {
-	LIST_HEAD(list);
 	struct kmem_cache_node *n = cachep->node[node];
 
 	if (ac->avail) {
@@ -1012,10 +1012,9 @@ static void __drain_alien_cache(struct kmem_cache *cachep,
 		if (n->shared)
 			transfer_objects(n->shared, ac, ac->limit);
 
-		free_block(cachep, ac->entry, ac->avail, node, &list);
+		free_block(cachep, ac->entry, ac->avail, node, list);
 		ac->avail = 0;
 		spin_unlock(&n->list_lock);
-		slabs_destroy(cachep, &list);
 	}
 }
 
@@ -1033,8 +1032,11 @@ static void reap_alien(struct kmem_cache *cachep, struct kmem_cache_node *n)
 		if (alc) {
 			ac = &alc->ac;
 			if (ac->avail && spin_trylock_irq(&alc->lock)) {
-				__drain_alien_cache(cachep, ac, node);
+				LIST_HEAD(list);
+
+				__drain_alien_cache(cachep, ac, node, &list);
 				spin_unlock_irq(&alc->lock);
+				slabs_destroy(cachep, &list);
 			}
 		}
 	}
@@ -1051,10 +1053,13 @@ static void drain_alien_cache(struct kmem_cache *cachep,
 	for_each_online_node(i) {
 		alc = alien[i];
 		if (alc) {
+			LIST_HEAD(list);
+
 			ac = &alc->ac;
 			spin_lock_irqsave(&alc->lock, flags);
-			__drain_alien_cache(cachep, ac, i);
+			__drain_alien_cache(cachep, ac, i, &list);
 			spin_unlock_irqrestore(&alc->lock, flags);
+			slabs_destroy(cachep, &list);
 		}
 	}
 }
@@ -1085,10 +1090,11 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 		spin_lock(&alien->lock);
 		if (unlikely(ac->avail == ac->limit)) {
 			STATS_INC_ACOVERFLOW(cachep);
-			__drain_alien_cache(cachep, ac, nodeid);
+			__drain_alien_cache(cachep, ac, nodeid, &list);
 		}
 		ac_put_obj(cachep, ac, objp);
 		spin_unlock(&alien->lock);
+		slabs_destroy(cachep, &list);
 	} else {
 		spin_lock(&(cachep->node[nodeid])->list_lock);
 		free_block(cachep, &objp, 1, nodeid, &list);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
