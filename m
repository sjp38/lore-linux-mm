Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3776B6B0069
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 20:31:42 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j3so7217354pfh.16
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 17:31:42 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id x3si4546233pgt.395.2017.12.07.17.31.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 17:31:40 -0800 (PST)
Received: from willy by bombadil.infradead.org with local (Exim 4.87 #1 (Red Hat Linux))
	id 1eN7Vr-0006b0-Dz
	for linux-mm@kvack.org; Fri, 08 Dec 2017 01:31:39 +0000
Date: Thu, 7 Dec 2017 17:31:39 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [RFC] Split out struct slab_page from struct page
Message-ID: <20171208013139.GG26792@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Dave Hansen and I talked about this a while ago.  I was trying to
understand something in the slab allocator today and thought I'd have
another crack at it.  I also documented my understanding of what the
rules are for using struct page.

I don't know if this is in any way useful.  If people want me to keep
going, the next step would be creating 'struct page_cache_page' and
perhaps 'struct page_table_page', and turning it into:

struct page {
	union {
		struct page_cache_page;
		struct page_table_page;
		struct slab_page;
	};
} struct_page_alignment;

[1]

I'm in two minds about whether this is an improvement.  On the one hand,
it shows you clearly which fields are used by which user of struct page.
On the other hand, you have to play some nasty games with the padding
to get everything to line up nicely with the fields that the page cache
is going to touch.  If we do want this, I'm going to add a BUILD_BUG_ON
to make sure they stay lined up.

I think there's three different things in this patch that might be useful,
1. The added documentation, because I don't think I've seen these rules
all written out in one place before.
2. The 'struct_page_alignment' preprocessor hackery.
3. The actual split into separate pages.

Happy to submit separate patches for anything people want to see.

Something I noticed, but didn't fix is that the comment says "Third
double-word block".  That's true on 64-bit systems, but on 32-bit
systems, the second "double-word block" is actually three words; pgoff_t,
_mapcount, _refcount (and various other members unioned with those).

[1] Unf.  Now I've written that out, it occurs to me that this might work
out better:

struct page {
	unsigned long flags;
	union {
		struct page_cache_page;
		struct page_table_page;
		struct slab_page;
	};
} struct_page_alignment;

... and if we do *that*, then maybe we want to move all of the elements
the pagecache might touch into the common definition.

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4e5e0e..77e42b48c24f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -31,15 +31,95 @@ struct hmm;
  * it to keep track of whatever it is we are using the page for at the
  * moment. Note that we have no way to track which tasks are using
  * a page, though if it is a pagecache page, rmap structures can tell us
- * who is mapping it.
+ * who is mapping it. If you allocate the page using alloc_pages(), you
+ * can use some of the space in struct page for your own purposes.
  *
  * The objects in struct page are organized in double word blocks in
  * order to allows us to use atomic double word operations on portions
  * of struct page. That is currently only used by slub but the arrangement
  * allows the use of atomic double word operations on the flags/mapping
  * and lru list pointers also.
+ *
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
+ * compound page in the page cache), so you must not use the three fields
+ * above in any of the struct pages.
+ */
+
+/*
+ * The struct page can be forced to be double word aligned so that atomic ops
+ * on double words work. The SLUB allocator can make use of such a feature.
  */
+#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
+#define struct_page_alignment __aligned(2 * sizeof(unsigned long))
+#else
+#define struct_page_alignment
+#endif
+
+struct slab_page {
+	unsigned long s_flags;
+	void *s_mem;			/* first object */
+	void *freelist;			/* first free object */
+	union {
+#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE) && \
+	defined(CONFIG_HAVE_ALIGNED_STRUCT_PAGE)
+		unsigned long counters;	/* Used for cmpxchg_double in slub */
+#else
+		/*
+		 * Keep _refcount separate from slub cmpxchg_double data.
+		 * The rest of the double word is protected by slab_lock
+		 * but _refcount is not.
+		 */
+		unsigned counters;
+#endif
+		struct {
+			union {
+				unsigned int active;		/* SLAB */
+				struct {			/* SLUB */
+					unsigned inuse:16;
+					unsigned objects:15;
+					unsigned frozen:1;
+				};
+				int units;			/* SLOB */
+			};
+			int s_refcount_pad;	/* refcount goes here */
+		};
+	};
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
+	};
+	struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
+};
+
 struct page {
+union {
+	struct slab_page;
+struct {
 	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
@@ -53,7 +133,6 @@ struct page {
 						 * PAGE_MAPPING_ANON and
 						 * PAGE_MAPPING_KSM.
 						 */
-		void *s_mem;			/* slab first object */
 		atomic_t compound_mapcount;	/* first tail page */
 		/* page_deferred_list().next	 -- second tail page */
 	};
@@ -61,52 +140,24 @@ struct page {
 	/* Second double word */
 	union {
 		pgoff_t index;		/* Our offset within mapping. */
-		void *freelist;		/* sl[aou]b first free object */
 		/* page_deferred_list().prev	-- second tail page */
 	};
 
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
+	/*
+	 * Count of ptes mapped in mms, to show when
+	 * page is mapped & limit reverse map searches.
+	 *
+	 * Extra information about page type may be stored here
+	 * for pages that are never mapped, in which case the
+	 * value MUST BE <= -2.  See page-flags.h for more details.
+	 */
+	atomic_t _mapcount;
 
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
-		};
-	};
+	/*
+	 * Usage count, *USE WRAPPER FUNCTION* when manual
+	 * accounting. See page_ref.h
+	 */
+	atomic_t _refcount;
 
 	/*
 	 * Third double word block
@@ -126,19 +177,9 @@ struct page {
 					    * allocator, this points to the
 					    * hosting device page map.
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
 
-		struct rcu_head rcu_head;	/* Used by SLAB
-						 * when destroying via RCU
+		struct rcu_head rcu_head;	/* Used by SLAB when freeing
+						 * the page via RCU.
 						 */
 		/* Tail pages of compound page */
 		struct {
@@ -187,7 +228,6 @@ struct page {
 		spinlock_t ptl;
 #endif
 #endif
-		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
 	};
 
 #ifdef CONFIG_MEMCG
@@ -212,15 +252,9 @@ struct page {
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 	int _last_cpupid;
 #endif
-}
-/*
- * The struct page can be forced to be double word aligned so that atomic ops
- * on double words work. The SLUB allocator can make use of such a feature.
- */
-#ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
-	__aligned(2 * sizeof(unsigned long))
-#endif
-;
+};
+};
+} struct_page_alignment;
 
 #define PAGE_FRAG_CACHE_MAX_SIZE	__ALIGN_MASK(32768, ~PAGE_MASK)
 #define PAGE_FRAG_CACHE_MAX_ORDER	get_order(PAGE_FRAG_CACHE_MAX_SIZE)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
