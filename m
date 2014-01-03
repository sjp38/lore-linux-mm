Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5665D6B003A
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 13:02:11 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so15592179pdj.4
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 10:02:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yy4si32290808pbc.219.2014.01.03.10.02.09
        for <linux-mm@kvack.org>;
        Fri, 03 Jan 2014 10:02:09 -0800 (PST)
Subject: [PATCH 6/9] mm: slub: rearrange 'struct page' fields
From: Dave Hansen <dave@sr71.net>
Date: Fri, 03 Jan 2014 10:01:58 -0800
References: <20140103180147.6566F7C1@viggo.jf.intel.com>
In-Reply-To: <20140103180147.6566F7C1@viggo.jf.intel.com>
Message-Id: <20140103180158.9530D16F@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org, cl@linux-foundation.org, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

SLUB has some very unique alignment constraints it places
on 'struct page'.  Break those out in to a separate structure
which will not pollute 'struct page'.

This structure will be moved around inside 'struct page' at
runtime in the next patch, so it is necessary to break it out for
those uses as well.

Vim pattern used for the renames:
%s/\(page\|new\)\(->\|\.\)\(freelist\|counters\)/slub_data(\1)\2\3/g

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/include/linux/mm_types.h |   66 ++++---
 linux.git-davehans/mm/slab_common.c         |   29 ++-
 linux.git-davehans/mm/slub.c                |  253 ++++++++++++++--------------
 3 files changed, 192 insertions(+), 156 deletions(-)

diff -puN include/linux/mm_types.h~slub-rearrange include/linux/mm_types.h
--- linux.git/include/linux/mm_types.h~slub-rearrange	2014-01-02 13:40:30.733330787 -0800
+++ linux.git-davehans/include/linux/mm_types.h	2014-01-02 15:24:43.756840049 -0800
@@ -23,6 +23,43 @@
 
 struct address_space;
 
+struct slub_data {
+	void *unused;
+	void *freelist;
+	union {
+		struct {
+			unsigned inuse:16;
+			unsigned objects:15;
+			unsigned frozen:1;
+			atomic_t dontuse_slub_count;
+		};
+		/*
+		 * ->counters is used to make it easier to copy
+		 * all of the above counters in one chunk.
+		 * The actual counts are never accessed via this.
+		 */
+#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
+    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+		unsigned long counters;
+#else
+		/*
+		 * Keep _count separate from slub cmpxchg_double data.
+		 * As the rest of the double word is protected by
+		 * slab_lock but _count is not.
+		 */
+		struct {
+			unsigned counters;
+			/*
+			 * This isn't used directly, but declare it here
+			 * for clarity since it must line up with _count
+			 * from 'struct page'
+			 */
+			atomic_t separate_count;
+		};
+#endif
+	};
+};
+
 #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 #define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
 		IS_ENABLED(CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK))
@@ -70,14 +107,7 @@ struct page {
 			atomic_t _count;
 		}; /* end of the "normal" use */
 
-		struct { /* SLUB */
-			void *unused;
-			void *freelist;
-			unsigned inuse:16;
-			unsigned objects:15;
-			unsigned frozen:1;
-			atomic_t dontuse_slub_count;
-		};
+		struct slub_data slub_data;
 		struct { /* SLAB */
 			void *s_mem;
 			void *slab_freelist;
@@ -90,26 +120,6 @@ struct page {
 			unsigned int units;
 			atomic_t dontuse_slob_count;
 		};
-		/*
-		 * This is here to help the slub code deal with
-		 * its inuse/objects/frozen bitfields as a single
-		 * blob.
-		 */
-		struct { /* slub helpers */
-			void *slubhelp_unused;
-			void *slubhelp_freelist;
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-			unsigned long counters;
-#else
-			/*
-			 * Keep _count separate from slub cmpxchg_double data.
-			 * As the rest of the double word is protected by
-			 * slab_lock but _count is not.
-			 */
-			unsigned counters;
-#endif
-		};
 	};
 
 	/* Third double word block */
