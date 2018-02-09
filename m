Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9166B0005
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 10:28:51 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a2so4082894pgn.7
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 07:28:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id y15si1500581pgv.202.2018.02.09.07.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 09 Feb 2018 07:28:49 -0800 (PST)
Date: Fri, 9 Feb 2018 07:28:48 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v2] mm: Split page_type out from _map_count
Message-ID: <20180209152848.GF16666@bombadil.infradead.org>
References: <20180207213047.6148-1-willy@infradead.org>
 <20180209105132.hhkjoijini3f74fz@node.shutemov.name>
 <20180209134942.GB16666@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180209134942.GB16666@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

We're already using a union of many fields here, so stop abusing the
_map_count and make page_type its own field.  That implies renaming some
of the machinery that creates PageBuddy, PageBalloon and PageKmemcg;
bring back the PG_buddy, PG_balloon and PG_kmemcg names.  As Kirill
pointed out, it would be nice to be able to set more than one flag
in this field, so change the definitions to allow this.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
v2: Fixed a few places that still referred to the old MAPCOUNT_VALUEs.
    Incorporated Kirill's suggestion to allow more than one flag.

 include/linux/mm_types.h   | 13 ++++++++-----
 include/linux/page-flags.h | 44 +++++++++++++++++++++++++-------------------
 kernel/crash_core.c        |  2 +-
 mm/page_alloc.c            | 13 +++++--------
 scripts/tags.sh            |  6 +++---
 5 files changed, 42 insertions(+), 36 deletions(-)

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
index 50c2b8786831..efe5ebfef5b2 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -630,49 +630,55 @@ PAGEFLAG_FALSE(DoubleMap)
 #endif
 
 /*
- * For pages that are never mapped to userspace, page->mapcount may be
- * used for storing extra information about page type. Any value used
- * for this purpose must be <= -2, but it's better start not too close
- * to -2 so that an underflow of the page_mapcount() won't be mistaken
- * for a special page.
+ * For pages that are never mapped to userspace (and aren't PageSlab),
+ * page_type may be used.  Because it is initialised to -1, we invert the
+ * sense of the bit, so SetPageFoo *clears* the bit used for PageFoo, and
+ * ClearPageFoo *sets* the bit used for PageFoo.  We leave a gap in the bit
+ * assignments so that an underflow of page_mapcount() won't be mistaken for
+ * a special page.
  */
-#define PAGE_MAPCOUNT_OPS(uname, lname)					\
+
+#define PAGE_TYPE_BASE	0xfffff000
+#define PG_buddy	0x00000080
+#define PG_balloon	0x00000100
+#define PG_kmemcg	0x00000200
+
+#define __is_page_type(page, flag)					\
+	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
+
+#define PAGE_TYPE_OPS(uname, lname)					\
 static __always_inline int Page##uname(struct page *page)		\
 {									\
-	return atomic_read(&page->_mapcount) ==				\
-				PAGE_##lname##_MAPCOUNT_VALUE;		\
+	return __is_page_type(page, PG_##lname);			\
 }									\
 static __always_inline void __SetPage##uname(struct page *page)		\
 {									\
-	VM_BUG_ON_PAGE(atomic_read(&page->_mapcount) != -1, page);	\
-	atomic_set(&page->_mapcount, PAGE_##lname##_MAPCOUNT_VALUE);	\
+	VM_BUG_ON_PAGE(!__is_page_type(page, 0), page);			\
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
index 4f63597c824d..490760ada638 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -458,7 +458,7 @@ static int __init crash_save_vmcoreinfo_init(void)
 	VMCOREINFO_NUMBER(PG_hwpoison);
 #endif
 	VMCOREINFO_NUMBER(PG_head_mask);
-	VMCOREINFO_NUMBER(PAGE_BUDDY_MAPCOUNT_VALUE);
+	VMCOREINFO_NUMBER(PG_buddy);
 #ifdef CONFIG_HUGETLB_PAGE
 	VMCOREINFO_NUMBER(HUGETLB_PAGE_DTOR);
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 81e18ceef579..ef9c259db041 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -740,16 +740,14 @@ static inline void rmv_page_order(struct page *page)
 
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
+ * For recording whether a page is in the buddy system, we set PG_buddy.
+ * Setting, clearing, and testing PG_buddy is serialized by zone->lock.
  *
  * For recording page's order, we use page_private(page).
  */
@@ -794,9 +792,8 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  * as necessary, plus some accounting needed to play nicely with other
  * parts of the VM system.
  * At each level, we keep a list of pages, which are heads of continuous
- * free pages of length of (1 << order) and marked with _mapcount
- * PAGE_BUDDY_MAPCOUNT_VALUE. Page's order is recorded in page_private(page)
- * field.
+ * free pages of length of (1 << order) and marked with PageBuddy().
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
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
