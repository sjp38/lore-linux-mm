Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 476AD6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 19:53:13 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v20so5641897qtg.3
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 16:53:13 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k3sor3640304qkl.17.2017.06.08.16.53.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Jun 2017 16:53:11 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [RFC][PATCH] slub: Introduce 'alternate' per cpu partial lists
Date: Thu,  8 Jun 2017 16:53:04 -0700
Message-Id: <1496965984-21962-1-git-send-email-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Laura Abbott <labbott@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

SLUB debugging features (poisoning, red zoning etc.) skip the fast path
completely. This ensures there is a single place to do all checks and
take any locks that may be necessary for debugging. The overhead of some
of the debugging features (e.g. poisoning) ends up being comparatively
small vs the overhead of not using the fast path.

We don't want to impose any kind of overhead on the fast path so
introduce the notion of an alternate fast path. This is essentially the
same idea as the existing fast path (store partially used pages on the
per-cpu list) but it happens after the real fast path. Debugging that
doesn't require locks (poisoning/red zoning) can happen on this path to
avoid the penalty of always needing to go for the slow path.

Signed-off-by: Laura Abbott <labbott@redhat.com>
---
This is a follow up to my previous proposal to speed up slub_debug=P
https://marc.info/?l=linux-mm&m=145920558822958&w=2 . The current approach
is hopelessly slow and can't really be used outside of limited debugging.
The goal is to make slub_debug=P more usable for general use.

Joonsoo Kim pointed out that my previous attempt still wouldn't scale
as it still involved taking the list_lock for every allocation. He suggested
adding per-cpu support, as did Christoph Lameter in a separate thread. This
proposal adds a separate per-cpu list for use when poisoning is enabled.
For this version, I'm mostly looking for general feedback about how reasonable
this approach is before trying to clean it up more.

- Some of this code is redundant and can probably be combined.
- The fast path is very sensitive and it was suggested I leave it alone. The
approach I took means the fastpath cmpxchg always fails before trying the
alternate cmpxchg. From some of my profiling, the cmpxchg seemed to be fairly
expensive.
- The flow for ___slab_free is ugly and should really be reworked.
- The poisoning is now scattered around in a few places. Ideally there would
be a single path for this to happen. If the fast path free fails we end up
doing an extra initialization of the object.
- I don't care about the name, feel free to suggest something better.

For some performance numbers, I used hackbench -g 20 -l 1000.
There does not seem to be an impact with slub_debug=- with this series.
For slub_debug=P, I get ~2 second drop with a UP system and almost a 10 second
drop with a 4 core system as run with QEMU.
---
 include/linux/slub_def.h |   8 ++
 mm/slub.c                | 263 ++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 244 insertions(+), 27 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 07ef550..d582101 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -10,8 +10,10 @@
 
 enum stat_item {
 	ALLOC_FASTPATH,		/* Allocation from cpu slab */
+	ALLOC_ALT_FASTPATH,	/* Allocation from alternate cpu slab */
 	ALLOC_SLOWPATH,		/* Allocation by getting a new cpu slab */
 	FREE_FASTPATH,		/* Free to cpu slab */
+	FREE_ALT_FASTPATH,	/* Free to alternate cpu slab */
 	FREE_SLOWPATH,		/* Freeing not to cpu slab */
 	FREE_FROZEN,		/* Freeing to frozen slab */
 	FREE_ADD_PARTIAL,	/* Freeing moves slab to partial list */
@@ -42,6 +44,12 @@ struct kmem_cache_cpu {
 	unsigned long tid;	/* Globally unique transaction id */
 	struct page *page;	/* The slab from which we are allocating */
 	struct page *partial;	/* Partially allocated frozen slabs */
+	/*
+	 * The following fields have identical uses to those above */
+	void **alt_freelist;
+	unsigned long alt_tid;
+	struct page *alt_partial;
+	struct page *alt_page;
 #ifdef CONFIG_SLUB_STATS
 	unsigned stat[NR_SLUB_STAT_ITEMS];
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index 7449593..b1fc4c6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -132,10 +132,24 @@ void *fixup_red_left(struct kmem_cache *s, void *p)
 	return p;
 }
 
+#define SLAB_NO_PARTIAL (SLAB_CONSISTENCY_CHECKS | SLAB_STORE_USER | \
+                               SLAB_TRACE)
+
+
+static inline bool kmem_cache_use_alt_partial(struct kmem_cache *s)
+{
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+	return s->flags & (SLAB_RED_ZONE | SLAB_POISON) &&
+		!(s->flags & SLAB_NO_PARTIAL);
+#else
+	return false;
+#endif
+}
+
 static inline bool kmem_cache_has_cpu_partial(struct kmem_cache *s)
 {
 #ifdef CONFIG_SLUB_CPU_PARTIAL
-	return !kmem_cache_debug(s);
+	return !(s->flags & SLAB_NO_PARTIAL);
 #else
 	return false;
 #endif
@@ -1786,6 +1800,7 @@ static inline void *acquire_slab(struct kmem_cache *s,
 }
 
 static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain);
