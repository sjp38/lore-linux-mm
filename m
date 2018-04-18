Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 314A36B000D
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:23 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n5so632216pgq.3
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o11-v6si1736269plk.434.2018.04.18.11.49.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:21 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 05/14] mm: Move 'private' union within struct page
Date: Wed, 18 Apr 2018 11:49:03 -0700
Message-Id: <20180418184912.2851-6-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

By moving page->private to the fourth word of struct page, we can put
the SLUB counters in the same word as SLAB's s_mem and still do the
cmpxchg_double trick.  Now the SLUB counters no longer overlap with
the refcount.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 54 ++++++++++++++++++----------------------
 1 file changed, 24 insertions(+), 30 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index e97a310a6abe..e83fef8c74d9 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -65,14 +65,8 @@ struct hmm;
  */
 #ifdef CONFIG_HAVE_ALIGNED_STRUCT_PAGE
 #define _struct_page_alignment	__aligned(2 * sizeof(unsigned long))
-#if defined(CONFIG_HAVE_CMPXCHG_DOUBLE)
-#define _slub_counter_t		unsigned long
-#else
-#define _slub_counter_t		unsigned int
-#endif
 #else /* !CONFIG_HAVE_ALIGNED_STRUCT_PAGE */
 #define _struct_page_alignment
-#define _slub_counter_t		unsigned int
 #endif /* !CONFIG_HAVE_ALIGNED_STRUCT_PAGE */
 
 struct page {
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
-- 
2.17.0
