From: Andi Kleen <andi@firstfloor.org>
References: <200803071007.493903088@firstfloor.org>
In-Reply-To: <200803071007.493903088@firstfloor.org>
Subject: [PATCH] [7/13] Implement compat hooks for GFP_DMA
Message-Id: <20080307090717.A146E1B419D@basil.firstfloor.org>
Date: Fri,  7 Mar 2008 10:07:17 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Add code to the normal allocation path to call the mask allocator
transparently for GFP_DMA allocations.

This is only a temporary measure and will go away as soon as all
the drivers are converted to use the mask allocator or one
of its callers (like PCI DMA API) directly.

But currently it is the only sane way to do a bisectable step by 
step conversion of the GFP_DMA users in tree.

Right now the special pagevec free function won't handle mask allocated
pages.

Signed-off-by: Andi Kleen <ak@suse.de>

---
 include/linux/page-flags.h |    4 ++++
 mm/page_alloc.c            |   18 ++++++++++++++++++
 2 files changed, 22 insertions(+)

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -499,6 +499,12 @@ static void __free_pages_ok(struct page 
 	int i;
 	int reserved = 0;
 
+	/* Compat code for now. Will go away */
+	if (unlikely(PageMaskAlloc(page))) {
+		__free_pages_mask(page, PAGE_SIZE << order);
+		return;
+	}
+
 	for (i = 0 ; i < (1 << order) ; ++i)
 		reserved += free_pages_check(page + i, 1 << PG_mask_alloc);
 	if (reserved)
@@ -1422,6 +1428,13 @@ __alloc_pages(gfp_t gfp_mask, unsigned i
 	if (should_fail_alloc_page(gfp_mask, order))
 		return NULL;
 
+#ifdef CONFIG_MASK_ALLOC
+	/* Compat code for now. Will go away. */
+	if (unlikely(gfp_mask & GFP_DMA))
+		return alloc_pages_mask(gfp_mask & ~__GFP_DMA,
+					PAGE_SIZE << order, TRAD_DMA_MASK);
+#endif
+
 restart:
 	z = zonelist->zones;  /* the list of zones suitable for gfp_mask */
 
@@ -1635,6 +1648,11 @@ void __pagevec_free(struct pagevec *pvec
 
 void __free_pages(struct page *page, unsigned int order)
 {
+	/* Compat code for now. Will go away */
+	if (unlikely(PageMaskAlloc(page))) {
+		__free_pages_mask(page, PAGE_SIZE << order);
+		return;
+	}
 	if (put_page_testzero(page)) {
 		if (order == 0)
 			free_hot_page(page);
Index: linux/include/linux/page-flags.h
===================================================================
--- linux.orig/include/linux/page-flags.h
+++ linux/include/linux/page-flags.h
@@ -257,9 +257,13 @@ static inline void SetPageUptodate(struc
 #define __SetPageCompound(page)	__set_bit(PG_compound, &(page)->flags)
 #define __ClearPageCompound(page) __clear_bit(PG_compound, &(page)->flags)
 
+#ifdef CONFIG_MASK_ALLOC
 #define PageMaskAlloc(page)	test_bit(PG_mask_alloc, &(page)->flags)
 #define __SetPageMaskAlloc(page)	__set_bit(PG_mask_alloc, &(page)->flags)
 #define __ClearPageMaskAlloc(page) __clear_bit(PG_mask_alloc, &(page)->flags)
+#else
+#define PageMaskAlloc(page)	0
+#endif
 
 /*
  * PG_reclaim is used in combination with PG_compound to mark the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