+static void put_cpu_partial_alt(struct kmem_cache *s, struct page *page, int drain);
 static inline bool pfmemalloc_match(struct page *page, gfp_t gfpflags);
 
 /*
@@ -1821,11 +1836,17 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 
 		available += objects;
 		if (!object) {
-			c->page = page;
+			if (kmem_cache_use_alt_partial(s))
+				c->alt_page = page;
+			else
+				c->page = page;
 			stat(s, ALLOC_FROM_PARTIAL);
 			object = t;
 		} else {
-			put_cpu_partial(s, page, 0);
+			if (kmem_cache_use_alt_partial(s))
+				put_cpu_partial_alt(s, page, 0);
+			else
+				put_cpu_partial(s, page, 0);
 			stat(s, CPU_PARTIAL_NODE);
 		}
 		if (!kmem_cache_has_cpu_partial(s)
@@ -2147,12 +2168,16 @@ static void unfreeze_partials(struct kmem_cache *s,
 #ifdef CONFIG_SLUB_CPU_PARTIAL
 	struct kmem_cache_node *n = NULL, *n2 = NULL;
 	struct page *page, *discard_page = NULL;
+	bool alt = kmem_cache_use_alt_partial(s);
 
-	while ((page = c->partial)) {
+	while ((page = alt ? c->alt_partial : c->partial)) {
 		struct page new;
 		struct page old;
 
-		c->partial = page->next;
+		if (alt)
+			c->alt_partial = page->next;
+		else
+			c->partial = page->next;
 
 		n2 = get_node(s, page_to_nid(page));
 		if (n != n2) {
@@ -2263,6 +2288,58 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
 #endif
 }
 
+static void put_cpu_partial_alt(struct kmem_cache *s, struct page *page, int drain)
+{
+#ifdef CONFIG_SLUB_CPU_PARTIAL
+	struct page *oldpage;
+	int pages;
+	int pobjects;
+
+	preempt_disable();
+	do {
+		pages = 0;
+		pobjects = 0;
+		oldpage = this_cpu_read(s->cpu_slab->alt_partial);
+
+		if (oldpage) {
+			pobjects = oldpage->pobjects;
+			pages = oldpage->pages;
+			if (drain && pobjects > s->cpu_partial) {
+				unsigned long flags;
+				/*
+				 * partial array is full. Move the existing
+				 * set to the per node partial list.
+				 */
+				local_irq_save(flags);
+				unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
+				local_irq_restore(flags);
+				oldpage = NULL;
+				pobjects = 0;
+				pages = 0;
+				stat(s, CPU_PARTIAL_DRAIN);
+			}
+		}
+
+		pages++;
+		pobjects += page->objects - page->inuse;
+
+		page->pages = pages;
+		page->pobjects = pobjects;
+		page->next = oldpage;
+
+	} while (this_cpu_cmpxchg(s->cpu_slab->alt_partial, oldpage, page)
+								!= oldpage);
+	if (unlikely(!s->cpu_partial)) {
+		unsigned long flags;
+
+		local_irq_save(flags);
+		unfreeze_partials(s, this_cpu_ptr(s->cpu_slab));
+		local_irq_restore(flags);
+	}
+	preempt_enable();
+#endif
+}
+
 static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 {
 	stat(s, CPUSLAB_FLUSH);
@@ -2273,6 +2350,16 @@ static inline void flush_slab(struct kmem_cache *s, struct kmem_cache_cpu *c)
 	c->freelist = NULL;
 }
 
