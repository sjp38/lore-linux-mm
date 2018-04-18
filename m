Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA70D6B0024
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j25so1381831pfh.18
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f8si1481332pgt.243.2018.04.18.11.49.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:23 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 08/14] mm: Combine first three unions in struct page
Date: Wed, 18 Apr 2018 11:49:06 -0700
Message-Id: <20180418184912.2851-9-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

By combining these three one-word unions into one three-word union,
we make it easier for users to add their own multi-word fields to struct
page, as well as making it obvious that SLUB needs to keep its double-word
alignment for its freelist & counters.

No field moves position; verified with pahole.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 65 ++++++++++++++++++++--------------------
 1 file changed, 32 insertions(+), 33 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 04d9dc442029..39521b8385c1 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -70,45 +70,44 @@ struct hmm;
 #endif
 
 struct page {
-	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
-	union {
-		/* See page-flags.h for the definition of PAGE_MAPPING_FLAGS */
-		struct address_space *mapping;
-
-		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
+	union {		/* This union is three words (12/24 bytes) in size */
+		struct {	/* Page cache and anonymous pages */
+			/* See page-flags.h for PAGE_MAPPING_FLAGS */
+			struct address_space *mapping;
+			pgoff_t index;		/* Our offset within mapping. */
+			/**
+			 * @private: Mapping-private opaque data.
+			 * Usually used for buffer_heads if PagePrivate.
+			 * Used for swp_entry_t if PageSwapCache.
+			 * Indicates order in the buddy system if PageBuddy.
+			 */
+			unsigned long private;
+		};
+		struct {	/* slab and slob */
+			struct kmem_cache *slab_cache;
+			void *freelist;		/* first free object */
+			void *s_mem;		/* first object */
+		};
+		struct {	/* slub also uses some of the slab fields */
+			struct kmem_cache *slub_cache;
+			/* Double-word boundary */
+			void *slub_freelist;
+			unsigned inuse:16;
+			unsigned objects:15;
+			unsigned frozen:1;
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
+		struct list_head deferred_list; /* second tail page */
+		struct {	/* Page table pages */
+			unsigned long _ptl_pad_1;
+			unsigned long _ptl_pad_2;
 #if ALLOC_SPLIT_PTLOCKS
-		spinlock_t *ptl;
+			spinlock_t *ptl;
 #else
-		spinlock_t ptl;
-#endif
+			spinlock_t ptl;
 #endif
-		void *s_mem;			/* slab first object */
-		struct {			/* SLUB */
-			unsigned inuse:16;
-			unsigned objects:15;
-			unsigned frozen:1;
 		};
 	};
 
-- 
2.17.0
