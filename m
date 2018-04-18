Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 721A86B0027
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:29 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h9so996727pfn.22
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i3si686473pfc.186.2018.04.18.11.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:24 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 11/14] mm: Combine first two unions in struct page
Date: Wed, 18 Apr 2018 11:49:09 -0700
Message-Id: <20180418184912.2851-12-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

This gives us five words of space in a single union in struct page.
The compound_mapcount moves position (from offset 24 to offset 20)
on 64-bit systems, but that does not seem likely to cause any trouble.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 96 ++++++++++++++++++----------------------
 mm/page_alloc.c          |  2 +-
 2 files changed, 45 insertions(+), 53 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 230d473f16da..080ea97ad444 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -73,58 +73,19 @@ struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
 	/*
-	 * WARNING: bit 0 of the first word encode PageTail(). That means
-	 * the rest users of the storage space MUST NOT use the bit to
+	 * Five words (20/40 bytes) are available in this union.
+	 * WARNING: bit 0 of the first word is used for PageTail(). That
+	 * means the other users of this union MUST NOT use the bit to
 	 * avoid collision and false-positive PageTail().
 	 */
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
-		struct rcu_head rcu_head;	/* Used by SLAB
-						 * when destroying via RCU
-						 */
-		/* Tail pages of compound page */
-		struct {
-			unsigned long compound_head; /* If bit zero is set */
-
-			/* First tail page only */
-			unsigned char compound_dtor;
-			unsigned char compound_order;
-			/* two/six bytes available here */
-		};
-
-#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
-		struct {
-			unsigned long __pad;	/* do not overlay pmd_huge_pte
-						 * with compound_head to avoid
-						 * possible bit 0 collision.
-						 */
-			pgtable_t pmd_huge_pte; /* protected by page->ptl */
-		};
-#endif
-	};
-
-	union {		/* This union is three words (12/24 bytes) in size */
 		struct {	/* Page cache and anonymous pages */
+			/**
+			 * @lru: Pageout list, eg. active_list protected by
+			 * zone_lru_lock.  Sometimes used as a generic list
+			 * by the page owner.
+			 */
+			struct list_head lru;
 			/* See page-flags.h for PAGE_MAPPING_FLAGS */
 			struct address_space *mapping;
 			pgoff_t index;		/* Our offset within mapping. */
@@ -137,11 +98,20 @@ struct page {
 			unsigned long private;
 		};
 		struct {	/* slab and slob */
+			struct list_head slab_list;
 			struct kmem_cache *slab_cache;
 			void *freelist;		/* first free object */
 			void *s_mem;		/* first object */
 		};
 		struct {	/* slub also uses some of the slab fields */
+			struct page *next;	/* Next partial slab */
+#ifdef CONFIG_64BIT
+			int pages;	/* Nr of partial slabs left */
+			int pobjects;	/* Approximate # of objects */
+#else
+			short int pages;
+			short int pobjects;
+#endif
 			struct kmem_cache *slub_cache;
 			/* Double-word boundary */
 			void *slub_freelist;
@@ -149,17 +119,39 @@ struct page {
 			unsigned objects:15;
 			unsigned frozen:1;
 		};
-		atomic_t compound_mapcount;	/* first tail page */
-		struct list_head deferred_list; /* second tail page */
+		struct {	/* Tail pages of compound page */
+			unsigned long compound_head;	/* Bit zero is set */
+
+			/* First tail page only */
+			unsigned char compound_dtor;
+			unsigned char compound_order;
+			atomic_t compound_mapcount;
+		};
+		struct {	/* Second tail page of compound page */
+			unsigned long _compound_pad_1;	/* compound_head */
+			unsigned long _compound_pad_2;
+			struct list_head deferred_list;
+		};
 		struct {	/* Page table pages */
-			unsigned long _ptl_pad_1;
-			unsigned long _ptl_pad_2;
+			unsigned long _pt_pad_1;	/* compound_head */
+			pgtable_t pmd_huge_pte; /* protected by page->ptl */
+			unsigned long _pt_pad_2;
+			unsigned long _pt_pad_3;
 #if ALLOC_SPLIT_PTLOCKS
 			spinlock_t *ptl;
 #else
 			spinlock_t ptl;
 #endif
 		};
+
+		/** @rcu_head: You can use this to free a page by RCU. */
+		struct rcu_head rcu_head;
+
+		/**
+		 * @pgmap: For ZONE_DEVICE pages, this points to the hosting
+		 * device page map.
+		 */
+		struct dev_pagemap *pgmap;
 	};
 
 	union {		/* This union is 4 bytes in size. */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 18720eccbce1..d1e4df7d57bf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -944,7 +944,7 @@ static int free_tail_pages_check(struct page *head_page, struct page *page)
 	}
 	switch (page - head_page) {
 	case 1:
-		/* the first tail page: ->mapping is compound_mapcount() */
+		/* the first tail page: ->mapping may be compound_mapcount() */
 		if (unlikely(compound_mapcount(page))) {
 			bad_page(page, "nonzero compound_mapcount", 0);
 			goto out;
-- 
2.17.0
