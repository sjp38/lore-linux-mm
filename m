Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 6C2896B003A
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:04:50 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 07/10] mm + fs: provide refault distance to page cache allocations
Date: Thu, 30 May 2013 14:04:03 -0400
Message-Id: <1369937046-27666-8-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

In order to make informed placement and reclaim decisions, the page
allocator requires the eviction information of refaulting pages.

Every site that does a find_or_create()-style allocation is converted
to pass this value to the page_cache_alloc() family of functions,
which in turn pass it down to the page allocator.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/btrfs/compression.c  |  7 +++--
 fs/cachefiles/rdwr.c    | 25 ++++++++++-------
 fs/ceph/xattr.c         |  2 +-
 fs/logfs/readwrite.c    |  9 ++++--
 fs/ntfs/file.c          | 10 +++++--
 fs/splice.c             |  9 +++---
 include/linux/gfp.h     | 18 +++++++-----
 include/linux/pagemap.h | 26 +++++++++++------
 include/linux/swap.h    |  6 ++++
 mm/filemap.c            | 74 ++++++++++++++++++++++++++++++-------------------
 mm/mempolicy.c          | 17 +++++++-----
 mm/page_alloc.c         | 51 +++++++++++++++++++---------------
 mm/readahead.c          |  6 ++--
 net/ceph/pagelist.c     |  4 +--
 net/ceph/pagevec.c      |  2 +-
 15 files changed, 163 insertions(+), 103 deletions(-)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 4a80f6b..9c83b84 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -464,6 +464,8 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 	end_index = (i_size_read(inode) - 1) >> PAGE_CACHE_SHIFT;
 
 	while (last_offset < compressed_end) {
+		unsigned long distance;
+
 		pg_index = last_offset >> PAGE_CACHE_SHIFT;
 
 		if (pg_index > end_index)
@@ -478,12 +480,11 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 				break;
 			goto next;
 		}
-
+		distance = workingset_refault_distance(page);
 		page = __page_cache_alloc(mapping_gfp_mask(mapping) &
-								~__GFP_FS);
+					  ~__GFP_FS, distance);
 		if (!page)
 			break;
