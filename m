Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 7543D6B00E8
	for <linux-mm@kvack.org>; Tue,  1 May 2012 04:43:21 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/5] mm + fs: provide refault distance to page cache instantiations
Date: Tue,  1 May 2012 10:41:52 +0200
Message-Id: <1335861713-4573-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

The page allocator needs to be given the non-residency information
stored in the page cache at the time the page is faulted back in.

Every site that does a find_or_create()-style allocation is converted
to pass this refault information to the page_cache_alloc() family of
functions, which in turn passes it down to the page allocator via
current->refault_distance.

XXX: Pages are charged to memory cgroups only when being added to the
page cache, and, in case of multi-page reads, allocation and addition
happen in separate batches.  To communicate the individual refault
distance to the memory controller, the refault distance is stored in
page->private between allocation and add_to_page_cache().  memcg does
not do anything with it yet, though, but it will use it when charging
requires reclaiming (hard limit reclaim).

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/btrfs/compression.c  |    8 +++--
 fs/cachefiles/rdwr.c    |   26 +++++++++-----
 fs/ceph/xattr.c         |    2 +-
 fs/logfs/readwrite.c    |    9 +++--
 fs/ntfs/file.c          |   11 ++++--
 fs/splice.c             |   10 +++--
 include/linux/pagemap.h |   28 ++++++++++-----
 include/linux/sched.h   |    1 +
 include/linux/swap.h    |    6 +++
 mm/filemap.c            |   84 ++++++++++++++++++++++++++++++++---------------
 mm/readahead.c          |    7 +++-
 net/ceph/messenger.c    |    2 +-
 net/ceph/pagelist.c     |    4 +-
 net/ceph/pagevec.c      |    2 +-
 14 files changed, 134 insertions(+), 66 deletions(-)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index a0594c9..dc57e09 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -464,6 +464,8 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 	end_index = (i_size_read(inode) - 1) >> PAGE_CACHE_SHIFT;
 
 	while (last_offset < compressed_end) {
+		unsigned long distance;
+
 		pg_index = last_offset >> PAGE_CACHE_SHIFT;
 
 		if (pg_index > end_index)
@@ -478,12 +480,12 @@ static noinline int add_ra_bio_pages(struct inode *inode,
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
+		set_page_private(page, distance);
 		if (add_to_page_cache_lru(page, mapping, pg_index,
 								GFP_NOFS)) {
 			page_cache_release(page);
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 0e3c092..359be1f 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -12,6 +12,7 @@
 #include <linux/mount.h>
 #include <linux/slab.h>
 #include <linux/file.h>
+#include <linux/swap.h>
 #include "internal.h"
 
 /*
@@ -253,16 +254,18 @@ static int cachefiles_read_backing_file_one(struct cachefiles_object *object,
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
-			newpage = page_cache_alloc_cold(bmapping);
+			newpage = page_cache_alloc_cold(bmapping, distance);
 			if (!newpage)
 				goto nomem_monitor;
 		}
-
+		set_page_private(newpage, distance);
 		ret = add_to_page_cache(newpage, bmapping,
 					netpage->index, GFP_KERNEL);
 		if (ret == 0)
@@ -495,16 +498,19 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
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
-				newpage = page_cache_alloc_cold(bmapping);
+				newpage = page_cache_alloc_cold(bmapping,
+								distance);
 				if (!newpage)
 					goto nomem;
 			}
-
+			set_page_private(newpage, distance);
 			ret = add_to_page_cache(newpage, bmapping,
 						netpage->index, GFP_KERNEL);
 			if (ret == 0)
diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
index a76f697..26e85d1 100644
--- a/fs/ceph/xattr.c
+++ b/fs/ceph/xattr.c
@@ -647,7 +647,7 @@ static int ceph_sync_setxattr(struct dentry *dentry, const char *name,
 			return -ENOMEM;
 		err = -ENOMEM;
 		for (i = 0; i < nr_pages; i++) {
-			pages[i] = __page_cache_alloc(GFP_NOFS);
+			pages[i] = __page_cache_alloc(GFP_NOFS, 0);
 			if (!pages[i]) {
 				nr_pages = i;
 				goto out;
diff --git a/fs/logfs/readwrite.c b/fs/logfs/readwrite.c
index 4153e65..b70fcfe 100644
--- a/fs/logfs/readwrite.c
+++ b/fs/logfs/readwrite.c
@@ -316,11 +316,14 @@ static struct page *logfs_get_write_page(struct inode *inode, u64 bix,
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
+		set_page_private(page, distance);
 		err = add_to_page_cache_lru(page, mapping, index, GFP_NOFS);
 		if (unlikely(err)) {
 			page_cache_release(page);
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index c587e2d..ccca902 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -412,15 +412,20 @@ static inline int __ntfs_grab_cache_pages(struct address_space *mapping,
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
 				}
 			}
+			set_page_private(*cached_page, distance);
 			err = add_to_page_cache_lru(*cached_page, mapping, index,
 					GFP_KERNEL);
 			if (unlikely(err)) {
diff --git a/fs/splice.c b/fs/splice.c
index 1ec0493..96cbad0 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -347,15 +347,17 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
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
+			set_page_private(page, distance);
 			error = add_to_page_cache_lru(page, mapping, index,
 						GFP_KERNEL);
 			if (unlikely(error)) {
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index c1abb88..7ddfc69 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -212,28 +212,38 @@ static inline void page_unfreeze_refs(struct page *page, int count)
 }
 
 #ifdef CONFIG_NUMA
-extern struct page *__page_cache_alloc(gfp_t gfp);
+extern struct page *__page_cache_alloc(gfp_t, unsigned long);
 #else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
+static inline struct page *__page_cache_alloc(gfp_t gfp,
+					      unsigned long refault_distance)
 {
-	return alloc_pages(gfp, 0);
+	struct page *page;
+
+	current->refault_distance = refault_distance;
+	page = alloc_pages(gfp, 0);
+	current->refault_distance = 0;
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
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 0657368..f1a984b 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1296,6 +1296,7 @@ struct task_struct {
 #endif
 
 	struct mm_struct *mm, *active_mm;
+	unsigned long refault_distance;
 #ifdef CONFIG_COMPAT_BRK
 	unsigned brk_randomized:1;
 #endif
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3e60228..03d327f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -204,6 +204,12 @@ struct swap_list_t {
 /* Swap 50% full? Release swapcache more aggressively.. */
 #define vm_swap_full() (nr_swap_pages*2 < total_swap_pages)
 
+/* linux/mm/workingset.c */
+static inline unsigned long workingset_refault_distance(struct page *page)
+{
+	return 0;
+}
+
 /* linux/mm/page_alloc.c */
 extern unsigned long totalram_pages;
 extern unsigned long totalreserve_pages;
diff --git a/mm/filemap.c b/mm/filemap.c
index 4ca12a3..288346a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -468,13 +468,19 @@ static int page_cache_insert(struct address_space *mapping, pgoff_t offset,
 int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		pgoff_t offset, gfp_t gfp_mask)
 {
+	unsigned long distance;
 	int error;
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageSwapBacked(page));
 
+	distance = page_private(page);
+	set_page_private(page, 0);
+
+	current->refault_distance = distance;
 	error = mem_cgroup_cache_charge(page, current->mm,
 					gfp_mask & GFP_RECLAIM_MASK);
+	current->refault_distance = 0;
 	if (error)
 		goto out;
 
@@ -518,19 +524,21 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc(gfp_t gfp, unsigned long refault_distance)
 {
 	int n;
 	struct page *page;
 
+	current->refault_distance = refault_distance;
 	if (cpuset_do_page_mem_spread()) {
 		get_mems_allowed();
 		n = cpuset_mem_spread_node();
 		page = alloc_pages_exact_node(n, gfp, 0);
 		put_mems_allowed();
-		return page;
-	}
-	return alloc_pages(gfp, 0);
+	} else
+		page = alloc_pages(gfp, 0);
+	current->refault_distance = 0;
+	return page;
 }
 EXPORT_SYMBOL(__page_cache_alloc);
 #endif
@@ -810,11 +818,14 @@ struct page *find_or_create_page(struct address_space *mapping,
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
+		set_page_private(page, distance);
 		/*
 		 * We want a regular kernel memory (not highmem or DMA etc)
 		 * allocation for the radix tree nodes, but we need to honour
@@ -1128,16 +1139,22 @@ EXPORT_SYMBOL(find_get_pages_tag);
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
+	set_page_private(page, distance);
+	if (add_to_page_cache_lru(page, mapping, index, GFP_NOFS)) {
 		page_cache_release(page);
 		page = NULL;
 	}
@@ -1199,6 +1216,7 @@ static void do_generic_file_read(struct file *filp, loff_t *ppos,
 	offset = *ppos & ~PAGE_CACHE_MASK;
 
 	for (;;) {
+		unsigned long distance;
 		struct page *page;
 		pgoff_t end_index;
 		loff_t isize;
@@ -1211,8 +1229,9 @@ find_page:
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
@@ -1370,11 +1389,13 @@ no_cached_page:
 		 * Ok, it wasn't cached, so we need to create a new
 		 * page..
 		 */
-		page = page_cache_alloc_cold(mapping);
+		distance = workingset_refault_distance(page);
+		page = page_cache_alloc_cold(mapping, distance);
 		if (!page) {
 			desc->error = -ENOMEM;
 			goto out;
 		}
+		set_page_private(page, distance);
 		error = add_to_page_cache_lru(page, mapping,
 						index, GFP_KERNEL);
 		if (error) {
@@ -1621,21 +1642,23 @@ SYSCALL_ALIAS(sys_readahead, SyS_readahead);
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
+		set_page_private(page, distance);
 		ret = add_to_page_cache_lru(page, mapping, offset, GFP_KERNEL);
 		if (ret == 0)
 			ret = mapping->a_ops->readpage(file, page);
@@ -1738,6 +1761,7 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 	struct file_ra_state *ra = &file->f_ra;
 	struct inode *inode = mapping->host;
 	pgoff_t offset = vmf->pgoff;
+	unsigned long distance;
 	struct page *page;
 	pgoff_t size;
 	int ret = 0;
@@ -1763,8 +1787,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
 retry_find:
-		page = find_get_page(mapping, offset);
-		if (!page)
+		page = __find_get_page(mapping, offset);
+		if (!page || radix_tree_exceptional_entry(page))
 			goto no_cached_page;
 	}
 
@@ -1807,7 +1831,8 @@ no_cached_page:
 	 * We're only likely to ever get here if MADV_RANDOM is in
 	 * effect.
 	 */
-	error = page_cache_read(file, offset);
+	distance = workingset_refault_distance(page);
+	error = page_cache_read(file, offset, distance);
 
 	/*
 	 * The page we want has now been added to the page cache.
@@ -1901,11 +1926,14 @@ static struct page *__read_cache_page(struct address_space *mapping,
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
+		set_page_private(page, distance);
 		err = add_to_page_cache_lru(page, mapping, index, gfp);
 		if (unlikely(err)) {
 			page_cache_release(page);
@@ -2432,18 +2460,20 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 	gfp_t gfp_mask;
 	struct page *page;
 	gfp_t gfp_notmask = 0;
+	unsigned long distance;
 
 	gfp_mask = mapping_gfp_mask(mapping) | __GFP_WRITE;
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
+	set_page_private(page, distance);
 	status = add_to_page_cache_lru(page, mapping, index,
 						GFP_KERNEL & ~gfp_notmask);
 	if (unlikely(status)) {
diff --git a/mm/readahead.c b/mm/readahead.c
index 43f9dd2..dc071cc 100644
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
@@ -170,6 +171,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 	 */
 	for (page_idx = 0; page_idx < nr_to_read; page_idx++) {
 		pgoff_t page_offset = offset + page_idx;
+		unsigned long distance;
 
 		if (page_offset > end_index)
 			break;
@@ -179,10 +181,11 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		rcu_read_unlock();
 		if (page && !radix_tree_exceptional_entry(page))
 			continue;
-
-		page = page_cache_alloc_readahead(mapping);
+		distance = workingset_refault_distance(page);
+		page = page_cache_alloc_readahead(mapping, distance);
 		if (!page)
 			break;
+		set_page_private(page, distance);
 		page->index = page_offset;
 		list_add(&page->lru, &page_pool);
 		if (page_idx == nr_to_read - lookahead_size)
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index ad5b708..b57933a 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -2218,7 +2218,7 @@ struct ceph_messenger *ceph_messenger_create(struct ceph_entity_addr *myaddr,
 
 	/* the zero page is needed if a request is "canceled" while the message
 	 * is being written over the socket */
-	msgr->zero_page = __page_cache_alloc(GFP_KERNEL | __GFP_ZERO);
+	msgr->zero_page = __page_cache_alloc(GFP_KERNEL | __GFP_ZERO, 0);
 	if (!msgr->zero_page) {
 		kfree(msgr);
 		return ERR_PTR(-ENOMEM);
diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
index 13cb409..ffc6289 100644
--- a/net/ceph/pagelist.c
+++ b/net/ceph/pagelist.c
@@ -33,7 +33,7 @@ static int ceph_pagelist_addpage(struct ceph_pagelist *pl)
 	struct page *page;
 
 	if (!pl->num_pages_free) {
-		page = __page_cache_alloc(GFP_NOFS);
+		page = __page_cache_alloc(GFP_NOFS, 0);
 	} else {
 		page = list_first_entry(&pl->free_list, struct page, lru);
 		list_del(&page->lru);
@@ -85,7 +85,7 @@ int ceph_pagelist_reserve(struct ceph_pagelist *pl, size_t space)
 	space = (space + PAGE_SIZE - 1) >> PAGE_SHIFT;   /* conv to num pages */
 
 	while (space > pl->num_pages_free) {
-		struct page *page = __page_cache_alloc(GFP_NOFS);
+		struct page *page = __page_cache_alloc(GFP_NOFS, 0);
 		if (!page)
 			return -ENOMEM;
 		list_add_tail(&page->lru, &pl->free_list);
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index cd9c21d..4bc4ffd 100644
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
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
