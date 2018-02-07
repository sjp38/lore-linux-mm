Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2D956B036F
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 16:30:51 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id a9so1002365pff.0
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 13:30:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v26si976020pgc.137.2018.02.07.13.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Feb 2018 13:30:50 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] mm: Split page_type out from _map_count
Date: Wed,  7 Feb 2018 13:30:47 -0800
Message-Id: <20180207213047.6148-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

We're already using a union of many fields here, so stop abusing the
_map_count and make page_type its own field.  That implies renaming some
of the machinery that creates PageBuddy, PageBalloon and PageKmemcg;
bring back the PG_buddy, PG_balloon and PG_kmemcg names.  Also, the
special values don't need to be (and probably shouldn't be) powers of two,
so renumber them to just start at -128.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/mm_types.h   | 13 ++++++++-----
 include/linux/page-flags.h | 36 +++++++++++++++++-------------------
 2 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index fd1af6b9591d..1c5dea402501 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -94,6 +94,14 @@ struct page {
 	};
 
 	union {
+		/*
+		 * If the page is neither PageSlab nor PageAnon, the value
+		 * stored here may help distinguish it from page cache pages.
+		 * See page-flags.h for a list of page types which are
+		 * currently stored here.
+		 */
+		unsigned int page_type;
+
 		_slub_counter_t counters;
 		unsigned int active;		/* SLAB */
 		struct {			/* SLUB */
@@ -107,11 +115,6 @@ struct page {
 			/*
 			 * Count of ptes mapped in mms, to show when
 			 * page is mapped & limit reverse map searches.
-			 *
-			 * Extra information about page type may be
-			 * stored here for pages that are never mapped,
-			 * in which case the value MUST BE <= -2.
-			 * See page-flags.h for more details.
 			 */
 			atomic_t _mapcount;
 
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 50c2b8786831..ba6a7e883425 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -630,49 +630,47 @@ PAGEFLAG_FALSE(DoubleMap)
 #endif
 
 /*
- * For pages that are never mapped to userspace, page->mapcount may be
- * used for storing extra information about page type. Any value used
- * for this purpose must be <= -2, but it's better start not too close
- * to -2 so that an underflow of the page_mapcount() won't be mistaken
- * for a special page.
+ * For pages that are never mapped to userspace, page_type may be
+ * used.  Values used for this purpose must be <= -2, but we leave a gap
+ * so that an underflow of page_mapcount() won't be mistaken for a
+ * special page.
  */
-#define PAGE_MAPCOUNT_OPS(uname, lname)					\
+#define PAGE_TYPE_OPS(uname, lname)					\
 static __always_inline int Page##uname(struct page *page)		\
 {									\
-	return atomic_read(&page->_mapcount) ==				\
-				PAGE_##lname##_MAPCOUNT_VALUE;		\
+	return page->page_type == PG_##lname;				\
 }									\
 static __always_inline void __SetPage##uname(struct page *page)		\
 {									\
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);	\
-	atomic_set(&page->_mapcount, PAGE_##lname##_MAPCOUNT_VALUE);	\
+	VM_BUG_ON_PAGE(page->page_type != -1, page);			\
+	page->page_type = PG_##lname;					\
 }									\
 static __always_inline void __ClearPage##uname(struct page *page)	\
 {									\
 	VM_BUG_ON_PAGE(!Page##uname(page), page);			\
-	atomic_set(&page->_mapcount, -1);				\
+	page->page_type = -1;						\
 }
 
 /*
- * PageBuddy() indicate that the page is free and in the buddy system
+ * PageBuddy() indicates that the page is free and in the buddy system
  * (see mm/page_alloc.c).
  */
-#define PAGE_BUDDY_MAPCOUNT_VALUE		(-128)
-PAGE_MAPCOUNT_OPS(Buddy, BUDDY)
+#define PG_buddy		(-128)
+PAGE_TYPE_OPS(Buddy, buddy)
 
 /*
- * PageBalloon() is set on pages that are on the balloon page list
+ * PageBalloon() is true for pages that are on the balloon page list
  * (see mm/balloon_compaction.c).
  */
-#define PAGE_BALLOON_MAPCOUNT_VALUE		(-256)
-PAGE_MAPCOUNT_OPS(Balloon, BALLOON)
+#define PG_balloon		(-129)
+PAGE_TYPE_OPS(Balloon, balloon)
 
 /*
  * If kmemcg is enabled, the buddy allocator will set PageKmemcg() on
  * pages allocated with __GFP_ACCOUNT. It gets cleared on page free.
  */
-#define PAGE_KMEMCG_MAPCOUNT_VALUE		(-512)
-PAGE_MAPCOUNT_OPS(Kmemcg, KMEMCG)
+#define PG_kmemcg		(-130)
+PAGE_TYPE_OPS(Kmemcg, kmemcg)
 
 extern bool is_free_buddy_page(struct page *page);
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
