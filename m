Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 332496B0038
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 13:02:08 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so15911730pbb.17
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 10:02:07 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id im7si46546429pbd.41.2014.01.03.10.02.05
        for <linux-mm@kvack.org>;
        Fri, 03 Jan 2014 10:02:06 -0800 (PST)
Subject: [PATCH 9/9] mm: slub: cleanups after code churn
From: Dave Hansen <dave@sr71.net>
Date: Fri, 03 Jan 2014 10:02:04 -0800
References: <20140103180147.6566F7C1@viggo.jf.intel.com>
In-Reply-To: <20140103180147.6566F7C1@viggo.jf.intel.com>
Message-Id: <20140103180204.4E064A3D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

I added a bunch of longer than 80 column lines and other various
messes.  But, doing line-to-line code replacements makes the
previous patch much easier to audit.  I stuck the cleanups in
here instead.

The slub code also delcares a bunch of 'struct page's on the
stack.  Now that 'struct slub_data' is separate, we can declare
those smaller structures instead.  This ends up saving us a
couple hundred bytes in object size.

Doing all the work of doing the pointer alignment operations over
and over costs us some code size.  In the end (not this patch
alone), we take slub.o's size from 26672->27168, so about 500
bytes.  But, on an 8GB system, we saved about 256k in 'struct
page' overhead.  That's a pretty good tradeoff.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/mm/slub.c |  129 ++++++++++++++++++++++---------------------
 1 file changed, 68 insertions(+), 61 deletions(-)

diff -puN mm/slub.c~slub-cleanups mm/slub.c
--- linux.git/mm/slub.c~slub-cleanups	2014-01-02 15:29:12.570949151 -0800
+++ linux.git-davehans/mm/slub.c	2014-01-02 15:39:08.978812390 -0800
@@ -257,7 +257,8 @@ static inline int check_valid_pointer(st
 		return 1;
 
 	base = page_address(page);
-	if (object < base || object >= base + slub_data(page)->objects * s->size ||
+	if (object < base ||
+	    object >= base + slub_data(page)->objects * s->size ||
 		(object - base) % s->size) {
 		return 0;
 	}
@@ -374,16 +375,17 @@ static inline bool __cmpxchg_double_slab
 	VM_BUG_ON(!irqs_disabled());
 #if defined(CONFIG_SLUB_ATTEMPT_CMPXCHG_DOUBLE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&slub_data(page)->freelist, &slub_data(page)->counters,
-			freelist_old, counters_old,
-			freelist_new, counters_new))
-		return 1;
+		if (cmpxchg_double(&slub_data(page)->freelist,
+				   &slub_data(page)->counters,
+				   freelist_old, counters_old,
+				   freelist_new, counters_new))
+			return 1;
 	} else
 #endif
 	{
 		slab_lock(page);
 		if (slub_data(page)->freelist == freelist_old &&
-					slub_data(page)->counters == counters_old) {
+		    slub_data(page)->counters == counters_old) {
 			slub_data(page)->freelist = freelist_new;
 			slub_data(page)->counters = counters_new;
 			slab_unlock(page);
@@ -407,11 +409,12 @@ static inline bool cmpxchg_double_slab(s
 		void *freelist_new, unsigned long counters_new,
 		const char *n)
 {
+	struct slub_data *sd = slub_data(page);
 #if defined(CONFIG_SLUB_ATTEMPT_CMPXCHG_DOUBLE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&slub_data(page)->freelist, &slub_data(page)->counters,
-			freelist_old, counters_old,
-			freelist_new, counters_new))
+		if (cmpxchg_double(&sd->freelist, &sd->counters,
+				   freelist_old, counters_old,
+				   freelist_new, counters_new))
 		return 1;
 	} else
 #endif
