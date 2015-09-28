Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id B72596B025B
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 08:26:32 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so66602797qkc.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 05:26:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e11si15235957qgf.0.2015.09.28.05.26.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 05:26:32 -0700 (PDT)
Subject: [PATCH 5/7] slub: support for bulk free with SLUB freelists
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Mon, 28 Sep 2015 14:26:29 +0200
Message-ID: <20150928122629.15409.69466.stgit@canyon>
In-Reply-To: <20150928122444.15409.10498.stgit@canyon>
References: <20150928122444.15409.10498.stgit@canyon>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Make it possible to free a freelist with several objects by extending
__slab_free() and slab_free() with two arguments: a freelist_head
pointer and objects counter (cnt).  If freelist_head pointer is set,
then the object is the freelist tail pointer.

This allows a freelist with several objects (all within the same
slub-page) to be free'ed using a single locked cmpxchg_double in
__slab_free() and with an unlocked cmpxchg_double in slab_free().

Object debugging on the free path is also extended to handle these
freelists.  When CONFIG_SLUB_DEBUG is enabled it will also detect if
objects don't belong to the same slub-page.

These changes are needed for the next patch to bulk free the detached
freelists it introduces and constructs.

Micro benchmarking showed no performance reduction due to this change,
when debugging is turned off (compiled with CONFIG_SLUB_DEBUG).

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 mm/slub.c |   97 +++++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 84 insertions(+), 13 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 1cf98d89546d..13b5f53e4840 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -675,11 +675,18 @@ static void init_object(struct kmem_cache *s, void *object, u8 val)
 {
 	u8 *p = object;
 
+	/* Freepointer not overwritten as SLAB_POISON moved it after object */
 	if (s->flags & __OBJECT_POISON) {
 		memset(p, POISON_FREE, s->object_size - 1);
 		p[s->object_size - 1] = POISON_END;
 	}
 
+	/*
+	 * If both SLAB_RED_ZONE and SLAB_POISON are enabled, then
+	 * freepointer is still safe, as then s->offset equals
+	 * s->inuse and below redzone is after s->object_size and only
+	 * area between s->object_size and s->inuse.
+	 */
 	if (s->flags & SLAB_RED_ZONE)
 		memset(p + s->object_size, val, s->inuse - s->object_size);
 }
@@ -1063,18 +1070,32 @@ bad:
 	return 0;
 }
 
+/* Supports checking bulk free of a constructed freelist */
 static noinline struct kmem_cache_node *free_debug_processing(
-	struct kmem_cache *s, struct page *page, void *object,
+	struct kmem_cache *s, struct page *page,
+	void *obj_tail, void *freelist_head, int bulk_cnt,
 	unsigned long addr, unsigned long *flags)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
+	void *object;
+	int cnt = 0;
 
 	spin_lock_irqsave(&n->list_lock, *flags);
 	slab_lock(page);
 
+	/*
+	 * Bulk free of a constructed freelist is indicated by the
+	 * freelist_head pointer being set, else obj_tail is object
+	 * being free'ed
+	 */
+	object = freelist_head ? : obj_tail;
+
 	if (!check_slab(s, page))
 		goto fail;
 
