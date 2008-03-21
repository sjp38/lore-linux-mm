Message-Id: <20080321061724.515504935@sgi.com>
References: <20080321061703.921169367@sgi.com>
Date: Thu, 20 Mar 2008 23:17:05 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [02/14] vcompound: pageflags: Add PageVcompound()
Content-Disposition: inline; filename=0004-vcompound-Pageflags-Add-PageVcompound.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add a another page flag that can be used to figure out if a compound
page is virtually mapped. The mark is necessary since we have to know
when freeing pages if we have to destroy a virtual mapping.

No additional flag is needed. We use PG_swapcache together with PG_compound
(similar to PageHead() and PageTail()) to signal that a compound
page is virtually mapped. PG_swapcache is not used at this point since
compound pages cannot be put onto the LRU (yet).

Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/page-flags.h |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

Index: linux-2.6.25-rc5-mm1/include/linux/page-flags.h
===================================================================
--- linux-2.6.25-rc5-mm1.orig/include/linux/page-flags.h	2008-03-20 17:40:16.141487362 -0700
+++ linux-2.6.25-rc5-mm1/include/linux/page-flags.h	2008-03-20 17:41:58.768233703 -0700
@@ -196,6 +196,24 @@ static inline int PageHighMem(struct pag
 }
 #endif
 
+/*
+ * PG_swapcache is used in combination with PG_compound to indicate
+ * that a compound page was allocated via vmalloc.
+ */
+#define PG_vcompound_mask ((1L << PG_compound) | (1L << PG_swapcache))
+#define PageVcompound(page)	((page->flags & PG_vcompound_mask) \
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
 #ifdef CONFIG_SWAP
 PAGEFLAG(SwapCache, swapcache)
 #else

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
