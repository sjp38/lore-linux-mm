Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6406F82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 10:37:54 -0500 (EST)
Received: by ykek133 with SMTP id k133so137286687yke.2
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 07:37:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 123si4955667vkf.70.2015.11.05.07.37.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 07:37:53 -0800 (PST)
Subject: [PATCH V2 1/2] slub: fix kmem cgroup bug in kmem_cache_alloc_bulk
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 05 Nov 2015 16:37:51 +0100
Message-ID: <20151105153744.1115.38620.stgit@firesoul>
In-Reply-To: <20151105153704.1115.10475.stgit@firesoul>
References: <20151105153704.1115.10475.stgit@firesoul>
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

To match the number of "put" calls, the call to memcg_kmem_put_cache()
is moved out of slab_post_alloc_hook().

Reported-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slub.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 9be12ffae9fc..8e9e9b2ee6f3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1298,7 +1298,6 @@ static inline void slab_post_alloc_hook(struct kmem_cache *s,
 	flags &= gfp_allowed_mask;
 	kmemcheck_slab_alloc(s, flags, object, slab_ksize(s));
 	kmemleak_alloc_recursive(object, s->object_size, 1, s->flags, flags);
-	memcg_kmem_put_cache(s);
 	kasan_slab_alloc(s, object);
 }
 
@@ -2557,6 +2556,7 @@ redo:
 		memset(object, 0, s->object_size);
 
 	slab_post_alloc_hook(s, gfpflags, object);
+	memcg_kmem_put_cache(s);
 
 	return object;
 }
@@ -2906,6 +2906,11 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
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
@@ -2931,11 +2936,6 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			continue; /* goto for-loop */
 		}
 
-		/* kmem_cache debug support */
-		s = slab_pre_alloc_hook(s, flags);
-		if (unlikely(!s))
-			goto error;
-
 		c->freelist = get_freepointer(s, object);
 		p[i] = object;
 
@@ -2953,9 +2953,11 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			memset(p[j], 0, s->object_size);
 	}
 
+	memcg_kmem_put_cache(s);
 	return true;
 
 error:
+	memcg_kmem_put_cache(s);
 	__kmem_cache_free_bulk(s, i, p);
 	local_irq_enable();
 	return false;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