diff -puN mm/slab_common.c~slub-rearrange mm/slab_common.c
--- linux.git/mm/slab_common.c~slub-rearrange	2014-01-02 13:40:30.735330876 -0800
+++ linux.git-davehans/mm/slab_common.c	2014-01-02 15:24:35.095449871 -0800
@@ -658,20 +658,39 @@ static int __init slab_proc_init(void)
 }
 module_init(slab_proc_init);
 #endif /* CONFIG_SLABINFO */
+
 #define SLAB_PAGE_CHECK(field1, field2)        \
 	BUILD_BUG_ON(offsetof(struct page, field1) !=   \
 		     offsetof(struct page, field2))
 /*
  * To make the layout of 'struct page' look nicer, we've broken
- * up a few of the unions.  Folks declaring their own use of the
- * first few fields need to make sure that their use does not
- * interfere with page->_count.  This ensures that the individual
- * users' use actually lines up with the real ->_count.
+ * up a few of the unions.  But, this has made it hard to see if
+ * any given use will interfere with page->_count.
+ *
+ * To work around this, each user declares their own _count field
+ * and we check them at build time to ensure that the independent
+ * definitions actually line up with the real ->_count.
  */
 void slab_build_checks(void)
 {
 	SLAB_PAGE_CHECK(_count, dontuse_slab_count);
-	SLAB_PAGE_CHECK(_count, dontuse_slub_count);
+	SLAB_PAGE_CHECK(_count, slub_data.dontuse_slub_count);
 	SLAB_PAGE_CHECK(_count, dontuse_slob_count);
+
+	/*
+	 * When doing a double-cmpxchg, the slub code sucks in
+	 * _count.  But, this is harmless since if _count is
+	 * modified, the cmpxchg will fail.  When not using a
+	 * real cmpxchg, the slub code uses a lock.  But, _count
+	 * is not modified under that lock and updates can be
+	 * lost if they race with one of the "faked" cmpxchg
+	 * under that lock.  This makes sure that the space we
+	 * carve out for _count in that case actually lines up
+	 * with the real _count.
+	 */
+#if !(defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
+	    defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE))
+	SLAB_PAGE_CHECK(_count, slub_data.separate_count);
+#endif
 }
 
diff -puN mm/slub.c~slub-rearrange mm/slub.c
--- linux.git/mm/slub.c~slub-rearrange	2014-01-02 13:40:30.737330966 -0800
+++ linux.git-davehans/mm/slub.c	2014-01-02 15:27:23.607040821 -0800
@@ -52,8 +52,8 @@
  *   The slab_lock is only used for debugging and on arches that do not
  *   have the ability to do a cmpxchg_double. It only protects the second
  *   double word in the page struct. Meaning
- *	A. page->freelist	-> List of object free in a page
- *	B. page->counters	-> Counters of objects
+ *	A. slub_data(page)->freelist	-> List of object free in a page
+ *	B. slub_data(page)->counters	-> Counters of objects
  *	C. page->frozen		-> frozen state
  *
  *   If a slab is frozen then it is exempt from list management. It is not
@@ -237,6 +237,12 @@ static inline struct kmem_cache_node *ge
 	return s->node[node];
 }
 
+static inline struct slub_data *slub_data(struct page *page)
+{
+	void *ptr = &page->slub_data;
+	return ptr;
+}
+
 /* Verify that a pointer has an address that is valid within a slab page */
 static inline int check_valid_pointer(struct kmem_cache *s,
 				struct page *page, const void *object)
