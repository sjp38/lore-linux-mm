Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 7FDF36B0036
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 18:44:47 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 4/9] mm + fs: prepare for non-page entries in page cache radix trees
Date: Tue,  6 Aug 2013 18:44:05 -0400
Message-Id: <1375829050-12654-5-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
References: <1375829050-12654-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

shmem mappings already contain exceptional entries where swap slot
information is remembered.

To be able to store eviction information for regular page cache,
prepare every site dealing with the radix trees directly to handle
entries other than pages.

The common lookup functions will filter out non-page entries and
return NULL for page cache holes, just as before.  But provide a raw
version of the API which returns non-page entries as well, and switch
shmem over to use it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 fs/btrfs/compression.c   |   2 +-
 include/linux/mm.h       |   8 +++
 include/linux/pagemap.h  |  15 +++---
 include/linux/pagevec.h  |   3 ++
 include/linux/shmem_fs.h |   1 +
 mm/filemap.c             | 131 +++++++++++++++++++++++++++++++++++++++--------
 mm/mincore.c             |  20 +++++---
 mm/readahead.c           |   2 +-
 mm/shmem.c               |  97 +++++++----------------------------
 mm/swap.c                |  20 ++++++++
 mm/truncate.c            |  75 +++++++++++++++++++++------
 11 files changed, 246 insertions(+), 128 deletions(-)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index b189bd1..5ce2c0f 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -475,7 +475,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, pg_index);
 		rcu_read_unlock();
-		if (page) {
+		if (page && !radix_tree_exceptional_entry(page)) {
 			misses++;
 			if (misses > 4)
 				break;
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e20da1b..7f4d1f1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -913,6 +913,14 @@ extern void show_free_areas(unsigned int flags);
 extern bool skip_free_areas_node(unsigned int flags, int nid);
 
 int shmem_zero_setup(struct vm_area_struct *);
+#ifdef CONFIG_SHMEM
+bool shmem_mapping(struct address_space *mapping);
+#else
+static inline bool shmem_mapping(struct address_space *mapping)
+{
+	return false;
+}
+#endif
 
 extern int can_do_mlock(void);
 extern int user_shm_lock(size_t, struct user_struct *);
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index c73130c..b6854b7 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -248,12 +248,15 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
 pgoff_t page_cache_prev_hole(struct address_space *mapping,
 			     pgoff_t index, unsigned long max_scan);
 
-extern struct page * find_get_page(struct address_space *mapping,
-				pgoff_t index);
-extern struct page * find_lock_page(struct address_space *mapping,
-				pgoff_t index);
-extern struct page * find_or_create_page(struct address_space *mapping,
-				pgoff_t index, gfp_t gfp_mask);
+struct page *__find_get_page(struct address_space *mapping, pgoff_t offset);
+struct page *find_get_page(struct address_space *mapping, pgoff_t offset);
+struct page *__find_lock_page(struct address_space *mapping, pgoff_t offset);
+struct page *find_lock_page(struct address_space *mapping, pgoff_t offset);
+struct page *find_or_create_page(struct address_space *mapping, pgoff_t index,
+				 gfp_t gfp_mask);
+unsigned __find_get_pages(struct address_space *mapping, pgoff_t start,
+			  unsigned int nr_pages, struct page **pages,
+			  pgoff_t *indices);
 unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 			unsigned int nr_pages, struct page **pages);
 unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index e4dbfab..3c6b8b1 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -22,6 +22,9 @@ struct pagevec {
 
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
+unsigned __pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
+			  pgoff_t start, unsigned nr_pages, pgoff_t *indices);
+void pagevec_remove_exceptionals(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 30aa0dc..deb4960 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -49,6 +49,7 @@ extern struct file *shmem_file_setup(const char *name,
 					loff_t size, unsigned long flags);
 extern int shmem_zero_setup(struct vm_area_struct *);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
+extern bool shmem_mapping(struct address_space *mapping);
 extern void shmem_unlock_mapping(struct address_space *mapping);
 extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 					pgoff_t index, gfp_t gfp_mask);
diff --git a/mm/filemap.c b/mm/filemap.c
index e7833d2..254eb16 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -446,6 +446,24 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
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
@@ -480,7 +498,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 	page->index = offset;
 
 	spin_lock_irq(&mapping->tree_lock);
-	error = radix_tree_insert(&mapping->page_tree, offset, page);
+	error = page_cache_insert(mapping, offset, page);
 	radix_tree_preload_end();
 	if (unlikely(error))
 		goto err_insert;
@@ -714,7 +732,10 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
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
@@ -752,7 +773,10 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
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
@@ -763,15 +787,7 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
 }
 EXPORT_SYMBOL(page_cache_prev_hole);
 
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
@@ -812,24 +828,31 @@ out:
 
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
-	page = find_get_page(mapping, offset);
+	page = __find_get_page(mapping, offset);
 	if (page && !radix_tree_exception(page)) {
 		lock_page(page);
 		/* Has the page been truncated? */
@@ -842,6 +865,25 @@ repeat:
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
@@ -891,6 +933,53 @@ repeat:
 }
 EXPORT_SYMBOL(find_or_create_page);
 
