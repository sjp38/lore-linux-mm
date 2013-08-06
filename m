Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 2F68E6B003B
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 18:23:33 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 6/9] mm + fs: provide shadow pages to page cache allocations
Date: Tue,  6 Aug 2013 18:22:55 -0400
Message-Id: <1375827778-12357-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375827778-12357-1-git-send-email-hannes@cmpxchg.org>
References: <1375827778-12357-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman@kvack.org, "Gushchin <klamm"@yandex-team.ru, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

In order to make informed placement and reclaim decisions, the page
cache allocation requires the shadow information of refaulting pages.

Every site that does a find_or_create()-style page cache allocation is
converted to pass the shadow page found in the faulting slot of the
radix tree to page_cache_alloc(), where it can be used in subsequent
patches to influence reclaim behavior.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 drivers/staging/lustre/lustre/llite/dir.c |  2 +-
 fs/btrfs/compression.c                    |  2 +-
 fs/cachefiles/rdwr.c                      | 13 +++++----
 fs/ceph/xattr.c                           |  2 +-
 fs/logfs/readwrite.c                      |  6 ++--
 fs/ntfs/file.c                            |  7 +++--
 fs/splice.c                               |  6 ++--
 include/linux/pagemap.h                   | 20 ++++++++------
 mm/filemap.c                              | 46 +++++++++++++++++--------------
 mm/readahead.c                            |  2 +-
 net/ceph/pagelist.c                       |  4 +--
 net/ceph/pagevec.c                        |  2 +-
 12 files changed, 61 insertions(+), 51 deletions(-)

diff --git a/drivers/staging/lustre/lustre/llite/dir.c b/drivers/staging/lustre/lustre/llite/dir.c
index 2ca8c45..ac63e4d 100644
--- a/drivers/staging/lustre/lustre/llite/dir.c
+++ b/drivers/staging/lustre/lustre/llite/dir.c
@@ -172,7 +172,7 @@ static int ll_dir_filler(void *_hash, struct page *page0)
 		max_pages = 1;
 	}
 	for (npages = 1; npages < max_pages; npages++) {
-		page = page_cache_alloc_cold(inode->i_mapping);
+		page = page_cache_alloc_cold(inode->i_mapping, NULL);
 		if (!page)
 			break;
 		page_pool[npages] = page;
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 5ce2c0f..f23bb17 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -483,7 +483,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		}
 
 		page = __page_cache_alloc(mapping_gfp_mask(mapping) &
-								~__GFP_FS);
+					  ~__GFP_FS, page);
 		if (!page)
 			break;
 
diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index ebaff36..1b34a42 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -254,13 +254,13 @@ static int cachefiles_read_backing_file_one(struct cachefiles_object *object,
 	newpage = NULL;
 
 	for (;;) {
-		backpage = find_get_page(bmapping, netpage->index);
-		if (backpage)
+		backpage = __find_get_page(bmapping, netpage->index);
+		if (backpage && !radix_tree_exceptional_entry(backpage))
 			goto backing_page_already_present;
 
 		if (!newpage) {
 			newpage = __page_cache_alloc(cachefiles_gfp |
-						     __GFP_COLD);
+						     __GFP_COLD, backpage);
 			if (!newpage)
 				goto nomem_monitor;
 		}
@@ -499,13 +499,14 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 		}
 
 		for (;;) {
-			backpage = find_get_page(bmapping, netpage->index);
-			if (backpage)
+			backpage = __find_get_page(bmapping, netpage->index);
+			if (backpage && !radix_tree_exceptional_entry(backpage))
 				goto backing_page_already_present;
 
 			if (!newpage) {
 				newpage = __page_cache_alloc(cachefiles_gfp |
-							     __GFP_COLD);
+							     __GFP_COLD,
+							     backpage);
 				if (!newpage)
 					goto nomem;
 			}
