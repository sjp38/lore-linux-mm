Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C052F6B000E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 15:54:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q11so7379582pfd.8
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:54:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p11si2232651pgn.752.2018.04.10.12.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 10 Apr 2018 12:54:30 -0700 (PDT)
Date: Tue, 10 Apr 2018 12:54:29 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] slub: Remove use of page->counter
Message-ID: <20180410195429.GB21336@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org


Hi Christoph,

In my continued attempt to clean up struct page, I've got to the point
where it'd be really nice to get rid of 'counters'.  I like the patch
below because it makes it clear when & where we're doing "weird" things
to access the various counters.

On 32-bit x86, it cuts the size of .text down by 400 bytes because GCC
now decides to inline get_partial_node() into its caller.  At least on
the 32-bit configuration I was testing with.

As a payoff, struct page now looks like this in my tree, which should make
it slightly easier for people to use the storage available in struct page:

struct {
	unsigned long flags;
	union {
		struct {
			struct address_space *mapping;
			pgoff_t index;
		};
		struct {
			void *s_mem;
			void *freelist;
		};
		...
	};
	union {
		atomic_t _mapcount;
		unsigned int active;
		...
	};
	atomic_t _refcount;
	union {
		struct {
			struct list_head lru;
			unsigned long private;
		};
		struct {
			struct page *next;
			int pages;
			int pobjects;
			struct kmem_cache *slab_cache;
		};
		...
	};
	struct mem_cgroup *mem_cgroup;
};

diff --git a/mm/slub.c b/mm/slub.c
index 0f55f0a0dcaa..a94075051ff3 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -55,8 +55,9 @@
  *   have the ability to do a cmpxchg_double. It only protects the second
  *   double word in the page struct. Meaning
  *	A. page->freelist	-> List of object free in a page
- *	B. page->counters	-> Counters of objects
- *	C. page->frozen		-> frozen state
+ *	B. page->inuse		-> Number of objects in use
+ *	C. page->objects	-> Number of objects
+ *	D. page->frozen		-> frozen state
  *
  *   If a slab is frozen then it is exempt from list management. It is not
  *   on any list. The processor that froze the slab is the one who can
@@ -356,23 +357,28 @@ static __always_inline void slab_unlock(struct page *page)
 	__bit_spin_unlock(PG_locked, &page->flags);
 }
 
-static inline void set_page_slub_counters(struct page *page, unsigned long counters_new)
+/*
+ * Load the various slab counters atomically.  On 64-bit machines, this will
+ * also load the page's _refcount field so we can use cmpxchg_double() to
+ * atomically set freelist and the counters.
+ */
+static inline unsigned long get_counters(struct page *p)
 {
-	struct page tmp;
-	tmp.counters = counters_new;
-	/*
-	 * page->counters can cover frozen/inuse/objects as well
-	 * as page->_refcount.  If we assign to ->counters directly
-	 * we run the risk of losing updates to page->_refcount, so
-	 * be careful and only assign to the fields we need.
-	 */
-	page->frozen  = tmp.frozen;
-	page->inuse   = tmp.inuse;
-	page->objects = tmp.objects;
+	return *(unsigned long *)&p->active;
+}
+
+/*
+ * set_counters() should only be called on a struct page on the stack,
+ * not an active struct page, or we'll overwrite _refcount.
+ */
+static inline void set_counters(struct page *p, unsigned long x)
+{
+	*(unsigned long *)&p->active = x;
 }
 
 /* Interrupts must be disabled (for the fallback code to work right) */
-static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
+static inline
+bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 		void *freelist_old, unsigned long counters_old,
 		void *freelist_new, unsigned long counters_new,
 		const char *n)
@@ -381,7 +387,8 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
+		if (cmpxchg_double(&page->freelist,
+				   (unsigned long *)&page->active,
 				   freelist_old, counters_old,
 				   freelist_new, counters_new))
 			return true;
