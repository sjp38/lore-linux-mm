Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A20C56B003B
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 01:57:29 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id lj1so11863671pab.40
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 22:57:29 -0800 (PST)
Received: from LGEAMRELO01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id to9si4662117pbc.125.2014.02.13.22.57.27
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 22:57:28 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 8/9] slab: destroy a slab without holding any alien cache lock
Date: Fri, 14 Feb 2014 15:57:22 +0900
Message-Id: <1392361043-22420-9-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

I haven't heard that this alien cache lock is contended, but to reduce
chance of contention would be better generally. And with this change,
we can simplify complex lockdep annotation in slab code.
In the following patch, it will be implemented.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index ec1df4c..9c9d4d4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1000,9 +1000,9 @@ static void free_alien_cache(struct alien_cache **alc_ptr)
 }
 
 static void __drain_alien_cache(struct kmem_cache *cachep,
-				struct array_cache *ac, int node)
+				struct array_cache *ac, int node,
+				struct list_head *list)
 {
-	LIST_HEAD(list);
 	struct kmem_cache_node *n = cachep->node[node];
 
 	if (ac->avail) {
@@ -1015,10 +1015,9 @@ static void __drain_alien_cache(struct kmem_cache *cachep,
 		if (n->shared)
 			transfer_objects(n->shared, ac, ac->limit);
 
-		free_block(cachep, ac->entry, ac->avail, node, &list);
+		free_block(cachep, ac->entry, ac->avail, node, list);
 		ac->avail = 0;
 		spin_unlock(&n->list_lock);
-		slabs_destroy(cachep, &list);
 	}
 }
 
@@ -1036,8 +1035,11 @@ static void reap_alien(struct kmem_cache *cachep, struct kmem_cache_node *n)
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
@@ -1054,10 +1056,13 @@ static void drain_alien_cache(struct kmem_cache *cachep,
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
@@ -1088,10 +1093,11 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
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
