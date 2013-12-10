Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5686B006E
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 15:46:49 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so8030561pdi.19
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:46:49 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [143.182.124.37])
        by mx.google.com with ESMTP id qx4si11392185pbc.285.2013.12.10.12.46.42
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 12:46:43 -0800 (PST)
Subject: [PATCH] [RFC] mm: slab: separate slab_page from 'struct page'
From: Dave Hansen <dave@sr71.net>
Date: Tue, 10 Dec 2013 12:46:41 -0800
Message-Id: <20131210204641.3CB515AE@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, cl@gentwo.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave@sr71.net>


This is a major RFC.  *SHOULD* we do something like this?

'struct page' is a 140-line crime against humanity at this point.
Most of the blame for its girth lies at the feet of the slab
allocators.  While the effort at reuse of unused 'struct page'
fields is laudable, the result is:

struct page {
       struct {
               union {
                       struct {
                               union {
                                       struct {
                                       };
                               };
                       };
               };
       };
       union {
               struct {

               };
       };
       union {
       };
}

What the slab allocators really want is a new structure that
shares very little with 'struct page'.  So, let's give that to
them: 'struct slab_page'.  As far as I can tell, page-flags is
just about the only thing in 'struct page' that the slab code
really cares about.  As long as flags in 'slab_page' and
'struct page' line up, we should be able to cast pointers back
and forth without anything awful happening.  Note: I even
enforce this sharing with a BUILD_BUG_ON(), so this *can* be as
safe the unions were.

At least for slab, this doesn't turn out to be too big of a deal:
it's only 8 casts.  slub looks like it'll be a bit more work, but
still manageable.

Note: there are a couple more patches if you want to actually run
this.  page->lru vs. page->list needs to get resolved too.

---

 linux.git-davehans/include/linux/mm_types.h |  169 ++++++++++++++--------------
 linux.git-davehans/mm/slab.c                |  104 ++++++++++-------
 linux.git-davehans/mm/slab.h                |    4 
 3 files changed, 155 insertions(+), 122 deletions(-)

