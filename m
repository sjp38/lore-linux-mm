Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 39BAE6B003A
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:40:35 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so10791988pbc.25
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:40:34 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 5si5469225pbj.5.2013.12.11.14.40.30
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 14:40:30 -0800 (PST)
Subject: [RFC][PATCH 1/3] mm: slab: create helpers for slab ->freelist pointer
From: Dave Hansen <dave@sr71.net>
Date: Wed, 11 Dec 2013 14:40:23 -0800
References: <20131211224022.AA8CF0B9@viggo.jf.intel.com>
In-Reply-To: <20131211224022.AA8CF0B9@viggo.jf.intel.com>
Message-Id: <20131211224023.5F39AC88@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cl@gentwo.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@sr71.net>


We have a need to move the ->freelist data around 'struct page'
in order to keep a cmpxchg aligned.  First step is to add an
accessor function which we will hook in to in the next patch.

I'm not super-happy with how this looks.  It's a bit ugly, but it
does work.  I'm open to some better suggestions for how to do
this.

---

 linux.git-davehans/include/linux/mm_types.h |    2 
 linux.git-davehans/mm/slab.c                |   25 ++++----
 linux.git-davehans/mm/slob.c                |   34 +++++++---
 linux.git-davehans/mm/slub.c                |   87 +++++++++++++++-------------
 4 files changed, 87 insertions(+), 61 deletions(-)

