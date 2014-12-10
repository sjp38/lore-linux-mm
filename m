Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2EA506B0080
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 11:30:49 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id i57so1420178yha.7
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 08:30:48 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id 12si5431780qgg.10.2014.12.10.08.30.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 10 Dec 2014 08:30:38 -0800 (PST)
Message-Id: <20141210163033.970247616@linux.com>
Date: Wed, 10 Dec 2014 10:30:22 -0600
From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 5/7] slub: Use end_token instead of NULL to terminate freelists
References: <20141210163017.092096069@linux.com>
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=slub_use_end_token_instead_of_null
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linuxfoundation.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, penberg@kernel.org, iamjoonsoo@lge.com, Jesper Dangaard Brouer <brouer@redhat.com>

Ending a list with NULL means that the termination of a list is the same
for all slab pages. The pointers of freelists otherwise always are
pointing to the address space of the page. Make termination of a
list possible by setting the lowest bit in the freelist address
and use the start address of a page if no other address is available
for list termination.

This will allow us to determine the page struct address from a
freelist pointer in the future.

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/mm/slub.c
===================================================================
--- linux.orig/mm/slub.c	2014-12-09 12:29:47.219144051 -0600
+++ linux/mm/slub.c	2014-12-09 12:29:47.219144051 -0600
@@ -132,6 +132,16 @@ static inline bool kmem_cache_has_cpu_pa
 #endif
 }
 
+static bool is_end_token(const void *freelist)
+{
+	return ((unsigned long)freelist) & 1;
+}
+
+static void *end_token(const void *address)
+{
+	return (void *)((unsigned long)address | 1);
+}
+
 /*
  * Issues still to be resolved:
  *
@@ -234,7 +244,7 @@ static inline int check_valid_pointer(st
 
 	base = page->address;
 	if (object < base || object >= base + page->objects * s->size ||
-		(object - base) % s->size) {
+		((object - base) % s->size && !is_end_token(object))) {
 		return 0;
 	}
 
@@ -451,7 +461,7 @@ static void get_map(struct kmem_cache *s
 	void *p;
 	void *addr = page->address;
 
-	for (p = page->freelist; p; p = get_freepointer(s, p))
+	for (p = page->freelist; !is_end_token(p); p = get_freepointer(s, p))
 		set_bit(slab_index(p, s, addr), map);
 }
 
@@ -829,7 +839,7 @@ static int check_object(struct kmem_cach
 		 * of the free objects in this slab. May cause
 		 * another error because the object count is now wrong.
 		 */
-		set_freepointer(s, p, NULL);
+		set_freepointer(s, p, end_token(page->address));
 		return 0;
 	}
 	return 1;
