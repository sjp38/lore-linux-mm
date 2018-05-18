Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEF9E6B0662
	for <linux-mm@kvack.org>; Fri, 18 May 2018 15:45:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e3-v6so5290422pfe.15
        for <linux-mm@kvack.org>; Fri, 18 May 2018 12:45:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q137-v6si8456752pfc.68.2018.05.18.12.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 12:45:23 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 07/17] mm: Combine first three unions in struct page
Date: Fri, 18 May 2018 12:45:09 -0700
Message-Id: <20180518194519.3820-8-willy@infradead.org>
In-Reply-To: <20180518194519.3820-1-willy@infradead.org>
References: <20180518194519.3820-1-willy@infradead.org>
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
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 include/linux/mm_types.h | 66 ++++++++++++++++++++--------------------
 1 file changed, 33 insertions(+), 33 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 9828cd170251..629a7b568ed7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -70,46 +70,46 @@ struct hmm;
 #endif
 
 struct page {
-	/* First double word block */
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
+	/* Three words (12/24 bytes) are available in this union. */
 	union {
-		/* See page-flags.h for the definition of PAGE_MAPPING_FLAGS */
-		struct address_space *mapping;
-
-		struct kmem_cache *slab_cache;	/* SL[AU]B: Pointer to slab */
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
+			struct kmem_cache *slab_cache; /* not slob */
+			/* Double-word boundary */
+			void *freelist;		/* first free object */
+			union {
+				void *s_mem;	/* slab: first object */
+				unsigned long counters;		/* SLUB */
+				struct {			/* SLUB */
+					unsigned inuse:16;
+					unsigned objects:15;
+					unsigned frozen:1;
+				};
+			};
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
-		unsigned long counters;		/* SLUB */
-		struct {			/* SLUB */
-			unsigned inuse:16;
-			unsigned objects:15;
-			unsigned frozen:1;
 		};
 	};
 
-- 
2.17.0
