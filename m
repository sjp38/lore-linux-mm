Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1726B0010
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 16:23:15 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s6-v6so6603815pgn.16
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 13:23:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y3si8308567pfa.181.2018.04.30.13.23.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Apr 2018 13:23:14 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 08/16] mm: Combine first three unions in struct page
Date: Mon, 30 Apr 2018 13:22:39 -0700
Message-Id: <20180430202247.25220-9-willy@infradead.org>
In-Reply-To: <20180430202247.25220-1-willy@infradead.org>
References: <20180430202247.25220-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

By combining these three one-word unions into one three-word union,
we make it easier for users to add their own multi-word fields to struct
page, as well as making it obvious that SLUB needs to keep its double-word
alignment for its freelist & counters.

No field moves position; verified with pahole.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_types.h | 65 ++++++++++++++++++++--------------------
 1 file changed, 32 insertions(+), 33 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 04d9dc442029..f0ccb699641d 100644
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
+		struct {	/* slab, slob and slub */
+			struct kmem_cache *slab_cache;	/* (slub) */
+			void *freelist;		/* first free object (slub) */
+			void *s_mem;		/* first object */
+		};
+		struct {	/* slub */
+			struct kmem_cache *slub_cache;	/* shared with slab */
+			/* Double-word boundary */
+			void *slub_freelist;		/* shared with slab */
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
+			unsigned long _pt_pad_2;	/* mapping */
+			unsigned long _pt_pad_3;
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