+unsigned __find_get_pages(struct address_space *mapping,
+			  pgoff_t start, unsigned int nr_pages,
+			  struct page **pages, pgoff_t *indices)
+{
+	void **slot;
+	unsigned int ret = 0;
+	struct radix_tree_iter iter;
+
+	if (!nr_pages)
+		return 0;
+
+	rcu_read_lock();
+restart:
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+		struct page *page;
+repeat:
+		page = radix_tree_deref_slot(slot);
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
+		if (unlikely(page != *slot)) {
+			page_cache_release(page);
+			goto repeat;
+		}
+export:
+		indices[ret] = iter.index;
+		pages[ret] = page;
+		if (++ret == nr_pages)
+			break;
+	}
+	rcu_read_unlock();
+	return ret;
+}
+
 /**
  * find_get_pages - gang pagecache lookup
  * @mapping:	The address_space to search
diff --git a/mm/mincore.c b/mm/mincore.c
index da2be56..ad411ec 100644
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
-		page = find_get_page(swap_address_space(swap), swap.val);
-	}
+	if (shmem_mapping(mapping)) {
+		page = __find_get_page(mapping, pgoff);
+		/*
+		 * shmem/tmpfs may return swap: account for swapcache
+		 * page too.
+		 */
+		if (radix_tree_exceptional_entry(page)) {
+			swp_entry_t swp = radix_to_swp_entry(page);
+			page = find_get_page(swap_address_space(swp), swp.val);
+		}
+	} else
+		page = find_get_page(mapping, pgoff);
+#else
+	page = find_get_page(mapping, pgoff);
 #endif
 	if (page) {
 		present = PageUptodate(page);
diff --git a/mm/readahead.c b/mm/readahead.c
index 01f4cae..0f85996 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -179,7 +179,7 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
 		rcu_read_lock();
 		page = radix_tree_lookup(&mapping->page_tree, page_offset);
 		rcu_read_unlock();
-		if (page)
+		if (page && !radix_tree_exceptional_entry(page))
 			continue;
 
 		page = page_cache_alloc_readahead(mapping);
diff --git a/mm/shmem.c b/mm/shmem.c
index 8510534..2d18981 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -329,56 +329,6 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 }
 
 /*
- * Like find_get_pages, but collecting swap entries as well as pages.
- */
-static unsigned shmem_find_get_pages_and_swap(struct address_space *mapping,
-					pgoff_t start, unsigned int nr_pages,
-					struct page **pages, pgoff_t *indices)
-{
-	void **slot;
-	unsigned int ret = 0;
-	struct radix_tree_iter iter;
-
-	if (!nr_pages)
-		return 0;
-
-	rcu_read_lock();
-restart:
-	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		struct page *page;
-repeat:
-		page = radix_tree_deref_slot(slot);
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
-		if (unlikely(page != *slot)) {
-			page_cache_release(page);
-			goto repeat;
-		}
-export:
-		indices[ret] = iter.index;
-		pages[ret] = page;
-		if (++ret == nr_pages)
-			break;
-	}
-	rcu_read_unlock();
-	return ret;
-}
-
-/*
  * Remove swap entry from radix tree, free the swap and its page cache.
  */
 static int shmem_free_swap(struct address_space *mapping,
@@ -396,21 +346,6 @@ static int shmem_free_swap(struct address_space *mapping,
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
@@ -428,12 +363,12 @@ void shmem_unlock_mapping(struct address_space *mapping)
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
@@ -465,9 +400,9 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index < end) {
-		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
-				min(end - index, (pgoff_t)PAGEVEC_SIZE),
-							pvec.pages, indices);
+		pvec.nr = __find_get_pages(mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE),
+			pvec.pages, indices);
 		if (!pvec.nr)
 			break;
 		mem_cgroup_uncharge_start();
@@ -496,7 +431,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			}
 			unlock_page(page);
 		}
-		shmem_deswap_pagevec(&pvec);
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
@@ -534,9 +469,10 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	index = start;
 	for ( ; ; ) {
 		cond_resched();
-		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
+
+		pvec.nr = __find_get_pages(mapping, index,
 				min(end - index, (pgoff_t)PAGEVEC_SIZE),
-							pvec.pages, indices);
+				pvec.pages, indices);
 		if (!pvec.nr) {
 			if (index == start || unfalloc)
 				break;
@@ -544,7 +480,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			continue;
 		}
 		if ((index == start || unfalloc) && indices[0] >= end) {
-			shmem_deswap_pagevec(&pvec);
+			pagevec_remove_exceptionals(&pvec);
 			pagevec_release(&pvec);
 			break;
 		}
