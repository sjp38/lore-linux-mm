Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id A4C7E6B025A
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 08:26:27 -0400 (EDT)
Received: by qkas79 with SMTP id s79so1822086qka.0
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 05:26:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 84si15173699qhx.86.2015.09.28.05.26.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 05:26:26 -0700 (PDT)
Subject: [PATCH 4/7] slab: implement bulking for SLAB allocator
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 28 Sep 2015 14:26:24 +0200
Message-ID: <20150928122624.15409.23038.stgit@canyon>
In-Reply-To: <20150928122444.15409.10498.stgit@canyon>
References: <20150928122444.15409.10498.stgit@canyon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Implement a basic approach of bulking in the SLAB allocator. Simply
use local_irq_{disable,enable} and call single alloc/free in a loop.
This simple implementation approach is surprising fast.

Notice the normal SLAB fastpath is: 96 cycles (24.119 ns). Below table
show that single object bulking only takes 42 cycles.  This can be
explained by the bulk APIs requirement to be called from a known
interrupt context, that is with interrupts enabled.  This allow us to
avoid the expensive (37 cycles) local_irq_{save,restore}, and instead
use the much faster (7 cycles) local_irq_{disable,restore}.

Benchmarked[1] obj size 256 bytes on CPU i7-4790K @ 4.00GHz:

bulk - Current                  - simple SLAB bulk implementation
  1 - 115 cycles(tsc) 28.812 ns - 42 cycles(tsc) 10.715 ns - improved 63.5%
  2 - 103 cycles(tsc) 25.956 ns - 27 cycles(tsc)  6.985 ns - improved 73.8%
  3 - 101 cycles(tsc) 25.336 ns - 22 cycles(tsc)  5.733 ns - improved 78.2%
  4 - 100 cycles(tsc) 25.147 ns - 21 cycles(tsc)  5.319 ns - improved 79.0%
  8 -  98 cycles(tsc) 24.616 ns - 18 cycles(tsc)  4.620 ns - improved 81.6%
 16 -  97 cycles(tsc) 24.408 ns - 17 cycles(tsc)  4.344 ns - improved 82.5%
 30 -  98 cycles(tsc) 24.641 ns - 16 cycles(tsc)  4.202 ns - improved 83.7%
 32 -  98 cycles(tsc) 24.607 ns - 16 cycles(tsc)  4.199 ns - improved 83.7%
 34 -  98 cycles(tsc) 24.605 ns - 18 cycles(tsc)  4.579 ns - improved 81.6%
 48 -  97 cycles(tsc) 24.463 ns - 17 cycles(tsc)  4.405 ns - improved 82.5%
 64 -  97 cycles(tsc) 24.370 ns - 17 cycles(tsc)  4.384 ns - improved 82.5%
128 -  99 cycles(tsc) 24.763 ns - 19 cycles(tsc)  4.755 ns - improved 80.8%
158 -  98 cycles(tsc) 24.708 ns - 18 cycles(tsc)  4.723 ns - improved 81.6%
250 - 101 cycles(tsc) 25.342 ns - 20 cycles(tsc)  5.035 ns - improved 80.2%

Also notice how well bulking maintains the performance when the bulk
size increases (which is a soar spot for the SLUB allocator).

Increasing the bulk size further:
 20 cycles(tsc)  5.214 ns (bulk: 512)
 30 cycles(tsc)  7.734 ns (bulk: 768)
 40 cycles(tsc) 10.244 ns (bulk:1024)
 72 cycles(tsc) 18.049 ns (bulk:2048)
 90 cycles(tsc) 22.585 ns (bulk:4096)

[1] https://github.com/netoptimizer/prototype-kernel/blob/master/kernel/mm/slab_bulk_test01.c

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 mm/slab.c |   87 +++++++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 62 insertions(+), 25 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index c77ebe6cc87c..21da6b1ccae3 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3234,11 +3234,15 @@ __do_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 #endif /* CONFIG_NUMA */
 
 static __always_inline void *
-slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
+slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller,
+	   bool irq_off_needed)
 {
 	unsigned long save_flags;
 	void *objp;
 
+	/* Compiler need to remove irq_off_needed branch statements */
+	BUILD_BUG_ON(!__builtin_constant_p(irq_off_needed));
+
 	flags &= gfp_allowed_mask;
 
 	lockdep_trace_alloc(flags);
@@ -3249,9 +3253,11 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 	cachep = memcg_kmem_get_cache(cachep, flags);
 
 	cache_alloc_debugcheck_before(cachep, flags);
-	local_irq_save(save_flags);
+	if (irq_off_needed)
+		local_irq_save(save_flags);
 	objp = __do_cache_alloc(cachep, flags);
-	local_irq_restore(save_flags);
+	if (irq_off_needed)
+		local_irq_restore(save_flags);
 	objp = cache_alloc_debugcheck_after(cachep, flags, objp, caller);
 	kmemleak_alloc_recursive(objp, cachep->object_size, 1, cachep->flags,
 				 flags);
@@ -3407,7 +3413,7 @@ static inline void __cache_free(struct kmem_cache *cachep, void *objp,
  */
 void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
-	void *ret = slab_alloc(cachep, flags, _RET_IP_);
+	void *ret = slab_alloc(cachep, flags, _RET_IP_, true);
 
 	trace_kmem_cache_alloc(_RET_IP_, ret,
 			       cachep->object_size, cachep->size, flags);
@@ -3416,16 +3422,23 @@ void *kmem_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 }
 EXPORT_SYMBOL(kmem_cache_alloc);
 
-void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
-{
-	__kmem_cache_free_bulk(s, size, p);
-}
-EXPORT_SYMBOL(kmem_cache_free_bulk);
-
+/* Note that interrupts must be enabled when calling this function. */
 bool kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
-								void **p)
+			   void **p)
 {
-	return __kmem_cache_alloc_bulk(s, flags, size, p);
+	size_t i;
+
+	local_irq_disable();
+	for (i = 0; i < size; i++) {
+		void *x = p[i] = slab_alloc(s, flags, _RET_IP_, false);
+
+		if (!x) {
+			__kmem_cache_free_bulk(s, i, p);
+			return false;
+		}
+	}
+	local_irq_enable();
+	return true;
 }
 EXPORT_SYMBOL(kmem_cache_alloc_bulk);
 
@@ -3435,7 +3448,7 @@ kmem_cache_alloc_trace(struct kmem_cache *cachep, gfp_t flags, size_t size)
 {
 	void *ret;
 
-	ret = slab_alloc(cachep, flags, _RET_IP_);
+	ret = slab_alloc(cachep, flags, _RET_IP_, true);
 
 	trace_kmalloc(_RET_IP_, ret,
 		      size, cachep->size, flags);
@@ -3526,7 +3539,7 @@ static __always_inline void *__do_kmalloc(size_t size, gfp_t flags,
 	cachep = kmalloc_slab(size, flags);
 	if (unlikely(ZERO_OR_NULL_PTR(cachep)))
 		return cachep;
-	ret = slab_alloc(cachep, flags, caller);
+	ret = slab_alloc(cachep, flags, caller, true);
 
 	trace_kmalloc(caller, ret,
 		      size, cachep->size, flags);
@@ -3546,32 +3559,56 @@ void *__kmalloc_track_caller(size_t size, gfp_t flags, unsigned long caller)
 }
 EXPORT_SYMBOL(__kmalloc_track_caller);
 
-/**
- * kmem_cache_free - Deallocate an object
- * @cachep: The cache the allocation was from.
- * @objp: The previously allocated object.
- *
- * Free an object which was previously allocated from this
- * cache.
- */
-void kmem_cache_free(struct kmem_cache *cachep, void *objp)
+/* Caller is responsible for disabling local IRQs */
+static __always_inline void __kmem_cache_free(struct kmem_cache *cachep,
+					      void *objp, bool irq_off_needed)
 {
 	unsigned long flags;
+
+	/* Compiler need to remove irq_off_needed branch statements */
+	BUILD_BUG_ON(!__builtin_constant_p(irq_off_needed));
+
 	cachep = cache_from_obj(cachep, objp);
 	if (!cachep)
 		return;
 
-	local_irq_save(flags);
+	if (irq_off_needed)
+		local_irq_save(flags);
 	debug_check_no_locks_freed(objp, cachep->object_size);
 	if (!(cachep->flags & SLAB_DEBUG_OBJECTS))
 		debug_check_no_obj_freed(objp, cachep->object_size);
 	__cache_free(cachep, objp, _RET_IP_);
-	local_irq_restore(flags);
+	if (irq_off_needed)
+		local_irq_restore(flags);
+}
 
+/**
+ * kmem_cache_free - Deallocate an object
+ * @cachep: The cache the allocation was from.
+ * @objp: The previously allocated object.
+ *
+ * Free an object which was previously allocated from this
+ * cache.
+ */
+void kmem_cache_free(struct kmem_cache *cachep, void *objp)
+{
+	__kmem_cache_free(cachep, objp, true);
 	trace_kmem_cache_free(_RET_IP_, objp);
 }
 EXPORT_SYMBOL(kmem_cache_free);
 
+/* Note that interrupts must be enabled when calling this function. */
+void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
+{
+	size_t i;
+
+	local_irq_disable();
+	for (i = 0; i < size; i++)
+		__kmem_cache_free(s, p[i], false);
+	local_irq_enable();
+}
+EXPORT_SYMBOL(kmem_cache_free_bulk);
+
 /**
  * kfree - free previously allocated memory
  * @objp: pointer returned by kmalloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
