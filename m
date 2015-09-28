Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f177.google.com (mail-qk0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id B62E06B025C
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 08:26:37 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so66603931qkc.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 05:26:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 7si15203157qgo.95.2015.09.28.05.26.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 05:26:37 -0700 (PDT)
Subject: [PATCH 6/7] slub: optimize bulk slowpath free by detached freelist
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 28 Sep 2015 14:26:34 +0200
Message-ID: <20150928122634.15409.6956.stgit@canyon>
In-Reply-To: <20150928122444.15409.10498.stgit@canyon>
References: <20150928122444.15409.10498.stgit@canyon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This change focus on improving the speed of object freeing in the
"slowpath" of kmem_cache_free_bulk.

The calls slab_free (fastpath) and __slab_free (slowpath) have been
extended with support for bulk free, which amortize the overhead of
the (locked) cmpxchg_double.

To use the new bulking feature, we build what I call a detached
freelist.  The detached freelist takes advantage of three properties:

 1) the free function call owns the object that is about to be freed,
    thus writing into this memory is synchronization-free.

 2) many freelist's can co-exist side-by-side in the same slab-page
    each with a separate head pointer.

 3) it is the visibility of the head pointer that needs synchronization.

Given these properties, the brilliant part is that the detached
freelist can be constructed without any need for synchronization.  The
freelist is constructed directly in the page objects, without any
synchronization needed.  The detached freelist is allocated on the
stack of the function call kmem_cache_free_bulk.  Thus, the freelist
head pointer is not visible to other CPUs.

All objects in a SLUB freelist must belong to the same slab-page.
Thus, constructing the detached freelist is about matching objects
that belong to the same slab-page.  The bulk free array is scanned is
a progressive manor with a limited look-ahead facility.

Kmem debug support is handled in call of slab_free().

Notice kmem_cache_free_bulk no longer need to disable IRQs. This
only slowed down single free bulk with approx 3 cycles.


Performance data:
 Benchmarked[1] obj size 256 bytes on CPU i7-4790K @ 4.00GHz

SLUB fastpath single object quick reuse: 47 cycles(tsc) 11.931 ns

To get stable and comparable numbers, the kernel have been booted with
"slab_merge" (this also improve performance for larger bulk sizes).

Performance data, compared against fallback bulking:

bulk -  fallback bulk            - improvement with this patch
   1 -  62 cycles(tsc) 15.662 ns - 49 cycles(tsc) 12.407 ns- improved 21.0%
   2 -  55 cycles(tsc) 13.935 ns - 30 cycles(tsc) 7.506 ns - improved 45.5%
   3 -  53 cycles(tsc) 13.341 ns - 23 cycles(tsc) 5.865 ns - improved 56.6%
   4 -  52 cycles(tsc) 13.081 ns - 20 cycles(tsc) 5.048 ns - improved 61.5%
   8 -  50 cycles(tsc) 12.627 ns - 18 cycles(tsc) 4.659 ns - improved 64.0%
  16 -  49 cycles(tsc) 12.412 ns - 17 cycles(tsc) 4.495 ns - improved 65.3%
  30 -  49 cycles(tsc) 12.484 ns - 18 cycles(tsc) 4.533 ns - improved 63.3%
  32 -  50 cycles(tsc) 12.627 ns - 18 cycles(tsc) 4.707 ns - improved 64.0%
  34 -  96 cycles(tsc) 24.243 ns - 23 cycles(tsc) 5.976 ns - improved 76.0%
  48 -  83 cycles(tsc) 20.818 ns - 21 cycles(tsc) 5.329 ns - improved 74.7%
  64 -  74 cycles(tsc) 18.700 ns - 20 cycles(tsc) 5.127 ns - improved 73.0%
 128 -  90 cycles(tsc) 22.734 ns - 27 cycles(tsc) 6.833 ns - improved 70.0%
 158 -  99 cycles(tsc) 24.776 ns - 30 cycles(tsc) 7.583 ns - improved 69.7%
 250 - 104 cycles(tsc) 26.089 ns - 37 cycles(tsc) 9.280 ns - improved 64.4%

Performance data, compared current in-kernel bulking:

bulk - curr in-kernel  - improvement with this patch
   1 -  46 cycles(tsc) - 49 cycles(tsc) - improved (cycles:-3) -6.5%
   2 -  27 cycles(tsc) - 30 cycles(tsc) - improved (cycles:-3) -11.1%
   3 -  21 cycles(tsc) - 23 cycles(tsc) - improved (cycles:-2) -9.5%
   4 -  18 cycles(tsc) - 20 cycles(tsc) - improved (cycles:-2) -11.1%
   8 -  17 cycles(tsc) - 18 cycles(tsc) - improved (cycles:-1) -5.9%
  16 -  18 cycles(tsc) - 17 cycles(tsc) - improved (cycles: 1)  5.6%
  30 -  18 cycles(tsc) - 18 cycles(tsc) - improved (cycles: 0)  0.0%
  32 -  18 cycles(tsc) - 18 cycles(tsc) - improved (cycles: 0)  0.0%
  34 -  78 cycles(tsc) - 23 cycles(tsc) - improved (cycles:55) 70.5%
  48 -  60 cycles(tsc) - 21 cycles(tsc) - improved (cycles:39) 65.0%
  64 -  49 cycles(tsc) - 20 cycles(tsc) - improved (cycles:29) 59.2%
 128 -  69 cycles(tsc) - 27 cycles(tsc) - improved (cycles:42) 60.9%
 158 -  79 cycles(tsc) - 30 cycles(tsc) - improved (cycles:49) 62.0%
 250 -  86 cycles(tsc) - 37 cycles(tsc) - improved (cycles:49) 57.0%