-
 		if (add_to_page_cache_lru(page, mapping, pg_index,
 								GFP_NOFS)) {
 			page_cache_release(page);
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 4809922..3d4a75a 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -12,6 +12,7 @@
 #include <linux/mount.h>
 #include <linux/slab.h>
 #include <linux/file.h>
+#include <linux/swap.h>
 #include "internal.h"
 
 /*
@@ -256,17 +257,19 @@ static int cachefiles_read_backing_file_one(struct cachefiles_object *object,
 	newpage = NULL;
 
 	for (;;) {
-		backpage = find_get_page(bmapping, netpage->index);
-		if (backpage)
-			goto backing_page_already_present;
+		unsigned long distance;
 
+		backpage = __find_get_page(bmapping, netpage->index);
+		if (backpage && !radix_tree_exceptional_entry(backpage))
+			goto backing_page_already_present;
+		distance = workingset_refault_distance(backpage);
 		if (!newpage) {
 			newpage = __page_cache_alloc(cachefiles_gfp |
-						     __GFP_COLD);
+						     __GFP_COLD,
+						     distance);
 			if (!newpage)
 				goto nomem_monitor;
 		}
-
 		ret = add_to_page_cache(newpage, bmapping,
 					netpage->index, cachefiles_gfp);
 		if (ret == 0)
@@ -507,17 +510,19 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 		}
 
 		for (;;) {
-			backpage = find_get_page(bmapping, netpage->index);
-			if (backpage)
-				goto backing_page_already_present;
+			unsigned long distance;
 
+			backpage = __find_get_page(bmapping, netpage->index);
+			if (backpage && !radix_tree_exceptional_entry(backpage))
+				goto backing_page_already_present;
+			distance = workingset_refault_distance(backpage);
 			if (!newpage) {
 				newpage = __page_cache_alloc(cachefiles_gfp |
-							     __GFP_COLD);
+							     __GFP_COLD,
+							     distance);
 				if (!newpage)
 					goto nomem;
 			}
-
 			ret = add_to_page_cache(newpage, bmapping,
 						netpage->index, cachefiles_gfp);
 			if (ret == 0)
diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
index 9b6b2b6..d52c9f0 100644
--- a/fs/ceph/xattr.c
+++ b/fs/ceph/xattr.c
@@ -815,7 +815,7 @@ static int ceph_sync_setxattr(struct dentry *dentry, const char *name,
 			return -ENOMEM;
 		err = -ENOMEM;
 		for (i = 0; i < nr_pages; i++) {
-			pages[i] = __page_cache_alloc(GFP_NOFS);
+			pages[i] = __page_cache_alloc(GFP_NOFS, 0);
 			if (!pages[i]) {
 				nr_pages = i;
 				goto out;
diff --git a/fs/logfs/readwrite.c b/fs/logfs/readwrite.c
index 9a59cba..0c4535d 100644
--- a/fs/logfs/readwrite.c
+++ b/fs/logfs/readwrite.c
@@ -19,6 +19,7 @@
 #include "logfs.h"
 #include <linux/sched.h>
 #include <linux/slab.h>
+#include <linux/swap.h>
 
 static u64 adjust_bix(u64 bix, level_t level)
 {
@@ -316,9 +317,11 @@ static struct page *logfs_get_write_page(struct inode *inode, u64 bix,
 	int err;
 
 repeat:
-	page = find_get_page(mapping, index);
-	if (!page) {
-		page = __page_cache_alloc(GFP_NOFS);
+	page = __find_get_page(mapping, index);
+	if (!page || radix_tree_exceptional_entry(page)) {
+		unsigned long distance = workingset_refault_distance(page);
+
+		page = __page_cache_alloc(GFP_NOFS, distance);
 		if (!page)
 			return NULL;
 		err = add_to_page_cache_lru(page, mapping, index, GFP_NOFS);
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 5b2d4f0..a8a4e07 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -412,10 +412,14 @@ static inline int __ntfs_grab_cache_pages(struct address_space *mapping,
 	BUG_ON(!nr_pages);
 	err = nr = 0;
 	do {
-		pages[nr] = find_lock_page(mapping, index);
-		if (!pages[nr]) {
+		pages[nr] = __find_lock_page(mapping, index);
+		if (!pages[nr] || radix_tree_exceptional_entry(pages[nr])) {
+			unsigned long distance;
+
+			distance = workingset_refault_distance(pages[nr]);
 			if (!*cached_page) {
-				*cached_page = page_cache_alloc(mapping);
+				*cached_page = page_cache_alloc(mapping,
+								distance);
 				if (unlikely(!*cached_page)) {
 					err = -ENOMEM;
 					goto err_out;
diff --git a/fs/splice.c b/fs/splice.c
index 29e394e..e60ddfc 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -352,15 +352,16 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 		 * Page could be there, find_get_pages_contig() breaks on
 		 * the first hole.
 		 */
-		page = find_get_page(mapping, index);
-		if (!page) {
+		page = __find_get_page(mapping, index);
+		if (!page || radix_tree_exceptional_entry(page)) {
+			unsigned long distance;
 			/*
 			 * page didn't exist, allocate one.
 			 */
-			page = page_cache_alloc_cold(mapping);
+			distance = workingset_refault_distance(page);
+			page = page_cache_alloc_cold(mapping, distance);
 			if (!page)
 				break;
-
 			error = add_to_page_cache_lru(page, mapping, index,
 						GFP_KERNEL);
 			if (unlikely(error)) {
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0f615eb..caf8d34 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -298,13 +298,16 @@ static inline void arch_alloc_page(struct page *page, int order) { }
 
 struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
-		       struct zonelist *zonelist, nodemask_t *nodemask);
+		       struct zonelist *zonelist, nodemask_t *nodemask,
+		       unsigned long refault_distance);
 
 static inline struct page *
 __alloc_pages(gfp_t gfp_mask, unsigned int order,
-		struct zonelist *zonelist)
+	      struct zonelist *zonelist, unsigned long refault_distance)
 {
-	return __alloc_pages_nodemask(gfp_mask, order, zonelist, NULL);
+	return __alloc_pages_nodemask(gfp_mask, order,
+				      zonelist, NULL,
+				      refault_distance);
 }
 
 static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
@@ -314,7 +317,7 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	if (nid < 0)
 		nid = numa_node_id();
 
-	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
+	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask), 0);
 }
 
 static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
