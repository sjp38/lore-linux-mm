Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA426B0254
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 20:15:24 -0500 (EST)
Received: by mail-qg0-f43.google.com with SMTP id 6so123259591qgy.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 17:15:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x137si27553432qhx.22.2016.01.25.17.15.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 17:15:23 -0800 (PST)
From: Laura Abbott <labbott@fedoraproject.org>
Subject: [RFC][PATCH 2/3] slub: Don't limit debugging to slow paths
Date: Mon, 25 Jan 2016 17:15:12 -0800
Message-Id: <1453770913-32287-3-git-send-email-labbott@fedoraproject.org>
In-Reply-To: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
References: <1453770913-32287-1-git-send-email-labbott@fedoraproject.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>


Currently, when slabs are marked with debug options, the allocation
path will skip using CPU slabs. This has a definite performance
impact. Add an option to allow debugging to happen on the fast path.

Signed-off-by: Laura Abbott <labbott@fedoraproject.org>
---
 init/Kconfig |  12 +++++
 mm/slub.c    | 164 +++++++++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 161 insertions(+), 15 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 2232080..6d807e7 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1674,6 +1674,18 @@ config SLUB_DEBUG
 	  SLUB sysfs support. /sys/slab will not exist and there will be
 	  no support for cache validation etc.
 
+config SLUB_DEBUG_FASTPATH
+	bool "Allow SLUB debugging to utilize the fastpath"
+	depends on SLUB_DEBUG
+	help
+	  SLUB_DEBUG forces all allocations to utilize the slow path which
+	  is a performance penalty. Turning on this option lets the debugging
+	  use the fast path. This helps the performance when debugging
+	  features are turned on. If you aren't planning on utilizing any
+	  of the SLUB_DEBUG features, you should say N here.
+
+	  If unsure, say N
+
 config COMPAT_BRK
 	bool "Disable heap randomization"
 	default y
diff --git a/mm/slub.c b/mm/slub.c
index 6ddba32..a47e615 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -898,9 +898,10 @@ static int check_slab(struct kmem_cache *s, struct page *page)
  * Determine if a certain object on a page is on the freelist. Must hold the
  * slab lock to guarantee that the chains are in a consistent state.
  */
-static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
+static int on_freelist(struct kmem_cache *s, struct page *page, void *search,
+			void *cpu_freelist)
 {
-	int nr = 0;
+	int nr = 0, cpu_nr = 0;
 	void *fp;
 	void *object = NULL;
 	int max_objects;
@@ -928,6 +929,29 @@ static int on_freelist(struct kmem_cache *s, struct page *page, void *search)
 		nr++;
 	}
 
+	fp = cpu_freelist;
+	while (fp && cpu_nr <= page->objects) {
+		if (fp == search)
+			return 1;
+		if (!check_valid_pointer(s, page, fp)) {
+			if (object) {
+				object_err(s, page, object,
+					"Freechain corrupt");
+				set_freepointer(s, object, NULL);
+			} else {
+				slab_err(s, page, "Freepointer corrupt");
+				page->freelist = NULL;
+				page->inuse = page->objects;
+				slab_fix(s, "Freelist cleared");
+				return 0;
+			}
+			break;
+		}
+		object = fp;
+		fp = get_freepointer(s, object);
+		cpu_nr++;
+	}
+
 	max_objects = order_objects(compound_order(page), s->size, s->reserved);
 	if (max_objects > MAX_OBJS_PER_PAGE)
 		max_objects = MAX_OBJS_PER_PAGE;
@@ -1034,6 +1058,7 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
 	init_tracking(s, object);
 }
 
+/* Must be not be called when migration can happen */
 static noinline int alloc_debug_processing(struct kmem_cache *s,
 					struct page *page,
 					void *object, unsigned long addr)
@@ -1070,10 +1095,51 @@ bad:
 	return 0;
 }
 