@@ -390,9 +397,9 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 	{
 		slab_lock(page);
 		if (page->freelist == freelist_old &&
-					page->counters == counters_old) {
+				page->active == (unsigned int)counters_old) {
 			page->freelist = freelist_new;
-			set_page_slub_counters(page, counters_new);
+			page->active = counters_new;
 			slab_unlock(page);
 			return true;
 		}
@@ -417,7 +424,8 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
+		if (cmpxchg_double(&page->freelist,
+				   (unsigned long *)&page->active,
 				   freelist_old, counters_old,
 				   freelist_new, counters_new))
 			return true;
@@ -429,9 +437,9 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 		local_irq_save(flags);
 		slab_lock(page);
 		if (page->freelist == freelist_old &&
-					page->counters == counters_old) {
+				page->active == (unsigned int)counters_old) {
 			page->freelist = freelist_new;
-			set_page_slub_counters(page, counters_new);
+			page->active = counters_new;
 			slab_unlock(page);
 			local_irq_restore(flags);
 			return true;
@@ -1771,8 +1779,8 @@ static inline void *acquire_slab(struct kmem_cache *s,
 	 * per cpu allocation list.
 	 */
 	freelist = page->freelist;
-	counters = page->counters;
-	new.counters = counters;
+	counters = get_counters(page);
+	set_counters(&new, counters);
 	*objects = new.objects - new.inuse;
 	if (mode) {
 		new.inuse = page->objects;
@@ -1786,7 +1794,7 @@ static inline void *acquire_slab(struct kmem_cache *s,
 
 	if (!__cmpxchg_double_slab(s, page,
 			freelist, counters,
-			new.freelist, new.counters,
+			new.freelist, get_counters(&new),
 			"acquire_slab"))
 		return NULL;
 
@@ -2033,15 +2041,15 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 
 		do {
 			prior = page->freelist;
-			counters = page->counters;
+			counters = get_counters(page);
 			set_freepointer(s, freelist, prior);
-			new.counters = counters;
+			set_counters(&new, counters);
 			new.inuse--;
 			VM_BUG_ON(!new.frozen);
 
 		} while (!__cmpxchg_double_slab(s, page,
 			prior, counters,
-			freelist, new.counters,
+			freelist, get_counters(&new),
 			"drain percpu freelist"));
 
 		freelist = nextfree;
@@ -2064,11 +2072,11 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 redo:
 
 	old.freelist = page->freelist;
-	old.counters = page->counters;
+	set_counters(&old, get_counters(page));
 	VM_BUG_ON(!old.frozen);
 
 	/* Determine target state of the slab */
-	new.counters = old.counters;
+	set_counters(&new, get_counters(&old));
 	if (freelist) {
 		new.inuse--;
 		set_freepointer(s, freelist, old.freelist);
@@ -2129,8 +2137,8 @@ static void deactivate_slab(struct kmem_cache *s, struct page *page,
 
 	l = m;
 	if (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				old.freelist, get_counters(&old),
+				new.freelist, get_counters(&new),
 				"unfreezing slab"))
 		goto redo;
 
@@ -2179,17 +2187,17 @@ static void unfreeze_partials(struct kmem_cache *s,
 		do {
 
 			old.freelist = page->freelist;
-			old.counters = page->counters;
+			set_counters(&old, get_counters(page));
 			VM_BUG_ON(!old.frozen);
 
-			new.counters = old.counters;
+			set_counters(&new, get_counters(&old));
 			new.freelist = old.freelist;
 
 			new.frozen = 0;
 
 		} while (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				old.freelist, get_counters(&old),
+				new.freelist, get_counters(&new),
 				"unfreezing slab"));
 
 		if (unlikely(!new.inuse && n->nr_partial >= s->min_partial)) {
@@ -2476,9 +2484,9 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 
 	do {
 		freelist = page->freelist;
-		counters = page->counters;
+		counters = get_counters(page);
 
-		new.counters = counters;
+		set_counters(&new, counters);
 		VM_BUG_ON(!new.frozen);
 
 		new.inuse = page->objects;
@@ -2486,7 +2494,7 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 
 	} while (!__cmpxchg_double_slab(s, page,
 		freelist, counters,
-		NULL, new.counters,
+		NULL, get_counters(&new),
 		"get_freelist"));
 
 	return freelist;
@@ -2813,9 +2821,9 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 			n = NULL;
 		}
 		prior = page->freelist;
-		counters = page->counters;
+		counters = get_counters(page);
 		set_freepointer(s, tail, prior);
-		new.counters = counters;
+		set_counters(&new, counters);
 		was_frozen = new.frozen;
 		new.inuse -= cnt;
 		if ((!new.inuse || !prior) && !was_frozen) {
@@ -2848,7 +2856,7 @@ static void __slab_free(struct kmem_cache *s, struct page *page,
 
 	} while (!cmpxchg_double_slab(s, page,
 		prior, counters,
-		head, new.counters,
+		head, get_counters(&new),
 		"__slab_free"));
 
 	if (likely(!n)) {