@@ -322,16 +325,17 @@ static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
 {
 	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid));
 
-	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
+	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask), 0);
 }
 
 #ifdef CONFIG_NUMA
-extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order);
+extern struct page *alloc_pages_current(gfp_t gfp_mask, unsigned order,
+					unsigned long refault_distance);
 
 static inline struct page *
 alloc_pages(gfp_t gfp_mask, unsigned int order)
 {
-	return alloc_pages_current(gfp_mask, order);
+	return alloc_pages_current(gfp_mask, order, 0);
 }
 extern struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
 			struct vm_area_struct *vma, unsigned long addr,
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 258eb38..d758243 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -228,28 +228,36 @@ static inline void page_unfreeze_refs(struct page *page, int count)
 }
 
 #ifdef CONFIG_NUMA
-extern struct page *__page_cache_alloc(gfp_t gfp);
+extern struct page *__page_cache_alloc(gfp_t gfp,
+				       unsigned long refault_distance);
 #else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
+static inline struct page *__page_cache_alloc(gfp_t gfp,
+					      unsigned long refault_distance)
 {
-	return alloc_pages(gfp, 0);
+	return __alloc_pages(gfp, 0, node_zonelist(numa_node_id(), gfp),
+			     refault_distance);
 }
 #endif
 
-static inline struct page *page_cache_alloc(struct address_space *x)
+static inline struct page *page_cache_alloc(struct address_space *x,
+					    unsigned long refault_distance)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x));
+	return __page_cache_alloc(mapping_gfp_mask(x), refault_distance);
 }
 
-static inline struct page *page_cache_alloc_cold(struct address_space *x)
+static inline struct page *page_cache_alloc_cold(struct address_space *x,
+						 unsigned long refault_distance)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
+	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD,
+				  refault_distance);
 }
 
-static inline struct page *page_cache_alloc_readahead(struct address_space *x)
+static inline struct page *page_cache_alloc_readahead(struct address_space *x,
+						      unsigned long refault_distance)
 {
 	return __page_cache_alloc(mapping_gfp_mask(x) |
-				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN);
+				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN,
+				  refault_distance);
 }
 
 typedef int filler_t(void *, struct page *);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 2818a12..ffa323a 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -221,6 +221,12 @@ struct swap_list_t {
 	int next;	/* swapfile to be used next */
 };
 
+/* linux/mm/workingset.c */
+static inline unsigned long workingset_refault_distance(struct page *page)
+{
+	return ~0UL;
+}
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
diff --git a/mm/filemap.c b/mm/filemap.c
index dd0835e..10f8a62 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -518,7 +518,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc(gfp_t gfp, unsigned long refault_distance)
 {
 	int n;
 	struct page *page;
@@ -528,12 +528,12 @@ struct page *__page_cache_alloc(gfp_t gfp)
 		do {
 			cpuset_mems_cookie = get_mems_allowed();
 			n = cpuset_mem_spread_node();
-			page = alloc_pages_exact_node(n, gfp, 0);
+			page = __alloc_pages(gfp, 0, node_zonelist(n, gfp),
+					     refault_distance);
 		} while (!put_mems_allowed(cpuset_mems_cookie) && !page);
-
-		return page;
-	}
-	return alloc_pages(gfp, 0);
+	} else
+		page = alloc_pages_current(gfp, 0, refault_distance);
+	return page;
 }
 EXPORT_SYMBOL(__page_cache_alloc);
 #endif
