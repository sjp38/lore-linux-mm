Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id F11A66B0005
	for <linux-mm@kvack.org>; Sun,  8 Apr 2018 10:23:39 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id m6-v6so4837690pln.8
        for <linux-mm@kvack.org>; Sun, 08 Apr 2018 07:23:39 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g1-v6si12290865plt.520.2018.04.08.07.23.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 08 Apr 2018 07:23:35 -0700 (PDT)
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1f5BEE-0005Fl-Ea
	for linux-mm@kvack.org; Sun, 08 Apr 2018 14:23:34 +0000
Date: Sun, 8 Apr 2018 07:23:34 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: [RFC] Group struct page elements
Message-ID: <20180408142334.GA29357@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


Please let me know if this way of expressing the layout of struct page
makes more sense to you.  I'm trying to make it easier for other users
to use some of the space in struct page, and without knowing the VM well,
it's hard to know what fields you can safely overload.

---

One of the confusing things about trying to use struct page is knowing
which fields are already in use by what.  Try and bring some order to
this by grouping the various fields together into sub-structs.  Verified
that the layout does not change with pahole.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 67 ++++++++++++++++++++++--------------------------
 1 file changed, 31 insertions(+), 36 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1c5dea402501..97ceec1c6e21 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -78,19 +78,18 @@ struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	union {
-		/* See page-flags.h for the definition of PAGE_MAPPING_FLAGS */
-		struct address_space *mapping;
-
-		void *s_mem;			/* slab first object */
+		struct {			/* Page cache */
+			/* See page-flags.h for PAGE_MAPPING_FLAGS */
+			struct address_space *mapping;
+			pgoff_t index;		/* Our offset within mapping. */
+		};
+		struct {			/* slab/slob/slub */
+			void *s_mem;		/* first object */
+			/* Second dword boundary */
+			void *freelist;		/* first free object */
+		};
 		atomic_t compound_mapcount;	/* first tail page */
-		/* page_deferred_list().next	 -- second tail page */
-	};
-
-	/* Second double word */
-	union {
-		pgoff_t index;		/* Our offset within mapping. */
-		void *freelist;		/* sl[aou]b first free object */
-		/* page_deferred_list().prev	-- second tail page */
+		struct list_head deferred_list;	/* second tail page */
 	};
 
 	union {
@@ -132,17 +131,27 @@ struct page {
 	 * avoid collision and false-positive PageTail().
 	 */
 	union {
-		struct list_head lru;	/* Pageout list, eg. active_list
-					 * protected by zone_lru_lock !
-					 * Can be used as a generic list
-					 * by the page owner.
-					 */
+		struct {	/* Page cache */
+			/**
+			 * @lru: Pageout list, eg. active_list protected by
+			 * zone_lru_lock.  Can be used as a generic list by
+			 * the page owner.
+			 */
+			struct list_head lru;
+			/*
+			 * Mapping-private opaque data:
+			 * Usually used for buffer_heads if PagePrivate
+			 * Used for swp_entry_t if PageSwapCache
+			 * Indicates order in the buddy system if PageBuddy
+			 */
+			unsigned long private;
+		};
 		struct dev_pagemap *pgmap; /* ZONE_DEVICE pages are never on an
 					    * lru or handled by a slab
 					    * allocator, this points to the
 					    * hosting device page map.
 					    */
-		struct {		/* slub per cpu partial pages */
+		struct {			/* slab/slob/slub */
 			struct page *next;	/* Next partial slab */
 #ifdef CONFIG_64BIT
 			int pages;	/* Nr of partial slabs left */
@@ -151,6 +160,7 @@ struct page {
 			short int pages;
 			short int pobjects;
 #endif
+			struct kmem_cache *slab_cache;	/* Pointer to slab */
 		};
 
 		struct rcu_head rcu_head;	/* Used by SLAB
@@ -166,33 +176,18 @@ struct page {
 			/* two/six bytes available here */
 		};
 
-#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
 		struct {
 			unsigned long __pad;	/* do not overlay pmd_huge_pte
 						 * with compound_head to avoid
 						 * possible bit 0 collision.
 						 */
 			pgtable_t pmd_huge_pte; /* protected by page->ptl */
-		};
-#endif
-	};
-
-	union {
-		/*
-		 * Mapping-private opaque data:
-		 * Usually used for buffer_heads if PagePrivate
-		 * Used for swp_entry_t if PageSwapCache
-		 * Indicates order in the buddy system if PageBuddy
-		 */
-		unsigned long private;
-#if USE_SPLIT_PTE_PTLOCKS
 #if ALLOC_SPLIT_PTLOCKS
-		spinlock_t *ptl;
+			spinlock_t *ptl;
 #else
-		spinlock_t ptl;
+			spinlock_t ptl;
 #endif
-#endif
-		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
+		};
 	};
 
 #ifdef CONFIG_MEMCG
-- 
2.16.3