+#ifdef SLUB_DEBUG_FASTPATH
+static noinline int alloc_debug_processing_fastpath(struct kmem_cache *s,
+					struct kmem_cache_cpu *c,
+					struct page *page,
+					void *object, unsigned long tid,
+					unsigned long addr)
+{
+	unsigned long flags;
+	int ret = 0;
+
+	preempt_disable();
+	local_irq_save(flags);
+
+	/*
+	 * We've now disabled preemption and IRQs but we still need
+	 * to check that this is the right CPU
+	 */
+	if (!this_cpu_cmpxchg_double(s->cpu_slab->freelist, s->cpu_slab->tid,
+				c->freelist, tid,
+				c->freelist, tid))
+		goto out;
+
+	ret = alloc_debug_processing(s, page, object, addr);
+
+out:
+	local_irq_restore(flags);
+	preempt_enable();
+	return ret;
+}
+#else
+static noinline int alloc_debug_processing_fastpath(struct kmem_cache *s,
+					struct kmem_cache_cpu *c,
+					struct page *page,
+					void *object, unsigned long tid,
+					unsigned long addr)
+{
+	return 1;
+}
+#endif
+
 /* Supports checking bulk free of a constructed freelist */
 static noinline int free_debug_processing(
 	struct kmem_cache *s, struct page *page,
 	void *head, void *tail, int bulk_cnt,
+	void *cpu_freelist,
 	unsigned long addr)
 {
 	struct kmem_cache_node *n = get_node(s, page_to_nid(page));
@@ -1095,7 +1161,7 @@ next_object:
 		goto fail;
 	}
 
-	if (on_freelist(s, page, object)) {
+	if (on_freelist(s, page, object, cpu_freelist)) {
 		object_err(s, page, object, "Object already free");
 		goto fail;
 	}
@@ -1144,6 +1210,53 @@ fail:
 	return 0;
 }
 
+#ifdef CONFIG_SLUB_DEBUG_FASTPATH
+static noinline int free_debug_processing_fastpath(
+	struct kmem_cache *s,
+	struct kmem_cache_cpu *c,
+	struct page *page,
+	void *head, void *tail, int bulk_cnt,
+	unsigned long tid,
+	unsigned long addr)
+{
+	int ret = 0;
+	unsigned long flags;
+
+	preempt_disable();
+	local_irq_save(flags);
+
+	/*
+	 * We've now disabled preemption and IRQs but we still need
+	 * to check that this is the right CPU
+	 */
+	if (!this_cpu_cmpxchg_double(s->cpu_slab->freelist, s->cpu_slab->tid,
+				c->freelist, tid,
+				c->freelist, tid))
+		goto out;
+
+
+	ret = free_debug_processing(s, page, head, tail, bulk_cnt,
+				c->freelist, addr);
+
+out:
+	local_irq_restore(flags);
+	preempt_enable();
+	return ret;
+}
+#else
+static inline int free_debug_processing_fastpath(
+	struct kmem_cache *s,
+	struct kmem_cache_cpu *c,
+	struct page *page,
+	void *head, void *tail, int bulk_cnt,
+	unsigned long tid,
+	unsigned long addr)
+{
+	return 1;
+}
+#endif
+
+
 static int __init setup_slub_debug(char *str)
 {
 	slub_debug = DEBUG_DEFAULT_FLAGS;
@@ -1234,8 +1347,8 @@ static inline int alloc_debug_processing(struct kmem_cache *s,
 
 static inline int free_debug_processing(
 	struct kmem_cache *s, struct page *page,
-	void *head, void *tail, int bulk_cnt,
-	unsigned long addr, unsigned long *flags) { return NULL; }
+	void *head, void *tail, int bulk_cnt, void *cpu_freelist,
+	unsigned long addr, unsigned long *flags) { return 0; }
 
 static inline int slab_pad_check(struct kmem_cache *s, struct page *page)
 			{ return 1; }
@@ -2352,7 +2465,8 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
  * already disabled (which is the case for bulk allocation).
  */
 static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
-			  unsigned long addr, struct kmem_cache_cpu *c)
+			  unsigned long addr, struct kmem_cache_cpu *c,
+			  bool debug_fail)
 {
 	void *freelist;
 	struct page *page;
@@ -2382,7 +2496,7 @@ redo:
 	 * PFMEMALLOC but right now, we are losing the pfmemalloc
 	 * information when the page leaves the per-cpu allocator
 	 */
-	if (unlikely(!pfmemalloc_match(page, gfpflags))) {
+	if (unlikely(debug_fail || !pfmemalloc_match(page, gfpflags))) {
 		deactivate_slab(s, page, c->freelist);
 		c->page = NULL;
 		c->freelist = NULL;
@@ -2433,7 +2547,9 @@ new_slab:
 	}
 
 	page = c->page;
-	if (likely(!kmem_cache_debug(s) && pfmemalloc_match(page, gfpflags)))
+
+	if (!IS_ENABLED(CONFIG_SLUB_DEBUG_FASTPATH) &&
+	    likely(!kmem_cache_debug(s) && pfmemalloc_match(page, gfpflags)))
 		goto load_freelist;
 
 	/* Only entered in the debug case */
@@ -2441,6 +2557,10 @@ new_slab:
 			!alloc_debug_processing(s, page, freelist, addr))
 		goto new_slab;	/* Slab failed checks. Next slab needed */
 
+	if (IS_ENABLED(CONFIG_SLUB_DEBUG_FASTPATH) &&
+	    likely(pfmemalloc_match(page, gfpflags)))
+		goto load_freelist;
+
 	deactivate_slab(s, page, get_freepointer(s, freelist));
 	c->page = NULL;
 	c->freelist = NULL;
@@ -2452,7 +2572,8 @@ new_slab:
  * cpu changes by refetching the per cpu area pointer.
  */
 static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
-			  unsigned long addr, struct kmem_cache_cpu *c)
+			  unsigned long addr, struct kmem_cache_cpu *c,
+			  bool debug_fail)
 {
 	void *p;
 	unsigned long flags;
@@ -2467,7 +2588,7 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 	c = this_cpu_ptr(s->cpu_slab);
 #endif
 
-	p = ___slab_alloc(s, gfpflags, node, addr, c);
+	p = ___slab_alloc(s, gfpflags, node, addr, c, debug_fail);
 	local_irq_restore(flags);
 	return p;
 }
