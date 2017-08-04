Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C20728040C
	for <linux-mm@kvack.org>; Fri,  4 Aug 2017 19:11:20 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g13so14903251qta.0
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 16:11:20 -0700 (PDT)
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com. [209.85.220.175])
        by mx.google.com with ESMTPS id w62si2535261qtd.27.2017.08.04.16.11.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Aug 2017 16:11:19 -0700 (PDT)
Received: by mail-qk0-f175.google.com with SMTP id d136so16905690qkg.3
        for <linux-mm@kvack.org>; Fri, 04 Aug 2017 16:11:19 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC][PATCH] mm/slub.c: Allow poisoning to use the fast path
Date: Fri,  4 Aug 2017 16:10:02 -0700
Message-Id: <20170804231002.20362-1-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>

All slub debug features currently disable the fast path completely.
Some features such as consistency checks require this to allow taking of
locks. Poisoning and red zoning don't require this and can safely use
the per-cpu fast path. Introduce a Kconfig to continue to use the fast
path when 'fast' debugging options are enabled. The code will
automatically revert to always using the slow path when 'slow' options
are enabled.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
This is a follow up from my previous proposal to add an alternate per-cpu
list. The feedback was just add to the fast path. With this version, the
hackbench penalty with slub_debug=P is only 3%. hackbench is too noisy to give
an idea of the change with just slub_debug=- so I looked at some of the bulk
allocation benchmarks from https://github.com/netoptimizer/prototype-kernel .
With slab_bulk_test01, the penalty was between 4-7 cycles even with
slub_debug=-.
---
 init/Kconfig | 10 ++++++++++
 mm/slub.c    | 50 +++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 55 insertions(+), 5 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 8514b25db21c..aef7cc2bf275 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1582,6 +1582,16 @@ config SLUB_CPU_PARTIAL
 	  which requires the taking of locks that may cause latency spikes.
 	  Typically one would choose no for a realtime system.
 
+config SLUB_FAST_POISON
+	bool "Allow poisoning debug options to use the fast path"
+	depends on SLUB_CPU_PARTIAL
+	help
+	   Some SLUB debugging options are safe to use without taking extra
+	   locks and can use the per-cpu lists. Enable this option to let
+	   poisoning and red zoning use the per-cpu lists. The trade-off is
+	   a few extra checks in the fast path. You should select this option
+	   if you intend to use poisoning for non-debugging uses.
+
 config MMAP_ALLOW_UNINITIALIZED
 	bool "Allow mmapped anonymous memory to be uninitialized"
 	depends on EXPERT && !MMU
diff --git a/mm/slub.c b/mm/slub.c
index 1d3f9835f4ea..a296693ce907 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -124,6 +124,18 @@ static inline int kmem_cache_debug(struct kmem_cache *s)
 #endif
 }
 
+#define SLAB_SLOW_FLAGS (SLAB_CONSISTENCY_CHECKS | SLAB_STORE_USER | \
+				SLAB_TRACE)
+
+static inline int kmem_cache_slow_debug(struct kmem_cache *s)
+{
+#if defined(CONFIG_SLUB_FAST_POISON)
+	return s->flags & SLAB_SLOW_FLAGS;
+#else
+	return kmem_cache_debug(s);
+#endif
+}
+
 void *fixup_red_left(struct kmem_cache *s, void *p)
 {
 	if (kmem_cache_debug(s) && s->flags & SLAB_RED_ZONE)
@@ -134,7 +146,9 @@ void *fixup_red_left(struct kmem_cache *s, void *p)
 
 static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 {
-#ifdef CONFIG_SLUB_CPU_PARTIAL
+#if defined(CONFIG_SLUB_FAST_POISON)
+	return !kmem_cache_slow_debug(s);
+#elif defined(CONFIG_SLUB_CPU_PARTIAL)
 	return !kmem_cache_debug(s);
 #else
 	return false;
@@ -2083,7 +2097,7 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 		}
 	} else {
 		m = M_FULL;
-		if (kmem_cache_debug(s) && !lock) {
+		if (kmem_cache_slow_debug(s) && !lock) {
 			lock = 1;
 			/*
 			 * This also ensures that the scanning of full
@@ -2580,11 +2594,11 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 	}
 
 	page = c->page;
-	if (likely(!kmem_cache_debug(s) && pfmemalloc_match(page, gfpflags)))
+	if (likely(!kmem_cache_slow_debug(s) && pfmemalloc_match(page, gfpflags)))
 		goto load_freelist;
 
 	/* Only entered in the debug case */
-	if (kmem_cache_debug(s) &&
+	if (kmem_cache_slow_debug(s) &&
 			!alloc_debug_processing(s, page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
@@ -2617,6 +2631,12 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 	return p;
 }
 
+static inline void alloc_sanitize(struct kmem_cache *s, void *object)
+{
+#ifdef CONFIG_SLUB_FAST_POISON
+	init_object(s, object, SLUB_RED_ACTIVE);
+#endif
+}
 /*
  * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
  * have the fastpath folded into their functions. So no function call
@@ -2706,6 +2726,8 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 		stat(s, ALLOC_FASTPATH);
 	}
 
+	if (kmem_cache_debug(s))
+		alloc_sanitize(s, object);
 	if (unlikely(gfpflags & __GFP_ZERO) && object)
 		memset(object, 0, s->object_size);
 
@@ -2793,7 +2815,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 	stat(s, FREE_SLOWPATH);
 
-	if (kmem_cache_debug(s) &&
+	if (kmem_cache_slow_debug(s) &&
 	    !free_debug_processing(s, page, head, tail, cnt, addr))
 		return;
 
@@ -2908,6 +2930,21 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
  * same page) possible by specifying head and tail ptr, plus objects
  * count (cnt). Bulk free indicated by tail pointer being set.
  */
+
+static inline void free_sanitize(struct kmem_cache *s, struct page *page, void *head, void *tail)
+{
+#ifdef CONFIG_SLUB_FAST_POISON
+	void *object = head;
+
+next_object:
+	init_object(s, object, SLUB_RED_INACTIVE);
+	if (object != tail) {
+		object = get_freepointer(s, object);
+		goto next_object;
+	}
+#endif
+}
+
 static __always_inline void do_slab_free(struct kmem_cache *s,
 				struct page *page, void *head, void *tail,
 				int cnt, unsigned long addr)
@@ -2931,6 +2968,9 @@ static __always_inline void do_slab_free(struct kmem_cache *s,
 	/* Same with comment on barrier() in slab_alloc_node() */
 	barrier();
 
+	if (kmem_cache_debug(s))
+		free_sanitize(s, page, head, tail_obj);
+
 	if (likely(page == c->page)) {
 		set_freepointer(s, tail_obj, c->freelist);
 
-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