+static inline void flush_slab_alt(struct kmem_cache *s, struct kmem_cache_cpu *c)
+{
+	stat(s, CPUSLAB_FLUSH);
+	deactivate_slab(s, c->alt_page, c->alt_freelist);
+
+	c->alt_tid = next_tid(c->alt_tid);
+	c->alt_page = NULL;
+	c->alt_freelist = NULL;
+}
+
 /*
  * Flush cpu slab.
  *
@@ -2285,6 +2372,8 @@ static inline void __flush_cpu_slab(struct kmem_cache *s, int cpu)
 	if (likely(c)) {
 		if (c->page)
 			flush_slab(s, c);
+		if (c->alt_page)
+			flush_slab_alt(s, c);
 
 		unfreeze_partials(s, c);
 	}
@@ -2302,7 +2391,7 @@ static bool has_cpu_slab(int cpu, void *info)
 	struct kmem_cache *s = info;
 	struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab, cpu);
 
-	return c->page || c->partial;
+	return c->page || c->partial || c->alt_page || c->alt_partial;
 }
 
 static void flush_all(struct kmem_cache *s)
@@ -2425,6 +2514,8 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 		if (c->page)
 			flush_slab(s, c);
 
+		if (c->alt_page)
+			flush_slab_alt(s, c);
 		/*
 		 * No other reference to the page yet so we can
 		 * muck around with it freely without cmpxchg
@@ -2433,7 +2524,10 @@ static inline void *new_slab_objects(struct kmem_cache *s, gfp_t flags,
 		page->freelist = NULL;
 
 		stat(s, ALLOC_SLAB);
-		c->page = page;
+		if (kmem_cache_use_alt_partial(s))
+			c->alt_page = page;
+		else
+			c->page = page;
 		*pc = c;
 	} else
 		freelist = NULL;
@@ -2507,10 +2601,14 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 {
 	void *freelist;
 	struct page *page;
+	bool alt = kmem_cache_use_alt_partial(s);
 
 	page = c->page;
-	if (!page)
-		goto new_slab;
+	if (!page) {
+		page = c->alt_page;
+		if (!page)
+			goto new_slab;
+	}
 redo:
 
 	if (unlikely(!node_match(page, node))) {
@@ -2541,14 +2639,18 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 	}
 
 	/* must check again c->freelist in case of cpu migration or IRQ */
-	freelist = c->freelist;
+	freelist = alt ? c->alt_freelist : c->freelist;
 	if (freelist)
 		goto load_freelist;
 
 	freelist = get_freelist(s, page);
 
+
 	if (!freelist) {
-		c->page = NULL;
+		if (alt)
+			c->alt_page = NULL;
+		else
+			c->page = NULL;
 		stat(s, DEACTIVATE_BYPASS);
 		goto new_slab;
 	}
@@ -2561,9 +2663,16 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 	 * page is pointing to the page from which the objects are obtained.
 	 * That page must be frozen for per cpu allocations to work.
 	 */
