Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id A8896828E1
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 09:04:06 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id b35so197709333qge.0
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 06:04:06 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 140si58344385qhi.4.2016.01.07.06.04.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 06:04:06 -0800 (PST)
Subject: [PATCH 06/10] slab: use slab_post_alloc_hook in SLAB allocator
 shared with SLUB
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 07 Jan 2016 15:04:03 +0100
Message-ID: <20160107140403.28907.2650.stgit@firesoul>
In-Reply-To: <20160107140253.28907.5469.stgit@firesoul>
References: <20160107140253.28907.5469.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Reviewers notice that the order in slab_post_alloc_hook() of
kmemcheck_slab_alloc() and kmemleak_alloc_recursive() gets
swapped compared to slab.c / SLAB allocator.

Also notice memset now occurs before calling kmemcheck_slab_alloc()
and kmemleak_alloc_recursive().

I assume this reordering of kmemcheck, kmemleak and memset is okay
because this is the order they are used by the SLUB allocator.

This patch completes the sharing of alloc_hook's between SLUB and SLAB.

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
