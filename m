From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 25 Jun 2007 15:53:13 -0400
Message-Id: <20070625195313.21210.85625.sendpatchset@localhost>
In-Reply-To: <20070625195224.21210.89898.sendpatchset@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
Subject: [PATCH/RFC 7/11] Shared Policy: use shared policy for page cache allocations
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Shared Mapped File Policy 7/11 use shared policy for page cache allocations

Against 2.6.22-rc4-mm2

This patch implements a "get_file_policy()" function, analogous
to get_vma_policy(), but for a given file[inode/mapping] at
at specified offset, using the shared_policy, if any, in the
file's address_space.  If no shared policy, returns the process
policy of the argument task [to match get_vma_policy() args] or
default policy, if no process policy.

	Note that for a file policy to exist the file must currently
	be mmap()ed into a task's address space with MAP_SHARED,
	with the policy installed via mbind().

	A later patch will hook up the generic file mempolicy
	vm_ops and define a per cpuset control file to enable
	this semantic.  Default will be same as current behavior--
	no policy on shared file mapping

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
shared policy structure attached, that policy takes precedence
over spreading.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 fs/ntfs/file.c          |    2 +-
 fs/splice.c             |    2 +-
 include/linux/pagemap.h |   19 ++++++++++++-------
 mm/filemap.c            |   48 +++++++++++++++++++++++++++++++++++++++---------
 mm/readahead.c          |    2 +-
 5 files changed, 54 insertions(+), 19 deletions(-)

Index: Linux/mm/filemap.c
===================================================================
--- Linux.orig/mm/filemap.c	2007-06-25 15:00:39.000000000 -0400
+++ Linux/mm/filemap.c	2007-06-25 15:03:25.000000000 -0400
@@ -31,6 +31,8 @@
 #include <linux/syscalls.h>
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
+#include <linux/mempolicy.h>
+
 #include "internal.h"
 
 /*
@@ -469,13 +471,41 @@ int add_to_page_cache_lru(struct page *p
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
 #endif
@@ -671,7 +701,7 @@ struct page *find_or_create_page(struct 
 repeat:
 	page = find_lock_page(mapping, index);
 	if (!page) {
-		page = __page_cache_alloc(gfp_mask);
+		page = __page_cache_alloc(mapping, index, ~0, gfp_mask);
 		if (!page)
 			return NULL;
 		err = add_to_page_cache_lru(page, mapping, index, gfp_mask);
@@ -804,7 +834,7 @@ grab_cache_page_nowait(struct address_sp
 		page_cache_release(page);
 		return NULL;
 	}
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
+	page = __page_cache_alloc(mapping, index, __GFP_FS, 0);
 	if (page && add_to_page_cache_lru(page, mapping, index, GFP_KERNEL)) {
 		page_cache_release(page);
 		page = NULL;
@@ -1052,7 +1082,7 @@ no_cached_page:
 		 * Ok, it wasn't cached, so we need to create a new
 		 * page..
 		 */
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, index);
 		if (!page) {
 			desc->error = -ENOMEM;
 			goto out;
@@ -1318,7 +1348,7 @@ static int fastcall page_cache_read(stru
 	int ret;
 
 	do {
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, offset);
 		if (!page)
 			return -ENOMEM;
 
@@ -1566,7 +1596,7 @@ static struct page *__read_cache_page(st
 repeat:
 	page = find_get_page(mapping, index);
 	if (!page) {
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, index);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, GFP_KERNEL);
@@ -2058,7 +2088,7 @@ repeat:
 	if (likely(page))
 		return page;
 
-	page = page_cache_alloc(mapping);
+	page = page_cache_alloc(mapping, index);
 	if (!page)
 		return NULL;
 	status = add_to_page_cache_lru(page, mapping, index, GFP_KERNEL);
Index: Linux/include/linux/pagemap.h
===================================================================
--- Linux.orig/include/linux/pagemap.h	2007-06-25 15:00:39.000000000 -0400
+++ Linux/include/linux/pagemap.h	2007-06-25 15:02:17.000000000 -0400
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
--- Linux.orig/fs/splice.c	2007-06-25 15:00:39.000000000 -0400
+++ Linux/fs/splice.c	2007-06-25 15:02:17.000000000 -0400
@@ -318,7 +318,7 @@ __generic_file_splice_read(struct file *
 			/*
 			 * page didn't exist, allocate one.
 			 */
-			page = page_cache_alloc_cold(mapping);
+			page = page_cache_alloc_cold(mapping, index);
 			if (!page)
 				break;
 
Index: Linux/mm/readahead.c
===================================================================
--- Linux.orig/mm/readahead.c	2007-06-25 15:00:39.000000000 -0400
+++ Linux/mm/readahead.c	2007-06-25 15:02:17.000000000 -0400
@@ -160,7 +160,7 @@ __do_page_cache_readahead(struct address
 			continue;
 
 		read_unlock_irq(&mapping->tree_lock);
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, page_offset);
 		read_lock_irq(&mapping->tree_lock);
 		if (!page)
 			break;
Index: Linux/fs/ntfs/file.c
===================================================================
--- Linux.orig/fs/ntfs/file.c	2007-06-25 15:00:39.000000000 -0400
+++ Linux/fs/ntfs/file.c	2007-06-25 15:02:17.000000000 -0400
@@ -424,7 +424,7 @@ static inline int __ntfs_grab_cache_page
 		pages[nr] = find_lock_page(mapping, index);
 		if (!pages[nr]) {
 			if (!*cached_page) {
-				*cached_page = page_cache_alloc(mapping);
+				*cached_page = page_cache_alloc(mapping, index);
 				if (unlikely(!*cached_page)) {
 					err = -ENOMEM;
 					goto err_out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
