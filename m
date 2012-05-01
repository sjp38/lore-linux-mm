Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 4E1776B0044
	for <linux-mm@kvack.org>; Tue,  1 May 2012 04:43:18 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/5] mm + fs: prepare for non-page entries in page cache
Date: Tue,  1 May 2012 10:41:50 +0200
Message-Id: <1335861713-4573-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

shmem mappings already contain exceptional entries where swap slot
information is remembered.

To be able to store eviction information for regular page cache,
prepare every site dealing with the radix trees directly to handle
non-page entries.

The common lookup functions will filter out non-page entries and
return NULL for page cache holes, just as before.  But provide a raw
version of the API which returns non-page entries as well, and switch
shmem over to use it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/btrfs/compression.c   |    2 +-
 fs/btrfs/extent_io.c     |    3 +-
 fs/inode.c               |    3 +-
 fs/nilfs2/inode.c        |    6 +--
 include/linux/mm.h       |    8 +++
 include/linux/pagemap.h  |   13 +++--
 include/linux/pagevec.h  |    3 +
 include/linux/shmem_fs.h |    1 +
 mm/filemap.c             |  124 +++++++++++++++++++++++++++++++++++++++-------
 mm/mincore.c             |   20 +++++--
 mm/readahead.c           |   12 +++-
 mm/shmem.c               |   89 +++++----------------------------
 mm/swap.c                |   21 ++++++++
 mm/truncate.c            |   71 +++++++++++++++++++++------
 14 files changed, 244 insertions(+), 132 deletions(-)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index d02c27c..a0594c9 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -472,7 +472,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, pg_index);
 		rcu_read_unlock();
-		if (page) {
+		if (page && !radix_tree_exceptional_entry(page)) {
 			misses++;
 			if (misses > 4)
 				break;
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index a55fbe6..f78352d 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -3566,7 +3566,8 @@ inline struct page *extent_buffer_page(struct extent_buffer *eb,
 	rcu_read_lock();
 	p = radix_tree_lookup(&mapping->page_tree, i);
 	rcu_read_unlock();
-
+	if (radix_tree_exceptional_entry(p))
+		p = NULL;
 	return p;
 }
 
diff --git a/fs/inode.c b/fs/inode.c
index 83ab215..645731f 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -544,8 +544,7 @@ static void evict(struct inode *inode)
 	if (op->evict_inode) {
 		op->evict_inode(inode);
 	} else {
-		if (inode->i_data.nrpages)
-			truncate_inode_pages(&inode->i_data, 0);
+		truncate_inode_pages(&inode->i_data, 0);
 		end_writeback(inode);
 	}
 	if (S_ISBLK(inode->i_mode) && inode->i_bdev)
diff --git a/fs/nilfs2/inode.c b/fs/nilfs2/inode.c
index 8f7b95a..35b7e18 100644
--- a/fs/nilfs2/inode.c
+++ b/fs/nilfs2/inode.c
@@ -732,16 +732,14 @@ void nilfs_evict_inode(struct inode *inode)
 	int ret;
 
 	if (inode->i_nlink || !ii->i_root || unlikely(is_bad_inode(inode))) {
-		if (inode->i_data.nrpages)
-			truncate_inode_pages(&inode->i_data, 0);
+		truncate_inode_pages(&inode->i_data, 0);
 		end_writeback(inode);
 		nilfs_clear_inode(inode);
 		return;
 	}
 	nilfs_transaction_begin(sb, &ti, 0); /* never fails */
 
-	if (inode->i_data.nrpages)
-		truncate_inode_pages(&inode->i_data, 0);
+	truncate_inode_pages(&inode->i_data, 0);
 
 	/* TODO: some of the following operations may fail.  */
 	nilfs_truncate_bmap(ii, 0);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..0d5948b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -873,6 +873,14 @@ extern bool skip_free_areas_node(unsigned int flags, int nid);
 int shmem_lock(struct file *file, int lock, struct user_struct *user);
 struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags);
 int shmem_zero_setup(struct vm_area_struct *);
+#ifdef CONFIG_SHMEM
+bool shmem_mapping(struct address_space *);
+#else
+static inline bool shmem_mapping(struct address_space *mapping)
+{
+	return false;
+}
+#endif
 
 extern int can_do_mlock(void);
 extern int user_shm_lock(size_t, struct user_struct *);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index cfaaa69..aba5b91 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -227,12 +227,13 @@ static inline struct page *page_cache_alloc_readahead(struct address_space *x)
 
 typedef int filler_t(void *, struct page *);
 
-extern struct page * find_get_page(struct address_space *mapping,
-				pgoff_t index);
-extern struct page * find_lock_page(struct address_space *mapping,
-				pgoff_t index);
-extern struct page * find_or_create_page(struct address_space *mapping,
-				pgoff_t index, gfp_t gfp_mask);
+struct page *__find_get_page(struct address_space *, pgoff_t);
+struct page *find_get_page(struct address_space *, pgoff_t);
+struct page *__find_lock_page(struct address_space *, pgoff_t);
+struct page *find_lock_page(struct address_space *, pgoff_t);
+struct page *find_or_create_page(struct address_space *, pgoff_t, gfp_t);
+unsigned __find_get_pages(struct address_space *, pgoff_t,  unsigned int,
+			  struct page **, pgoff_t *);
 unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 			unsigned int nr_pages, struct page **pages);
 unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 2aa12b8..7520532 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -22,6 +22,9 @@ struct pagevec {
 
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
+unsigned __pagevec_lookup(struct pagevec *, struct address_space *,
+			  pgoff_t, unsigned, pgoff_t *);
+void pagevec_remove_exceptionals(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 79ab255..69444f1 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -48,6 +48,7 @@ extern struct file *shmem_file_setup(const char *name,
 					loff_t size, unsigned long flags);
 extern int shmem_zero_setup(struct vm_area_struct *);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
+extern bool shmem_mapping(struct address_space *);
 extern void shmem_unlock_mapping(struct address_space *mapping);
 extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 					pgoff_t index, gfp_t gfp_mask);
diff --git a/mm/filemap.c b/mm/filemap.c
index b662757..b8af34a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -431,6 +431,24 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
 }
 EXPORT_SYMBOL_GPL(replace_page_cache_page);
 