@@ -247,7 +253,7 @@ static inline int check_valid_pointer(st
 		return 1;
 
 	base = page_address(page);
-	if (object < base || object >= base + page->objects * s->size ||
+	if (object < base || object >= base + slub_data(page)->objects * s->size ||
 		(object - base) % s->size) {
 		return 0;
 	}
@@ -365,7 +371,7 @@ static inline bool __cmpxchg_double_slab
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
+		if (cmpxchg_double(&slub_data(page)->freelist, &slub_data(page)->counters,
 			freelist_old, counters_old,
 			freelist_new, counters_new))
 		return 1;
@@ -373,10 +379,10 @@ static inline bool __cmpxchg_double_slab
 #endif
 	{
 		slab_lock(page);
-		if (page->freelist == freelist_old &&
-					page->counters == counters_old) {
-			page->freelist = freelist_new;
-			page->counters = counters_new;
+		if (slub_data(page)->freelist == freelist_old &&
+					slub_data(page)->counters == counters_old) {
+			slub_data(page)->freelist = freelist_new;
+			slub_data(page)->counters = counters_new;
 			slab_unlock(page);
 			return 1;
 		}
@@ -401,7 +407,7 @@ static inline bool cmpxchg_double_slab(s
 #if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
     defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
 	if (s->flags & __CMPXCHG_DOUBLE) {
-		if (cmpxchg_double(&page->freelist, &page->counters,
+		if (cmpxchg_double(&slub_data(page)->freelist, &slub_data(page)->counters,
 			freelist_old, counters_old,
 			freelist_new, counters_new))
 		return 1;
@@ -412,10 +418,10 @@ static inline bool cmpxchg_double_slab(s
 
 		local_irq_save(flags);
 		slab_lock(page);
-		if (page->freelist == freelist_old &&
-					page->counters == counters_old) {
-			page->freelist = freelist_new;
-			page->counters = counters_new;
+		if (slub_data(page)->freelist == freelist_old &&
+		    slub_data(page)->counters == counters_old) {
+			slub_data(page)->freelist = freelist_new;
+			slub_data(page)->counters = counters_new;
 			slab_unlock(page);
 			local_irq_restore(flags);
 			return 1;
@@ -446,7 +452,7 @@ static void get_map(struct kmem_cache *s
 	void *p;
 	void *addr = page_address(page);
 
-	for (p = page->freelist; p; p = get_freepointer(s, p))
+	for (p = slub_data(page)->freelist; p; p = get_freepointer(s, p))
 		set_bit(slab_index(p, s, addr), map);
 }
 
@@ -557,7 +563,8 @@ static void print_page_info(struct page
 {
 	printk(KERN_ERR
 	       "INFO: Slab 0x%p objects=%u used=%u fp=0x%p flags=0x%04lx\n",
-	       page, page->objects, page->inuse, page->freelist, page->flags);
+	       page, slub_data(page)->objects, slub_data(page)->inuse,
+	       slub_data(page)->freelist, page->flags);
 
 }
 
@@ -843,14 +850,14 @@ static int check_slab(struct kmem_cache
 	}
 
 	maxobj = order_objects(compound_order(page), s->size, s->reserved);
-	if (page->objects > maxobj) {
+	if (slub_data(page)->objects > maxobj) {
 		slab_err(s, page, "objects %u > max %u",
-			s->name, page->objects, maxobj);
+			s->name, slub_data(page)->objects, maxobj);
 		return 0;
 	}
-	if (page->inuse > page->objects) {
+	if (slub_data(page)->inuse > slub_data(page)->objects) {
 		slab_err(s, page, "inuse %u > max %u",
-			s->name, page->inuse, page->objects);
+			s->name, slub_data(page)->inuse, slub_data(page)->objects);
 		return 0;
 	}
 	/* Slab_pad_check fixes things up after itself */
@@ -869,8 +876,8 @@ static int on_freelist(struct kmem_cache
 	void *object = NULL;
 	unsigned long max_objects;
 
-	fp = page->freelist;
-	while (fp && nr <= page->objects) {
+	fp = slub_data(page)->freelist;
+	while (fp && nr <= slub_data(page)->objects) {
 		if (fp == search)
 			return 1;
 		if (!check_valid_pointer(s, page, fp)) {
@@ -880,8 +887,8 @@ static int on_freelist(struct kmem_cache
 				set_freepointer(s, object, NULL);
 			} else {
 				slab_err(s, page, "Freepointer corrupt");
-				page->freelist = NULL;
-				page->inuse = page->objects;
+				slub_data(page)->freelist = NULL;
+				slub_data(page)->inuse = slub_data(page)->objects;
 				slab_fix(s, "Freelist cleared");
 				return 0;
 			}
@@ -896,16 +903,16 @@ static int on_freelist(struct kmem_cache
 	if (max_objects > MAX_OBJS_PER_PAGE)
 		max_objects = MAX_OBJS_PER_PAGE;
 
-	if (page->objects != max_objects) {
+	if (slub_data(page)->objects != max_objects) {
 		slab_err(s, page, "Wrong number of objects. Found %d but "
-			"should be %d", page->objects, max_objects);
-		page->objects = max_objects;
+			"should be %d", slub_data(page)->objects, max_objects);
+		slub_data(page)->objects = max_objects;
 		slab_fix(s, "Number of objects adjusted.");
 	}
-	if (page->inuse != page->objects - nr) {
+	if (slub_data(page)->inuse != slub_data(page)->objects - nr) {
 		slab_err(s, page, "Wrong object count. Counter is %d but "
-			"counted were %d", page->inuse, page->objects - nr);
-		page->inuse = page->objects - nr;
+			"counted were %d", slub_data(page)->inuse, slub_data(page)->objects - nr);
+		slub_data(page)->inuse = slub_data(page)->objects - nr;
 		slab_fix(s, "Object count adjusted.");
 	}
 	return search == NULL;
@@ -918,8 +925,8 @@ static void trace(struct kmem_cache *s,
 		printk(KERN_INFO "TRACE %s %s 0x%p inuse=%d fp=0x%p\n",
 			s->name,
 			alloc ? "alloc" : "free",
-			object, page->inuse,
-			page->freelist);
+			object, slub_data(page)->inuse,
+			slub_data(page)->freelist);
 
 		if (!alloc)
 			print_section("Object ", (void *)object,
@@ -1085,8 +1092,8 @@ bad:
 		 * as used avoids touching the remaining objects.
 		 */
 		slab_fix(s, "Marking all objects used");
-		page->inuse = page->objects;
-		page->freelist = NULL;
+		slub_data(page)->inuse = slub_data(page)->objects;
+		slub_data(page)->freelist = NULL;
 	}
 	return 0;
 }
@@ -1366,7 +1373,7 @@ static struct page *allocate_slab(struct
 	if (!page)
 		return NULL;
 
-	page->objects = oo_objects(oo);
+	slub_data(page)->objects = oo_objects(oo);
 	mod_zone_page_state(page_zone(page),
 		(s->flags & SLAB_RECLAIM_ACCOUNT) ?
 		NR_SLAB_RECLAIMABLE : NR_SLAB_UNRECLAIMABLE,
@@ -1399,7 +1406,7 @@ static struct page *new_slab(struct kmem
 		goto out;
 
 	order = compound_order(page);
-	inc_slabs_node(s, page_to_nid(page), page->objects);
+	inc_slabs_node(s, page_to_nid(page), slub_data(page)->objects);
 	memcg_bind_pages(s, order);
 	page->slab_cache = s;
 	__SetPageSlab(page);
@@ -1412,7 +1419,7 @@ static struct page *new_slab(struct kmem
 		memset(start, POISON_INUSE, PAGE_SIZE << order);
 
 	last = start;
-	for_each_object(p, s, start, page->objects) {
+	for_each_object(p, s, start, slub_data(page)->objects) {
 		setup_object(s, page, last);
 		set_freepointer(s, last, p);
 		last = p;
@@ -1420,9 +1427,9 @@ static struct page *new_slab(struct kmem
 	setup_object(s, page, last);
 	set_freepointer(s, last, NULL);
 
-	page->freelist = start;
-	page->inuse = page->objects;
-	page->frozen = 1;
+	slub_data(page)->freelist = start;
+	slub_data(page)->inuse = slub_data(page)->objects;
+	slub_data(page)->frozen = 1;
 out:
 	return page;
 }
@@ -1437,7 +1444,7 @@ static void __free_slab(struct kmem_cach
 
 		slab_pad_check(s, page);
 		for_each_object(p, s, page_address(page),
-						page->objects)
+						slub_data(page)->objects)
 			check_object(s, page, p, SLUB_RED_INACTIVE);
 	}
 
@@ -1498,7 +1505,7 @@ static void free_slab(struct kmem_cache
 
 static void discard_slab(struct kmem_cache *s, struct page *page)
 {
-	dec_slabs_node(s, page_to_nid(page), page->objects);
+	dec_slabs_node(s, page_to_nid(page), slub_data(page)->objects);
 	free_slab(s, page);
 }
 
@@ -1548,23 +1555,23 @@ static inline void *acquire_slab(struct
 	 * The old freelist is the list of objects for the
 	 * per cpu allocation list.
 	 */
-	freelist = page->freelist;
-	counters = page->counters;
-	new.counters = counters;
-	*objects = new.objects - new.inuse;
+	freelist = slub_data(page)->freelist;
+	counters = slub_data(page)->counters;
+	slub_data(&new)->counters = counters;
+	*objects = slub_data(&new)->objects - slub_data(&new)->inuse;
 	if (mode) {
-		new.inuse = page->objects;
-		new.freelist = NULL;
+		slub_data(&new)->inuse = slub_data(page)->objects;
+		slub_data(&new)->freelist = NULL;
 	} else {
-		new.freelist = freelist;
+		slub_data(&new)->freelist = freelist;
 	}
 
-	VM_BUG_ON(new.frozen);
-	new.frozen = 1;
+	VM_BUG_ON(slub_data(&new)->frozen);
+	slub_data(&new)->frozen = 1;
 
 	if (!__cmpxchg_double_slab(s, page,
 			freelist, counters,
-			new.freelist, new.counters,
+			slub_data(&new)->freelist, slub_data(&new)->counters,
 			"acquire_slab"))
 		return NULL;
 
@@ -1789,7 +1796,7 @@ static void deactivate_slab(struct kmem_
 	struct page new;
 	struct page old;
 
-	if (page->freelist) {
+	if (slub_data(page)->freelist) {
 		stat(s, DEACTIVATE_REMOTE_FREES);
 		tail = DEACTIVATE_TO_TAIL;
 	}
@@ -1807,16 +1814,16 @@ static void deactivate_slab(struct kmem_
 		unsigned long counters;
 
 		do {
-			prior = page->freelist;
-			counters = page->counters;
+			prior = slub_data(page)->freelist;
+			counters = slub_data(page)->counters;
 			set_freepointer(s, freelist, prior);
-			new.counters = counters;
-			new.inuse--;
-			VM_BUG_ON(!new.frozen);
+			slub_data(&new)->counters = counters;
+			slub_data(&new)->inuse--;
+			VM_BUG_ON(!slub_data(&new)->frozen);
 
 		} while (!__cmpxchg_double_slab(s, page,
 			prior, counters,
-			freelist, new.counters,
+			freelist, slub_data(&new)->counters,
 			"drain percpu freelist"));
 
 		freelist = nextfree;
@@ -1838,24 +1845,24 @@ static void deactivate_slab(struct kmem_
 	 */
 redo:
 
-	old.freelist = page->freelist;
-	old.counters = page->counters;
-	VM_BUG_ON(!old.frozen);
+	slub_data(&old)->freelist = slub_data(page)->freelist;
+	slub_data(&old)->counters = slub_data(page)->counters;
+	VM_BUG_ON(!slub_data(&old)->frozen);
 
 	/* Determine target state of the slab */
-	new.counters = old.counters;
+	slub_data(&new)->counters = slub_data(&old)->counters;
 	if (freelist) {
-		new.inuse--;
-		set_freepointer(s, freelist, old.freelist);
-		new.freelist = freelist;
+		slub_data(&new)->inuse--;
+		set_freepointer(s, freelist, slub_data(&old)->freelist);
+		slub_data(&new)->freelist = freelist;
 	} else
-		new.freelist = old.freelist;
+		slub_data(&new)->freelist = slub_data(&old)->freelist;
 
-	new.frozen = 0;
+	slub_data(&new)->frozen = 0;
 
-	if (!new.inuse && n->nr_partial > s->min_partial)
+	if (!slub_data(&new)->inuse && n->nr_partial > s->min_partial)
 		m = M_FREE;
-	else if (new.freelist) {
+	else if (slub_data(&new)->freelist) {
 		m = M_PARTIAL;
 		if (!lock) {
 			lock = 1;
@@ -1904,8 +1911,8 @@ redo:
 
 	l = m;
 	if (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				slub_data(&old)->freelist, slub_data(&old)->counters,
+				slub_data(&new)->freelist, slub_data(&new)->counters,
 				"unfreezing slab"))
 		goto redo;
 
@@ -1950,21 +1957,21 @@ static void unfreeze_partials(struct kme
 
 		do {
 
-			old.freelist = page->freelist;
-			old.counters = page->counters;
-			VM_BUG_ON(!old.frozen);
+			slub_data(&old)->freelist = slub_data(page)->freelist;
+			slub_data(&old)->counters = slub_data(page)->counters;
+			VM_BUG_ON(!slub_data(&old)->frozen);
 
-			new.counters = old.counters;
-			new.freelist = old.freelist;
+			slub_data(&new)->counters = slub_data(&old)->counters;
+			slub_data(&new)->freelist = slub_data(&old)->freelist;
 
-			new.frozen = 0;
+			slub_data(&new)->frozen = 0;
 
 		} while (!__cmpxchg_double_slab(s, page,
-				old.freelist, old.counters,
-				new.freelist, new.counters,
+				slub_data(&old)->freelist, slub_data(&old)->counters,
+				slub_data(&new)->freelist, slub_data(&new)->counters,
 				"unfreezing slab"));
 
-		if (unlikely(!new.inuse && n->nr_partial > s->min_partial)) {
+		if (unlikely(!slub_data(&new)->inuse && n->nr_partial > s->min_partial)) {
 			page->next = discard_page;
 			discard_page = page;
 		} else {
@@ -2028,7 +2035,7 @@ static void put_cpu_partial(struct kmem_
 		}
 
 		pages++;
-		pobjects += page->objects - page->inuse;
+		pobjects += slub_data(page)->objects - slub_data(page)->inuse;
 
 		page->pages = pages;
 		page->pobjects = pobjects;
@@ -2101,7 +2108,7 @@ static inline int node_match(struct page
 
 static int count_free(struct page *page)
 {
-	return page->objects - page->inuse;
+	return slub_data(page)->objects - slub_data(page)->inuse;
 }
 
 static unsigned long count_partial(struct kmem_cache_node *n,
@@ -2184,8 +2191,8 @@ static inline void *new_slab_objects(str
 		 * No other reference to the page yet so we can
 		 * muck around with it freely without cmpxchg
 		 */
-		freelist = page->freelist;
-		page->freelist = NULL;
+		freelist = slub_data(page)->freelist;
+		slub_data(page)->freelist = NULL;
 
 		stat(s, ALLOC_SLAB);
 		c->page = page;
@@ -2205,7 +2212,7 @@ static inline bool pfmemalloc_match(stru
 }
 
 /*
- * Check the page->freelist of a page and either transfer the freelist to the
+ * Check the ->freelist of a page and either transfer the freelist to the
  * per cpu freelist or deactivate the page.
  *
  * The page is still frozen if the return value is not NULL.
@@ -2221,18 +2228,18 @@ static inline void *get_freelist(struct
 	void *freelist;
 
 	do {
-		freelist = page->freelist;
-		counters = page->counters;
+		freelist = slub_data(page)->freelist;
+		counters = slub_data(page)->counters;
 
-		new.counters = counters;
-		VM_BUG_ON(!new.frozen);
+		slub_data(&new)->counters = counters;
+		VM_BUG_ON(!slub_data(&new)->frozen);
 
-		new.inuse = page->objects;
-		new.frozen = freelist != NULL;
+		slub_data(&new)->inuse = slub_data(page)->objects;
+		slub_data(&new)->frozen = freelist != NULL;
 
 	} while (!__cmpxchg_double_slab(s, page,
 		freelist, counters,
-		NULL, new.counters,
+		NULL, slub_data(&new)->counters,
 		"get_freelist"));
 
 	return freelist;
@@ -2319,7 +2326,7 @@ load_freelist:
 	 * page is pointing to the page from which the objects are obtained.
 	 * That page must be frozen for per cpu allocations to work.
 	 */
-	VM_BUG_ON(!c->page->frozen);
+	VM_BUG_ON(!slub_data(c->page)->frozen);
 	c->freelist = get_freepointer(s, freelist);
 	c->tid = next_tid(c->tid);
 	local_irq_restore(flags);
@@ -2533,13 +2540,13 @@ static void __slab_free(struct kmem_cach
 			spin_unlock_irqrestore(&n->list_lock, flags);
 			n = NULL;
 		}
-		prior = page->freelist;
-		counters = page->counters;
+		prior = slub_data(page)->freelist;
+		counters = slub_data(page)->counters;
 		set_freepointer(s, object, prior);
-		new.counters = counters;
-		was_frozen = new.frozen;
-		new.inuse--;
-		if ((!new.inuse || !prior) && !was_frozen) {
+		slub_data(&new)->counters = counters;
+		was_frozen = slub_data(&new)->frozen;
+		slub_data(&new)->inuse--;
+		if ((!slub_data(&new)->inuse || !prior) && !was_frozen) {
 
 			if (kmem_cache_has_cpu_partial(s) && !prior)
 
@@ -2549,7 +2556,7 @@ static void __slab_free(struct kmem_cach
 				 * We can defer the list move and instead
 				 * freeze it.
 				 */
-				new.frozen = 1;
+				slub_data(&new)->frozen = 1;
 
 			else { /* Needs to be taken off a list */
 
@@ -2569,7 +2576,7 @@ static void __slab_free(struct kmem_cach
 
 	} while (!cmpxchg_double_slab(s, page,
 		prior, counters,
-		object, new.counters,
+		object, slub_data(&new)->counters,
 		"__slab_free"));
 
 	if (likely(!n)) {
@@ -2578,7 +2585,7 @@ static void __slab_free(struct kmem_cach
 		 * If we just froze the page then put it onto the
 		 * per cpu partial list.
 		 */
-		if (new.frozen && !was_frozen) {
+		if (slub_data(&new)->frozen && !was_frozen) {
 			put_cpu_partial(s, page, 1);
 			stat(s, CPU_PARTIAL_FREE);
 		}
@@ -2591,7 +2598,7 @@ static void __slab_free(struct kmem_cach
                 return;
         }
 
-	if (unlikely(!new.inuse && n->nr_partial > s->min_partial))
+	if (unlikely(!slub_data(&new)->inuse && n->nr_partial > s->min_partial))
 		goto slab_empty;
 
 	/*
@@ -2877,18 +2884,18 @@ static void early_kmem_cache_node_alloc(
 				"in order to be able to continue\n");
 	}
 
-	n = page->freelist;
+	n = slub_data(page)->freelist;
 	BUG_ON(!n);
-	page->freelist = get_freepointer(kmem_cache_node, n);
-	page->inuse = 1;
-	page->frozen = 0;
+	slub_data(page)->freelist = get_freepointer(kmem_cache_node, n);
+	slub_data(page)->inuse = 1;
+	slub_data(page)->frozen = 0;
 	kmem_cache_node->node[node] = n;
 #ifdef CONFIG_SLUB_DEBUG
 	init_object(kmem_cache_node, n, SLUB_RED_ACTIVE);
 	init_tracking(kmem_cache_node, n);
 #endif
 	init_kmem_cache_node(n);
-	inc_slabs_node(kmem_cache_node, node, page->objects);
+	inc_slabs_node(kmem_cache_node, node, slub_data(page)->objects);
 
 	add_partial(n, page, DEACTIVATE_TO_HEAD);
 }
@@ -3144,7 +3151,7 @@ static void list_slab_objects(struct kme
 #ifdef CONFIG_SLUB_DEBUG
 	void *addr = page_address(page);
 	void *p;
-	unsigned long *map = kzalloc(BITS_TO_LONGS(page->objects) *
+	unsigned long *map = kzalloc(BITS_TO_LONGS(slub_data(page)->objects) *
 				     sizeof(long), GFP_ATOMIC);
 	if (!map)
 		return;
@@ -3152,7 +3159,7 @@ static void list_slab_objects(struct kme
 	slab_lock(page);
 
 	get_map(s, page, map);
-	for_each_object(p, s, addr, page->objects) {
+	for_each_object(p, s, addr, slub_data(page)->objects) {
 
 		if (!test_bit(slab_index(p, s, addr), map)) {
 			printk(KERN_ERR "INFO: Object 0x%p @offset=%tu\n",
@@ -3175,7 +3182,7 @@ static void free_partial(struct kmem_cac
 	struct page *page, *h;
 
 	list_for_each_entry_safe(page, h, &n->partial, lru) {
-		if (!page->inuse) {
+		if (!slub_data(page)->inuse) {
 			remove_partial(n, page);
 			discard_slab(s, page);
 		} else {
@@ -3412,11 +3419,11 @@ int kmem_cache_shrink(struct kmem_cache
 		 * Build lists indexed by the items in use in each slab.
 		 *
 		 * Note that concurrent frees may occur while we hold the
-		 * list_lock. page->inuse here is the upper limit.
+		 * list_lock.  ->inuse here is the upper limit.
 		 */
 		list_for_each_entry_safe(page, t, &n->partial, lru) {
-			list_move(&page->lru, slabs_by_inuse + page->inuse);
-			if (!page->inuse)
+			list_move(&page->lru, slabs_by_inuse + slub_data(page)->inuse);
+			if (!slub_data(page)->inuse)
 				n->nr_partial--;
 		}
 
@@ -3855,12 +3862,12 @@ void *__kmalloc_node_track_caller(size_t
 #ifdef CONFIG_SYSFS
 static int count_inuse(struct page *page)
 {
-	return page->inuse;
+	return slub_data(page)->inuse;
 }
 
 static int count_total(struct page *page)
 {
-	return page->objects;
+	return slub_data(page)->objects;
 }
 #endif
 
@@ -3876,16 +3883,16 @@ static int validate_slab(struct kmem_cac
 		return 0;
 
 	/* Now we know that a valid freelist exists */
-	bitmap_zero(map, page->objects);
+	bitmap_zero(map, slub_data(page)->objects);
 
 	get_map(s, page, map);
-	for_each_object(p, s, addr, page->objects) {
+	for_each_object(p, s, addr, slub_data(page)->objects) {
 		if (test_bit(slab_index(p, s, addr), map))
 			if (!check_object(s, page, p, SLUB_RED_INACTIVE))
 				return 0;
 	}
 
-	for_each_object(p, s, addr, page->objects)
+	for_each_object(p, s, addr, slub_data(page)->objects)
 		if (!test_bit(slab_index(p, s, addr), map))
 			if (!check_object(s, page, p, SLUB_RED_ACTIVE))
 				return 0;
@@ -4086,10 +4093,10 @@ static void process_slab(struct loc_trac
 	void *addr = page_address(page);
 	void *p;
 
-	bitmap_zero(map, page->objects);
+	bitmap_zero(map, slub_data(page)->objects);
 	get_map(s, page, map);
 
-	for_each_object(p, s, addr, page->objects)
+	for_each_object(p, s, addr, slub_data(page)->objects)
 		if (!test_bit(slab_index(p, s, addr), map))
 			add_location(t, s, get_track(s, p, alloc));
 }
@@ -4288,9 +4295,9 @@ static ssize_t show_slab_objects(struct
 
 			node = page_to_nid(page);
 			if (flags & SO_TOTAL)
-				x = page->objects;
+				x = slub_data(page)->objects;
 			else if (flags & SO_OBJECTS)
-				x = page->inuse;
+				x = slub_data(page)->inuse;
 			else
 				x = 1;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