@@ -2489,6 +2610,7 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 	struct kmem_cache_cpu *c;
 	struct page *page;
 	unsigned long tid;
+	bool debug_fail = false;
 
 	s = slab_pre_alloc_hook(s, gfpflags);
 	if (!s)
@@ -2529,12 +2651,18 @@ redo:
 
 	object = c->freelist;
 	page = c->page;
-	if (unlikely(!object || !node_match(page, node))) {
-		object = __slab_alloc(s, gfpflags, node, addr, c);
+	if (unlikely(debug_fail || !object || !node_match(page, node))) {
+		object = __slab_alloc(s, gfpflags, node, addr, c, debug_fail);
 		stat(s, ALLOC_SLOWPATH);
 	} else {
 		void *next_object = get_freepointer_safe(s, object);
 
+
+		if (kmem_cache_debug(s) && !alloc_debug_processing_fastpath(s, c, page, object, tid, addr)) {
+			debug_fail = true;
+			goto redo;
+		}
+
 		/*
 		 * The cmpxchg will only match if there was no additional
 		 * operation and if we are on the right processor.
@@ -2557,6 +2685,7 @@ redo:
 			note_cmpxchg_failure("slab_alloc", s, tid);
 			goto redo;
 		}
+
 		prefetch_freepointer(s, next_object);
 		stat(s, ALLOC_FASTPATH);
 	}
@@ -2649,9 +2778,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 	stat(s, FREE_SLOWPATH);
 
 	if (kmem_cache_debug(s) &&
-	    !free_debug_processing(s, page, head, tail, cnt, addr))
+	    !free_debug_processing(s, page, head, tail, cnt, NULL, addr))
 		return;
 
+
 	do {
 		if (unlikely(n)) {
 			spin_unlock_irqrestore(&n->list_lock, flags);
@@ -2790,6 +2920,10 @@ redo:
 	barrier();
 
 	if (likely(page == c->page)) {
+		if (kmem_cache_debug(s) &&
+		    !free_debug_processing_fastpath(s, c, page, head, tail_obj, cnt, tid, addr))
+			return;
+
 		set_freepointer(s, tail_obj, c->freelist);
 
 		if (unlikely(!this_cpu_cmpxchg_double(
@@ -2938,7 +3072,7 @@ int kmem_cache_alloc_bulk(struct kmem_cache *s, gfp_t flags, size_t size,
 			 * of re-populating per CPU c->freelist
 			 */
 			p[i] = ___slab_alloc(s, flags, NUMA_NO_NODE,
-					    _RET_IP_, c);
+					    _RET_IP_, c, false);
 			if (unlikely(!p[i]))
 				goto error;
 
@@ -4094,7 +4228,7 @@ static int validate_slab(struct kmem_cache *s, struct page *page,
 	void *addr = page_address(page);
 
 	if (!check_slab(s, page) ||
-			!on_freelist(s, page, NULL))
+			!on_freelist(s, page, NULL, NULL))
 		return 0;
 
 	/* Now we know that a valid freelist exists */
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
