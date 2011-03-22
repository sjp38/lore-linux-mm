Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E754B8D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 15:15:09 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2MIrwKL024348
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 14:53:58 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 6B4D16E8048
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 15:15:06 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2MJF5JC276854
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 15:15:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2MJF4VS027948
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 15:15:05 -0400
Subject: [RFC][PATCH 2/2] make new alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Tue, 22 Mar 2011 12:15:03 -0700
References: <20110322191501.7EEC645D@kernel>
In-Reply-To: <20110322191501.7EEC645D@kernel>
Message-Id: <20110322191503.91DA6036@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>


What I really wanted in the end was a highmem-capable alloc_pages_exact(),
so here it is.

It's a bit unfortunate that we have __free_pages_exact() and
free_pages_exact(), but that mess already exists with __free_pages()
vs. free_pages_exact().  So, at worst, this mirrors the mess that we
already have.

I'm also a bit worried that I've not put in something named
alloc_pages_exact(), but that behaves differently.  I got all of the
in-tree cases, but I'm a bit worried about stragglers elsewheree

Note that the __get_free_pages() has a !GFP_HIGHMEM check.  Now that
we're not using it, we had to add a new check to get_free_pages_exact().

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/include/linux/gfp.h |    4 +
 linux-2.6.git-dave/mm/page_alloc.c     |   81 ++++++++++++++++++++++++---------
 2 files changed, 65 insertions(+), 20 deletions(-)

diff -puN include/linux/gfp.h~make_new_alloc_pages_exact include/linux/gfp.h
--- linux-2.6.git/include/linux/gfp.h~make_new_alloc_pages_exact	2011-03-22 12:11:57.557452739 -0700
+++ linux-2.6.git-dave/include/linux/gfp.h	2011-03-22 12:11:57.573452738 -0700
@@ -346,6 +346,10 @@ extern struct page *alloc_pages_vma(gfp_
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
+/* 'struct page' version */
+struct page *alloc_pages_exact(gfp_t gfp_mask, size_t);
+void __free_pages_exact(struct page *page, size_t size);
+/* virtual address version */
 void *get_free_pages_exact(size_t size, gfp_t gfp_mask);
 void free_pages_exact(void *virt, size_t size);
 
diff -puN mm/page_alloc.c~make_new_alloc_pages_exact mm/page_alloc.c
--- linux-2.6.git/mm/page_alloc.c~make_new_alloc_pages_exact	2011-03-22 12:11:57.561452738 -0700
+++ linux-2.6.git-dave/mm/page_alloc.c	2011-03-22 12:11:57.573452738 -0700
@@ -2284,36 +2284,83 @@ void free_pages(unsigned long addr, unsi
 EXPORT_SYMBOL(free_pages);
 
 /**
- * get_free_pages_exact - allocate an exact number physically-contiguous pages.
+ * alloc_pages_exact - allocate an exact number physically-contiguous pages.
  * @size: the number of bytes to allocate
  * @gfp_mask: GFP flags for the allocation
+ * returns: struct page for allocated memory
  *
- * This function is similar to __get_free_pages(), except that it allocates the
- * minimum number of pages to satisfy the request.  get_free_pages() can only
+ * This function is similar to alloc_pages(), except that it allocates the
+ * minimum number of pages to satisfy the request.  alloc_pages() can only
  * allocate memory in power-of-two pages.
  *
  * This function is also limited by MAX_ORDER.
  *
  * Memory allocated by this function must be released by free_pages_exact().
  */
-void *get_free_pages_exact(size_t size, gfp_t gfp_mask)
+struct page *alloc_pages_exact(gfp_t gfp_mask, size_t size)
 {
 	unsigned int order = get_order(size);
-	unsigned long addr;
+	struct page *page;
 
-	addr = __get_free_pages(gfp_mask, order);
-	if (addr) {
-		unsigned long alloc_end = addr + (PAGE_SIZE << order);
-		unsigned long used = addr + PAGE_ALIGN(size);
+	page = alloc_pages(gfp_mask, order);
+	if (page) {
+		struct page *alloc_end = page + (1 << order);
+		struct page *used = page + PAGE_ALIGN(size)/PAGE_SIZE;
 
-		split_page(virt_to_page((void *)addr), order);
+		split_page(page, order);
 		while (used < alloc_end) {
-			free_page(used);
-			used += PAGE_SIZE;
+			__free_page(page);
+			used++;
 		}
 	}
 
-	return (void *)addr;
+	return page;
+}
+EXPORT_SYMBOL(alloc_pages_exact);
+
+/**
+ * __free_pages_exact - release memory allocated via alloc_pages_exact()
+ * @virt: the value returned by alloc_pages_exact().
+ * @size: size of allocation, same value as passed to alloc_pages_exact().
+ *
+ * Release the memory allocated by a previous call to alloc_pages_exact().
+ */
+void __free_pages_exact(struct page *page, size_t size)
+{
+	struct page *end = page + PAGE_ALIGN(size)/PAGE_SIZE;
+
+	while (page < end) {
+		__free_page(page);
+		page++;
+	}
+}
+EXPORT_SYMBOL(__free_pages_exact);
+
+/**
+ * get_free_pages_exact - allocate an exact number physically-contiguous pages.
+ * @size: the number of bytes to allocate
+ * @gfp_mask: GFP flags for the allocation
+ * returns: virtual address of allocated memory
+ *
+ * This function is similar to __get_free_pages(), except that it allocates the
+ * minimum number of pages to satisfy the request.  get_free_pages() can only
+ * allocate memory in power-of-two pages.
+ *
+ * This function is also limited by MAX_ORDER.
+ *
+ * Memory allocated by this function must be released by free_pages_exact().
+ */
+void *get_free_pages_exact(size_t size, gfp_t gfp_mask)
+{
+	struct page *page;
+
+	/* If we are using page_address(), we can not allow highmem */
+	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
+
+	page = alloc_pages_exact(gfp_mask, size);
+	if (page)
+		return (void *) page_address(page);
+	return NULL;
 }
 EXPORT_SYMBOL(get_free_pages_exact);
 
@@ -2326,13 +2373,7 @@ EXPORT_SYMBOL(get_free_pages_exact);
  */
 void free_pages_exact(void *virt, size_t size)
 {
-	unsigned long addr = (unsigned long)virt;
-	unsigned long end = addr + PAGE_ALIGN(size);
-
-	while (addr < end) {
-		free_page(addr);
-		addr += PAGE_SIZE;
-	}
+	__free_pages_exact(virt_to_page(virt), size);
 }
 EXPORT_SYMBOL(free_pages_exact);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