+static int page_cache_insert(struct address_space *mapping, pgoff_t offset,
+			     struct page *page)
+{
+	void **slot;
+
+	slot = radix_tree_lookup_slot(&mapping->page_tree, offset);
+	if (slot) {
+		void *p;
+
+		p = radix_tree_deref_slot_protected(slot, &mapping->tree_lock);
+		if (!radix_tree_exceptional_entry(p))
+			return -EEXIST;
+		radix_tree_replace_slot(slot, page);
+		return 0;
+	}
+	return radix_tree_insert(&mapping->page_tree, offset, page);
+}
+
 /**
  * add_to_page_cache_locked - add a locked page to the pagecache
  * @page:	page to add
@@ -461,7 +479,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		page->index = offset;
 
 		spin_lock_irq(&mapping->tree_lock);
-		error = radix_tree_insert(&mapping->page_tree, offset, page);
+		error = page_cache_insert(mapping, offset, page);
 		if (likely(!error)) {
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
@@ -664,15 +682,7 @@ int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 	}
 }
 
-/**
- * find_get_page - find and get a page reference
- * @mapping: the address_space to search
- * @offset: the page index
- *
- * Is there a pagecache struct page at the given (mapping, offset) tuple?
- * If yes, increment its refcount and return it; if no, return NULL.
- */
-struct page *find_get_page(struct address_space *mapping, pgoff_t offset)
+struct page *__find_get_page(struct address_space *mapping, pgoff_t offset)
 {
 	void **pagep;
 	struct page *page;
@@ -713,22 +723,29 @@ out:
 
 	return page;
 }
