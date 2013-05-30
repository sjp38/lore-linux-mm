Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 19C396B0038
	for <linux-mm@kvack.org>; Thu, 30 May 2013 14:04:45 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 05/10] mm + fs: prepare for non-page entries in page cache radix trees
Date: Thu, 30 May 2013 14:04:01 -0400
Message-Id: <1369937046-27666-6-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

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
 mm/filemap.c             | 130 +++++++++++++++++++++++++++++++++++++++--------
 mm/mincore.c             |  20 +++++---
 mm/readahead.c           |   2 +-
 mm/shmem.c               |  97 +++++++----------------------------
 mm/swap.c                |  20 ++++++++
 mm/truncate.c            |  75 +++++++++++++++++++++------
 11 files changed, 245 insertions(+), 128 deletions(-)

diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 15b9408..4a80f6b 100644
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e2091b8..c1dcd2f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -905,6 +905,14 @@ extern void show_free_areas(unsigned int flags);
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
index 206ae96..a972341 100644
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
index 2aa12b8..a2eeb43 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -22,6 +22,9 @@ struct pagevec {
 
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
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
index ccd5af8..df9a1db 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -429,6 +429,24 @@ int replace_page_cache_page(struct page *old, struct page *new, gfp_t gfp_mask)
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
@@ -459,7 +477,7 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		page->index = offset;
 
 		spin_lock_irq(&mapping->tree_lock);
-		error = radix_tree_insert(&mapping->page_tree, offset, page);
+		error = page_cache_insert(mapping, offset, page);
 		if (likely(!error)) {
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
@@ -692,7 +710,10 @@ pgoff_t page_cache_next_hole(struct address_space *mapping,
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
@@ -730,7 +751,10 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
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
@@ -741,15 +765,7 @@ pgoff_t page_cache_prev_hole(struct address_space *mapping,
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
@@ -790,24 +806,30 @@ out:
 
 	return page;
 }
-EXPORT_SYMBOL(find_get_page);
 
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
@@ -820,6 +842,25 @@ repeat:
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
@@ -869,6 +910,53 @@ repeat:
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
index 187cbea..29efd45 100644
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
index f6f5e4c..9bb4a7f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -327,56 +327,6 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
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
@@ -394,21 +344,6 @@ static int shmem_free_swap(struct address_space *mapping,
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
@@ -426,12 +361,12 @@ void shmem_unlock_mapping(struct address_space *mapping)
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
@@ -463,9 +398,9 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
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
@@ -494,7 +429,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			}
 			unlock_page(page);
 		}
-		shmem_deswap_pagevec(&pvec);
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
@@ -532,9 +467,10 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
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
@@ -542,7 +478,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			continue;
 		}
 		if ((index == start || unfalloc) && indices[0] >= end) {
-			shmem_deswap_pagevec(&pvec);
+			pagevec_remove_exceptionals(&pvec);
 			pagevec_release(&pvec);
 			break;
 		}
@@ -571,7 +507,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			}
 			unlock_page(page);
 		}
-		shmem_deswap_pagevec(&pvec);
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		index++;
@@ -1079,7 +1015,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		return -EFBIG;
 repeat:
 	swap.val = 0;
-	page = find_lock_page(mapping, index);
+	page = __find_lock_page(mapping, index);
 	if (radix_tree_exceptional_entry(page)) {
 		swap = radix_to_swp_entry(page);
 		page = NULL;
@@ -1416,6 +1352,11 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
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
@@ -1728,7 +1669,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 	pagevec_init(&pvec, 0);
 	pvec.nr = 1;		/* start small: we may be there already */
 	while (!done) {
-		pvec.nr = shmem_find_get_pages_and_swap(mapping, index,
+		pvec.nr = __find_get_pages(mapping, index,
 					pvec.nr, pvec.pages, indices);
 		if (!pvec.nr) {
 			if (whence == SEEK_DATA)
@@ -1755,7 +1696,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 				break;
 			}
 		}
-		shmem_deswap_pagevec(&pvec);
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		pvec.nr = PAGEVEC_SIZE;
 		cond_resched();
diff --git a/mm/swap.c b/mm/swap.c
index 8a529a0..37bfe2d 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -816,6 +816,26 @@ void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
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
index c75b736..d6ec30c 100644
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
@@ -206,31 +222,36 @@ void truncate_inode_pages_range(struct address_space *mapping,
 {
 	const pgoff_t start = (lstart + PAGE_CACHE_SIZE-1) >> PAGE_CACHE_SHIFT;
 	const unsigned partial = lstart & (PAGE_CACHE_SIZE - 1);
+	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
 	pgoff_t index;
 	pgoff_t end;
 	int i;
 
 	cleancache_invalidate_inode(mapping);
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
@@ -241,6 +262,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
@@ -260,14 +282,15 @@ void truncate_inode_pages_range(struct address_space *mapping,
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
@@ -276,16 +299,22 @@ void truncate_inode_pages_range(struct address_space *mapping,
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
@@ -328,6 +357,7 @@ EXPORT_SYMBOL(truncate_inode_pages);
 unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		pgoff_t start, pgoff_t end)
 {
+	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
 	pgoff_t index = start;
 	unsigned long ret;
@@ -343,17 +373,23 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
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
@@ -367,6 +403,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 				deactivate_page(page);
 			count += ret;
 		}
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
@@ -434,6 +471,7 @@ static int do_launder_page(struct address_space *mapping, struct page *page)
 int invalidate_inode_pages2_range(struct address_space *mapping,
 				  pgoff_t start, pgoff_t end)
 {
+	pgoff_t indices[PAGEVEC_SIZE];
 	struct pagevec pvec;
 	pgoff_t index;
 	int i;
@@ -444,17 +482,23 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
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
@@ -492,6 +536,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 				ret = ret2;
 			unlock_page(page);
 		}
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 		cond_resched();
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
