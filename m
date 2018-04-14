Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D47E26B0009
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 00:31:52 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id t4-v6so7016022plo.9
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 21:31:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x8-v6si6730458plv.420.2018.04.13.21.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 21:31:51 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 3/8] mm: Turn PF_POISONED_CHECK into CheckPageInit
Date: Fri, 13 Apr 2018 21:31:40 -0700
Message-Id: <20180414043145.3953-4-willy@infradead.org>
In-Reply-To: <20180414043145.3953-1-willy@infradead.org>
References: <20180414043145.3953-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This is not a page flag policy, and should not have been documented as
such.  It's a debug check, so combine it with PagePoisoned into
CheckPageInit.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm.h         |  2 +-
 include/linux/page-flags.h | 21 ++++++++-------------
 2 files changed, 9 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4d1aff80669c..8b09adeed1f7 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -907,7 +907,7 @@ static inline int page_to_nid(const struct page *page)
 {
 	struct page *p = (struct page *)page;
 
-	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
+	return (CheckPageInit(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
 }
 #endif
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 8588c4628a7d..393bb93b6b89 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -157,17 +157,15 @@ static __always_inline int PageCompound(struct page *page)
 }
 
 #define	PAGE_POISON_PATTERN	-1l
-static inline int PagePoisoned(const struct page *page)
+static __always_inline struct page *CheckPageInit(struct page *page)
 {
-	return page->flags == PAGE_POISON_PATTERN;
+	VM_BUG_ON_PGFLAGS(page->flags == PAGE_POISON_PATTERN, page);
+	return page;
 }
 
 /*
  * Page flags policies wrt compound pages
  *
- * PF_POISONED_CHECK
- *     check if this struct page poisoned/uninitialized
- *
  * PF_ANY:
  *     the page flag is relevant for small, head and tail pages.
  *
@@ -185,20 +183,17 @@ static inline int PagePoisoned(const struct page *page)
  * PF_NO_COMPOUND:
  *     the page flag is not relevant for compound pages.
  */
-#define PF_POISONED_CHECK(page) ({					\
-		VM_BUG_ON_PGFLAGS(PagePoisoned(page), page);		\
-		page; })
-#define PF_ANY(page, modify)	PF_POISONED_CHECK(page)
-#define PF_HEAD(page, modify)	PF_POISONED_CHECK(compound_head(page))
+#define PF_ANY(page, modify)	CheckPageInit(page)
+#define PF_HEAD(page, modify)	CheckPageInit(compound_head(page))
 #define PF_ONLY_HEAD(page, modify) ({					\
 		VM_BUG_ON_PGFLAGS(PageTail(page), page);		\
-		PF_POISONED_CHECK(page); })
+		CheckPageInit(page); })
 #define PF_TAIL_READ(page, modify) ({					\
 		VM_BUG_ON_PGFLAGS(modify && PageTail(page), page);	\
-		PF_POISONED_CHECK(compound_head(page)); })
+		CheckPageInit(compound_head(page)); })
 #define PF_NO_COMPOUND(page, modify) ({				\
 		VM_BUG_ON_PGFLAGS(modify && PageCompound(page), page);	\
-		PF_POISONED_CHECK(page); })
+		CheckPageInit(page); })
 
 /*
  * Macros to create function definitions for page flags
-- 
2.16.3
