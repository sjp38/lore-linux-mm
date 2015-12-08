Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id B18376B025C
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 11:19:22 -0500 (EST)
Received: by qgeb1 with SMTP id b1so23389602qge.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 08:19:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d139si4035448qhd.89.2015.12.08.08.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 08:18:49 -0800 (PST)
Subject: [RFC PATCH V2 5/9] slab: use slab_post_alloc_hook in SLAB allocator
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 08 Dec 2015 17:18:47 +0100
Message-ID: <20151208161847.21945.28194.stgit@firesoul>
In-Reply-To: <20151208161751.21945.53936.stgit@firesoul>
References: <20151208161751.21945.53936.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

Reviewers notice that the order in slab_post_alloc_hook() of
kmemcheck_slab_alloc() and kmemleak_alloc_recursive() gets
swapped compared to slab.c.

Also notice memset now occurs before calling kmemcheck_slab_alloc()
and kmemleak_alloc_recursive().

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.c |   22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 17fd6268ad41..47e7bcab8c3b 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3172,16 +3172,11 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
   out:
 	local_irq_restore(save_flags);
 	ptr = cache_alloc_debugcheck_after(cachep, flags, ptr, caller);
-	kmemleak_alloc_recursive(ptr, cachep->object_size, 1, cachep->flags,
-				 flags);
 
-	if (likely(ptr)) {
-		kmemcheck_slab_alloc(cachep, flags, ptr, cachep->object_size);
-		if (unlikely(flags & __GFP_ZERO))
-			memset(ptr, 0, cachep->object_size);
-	}
+	if (unlikely(flags & __GFP_ZERO) && ptr)
+		memset(ptr, 0, cachep->object_size);
 
-	memcg_kmem_put_cache(cachep);
+	slab_post_alloc_hook(cachep, flags, 1, &ptr);
 	return ptr;
 }
 
@@ -3232,17 +3227,12 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	objp = __do_cache_alloc(cachep, flags);
 	local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
-	kmemleak_alloc_recursive(objp, cachep->object_size, 1, cachep->flags,
-				 flags);
 	prefetchw(objp);
 
-	if (likely(objp)) {
-		kmemcheck_slab_alloc(cachep, flags, objp, cachep->object_size);
-		if (unlikely(flags & __GFP_ZERO))
-			memset(objp, 0, cachep->object_size);
-	}
+	if (unlikely(flags & __GFP_ZERO) && objp)
+		memset(objp, 0, cachep->object_size);
 
-	memcg_kmem_put_cache(cachep);
+	slab_post_alloc_hook(cachep, flags, 1, &objp);
 	return objp;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
