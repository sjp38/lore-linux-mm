Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 34D366B0253
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 13:17:35 -0500 (EST)
Received: by igl9 with SMTP id 9so36594680igl.0
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 10:17:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j14si11637390igh.79.2015.11.09.10.17.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 10:17:34 -0800 (PST)
Subject: [PATCH V3 1/2] slub: fix kmem cgroup bug in kmem_cache_alloc_bulk
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 09 Nov 2015 19:17:31 +0100
Message-ID: <20151109181703.8231.66384.stgit@firesoul>
In-Reply-To: <20151109181604.8231.22983.stgit@firesoul>
References: <20151109181604.8231.22983.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vdavydov@virtuozzo.com, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Jesper Dangaard Brouer <brouer@redhat.com>

The call slab_pre_alloc_hook() interacts with kmemgc and is not
allowed to be called several times inside the bulk alloc for loop,
due to the call to memcg_kmem_get_cache().

This would result in hitting the VM_BUG_ON in __memcg_kmem_get_cache.

As suggested by Vladimir Davydov, change slab_post_alloc_hook()
to be able to handle an array of objects.

A subtle detail is, loop iterator "i" in slab_post_alloc_hook()
must have same type (size_t) as size argument.  This helps the
compiler to easier realize that it can remove the loop, when all
debug statements inside loop evaluates to nothing.
 Note, this is only an issue because the kernel is compiled with
GCC option: -fno-strict-overflow

Reported-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Suggested-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V3:
 Addressed input and used suggetions from Vladimir

 mm/slub.c |   35 ++++++++++++++++++++++-------------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 9be12ffae9fc..8e6b929d06d6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1292,14 +1292,21 @@ static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
 	return memcg_kmem_get_cache(s, flags);
 }
 
-static inline void slab_post_alloc_hook(struct kmem_cache *s,
-					gfp_t flags, void *object)
+static inline void slab_post_alloc_hook(struct kmem_cache *s, gfp_t flags,
+					size_t size, void **p)
 {
+	size_t i;
+
 	flags &= gfp_allowed_mask;
-	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
-	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
+	for (i = 0; i < size; i++) {
+		void *object = p[i];
+
+		kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
+		kmemleak_alloc_recursive(object, s->object_size, 1,
+					 s->flags, flags);
+		kasan_slab_alloc(s, object);
+	}
 	memcg_kmem_put_cache(s);
-	kasan_slab_alloc(s, object);
 }
 
 static inline void slab_free_hook(struct kmem_cache *s, void *x)
@@ -2556,7 +2563,7 @@ redo:
 	if (unlikely(gfpflags & __GFP_ZERO) && object)
 		memset(object, 0, s->object_size);
 
-	slab_post_alloc_hook(s, gfpflags, object);
+	slab_post_alloc_hook(s, gfpflags, 1, object);
 
 	return object;
 }
@@ -2906,6 +2913,11 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	struct kmem_cache_cpu *c;
 	int i;
 
+	/* memcg and kmem_cache debug support */
+	s = slab_pre_alloc_hook(s, flags);
+	if (unlikely(!s))
+		return false;
+
 	/*
 	 * Drain objects in the per cpu slab, while disabling local
 	 * IRQs, which protects against PREEMPT and interrupts
@@ -2931,16 +2943,9 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			continue; /* goto for-loop */
 		}
 
-		/* kmem_cache debug support */
-		s = slab_pre_alloc_hook(s, flags);
-		if (unlikely(!s))
-			goto error;
-
 		c->freelist = get_freepointer(s, object);
 		p[i] = object;
 
-		/* kmem_cache debug support */
-		slab_post_alloc_hook(s, flags, object);
 	}
 	c->tid = next_tid(c->tid);
 	local_irq_enable();
@@ -2953,11 +2958,15 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			memset(p[j], 0, s->object_size);
 	}
 
+	/* memcg and kmem_cache debug support */
+	slab_post_alloc_hook(s, flags, size, p);
+
 	return true;
 
 error:
 	__kmem_cache_free_bulk(s, i, p);
 	local_irq_enable();
+	memcg_kmem_put_cache(s);
 	return false;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
