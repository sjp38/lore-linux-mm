Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 874066B0022
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e14so1404945pfi.9
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e15si1518705pgu.656.2018.04.18.11.49.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:24 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 10/14] mm: Move lru union within struct page
Date: Wed, 18 Apr 2018 11:49:08 -0700
Message-Id: <20180418184912.2851-11-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

Since the LRU is two words, this does not affect the double-word
alignment of SLUB's freelist.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h | 102 +++++++++++++++++++--------------------
 1 file changed, 51 insertions(+), 51 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 39521b8385c1..230d473f16da 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -72,6 +72,57 @@ struct hmm;
 struct page {
 	unsigned long flags;		/* Atomic flags, some possibly
 					 * updated asynchronously */
+	/*
+	 * WARNING: bit 0 of the first word encode PageTail(). That means
+	 * the rest users of the storage space MUST NOT use the bit to
+	 * avoid collision and false-positive PageTail().
+	 */
+	union {
+		struct list_head lru;	/* Pageout list, eg. active_list
+					 * protected by zone_lru_lock !
+					 * Can be used as a generic list
+					 * by the page owner.
+					 */
+		struct dev_pagemap *pgmap; /* ZONE_DEVICE pages are never on an
+					    * lru or handled by a slab
+					    * allocator, this points to the
+					    * hosting device page map.
+					    */
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
+		struct rcu_head rcu_head;	/* Used by SLAB
+						 * when destroying via RCU
+						 */
+		/* Tail pages of compound page */
+		struct {
+			unsigned long compound_head; /* If bit zero is set */
+
+			/* First tail page only */
+			unsigned char compound_dtor;
+			unsigned char compound_order;
+			/* two/six bytes available here */
+		};
+
+#if defined(CONFIG_TRANSPARENT_HUGEPAGE) && USE_SPLIT_PMD_PTLOCKS
+		struct {
+			unsigned long __pad;	/* do not overlay pmd_huge_pte
+						 * with compound_head to avoid
+						 * possible bit 0 collision.
+						 */
+			pgtable_t pmd_huge_pte; /* protected by page->ptl */
+		};
+#endif
+	};
+
 	union {		/* This union is three words (12/24 bytes) in size */
 		struct {	/* Page cache and anonymous pages */
 			/* See page-flags.h for PAGE_MAPPING_FLAGS */
@@ -133,57 +184,6 @@ struct page {
 	/* Usage count. *DO NOT USE DIRECTLY*. See page_ref.h */
 	atomic_t _refcount;
 
-	/*
-	 * WARNING: bit 0 of the first word encode PageTail(). That means
-	 * the rest users of the storage space MUST NOT use the bit to
-	 * avoid collision and false-positive PageTail().
-	 */
-	union {
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
 #ifdef CONFIG_MEMCG
 	struct mem_cgroup *mem_cgroup;
 #endif
-- 
2.17.0