+next_object:
+	cnt++;
+
 	if (!check_valid_pointer(s, page, object)) {
 		slab_err(s, page, "Invalid object pointer 0x%p", object);
 		goto fail;
@@ -1105,8 +1126,19 @@ static noinline struct kmem_cache_node *free_debug_processing(
 	if (s->flags & SLAB_STORE_USER)
 		set_track(s, object, TRACK_FREE, addr);
 	trace(s, page, object, 0);
+	/* Freepointer not overwritten by init_object(), SLAB_POISON moved it */
 	init_object(s, object, SLUB_RED_INACTIVE);
+
+	/* Reached end of constructed freelist yet? */
+	if (object != obj_tail) {
+		object = get_freepointer(s, object);
+		goto next_object;
+	}
 out:
+	if (cnt != bulk_cnt)
+		slab_err(s, page, "Bulk freelist count(%d) invalid(%d)\n",
+			 bulk_cnt, cnt);
+
 	slab_unlock(page);
 	/*
 	 * Keep node_lock to preserve integrity
@@ -1210,7 +1242,8 @@ static inline int alloc_debug_processing(struct kmem_cache *s,
 	struct page *page, void *object, unsigned long addr) { return 0; }
 
 static inline struct kmem_cache_node *free_debug_processing(
-	struct kmem_cache *s, struct page *page, void *object,
+	struct kmem_cache *s, struct page *page,
+	void *obj_tail, void *freelist_head, int bulk_cnt,
 	unsigned long addr, unsigned long *flags) { return NULL; }
 
 static inline int slab_pad_check(struct kmem_cache *s, struct page *page)
@@ -1306,6 +1339,35 @@ static inline void slab_free_hook(struct kmem_cache *s, void *x)
 	kasan_slab_free(s, x);
 }
 
+/* Compiler cannot detect that slab_free_freelist_hook() can be
+ * removed if slab_free_hook() evaluates to nothing.  Thus, we need to
+ * catch all relevant config debug options here.
+ */
+#if defined(CONFIG_KMEMCHECK) ||		\
+	defined(CONFIG_LOCKDEP)	||		\
+	defined(CONFIG_DEBUG_KMEMLEAK) ||	\
+	defined(CONFIG_DEBUG_OBJECTS_FREE) ||	\
+	defined(CONFIG_KASAN)
+static inline void slab_free_freelist_hook(struct kmem_cache *s, void *obj_tail,
+					   void *freelist_head)
+{
+	/*
+	 * Bulk free of a constructed freelist is indicated by the
+	 * freelist_head pointer being set, else obj_tail is object
+	 * being free'ed
+	 */
+	void *object = freelist_head ? : obj_tail;
+
+	do {
+		slab_free_hook(s, object);
+	} while ((object != obj_tail) &&
+		 (object = get_freepointer(s, object)));
+}
+#else
+static inline void slab_free_freelist_hook(struct kmem_cache *s, void *obj_tail,
+					   void *freelist_head) {}
+#endif
+
 static void setup_object(struct kmem_cache *s, struct page *page,
 				void *object)
 {
@@ -2584,9 +2646,14 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
  * So we still attempt to reduce cache line usage. Just take the slab
  * lock and free the item. If there is no additional partial page
  * handling required then we can return immediately.
+ *
+ * Bulk free of a freelist with several objects (all pointing to the
+ * same page) possible by specifying freelist_head ptr and object as
+ * tail ptr, plus objects count (cnt).
  */
 static void __slab_free(struct kmem_cache *s, struct page *page,
-			void *x, unsigned long addr)
+			void *x, unsigned long addr,
+			void *freelist_head, int cnt)
 {
 	void *prior;
 	void **object = (void *)x;
@@ -2595,11 +2662,13 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	unsigned long counters;
 	struct kmem_cache_node *n = NULL;
 	unsigned long uninitialized_var(flags);
+	void *new_freelist = freelist_head ? : x;
 
 	stat(s, FREE_SLOWPATH);
 
 	if (kmem_cache_debug(s) &&
-		!(n = free_debug_processing(s, page, x, addr, &flags)))
+	    !(n = free_debug_processing(s, page, x, freelist_head, cnt,
+					addr, &flags)))
 		return;
 
 	do {
@@ -2612,7 +2681,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		set_freepointer(s, object, prior);
 		new.counters = counters;
 		was_frozen = new.frozen;
-		new.inuse--;
+		new.inuse -= cnt;
 		if ((!new.inuse || !prior) && !was_frozen) {
 
 			if (kmem_cache_has_cpu_partial(s) && !prior) {
@@ -2643,7 +2712,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 	} while (!cmpxchg_double_slab(s, page,
 		prior, counters,
-		object, new.counters,
+		new_freelist, new.counters,
 		"__slab_free"));
 
 	if (likely(!n)) {
@@ -2710,13 +2779,15 @@ slab_empty:
  * with all sorts of special processing.
  */
 static __always_inline void slab_free(struct kmem_cache *s,
-			struct page *page, void *x, unsigned long addr)
+			struct page *page, void *x, unsigned long addr,
+			void *freelist_head, int cnt)
 {
 	void **object = (void *)x;
+	void *new_freelist = freelist_head ? : x;
 	struct kmem_cache_cpu *c;
 	unsigned long tid;
 
-	slab_free_hook(s, x);
+	slab_free_freelist_hook(s, x, freelist_head);
 
 redo:
 	/*
@@ -2740,14 +2811,14 @@ redo:
 		if (unlikely(!this_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
 				c->freelist, tid,
-				object, next_tid(tid)))) {
+				new_freelist, next_tid(tid)))) {
 
 			note_cmpxchg_failure("slab_free", s, tid);
 			goto redo;
 		}
 		stat(s, FREE_FASTPATH);
 	} else
-		__slab_free(s, page, x, addr);
+		__slab_free(s, page, x, addr, freelist_head, cnt);
 
 }
 
@@ -2756,7 +2827,7 @@ void kmem_cache_free(struct kmem_cache *s, void *x)
 	s = cache_from_obj(s, x);
 	if (!s)
 		return;
-	slab_free(s, virt_to_head_page(x), x, _RET_IP_);
+	slab_free(s, virt_to_head_page(x), x, _RET_IP_, NULL, 1);
 	trace_kmem_cache_free(_RET_IP_, x);
 }
 EXPORT_SYMBOL(kmem_cache_free);
@@ -2791,7 +2862,7 @@ void kmem_cache_free_bulk(struct kmem_cache *s, size_t size, void **p)
 			c->tid = next_tid(c->tid);
 			local_irq_enable();
 			/* Slowpath: overhead locked cmpxchg_double_slab */
-			__slab_free(s, page, object, _RET_IP_);
+			__slab_free(s, page, object, _RET_IP_, NULL, 1);
 			local_irq_disable();
 			c = this_cpu_ptr(s->cpu_slab);
 		}
@@ -3531,7 +3602,7 @@ void kfree(const void *x)
 		__free_kmem_pages(page, compound_order(page));
 		return;
 	}
-	slab_free(page->slab_cache, page, object, _RET_IP_);
+	slab_free(page->slab_cache, page, object, _RET_IP_, NULL, 1);
 }
 EXPORT_SYMBOL(kfree);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