@@ -894,9 +894,11 @@ struct page *find_or_create_page(struct address_space *mapping,
 	struct page *page;
 	int err;
 repeat:
-	page = find_lock_page(mapping, index);
-	if (!page) {
-		page = __page_cache_alloc(gfp_mask);
+	page = __find_lock_page(mapping, index);
+	if (!page || radix_tree_exceptional_entry(page)) {
+		unsigned long distance = workingset_refault_distance(page);
+
+		page = __page_cache_alloc(gfp_mask, distance);
 		if (!page)
 			return NULL;
 		/*
@@ -1199,16 +1201,21 @@ EXPORT_SYMBOL(find_get_pages_tag);
 struct page *
 grab_cache_page_nowait(struct address_space *mapping, pgoff_t index)
 {
-	struct page *page = find_get_page(mapping, index);
+	struct page *page = __find_get_page(mapping, index);
+	unsigned long distance;
 
-	if (page) {
+	if (page && !radix_tree_exceptional_entry(page)) {
 		if (trylock_page(page))
 			return page;
 		page_cache_release(page);
 		return NULL;
 	}
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
-	if (page && add_to_page_cache_lru(page, mapping, index, GFP_NOFS)) {
+	distance = workingset_refault_distance(page);
+	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS,
+				  distance);
+	if (!page)
+		return NULL;
+	if (add_to_page_cache_lru(page, mapping, index, GFP_NOFS)) {
 		page_cache_release(page);
 		page = NULL;
 	}
@@ -1270,6 +1277,7 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
 	offset = *ppos & ~PAGE_CACHE_MASK;
 
 	for (;;) {
+		unsigned long distance;
 		struct page *page;
 		pgoff_t end_index;
 		loff_t isize;
@@ -1282,8 +1290,9 @@ find_page:
 			page_cache_sync_readahead(mapping,
 					ra, filp,
 					index, last_index - index);
-			page = find_get_page(mapping, index);
-			if (unlikely(page == NULL))
+			page = __find_get_page(mapping, index);
+			if (unlikely(!page ||
+				     radix_tree_exceptional_entry(page)))
 				goto no_cached_page;
 		}
 		if (PageReadahead(page)) {
@@ -1441,7 +1450,8 @@ no_cached_page:
 		 * Ok, it wasn't cached, so we need to create a new
 		 * page..
 		 */
-		page = page_cache_alloc_cold(mapping);
+		distance = workingset_refault_distance(page);
+		page = page_cache_alloc_cold(mapping, distance);
 		if (!page) {
 			desc->error = -ENOMEM;
 			goto out;
@@ -1650,21 +1660,22 @@ EXPORT_SYMBOL(generic_file_aio_read);
  * page_cache_read - adds requested page to the page cache if not already there
  * @file:	file to read
  * @offset:	page index
+ * @distance:	refault distance
  *
  * This adds the requested page to the page cache if it isn't already there,
  * and schedules an I/O to read in its contents from disk.
  */
-static int page_cache_read(struct file *file, pgoff_t offset)
+static int page_cache_read(struct file *file, pgoff_t offset,
+			   unsigned long distance)
 {
 	struct address_space *mapping = file->f_mapping;
 	struct page *page; 
 	int ret;
 
 	do {
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, distance);
 		if (!page)
 			return -ENOMEM;
-
 		ret = add_to_page_cache_lru(page, mapping, offset, GFP_KERNEL);
 		if (ret == 0)
 			ret = mapping->a_ops->readpage(file, page);
@@ -1767,6 +1778,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
 	pgoff_t offset = vmf->pgoff;
+	unsigned long distance;
 	struct page *page;
 	pgoff_t size;
 	int ret = 0;
@@ -1792,8 +1804,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
 retry_find:
-		page = find_get_page(mapping, offset);
-		if (!page)
+		page = __find_get_page(mapping, offset);
+		if (!page || radix_tree_exceptional_entry(page))
 			goto no_cached_page;
 	}
 
@@ -1836,7 +1848,8 @@ no_cached_page:
 	 * We're only likely to ever get here if MADV_RANDOM is in
 	 * effect.
 	 */
-	error = page_cache_read(file, offset);
+	distance = workingset_refault_distance(page);
+	error = page_cache_read(file, offset, distance);
 
 	/*
 	 * The page we want has now been added to the page cache.
@@ -1958,9 +1971,11 @@ static struct page *__read_cache_page(struct address_space *mapping,
 	struct page *page;
 	int err;
 repeat:
-	page = find_get_page(mapping, index);
-	if (!page) {
-		page = __page_cache_alloc(gfp | __GFP_COLD);
+	page = __find_get_page(mapping, index);
+	if (!page || radix_tree_exceptional_entry(page)) {
+		unsigned long distance = workingset_refault_distance(page);
+
+		page = __page_cache_alloc(gfp | __GFP_COLD, distance);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, gfp);
@@ -2424,6 +2439,7 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 	gfp_t gfp_mask;
 	struct page *page;
 	gfp_t gfp_notmask = 0;
+	unsigned long distance;
 
 	gfp_mask = mapping_gfp_mask(mapping);
 	if (mapping_cap_account_dirty(mapping))
@@ -2431,11 +2447,11 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 	if (flags & AOP_FLAG_NOFS)
 		gfp_notmask = __GFP_FS;
 repeat:
-	page = find_lock_page(mapping, index);
-	if (page)
+	page = __find_lock_page(mapping, index);
+	if (page && !radix_tree_exceptional_entry(page))
 		goto found;
-
-	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
+	distance = workingset_refault_distance(page);
+	page = __page_cache_alloc(gfp_mask & ~gfp_notmask, distance);
 	if (!page)
 		return NULL;
 	status = add_to_page_cache_lru(page, mapping, index,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7431001..69f57b8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1944,13 +1944,14 @@ out:
 /* Allocate a page in interleaved policy.
    Own path because it needs to do special accounting. */
 static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
-					unsigned nid)
+					  unsigned nid,
+					  unsigned long refault_distance)
 {
 	struct zonelist *zl;
 	struct page *page;
 
 	zl = node_zonelist(nid, gfp);
-	page = __alloc_pages(gfp, order, zl);
+	page = __alloc_pages(gfp, order, zl, refault_distance);
 	if (page && page_zone(page) == zonelist_zone(&zl->_zonerefs[0]))
 		inc_zone_page_state(page, NUMA_INTERLEAVE_HIT);
 	return page;
@@ -1996,7 +1997,7 @@ retry_cpuset:
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
 		mpol_cond_put(pol);
-		page = alloc_page_interleave(gfp, order, nid);
+		page = alloc_page_interleave(gfp, order, nid, 0);
 		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 			goto retry_cpuset;
 
@@ -2004,7 +2005,7 @@ retry_cpuset:
 	}
 	page = __alloc_pages_nodemask(gfp, order,
 				      policy_zonelist(gfp, pol, node),
-				      policy_nodemask(gfp, pol));
+				      policy_nodemask(gfp, pol), 0);
 	if (unlikely(mpol_needs_cond_ref(pol)))
 		__mpol_put(pol);
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
@@ -2031,7 +2032,8 @@ retry_cpuset:
  *	1) it's ok to take cpuset_sem (can WAIT), and
  *	2) allocating for current task (not interrupt).
  */
