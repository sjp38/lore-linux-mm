Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [150.166.1.51])
	by relay1.corp.sgi.com (Postfix) with ESMTP id AD2B78F80F7
	for <linux-mm@kvack.org>; Thu, 10 Jan 2008 20:15:38 -0800 (PST)
Received: from clameter (helo=localhost)
	by schroedinger.engr.sgi.com with local-esmtp (Exim 3.36 #1 (Debian))
	id 1JDBIw-0006Fa-00
	for <linux-mm@kvack.org>; Thu, 10 Jan 2008 20:15:38 -0800
Date: Thu, 10 Jan 2008 20:15:38 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: [PATCH] Remove GFP_COLD
Message-ID: <Pine.LNX.4.64.0801102015250.24029@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
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

Index: linux-2.6.24-rc6-mm1/fs/splice.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/fs/splice.c	2008-01-10 19:54:00.147655705 -0800
+++ linux-2.6.24-rc6-mm1/fs/splice.c	2008-01-10 19:54:16.483558860 -0800
@@ -315,7 +315,7 @@ __generic_file_splice_read(struct file *
 			/*
 			 * page didn't exist, allocate one.
 			 */
-			page = page_cache_alloc_cold(mapping);
+			page = page_cache_alloc(mapping);
 			if (!page)
 				break;
 
Index: linux-2.6.24-rc6-mm1/include/linux/gfp.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/gfp.h	2008-01-10 19:54:00.155655612 -0800
+++ linux-2.6.24-rc6-mm1/include/linux/gfp.h	2008-01-10 19:54:16.483558860 -0800
@@ -38,7 +38,6 @@ struct vm_area_struct;
 #define __GFP_HIGH	((__force gfp_t)0x20u)	/* Should access emergency pools? */
 #define __GFP_IO	((__force gfp_t)0x40u)	/* Can start physical IO? */
 #define __GFP_FS	((__force gfp_t)0x80u)	/* Can call down to low-level FS? */
-#define __GFP_COLD	((__force gfp_t)0x100u)	/* Cache-cold page required */
 #define __GFP_NOWARN	((__force gfp_t)0x200u)	/* Suppress page allocation failure warning */
 #define __GFP_REPEAT	((__force gfp_t)0x400u)	/* Retry the allocation.  Might fail */
 #define __GFP_NOFAIL	((__force gfp_t)0x800u)	/* Retry for ever.  Cannot fail */
Index: linux-2.6.24-rc6-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/pagemap.h	2008-01-10 19:54:00.167655710 -0800
+++ linux-2.6.24-rc6-mm1/include/linux/pagemap.h	2008-01-10 19:54:16.487558716 -0800
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
Index: linux-2.6.24-rc6-mm1/include/linux/slab.h
===================================================================
--- linux-2.6.24-rc6-mm1.orig/include/linux/slab.h	2008-01-10 19:54:00.179655299 -0800
+++ linux-2.6.24-rc6-mm1/include/linux/slab.h	2008-01-10 19:54:16.487558716 -0800
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
Index: linux-2.6.24-rc6-mm1/kernel/power/snapshot.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/kernel/power/snapshot.c	2008-01-10 19:54:00.191655644 -0800
+++ linux-2.6.24-rc6-mm1/kernel/power/snapshot.c	2008-01-10 19:54:16.487558716 -0800
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
Index: linux-2.6.24-rc6-mm1/mm/readahead.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/readahead.c	2008-01-10 19:54:00.203655220 -0800
+++ linux-2.6.24-rc6-mm1/mm/readahead.c	2008-01-10 19:54:16.487558716 -0800
@@ -153,7 +153,7 @@ __do_page_cache_readahead(struct address
 		if (page)
 			continue;
 
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc(mapping);
 		if (!page)
 			break;
 		page->index = page_offset;
Index: linux-2.6.24-rc6-mm1/mm/filemap.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/filemap.c	2008-01-10 19:54:00.215655465 -0800
+++ linux-2.6.24-rc6-mm1/mm/filemap.c	2008-01-10 19:54:16.487558716 -0800
@@ -1067,7 +1067,7 @@ no_cached_page:
 		 * Ok, it wasn't cached, so we need to create a new
 		 * page..
 		 */
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc(mapping);
 		if (!page) {
 			desc->error = -ENOMEM;
 			goto out;
@@ -1295,7 +1295,7 @@ static int page_cache_read(struct file *
 	int ret;
 
 	do {
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc(mapping);
 		if (!page)
 			return -ENOMEM;
 
@@ -1529,7 +1529,7 @@ static struct page *__read_cache_page(st
 repeat:
 	page = find_get_page(mapping, index);
 	if (!page) {
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc(mapping);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, GFP_KERNEL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
