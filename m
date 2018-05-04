Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6BD9D6B026C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 14:33:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3so663877pfe.15
        for <linux-mm@kvack.org>; Fri, 04 May 2018 11:33:26 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v2-v6si13336032pge.105.2018.05.04.11.33.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 11:33:22 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 05/17] mm: Move 'private' union within struct page
Date: Fri,  4 May 2018 11:33:06 -0700
Message-Id: <20180504183318.14415-6-willy@infradead.org>
In-Reply-To: <20180504183318.14415-1-willy@infradead.org>
References: <20180504183318.14415-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

By moving page->private to the fourth word of struct page, we can put
the SLUB counters in the same word as SLAB's s_mem and still do the
cmpxchg_double trick.  Now the SLUB counters no longer overlap with the
mapcount or refcount so we can drop the call to page_mapcount_reset()
and simplify set_page_slub_counters() to a single line.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_types.h | 56 ++++++++++++++++++----------------------
 mm/slub.c                | 20 ++------------
 2 files changed, 27 insertions(+), 49 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e97a310a6abe..23378a789af4 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -65,15 +65,9 @@ struct hmm;
  */
 #ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
 #define _struct_page_alignment	__aligned(2 * sizeof(unsigned long))
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE)
-#define _slub_counter_t		unsigned long
 #else
-#define _slub_counter_t		unsigned int
-#endif
-#else /* !CONFIG_HAVE_ALIGNED_STRUCT_PAGE */
 #define _struct_page_alignment
-#define _slub_counter_t		unsigned int
-#endif /* !CONFIG_HAVE_ALIGNED_STRUCT_PAGE */
+#endif
 
 struct page {
 	/* First double word block */
@@ -95,6 +89,30 @@ struct page {
 		/* page_deferred_list().prev	-- second tail page */
 	};
 
+	union {
+		/*
+		 * Mapping-private opaque data:
+		 * Usually used for buffer_heads if PagePrivate
+		 * Used for swp_entry_t if PageSwapCache
+		 * Indicates order in the buddy system if PageBuddy
+		 */
+		unsigned long private;
+#if USE_SPLIT_PTE_PTLOCKS
+#if ALLOC_SPLIT_PTLOCKS
+		spinlock_t *ptl;
+#else
+		spinlock_t ptl;
+#endif
+#endif
+		void *s_mem;			/* slab first object */
+		unsigned long counters;		/* SLUB */
+		struct {			/* SLUB */
+			unsigned inuse:16;
+			unsigned objects:15;
+			unsigned frozen:1;
+		};
+	};
+
 	union {
 		/*
 		 * If the page is neither PageSlab nor mappable to userspace,
@@ -104,13 +122,7 @@ struct page {
 		 */
 		unsigned int page_type;
 
-		_slub_counter_t counters;
 		unsigned int active;		/* SLAB */
-		struct {			/* SLUB */
-			unsigned inuse:16;
-			unsigned objects:15;
-			unsigned frozen:1;
-		};
 		int units;			/* SLOB */
 
 		struct {			/* Page cache */
@@ -179,24 +191,6 @@ struct page {
 #endif
 	};
 
-	union {
-		/*
-		 * Mapping-private opaque data:
-		 * Usually used for buffer_heads if PagePrivate
-		 * Used for swp_entry_t if PageSwapCache
-		 * Indicates order in the buddy system if PageBuddy
-		 */
-		unsigned long private;
-#if USE_SPLIT_PTE_PTLOCKS
-#if ALLOC_SPLIT_PTLOCKS
-		spinlock_t *ptl;
-#else
-		spinlock_t ptl;
-#endif
-#endif
-		void *s_mem;			/* slab first object */
-	};
-
 #ifdef CONFIG_MEMCG
 	struct mem_cgroup *mem_cgroup;
 #endif
diff --git a/mm/slub.c b/mm/slub.c
index 7fc13c46e975..05ca612a5fe6 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -356,21 +356,6 @@ static __always_inline void slab_unlock(struct page *page)
 	__bit_spin_unlock(PG_locked, &page->flags);
 }
 
-static inline void set_page_slub_counters(struct page *page, unsigned long counters_new)
-{
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
-}
-
 /* Interrupts must be disabled (for the fallback code to work right) */
 static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 		void *freelist_old, unsigned long counters_old,
@@ -392,7 +377,7 @@ static inline bool __cmpxchg_double_slab(struct kmem_cache *s, struct page *page
 		if (page->freelist == freelist_old &&
 					page->counters == counters_old) {
 			page->freelist = freelist_new;
-			set_page_slub_counters(page, counters_new);
+			page->counters = counters_new;
 			slab_unlock(page);
 			return true;
 		}
@@ -431,7 +416,7 @@ static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
 		if (page->freelist == freelist_old &&
 					page->counters == counters_old) {
 			page->freelist = freelist_new;
-			set_page_slub_counters(page, counters_new);
+			page->counters = counters_new;
 			slab_unlock(page);
 			local_irq_restore(flags);
 			return true;
@@ -1689,7 +1674,6 @@ static void __free_slab(struct kmem_cache *s, struct page *page)
 	__ClearPageSlabPfmemalloc(page);
 	__ClearPageSlab(page);
 
-	page_mapcount_reset(page);
 	page->mapping = NULL;
 	if (current->reclaim_state)
 		current->reclaim_state->reclaimed_slab += pages;
-- 
2.17.0