-EXPORT_SYMBOL(find_get_page);
+EXPORT_SYMBOL(__find_get_page);
 
 /**
- * find_lock_page - locate, pin and lock a pagecache page
+ * find_get_page - find and get a page reference
  * @mapping: the address_space to search
  * @offset: the page index
  *
- * Locates the desired pagecache page, locks it, increments its reference
- * count and returns its address.
- *
- * Returns zero if the page was not present. find_lock_page() may sleep.
+ * Is there a pagecache struct page at the given (mapping, offset) tuple?
+ * If yes, increment its refcount and return it; if no, return NULL.
  */
-struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
+struct page *find_get_page(struct address_space *mapping, pgoff_t offset)
 {
-	struct page *page;
+	struct page *page = __find_get_page(mapping, offset);
+
+	if (radix_tree_exceptional_entry(page))
+		page = NULL;
+	return page;
+}
+EXPORT_SYMBOL(find_get_page);
 
+struct page *__find_lock_page(struct address_space *mapping, pgoff_t offset)
+{
+	struct page *page;
 repeat:
 	page = find_get_page(mapping, offset);
 	if (page && !radix_tree_exception(page)) {
@@ -743,6 +760,25 @@ repeat:
 	}
 	return page;
 }
+
+/**
+ * find_lock_page - locate, pin and lock a pagecache page
+ * @mapping: the address_space to search
+ * @offset: the page index
+ *
+ * Locates the desired pagecache page, locks it, increments its reference
+ * count and returns its address.
+ *
+ * Returns zero if the page was not present. find_lock_page() may sleep.
+ */
+struct page *find_lock_page(struct address_space *mapping, pgoff_t offset)
+{
+	struct page *page = __find_lock_page(mapping, offset);
+
+	if (radix_tree_exceptional_entry(page))
+		page = NULL;
+	return page;
+}
 EXPORT_SYMBOL(find_lock_page);
 
 /**
@@ -792,6 +828,54 @@ repeat:
 }
 EXPORT_SYMBOL(find_or_create_page);
 
+unsigned __find_get_pages(struct address_space *mapping,
+			  pgoff_t start, unsigned int nr_pages,
+			  struct page **pages, pgoff_t *indices)
+{
+	unsigned int i;
+	unsigned int ret;
+	unsigned int nr_found;
+
+	rcu_read_lock();
+restart:
+	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
+				(void ***)pages, indices, start, nr_pages);
+	ret = 0;
+	for (i = 0; i < nr_found; i++) {
+		struct page *page;
+repeat:
+		page = radix_tree_deref_slot((void **)pages[i]);
+		if (unlikely(!page))
+			continue;
+		if (radix_tree_exception(page)) {
+			if (radix_tree_deref_retry(page))
+				goto restart;
+			/*
+			 * Otherwise, we must be storing a swap entry
+			 * here as an exceptional entry: so return it
+			 * without attempting to raise page count.
+			 */
+			goto export;
+		}
+		if (!page_cache_get_speculative(page))
+			goto repeat;
+
+		/* Has the page moved? */
+		if (unlikely(page != *((void **)pages[i]))) {
+			page_cache_release(page);
+			goto repeat;
+		}
+export:
+		indices[ret] = indices[i];
+		pages[ret] = page;
+		ret++;
+	}
+	if (unlikely(!ret && nr_found))
+		goto restart;
+	rcu_read_unlock();
+	return ret;
+}
+
 /**
  * find_get_pages - gang pagecache lookup
  * @mapping:	The address_space to search
@@ -864,8 +948,10 @@ repeat:
 	 * If all entries were removed before we could secure them,
 	 * try again, because callers stop trying once 0 is returned.
 	 */
-	if (unlikely(!ret && nr_found > nr_skip))
+	if (unlikely(!ret && nr_found)) {
+		start += nr_skip;
 		goto restart;
+	}
 	rcu_read_unlock();
 	return ret;
 }