@@ -874,7 +884,7 @@ static int on_freelist(struct kmem_cache
 	unsigned long max_objects;
 
 	fp = page->freelist;
-	while (fp && nr <= page->objects) {
+	while (!is_end_token(fp) && nr <= page->objects) {
 		if (fp == search)
 			return 1;
 		if (!check_valid_pointer(s, page, fp)) {
@@ -1033,7 +1043,7 @@ bad:
 		 */
 		slab_fix(s, "Marking all objects used");
 		page->inuse = page->objects;
-		page->freelist = NULL;
+		page->freelist = end_token(page->address);
 	}
 	return 0;
 }
@@ -1402,7 +1412,7 @@ static struct page *new_slab(struct kmem
 		if (likely(idx < page->objects))
 			set_freepointer(s, p, p + s->size);
 		else
-			set_freepointer(s, p, NULL);
+			set_freepointer(s, p, end_token(start));
 	}
 
 	page->freelist = start;
@@ -1546,12 +1556,11 @@ static inline void *acquire_slab(struct
 	freelist = page->freelist;
 	counters = page->counters;
 	new.counters = counters;
+	new.freelist = freelist;
 	*objects = new.objects - new.inuse;
 	if (mode) {
 		new.inuse = page->objects;
-		new.freelist = NULL;
-	} else {
-		new.freelist = freelist;
+		new.freelist = end_token(freelist);
 	}
 
 	VM_BUG_ON(new.frozen);
@@ -1787,7 +1796,7 @@ static void deactivate_slab(struct kmem_
 	struct page new;
 	struct page old;
 
-	if (page->freelist) {
+	if (!is_end_token(page->freelist)) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
 		tail = DEACTIVATE_TO_TAIL;
 	}
@@ -1800,7 +1809,8 @@ static void deactivate_slab(struct kmem_
 	 * There is no need to take the list->lock because the page
 	 * is still frozen.
 	 */
-	while (freelist && (nextfree = get_freepointer(s, freelist))) {
+	if (freelist)
+	    while (!is_end_token(freelist) && (nextfree = get_freepointer(s, freelist))) {
 		void *prior;
 		unsigned long counters;
 
@@ -1818,7 +1828,8 @@ static void deactivate_slab(struct kmem_
 			"drain percpu freelist"));
 
 		freelist = nextfree;
-	}
+	} else
+		freelist = end_token(page->address);
 
 	/*
 	 * Stage two: Ensure that the page is unfrozen while the
@@ -1842,7 +1853,7 @@ redo:
 
 	/* Determine target state of the slab */
 	new.counters = old.counters;
-	if (freelist) {
+	if (!is_end_token(freelist)) {
 		new.inuse--;
 		set_freepointer(s, freelist, old.freelist);
 		new.freelist = freelist;
@@ -1853,7 +1864,7 @@ redo:
 
 	if (!new.inuse && n->nr_partial >= s->min_partial)
 		m = M_FREE;
-	else if (new.freelist) {
+	else if (!is_end_token(new.freelist)) {
 		m = M_PARTIAL;
 		if (!lock) {
 			lock = 1;
@@ -2180,7 +2191,7 @@ static inline void *new_slab_objects(str
 
 	freelist = get_partial(s, flags, node, c);
 
-	if (freelist)
+	if (freelist && !is_end_token(freelist))
 		return freelist;
 
 	page = new_slab(s, flags, node);
@@ -2194,7 +2205,7 @@ static inline void *new_slab_objects(str
 		 * muck around with it freely without cmpxchg
 		 */
 		freelist = page->freelist;
-		page->freelist = NULL;
+		page->freelist = end_token(freelist);
 
 		stat(s, ALLOC_SLAB);
 		c->page = page;
@@ -2217,11 +2228,11 @@ static inline bool pfmemalloc_match(stru
  * Check the page->freelist of a page and either transfer the freelist to the
  * per cpu freelist or deactivate the page.
  *
- * The page is still frozen if the return value is not NULL.
+ * The page is still frozen if the return value is not end_token.
  *
- * If this function returns NULL then the page has been unfrozen.
+ * If this function returns end_token then the page has been unfrozen.
  *
- * This function must be called with interrupt disabled.
+ * This function must be called with interrupts disabled.
  */
 static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 {
@@ -2237,11 +2248,11 @@ static inline void *get_freelist(struct
 		VM_BUG_ON(!new.frozen);
 
 		new.inuse = page->objects;
-		new.frozen = freelist != NULL;
+		new.frozen = !is_end_token(freelist);
 
 	} while (!__cmpxchg_double_slab(s, page,
 		freelist, counters,
-		NULL, new.counters,
+		end_token(freelist), new.counters,
 		"get_freelist"));
 
 	return freelist;
@@ -2307,12 +2318,17 @@ redo:
 
 	/* must check again c->freelist in case of cpu migration or IRQ */
 	freelist = c->freelist;
-	if (freelist)
+	if (freelist && !is_end_token(freelist))
 		goto load_freelist;
 
+	/*
+	 * There is no freelist or its exhausted. See if the page has any
+	 * objects freed to it.
+	 */
 	freelist = get_freelist(s, page);
 
-	if (!freelist) {
+	if (is_end_token(freelist)) {
+		/* page has been deactivated by get_freelist */
 		c->page = NULL;
 		stat(s, DEACTIVATE_BYPASS);
 		goto new_slab;
@@ -2343,7 +2359,7 @@ new_slab:
 		page = c->page = c->partial;
 		c->partial = page->next;
 		stat(s, CPU_PARTIAL_ALLOC);
-		c->freelist = NULL;
+		c->freelist = end_token(page->address);
 		goto redo;
 	}
 
@@ -2419,7 +2435,7 @@ redo:
 
 	object = c->freelist;
 	page = c->page;
-	if (unlikely(!object || !node_match_ptr(object, node))) {
+	if (unlikely(!object || is_end_token(object) ||!node_match_ptr(object, node))) {
 		object = __slab_alloc(s, gfpflags, node, addr, c);
 		stat(s, ALLOC_SLOWPATH);
 	} else {
@@ -2549,9 +2565,9 @@ static void __slab_free(struct kmem_cach
 		new.counters = counters;
 		was_frozen = new.frozen;
 		new.inuse--;
-		if ((!new.inuse || !prior) && !was_frozen) {
+		if ((!new.inuse || is_end_token(prior)) && !was_frozen) {
 
-			if (kmem_cache_has_cpu_partial(s) && !prior) {
+			if (kmem_cache_has_cpu_partial(s) && is_end_token(prior)) {
 
 				/*
 				 * Slab was on no list before and will be
@@ -2608,7 +2624,7 @@ static void __slab_free(struct kmem_cach
 	 * Objects left in the slab. If it was not on the partial list before
 	 * then add it.
 	 */
-	if (!kmem_cache_has_cpu_partial(s) && unlikely(!prior)) {
+	if (!kmem_cache_has_cpu_partial(s) && unlikely(is_end_token(prior))) {
 		if (kmem_cache_debug(s))
 			remove_full(s, n, page);
 		add_partial(n, page, DEACTIVATE_TO_TAIL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
