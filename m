Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f47.google.com (mail-vk0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7BF4403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:15:03 -0500 (EST)
Received: by mail-vk0-f47.google.com with SMTP id k1so244362912vkb.2
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:15:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u133si110346942vkd.49.2016.01.12.07.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 07:15:02 -0800 (PST)
Subject: [PATCH V2 06/11] slab: use slab_post_alloc_hook in SLAB allocator
 shared with SLUB
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 12 Jan 2016 16:14:56 +0100
Message-ID: <20160112151446.31725.19173.stgit@firesoul>
In-Reply-To: <20160112151257.31725.71327.stgit@firesoul>
References: <20160112151257.31725.71327.stgit@firesoul>
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
index 30365be73547..a05f716031de 100644
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
