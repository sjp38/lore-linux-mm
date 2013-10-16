Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8695E6B0038
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 04:44:18 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id g10so458689pdj.21
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 01:44:18 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 04/15] slab: remove nodeid in struct slab
Date: Wed, 16 Oct 2013 17:44:01 +0900
Message-Id: <1381913052-23875-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We can get nodeid using address translation, so this field is not useful.
Therefore, remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 34eb115..71ba8f5 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -222,7 +222,6 @@ struct slab {
 			void *s_mem;		/* including colour offset */
 			unsigned int inuse;	/* num of objs active in slab */
 			kmem_bufctl_t free;
-			unsigned short nodeid;
 		};
 		struct slab_rcu __slab_cover_slab_rcu;
 	};
@@ -1099,8 +1098,7 @@ static void drain_alien_cache(struct kmem_cache *cachep,
 
 static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 {
-	struct slab *slabp = virt_to_slab(objp);
-	int nodeid = slabp->nodeid;
+	int nodeid = page_to_nid(virt_to_page(objp));
 	struct kmem_cache_node *n;
 	struct array_cache *alien = NULL;
 	int node;
@@ -1111,7 +1109,7 @@ static inline int cache_free_alien(struct kmem_cache *cachep, void *objp)
 	 * Make sure we are not freeing a object from another node to the array
 	 * cache on this cpu.
 	 */
-	if (likely(slabp->nodeid == node))
+	if (likely(nodeid == node))
 		return 0;
 
 	n = cachep->node[node];
@@ -2630,7 +2628,6 @@ static struct slab *alloc_slabmgmt(struct kmem_cache *cachep,
 	}
 	slabp->inuse = 0;
 	slabp->s_mem = addr + colour_off;
-	slabp->nodeid = nodeid;
 	slabp->free = 0;
 	return slabp;
 }
@@ -2707,7 +2704,7 @@ static void *slab_get_obj(struct kmem_cache *cachep, struct slab *slabp,
 	next = slab_bufctl(slabp)[slabp->free];
 #if DEBUG
 	slab_bufctl(slabp)[slabp->free] = BUFCTL_FREE;
-	WARN_ON(slabp->nodeid != nodeid);
+	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
 #endif
 	slabp->free = next;
 
@@ -2721,7 +2718,7 @@ static void slab_put_obj(struct kmem_cache *cachep, struct slab *slabp,
 
 #if DEBUG
 	/* Verify that the slab belongs to the intended node */
-	WARN_ON(slabp->nodeid != nodeid);
+	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
 
 	if (slab_bufctl(slabp)[objnr] + 1 <= SLAB_LIMIT + 1) {
 		printk(KERN_ERR "slab: double free detected in cache "
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