-struct page *alloc_pages_current(gfp_t gfp, unsigned order)
+struct page *alloc_pages_current(gfp_t gfp, unsigned order,
+				 unsigned long refault_distance)
 {
 	struct mempolicy *pol = get_task_policy(current);
 	struct page *page;
@@ -2048,11 +2050,12 @@ retry_cpuset:
 	 * nor system default_policy
 	 */
 	if (pol->mode == MPOL_INTERLEAVE)
-		page = alloc_page_interleave(gfp, order, interleave_nodes(pol));
+		page = alloc_page_interleave(gfp, order, interleave_nodes(pol),
+					     refault_distance);
 	else
 		page = __alloc_pages_nodemask(gfp, order,
 				policy_zonelist(gfp, pol, numa_node_id()),
-				policy_nodemask(gfp, pol));
+				policy_nodemask(gfp, pol), refault_distance);
 
 	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
 		goto retry_cpuset;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a64d786..92b4c01 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1842,7 +1842,8 @@ static inline void init_zone_allows_reclaim(int nid)
 static struct page *
 get_page_from_freelist(gfp_t gfp_mask, nodemask_t *nodemask, unsigned int order,
 		struct zonelist *zonelist, int high_zoneidx, int alloc_flags,
-		struct zone *preferred_zone, int migratetype)
+		struct zone *preferred_zone, int migratetype,
+		unsigned long refault_distance)
 {
 	struct zoneref *z;
 	struct page *page = NULL;
@@ -2105,7 +2106,7 @@ static inline struct page *
 __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int migratetype, unsigned long refault_distance)
 {
 	struct page *page;
 
@@ -2123,7 +2124,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask,
 		order, zonelist, high_zoneidx,
 		ALLOC_WMARK_HIGH|ALLOC_CPUSET,
-		preferred_zone, migratetype);
+		preferred_zone, migratetype, refault_distance);
 	if (page)
 		goto out;
 