-	VM_BUG_ON(!c->page->frozen);
-	c->freelist = get_freepointer(s, freelist);
-	c->tid = next_tid(c->tid);
+	if (alt) {
+		VM_BUG_ON(!c->alt_page->frozen);
+		c->alt_freelist = get_freepointer(s, freelist);
+		c->alt_tid = next_tid(c->alt_tid);
+		init_object(s, freelist, SLUB_RED_ACTIVE);
+	} else {
+		VM_BUG_ON(!c->page->frozen);
+		c->freelist = get_freepointer(s, freelist);
+		c->tid = next_tid(c->tid);
+	}
 	return freelist;
 
 new_slab:
@@ -2576,6 +2685,14 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 		goto redo;
 	}
 
+	if (c->alt_partial) {
+		page = c->alt_page = c->alt_partial;
+		c->alt_partial = page->next;
+		stat(s, CPU_PARTIAL_ALLOC);
+		c->alt_freelist = NULL;
+		goto redo;
+	}
+
 	freelist = new_slab_objects(s, gfpflags, node, &c);
 
 	if (unlikely(!freelist)) {
@@ -2583,19 +2700,21 @@ static void *___slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 		return NULL;
 	}
 
-	page = c->page;
-	if (likely(!kmem_cache_debug(s) && pfmemalloc_match(page, gfpflags)))
-		goto load_freelist;
-
+	page = alt ? c->alt_page : c->page;
 	/* Only entered in the debug case */