diff --git a/mm/mincore.c b/mm/mincore.c
index 636a868..0c7f093 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -70,13 +70,21 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 	 * any other file mapping (ie. marked !present and faulted in with
 	 * tmpfs's .fault). So swapped out tmpfs mappings are tested here.
 	 */
-	page = find_get_page(mapping, pgoff);
 #ifdef CONFIG_SWAP
-	/* shmem/tmpfs may return swap: account for swapcache page too. */
-	if (radix_tree_exceptional_entry(page)) {
-		swp_entry_t swap = radix_to_swp_entry(page);
-		page = find_get_page(&swapper_space, swap.val);
-	}
+	if (shmem_mapping(mapping)) {
+		page = __find_get_page(mapping, pgoff);
+		/*
+		 * shmem/tmpfs may return swap: account for swapcache
+		 * page too.
+		 */
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swap = radix_to_swp_entry(page);
+			page = find_get_page(&swapper_space, swap.val);
+		}
+	} else
+		page = find_get_page(mapping, pgoff);
+#else
+	page = find_get_page(mapping, pgoff);
 #endif
 	if (page) {
 		present = PageUptodate(page);
diff --git a/mm/readahead.c b/mm/readahead.c
index 0d1f1aa..43f9dd2 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -177,7 +177,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
 		rcu_read_unlock();
-		if (page)
+		if (page && !radix_tree_exceptional_entry(page))
 			continue;
 
 		page = page_cache_alloc_readahead(mapping);
@@ -342,7 +342,10 @@ static unsigned long page_cache_next_hole(struct address_space *mapping,
 	unsigned long i;
 
 	for (i = 0; i < max_scan; i++) {
-		if (!radix_tree_lookup(&mapping->page_tree, index))
+		struct page *page;
+
+		page = radix_tree_lookup(&mapping->page_tree, index);
+		if (!page || radix_tree_exceptional_entry(page))
 			break;
 		index++;
 		if (index == 0)
@@ -358,7 +361,10 @@ static unsigned long page_cache_prev_hole(struct address_space *mapping,
 	unsigned long i;
 
 	for (i = 0; i < max_scan; i++) {
-		if (!radix_tree_lookup(&mapping->page_tree, index))
+		struct page *page;
+
+		page = radix_tree_lookup(&mapping->page_tree, index);
+		if (!page || radix_tree_exceptional_entry(page))
 			break;
 		index--;
 		if (index == ULONG_MAX)
diff --git a/mm/shmem.c b/mm/shmem.c
index 269d049..6d063eb 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -310,57 +310,6 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 }
 
 /*
- * Like find_get_pages, but collecting swap entries as well as pages.
- */
-static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
-					pgoff_t start, unsigned int nr_pages,
-					struct page **pages, pgoff_t *indices)
-{
-	unsigned int i;
-	unsigned int ret;
-	unsigned int nr_found;
-
-	rcu_read_lock();
-restart:
-	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
-				(void ***)pages, indices, start, nr_pages);
-	ret = 0;
-	for (i = 0; i < nr_found; i++) {
-		struct page *page;
-repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
-		if (unlikely(!page))
-			continue;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page))
-				goto restart;
-			/*
-			 * Otherwise, we must be storing a swap entry
-			 * here as an exceptional entry: so return it
-			 * without attempting to raise page count.
-			 */
-			goto export;
-		}
-		if (!page_cache_get_speculative(page))
-			goto repeat;
-
-		/* Has the page moved? */
-		if (unlikely(page != *((void **)pages[i]))) {
-			page_cache_release(page);
-			goto repeat;
-		}
-export:
-		indices[ret] = indices[i];
-		pages[ret] = page;
-		ret++;
-	}
-	if (unlikely(!ret && nr_found))
-		goto restart;
-	rcu_read_unlock();
-	return ret;
-}
-
-/*
  * Remove swap entry from radix tree, free the swap and its page cache.
  */
 static int shmem_free_swap(struct address_space *mapping,
@@ -377,21 +326,6 @@ static int shmem_free_swap(struct address_space *mapping,
 }
 
 /*
- * Pagevec may contain swap entries, so shuffle up pages before releasing.
- */
-static void shmem_deswap_pagevec(struct pagevec *pvec)
-{
-	int i, j;
-
-	for (i = 0, j = 0; i < pagevec_count(pvec); i++) {
-		struct page *page = pvec->pages[i];
-		if (!radix_tree_exceptional_entry(page))
-			pvec->pages[j++] = page;
-	}
-	pvec->nr = j;
-}
-
-/*
  * SysV IPC SHM_UNLOCK restore Unevictable pages to their evictable lists.
  */
 void shmem_unlock_mapping(struct address_space *mapping)
@@ -409,12 +343,12 @@ void shmem_unlock_mapping(struct address_space *mapping)
 		 * Avoid pagevec_lookup(): find_get_pages() returns 0 as if it
 		 * has finished, if it hits a row of PAGEVEC_SIZE swap entries.
 		 */
-		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
+		pvec.nr = __find_get_pages(mapping, index,
 					PAGEVEC_SIZE, pvec.pages, indices);
 		if (!pvec.nr)
 			break;
 		index = indices[pvec.nr - 1] + 1;
-		shmem_deswap_pagevec(&pvec);
+		pagevec_remove_exceptionals(&pvec);
 		check_move_unevictable_pages(pvec.pages, pvec.nr);
 		pagevec_release(&pvec);
 		cond_resched();
@@ -442,7 +376,7 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index <= end) {
-		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
+		pvec.nr = __find_get_pages(mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 							pvec.pages, indices);
 		if (!pvec.nr)
@@ -469,7 +403,7 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 			}
 			unlock_page(page);
 		}
