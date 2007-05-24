From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 24 May 2007 13:29:07 -0400
Message-Id: <20070524172907.13933.62003.sendpatchset@localhost>
In-Reply-To: <20070524172821.13933.80093.sendpatchset@localhost>
References: <20070524172821.13933.80093.sendpatchset@localhost>
Subject: [PATCH/RFC 6/8] Mapped File Policy: use file policy for page cache allocations
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nish.aravamudan@gmail.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Mapped File Policy 6/8 - use file policy for page cache allocations

Against 2.6.22-rc2-mm1

This patch implements a "get_file_policy()" function, analogous
to get_vma_policy(), but for a given file[inode/mapping] at
at specified offset, using the shared_policy, if any, in the
file's address_space.  If no shared policy, returns the process
policy of the argument task [to match get_vma_policy() args] or
default policy, if no process policy.

Revert [__]page_cache_alloc() to take mapping argument as I need
that to locate the shared policy.  Add pgoff_t and gfp_t modifier
arguments.  Fix up page_cache_alloc() and page_cache_alloc_cold()
in pagemap.h and all direct callers of __page_cache_alloc accordingly.

Modify __page_cache_alloc() to use get_file_policy() and
alloc_page_pol().  

page_cache_alloc*() now take an additional offset/index
argument, available at all call sites, to lookup the appropriate
policy.  The patches fixes all in kernel users of the modified
interfaces.

Re: interaction with cpusets page spread:  if the file has a
shared policy structure attached, that takes precedence over
spreading.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 fs/ntfs/file.c          |    2 +-
 fs/splice.c             |    4 ++--
 include/linux/mm.h      |    6 +++++-
 include/linux/pagemap.h |   19 ++++++++++++-------
 mm/filemap.c            |   47 ++++++++++++++++++++++++++++++++++++++---------
 mm/readahead.c          |    2 +-
 6 files changed, 59 insertions(+), 21 deletions(-)