diff --git a/fs/ceph/xattr.c b/fs/ceph/xattr.c
index be661d8..a5d2b86 100644
--- a/fs/ceph/xattr.c
+++ b/fs/ceph/xattr.c
@@ -816,7 +816,7 @@ static int ceph_sync_setxattr(struct dentry *dentry, const char *name,
 			return -ENOMEM;
 		err = -ENOMEM;
 		for (i = 0; i < nr_pages; i++) {
-			pages[i] = __page_cache_alloc(GFP_NOFS);
+			pages[i] = __page_cache_alloc(GFP_NOFS, NULL);
 			if (!pages[i]) {
 				nr_pages = i;
 				goto out;
diff --git a/fs/logfs/readwrite.c b/fs/logfs/readwrite.c
index 9a59cba..67c669a 100644
--- a/fs/logfs/readwrite.c
+++ b/fs/logfs/readwrite.c
@@ -316,9 +316,9 @@ static struct page *logfs_get_write_page(struct inode *inode, u64 bix,
 	int err;
 
 repeat:
-	page = find_get_page(mapping, index);
-	if (!page) {
-		page = __page_cache_alloc(GFP_NOFS);
+	page = __find_get_page(mapping, index);
+	if (!page || radix_tree_exceptional_entry(page)) {
+		page = __page_cache_alloc(GFP_NOFS, page);
 		if (!page)
 			return NULL;
 		err = add_to_page_cache_lru(page, mapping, index, GFP_NOFS);
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index c5670b8..7aee2d1 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -413,10 +413,11 @@ static inline int __ntfs_grab_cache_pages(struct address_space *mapping,
 	BUG_ON(!nr_pages);
 	err = nr = 0;
 	do {
-		pages[nr] = find_lock_page(mapping, index);
-		if (!pages[nr]) {
+		pages[nr] = __find_lock_page(mapping, index);
+		if (!pages[nr] || radix_tree_exceptional_entry(pages[nr])) {
 			if (!*cached_page) {
-				*cached_page = page_cache_alloc(mapping);
+				*cached_page = page_cache_alloc(mapping,
+								pages[nr]);
 				if (unlikely(!*cached_page)) {
 					err = -ENOMEM;
 					goto err_out;
diff --git a/fs/splice.c b/fs/splice.c
index 3b7ee65..edc54ae 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -353,12 +353,12 @@ __generic_file_splice_read(struct file *in, loff_t *ppos,
 		 * Page could be there, find_get_pages_contig() breaks on
 		 * the first hole.
 		 */
-		page = find_get_page(mapping, index);
-		if (!page) {
+		page = __find_get_page(mapping, index);
+		if (!page || radix_tree_exceptional_entry(page)) {
 			/*
 			 * page didn't exist, allocate one.
 			 */
-			page = page_cache_alloc_cold(mapping);
+			page = page_cache_alloc_cold(mapping, page);
 			if (!page)
 				break;
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index db3a78b..4b24236 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -228,28 +228,32 @@ static inline void page_unfreeze_refs(struct page *page, int count)
 }
 
 #ifdef CONFIG_NUMA
-extern struct page *__page_cache_alloc(gfp_t gfp);
+extern struct page *__page_cache_alloc(gfp_t gfp, struct page *shadow);
 #else
-static inline struct page *__page_cache_alloc(gfp_t gfp)
+static inline struct page *__page_cache_alloc(gfp_t gfp, struct page *shadow)
 {
 	return alloc_pages(gfp, 0);
 }
 #endif
 
-static inline struct page *page_cache_alloc(struct address_space *x)
+static inline struct page *page_cache_alloc(struct address_space *x,
+					    struct page *shadow)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x));
+	return __page_cache_alloc(mapping_gfp_mask(x), shadow);
 }
 
-static inline struct page *page_cache_alloc_cold(struct address_space *x)
+static inline struct page *page_cache_alloc_cold(struct address_space *x,
+						 struct page *shadow)
 {
-	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD);
+	return __page_cache_alloc(mapping_gfp_mask(x)|__GFP_COLD, shadow);
 }
 
-static inline struct page *page_cache_alloc_readahead(struct address_space *x)
+static inline struct page *page_cache_alloc_readahead(struct address_space *x,
+						      struct page *shadow)
 {
 	return __page_cache_alloc(mapping_gfp_mask(x) |
-				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN);
+				  __GFP_COLD | __GFP_NORETRY | __GFP_NOWARN,
+				  shadow);
 }
 
 typedef int filler_t(void *, struct page *);
diff --git a/mm/filemap.c b/mm/filemap.c
index 34b2f0b..d3e5578 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -538,7 +538,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
-struct page *__page_cache_alloc(gfp_t gfp)
+struct page *__page_cache_alloc(gfp_t gfp, struct page *shadow)
 {
 	int n;
 	struct page *page;
@@ -917,9 +917,9 @@ struct page *find_or_create_page(struct address_space *mapping,
 	struct page *page;
 	int err;
 repeat:
-	page = find_lock_page(mapping, index);
-	if (!page) {
-		page = __page_cache_alloc(gfp_mask);
+	page = __find_lock_page(mapping, index);
+	if (!page || radix_tree_exceptional_entry(page)) {
+		page = __page_cache_alloc(gfp_mask, page);
 		if (!page)
 			return NULL;
 		/*
@@ -1222,15 +1222,16 @@ EXPORT_SYMBOL(find_get_pages_tag);
 struct page *
 grab_cache_page_nowait(struct address_space *mapping, pgoff_t index)
 {
-	struct page *page = find_get_page(mapping, index);
+	struct page *page = __find_get_page(mapping, index);
 
-	if (page) {
+	if (page && !radix_tree_exceptional_entry(page)) {
 		if (trylock_page(page))
 			return page;
 		page_cache_release(page);
 		return NULL;
 	}
-	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS);
+	page = __page_cache_alloc(mapping_gfp_mask(mapping) & ~__GFP_FS,
+				  page);
 	if (page && add_to_page_cache_lru(page, mapping, index, GFP_NOFS)) {
 		page_cache_release(page);
 		page = NULL;
@@ -1304,8 +1305,9 @@ find_page:
 			page_cache_sync_readahead(mapping,
 					ra, filp,
 					index, last_index - index);
-			page = find_get_page(mapping, index);
-			if (unlikely(page == NULL))
+			page = __find_get_page(mapping, index);
+			if (unlikely(page == NULL ||
+				     radix_tree_exceptional_entry(page)))
 				goto no_cached_page;
 		}
 		if (PageReadahead(page)) {
@@ -1464,7 +1466,7 @@ no_cached_page:
 		 * Ok, it wasn't cached, so we need to create a new
 		 * page..
 		 */
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, page);
 		if (!page) {
 			desc->error = -ENOMEM;
 			goto out;
@@ -1673,18 +1675,20 @@ EXPORT_SYMBOL(generic_file_aio_read);
  * page_cache_read - adds requested page to the page cache if not already there
  * @file:	file to read
  * @offset:	page index
+ * @shadow:	shadow page of the page to be added
  *
  * This adds the requested page to the page cache if it isn't already there,
  * and schedules an I/O to read in its contents from disk.
  */
-static int page_cache_read(struct file *file, pgoff_t offset)
+static int page_cache_read(struct file *file, pgoff_t offset,
+			   struct page *shadow)
 {
 	struct address_space *mapping = file->f_mapping;
 	struct page *page; 
 	int ret;
 
 	do {
-		page = page_cache_alloc_cold(mapping);
+		page = page_cache_alloc_cold(mapping, shadow);
 		if (!page)
 			return -ENOMEM;
 
@@ -1815,8 +1819,8 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		mem_cgroup_count_vm_event(vma->vm_mm, PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
 retry_find:
-		page = find_get_page(mapping, offset);
-		if (!page)
+		page = __find_get_page(mapping, offset);
+		if (!page || radix_tree_exceptional_entry(page))
 			goto no_cached_page;
 	}
 
@@ -1859,7 +1863,7 @@ no_cached_page:
 	 * We're only likely to ever get here if MADV_RANDOM is in
 	 * effect.
 	 */
-	error = page_cache_read(file, offset);
+	error = page_cache_read(file, offset, page);
 
 	/*
 	 * The page we want has now been added to the page cache.
@@ -1981,9 +1985,9 @@ static struct page *__read_cache_page(struct address_space *mapping,
 	struct page *page;
 	int err;
 repeat:
-	page = find_get_page(mapping, index);
-	if (!page) {
-		page = __page_cache_alloc(gfp | __GFP_COLD);
+	page = __find_get_page(mapping, index);
+	if (!page || radix_tree_exceptional_entry(page)) {
+		page = __page_cache_alloc(gfp | __GFP_COLD, page);
 		if (!page)
 			return ERR_PTR(-ENOMEM);
 		err = add_to_page_cache_lru(page, mapping, index, gfp);
@@ -2454,11 +2458,11 @@ struct page *grab_cache_page_write_begin(struct address_space *mapping,
 	if (flags & AOP_FLAG_NOFS)
 		gfp_notmask = __GFP_FS;
 repeat:
-	page = find_lock_page(mapping, index);
-	if (page)
+	page = __find_lock_page(mapping, index);
+	if (page && !radix_tree_exceptional_entry(page))
 		goto found;
 
-	page = __page_cache_alloc(gfp_mask & ~gfp_notmask);
+	page = __page_cache_alloc(gfp_mask & ~gfp_notmask, page);
 	if (!page)
 		return NULL;
 	status = add_to_page_cache_lru(page, mapping, index,
diff --git a/mm/readahead.c b/mm/readahead.c
index 0f85996..58142ef 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -182,7 +182,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		if (page && !radix_tree_exceptional_entry(page))
 			continue;
 
-		page = page_cache_alloc_readahead(mapping);
+		page = page_cache_alloc_readahead(mapping, page);
 		if (!page)
 			break;
 		page->index = page_offset;
diff --git a/net/ceph/pagelist.c b/net/ceph/pagelist.c
index 92866be..83fb56e 100644
--- a/net/ceph/pagelist.c
+++ b/net/ceph/pagelist.c
@@ -32,7 +32,7 @@ static int ceph_pagelist_addpage(struct ceph_pagelist *pl)
 	struct page *page;
 
 	if (!pl->num_pages_free) {
-		page = __page_cache_alloc(GFP_NOFS);
+		page = __page_cache_alloc(GFP_NOFS, NULL);
 	} else {
 		page = list_first_entry(&pl->free_list, struct page, lru);
 		list_del(&page->lru);
@@ -83,7 +83,7 @@ int ceph_pagelist_reserve(struct ceph_pagelist *pl, size_t space)
 	space = (space + PAGE_SIZE - 1) >> PAGE_SHIFT;   /* conv to num pages */
 
 	while (space > pl->num_pages_free) {
-		struct page *page = __page_cache_alloc(GFP_NOFS);
+		struct page *page = __page_cache_alloc(GFP_NOFS, NULL);
 		if (!page)
 			return -ENOMEM;
 		list_add_tail(&page->lru, &pl->free_list);
diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
index 815a224..ff76422 100644
--- a/net/ceph/pagevec.c
+++ b/net/ceph/pagevec.c
@@ -79,7 +79,7 @@ struct page **ceph_alloc_page_vector(int num_pages, gfp_t flags)
 	if (!pages)
 		return ERR_PTR(-ENOMEM);
 	for (i = 0; i < num_pages; i++) {
-		pages[i] = __page_cache_alloc(flags);
+		pages[i] = __page_cache_alloc(flags, NULL);
 		if (pages[i] == NULL) {
 			ceph_release_page_vector(pages, i);
 			return ERR_PTR(-ENOMEM);
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
