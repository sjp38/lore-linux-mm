Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1E96B0073
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 10:30:27 -0400 (EDT)
Received: by qged89 with SMTP id d89so15773983qge.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 07:30:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b69si4499863qgb.50.2015.06.17.07.30.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 07:30:26 -0700 (PDT)
Subject: [PATCH V2 5/6] slub: initial bulk free implementation
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 17 Jun 2015 16:29:24 +0200
Message-ID: <20150617142901.11791.19168.stgit@devil>
In-Reply-To: <20150617142613.11791.76008.stgit@devil>
References: <20150617142613.11791.76008.stgit@devil>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

This implements SLUB specific kmem_cache_free_bulk().  SLUB allocator
now both have bulk alloc and free implemented.

Choose to reenable local IRQs while calling slowpath __slab_free().
In worst case, where all objects hit slowpath call, the performance
should still be faster than fallback function __kmem_cache_free_bulk(),
because local_irq_{disable+enable} is very fast (7-cycles), while the
fallback invokes this_cpu_cmpxchg() which is slightly slower
(9-cycles). Nitpicking, this should be faster for N>=4, due to the
entry cost of local_irq_{disable+enable}.

Do notice that the save+restore variant is very expensive, this is key
to why this optimization works.

CPU: i7-4790K CPU @ 4.00GHz
 * local_irq_{disable,enable}:  7 cycles(tsc) - 1.821 ns
 * local_irq_{save,restore}  : 37 cycles(tsc) - 9.443 ns

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
V2:
 - Add BUG_ON(!object)
 - No support for kmem_cache_debug()

Measurements on CPU CPU i7-4790K @ 4.00GHz
Baseline normal fastpath (alloc+free cost): 43 cycles(tsc) 10.834 ns

Bulk- fallback                   - this-patch
  1 -  58 cycles(tsc) 14.542 ns  -  43 cycles(tsc) 10.811 ns  improved 25.9%
  2 -  50 cycles(tsc) 12.659 ns  -  27 cycles(tsc)  6.867 ns  improved 46.0%
  3 -  48 cycles(tsc) 12.168 ns  -  21 cycles(tsc)  5.496 ns  improved 56.2%
  4 -  47 cycles(tsc) 11.987 ns  -  24 cycles(tsc)  6.038 ns  improved 48.9%
  8 -  46 cycles(tsc) 11.518 ns  -  17 cycles(tsc)  4.280 ns  improved 63.0%
 16 -  45 cycles(tsc) 11.366 ns  -  17 cycles(tsc)  4.483 ns  improved 62.2%
 30 -  45 cycles(tsc) 11.433 ns  -  18 cycles(tsc)  4.531 ns  improved 60.0%
 32 -  75 cycles(tsc) 18.983 ns  -  58 cycles(tsc) 14.586 ns  improved 22.7%
 34 -  71 cycles(tsc) 17.940 ns  -  53 cycles(tsc) 13.391 ns  improved 25.4%
 48 -  80 cycles(tsc) 20.077 ns  -  65 cycles(tsc) 16.268 ns  improved 18.8%
 64 -  71 cycles(tsc) 17.799 ns  -  53 cycles(tsc) 13.440 ns  improved 25.4%
128 -  91 cycles(tsc) 22.980 ns  -  79 cycles(tsc) 19.899 ns  improved 13.2%
158 - 100 cycles(tsc) 25.241 ns  -  90 cycles(tsc) 22.732 ns  improved 10.0%
250 - 102 cycles(tsc) 25.583 ns  -  95 cycles(tsc) 23.916 ns  improved  6.9%

 mm/slub.c |   34 +++++++++++++++++++++++++++++++++-
 1 file changed, 33 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 02c33bacd3a6..6ac5921b3389 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2753,7 +2753,39 @@ EXPORT_SYMBOL(kmem_cache_free);
 /* Note that interrupts must be enabled when calling this function. */
 void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 {
-	__kmem_cache_free_bulk(s, size, p);
+	struct kmem_cache_cpu *c;
+	struct page *page;
+	int i;
+
+	/* Debugging fallback to generic bulk */
+	if (kmem_cache_debug(s))
+		return __kmem_cache_free_bulk(s, size, p);
+
+	local_irq_disable();
+	c = this_cpu_ptr(s->cpu_slab);
+
+	for (i = 0; i < size; i++) {
+		void *object = p[i];
+
+		BUG_ON(!object);
+		page = virt_to_head_page(object);
+		BUG_ON(s != page->slab_cache); /* Check if valid slab page */
+
+		if (c->page == page) {
+			/* Fastpath: local CPU free */
+			set_freepointer(s, object, c->freelist);
+			c->freelist = object;
+		} else {
+			c->tid = next_tid(c->tid);
+			local_irq_enable();
+			/* Slowpath: overhead locked cmpxchg_double_slab */
+			__slab_free(s, page, object, _RET_IP_);
+			local_irq_disable();
+			c = this_cpu_ptr(s->cpu_slab);
+		}
+	}
+	c->tid = next_tid(c->tid);
+	local_irq_enable();
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
