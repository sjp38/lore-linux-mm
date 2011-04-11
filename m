Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 29D278D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 18:03:59 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3BLwMi6027293
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 15:58:22 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3BM3mto098870
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 16:03:48 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3BM3lrJ005386
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 16:03:48 -0600
Subject: [PATCH 2/3] make new alloc_pages_exact()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 11 Apr 2011 15:03:46 -0700
References: <20110411220345.9B95067C@kernel>
In-Reply-To: <20110411220345.9B95067C@kernel>
Message-Id: <20110411220346.2FED5787@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Timur Tabi <timur@freescale.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>


What I really wanted in the end was a highmem-capable alloc_pages_exact(),
so here it is.  This function can be used to allocate unmapped (like
highmem) non-power-of-two-sized areas of memory.  This is in constast to
get_free_pages_exact() which can only allocate from lowmem.

My plan is to use this in the virtio_balloon driver to allocate large,
oddly-sized contiguous areas.

The new __alloc_pages_exact() now takes a size in numbers of pages,
and returns a 'struct page', which means it can now address highmem.

It's a bit unfortunate that this introduces __free_pages_exact()
alongside free_pages_exact().  But that mess already exists with
__free_pages() vs. free_pages_exact().  So, at worst, this mirrors
the mess that we already have.

I'm also a bit worried that I've not put in something named
alloc_pages_exact(), but that behaves differently than it did before this
set.  I got all of the in-tree cases, but I'm a bit worried about
stragglers elsewhere.  So, I'm calling this __alloc_pages_exact() for
the moment.  We can take out the __ some day if it bothers people.

Note that the __get_free_pages() has a !GFP_HIGHMEM check.  Now that
we are using alloc_pages_exact() instead of __get_free_pages() for
get_free_pages_exact(), we had to add a new check in
get_free_pages_exact().

This has been compile and boot tested, and I checked that

	echo 2 > /sys/kernel/profiling

still works, since it uses get_free_pages_exact().

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/include/linux/gfp.h |    4 +
 linux-2.6.git-dave/mm/page_alloc.c     |   84 ++++++++++++++++++++++++---------
 2 files changed, 67 insertions(+), 21 deletions(-)

diff -puN include/linux/gfp.h~make_new_alloc_pages_exact include/linux/gfp.h
--- linux-2.6.git/include/linux/gfp.h~make_new_alloc_pages_exact	2011-04-11 15:01:17.165822836 -0700
+++ linux-2.6.git-dave/include/linux/gfp.h	2011-04-11 15:01:17.177822831 -0700
@@ -351,6 +351,10 @@ extern struct page *alloc_pages_vma(gfp_
 extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
+/* 'struct page' version */
+struct page *__alloc_pages_exact(gfp_t gfp_mask, size_t size);
+void __free_pages_exact(struct page *page, size_t size);
+/* virtual address version */
 void *get_free_pages_exact(gfp_t gfp_mask, size_t size);
 void free_pages_exact(void *virt, size_t size);
 
diff -puN mm/page_alloc.c~make_new_alloc_pages_exact mm/page_alloc.c
--- linux-2.6.git/mm/page_alloc.c~make_new_alloc_pages_exact	2011-04-11 15:01:17.169822835 -0700
+++ linux-2.6.git-dave/mm/page_alloc.c	2011-04-11 15:01:17.177822831 -0700
@@ -2318,9 +2318,10 @@ void free_pages(unsigned long addr, unsi
 EXPORT_SYMBOL(free_pages);
 
 /**
- * get_free_pages_exact - allocate an exact number physically-contiguous pages.
- * @size: the number of bytes to allocate
+ * __alloc_pages_exact - allocate an exact number physically-contiguous pages.
+ * @nr_pages: the number of pages to allocate
  * @gfp_mask: GFP flags for the allocation
+ * returns: struct page for allocated memory
  *
  * This function is similar to alloc_pages(), except that it allocates the
  * minimum number of pages to satisfy the request.  alloc_pages() can only
@@ -2330,29 +2331,75 @@ EXPORT_SYMBOL(free_pages);
  *
  * Memory allocated by this function must be released by free_pages_exact().
  */
-void *get_free_pages_exact(gfp_t gfp_mask, size_t size)
+struct page *__alloc_pages_exact(gfp_t gfp_mask, size_t nr_pages)
 {
-	unsigned int order = get_order(size);
-	unsigned long addr;
+	unsigned int order = get_order(nr_pages * PAGE_SIZE);
+	struct page *page;
 
-	addr = __get_free_pages(gfp_mask, order);
-	if (addr) {
-		unsigned long alloc_end = addr + (PAGE_SIZE << order);
-		unsigned long used = addr + PAGE_ALIGN(size);
+	page = alloc_pages(gfp_mask, order);
+	if (page) {
+		struct page *alloc_end = page + (1 << order);
+		struct page *used = page + nr_pages;
 
-		split_page(virt_to_page((void *)addr), order);
+		split_page(page, order);
 		while (used < alloc_end) {
-			free_page(used);
-			used += PAGE_SIZE;
+			__free_page(used);
+			used++;
 		}
 	}
 
-	return (void *)addr;
+	return page;
+}
+EXPORT_SYMBOL(__alloc_pages_exact);
+
+/**
+ * __free_pages_exact - release memory allocated via __alloc_pages_exact()
+ * @virt: the value returned by get_free_pages_exact.
+ * @nr_pages: size in pages, same value as passed to __alloc_pages_exact().
+ *
+ * Release the memory allocated by a previous call to __alloc_pages_exact().
+ */
+void __free_pages_exact(struct page *page, size_t nr_pages)
+{
+	struct page *end = page + nr_pages;
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
+ * @gfp_mask: GFP flags for the allocation
+ * @size: the number of bytes to allocate
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
+void *get_free_pages_exact(gfp_t gfp_mask, size_t size)
+{
+	struct page *page;
+
+	/* If we are using page_address(), we can not allow highmem */
+	VM_BUG_ON((gfp_mask & __GFP_HIGHMEM) != 0);
+
+	page = __alloc_pages_exact(gfp_mask, size * PAGE_SIZE);
+	if (page)
+		return (void *) page_address(page);
+	return NULL;
 }
 EXPORT_SYMBOL(get_free_pages_exact);
 
 /**
- * free_pages_exact - release memory allocated via get_free_pages_exact()
+ * __free_pages_exact - release memory allocated via get_free_pages_exact()
  * @virt: the value returned by get_free_pages_exact.
  * @size: size of allocation, same value as passed to get_free_pages_exact().
  *
@@ -2360,13 +2407,8 @@ EXPORT_SYMBOL(get_free_pages_exact);
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
+	int nr_pages = PAGE_ALIGN(size)/PAGE_SIZE;
+	__free_pages_exact(virt_to_page(virt), nr_pages);
 }
 EXPORT_SYMBOL(free_pages_exact);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