@@ -420,10 +423,10 @@ static inline bool cmpxchg_double_slab(s
 
 		local_irq_save(flags);
 		slab_lock(page);
-		if (slub_data(page)->freelist == freelist_old &&
-		    slub_data(page)->counters == counters_old) {
-			slub_data(page)->freelist = freelist_new;
-			slub_data(page)->counters = counters_new;
+		if (sd->freelist == freelist_old &&
+		    sd->counters == counters_old) {
+			sd->freelist = freelist_new;
+			sd->counters = counters_new;
 			slab_unlock(page);
 			local_irq_restore(flags);
 			return 1;
@@ -859,7 +862,8 @@ static int check_slab(struct kmem_cache
 	}
 	if (slub_data(page)->inuse > slub_data(page)->objects) {
 		slab_err(s, page, "inuse %u > max %u",
-			s->name, slub_data(page)->inuse, slub_data(page)->objects);
+			s->name, slub_data(page)->inuse,
+			slub_data(page)->objects);
 		return 0;
 	}
 	/* Slab_pad_check fixes things up after itself */
@@ -890,7 +894,8 @@ static int on_freelist(struct kmem_cache
 			} else {
 				slab_err(s, page, "Freepointer corrupt");
 				slub_data(page)->freelist = NULL;
-				slub_data(page)->inuse = slub_data(page)->objects;
+				slub_data(page)->inuse =
+					slub_data(page)->objects;
 				slab_fix(s, "Freelist cleared");
 				return 0;
 			}
@@ -913,7 +918,8 @@ static int on_freelist(struct kmem_cache
 	}
 	if (slub_data(page)->inuse != slub_data(page)->objects - nr) {
 		slab_err(s, page, "Wrong object count. Counter is %d but "
-			"counted were %d", slub_data(page)->inuse, slub_data(page)->objects - nr);
+			"counted were %d", slub_data(page)->inuse,
+			slub_data(page)->objects - nr);
 		slub_data(page)->inuse = slub_data(page)->objects - nr;
 		slab_fix(s, "Object count adjusted.");
 	}
@@ -1550,7 +1556,7 @@ static inline void *acquire_slab(struct
 {
 	void *freelist;
 	unsigned long counters;
-	struct page new;
+	struct slub_data new;
 
 	/*
 	 * Zap the freelist and set the frozen bit.
@@ -1795,8 +1801,8 @@ static void deactivate_slab(struct kmem_
 	enum slab_modes l = M_NONE, m = M_NONE;
 	void *nextfree;
 	int tail = DEACTIVATE_TO_HEAD;
-	struct page new;
-	struct page old;
+	struct slub_data new;
+	struct slub_data old;
 
 	if (slub_data(page)->freelist) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
@@ -1819,13 +1825,13 @@ static void deactivate_slab(struct kmem_
 			prior = slub_data(page)->freelist;
 			counters = slub_data(page)->counters;
 			set_freepointer(s, freelist, prior);
-			slub_data(&new)->counters = counters;
-			slub_data(&new)->inuse--;
-			VM_BUG_ON(!slub_data(&new)->frozen);
+			new.counters = counters;
+			new.inuse--;
+			VM_BUG_ON(!new.frozen);
 
 		} while (!__cmpxchg_double_slab(s, page,
 			prior, counters,
-			freelist, slub_data(&new)->counters,
+			freelist, new.counters,
 			"drain percpu freelist"));
 
 		freelist = nextfree;
@@ -1847,24 +1853,24 @@ static void deactivate_slab(struct kmem_
 	 */
 redo:
 
-	slub_data(&old)->freelist = slub_data(page)->freelist;
-	slub_data(&old)->counters = slub_data(page)->counters;
-	VM_BUG_ON(!slub_data(&old)->frozen);
+	old.freelist = slub_data(page)->freelist;
+	old.counters = slub_data(page)->counters;
+	VM_BUG_ON(!old.frozen);
 
 	/* Determine target state of the slab */
-	slub_data(&new)->counters = slub_data(&old)->counters;
+	new.counters = old.counters;
 	if (freelist) {
-		slub_data(&new)->inuse--;
-		set_freepointer(s, freelist, slub_data(&old)->freelist);
-		slub_data(&new)->freelist = freelist;
+		new.inuse--;
+		set_freepointer(s, freelist, old.freelist);
+		new.freelist = freelist;
 	} else
-		slub_data(&new)->freelist = slub_data(&old)->freelist;
+		new.freelist = old.freelist;
 
-	slub_data(&new)->frozen = 0;
+	new.frozen = 0;
 
-	if (!slub_data(&new)->inuse && n->nr_partial > s->min_partial)
+	if (!new.inuse && n->nr_partial > s->min_partial)
 		m = M_FREE;
-	else if (slub_data(&new)->freelist) {
+	else if (new.freelist) {
 		m = M_PARTIAL;
 		if (!lock) {
 			lock = 1;
@@ -1913,8 +1919,8 @@ redo:
 
 	l = m;
 	if (!__cmpxchg_double_slab(s, page,
-				slub_data(&old)->freelist, slub_data(&old)->counters,
-				slub_data(&new)->freelist, slub_data(&new)->counters,
+				old.freelist, old.counters,
+				new.freelist, new.counters,
 				"unfreezing slab"))
 		goto redo;
 
@@ -1943,8 +1949,8 @@ static void unfreeze_partials(struct kme
 	struct page *page, *discard_page = NULL;
 
 	while ((page = c->partial)) {
-		struct page new;
-		struct page old;
+		struct slub_data new;
+		struct slub_data old;
 
 		c->partial = page->next;
 
@@ -1959,21 +1965,21 @@ static void unfreeze_partials(struct kme
 
 		do {
 
-			slub_data(&old)->freelist = slub_data(page)->freelist;
-			slub_data(&old)->counters = slub_data(page)->counters;
+			old.freelist = slub_data(page)->freelist;
+			old.counters = slub_data(page)->counters;
 			VM_BUG_ON(!slub_data(&old)->frozen);
 
-			slub_data(&new)->counters = slub_data(&old)->counters;
-			slub_data(&new)->freelist = slub_data(&old)->freelist;
+			new.counters = old.counters;
+			new.freelist = old.freelist;
 
 			slub_data(&new)->frozen = 0;
 
 		} while (!__cmpxchg_double_slab(s, page,
-				slub_data(&old)->freelist, slub_data(&old)->counters,
-				slub_data(&new)->freelist, slub_data(&new)->counters,
+				old.freelist, old.counters,
+				new.freelist, new.counters,
 				"unfreezing slab"));
 
-		if (unlikely(!slub_data(&new)->inuse && n->nr_partial > s->min_partial)) {
+		if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
 			page->next = discard_page;
 			discard_page = page;
 		} else {
@@ -2225,7 +2231,7 @@ static inline bool pfmemalloc_match(stru
  */
 static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 {
-	struct page new;
+	struct slub_data new;
 	unsigned long counters;
 	void *freelist;
 
@@ -2233,15 +2239,15 @@ static inline void *get_freelist(struct
 		freelist = slub_data(page)->freelist;
 		counters = slub_data(page)->counters;
 
-		slub_data(&new)->counters = counters;
-		VM_BUG_ON(!slub_data(&new)->frozen);
+		new.counters = counters;
+		VM_BUG_ON(!new.frozen);
 
-		slub_data(&new)->inuse = slub_data(page)->objects;
-		slub_data(&new)->frozen = freelist != NULL;
+		new.inuse = slub_data(page)->objects;
+		new.frozen = freelist != NULL;
 
 	} while (!__cmpxchg_double_slab(s, page,
 		freelist, counters,
-		NULL, slub_data(&new)->counters,
+		NULL, new.counters,
 		"get_freelist"));
 
 	return freelist;
@@ -2526,7 +2532,7 @@ static void __slab_free(struct kmem_cach
 	void *prior;
 	void **object = (void *)x;
 	int was_frozen;
-	struct page new;
+	struct slub_data new;
 	unsigned long counters;
 	struct kmem_cache_node *n = NULL;
 	unsigned long uninitialized_var(flags);
@@ -2545,10 +2551,10 @@ static void __slab_free(struct kmem_cach
 		prior = slub_data(page)->freelist;
 		counters = slub_data(page)->counters;
 		set_freepointer(s, object, prior);
-		slub_data(&new)->counters = counters;
-		was_frozen = slub_data(&new)->frozen;
-		slub_data(&new)->inuse--;
-		if ((!slub_data(&new)->inuse || !prior) && !was_frozen) {
+		new.counters = counters;
+		was_frozen = new.frozen;
+		new.inuse--;
+		if ((!new.inuse || !prior) && !was_frozen) {
 
 			if (kmem_cache_has_cpu_partial(s) && !prior)
 
@@ -2558,7 +2564,7 @@ static void __slab_free(struct kmem_cach
 				 * We can defer the list move and instead
 				 * freeze it.
 				 */
-				slub_data(&new)->frozen = 1;
+				new.frozen = 1;
 
 			else { /* Needs to be taken off a list */
 
@@ -2578,7 +2584,7 @@ static void __slab_free(struct kmem_cach
 
 	} while (!cmpxchg_double_slab(s, page,
 		prior, counters,
-		object, slub_data(&new)->counters,
+		object, new.counters,
 		"__slab_free"));
 
 	if (likely(!n)) {
@@ -2587,7 +2593,7 @@ static void __slab_free(struct kmem_cach
 		 * If we just froze the page then put it onto the
 		 * per cpu partial list.
 		 */
-		if (slub_data(&new)->frozen && !was_frozen) {
+		if (new.frozen && !was_frozen) {
 			put_cpu_partial(s, page, 1);
 			stat(s, CPU_PARTIAL_FREE);
 		}
@@ -2600,7 +2606,7 @@ static void __slab_free(struct kmem_cach
                 return;
         }
 
-	if (unlikely(!slub_data(&new)->inuse && n->nr_partial > s->min_partial))
+	if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
 		goto slab_empty;
 
 	/*
@@ -3423,7 +3429,8 @@ int kmem_cache_shrink(struct kmem_cache
 		 * list_lock.  ->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			list_move(&page->lru, slabs_by_inuse + slub_data(page)->inuse);
+			list_move(&page->lru, slabs_by_inuse +
+						slub_data(page)->inuse);
 			if (!slub_data(page)->inuse)
 				n->nr_partial--;
 		}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
