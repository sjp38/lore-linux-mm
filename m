Message-Id: <20070423062129.804903028@sgi.com>
References: <20070423062107.843307112@sgi.com>
Date: Sun, 22 Apr 2007 23:21:12 -0700
From: clameter@sgi.com
Subject: [RFC 05/16] Variable Order Page Cache: Add functions to establish sizes
Content-Disposition: inline; filename=var_pc_size_functions
To: linux-mm@kvack.org
Cc: Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Adam Litke <aglitke@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Avi Kivity <avi@argo.co.il>, Dave Hansen <hansendc@us.ibm.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>
List-ID: <linux-mm.kvack.org>

We use the macros PAGE_CACHE_SIZE PAGE_CACHE_SHIFT PAGE_CACHE_MASK
and PAGE_CACHE_ALIGN in various places in the kernel. These are now
the base page size but we do not have a means to calculating these
values for higher order pages.

Provide these functions. An address_space pointer must be passed
to them. Also add a set of extended functions that will be used
to consolidate the hand crafted shifts and adds in use right
now for the page cache.

New function			Related base page constant
---------------------------------------------------
page_cache_shift(a)		PAGE_CACHE_SHIFT
page_cache_size(a)		PAGE_CACHE_SIZE
page_cache_mask(a)		PAGE_CACHE_MASK
page_cache_index(a, pos)	Calculate page number from position
page_cache_next(addr, pos)	Page number of next page
page_cache_offset(a, pos)	Calculate offset into a page
page_cache_pos(a, index, offset)
				Form position based on page number
				and an offset.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/pagemap.h |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

Index: linux-2.6.21-rc7/include/linux/pagemap.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/pagemap.h	2007-04-22 17:30:50.000000000 -0700
+++ linux-2.6.21-rc7/include/linux/pagemap.h	2007-04-22 19:44:12.000000000 -0700
@@ -62,6 +62,48 @@ static inline void set_mapping_order(str
 #define PAGE_CACHE_MASK		PAGE_MASK
 #define PAGE_CACHE_ALIGN(addr)	(((addr)+PAGE_CACHE_SIZE-1)&PAGE_CACHE_MASK)
 
+static inline int page_cache_shift(struct address_space *a)
+{
+	return a->order + PAGE_SHIFT;
+}
+
+static inline unsigned int page_cache_size(struct address_space *a)
+{
+	return PAGE_SIZE << a->order;
+}
+
+static inline loff_t page_cache_mask(struct address_space *a)
+{
+	return (loff_t)PAGE_MASK << a->order;
+}
+
+static inline unsigned int page_cache_offset(struct address_space *a,
+		loff_t pos)
+{
+	return pos & ~(PAGE_MASK << a->order);
+}
+
+static inline pgoff_t page_cache_index(struct address_space *a,
+		loff_t pos)
+{
+	return pos >> page_cache_shift(a);
+}
+
+/*
+ * Index of the page starting on or after the given position.
+ */
+static inline pgoff_t page_cache_next(struct address_space *a,
+		loff_t pos)
+{
+	return page_cache_index(a, pos + page_cache_size(a) - 1);
+}
+
+static inline loff_t page_cache_pos(struct address_space *a,
+		pgoff_t index, unsigned long offset)
+{
+	return ((loff_t)index << page_cache_shift(a)) + offset;
+}
+
 #define page_cache_get(page)		get_page(page)
 #define page_cache_release(page)	put_page(page)
 void release_pages(struct page **pages, int nr, int cold);

--