-		shmem_deswap_pagevec(&pvec);
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
@@ -490,7 +424,7 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 	index = start;
 	for ( ; ; ) {
 		cond_resched();
-		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
+		pvec.nr = __find_get_pages(mapping, index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 							pvec.pages, indices);
 		if (!pvec.nr) {
@@ -500,7 +434,7 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 			continue;
 		}
 		if (index == start && indices[0] > end) {
-			shmem_deswap_pagevec(&pvec);
+			pagevec_remove_exceptionals(&pvec);
 			pagevec_release(&pvec);
 			break;
 		}
@@ -525,7 +459,7 @@ void shmem_truncate_range(struct inode *inode, loff_t lstart, loff_t lend)
 			}
 			unlock_page(page);
 		}
-		shmem_deswap_pagevec(&pvec);
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		index++;
@@ -877,7 +811,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		return -EFBIG;
 repeat:
 	swap.val = 0;
-	page = find_lock_page(mapping, index);
+	page = __find_lock_page(mapping, index);
 	if (radix_tree_exceptional_entry(page)) {
 		swap = radix_to_swp_entry(page);
 		page = NULL;
@@ -1025,7 +959,7 @@ unacct:
 	shmem_unacct_blocks(info->flags, 1);
 failed:
 	if (swap.val && error != -EINVAL) {
-		struct page *test = find_get_page(mapping, index);
+		struct page *test = __find_get_page(mapping, index);
 		if (test && !radix_tree_exceptional_entry(test))
 			page_cache_release(test);
 		/* Have another try if the entry has changed */
@@ -1174,6 +1108,11 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
 	return inode;
 }
 
+bool shmem_mapping(struct address_space *mapping)
+{
+	return mapping->backing_dev_info == &shmem_backing_dev_info;
+}
+
 #ifdef CONFIG_TMPFS
 static const struct inode_operations shmem_symlink_inode_operations;
 static const struct inode_operations shmem_short_symlink_operations;
diff --git a/mm/swap.c b/mm/swap.c
index 14380e9..cc5ce81 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -728,6 +728,27 @@ void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
 }
 EXPORT_SYMBOL(__pagevec_lru_add);
 
