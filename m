Message-Id: <20071227053359.844526604@sgi.com>
References: <20071227053246.902699851@sgi.com>
Date: Wed, 26 Dec 2007 21:32:47 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 01/18] Define functions for page cache handling
Content-Disposition: inline; filename=0002-Define-functions-for-page-cache-handling.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

- Use "mapping" instead of "a" as the address space parameter

We use the macros PAGE_CACHE_SIZE PAGE_CACHE_SHIFT PAGE_CACHE_MASK
and PAGE_CACHE_ALIGN in various places in the kernel. Many times
common operations like calculating the offset or the index are coded
using shifts and adds. This patch provides inline functions to
get the calculations accomplished without having to explicitly
shift and add constants.

All functions take an address_space pointer. The address space pointer
will be used in the future to eventually support a variable size
page cache. Information reachable via the mapping may then determine
page size.

New function                    Related base page constant
====================================================================
page_cache_shift(a)             PAGE_CACHE_SHIFT
page_cache_size(a)              PAGE_CACHE_SIZE
page_cache_mask(a)              PAGE_CACHE_MASK
page_cache_index(a, pos)        Calculate page number from position
page_cache_next(addr, pos)      Page number of next page
page_cache_offset(a, pos)       Calculate offset into a page
page_cache_pos(a, index, offset)
                                Form position based on page number
                                and an offset.

This provides a basis that would allow the conversion of all page cache
handling in the kernel and ultimately allow the removal of the PAGE_CACHE_*
constants.

Reviewed-by: Dave Chinner <dgc@sgi.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/pagemap.h |   53 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 52 insertions(+), 1 deletion(-)

Index: linux-2.6.24-rc6-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/pagemap.h	2007-12-26 21:12:59.773000516 -0800
+++ linux-2.6.24-rc6-mm1/include/linux/pagemap.h	2007-12-26 21:19:15.537477621 -0800
@@ -52,12 +52,61 @@ static inline void mapping_set_gfp_mask(
  * space in smaller chunks for same flexibility).
  *
  * Or rather, it _will_ be done in larger chunks.
+ *
+ * The following constants can be used if a filesystem only supports a single
+ * page size.
  */
 #define PAGE_CACHE_SHIFT	PAGE_SHIFT
 #define PAGE_CACHE_SIZE		PAGE_SIZE
 #define PAGE_CACHE_MASK		PAGE_MASK
 #define PAGE_CACHE_ALIGN(addr)	(((addr)+PAGE_CACHE_SIZE-1)&PAGE_CACHE_MASK)
 
+/*
+ * Functions that are currently setup for a fixed PAGE_SIZE. The use of
+ * these may allow larger page sizes in the future.
+ */
+static inline int mapping_order(struct address_space *mapping)
+{
+	return 0;
+}
+
+static inline int page_cache_shift(struct address_space *mapping)
+{
+	return PAGE_SHIFT;
+}
+
+static inline unsigned int page_cache_size(struct address_space *mapping)
+{
+	return PAGE_SIZE;
+}
+
+static inline unsigned int page_cache_offset(struct address_space *mapping,
+		loff_t pos)
+{
+	return pos & ~PAGE_MASK;
+}
+
+static inline pgoff_t page_cache_index(struct address_space *mapping,
+		loff_t pos)
+{
+	return pos >> page_cache_shift(mapping);
+}
+
+/*
+ * Index of the page starting on or after the given position.
+ */
+static inline pgoff_t page_cache_next(struct address_space *mapping,
+		loff_t pos)
+{
+	return page_cache_index(mapping, pos + page_cache_size(mapping) - 1);
+}
+
+static inline loff_t page_cache_pos(struct address_space *mapping,
+		pgoff_t index, unsigned long offset)
+{
+	return ((loff_t)index << page_cache_shift(mapping)) + offset;
+}
+
 #define page_cache_get(page)		get_page(page)
 #define page_cache_release(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