@@ -2158,7 +2159,7 @@ static struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, bool sync_migration,
+	int migratetype, unsigned long refault_distance, bool sync_migration,
 	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
@@ -2186,7 +2187,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		page = get_page_from_freelist(gfp_mask, nodemask,
 				order, zonelist, high_zoneidx,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
-				preferred_zone, migratetype);
+				preferred_zone, migratetype, refault_distance);
 		if (page) {
 			preferred_zone->compact_blockskip_flush = false;
 			preferred_zone->compact_considered = 0;
@@ -2221,7 +2222,7 @@ static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, bool sync_migration,
+	int migratetype, unsigned long refault_distance, bool sync_migration,
 	bool *contended_compaction, bool *deferred_compaction,
 	unsigned long *did_some_progress)
 {
@@ -2262,7 +2263,8 @@ static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
-	int migratetype, unsigned long *did_some_progress)
+	int migratetype, unsigned long refault_distance,
+	unsigned long *did_some_progress)
 {
 	struct page *page = NULL;
 	bool drained = false;
@@ -2278,9 +2280,9 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 
 retry:
 	page = get_page_from_freelist(gfp_mask, nodemask, order,
-					zonelist, high_zoneidx,
-					alloc_flags & ~ALLOC_NO_WATERMARKS,
-					preferred_zone, migratetype);
+				zonelist, high_zoneidx,
+				alloc_flags & ~ALLOC_NO_WATERMARKS,
+				preferred_zone, migratetype, refault_distance);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -2303,14 +2305,14 @@ static inline struct page *
 __alloc_pages_high_priority(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int migratetype, unsigned long refault_distance)
 {
 	struct page *page;
 
 	do {
 		page = get_page_from_freelist(gfp_mask, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, refault_distance);
 
 		if (!page && gfp_mask & __GFP_NOFAIL)
 			wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
@@ -2391,7 +2393,7 @@ static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, struct zone *preferred_zone,
-	int migratetype)
+	int migratetype, unsigned long refault_distance)
 {
 	const gfp_t wait = gfp_mask & __GFP_WAIT;
 	struct page *page = NULL;
@@ -2449,7 +2451,7 @@ rebalance:
 	/* This is the last chance, in general, before the goto nopage. */
 	page = get_page_from_freelist(gfp_mask, nodemask, order, zonelist,
 			high_zoneidx, alloc_flags & ~ALLOC_NO_WATERMARKS,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, refault_distance);
 	if (page)
 		goto got_pg;
 
@@ -2464,7 +2466,8 @@ rebalance:
 
 		page = __alloc_pages_high_priority(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
-				preferred_zone, migratetype);
+				preferred_zone, migratetype,
+				refault_distance);
 		if (page) {
 			goto got_pg;
 		}
@@ -2490,7 +2493,8 @@ rebalance:
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, sync_migration,
+					migratetype, refault_distance,
+					sync_migration,
 					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