@@ -573,7 +509,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			}
 			unlock_page(page);
 		}
-		shmem_deswap_pagevec(&pvec);
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		index++;
@@ -1081,7 +1017,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		return -EFBIG;
 repeat:
 	swap.val = 0;
-	page = find_lock_page(mapping, index);
+	page = __find_lock_page(mapping, index);
 	if (radix_tree_exceptional_entry(page)) {
 		swap = radix_to_swp_entry(page);
 		page = NULL;
@@ -1418,6 +1354,11 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
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
@@ -1731,7 +1672,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 	pagevec_init(&pvec, 0);
 	pvec.nr = 1;		/* start small: we may be there already */
 	while (!done) {
-		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
+		pvec.nr = __find_get_pages(mapping, index,
 					pvec.nr, pvec.pages, indices);
 		if (!pvec.nr) {
 			if (whence == SEEK_DATA)
@@ -1758,7 +1699,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 				break;
 			}
 		}
-		shmem_deswap_pagevec(&pvec);
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		pvec.nr = PAGEVEC_SIZE;
 		cond_resched();
diff --git a/mm/swap.c b/mm/swap.c
index 62b78a6..bf448cf 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -831,6 +831,26 @@ void __pagevec_lru_add(struct pagevec *pvec)
 }
 EXPORT_SYMBOL(__pagevec_lru_add);
 
+unsigned __pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
+			  pgoff_t start, unsigned nr_pages, pgoff_t *indices)
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
index e2e8a8a..21e4851 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -22,6 +22,22 @@
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
+	/*
+	 * Regular page slots are stabilized by the page lock even
+	 * without the tree itself locked.  These unlocked entries
+	 * need verification under the tree lock.
+	 */
+	radix_tree_delete_item(&mapping->page_tree, index, page);
+	spin_unlock_irq(&mapping->tree_lock);
+}
 
 /**
  * do_invalidatepage - invalidate part or all of a page
@@ -208,12 +224,11 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	unsigned int	partial_start;	/* inclusive */
 	unsigned int	partial_end;	/* exclusive */
 	struct pagevec	pvec;
+	pgoff_t		indices[PAGEVEC_SIZE];
 	pgoff_t		index;
 	int		i;
 
 	cleancache_invalidate_inode(mapping);
-	if (mapping->nrpages == 0)
-		return;
 
 	/* Offsets within partial pages */
 	partial_start = lstart & (PAGE_CACHE_SIZE - 1);
@@ -238,17 +253,23 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index < end && pagevec_lookup(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
+	while (index < end && __pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE),
+			indices)) {
 		mem_cgroup_uncharge_start();
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
-			index = page->index;
+			index = indices[i];
 			if (index >= end)
 				break;
 
+			if (radix_tree_exceptional_entry(page)) {
+				clear_exceptional_entry(mapping, index, page);
+				continue;
+			}
+
 			if (!trylock_page(page))
 				continue;
 			WARN_ON(page->index != index);
@@ -259,6 +280,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
@@ -307,14 +329,15 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	index = start;
 	for ( ; ; ) {
 		cond_resched();
-		if (!pagevec_lookup(&pvec, mapping, index,
-			min(end - index, (pgoff_t)PAGEVEC_SIZE))) {
+		if (!__pagevec_lookup(&pvec, mapping, index,
+			min(end - index, (pgoff_t)PAGEVEC_SIZE),
+			indices)) {
 			if (index == start)
 				break;
 			index = start;
 			continue;
 		}
-		if (index == start && pvec.pages[0]->index >= end) {
+		if (index == start && indices[0] >= end) {
 			pagevec_release(&pvec);
 			break;
 		}
@@ -323,16 +346,22 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
-			index = page->index;
+			index = indices[i];
 			if (index >= end)
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
@@ -375,6 +404,7 @@ EXPORT_SYMBOL(truncate_inode_pages);
 unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t end)
 {
+	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
 	pgoff_t index = start;
 	unsigned long ret;
@@ -390,17 +420,23 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
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
@@ -414,6 +450,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 				deactivate_page(page);
 			count += ret;
 		}
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
@@ -481,6 +518,7 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
 int invalidate_inode_pages2_range(struct address_space *mapping,
 				  pgoff_t start, pgoff_t end)
 {
+	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
 	pgoff_t index;
 	int i;
@@ -491,17 +529,23 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	cleancache_invalidate_inode(mapping);
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
@@ -539,6 +583,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 				ret = ret2;
 			unlock_page(page);
 		}
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
