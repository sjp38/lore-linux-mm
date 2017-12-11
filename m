Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D50156B0069
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 01:37:55 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j3so13850638pfh.16
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 22:37:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g5si9399555pgc.555.2017.12.10.22.37.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Dec 2017 22:37:53 -0800 (PST)
Received: from willy by bombadil.infradead.org with local (Exim 4.87 #1 (Red Hat Linux))
	id 1eOHir-0002ZJ-6p
	for linux-mm@kvack.org; Mon, 11 Dec 2017 06:37:53 +0000
Date: Sun, 10 Dec 2017 22:37:53 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: New layout for struct page
Message-ID: <20171211063753.GB25236@bombadil.infradead.org>
References: <20171208013139.GG26792@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208013139.GG26792@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Thu, Dec 07, 2017 at 05:31:39PM -0800, Matthew Wilcox wrote:
> Dave Hansen and I talked about this a while ago.  I was trying to
> understand something in the slab allocator today and thought I'd have
> another crack at it.  I also documented my understanding of what the
> rules are for using struct page.

I kept going with this and ended up with something that's maybe more
interesting -- a new layout for struct page.

Advantages:
 - Simpler struct definitions
 - Compound pages may now be allocated of order 1 (currently, tail pages
   1 and 2 both contain information).
 - page_deferred_list is now really defined in the struct instead of only
   in comments and code.
 - page_deferred_list doesn't conflict with tail2->index, which would
   cause problems putting it in the page cache.  Actually, I don't see
   how shmem_add_to_page_cache of a transhuge page doesn't provoke a
   BUG in filemap_fault()?  VM_BUG_ON_PAGE(page->index != offset, page)
   ought to trigger.

Disadvantages
 - If adding a new variation to struct page, harder to tell where refcount
   and compound_head land in your struct.
 - Need to remember that 'flags' is defined in the top level 'struct page'
   and not in any of the layouts.
   - Can do a variant of this with flags explicitly in each layout if
     preferred.
 - Need to explicitly define padding in layouts.

I haven't changed any code yet.  I wanted to get feedback from Christoph
and Kirill before going further.

The new layout keeps struct page the same size as it is currently.  Mostly
the only things that have changed are compound pages.  slab has not changed
layout at all.

In the two tables below, the first column is the starting byte of the
named element.  The next three columns are after the patch, and the last
two are before the patch.  The annotation (1) means this field only has
that meaning in the first tail page; the other fields are used in all
tail pages.  The head page of a compound page uses all the fields the
same way as a non-compound page.

---+------------+------------------------------------+-------------------+
 B | slab       | page cache | tail pages            | old tail          |
---+------------+------------------------------------+-------------------+
 0 |                flags                            |                   |
 4 |                  "                              |                   |
 8 | s_mem      |          index                     | compound_mapcount |
12 | "          |            "                       | --                |
16 | freelist   | mapping    | dtor / order (1)      |                   |
20 | "          | "          | --                    |                   |
24 | counters   | mapcount   | compound_mapcount (1) | --                |
28 | "          | refcount   | --                    | --                |
32 | next       | lru        | compound_head         | compound_head     |
36 | "          | "          | "                     | "                 |
40 | pages      | "          | deferred_list (1)     | dtor              |
44 | pobjects   | "          | "                     | order             |
48 | slab_cache | private    | "                     | --                |
52 | "          | "          | "                     | --                |
---+------------+------------+-----------------------+-------------------+

---+------------+--------------------------------+
 B | slab       | page cache | compound tail     |
---+------------+--------------------------------+
 0 |                flags                        |
 4 | s_mem      |          index                 |
 8 | freelist   | mapping    | dtor/ order       |
12 | counters   | mapcount   | compound_mapcount |
16 | --         | refcount   | --                |
20 | next       | lru        | compound_head     |
24 | pg/pobj    | "          | deferred_list     |
28 | slab_cache | private    | "                 |
---+------------+------------+-------------------+


diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4e5e0e..5eee094a1bb7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -31,101 +31,56 @@ struct hmm;
  * it to keep track of whatever it is we are using the page for at the
  * moment. Note that we have no way to track which tasks are using
  * a page, though if it is a pagecache page, rmap structures can tell us
- * who is mapping it.
+ * who is mapping it. If you allocate the page using alloc_pages(), you
+ * can use some of the space in struct page for your own purposes.
  *
- * The objects in struct page are organized in double word blocks in
- * order to allows us to use atomic double word operations on portions
- * of struct page. That is currently only used by slub but the arrangement
- * allows the use of atomic double word operations on the flags/mapping
- * and lru list pointers also.
+ * Pages that were once in the page cache may be found under the RCU lock
+ * even after they have been recycled to a different purpose.  The page cache
+ * will read and writes some of the fields in struct page to lock the page,
+ * then check that it's still in the page cache.  It is vital that all users
+ * of struct page:
+ * 1. Use the first word as PageFlags.
+ * 2. Clear or preserve bit 0 of page->compound_head.  It is used as
+ *    PageTail for compound pages, and the page cache must not see false
+ *    positives.  Some users put a pointer here (guaranteed to be at least
+ *    4-byte aligned), other users avoid using the word altogether.
+ * 3. page->_refcount must either not be used, or must be used as a refcount,
+ *    in such a way that other CPUs temporarily incrementing and then
+ *    decrementing the refcount does not cause it to go to zero.  On receiving
+ *    the page from alloc_pages(), the refcount will be positive.
+ *
+ * If you allocate pages of order > 0, you can use the fields in the struct
+ * page associated with each page, but bear in mind that the pages may have
+ * been inserted individually into the page cache (or may have been a
+ * compound page in the page cache), so you must use the above three fields
+ * in a compatible way for each struct page.
+ *
+ * The layout of struct page is further complicated by the slub optimisation
+ * of using cmpxchg_double on 'freelist' and 'counters'.  This pair must be
+ * dword aligned.
  */
-struct page {
-	/* First double word block */
-	unsigned long flags;		/* Atomic flags, some possibly
-					 * updated asynchronously */
+struct slab_page_layout {
+	void *s_mem;			/* first object */
+	void *freelist;			/* first free object */
 	union {
-		struct address_space *mapping;	/* If low bit clear, points to
-						 * inode address_space, or NULL.
-						 * If page mapped as anonymous
-						 * memory, low bit is set, and
-						 * it points to anon_vma object
-						 * or KSM private structure. See
-						 * PAGE_MAPPING_ANON and
-						 * PAGE_MAPPING_KSM.
-						 */
-		void *s_mem;			/* slab first object */
-		atomic_t compound_mapcount;	/* first tail page */
-		/* page_deferred_list().next	 -- second tail page */
-	};
-
-	/* Second double word */
-	union {
-		pgoff_t index;		/* Our offset within mapping. */
-		void *freelist;		/* sl[aou]b first free object */
-		/* page_deferred_list().prev	-- second tail page */
-	};
-
-	union {
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
-	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
-		/* Used for cmpxchg_double in slub */
-		unsigned long counters;
-#else
-		/*
-		 * Keep _refcount separate from slub cmpxchg_double data.
-		 * As the rest of the double word is protected by slab_lock
-		 * but _refcount is not.
-		 */
-		unsigned counters;
-#endif
-		struct {
-
-			union {
-				/*
-				 * Count of ptes mapped in mms, to show when
-				 * page is mapped & limit reverse map searches.
-				 *
-				 * Extra information about page type may be
-				 * stored here for pages that are never mapped,
-				 * in which case the value MUST BE <= -2.
-				 * See page-flags.h for more details.
-				 */
-				atomic_t _mapcount;
-
-				unsigned int active;		/* SLAB */
-				struct {			/* SLUB */
-					unsigned inuse:16;
-					unsigned objects:15;
-					unsigned frozen:1;
-				};
-				int units;			/* SLOB */
-			};
-			/*
-			 * Usage count, *USE WRAPPER FUNCTION* when manual
-			 * accounting. See page_ref.h
-			 */
-			atomic_t _refcount;
+		unsigned long counters;	/* Used for cmpxchg_double in slub */
+		unsigned int active;		/* SLAB */
+		struct {			/* SLUB */
+			unsigned inuse:16;
+			unsigned objects:15;
+			unsigned frozen:1;
 		};
+		int units;			/* SLOB */
 	};
-
-	/*
-	 * Third double word block
-	 *
-	 * WARNING: bit 0 of the first word encode PageTail(). That means
-	 * the rest users of the storage space MUST NOT use the bit to
-	 * avoid collision and false-positive PageTail().
-	 */
+#ifndef CONFIG_64BIT
+	/* On 64-bit, _refcount is in the upper half of 'counters'. */
+	unsigned int s_refcount_pad;
+#endif
+	/* Bit 0 of the first word is used for PageTail(). */
 	union {
-		struct list_head lru;	/* Pageout list, eg. active_list
-					 * protected by zone_lru_lock !
-					 * Can be used as a generic list
-					 * by the page owner.
-					 */
-		struct dev_pagemap *pgmap; /* ZONE_DEVICE pages are never on an
-					    * lru or handled by a slab
-					    * allocator, this points to the
-					    * hosting device page map.
-					    */
+		struct rcu_head rcu_head;	/* Used by SLAB when freeing
+						 * the page via RCU.
+						 */
 		struct {		/* slub per cpu partial pages */
 			struct page *next;	/* Next partial slab */
 #ifdef CONFIG_64BIT
@@ -136,60 +91,83 @@ struct page {
 			short int pobjects;
 #endif
 		};
+	};
+	struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
+};
 
-		struct rcu_head rcu_head;	/* Used by SLAB
-						 * when destroying via RCU
-						 */
-		/* Tail pages of compound page */
-		struct {
-			unsigned long compound_head; /* If bit zero is set */
-
-			/* First tail page only */
-#ifdef CONFIG_64BIT
-			/*
-			 * On 64 bit system we have enough space in struct page
-			 * to encode compound_dtor and compound_order with
-			 * unsigned int. It can help compiler generate better or
-			 * smaller code on some archtectures.
-			 */
-			unsigned int compound_dtor;
-			unsigned int compound_order;
+struct page_table_layout {
+#if ALLOC_SPLIT_PTLOCKS
+	spinlock_t *ptl;
 #else
-			unsigned short int compound_dtor;
-			unsigned short int compound_order;
+	spinlock_t ptl;
 #endif
-		};
+	pgtable_t pmd_huge_pte; /* protected by page->ptl */
+};
 
-#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
+/*
+ * For tail pages of compound pages.  Some entries are used by all tail
+ * pages.  Entries marked with "1" are used on the first tail page only.
+ */
+struct compound_page_layout {
+	unsigned long c_index;				/* all */
+	union {
+		unsigned long c_padding;
 		struct {
-			unsigned long __pad;	/* do not overlay pmd_huge_pte
-						 * with compound_head to avoid
-						 * possible bit 0 collision.
-						 */
-			pgtable_t pmd_huge_pte; /* protected by page->ptl */
+			unsigned char compound_dtor;	/* 1 */
+			unsigned char compound_order;	/* 1 */
 		};
-#endif
 	};
+	atomic_t compound_mapcount;			/* 1 */
+	atomic_t c_refcount_pad;			/* not used */
+	unsigned long compound_head;			/* all */
+	struct list_head page_deferred_list;		/* 1 */
+};
+
+struct page_cache_page_layout {
+	pgoff_t index;		/* Our offset within mapping. */
+	/*
+	 * If low bit clear, points to inode address_space, or NULL.
+	 * If page mapped as anonymous memory, low bit is set, and
+	 * it points to anon_vma object or KSM private structure. See
+	 * PAGE_MAPPING_ANON and PAGE_MAPPING_KSM.
+	 */
+	struct address_space *mapping;
+
+	/*
+	 * Count of ptes mapped in mms, to show when
+	 * page is mapped & limit reverse map searches.
+	 *
+	 * Extra information about page type may be stored here
+	 * for pages that are never mapped, in which case the
+	 * value MUST BE <= -2.  See page-flags.h for more details.
+	 */
+	atomic_t _mapcount;
+
+	/*
+	 * Usage count, *USE WRAPPER FUNCTION* when manual
+	 * accounting. See page_ref.h
+	 */
+	atomic_t _refcount;
 
-	/* Remainder is not double word aligned */
 	union {
-		unsigned long private;		/* Mapping-private opaque data:
-					 	 * usually used for buffer_heads
-						 * if PagePrivate set; used for
-						 * swp_entry_t if PageSwapCache;
-						 * indicates order in the buddy
-						 * system if PG_buddy is set.
-						 */
-#if USE_SPLIT_PTE_PTLOCKS
-#if ALLOC_SPLIT_PTLOCKS
-		spinlock_t *ptl;
-#else
-		spinlock_t ptl;
-#endif
-#endif
-		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
+		/*
+		 * Pageout list, eg. active_list protected by zone_lru_lock.
+		 * Can be used as a generic list by the page owner.  Bit 0 is
+		 * always 0, so these pages are never PageTail.
+		 */
+		struct list_head lru;
+
+		/* ZONE_DEVICE pages are never on an lru */
+		struct dev_pagemap *pgmap;
 	};
 
+	/*
+	 * Mapping-private opaque data: used for buffer_heads
+	 * if PagePrivate set; used for swp_entry_t if PageSwapCache;
+	 * indicates order in the buddy system if PG_buddy is set.
+	 */
+	unsigned long private;
+
 #ifdef CONFIG_MEMCG
 	struct mem_cgroup *mem_cgroup;
 #endif
@@ -212,15 +190,28 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
-}
+};
+
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
  * on double words work. The SLUB allocator can make use of such a feature.
  */
 #ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
-	__aligned(2 * sizeof(unsigned long))
+#define _struct_page_alignment __aligned(2 * sizeof(unsigned long))
+#else
+#define _struct_page_alignment
 #endif
-;
+
+struct page {
+	/* Atomic flags, some possibly updated asynchronously */
+	unsigned long flags;
+	union {
+		struct page_cache_page_layout;
+		struct compound_page_layout;
+		struct slab_page_layout;
+		struct page_table_layout;
+	};
+} _struct_page_alignment;
 
 #define PAGE_FRAG_CACHE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
 #define PAGE_FRAG_CACHE_MAX_ORDER	get_order(PAGE_FRAG_CACHE_MAX_SIZE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