Performance with normal SLUB merging is significantly slower for
larger bulking.  This is believed to (primarily) be an effect of not
having to share the per-CPU data-structures, as tuning per-CPU size
can achieve similar performance.

bulk - slab_nomerge   -  normal SLUB merge
   1 -  49 cycles(tsc) - 49 cycles(tsc) - merge slower with cycles:0
   2 -  30 cycles(tsc) - 30 cycles(tsc) - merge slower with cycles:0
   3 -  23 cycles(tsc) - 23 cycles(tsc) - merge slower with cycles:0
   4 -  20 cycles(tsc) - 20 cycles(tsc) - merge slower with cycles:0
   8 -  18 cycles(tsc) - 18 cycles(tsc) - merge slower with cycles:0
  16 -  17 cycles(tsc) - 17 cycles(tsc) - merge slower with cycles:0
  30 -  18 cycles(tsc) - 23 cycles(tsc) - merge slower with cycles:5
  32 -  18 cycles(tsc) - 22 cycles(tsc) - merge slower with cycles:4
  34 -  23 cycles(tsc) - 22 cycles(tsc) - merge slower with cycles:-1
  48 -  21 cycles(tsc) - 22 cycles(tsc) - merge slower with cycles:1
  64 -  20 cycles(tsc) - 48 cycles(tsc) - merge slower with cycles:28
 128 -  27 cycles(tsc) - 57 cycles(tsc) - merge slower with cycles:30
 158 -  30 cycles(tsc) - 59 cycles(tsc) - merge slower with cycles:29
 250 -  37 cycles(tsc) - 56 cycles(tsc) - merge slower with cycles:19

Joint work with Alexander Duyck.

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test01.c

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 mm/slub.c |  109 ++++++++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 79 insertions(+), 30 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 13b5f53e4840..c25717ab3b5a 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2832,44 +2832,93 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
-/* Note that interrupts must be enabled when calling this function. */
-void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
-{
-	struct kmem_cache_cpu *c;
+struct detached_freelist {
 	struct page *page;
-	int i;
+	void *tail_object;
+	void *freelist;
+	int cnt;
+};
 
-	local_irq_disable();
-	c = this_cpu_ptr(s->cpu_slab);
+/*
+ * This function progressively scans the array with free objects (with
+ * a limited look ahead) and extract objects belonging to the same
+ * page.  It builds a detached freelist directly within the given
+ * page/objects.  This can happen without any need for
+ * synchronization, because the objects are owned by running process.
+ * The freelist is build up as a single linked list in the objects.
+ * The idea is, that this detached freelist can then be bulk
+ * transferred to the real freelist(s), but only requiring a single
+ * synchronization primitive.  Look ahead in the array is limited due
+ * to performance reasons.
+ */
+static int build_detached_freelist(struct kmem_cache *s, size_t size,
+				   void **p, struct detached_freelist *df)
+{
+	size_t first_skipped_index = 0;
+	int lookahead = 3;
+	void *object;
 
-	for (i = 0; i < size; i++) {
-		void *object = p[i];
+	/* Always re-init detached_freelist */
+	df->page = NULL;
 
-		BUG_ON(!object);
-		/* kmem cache debug support */
-		s = cache_from_obj(s, object);
-		if (unlikely(!s))
-			goto exit;
-		slab_free_hook(s, object);
+	do {
+		object = p[--size];
+	} while (!object && size);
 
-		page = virt_to_head_page(object);
+	if (!object)
+		return 0;
 
-		if (c->page == page) {
-			/* Fastpath: local CPU free */
-			set_freepointer(s, object, c->freelist);
-			c->freelist = object;
-		} else {
-			c->tid = next_tid(c->tid);
-			local_irq_enable();
-			/* Slowpath: overhead locked cmpxchg_double_slab */
-			__slab_free(s, page, object, _RET_IP_, NULL, 1);
-			local_irq_disable();
-			c = this_cpu_ptr(s->cpu_slab);
+	/* Start new detached freelist */
+	set_freepointer(s, object, NULL);
+	df->page = virt_to_head_page(object);
+	df->tail_object = object;
+	df->freelist = object;
+	p[size] = NULL; /* mark object processed */
+	df->cnt = 1;
+
+	while (size) {
+		object = p[--size];
+		if (!object)
+			continue; /* Skip processed objects */
+
+		/* df->page is always set at this point */
+		if (df->page == virt_to_head_page(object)) {
+			/* Opportunity build freelist */
+			set_freepointer(s, object, df->freelist);
+			df->freelist = object;
+			df->cnt++;
+			p[size] = NULL; /* mark object processed */
+
+			continue;
 		}
+
+		/* Limit look ahead search */
+		if (!--lookahead)
+			break;
+
+		if (!first_skipped_index)
+			first_skipped_index = size + 1;
 	}
-exit:
-	c->tid = next_tid(c->tid);
-	local_irq_enable();
+
+	return first_skipped_index;
+}
+
+
+/* Note that interrupts must be enabled when calling this function. */
+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+{
+	BUG_ON(!size);
+
+	do {
+		struct detached_freelist df;
+
+		size = build_detached_freelist(s, size, p, &df);
+		if (unlikely(!df.page))
+			continue;
+
+		slab_free(s, df.page, df.tail_object, _RET_IP_,
+			  df.freelist, df.cnt);
+	} while (likely(size));
 }
 EXPORT_SYMBOL(kmem_cache_free_bulk);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
