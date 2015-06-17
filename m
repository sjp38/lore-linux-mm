Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id A088C6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:29:29 -0400 (EDT)
Received: by qged89 with SMTP id d89so15763052qge.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 07:29:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i35si4475036qgd.126.2015.06.17.07.29.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 07:29:28 -0700 (PDT)
Subject: [PATCH V2 3/6] slub bulk alloc: extract objects from the per cpu
 slab
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 17 Jun 2015 16:28:24 +0200
Message-ID: <20150617142803.11791.896.stgit@devil>
In-Reply-To: <20150617142613.11791.76008.stgit@devil>
References: <20150617142613.11791.76008.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

First piece: acceleration of retrieval of per cpu objects

If we are allocating lots of objects then it is advantageous to disable
interrupts and avoid the this_cpu_cmpxchg() operation to get these objects
faster.

Note that we cannot do the fast operation if debugging is enabled, because
we would have to add extra code to do all the debugging checks.  And it
would not be fast anyway.

Note also that the requirement of having interrupts disabled
avoids having to do processor flag operations.

Allocate as many objects as possible in the fast way and then fall back to
the generic implementation for the rest of the objects.

Signed-off-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2:
 - Merged several patches into this
 - Basically rewritten entire function...

Measurements on CPU CPU i7-4790K @ 4.00GHz
Baseline normal fastpath (alloc+free cost): 42 cycles(tsc) 10.554 ns

Bulk- fallback                   - this-patch
  1 -  57 cycles(tsc) 14.432 ns  -  48 cycles(tsc) 12.155 ns  improved 15.8%
  2 -  50 cycles(tsc) 12.746 ns  -  37 cycles(tsc)  9.390 ns  improved 26.0%
  3 -  48 cycles(tsc) 12.180 ns  -  33 cycles(tsc)  8.417 ns  improved 31.2%
  4 -  48 cycles(tsc) 12.015 ns  -  32 cycles(tsc)  8.045 ns  improved 33.3%
  8 -  46 cycles(tsc) 11.526 ns  -  30 cycles(tsc)  7.699 ns  improved 34.8%
 16 -  45 cycles(tsc) 11.418 ns  -  32 cycles(tsc)  8.205 ns  improved 28.9%
 30 -  80 cycles(tsc) 20.246 ns  -  73 cycles(tsc) 18.328 ns  improved  8.8%
 32 -  79 cycles(tsc) 19.946 ns  -  72 cycles(tsc) 18.208 ns  improved  8.9%
 34 -  78 cycles(tsc) 19.659 ns  -  71 cycles(tsc) 17.987 ns  improved  9.0%
 48 -  86 cycles(tsc) 21.516 ns  -  82 cycles(tsc) 20.566 ns  improved  4.7%
 64 -  93 cycles(tsc) 23.423 ns  -  89 cycles(tsc) 22.480 ns  improved  4.3%
128 - 100 cycles(tsc) 25.170 ns  -  99 cycles(tsc) 24.871 ns  improved  1.0%
158 - 102 cycles(tsc) 25.549 ns  - 101 cycles(tsc) 25.375 ns  improved  1.0%
250 - 101 cycles(tsc) 25.344 ns  - 100 cycles(tsc) 25.182 ns  improved  1.0%

 mm/slub.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 47 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index ac5a196d5ea5..a92fdec57237 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2750,16 +2750,61 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
+/* Note that interrupts must be enabled when calling this function. */
 void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 {
 	__kmem_cache_free_bulk(s, size, p);
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 
+/* Note that interrupts must be enabled when calling this function. */
 bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
-								void **p)
+			   void **p)
 {
-	return __kmem_cache_alloc_bulk(s, flags, size, p);
+	struct kmem_cache_cpu *c;
+	int i;
+
+	/* Debugging fallback to generic bulk */
+	if (kmem_cache_debug(s))
+		return __kmem_cache_alloc_bulk(s, flags, size, p);
+
+	/*
+	 * Drain objects in the per cpu slab, while disabling local
+	 * IRQs, which protects against PREEMPT and interrupts
+	 * handlers invoking normal fastpath.
+	 */
+	local_irq_disable();
+	c = this_cpu_ptr(s->cpu_slab);
+
+	for (i = 0; i < size; i++) {
+		void *object = c->freelist;
+
+		if (!object)
+			break;
+
+		c->freelist = get_freepointer(s, object);
+		p[i] = object;
+	}
+	c->tid = next_tid(c->tid);
+	local_irq_enable();
+
+	/* Clear memory outside IRQ disabled fastpath loop */
+	if (unlikely(flags & __GFP_ZERO)) {
+		int j;
+
+		for (j = 0; j < i; j++)
+			memset(p[j], 0, s->object_size);
+	}
+
+	/* Fallback to single elem alloc */
+	for (; i < size; i++) {
+		void *x = p[i] = kmem_cache_alloc(s, flags);
+		if (unlikely(!x)) {
+			__kmem_cache_free_bulk(s, i, p);
+			return false;
+		}
+	}
+	return true;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
