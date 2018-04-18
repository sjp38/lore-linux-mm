Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 04C5A6B0011
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:24 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g1-v6so1488604plm.2
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 71-v6si1771558plb.511.2018.04.18.11.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:20 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 02/14] mm: Split page_type out from _mapcount
Date: Wed, 18 Apr 2018 11:49:00 -0700
Message-Id: <20180418184912.2851-3-willy@infradead.org>
In-Reply-To: <20180418184912.2851-1-willy@infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

We're already using a union of many fields here, so stop abusing the
_mapcount and make page_type its own field.  That implies renaming some
of the machinery that creates PageBuddy, PageBalloon and PageKmemcg;
bring back the PG_buddy, PG_balloon and PG_kmemcg names.

As suggested by Kirill, make page_type a bitmask.  Because it starts out
life as -1 (thanks to sharing the storage with _mapcount), setting a
page flag means clearing the appropriate bit.  This gives us space for
probably twenty or so extra bits (depending how paranoid we want to be
about _mapcount underflow).

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm_types.h   | 13 ++++++-----
 include/linux/page-flags.h | 45 ++++++++++++++++++++++----------------
 kernel/crash_core.c        |  1 +
 mm/page_alloc.c            | 13 +++++------
 scripts/tags.sh            |  6 ++---
 5 files changed, 43 insertions(+), 35 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 21612347d311..41828fb34860 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -96,6 +96,14 @@ struct page {
 	};
 
 	union {
+		/*
+		 * If the page is neither PageSlab nor mappable to userspace,
+		 * the value stored here may help determine what this page
+		 * is used for.  See page-flags.h for a list of page types
+		 * which are currently stored here.
+		 */
+		unsigned int page_type;
+
 		_slub_counter_t counters;
 		unsigned int active;		/* SLAB */
 		struct {			/* SLUB */
@@ -109,11 +117,6 @@ struct page {
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
index e34a27727b9a..8c25b28a35aa 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -642,49 +642,56 @@ PAGEFLAG_FALSE(DoubleMap)
 #endif
 
 /*
- * For pages that are never mapped to userspace, page->mapcount may be
- * used for storing extra information about page type. Any value used
- * for this purpose must be <= -2, but it's better start not too close
- * to -2 so that an underflow of the page_mapcount() won't be mistaken
- * for a special page.
+ * For pages that are never mapped to userspace (and aren't PageSlab),
+ * page_type may be used.  Because it is initialised to -1, we invert the
+ * sense of the bit, so __SetPageFoo *clears* the bit used for PageFoo, and
+ * __ClearPageFoo *sets* the bit used for PageFoo.  We reserve a few high and
+ * low bits so that an underflow or overflow of page_mapcount() won't be
+ * mistaken for a page type value.
  */
-#define PAGE_MAPCOUNT_OPS(uname, lname)					\
+
+#define PAGE_TYPE_BASE	0xf0000000
+/* Reserve		0x0000007f to catch underflows of page_mapcount */
+#define PG_buddy	0x00000080
+#define PG_balloon	0x00000100
+#define PG_kmemcg	0x00000200
+
+#define PageType(page, flag)						\
+	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
+
+#define PAGE_TYPE_OPS(uname, lname)					\
 static __always_inline int Page##uname(struct page *page)		\
 {									\
-	return atomic_read(&page->_mapcount) ==				\
-				PAGE_##lname##_MAPCOUNT_VALUE;		\
+	return PageType(page, PG_##lname);				\
 }									\
 static __always_inline void __SetPage##uname(struct page *page)		\
 {									\
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);	\
-	atomic_set(&page->_mapcount, PAGE_##lname##_MAPCOUNT_VALUE);	\
+	VM_BUG_ON_PAGE(!PageType(page, 0), page);			\
+	page->page_type &= ~PG_##lname;					\
 }									\
 static __always_inline void __ClearPage##uname(struct page *page)	\
 {									\
 	VM_BUG_ON_PAGE(!Page##uname(page), page);			\
-	atomic_set(&page->_mapcount, -1);				\
+	page->page_type |= PG_##lname;					\
 }
 
 /*
- * PageBuddy() indicate that the page is free and in the buddy system
+ * PageBuddy() indicates that the page is free and in the buddy system
  * (see mm/page_alloc.c).
  */
-#define PAGE_BUDDY_MAPCOUNT_VALUE		(-128)
-PAGE_MAPCOUNT_OPS(Buddy, BUDDY)
+PAGE_TYPE_OPS(Buddy, buddy)
 
 /*
- * PageBalloon() is set on pages that are on the balloon page list
+ * PageBalloon() is true for pages that are on the balloon page list
  * (see mm/balloon_compaction.c).
  */
-#define PAGE_BALLOON_MAPCOUNT_VALUE		(-256)
-PAGE_MAPCOUNT_OPS(Balloon, BALLOON)
+PAGE_TYPE_OPS(Balloon, balloon)
 
 /*
  * If kmemcg is enabled, the buddy allocator will set PageKmemcg() on
  * pages allocated with __GFP_ACCOUNT. It gets cleared on page free.
  */
-#define PAGE_KMEMCG_MAPCOUNT_VALUE		(-512)
-PAGE_MAPCOUNT_OPS(Kmemcg, KMEMCG)
+PAGE_TYPE_OPS(Kmemcg, kmemcg)
 
 extern bool is_free_buddy_page(struct page *page);
 
diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index f7674d676889..b66aced5e8c2 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -460,6 +460,7 @@ static int __init crash_save_vmcoreinfo_init(void)
 	VMCOREINFO_NUMBER(PG_hwpoison);
 #endif
 	VMCOREINFO_NUMBER(PG_head_mask);
+#define PAGE_BUDDY_MAPCOUNT_VALUE	(~PG_buddy)
 	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
 #ifdef CONFIG_HUGETLB_PAGE
 	VMCOREINFO_NUMBER(HUGETLB_PAGE_DTOR);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7eebd6925b10..88e817d7ccef 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -706,16 +706,14 @@ static inline void rmv_page_order(struct page *page)
 
 /*
  * This function checks whether a page is free && is the buddy
- * we can do coalesce a page and its buddy if
+ * we can coalesce a page and its buddy if
  * (a) the buddy is not in a hole (check before calling!) &&
  * (b) the buddy is in the buddy system &&
  * (c) a page and its buddy have the same order &&
  * (d) a page and its buddy are in the same zone.
  *
- * For recording whether a page is in the buddy system, we set ->_mapcount
- * PAGE_BUDDY_MAPCOUNT_VALUE.
- * Setting, clearing, and testing _mapcount PAGE_BUDDY_MAPCOUNT_VALUE is
- * serialized by zone->lock.
+ * For recording whether a page is in the buddy system, we set PageBuddy.
+ * Setting, clearing, and testing PageBuddy is serialized by zone->lock.
  *
  * For recording page's order, we use page_private(page).
  */
@@ -760,9 +758,8 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  * as necessary, plus some accounting needed to play nicely with other
  * parts of the VM system.
  * At each level, we keep a list of pages, which are heads of continuous
- * free pages of length of (1 << order) and marked with _mapcount
- * PAGE_BUDDY_MAPCOUNT_VALUE. Page's order is recorded in page_private(page)
- * field.
+ * free pages of length of (1 << order) and marked with PageBuddy.
+ * Page's order is recorded in page_private(page) field.
  * So when we are allocating or freeing one, we can derive the state of the
  * other.  That is, if we allocate a small block, and both were
  * free, the remainder of the region must be split into blocks.
diff --git a/scripts/tags.sh b/scripts/tags.sh
index 78e546ff689c..8c3ae36d4ea8 100755
--- a/scripts/tags.sh
+++ b/scripts/tags.sh
@@ -188,9 +188,9 @@ regex_c=(
 	'/\<CLEARPAGEFLAG_NOOP(\([[:alnum:]_]*\).*/ClearPage\1/'
 	'/\<__CLEARPAGEFLAG_NOOP(\([[:alnum:]_]*\).*/__ClearPage\1/'
 	'/\<TESTCLEARFLAG_FALSE(\([[:alnum:]_]*\).*/TestClearPage\1/'
-	'/^PAGE_MAPCOUNT_OPS(\([[:alnum:]_]*\).*/Page\1/'
-	'/^PAGE_MAPCOUNT_OPS(\([[:alnum:]_]*\).*/__SetPage\1/'
-	'/^PAGE_MAPCOUNT_OPS(\([[:alnum:]_]*\).*/__ClearPage\1/'
+	'/^PAGE_TYPE_OPS(\([[:alnum:]_]*\).*/Page\1/'
+	'/^PAGE_TYPE_OPS(\([[:alnum:]_]*\).*/__SetPage\1/'
+	'/^PAGE_TYPE_OPS(\([[:alnum:]_]*\).*/__ClearPage\1/'
 	'/^TASK_PFA_TEST([^,]*, *\([[:alnum:]_]*\))/task_\1/'
 	'/^TASK_PFA_SET([^,]*, *\([[:alnum:]_]*\))/task_set_\1/'
 	'/^TASK_PFA_CLEAR([^,]*, *\([[:alnum:]_]*\))/task_clear_\1/'
-- 
2.17.0