@@ -2513,7 +2517,8 @@ rebalance:
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, &did_some_progress);
+					migratetype, refault_distance,
+					&did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -2532,7 +2537,7 @@ rebalance:
 			page = __alloc_pages_may_oom(gfp_mask, order,
 					zonelist, high_zoneidx,
 					nodemask, preferred_zone,
-					migratetype);
+					migratetype, refault_distance);
 			if (page)
 				goto got_pg;
 
@@ -2575,7 +2580,8 @@ rebalance:
 					zonelist, high_zoneidx,
 					nodemask,
 					alloc_flags, preferred_zone,
-					migratetype, sync_migration,
+					migratetype, refault_distance,
+					sync_migration,
 					&contended_compaction,
 					&deferred_compaction,
 					&did_some_progress);
@@ -2598,7 +2604,8 @@ got_pg:
  */
 struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
-			struct zonelist *zonelist, nodemask_t *nodemask)
+		       struct zonelist *zonelist, nodemask_t *nodemask,
+		       unsigned long refault_distance)
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	struct zone *preferred_zone;
@@ -2649,7 +2656,7 @@ retry_cpuset:
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, alloc_flags,
-			preferred_zone, migratetype);
+			preferred_zone, migratetype, refault_distance);
 	if (unlikely(!page)) {
 		/*
 		 * Runtime PM, block IO and its error handling path
@@ -2659,7 +2666,7 @@ retry_cpuset:
 		gfp_mask = memalloc_noio_flags(gfp_mask);
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
-				preferred_zone, migratetype);
+				preferred_zone, migratetype, refault_distance);
 	}
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
diff --git a/mm/readahead.c b/mm/readahead.c
index 29efd45..1ff6104 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -11,6 +11,7 @@
 #include <linux/fs.h>
 #include <linux/gfp.h>
 #include <linux/mm.h>
+#include <linux/swap.h>
 #include <linux/export.h>
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
@@ -172,6 +173,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	 */
 	for (page_idx = 0; page_idx < nr_to_read; page_idx++) {
 		pgoff_t page_offset = offset + page_idx;
+		unsigned long distance;
 
 		if (page_offset > end_index)
 			break;
@@ -181,8 +183,8 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		rcu_read_unlock();
 		if (page && !radix_tree_exceptional_entry(page))
 			continue;
-
-		page = page_cache_alloc_readahead(mapping);
+		distance = workingset_refault_distance(page);
+		page = page_cache_alloc_readahead(mapping, distance);
 		if (!page)
 			break;
 		page->index = page_offset;
diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
index 92866be..fabdc16 100644
--- a/net/ceph/pagelist.c
+++ b/net/ceph/pagelist.c
@@ -32,7 +32,7 @@ static int ceph_pagelist_addpage(struct ceph_pagelist *pl)
 	struct page *page;
 
 	if (!pl->num_pages_free) {
-		page = __page_cache_alloc(GFP_NOFS);
+		page = __page_cache_alloc(GFP_NOFS, 0);
 	} else {
 		page = list_first_entry(&pl->free_list, struct page, lru);
 		list_del(&page->lru);
@@ -83,7 +83,7 @@ int ceph_pagelist_reserve(struct ceph_pagelist *pl, size_t space)
 	space = (space + PAGE_SIZE - 1) >> PAGE_SHIFT;   /* conv to num pages */
 
 	while (space > pl->num_pages_free) {
-		struct page *page = __page_cache_alloc(GFP_NOFS);
+		struct page *page = __page_cache_alloc(GFP_NOFS, 0);
 		if (!page)
 			return -ENOMEM;
 		list_add_tail(&page->lru, &pl->free_list);
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 815a224..b1151f4 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -79,7 +79,7 @@ struct page **ceph_alloc_page_vector(int num_pages, gfp_t flags)
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 	for (i = 0; i < num_pages; i++) {
-		pages[i] = __page_cache_alloc(flags);
+		pages[i] = __page_cache_alloc(flags, 0);
 		if (pages[i] == NULL) {
 			ceph_release_page_vector(pages, i);
 			return ERR_PTR(-ENOMEM);
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