diff -puN include/linux/mm_types.h~slub-internally-align-freelist-and-counters include/linux/mm_types.h
--- linux.git/include/linux/mm_types.h~slub-internally-align-freelist-and-counters	2013-12-11 13:19:54.001948772 -0800
+++ linux.git-davehans/include/linux/mm_types.h	2013-12-11 13:19:54.010949170 -0800
@@ -143,7 +143,7 @@ struct slab_page {
 	void *s_mem;			/* slab first object */
 
 	/* Second double word */
-	void *freelist;		/* sl[aou]b first free object */
+	void *_freelist;		/* sl[aou]b first free object */
 
 	union {
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
diff -puN mm/slab.c~slub-internally-align-freelist-and-counters mm/slab.c
--- linux.git/mm/slab.c~slub-internally-align-freelist-and-counters	2013-12-11 13:19:54.003948861 -0800
+++ linux.git-davehans/mm/slab.c	2013-12-11 13:19:54.011949215 -0800
@@ -1950,6 +1950,16 @@ static void slab_destroy_debugcheck(stru
 }
 #endif
 
+static inline unsigned int **slab_freelist_ptr(struct slab_page *page)
+{
+	return (unsigned int **)&page->_freelist;
+}
+
+static inline unsigned int *slab_freelist(struct slab_page *page)
+{
+	return *slab_freelist_ptr(page);
+}
+
 /**
  * slab_destroy - destroy and release all objects in a slab
  * @cachep: cache pointer being destroyed
@@ -1963,7 +1973,7 @@ static void slab_destroy(struct kmem_cac
 {
 	void *freelist;
 
-	freelist = page->freelist;
+	freelist = slab_freelist(page);
 	slab_destroy_debugcheck(cachep, page);
 	if (unlikely(cachep->flags & SLAB_DESTROY_BY_RCU)) {
 		struct rcu_head *head;
@@ -2549,11 +2559,6 @@ static void *alloc_slabmgmt(struct kmem_
 	return freelist;
 }
 
-static inline unsigned int *slab_freelist(struct slab_page *page)
-{
-	return (unsigned int *)(page->freelist);
-}
-
 static void cache_init_objs(struct kmem_cache *cachep,
 			    struct slab_page *page)
 {
@@ -2615,7 +2620,7 @@ static void *slab_get_obj(struct kmem_ca
 {
 	void *objp;
 
-	objp = index_to_obj(cachep, page, slab_freelist(page)[page->active]);
+	objp = index_to_obj(cachep, page, (slab_freelist(page))[page->active]);
 	page->active++;
 #if DEBUG
 	WARN_ON(page_to_nid(virt_to_page(objp)) != nodeid);
@@ -2636,7 +2641,7 @@ static void slab_put_obj(struct kmem_cac
 
 	/* Verify double free bug */
 	for (i = page->active; i < cachep->num; i++) {
-		if (slab_freelist(page)[i] == objnr) {
+		if ((slab_freelist(page))[i] == objnr) {
 			printk(KERN_ERR "slab: double free detected in cache "
 					"'%s', objp %p\n", cachep->name, objp);
 			BUG();
@@ -2656,7 +2661,7 @@ static void slab_map_pages(struct kmem_c
 			   void *freelist)
 {
 	page->slab_cache = cache;
-	page->freelist = freelist;
+	*slab_freelist_ptr(page) = freelist;
 }
 
 /*
@@ -4217,7 +4222,7 @@ static void handle_slab(unsigned long *n
 
 		for (j = page->active; j < c->num; j++) {
 			/* Skip freed item */
-			if (slab_freelist(page)[j] == i) {
+			if ((slab_freelist(page))[j] == i) {
 				active = false;
 				break;
 			}
diff -puN mm/slob.c~slub-internally-align-freelist-and-counters mm/slob.c
--- linux.git/mm/slob.c~slub-internally-align-freelist-and-counters	2013-12-11 13:19:54.004948905 -0800
+++ linux.git-davehans/mm/slob.c	2013-12-11 13:19:54.012949259 -0800
@@ -211,6 +211,16 @@ static void slob_free_pages(void *b, int
 	free_pages((unsigned long)b, order);
 }
 
+static inline void **slab_freelist_ptr(struct slab_page *sp)
+{
+	return &sp->_freelist;
+}
+
+static inline void *slab_freelist(struct slab_page *sp)
+{
+	return *slab_freelist_ptr(sp);
+}
+
 /*
  * Allocate a slob block within a given slob_page sp.
  */
@@ -219,7 +229,7 @@ static void *slob_page_alloc(struct slab
 	slob_t *prev, *cur, *aligned = NULL;
 	int delta = 0, units = SLOB_UNITS(size);
 
-	for (prev = NULL, cur = sp->freelist; ; prev = cur, cur = slob_next(cur)) {
+	for (prev = NULL, cur = slab_freelist(sp); ; prev = cur, cur = slob_next(cur)) {
 		slobidx_t avail = slob_units(cur);
 
 		if (align) {
@@ -243,12 +253,12 @@ static void *slob_page_alloc(struct slab
 				if (prev)
 					set_slob(prev, slob_units(prev), next);
 				else
-					sp->freelist = next;
+					*slab_freelist_ptr(sp) = next;
 			} else { /* fragment */
 				if (prev)
 					set_slob(prev, slob_units(prev), cur + units);
 				else
-					sp->freelist = cur + units;
+					*slab_freelist_ptr(sp) = cur + units;
 				set_slob(cur + units, avail - units, next);
 			}
 
@@ -322,7 +332,7 @@ static void *slob_alloc(size_t size, gfp
 
 		spin_lock_irqsave(&slob_lock, flags);
 		sp->units = SLOB_UNITS(PAGE_SIZE);
-		sp->freelist = b;
+		*slab_freelist_ptr(sp) = b;
 		INIT_LIST_HEAD(&sp->list);
 		set_slob(b, SLOB_UNITS(PAGE_SIZE), b + SLOB_UNITS(PAGE_SIZE));
 		set_slob_page_free(sp, slob_list);
@@ -369,7 +379,7 @@ static void slob_free(void *block, int s
 	if (!slob_page_free(sp)) {
 		/* This slob page is about to become partially free. Easy! */
 		sp->units = units;
-		sp->freelist = b;
+		*slab_freelist_ptr(sp) = b;
 		set_slob(b, units,
 			(void *)((unsigned long)(b +
 					SLOB_UNITS(PAGE_SIZE)) & PAGE_MASK));
@@ -389,15 +399,15 @@ static void slob_free(void *block, int s
 	 */
 	sp->units += units;
 
-	if (b < (slob_t *)sp->freelist) {
-		if (b + units == sp->freelist) {
-			units += slob_units(sp->freelist);
-			sp->freelist = slob_next(sp->freelist);
+	if (b < (slob_t *)slab_freelist(sp)) {
+		if (b + units == slab_freelist(sp)) {
+			units += slob_units(slab_freelist(sp));
+			*slab_freelist_ptr(sp) = slob_next(slab_freelist(sp));
 		}
-		set_slob(b, units, sp->freelist);
-		sp->freelist = b;
+		set_slob(b, units, slab_freelist(sp));
+		*slab_freelist_ptr(sp) = b;
 	} else {
-		prev = sp->freelist;
+		prev = slab_freelist(sp);
 		next = slob_next(prev);
 		while (b > next) {
 			prev = next;
diff -puN mm/slub.c~slub-internally-align-freelist-and-counters mm/slub.c
--- linux.git/mm/slub.c~slub-internally-align-freelist-and-counters	2013-12-11 13:19:54.006948993 -0800
+++ linux.git-davehans/mm/slub.c	2013-12-11 13:19:54.014949347 -0800
@@ -52,7 +52,7 @@
  *   The slab_lock is only used for debugging and on arches that do not
  *   have the ability to do a cmpxchg_double. It only protects the second
  *   double word in the page struct. Meaning
- *	A. page->freelist	-> List of object free in a page
+ *	A. slab_freelist(page)	-> (pointer to) list of object free in a page
  *	B. page->counters	-> Counters of objects
  *	C. page->frozen		-> frozen state
  *
@@ -228,6 +228,16 @@ static inline void stat(const struct kme
 #endif
 }
 
+static inline void **slab_freelist_ptr(struct slab_page *spage)
+{
+	return &spage->_freelist;
+}
+
+static inline void *slab_freelist(struct slab_page *spage)
+{
+	return *slab_freelist_ptr(spage);
+}
+
 /********************************************************************
  * 			Core slab cache functions
  *******************************************************************/
@@ -380,7 +390,7 @@ static inline bool __cmpxchg_double_slab
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
+		if (cmpxchg_double(slab_freelist_ptr(page), &page->counters,
 			freelist_old, counters_old,
 			freelist_new, counters_new))
 		return 1;
@@ -388,9 +398,9 @@ static inline bool __cmpxchg_double_slab
 #endif
 	{
 		slab_lock(page);
-		if (page->freelist == freelist_old &&
+		if (slab_freelist(page) == freelist_old &&
 					page->counters == counters_old) {
-			page->freelist = freelist_new;
+			*slab_freelist_ptr(page) = freelist_new;
 			page->counters = counters_new;
 			slab_unlock(page);
 			return 1;
@@ -416,7 +426,7 @@ static inline bool cmpxchg_double_slab(s
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
+		if (cmpxchg_double(slab_freelist_ptr(page), &page->counters,
 			freelist_old, counters_old,
 			freelist_new, counters_new))
 		return 1;
@@ -427,9 +437,9 @@ static inline bool cmpxchg_double_slab(s
 
 		local_irq_save(flags);
 		slab_lock(page);
-		if (page->freelist == freelist_old &&
+		if (slab_freelist(page) == freelist_old &&
 					page->counters == counters_old) {
-			page->freelist = freelist_new;
+			*slab_freelist_ptr(page) = freelist_new;
 			page->counters = counters_new;
 			slab_unlock(page);
 			local_irq_restore(flags);
@@ -461,7 +471,7 @@ static void get_map(struct kmem_cache *s
 	void *p;
 	void *addr = slub_page_address(page);
 
-	for (p = page->freelist; p; p = get_freepointer(s, p))
+	for (p = slab_freelist(page); p; p = get_freepointer(s, p))
 		set_bit(slab_index(p, s, addr), map);
 }
 
@@ -572,7 +582,7 @@ static void print_page_info(struct slab_
 {
 	printk(KERN_ERR
 	       "INFO: Slab 0x%p objects=%u used=%u fp=0x%p flags=0x%04lx\n",
-	       page, page->objects, page->inuse, page->freelist, page->flags);
+	       page, page->objects, page->inuse, slab_freelist(page), page->flags);
 
 }
 
@@ -884,7 +894,7 @@ static int on_freelist(struct kmem_cache
 	void *object = NULL;
 	unsigned long max_objects;
 
-	fp = page->freelist;
+	fp = slab_freelist(page);
 	while (fp && nr <= page->objects) {
 		if (fp == search)
 			return 1;
@@ -895,7 +905,7 @@ static int on_freelist(struct kmem_cache
 				set_freepointer(s, object, NULL);
 			} else {
 				slab_err(s, page, "Freepointer corrupt");
-				page->freelist = NULL;
+				*slab_freelist_ptr(page) = NULL;
 				page->inuse = page->objects;
 				slab_fix(s, "Freelist cleared");
 				return 0;
@@ -934,7 +944,7 @@ static void trace(struct kmem_cache *s,
 			s->name,
 			alloc ? "alloc" : "free",
 			object, page->inuse,
-			page->freelist);
+			slab_freelist(page));
 
 		if (!alloc)
 			print_section("Object ", (void *)object,
@@ -1101,7 +1111,7 @@ bad:
 		 */
 		slab_fix(s, "Marking all objects used");
 		page->inuse = page->objects;
-		page->freelist = NULL;
+		*slab_freelist_ptr(page) = NULL;
 	}
 	return 0;
 }
@@ -1440,7 +1450,7 @@ static struct slab_page *new_slab(struct
 	setup_object(s, spage, last);
 	set_freepointer(s, last, NULL);
 
-	spage->freelist = start;
+	*slab_freelist_ptr(spage) = start;
 	spage->inuse = spage->objects;
 	spage->frozen = 1;
 out:
@@ -1570,15 +1580,15 @@ static inline void *acquire_slab(struct
 	 * The old freelist is the list of objects for the
 	 * per cpu allocation list.
 	 */
-	freelist = page->freelist;
+	freelist = slab_freelist(page);
 	counters = page->counters;
 	new.counters = counters;
 	*objects = new.objects - new.inuse;
 	if (mode) {
 		new.inuse = page->objects;
-		new.freelist = NULL;
+		*slab_freelist_ptr(&new) = NULL;
 	} else {
-		new.freelist = freelist;
+		*slab_freelist_ptr(&new) = freelist;
 	}
 
 	VM_BUG_ON(new.frozen);
@@ -1586,7 +1596,8 @@ static inline void *acquire_slab(struct
 
 	if (!__cmpxchg_double_slab(s, page,
 			freelist, counters,
-			new.freelist, new.counters,
+			slab_freelist(&new),
+			new.counters,
 			"acquire_slab"))
 		return NULL;
 
@@ -1812,7 +1823,7 @@ static void deactivate_slab(struct kmem_
 	struct slab_page new;
 	struct slab_page old;
 
-	if (page->freelist) {
+	if (slab_freelist(page)) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
 		tail = DEACTIVATE_TO_TAIL;
 	}
@@ -1830,7 +1841,7 @@ static void deactivate_slab(struct kmem_
 		unsigned long counters;
 
 		do {
-			prior = page->freelist;
+			prior = slab_freelist(page);
 			counters = page->counters;
 			set_freepointer(s, freelist, prior);
 			new.counters = counters;
@@ -1861,7 +1872,7 @@ static void deactivate_slab(struct kmem_
 	 */
 redo:
 
-	old.freelist = page->freelist;
+	*slab_freelist_ptr(&old) = slab_freelist(page);
 	old.counters = page->counters;
 	VM_BUG_ON(!old.frozen);
 
@@ -1869,16 +1880,16 @@ redo:
 	new.counters = old.counters;
 	if (freelist) {
 		new.inuse--;
-		set_freepointer(s, freelist, old.freelist);
-		new.freelist = freelist;
+		set_freepointer(s, freelist, slab_freelist(&old));
+		*slab_freelist_ptr(&new) = freelist;
 	} else
-		new.freelist = old.freelist;
+		*slab_freelist_ptr(&new) = slab_freelist(&old);
 
 	new.frozen = 0;
 
 	if (!new.inuse && n->nr_partial > s->min_partial)
 		m = M_FREE;
-	else if (new.freelist) {
+	else if (slab_freelist(&new)) {
 		m = M_PARTIAL;
 		if (!lock) {
 			lock = 1;
@@ -1927,8 +1938,8 @@ redo:
 
 	l = m;
 	if (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				slab_freelist(&old), old.counters,
+				slab_freelist(&new), new.counters,
 				"unfreezing slab"))
 		goto redo;
 
@@ -1973,18 +1984,18 @@ static void unfreeze_partials(struct kme
 
 		do {
 
-			old.freelist = page->freelist;
+			*slab_freelist_ptr(&old) = slab_freelist(page);
 			old.counters = page->counters;
 			VM_BUG_ON(!old.frozen);
 
 			new.counters = old.counters;
-			new.freelist = old.freelist;
+			*slab_freelist_ptr(&new) = slab_freelist(&old);
 
 			new.frozen = 0;
 
 		} while (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				slab_freelist_ptr(&old), old.counters,
+				slab_freelist_ptr(&new), new.counters,
 				"unfreezing slab"));
 
 		if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
@@ -2208,8 +2219,8 @@ static inline void *new_slab_objects(str
 		 * No other reference to the page yet so we can
 		 * muck around with it freely without cmpxchg
 		 */
-		freelist = page->freelist;
-		page->freelist = NULL;
+		freelist = slab_freelist(page);
+		*slab_freelist_ptr(page) = NULL;
 
 		stat(s, ALLOC_SLAB);
 		c->page = page;
@@ -2229,7 +2240,7 @@ static inline bool pfmemalloc_match(stru
 }
 
 /*
- * Check the page->freelist of a page and either transfer the freelist to the
+ * Check the slab_freelist(page) of a page and either transfer the freelist to the
  * per cpu freelist or deactivate the page.
  *
  * The page is still frozen if the return value is not NULL.
@@ -2245,7 +2256,7 @@ static inline void *get_freelist(struct
 	void *freelist;
 
 	do {
-		freelist = page->freelist;
+		freelist = slab_freelist(page);
 		counters = page->counters;
 
 		new.counters = counters;
@@ -2557,7 +2568,7 @@ static void __slab_free(struct kmem_cach
 			spin_unlock_irqrestore(&n->list_lock, flags);
 			n = NULL;
 		}
-		prior = page->freelist;
+		prior = slab_freelist(page);
 		counters = page->counters;
 		set_freepointer(s, object, prior);
 		new.counters = counters;
@@ -2901,9 +2912,9 @@ static void early_kmem_cache_node_alloc(
 				"in order to be able to continue\n");
 	}
 
-	n = page->freelist;
+	n = slab_freelist(page);
 	BUG_ON(!n);
-	page->freelist = get_freepointer(kmem_cache_node, n);
+	*slab_freelist_ptr(page) = get_freepointer(kmem_cache_node, n);
 	page->inuse = 1;
 	page->frozen = 0;
 	kmem_cache_node->node[node] = n;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