Index: Linux/mm/filemap.c
===================================================================
--- Linux.orig/mm/filemap.c	2007-05-23 11:34:43.000000000 -0400
+++ Linux/mm/filemap.c	2007-05-23 12:19:46.000000000 -0400
@@ -470,13 +470,41 @@ int add_to_page_cache_lru(struct page *p
 }
 
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+/**
+ * __page_cache_alloc - allocate a page cache page
+ * @mapping - address_space for which page will be allocated
+ * @pgoff   - page index in mapping -- for mem policy
+ * @gfp_sub - gfp flags to be removed from mapping's gfp
+ * @gfp_add - gfp flags to be added to mapping's gfp
+ *
+ * If the mapping does not contain a shared policy, and page cache spreading
+ * is enabled for the current context's cpuset, allocate a page from the node
+ * indicated by page cache spreading.
+ *
+ * Otherwise, fetch the memory policy at the indicated pgoff and allocate
+ * a page according to that policy.  Note that if the mapping does not
+ * have a shared policy, the allocation will use the task policy, if any,
+ * else the system default policy.
+ *
+ * All allocations will use the mapping's gfp mask, as modified by the
+ * gfp_sub and gfp_add arguments.
+ */
+struct page *__page_cache_alloc(struct address_space *mapping, pgoff_t pgoff,
+					gfp_t gfp_sub, gfp_t gfp_add)
 {
-	if (cpuset_do_page_mem_spread()) {
+	struct mempolicy *pol;
+	gfp_t gfp = (mapping_gfp_mask(mapping) & ~gfp_sub) | gfp_add;
+
+	/*
+	 * Consider spreading only if no shared_policy
+	 */
+	if (!mapping->spolicy && cpuset_do_page_mem_spread()) {
 		int n = cpuset_mem_spread_node();
 		return alloc_pages_node(n, gfp, 0);
 	}
-	return alloc_pages(gfp, 0);
+
+	pol = get_file_policy(current, mapping, pgoff);
+	return alloc_page_pol(gfp, pol, pgoff);
 }
 EXPORT_SYMBOL(__page_cache_alloc);
 
@@ -697,7 +725,8 @@ repeat:
 	if (!page) {
 		if (!cached_page) {
 			cached_page =
-				__page_cache_alloc(gfp_mask);
+				__page_cache_alloc(mapping, index,
+					 ~0, gfp_mask);
 			if (!cached_page)
 				return NULL;
 		}
@@ -833,7 +862,7 @@ grab_cache_page_nowait(struct address_sp
 		page_cache_release(page);
 		return NULL;
 	}
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
+	page = __page_cache_alloc(mapping, index, __GFP_FS, 0);
 	if (page && add_to_page_cache_lru(page, mapping, index, GFP_KERNEL)) {
 		page_cache_release(page);
 		page = NULL;
@@ -1084,7 +1113,7 @@ no_cached_page:
 		 * page..
 		 */
 		if (!cached_page) {
-			cached_page = page_cache_alloc_cold(mapping);
+			cached_page = page_cache_alloc_cold(mapping, index);
 			if (!cached_page) {
 				desc->error = -ENOMEM;
 				goto out;
@@ -1354,7 +1383,7 @@ static int fastcall page_cache_read(stru
 	int ret;
 
 	do {
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, offset);
 		if (!page)
 			return -ENOMEM;
 
@@ -1607,7 +1636,7 @@ repeat:
 	page = find_get_page(mapping, index);
 	if (!page) {
 		if (!cached_page) {
-			cached_page = page_cache_alloc_cold(mapping);
+			cached_page = page_cache_alloc_cold(mapping, index);
 			if (!cached_page)
 				return ERR_PTR(-ENOMEM);
 		}
@@ -1721,7 +1750,7 @@ repeat:
 	page = find_lock_page(mapping, index);
 	if (!page) {
 		if (!*cached_page) {
-			*cached_page = page_cache_alloc(mapping);
+			*cached_page = page_cache_alloc(mapping, index);
 			if (!*cached_page)
 				return NULL;
 		}
Index: Linux/include/linux/pagemap.h
===================================================================
--- Linux.orig/include/linux/pagemap.h	2007-05-23 10:56:54.000000000 -0400
+++ Linux/include/linux/pagemap.h	2007-05-23 12:02:53.000000000 -0400
@@ -63,22 +63,27 @@ static inline void mapping_set_gfp_mask(
 void release_pages(struct page **pages, int nr, int cold);
 
 #ifdef CONFIG_NUMA
-extern struct page *__page_cache_alloc(gfp_t gfp);
+extern struct page *__page_cache_alloc(struct address_space *, pgoff_t,
+							gfp_t,  gfp_t);
 #else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
+static inline struct page *__page_cache_alloc(struct address_space *mapping,
+						pgoff_t off,
+						gfp_t gfp_sub, gfp_t gfp_add)
 {
-	return alloc_pages(gfp, 0);
+	return alloc_pages((mapping_gfp_mask(mapping) & ~gfp_sub) | gfp_add, 0);
 }
 #endif
 
-static inline struct page *page_cache_alloc(struct address_space *x)
+static inline struct page *page_cache_alloc(struct address_space *mapping,
+						pgoff_t off)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x));
+	return __page_cache_alloc(mapping, off, 0, 0);
 }
 
-static inline struct page *page_cache_alloc_cold(struct address_space *x)
+static inline struct page *page_cache_alloc_cold(struct address_space *mapping,
+						pgoff_t off)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
+	return __page_cache_alloc(mapping, off, 0, __GFP_COLD);
 }
 
 typedef int filler_t(void *, struct page *);
Index: Linux/fs/splice.c
===================================================================
--- Linux.orig/fs/splice.c	2007-05-23 10:57:03.000000000 -0400
+++ Linux/fs/splice.c	2007-05-23 11:34:48.000000000 -0400
@@ -317,7 +317,7 @@ __generic_file_splice_read(struct file *
 			/*
 			 * page didn't exist, allocate one.
 			 */
-			page = page_cache_alloc_cold(mapping);
+			page = page_cache_alloc_cold(mapping, index);
 			if (!page)
 				break;
 
@@ -575,7 +575,7 @@ find_page:
 	page = find_lock_page(mapping, index);
 	if (!page) {
 		ret = -ENOMEM;
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, index);
 		if (unlikely(!page))
 			goto out_ret;
 
Index: Linux/mm/readahead.c
===================================================================
--- Linux.orig/mm/readahead.c	2007-05-23 10:57:09.000000000 -0400
+++ Linux/mm/readahead.c	2007-05-23 11:34:48.000000000 -0400
@@ -168,7 +168,7 @@ __do_page_cache_readahead(struct address
 			continue;
 
 		read_unlock_irq(&mapping->tree_lock);
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, page_offset);
 		read_lock_irq(&mapping->tree_lock);
 		if (!page)
 			break;
Index: Linux/fs/ntfs/file.c
===================================================================
--- Linux.orig/fs/ntfs/file.c	2007-05-23 10:57:02.000000000 -0400
+++ Linux/fs/ntfs/file.c	2007-05-23 11:34:48.000000000 -0400
@@ -424,7 +424,7 @@ static inline int __ntfs_grab_cache_page
 		pages[nr] = find_lock_page(mapping, index);
 		if (!pages[nr]) {
 			if (!*cached_page) {
-				*cached_page = page_cache_alloc(mapping);
+				*cached_page = page_cache_alloc(mapping, index);
 				if (unlikely(!*cached_page)) {
 					err = -ENOMEM;
 					goto err_out;
Index: Linux/include/linux/mm.h
===================================================================
--- Linux.orig/include/linux/mm.h	2007-05-23 11:34:43.000000000 -0400
+++ Linux/include/linux/mm.h	2007-05-23 12:15:52.000000000 -0400
@@ -1059,11 +1059,15 @@ extern void setup_per_cpu_pageset(void);
 
 /*
  * Address to offset for shared mapping policy lookup.
+ * When used for interleaving hugepagefs pages [when shift
+ * == HPAGE_SHIFT], actually returns hugepage offset in
+ * mapping; NOT file page offset.
  */
 static inline pgoff_t vma_addr_to_pgoff(struct vm_area_struct *vma,
 		unsigned long addr, int shift)
 {
-	return ((addr - vma->vm_start) >> shift) + vma->vm_pgoff;
+	return ((addr - vma->vm_start) >> shift) +
+		(vma->vm_pgoff >> (shift - PAGE_SHIFT));
 }
 
 int generic_file_set_policy(struct vm_area_struct *vma,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
