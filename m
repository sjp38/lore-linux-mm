Message-Id: <20080212003803.761113538@sgi.com>
References: <20080212003643.536643832@sgi.com>
Date: Mon, 11 Feb 2008 16:36:45 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 2/3] Remove GFP_COLD
Content-Disposition: inline; filename=hotcold_2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On top of the patch that eliminates the hot/cold distinction:

There is no point in having GFP_COLD if we do not have a hot/cold distinction
in the pcp lists. Remove __GFP_COLD and the use of page_cache_alloc_cold().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/splice.c             |    2 +-
 include/linux/gfp.h     |    1 -
 include/linux/pagemap.h |    5 -----
 include/linux/slab.h    |    3 ---
 kernel/power/snapshot.c |    8 ++++----
 mm/filemap.c            |    6 +++---
 mm/readahead.c          |    2 +-
 7 files changed, 9 insertions(+), 18 deletions(-)

Index: linux-2.6/fs/splice.c
===================================================================
--- linux-2.6.orig/fs/splice.c	2008-02-11 11:03:08.000000000 -0800
+++ linux-2.6/fs/splice.c	2008-02-11 16:18:47.000000000 -0800
@@ -315,7 +315,7 @@ __generic_file_splice_read(struct file *
 			/*
 			 * page didn't exist, allocate one.
 			 */
-			page = page_cache_alloc_cold(mapping);
+			page = page_cache_alloc(mapping);
 			if (!page)
 				break;
 
Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h	2008-02-11 16:18:36.000000000 -0800
+++ linux-2.6/include/linux/gfp.h	2008-02-11 16:18:47.000000000 -0800
@@ -38,7 +38,6 @@ struct vm_area_struct;
 #define __GFP_HIGH	((__force gfp_t)0x20u)	/* Should access emergency pools? */
 #define __GFP_IO	((__force gfp_t)0x40u)	/* Can start physical IO? */
 #define __GFP_FS	((__force gfp_t)0x80u)	/* Can call down to low-level FS? */
-#define __GFP_COLD	((__force gfp_t)0x100u)	/* Cache-cold page required */
 #define __GFP_NOWARN	((__force gfp_t)0x200u)	/* Suppress page allocation failure warning */
 #define __GFP_REPEAT	((__force gfp_t)0x400u)	/* Retry the allocation.  Might fail */
 #define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* Retry for ever.  Cannot fail */
Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2008-01-31 19:06:09.000000000 -0800
+++ linux-2.6/include/linux/pagemap.h	2008-02-11 16:18:47.000000000 -0800
@@ -76,11 +76,6 @@ static inline struct page *page_cache_al
 	return __page_cache_alloc(mapping_gfp_mask(x));
 }
 
-static inline struct page *page_cache_alloc_cold(struct address_space *x)
-{
-	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
-}
-
 typedef int filler_t(void *, struct page *);
 
 extern struct page * find_get_page(struct address_space *mapping,
Index: linux-2.6/include/linux/slab.h
===================================================================
--- linux-2.6.orig/include/linux/slab.h	2008-01-29 18:17:22.000000000 -0800
+++ linux-2.6/include/linux/slab.h	2008-02-11 16:18:47.000000000 -0800
@@ -154,9 +154,6 @@ size_t ksize(const void *);
  * Also it is possible to set different flags by OR'ing
  * in one or more of the following additional @flags:
  *
- * %__GFP_COLD - Request cache-cold pages instead of
- *   trying to return cache-warm pages.
- *
  * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
  *
  * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
Index: linux-2.6/kernel/power/snapshot.c
===================================================================
--- linux-2.6.orig/kernel/power/snapshot.c	2008-02-07 19:07:05.000000000 -0800
+++ linux-2.6/kernel/power/snapshot.c	2008-02-11 16:18:47.000000000 -0800
@@ -1102,7 +1102,7 @@ static int enough_free_mem(unsigned int 
 
 static inline int get_highmem_buffer(int safe_needed)
 {
-	buffer = get_image_page(GFP_ATOMIC | __GFP_COLD, safe_needed);
+	buffer = get_image_page(GFP_ATOMIC, safe_needed);
 	return buffer ? 0 : -ENOMEM;
 }
 
@@ -1154,11 +1154,11 @@ swsusp_alloc(struct memory_bitmap *orig_
 {
 	int error;
 
-	error = memory_bm_create(orig_bm, GFP_ATOMIC | __GFP_COLD, PG_ANY);
+	error = memory_bm_create(orig_bm, GFP_ATOMIC, PG_ANY);
 	if (error)
 		goto Free;
 
-	error = memory_bm_create(copy_bm, GFP_ATOMIC | __GFP_COLD, PG_ANY);
+	error = memory_bm_create(copy_bm, GFP_ATOMIC, PG_ANY);
 	if (error)
 		goto Free;
 
@@ -1170,7 +1170,7 @@ swsusp_alloc(struct memory_bitmap *orig_
 		nr_pages += alloc_highmem_image_pages(copy_bm, nr_highmem);
 	}
 	while (nr_pages-- > 0) {
-		struct page *page = alloc_image_page(GFP_ATOMIC | __GFP_COLD);
+		struct page *page = alloc_image_page(GFP_ATOMIC);
 
 		if (!page)
 			goto Free;
Index: linux-2.6/mm/readahead.c
===================================================================
--- linux-2.6.orig/mm/readahead.c	2007-11-09 19:30:31.000000000 -0800
+++ linux-2.6/mm/readahead.c	2008-02-11 16:18:47.000000000 -0800
@@ -153,7 +153,7 @@ __do_page_cache_readahead(struct address
 		if (page)
 			continue;
 
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc(mapping);
 		if (!page)
 			break;
 		page->index = page_offset;
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2008-02-08 13:22:14.000000000 -0800
+++ linux-2.6/mm/filemap.c	2008-02-11 16:18:47.000000000 -0800
@@ -1058,7 +1058,7 @@ no_cached_page:
 		 * Ok, it wasn't cached, so we need to create a new
 		 * page..
 		 */
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc(mapping);
 		if (!page) {
 			desc->error = -ENOMEM;
 			goto out;
@@ -1285,7 +1285,7 @@ static int page_cache_read(struct file *
 	int ret;
 
 	do {
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc(mapping);
 		if (!page)
 			return -ENOMEM;
 
@@ -1519,7 +1519,7 @@ static struct page *__read_cache_page(st
 repeat:
 	page = find_get_page(mapping, index);
 	if (!page) {
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc(mapping);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, GFP_KERNEL);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
