Message-Id: <20080430044319.309218061@sgi.com>
References: <20080430044251.266380837@sgi.com>
Date: Tue, 29 Apr 2008 21:42:53 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [02/11] vcompound: pageflags: Add PageVcompound()
Content-Disposition: inline; filename=vcp_add_pagevcompound
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add a page flag that can be used to figure out if a compound page was
virtually mapped (virtualized). The mark is necessary since we have to
know when freeing pages if we have to destroy a virtual mapping and
we need to know that the pages of the compound are not in sequence.

A pageflag is only used if we have lots of available flags
(PAGEFLAGS_EXTENDED). Otherwise no additional flag is needed by
combining PG_swapcache together with PG_compound (similar to
PageHead() and PageTail()).

Overlaying flags has two bad effects:

1. The tests for PageVcompound become more expensive since multiple
   bits must be tested. There is a potential effect on hot codepaths.

2. Vcompound pages can not be on the LRU since PG_swapcache has
   another meaning for pages on the LRU.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/page-flags.h |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

Index: linux-2.6/include/linux/page-flags.h
===================================================================
--- linux-2.6.orig/include/linux/page-flags.h	2008-04-28 14:34:39.953650145 -0700
+++ linux-2.6/include/linux/page-flags.h	2008-04-29 16:45:00.481208036 -0700
@@ -86,6 +86,7 @@ enum pageflags {
 #ifdef CONFIG_PAGEFLAGS_EXTENDED
 	PG_head,		/* A head page */
 	PG_tail,		/* A tail page */
+	PG_vcompound,		/* A virtualized compound page */
 #else
 	PG_compound,		/* A compound page */
 #endif
@@ -262,6 +263,7 @@ static inline void set_page_writeback(st
  */
 __PAGEFLAG(Head, head)
 __PAGEFLAG(Tail, tail)
+__PAGEFLAG(Vcompound, vcompound)
 
 static inline int PageCompound(struct page *page)
 {
@@ -305,6 +307,20 @@ static inline void __ClearPageTail(struc
 	page->flags &= ~PG_head_tail_mask;
 }
 
+#define PG_vcompound_mask ((1L << PG_compound) | (1L << PG_swapcache))
++#define PageVcompound(page)	((page->flags & PG_vcompound_mask) \
+					== PG_vcompound_mask)
+
+static inline void __SetPageVcompound(struct page *page)
+{
+	page->flags |= PG_vcompound_mask;
+}
+
+static inline void __ClearPageVcompound(struct page *page)
+{
+	page->flags &= ~PG_vcompound_mask;
+}
+
 #endif /* !PAGEFLAGS_EXTENDED */
 #endif /* !__GENERATING_BOUNDS_H */
 #endif	/* PAGE_FLAGS_H */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
