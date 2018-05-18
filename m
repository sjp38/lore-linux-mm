Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6D0DE6B066B
	for <linux-mm@kvack.org>; Fri, 18 May 2018 15:45:32 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o23-v6so5576026pll.12
        for <linux-mm@kvack.org>; Fri, 18 May 2018 12:45:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g12-v6si8469826pfi.212.2018.05.18.12.45.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 18 May 2018 12:45:23 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v6 09/17] mm: Move lru union within struct page
Date: Fri, 18 May 2018 12:45:11 -0700
Message-Id: <20180518194519.3820-10-willy@infradead.org>
In-Reply-To: <20180518194519.3820-1-willy@infradead.org>
References: <20180518194519.3820-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Since the LRU is two words, this does not affect the double-word
alignment of SLUB's freelist.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_types.h | 102 +++++++++++++++++++--------------------
 mm/slub.c                |   8 +--
 2 files changed, 55 insertions(+), 55 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 629a7b568ed7..b6a3948195d3 100644
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
 	/* Three words (12/24 bytes) are available in this union. */
 	union {
 		struct {	/* Page cache and anonymous pages */
@@ -135,57 +186,6 @@ struct page {
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
diff --git a/mm/slub.c b/mm/slub.c
index 05ca612a5fe6..57a20f995220 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -52,11 +52,11 @@
  *   and to synchronize major metadata changes to slab cache structures.
  *
  *   The slab_lock is only used for debugging and on arches that do not
- *   have the ability to do a cmpxchg_double. It only protects the second
- *   double word in the page struct. Meaning
+ *   have the ability to do a cmpxchg_double. It only protects:
  *	A. page->freelist	-> List of object free in a page
- *	B. page->counters	-> Counters of objects
- *	C. page->frozen		-> frozen state
+ *	B. page->inuse		-> Number of objects in use
+ *	C. page->objects	-> Number of objects in page
+ *	D. page->frozen		-> frozen state
  *
  *   If a slab is frozen then it is exempt from list management. It is not
  *   on any list. The processor that froze the slab is the one who can
-- 
2.17.0
