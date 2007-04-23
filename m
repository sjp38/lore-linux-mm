From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070423064906.5458.90458.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 04/16] Variable Order Page Cache: Add basic allocation functions
Date: Sun, 22 Apr 2007 23:49:06 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: William Lee Irwin III <wli@holomorphy.com>, Badari Pulavarty <pbadari@gmail.com>, David Chinner <dgc@sgi.com>, Jens Axboe <jens.axboe@oracle.com>, Adam Litke <aglitke@gmail.com>, Christoph Lameter <clameter@sgi.com>, Dave Hansen <hansendc@us.ibm.com>, Mel Gorman <mel@skynet.ie>, Avi Kivity <avi@argo.co.il>
List-ID: <linux-mm.kvack.org>

Variable Order Page Cache: Add basic allocation functions

Extend __page_cache_alloc to take an order parameter and modify caller
sites. Modify mapping_set_gfp_mask to set __GFP_COMP if the mapping
requires higher order allocations.

put_page() is already capable of handling compound pages. So there are no
changes needed to release higher order page cache pages.

However, there is a call to "alloc_page" in mm/filemap.c that does not
perform an allocation conformand with the parameters of the mapping.
Fix that by introducing a new page_cache_alloc function that
is capable of taking a gfp_t flag.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/pagemap.h |   34 ++++++++++++++++++++++++++++------
 mm/filemap.c            |   12 +++++++-----
 2 files changed, 35 insertions(+), 11 deletions(-)

Index: linux-2.6.21-rc7/include/linux/pagemap.h
===================================================================
--- linux-2.6.21-rc7.orig/include/linux/pagemap.h	2007-04-22 21:47:47.000000000 -0700
+++ linux-2.6.21-rc7/include/linux/pagemap.h	2007-04-22 21:52:37.000000000 -0700
@@ -3,6 +3,9 @@
 
 /*
  * Copyright 1995 Linus Torvalds
+ *
+ * (C) 2007 sgi, Christoph Lameter <clameter@sgi.com>
+ * 	Add variable order page cache support.
  */
 #include <linux/mm.h>
 #include <linux/fs.h>
@@ -32,6 +35,18 @@ static inline void mapping_set_gfp_mask(
 {
 	m->flags = (m->flags & ~(__force unsigned long)__GFP_BITS_MASK) |
 				(__force unsigned long)mask;
+	if (m->order)
+		m->flags |= __GFP_COMP;
+}
+
+static inline void set_mapping_order(struct address_space *m, int order)
+{
+	m->order = order;
+
+	if (order)
+		m->flags |= __GFP_COMP;
+	else
+		m->flags &= ~__GFP_COMP;
 }
 
 /*
@@ -40,7 +55,7 @@ static inline void mapping_set_gfp_mask(
  * throughput (it can then be mapped into user
  * space in smaller chunks for same flexibility).
  *
- * Or rather, it _will_ be done in larger chunks.
+ * This is the base page size
  */
 #define PAGE_CACHE_SHIFT	PAGE_SHIFT
 #define PAGE_CACHE_SIZE		PAGE_SIZE
@@ -52,22 +67,29 @@ static inline void mapping_set_gfp_mask(
 void release_pages(struct page **pages, int nr, int cold);
 
 #ifdef CONFIG_NUMA
-extern struct page *__page_cache_alloc(gfp_t gfp);
+extern struct page *__page_cache_alloc(gfp_t gfp, int order);
 #else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
+static inline struct page *__page_cache_alloc(gfp_t gfp, int order)
 {
-	return alloc_pages(gfp, 0);
+	return alloc_pages(gfp, order);
 }
 #endif
 
+static inline struct page *page_cache_alloc_mask(struct address_space *x,
+						gfp_t flags)
+{
+	return __page_cache_alloc(mapping_gfp_mask(x) | flags,
+		x->order);
+}
+
 static inline struct page *page_cache_alloc(struct address_space *x)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x));
+	return page_cache_alloc_mask(x, 0);
 }
 
 static inline struct page *page_cache_alloc_cold(struct address_space *x)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
+	return page_cache_alloc_mask(x, __GFP_COLD);
 }
 
 typedef int filler_t(void *, struct page *);
Index: linux-2.6.21-rc7/mm/filemap.c
===================================================================
--- linux-2.6.21-rc7.orig/mm/filemap.c	2007-04-22 21:47:47.000000000 -0700
+++ linux-2.6.21-rc7/mm/filemap.c	2007-04-22 21:54:00.000000000 -0700
@@ -467,13 +467,13 @@ int add_to_page_cache_lru(struct page *p
 }
 
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc(gfp_t gfp, int order)
 {
 	if (cpuset_do_page_mem_spread()) {
 		int n = cpuset_mem_spread_node();
-		return alloc_pages_node(n, gfp, 0);
+		return alloc_pages_node(n, gfp, order);
 	}
-	return alloc_pages(gfp, 0);
+	return alloc_pages(gfp, order);
 }
 EXPORT_SYMBOL(__page_cache_alloc);
 #endif
@@ -670,7 +670,8 @@ repeat:
 	page = find_lock_page(mapping, index);
 	if (!page) {
 		if (!cached_page) {
-			cached_page = alloc_page(gfp_mask);
+			cached_page =
+				page_cache_alloc_mask(mapping, gfp_mask);
 			if (!cached_page)
 				return NULL;
 		}
@@ -803,7 +804,8 @@ grab_cache_page_nowait(struct address_sp
 		page_cache_release(page);
 		return NULL;
 	}
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
+	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS,
+		mapping->order);
 	if (page && add_to_page_cache_lru(page, mapping, index, GFP_KERNEL)) {
 		page_cache_release(page);
 		page = NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
