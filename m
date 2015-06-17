Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id D22A36B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:30:55 -0400 (EDT)
Received: by qkeo142 with SMTP id o142so9954287qke.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 07:30:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id da8si4521045qcb.10.2015.06.17.07.30.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 07:30:55 -0700 (PDT)
Subject: [PATCH V2 6/6] slub: add support for kmem_cache_debug in bulk calls
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 17 Jun 2015 16:29:52 +0200
Message-ID: <20150617142934.11791.85352.stgit@devil>
In-Reply-To: <20150617142613.11791.76008.stgit@devil>
References: <20150617142613.11791.76008.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Per request of Joonsoo Kim adding kmem debug support.

I've tested that when debugging is disabled, then there is almost
no performance impact as this code basically gets removed by the
compiler.

Need some guidance in enabling and testing this.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
Measurements with disabled debugging:

bulk- PREVIOUS                  - THIS-PATCH
  1 -  43 cycles(tsc) 10.811 ns -  44 cycles(tsc) 11.236 ns  improved  -2.3%
  2 -  27 cycles(tsc)  6.867 ns -  28 cycles(tsc)  7.019 ns  improved  -3.7%
  3 -  21 cycles(tsc)  5.496 ns -  22 cycles(tsc)  5.526 ns  improved  -4.8%
  4 -  24 cycles(tsc)  6.038 ns -  19 cycles(tsc)  4.786 ns  improved  20.8%
  8 -  17 cycles(tsc)  4.280 ns -  18 cycles(tsc)  4.572 ns  improved  -5.9%
 16 -  17 cycles(tsc)  4.483 ns -  18 cycles(tsc)  4.658 ns  improved  -5.9%
 30 -  18 cycles(tsc)  4.531 ns -  18 cycles(tsc)  4.568 ns  improved   0.0%
 32 -  58 cycles(tsc) 14.586 ns -  65 cycles(tsc) 16.454 ns  improved -12.1%
 34 -  53 cycles(tsc) 13.391 ns -  63 cycles(tsc) 15.932 ns  improved -18.9%
 48 -  65 cycles(tsc) 16.268 ns -  50 cycles(tsc) 12.506 ns  improved  23.1%
 64 -  53 cycles(tsc) 13.440 ns -  63 cycles(tsc) 15.929 ns  improved -18.9%
128 -  79 cycles(tsc) 19.899 ns -  86 cycles(tsc) 21.583 ns  improved  -8.9%
158 -  90 cycles(tsc) 22.732 ns -  90 cycles(tsc) 22.552 ns  improved   0.0%
250 -  95 cycles(tsc) 23.916 ns -  98 cycles(tsc) 24.589 ns  improved  -3.2%

 mm/slub.c |   28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 6ac5921b3389..cb19d5c0e26c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2757,10 +2757,6 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 	struct page *page;
 	int i;
 
-	/* Debugging fallback to generic bulk */
-	if (kmem_cache_debug(s))
-		return __kmem_cache_free_bulk(s, size, p);
-
 	local_irq_disable();
 	c = this_cpu_ptr(s->cpu_slab);
 
@@ -2768,8 +2764,13 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 		void *object = p[i];
 
 		BUG_ON(!object);
+		/* kmem cache debug support */
+		s = cache_from_obj(s, object);
+		if (unlikely(!s))
+			goto exit;
+		slab_free_hook(s, object);
+
 		page = virt_to_head_page(object);
-		BUG_ON(s != page->slab_cache); /* Check if valid slab page */
 
 		if (c->page == page) {
 			/* Fastpath: local CPU free */
@@ -2784,6 +2785,7 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 			c = this_cpu_ptr(s->cpu_slab);
 		}
 	}
+exit:
 	c->tid = next_tid(c->tid);
 	local_irq_enable();
 }
@@ -2796,10 +2798,6 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 	struct kmem_cache_cpu *c;
 	int i;
 
-	/* Debugging fallback to generic bulk */
-	if (kmem_cache_debug(s))
-		return __kmem_cache_alloc_bulk(s, flags, size, p);
-
 	/*
 	 * Drain objects in the per cpu slab, while disabling local
 	 * IRQs, which protects against PREEMPT and interrupts
@@ -2828,8 +2826,20 @@ bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			continue; /* goto for-loop */
 		}
 
+		/* kmem_cache debug support */
+		s = slab_pre_alloc_hook(s, flags);
+		if (unlikely(!s)) {
+			__kmem_cache_free_bulk(s, i, p);
+			c->tid = next_tid(c->tid);
+			local_irq_enable();
+			return false;
+		}
+
 		c->freelist = get_freepointer(s, object);
 		p[i] = object;
+
+		/* kmem_cache debug support */
+		slab_post_alloc_hook(s, flags, object);
 	}
 	c->tid = next_tid(c->tid);
 	local_irq_enable();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