diff -puN include/linux/mm_types.h~make-separate-slab-page include/linux/mm_types.h
--- linux.git/include/linux/mm_types.h~make-separate-slab-page	2013-12-10 12:32:59.586866828 -0800
+++ linux.git-davehans/include/linux/mm_types.h	2013-12-10 12:34:54.081949808 -0800
@@ -44,93 +44,35 @@ struct page {
 	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
-	union {
-		struct address_space *mapping;	/* If low bit clear, points to
-						 * inode address_space, or NULL.
-						 * If page mapped as anonymous
-						 * memory, low bit is set, and
-						 * it points to anon_vma object:
-						 * see PAGE_MAPPING_ANON below.
-						 */
-		void *s_mem;			/* slab first object */
-	};
+	struct address_space *mapping;	/* If low bit clear, points to
+					 * inode address_space, or NULL.
+					 * If page mapped as anonymous
+					 * memory, low bit is set, and
+					 * it points to anon_vma object:
+					 * see PAGE_MAPPING_ANON below.
+					 */
 
 	/* Second double word */
-	struct {
-		union {
-			pgoff_t index;		/* Our offset within mapping. */
-			void *freelist;		/* sl[aou]b first free object */
-		};
-
-		union {
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-			/* Used for cmpxchg_double in slub */
-			unsigned long counters;
-#else
-			/*
-			 * Keep _count separate from slub cmpxchg_double data.
-			 * As the rest of the double word is protected by
-			 * slab_lock but _count is not.
-			 */
-			unsigned counters;
-#endif
-
-			struct {
-
-				union {
-					/*
-					 * Count of ptes mapped in
-					 * mms, to show when page is
-					 * mapped & limit reverse map
-					 * searches.
-					 *
-					 * Used also for tail pages
-					 * refcounting instead of
-					 * _count. Tail pages cannot
-					 * be mapped and keeping the
-					 * tail page _count zero at
-					 * all times guarantees
-					 * get_page_unless_zero() will
-					 * never succeed on tail
-					 * pages.
-					 */
-					atomic_t _mapcount;
+	pgoff_t index;		/* Our offset within mapping. */
 
-					struct { /* SLUB */
-						unsigned inuse:16;
-						unsigned objects:15;
-						unsigned frozen:1;
-					};
-					int units;	/* SLOB */
-				};
-				atomic_t _count;		/* Usage count, see below. */
-			};
-			unsigned int active;	/* SLAB */
-		};
-	};
+	/*
+	 * Count of ptes mapped in mms, to show when page is
+	 * mapped & limit reverse map searches.
+	 *
+	 * Used also for tail pages refcounting instead of
+	 * _count. Tail pages cannot be mapped and keeping the
+	 * tail page _count zero at all times guarantees
+	 * get_page_unless_zero() will never succeed on tail
+	 * pages.
+	 */
+	atomic_t _mapcount;
+	atomic_t _count;		/* Usage count, see below. */
 
 	/* Third double word block */
 	union {
 		struct list_head lru;	/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
 					 */
-		struct {		/* slub per cpu partial pages */
-			struct page *next;	/* Next partial slab */
-#ifdef CONFIG_64BIT
-			int pages;	/* Nr of partial slabs left */
-			int pobjects;	/* Approximate # of objects */
-#else
-			short int pages;
-			short int pobjects;
-#endif
-		};
-
-		struct list_head list;	/* slobs list of pages */
-		struct slab *slab_page; /* slab fields */
-		struct rcu_head rcu_head;	/* Used by SLAB
-						 * when destroying via RCU
-						 */
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
 		pgtable_t pmd_huge_pte; /* protected by page->ptl */
 #endif
@@ -152,7 +94,6 @@ struct page {
 		spinlock_t ptl;
 #endif
 #endif
-		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
 		struct page *first_page;	/* Compound tail pages */
 	};
 
@@ -188,6 +129,76 @@ struct page {
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
+ * on double words work. The SLUB allocator can make use of such a feature.
+ */
+#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
+	__aligned(2 * sizeof(unsigned long))
+#endif
+;
+
+struct slab_page {
+	/* First double word block */
+	unsigned long flags;		/* Atomic flags, some possibly
+					 * updated asynchronously */
+	void *s_mem;			/* slab first object */
+
+	/* Second double word */
+	void *freelist;		/* sl[aou]b first free object */
+
+	union {
+#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
+	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+		/* Used for cmpxchg_double in slub */
+		unsigned long counters;
+#else
+		/*
+		 * Keep _count separate from slub cmpxchg_double data.
+		 * As the rest of the double word is protected by
+		 * slab_lock but _count is not.
+		 */
+		unsigned counters;
+#endif
+
+		struct {
+
+			union {
+				struct { /* SLUB */
+					unsigned inuse:16;
+					unsigned objects:15;
+					unsigned frozen:1;
+				};
+				int units;	/* SLOB */
+			};
+		};
+		unsigned int active;	/* SLAB */
+	};
+
+	/* Third double word block */
+	union {
+		struct {		/* slub per cpu partial pages */
+			struct page *next;	/* Next partial slab */
+#ifdef CONFIG_64BIT
+			int pages;	/* Nr of partial slabs left */
+			int pobjects;	/* Approximate # of objects */
+#else
+			short int pages;
+			short int pobjects;
+#endif
+		};
+
+		struct list_head list;	/* slobs list of pages */
+		struct slab *slab_page; /* slab fields */
+		struct rcu_head rcu_head;	/* Used by SLAB
+						 * when destroying via RCU
+						 */
+	};
+
+	/* Remainder is not double word aligned */
+	struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
+
+}
+/*
+ * The struct page can be forced to be double word aligned so that atomic ops
  * on double words work. The SLUB allocator can make use of such a feature.
  */
 #ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
diff -puN mm/slab.c~make-separate-slab-page mm/slab.c
--- linux.git/mm/slab.c~make-separate-slab-page	2013-12-10 12:32:59.588866917 -0800
+++ linux.git-davehans/mm/slab.c	2013-12-10 12:37:11.515049666 -0800
@@ -322,6 +322,21 @@ static void kmem_cache_node_init(struct
 #define STATS_INC_FREEMISS(x)	do { } while (0)
 #endif
 
+#define SLAB_PAGE_CHECK(_field) 	\
+	BUILD_BUG_ON(offsetof(struct page, _field) !=	\
+		     offsetof(struct slab_page, _field))
+/*
+ * Since we essentially share storage space between 'struct page'
+ * and 'slab_page', we need to make sure that the shared fields
+ * are present in the same place in both structures.  unions are
+ * another way to do this, of course, but this results in cleaner
+ * and more readable structures.
+ */
+void slab_build_checks(void)
+{
+	SLAB_PAGE_CHECK(flags);
+}
+
 #if DEBUG
 
 /*
@@ -386,11 +401,11 @@ static bool slab_max_order_set __initdat
 
 static inline struct kmem_cache *virt_to_cache(const void *obj)
 {
-	struct page *page = virt_to_head_page(obj);
+	struct slab_page *page = (struct slab_page *)virt_to_head_page(obj);
 	return page->slab_cache;
 }
 
-static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
+static inline void *index_to_obj(struct kmem_cache *cache, struct slab_page *page,
 				 unsigned int idx)
 {
 	return page->s_mem + cache->size * idx;
@@ -403,7 +418,7 @@ static inline void *index_to_obj(struct
  *   reciprocal_divide(offset, cache->reciprocal_buffer_size)
  */
 static inline unsigned int obj_to_index(const struct kmem_cache *cache,
-					const struct page *page, void *obj)
+					const struct slab_page *page, void *obj)
 {
 	u32 offset = (obj - page->s_mem);
 	return reciprocal_divide(offset, cache->reciprocal_buffer_size);
@@ -748,9 +763,9 @@ static struct array_cache *alloc_arrayca
 	return nc;
 }
 
-static inline bool is_slab_pfmemalloc(struct page *page)
+static inline bool is_slab_pfmemalloc(struct slab_page *page)
 {
-	return PageSlabPfmemalloc(page);
+	return PageSlabPfmemalloc((struct page *)page);
 }
 
 /* Clears pfmemalloc_active if no slabs have pfmalloc set */
@@ -758,7 +773,7 @@ static void recheck_pfmemalloc_active(st
 						struct array_cache *ac)
 {
 	struct kmem_cache_node *n = cachep->node[numa_mem_id()];
-	struct page *page;
+	struct slab_page *page;
 	unsigned long flags;
 
 	if (!pfmemalloc_active)
@@ -1428,7 +1443,13 @@ void __init kmem_cache_init(void)
 {
 	int i;
 
-	BUILD_BUG_ON(sizeof(((struct page *)NULL)->list) <
+	/*
+	 * This check makes no sense.  The ->list and ->rcu_head
+	 * are delcared in a union, so even if the list shrunk
+	 * or the rcu_head grew, everything would still work.
+	 * So what is this *ACTUALLY* testing for?
+	 */
+	BUILD_BUG_ON(sizeof(((struct slab_page *)NULL)->list) <
 					sizeof(struct rcu_head));
 	kmem_cache = &kmem_cache_boot;
 	setup_node_pointer(kmem_cache);
@@ -1605,7 +1626,7 @@ static noinline void
 slab_out_of_memory(struct kmem_cache *cachep, gfp_t gfpflags, int nodeid)
 {
 	struct kmem_cache_node *n;
-	struct page *page;
+	struct slab_page *page;
 	unsigned long flags;
 	int node;
 
@@ -1654,7 +1675,7 @@ slab_out_of_memory(struct kmem_cache *ca
  * did not request dmaable memory, we might get it, but that
  * would be relatively rare and ignorable.
  */
-static struct page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
+static struct slab_page *kmem_getpages(struct kmem_cache *cachep, gfp_t flags,
 								int nodeid)
 {
 	struct page *page;
@@ -1696,14 +1717,15 @@ static struct page *kmem_getpages(struct
 			kmemcheck_mark_unallocated_pages(page, nr_pages);
 	}
 
-	return page;
+	return (struct slab_page *)page;
 }
 
 /*
  * Interface to system's page release.
  */
-static void kmem_freepages(struct kmem_cache *cachep, struct page *page)
+static void kmem_freepages(struct kmem_cache *cachep, struct slab_page *spage)
 {
+	struct page *page = (struct page *)spage;
 	const unsigned long nr_freed = (1 << cachep->gfporder);
 
 	kmemcheck_free_shadow(page, cachep->gfporder);
@@ -1730,9 +1752,9 @@ static void kmem_freepages(struct kmem_c
 static void kmem_rcu_free(struct rcu_head *head)
 {
 	struct kmem_cache *cachep;
-	struct page *page;
+	struct slab_page *page;
 
-	page = container_of(head, struct page, rcu_head);
+	page = container_of(head, struct slab_page, rcu_head);
 	cachep = page->slab_cache;
 
 	kmem_freepages(cachep, page);
@@ -1884,7 +1906,7 @@ static void check_poison_obj(struct kmem
 		/* Print some data about the neighboring objects, if they
 		 * exist:
 		 */
-		struct page *page = virt_to_head_page(objp);
+		struct slab_page *page = virt_to_head_page(objp);
 		unsigned int objnr;
 
 		objnr = obj_to_index(cachep, page, objp);
@@ -1908,7 +1930,7 @@ static void check_poison_obj(struct kmem
 
 #if DEBUG
 static void slab_destroy_debugcheck(struct kmem_cache *cachep,
-						struct page *page)
+						struct slab_page *page)
 {
 	int i;
 	for (i = 0; i < cachep->num; i++) {
@@ -1938,7 +1960,7 @@ static void slab_destroy_debugcheck(stru
 }
 #else
 static void slab_destroy_debugcheck(struct kmem_cache *cachep,
-						struct page *page)
+						struct slab_page *page)
 {
 }
 #endif
@@ -1952,7 +1974,7 @@ static void slab_destroy_debugcheck(stru
  * Before calling the slab must have been unlinked from the cache.  The
  * cache-lock is not held/needed.
  */
-static void slab_destroy(struct kmem_cache *cachep, struct page *page)
+static void slab_destroy(struct kmem_cache *cachep, struct slab_page *page)
 {
 	void *freelist;
 
@@ -2412,7 +2434,7 @@ static int drain_freelist(struct kmem_ca
 {
 	struct list_head *p;
 	int nr_freed;
-	struct page *page;
+	struct slab_page *page;
 
 	nr_freed = 0;
 	while (nr_freed < tofree && !list_empty(&n->slabs_free)) {
@@ -2424,7 +2446,7 @@ static int drain_freelist(struct kmem_ca
 			goto out;
 		}
 
-		page = list_entry(p, struct page, list);
+		page = list_entry(p, struct slab_page, list);
 #if DEBUG
 		BUG_ON(page->active);
 #endif
@@ -2521,11 +2543,11 @@ int __kmem_cache_shutdown(struct kmem_ca
  * Hence we cannot have freelist_cache same as the original cache.
  */
 static void *alloc_slabmgmt(struct kmem_cache *cachep,
-				   struct page *page, int colour_off,
+				   struct slab_page *page, int colour_off,
 				   gfp_t local_flags, int nodeid)
 {
 	void *freelist;
-	void *addr = page_address(page);
+	void *addr = page_address((struct page *)page);
 
 	if (OFF_SLAB(cachep)) {
 		/* Slab management obj is off-slab. */
@@ -2542,13 +2564,13 @@ static void *alloc_slabmgmt(struct kmem_
 	return freelist;
 }
 
-static inline unsigned int *slab_freelist(struct page *page)
+static inline unsigned int *slab_freelist(struct slab_page *page)
 {
 	return (unsigned int *)(page->freelist);
 }
 
 static void cache_init_objs(struct kmem_cache *cachep,
-			    struct page *page)
+			    struct slab_page *page)
 {
 	int i;
 
@@ -2603,7 +2625,7 @@ static void kmem_flagcheck(struct kmem_c
 	}
 }
 
-static void *slab_get_obj(struct kmem_cache *cachep, struct page *page,
+static void *slab_get_obj(struct kmem_cache *cachep, struct slab_page *page,
 				int nodeid)
 {
 	void *objp;
@@ -2617,7 +2639,7 @@ static void *slab_get_obj(struct kmem_ca
 	return objp;
 }
 
-static void slab_put_obj(struct kmem_cache *cachep, struct page *page,
+static void slab_put_obj(struct kmem_cache *cachep, struct slab_page *page,
 				void *objp, int nodeid)
 {
 	unsigned int objnr = obj_to_index(cachep, page, objp);
@@ -2645,7 +2667,7 @@ static void slab_put_obj(struct kmem_cac
  * for the slab allocator to be able to lookup the cache and slab of a
  * virtual address for kfree, ksize, and slab debugging.
  */
-static void slab_map_pages(struct kmem_cache *cache, struct page *page,
+static void slab_map_pages(struct kmem_cache *cache, struct slab_page *page,
 			   void *freelist)
 {
 	page->slab_cache = cache;
@@ -2657,7 +2679,7 @@ static void slab_map_pages(struct kmem_c
  * kmem_cache_alloc() when there are no active objs left in a cache.
  */
 static int cache_grow(struct kmem_cache *cachep,
-		gfp_t flags, int nodeid, struct page *page)
+		gfp_t flags, int nodeid, struct slab_page *page)
 {
 	void *freelist;
 	size_t offset;
@@ -2776,7 +2798,7 @@ static void *cache_free_debugcheck(struc
 				   unsigned long caller)
 {
 	unsigned int objnr;
-	struct page *page;
+	struct slab_page *page;
 
 	BUG_ON(virt_to_cache(objp) != cachep);
 
@@ -2854,7 +2876,7 @@ retry:
 
 	while (batchcount > 0) {
 		struct list_head *entry;
-		struct page *page;
+		struct slab_page *page;
 		/* Get slab alloc is to come from. */
 		entry = n->slabs_partial.next;
 		if (entry == &n->slabs_partial) {
@@ -2864,7 +2886,7 @@ retry:
 				goto must_grow;
 		}
 
-		page = list_entry(entry, struct page, list);
+		page = list_entry(entry, struct slab_page, list);
 		check_spinlock_acquired(cachep);
 
 		/*
@@ -3101,7 +3123,7 @@ retry:
 		 * We may trigger various forms of reclaim on the allowed
 		 * set and go into memory reserves if necessary.
 		 */
-		struct page *page;
+		struct slab_page *page;
 
 		if (local_flags & __GFP_WAIT)
 			local_irq_enable();
@@ -3113,7 +3135,7 @@ retry:
 			/*
 			 * Insert into the appropriate per node queues
 			 */
-			nid = page_to_nid(page);
+			nid = page_to_nid((struct page *)page);
 			if (cache_grow(cache, flags, nid, page)) {
 				obj = ____cache_alloc_node(cache,
 					flags | GFP_THISNODE, nid);
@@ -3143,7 +3165,7 @@ static void *____cache_alloc_node(struct
 				int nodeid)
 {
 	struct list_head *entry;
-	struct page *page;
+	struct slab_page *page;
 	struct kmem_cache_node *n;
 	void *obj;
 	int x;
@@ -3163,7 +3185,7 @@ retry:
 			goto must_grow;
 	}
 
-	page = list_entry(entry, struct page, list);
+	page = list_entry(entry, struct slab_page, list);
 	check_spinlock_acquired_node(cachep, nodeid);
 
 	STATS_INC_NODEALLOCS(cachep);
@@ -3330,12 +3352,12 @@ static void free_block(struct kmem_cache
 
 	for (i = 0; i < nr_objects; i++) {
 		void *objp;
-		struct page *page;
+		struct slab_page *page;
 
 		clear_obj_pfmemalloc(&objpp[i]);
 		objp = objpp[i];
 
-		page = virt_to_head_page(objp);
+		page = (struct slab_page *)virt_to_head_page(objp);
 		n = cachep->node[node];
 		list_del(&page->list);
 		check_spinlock_acquired_node(cachep, node);
@@ -3402,9 +3424,9 @@ free_done:
 
 		p = n->slabs_free.next;
 		while (p != &(n->slabs_free)) {
-			struct page *page;
+			struct slab_page *page;
 
-			page = list_entry(p, struct page, list);
+			page = list_entry(p, struct slab_page, list);
 			BUG_ON(page->active);
 
 			i++;
@@ -4009,7 +4031,7 @@ out:
 #ifdef CONFIG_SLABINFO
 void get_slabinfo(struct kmem_cache *cachep, struct slabinfo *sinfo)
 {
-	struct page *page;
+	struct slab_page *page;
 	unsigned long active_objs;
 	unsigned long num_objs;
 	unsigned long active_slabs = 0;
@@ -4198,7 +4220,7 @@ static inline int add_caller(unsigned lo
 }
 
 static void handle_slab(unsigned long *n, struct kmem_cache *c,
-						struct page *page)
+						struct slab_page *page)
 {
 	void *p;
 	int i, j;
@@ -4242,7 +4264,7 @@ static void show_symbol(struct seq_file
 static int leaks_show(struct seq_file *m, void *p)
 {
 	struct kmem_cache *cachep = list_entry(p, struct kmem_cache, list);
-	struct page *page;
+	struct slab_page *page;
 	struct kmem_cache_node *n;
 	const char *name;
 	unsigned long *x = m->private;
diff -puN mm/slab.h~make-separate-slab-page mm/slab.h
--- linux.git/mm/slab.h~make-separate-slab-page	2013-12-10 12:33:28.357144182 -0800
+++ linux.git-davehans/mm/slab.h	2013-12-10 12:33:28.361144360 -0800
@@ -220,7 +220,7 @@ static inline struct kmem_cache *memcg_r
 static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 {
 	struct kmem_cache *cachep;
-	struct page *page;
+	struct slab_page *page;
 
 	/*
 	 * When kmemcg is not being used, both assignments should return the
@@ -232,7 +232,7 @@ static inline struct kmem_cache *cache_f
 	if (!memcg_kmem_enabled() && !unlikely(s->flags & SLAB_DEBUG_FREE))
 		return s;
 
-	page = virt_to_head_page(x);
+	page = (struct slab_page *)virt_to_head_page(x);
 	cachep = page->slab_cache;
 	if (slab_equal_or_root(cachep, s))
 		return cachep;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
