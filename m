Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id CD96C6B0255
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 10:57:33 -0500 (EST)
Received: by qgeb1 with SMTP id b1so64362379qge.1
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 07:57:33 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 18si9122525qgl.97.2015.12.03.07.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 07:57:33 -0800 (PST)
Subject: [RFC PATCH 1/2] slab: implement bulk alloc in SLAB allocator
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 03 Dec 2015 16:57:31 +0100
Message-ID: <20151203155637.3589.62609.stgit@firesoul>
In-Reply-To: <20151203155600.3589.86568.stgit@firesoul>
References: <20151203155600.3589.86568.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <cl@linux.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

(will add more desc after RFC)

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.c |   54 ++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 52 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 4765c97ce690..3354489547ec 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3420,9 +3420,59 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 
 int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
-								void **p)
+			  void **p)
 {
-	return __kmem_cache_alloc_bulk(s, flags, size, p);
+	size_t i;
+
+	flags &= gfp_allowed_mask;
+	lockdep_trace_alloc(flags);
+
+	if (slab_should_failslab(s, flags))
+		return 0;
+
+	s = memcg_kmem_get_cache(s, flags);
+
+	cache_alloc_debugcheck_before(s, flags);
+
+	local_irq_disable();
+	for (i = 0; i < size; i++) {
+		void *objp = __do_cache_alloc(s, flags);
+
+		// this call could be done outside IRQ disabled section
+		objp = cache_alloc_debugcheck_after(s, flags, objp, _RET_IP_);
+
+		if (unlikely(!objp))
+			goto error;
+
+		prefetchw(objp);
+		p[i] = objp;
+	}
+	local_irq_enable();
+
+	/* Kmemleak and kmemcheck outside IRQ disabled section */
+	for (i = 0; i < size; i++) {
+		void *x = p[i];
+
+		kmemleak_alloc_recursive(x, s->object_size, 1, s->flags, flags);
+		kmemcheck_slab_alloc(s, flags, x, s->object_size);
+	}
+
+	/* Clear memory outside IRQ disabled section */
+	if (unlikely(flags & __GFP_ZERO))
+		for (i = 0; i < size; i++)
+			memset(p[i], 0, s->object_size);
+
+// FIXME: Trace call missing... should we create a bulk variant?
+/*  Like:
+	trace_kmem_cache_alloc(_RET_IP_, ret, s->object_size, s->size, flags);
+*/
+	memcg_kmem_put_cache(s);
+	return size;
+error:
+	local_irq_enable();
+	memcg_kmem_put_cache(s);
+	__kmem_cache_free_bulk(s, i, p);
+	return 0;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