+unsigned __pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
+			  pgoff_t start, unsigned int nr_pages,
+			  pgoff_t *indices)
+{
+	pvec->nr = __find_get_pages(mapping, start, nr_pages,
+				    pvec->pages, indices);
+	return pagevec_count(pvec);
+}
+
+void pagevec_remove_exceptionals(struct pagevec *pvec)
+{
+	int i, j;
+
+	for (i = 0, j = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		if (!radix_tree_exceptional_entry(page))
+			pvec->pages[j++] = page;
+	}
+	pvec->nr = j;
+}
+
 /**
  * pagevec_lookup - gang pagecache lookup
  * @pvec:	Where the resulting pages are placed
diff --git a/mm/truncate.c b/mm/truncate.c
index 632b15e..d8c8964 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -22,6 +22,18 @@
 #include <linux/cleancache.h>
 #include "internal.h"
 
+static void clear_exceptional_entry(struct address_space *mapping,
+				    pgoff_t index, struct page *page)
+{
+	/* Handled by shmem itself */
+	if (shmem_mapping(mapping))
+		return;
+
+	spin_lock_irq(&mapping->tree_lock);
+	if (radix_tree_lookup(&mapping->page_tree, index) == page)
+		radix_tree_delete(&mapping->page_tree, index);
+	spin_unlock_irq(&mapping->tree_lock);
+}
 
 /**
  * do_invalidatepage - invalidate part or all of a page
@@ -208,31 +220,36 @@ void truncate_inode_pages_range(struct address_space *mapping,
 {
 	const pgoff_t start = (lstart + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
 	const unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
+	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
 	pgoff_t index;
 	pgoff_t end;
 	int i;
 
 	cleancache_flush_inode(mapping);
-	if (mapping->nrpages == 0)
-		return;
 
 	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
 	end = (lend >> PAGE_CACHE_SHIFT);
 
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index <= end && pagevec_lookup(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+	while (index <= end && __pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
+			indices)) {
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
-			index = page->index;
+			index = indices[i];
 			if (index > end)
 				break;
 
+			if (radix_tree_exceptional_entry(page)) {
+				clear_exceptional_entry(mapping, index, page);
+				continue;
+			}
+
 			if (!trylock_page(page))
 				continue;
 			WARN_ON(page->index != index);
@@ -243,6 +260,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
@@ -262,14 +280,15 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	index = start;
 	for ( ; ; ) {
 		cond_resched();
-		if (!pagevec_lookup(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+		if (!__pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
+			indices)) {
 			if (index == start)
 				break;
 			index = start;
 			continue;
 		}
-		if (index == start && pvec.pages[0]->index > end) {
+		if (index == start && indices[0] > end) {
 			pagevec_release(&pvec);
 			break;
 		}
@@ -278,16 +297,22 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
-			index = page->index;
+			index = indices[i];
 			if (index > end)
 				break;
 
+			if (radix_tree_exceptional_entry(page)) {
+				clear_exceptional_entry(mapping, index, page);
+				continue;
+			}
+
 			lock_page(page);
 			WARN_ON(page->index != index);
 			wait_on_page_writeback(page);
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		index++;
@@ -330,6 +355,7 @@ EXPORT_SYMBOL(truncate_inode_pages);
 unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t end)
 {
+	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
 	pgoff_t index = start;
 	unsigned long ret;
@@ -345,17 +371,23 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	 */
 
 	pagevec_init(&pvec, 0);
-	while (index <= end && pagevec_lookup(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+	while (index <= end && __pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
+			indices)) {
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
-			index = page->index;
+			index = indices[i];
 			if (index > end)
 				break;
 
+			if (radix_tree_exceptional_entry(page)) {
+				clear_exceptional_entry(mapping, index, page);
+				continue;
+			}
+
 			if (!trylock_page(page))
 				continue;
 			WARN_ON(page->index != index);
@@ -369,6 +401,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 				deactivate_page(page);
 			count += ret;
 		}
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
@@ -437,6 +470,7 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
 int invalidate_inode_pages2_range(struct address_space *mapping,
 				  pgoff_t start, pgoff_t end)
 {
+	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
 	pgoff_t index;
 	int i;
@@ -447,17 +481,23 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	cleancache_flush_inode(mapping);
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index <= end && pagevec_lookup(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1)) {
+	while (index <= end && __pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
+			indices)) {
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
-			index = page->index;
+			index = indices[i];
 			if (index > end)
 				break;
 
+			if (radix_tree_exceptional_entry(page)) {
+				clear_exceptional_entry(mapping, index, page);
+				continue;
+			}
+
 			lock_page(page);
 			WARN_ON(page->index != index);
 			if (page->mapping != mapping) {
@@ -495,6 +535,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 				ret = ret2;
 			unlock_page(page);
 		}
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
