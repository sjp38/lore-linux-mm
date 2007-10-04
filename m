Message-Id: <20071004040003.303112696@sgi.com>
References: <20071004035935.042951211@sgi.com>
Date: Wed, 03 Oct 2007 20:59:42 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [07/18] Vcompound: Add compound_nth_page() to determine nth base page
Content-Disposition: inline; filename=vcompound_compound_nth_page
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Add a new function

        compound_nth_page(page, n)

and
	vmalloc_nth_page(page, n)

to find the nth page of a compound page. For real compound pages
his simply reduces to page + n. For virtual compound pages we need to consult
the page tables to figure out the nth page from the one specified.

Update all the references to page[1] to use compound_nth instead.

---
 include/linux/mm.h |   17 +++++++++++++----
 mm/page_alloc.c    |   16 +++++++++++-----
 mm/vmalloc.c       |   10 ++++++++++
 3 files changed, 34 insertions(+), 9 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2007-10-03 19:31:45.000000000 -0700
+++ linux-2.6/include/linux/mm.h	2007-10-03 19:31:51.000000000 -0700
@@ -295,6 +295,8 @@ static inline int get_page_unless_zero(s
 }
 
 void *vmalloc_address(struct page *);
+struct page *vmalloc_to_page(void *addr);
+struct page *vmalloc_nth_page(struct page *page, int n);
 
 static inline struct page *compound_head(struct page *page)
 {
@@ -338,27 +340,34 @@ void split_page(struct page *page, unsig
  */
 typedef void compound_page_dtor(struct page *);
 
+static inline struct page *compound_nth_page(struct page *page, int n)
+{
+	if (likely(!PageVcompound(page)))
+		return page + n;
+	return vmalloc_nth_page(page, n);
+}
+
 static inline void set_compound_page_dtor(struct page *page,
 						compound_page_dtor *dtor)
 {
-	page[1].lru.next = (void *)dtor;
+	compound_nth_page(page, 1)->lru.next = (void *)dtor;
 }
 
 static inline compound_page_dtor *get_compound_page_dtor(struct page *page)
 {
-	return (compound_page_dtor *)page[1].lru.next;
+	return (compound_page_dtor *)compound_nth_page(page, 1)->lru.next;
 }
 
 static inline int compound_order(struct page *page)
 {
 	if (!PageHead(page))
 		return 0;
-	return (unsigned long)page[1].lru.prev;
+	return (unsigned long)compound_nth_page(page, 1)->lru.prev;
 }
 
 static inline void set_compound_order(struct page *page, unsigned long order)
 {
-	page[1].lru.prev = (void *)order;
+	compound_nth_page(page, 1)->lru.prev = (void *)order;
 }
 
 /*
Index: linux-2.6/mm/vmalloc.c
===================================================================
--- linux-2.6.orig/mm/vmalloc.c	2007-10-03 19:31:45.000000000 -0700
+++ linux-2.6/mm/vmalloc.c	2007-10-03 19:31:51.000000000 -0700
@@ -541,6 +541,16 @@ void *vmalloc(unsigned long size)
 }
 EXPORT_SYMBOL(vmalloc);
 
+/*
+ * Given a pointer to the first page struct:
+ * Determine a pointer to the nth page.
+ */
+struct page *vmalloc_nth_page(struct page *page, int n)
+{
+	return vmalloc_to_page(page_address(page) + n * PAGE_SIZE);
+}
+EXPORT_SYMBOL(vmalloc_nth_page);
+
 /**
  * vmalloc_user - allocate zeroed virtually contiguous memory for userspace
  * @size: allocation size
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2007-10-03 19:31:51.000000000 -0700
+++ linux-2.6/mm/page_alloc.c	2007-10-03 19:32:45.000000000 -0700
@@ -274,7 +274,7 @@ static void prep_compound_page(struct pa
 	set_compound_order(page, order);
 	__SetPageHead(page);
 	for (i = 1; i < nr_pages; i++) {
-		struct page *p = page + i;
+		struct page *p = compound_nth_page(page, i);
 
 		__SetPageTail(p);
 		p->first_page = page;
@@ -289,17 +289,23 @@ static void destroy_compound_page(struct
 	if (unlikely(compound_order(page) != order))
 		bad_page(page);
 
-	if (unlikely(!PageHead(page)))
-			bad_page(page);
-	__ClearPageHead(page);
 	for (i = 1; i < nr_pages; i++) {
-		struct page *p = page + i;
+		struct page *p = compound_nth_page(page,  i);
 
 		if (unlikely(!PageTail(p) |
 				(p->first_page != page)))
 			bad_page(page);
 		__ClearPageTail(p);
 	}
+
+	/*
+	 * The PageHead is important since it determines how operations on
+	 * a compound page have to be performed. We can only tear the head
+	 * down after all the tail pages are done.
+	 */
+	if (unlikely(!PageHead(page)))
+			bad_page(page);
+	__ClearPageHead(page);
 }
 
 static inline void prep_zero_page(struct page *page, int order, gfp_t gfp_flags)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