-	if (kmem_cache_debug(s) &&
-			!alloc_debug_processing(s, page, freelist, addr))
-		goto new_slab;	/* Slab failed checks. Next slab needed */
+	if (kmem_cache_debug(s)) {
+		if (!alloc_debug_processing(s, page, freelist, addr))
+			goto new_slab;	/* Slab failed checks. Next slab needed */
 
-	deactivate_slab(s, page, get_freepointer(s, freelist));
-	c->page = NULL;
-	c->freelist = NULL;
-	return freelist;
+		if (!kmem_cache_use_alt_partial(s)) {
+			deactivate_slab(s, page, get_freepointer(s, freelist));
+			c->page = NULL;
+			c->freelist = NULL;
+			return freelist;
+		}
+	}
+	/* XXX Fix this flow */
+	goto load_freelist;
 }
 
 /*
@@ -2623,6 +2742,39 @@ static void *__slab_alloc(struct kmem_cache *s, gfp_t gfpflags, int node,
 	return p;
 }
 
+static void *__slab_alloc_alt_path(struct kmem_cache *s)
+{
+	void *object;
+	void *next_object;
+	struct kmem_cache_cpu *c;
+	unsigned long tid;
+
+	do {
+		tid = this_cpu_read(s->cpu_slab->alt_tid);
+		c = raw_cpu_ptr(s->cpu_slab);
+	} while (IS_ENABLED(CONFIG_PREEMPT) &&
+		 unlikely(tid != READ_ONCE(c->alt_tid)));
+
+	barrier();
+
+	object = c->alt_freelist;
+
+	if (!object)
+		return NULL;
+
+	next_object = get_freepointer_safe(s, object);
+
+	if (unlikely(!this_cpu_cmpxchg_double(
+			s->cpu_slab->alt_freelist, s->cpu_slab->alt_tid,
+			object, tid,
+			next_object, next_tid(tid))))
+		return NULL;
+
+	init_object(s, object, SLUB_RED_ACTIVE);
+	stat(s, ALLOC_ALT_FASTPATH);
+	return object;
+}
+
 /*
  * Inlined fastpath so that allocation functions (kmalloc, kmem_cache_alloc)
  * have the fastpath folded into their functions. So no function call
@@ -2681,7 +2833,10 @@ static __always_inline void *slab_alloc_node(struct kmem_cache *s,
 	object = c->freelist;
 	page = c->page;
 	if (unlikely(!object || !node_match(page, node))) {
-		object = __slab_alloc(s, gfpflags, node, addr, c);
+		if (kmem_cache_use_alt_partial(s))
+			object = __slab_alloc_alt_path(s);
+		if (!object)
+			object = __slab_alloc(s, gfpflags, node, addr, c);
 		stat(s, ALLOC_SLOWPATH);
 	} else {
 		void *next_object = get_freepointer_safe(s, object);
@@ -2777,6 +2932,50 @@ EXPORT_SYMBOL(kmem_cache_alloc_node_trace);
 #endif
 #endif
 
+static bool __slab_free_alt_path(struct kmem_cache *s, struct page *page,
+				void *head, void *tail)
+{
+	unsigned long tid;
+	struct kmem_cache_cpu *c;
+	void *object = head;
+
+	do {
+		tid = this_cpu_read(s->cpu_slab->alt_tid);
+		c = raw_cpu_ptr(s->cpu_slab);
+	} while (IS_ENABLED(CONFIG_PREEMPT) &&
+		 unlikely(tid != READ_ONCE(c->alt_tid)));
+
+	barrier();
+
+	/*
+	 * XXX How to avoid duplicating the initialization?
+	 */
+next_object:
+	init_object(s, object, SLUB_RED_INACTIVE);
+	if (object != tail) {
+		object = get_freepointer(s, object);
+		goto next_object;
+	}
+
+	if (likely(page == c->alt_page)) {
+		set_freepointer(s, tail, c->alt_freelist);
+
+		if (unlikely(!this_cpu_cmpxchg_double(
+				s->cpu_slab->alt_freelist, s->cpu_slab->alt_tid,
+				c->alt_freelist, tid,
+				head, next_tid(tid)))) {
+
+			note_cmpxchg_failure("slab_free", s, tid);
+			return false;
+		}
+
+		stat(s, FREE_ALT_FASTPATH);
+		return true;
+	}
+
+	return false;
+}
+
 /*
  * Slow path handling. This may still be called frequently since objects
  * have a longer lifetime than the cpu slabs in most processing loads.
@@ -2799,6 +2998,9 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 	stat(s, FREE_SLOWPATH);
 
+	if (kmem_cache_use_alt_partial(s) && __slab_free_alt_path(s, page, head, tail))
+		return;
+
 	if (kmem_cache_debug(s) &&
 	    !free_debug_processing(s, page, head, tail, cnt, addr))
 		return;
@@ -2854,7 +3056,10 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 		 * per cpu partial list.
 		 */
 		if (new.frozen && !was_frozen) {
-			put_cpu_partial(s, page, 1);
+			if (kmem_cache_use_alt_partial(s))
+				put_cpu_partial_alt(s, page, 1);
+			else
+				put_cpu_partial(s, page, 1);
 			stat(s, CPU_PARTIAL_FREE);
 		}
 		/*
@@ -5317,9 +5522,11 @@ static ssize_t text##_store(struct kmem_cache *s,		\
 }								\
 SLAB_ATTR(text);						\
 
+STAT_ATTR(ALLOC_ALT_FASTPATH, alloc_alt_fastpath);
 STAT_ATTR(ALLOC_FASTPATH, alloc_fastpath);
 STAT_ATTR(ALLOC_SLOWPATH, alloc_slowpath);
 STAT_ATTR(FREE_FASTPATH, free_fastpath);
+STAT_ATTR(FREE_ALT_FASTPATH, free_alt_fastpath);
 STAT_ATTR(FREE_SLOWPATH, free_slowpath);
 STAT_ATTR(FREE_FROZEN, free_frozen);
 STAT_ATTR(FREE_ADD_PARTIAL, free_add_partial);
@@ -5385,8 +5592,10 @@ static struct attribute *slab_attrs[] = {
 #endif
 #ifdef CONFIG_SLUB_STATS
 	&alloc_fastpath_attr.attr,
+	&alloc_alt_fastpath_attr.attr,
 	&alloc_slowpath_attr.attr,
 	&free_fastpath_attr.attr,
+	&free_alt_fastpath_attr.attr,
 	&free_slowpath_attr.attr,
 	&free_frozen_attr.attr,
 	&free_add_partial_attr.attr,
-- 
2.7.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
