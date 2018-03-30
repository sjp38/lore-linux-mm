Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D28C26B005C
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 23:43:00 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v25so5708190pgn.20
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 20:43:00 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w129si5637664pfd.325.2018.03.29.20.42.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 29 Mar 2018 20:42:58 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v10 21/62] page cache: Convert page cache lookups to XArray
Date: Thu, 29 Mar 2018 20:42:04 -0700
Message-Id: <20180330034245.10462-22-willy@infradead.org>
In-Reply-To: <20180330034245.10462-1-willy@infradead.org>
References: <20180330034245.10462-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

Introduce page_cache_pin() to factor out the common logic between the
various lookup routines:

find_get_entry
find_get_entries
find_get_pages_range
find_get_pages_contig
find_get_pages_range_tag
find_get_entries_tag
filemap_map_pages

By using the xa_state to control the iteration, we can remove most of
the gotos and just use the normal break/continue loop control flow.

Also convert the regression1 read-side to XArray since that simulates
the functions being modified here.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/pagemap.h                |   6 +-
 mm/filemap.c                           | 380 +++++++++------------------------
 tools/testing/radix-tree/regression1.c |  68 +++---
 3 files changed, 129 insertions(+), 325 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 2f5d2d3ebaac..442977811b59 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -363,17 +363,17 @@ static inline unsigned find_get_pages(struct address_space *mapping,
 unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
 			       unsigned int nr_pages, struct page **pages);
 unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
-			pgoff_t end, int tag, unsigned int nr_pages,
+			pgoff_t end, xa_tag_t tag, unsigned int nr_pages,
 			struct page **pages);
 static inline unsigned find_get_pages_tag(struct address_space *mapping,
-			pgoff_t *index, int tag, unsigned int nr_pages,
+			pgoff_t *index, xa_tag_t tag, unsigned int nr_pages,
 			struct page **pages)
 {
 	return find_get_pages_range_tag(mapping, index, (pgoff_t)-1, tag,
 					nr_pages, pages);
 }
 unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
-			int tag, unsigned int nr_entries,
+			xa_tag_t tag, unsigned int nr_entries,
 			struct page **entries, pgoff_t *indices);
 
 struct page *grab_cache_page_write_begin(struct address_space *mapping,
diff --git a/mm/filemap.c b/mm/filemap.c
index bdda1beda932..5a6c7c874d45 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1374,6 +1374,32 @@ pgoff_t page_cache_prev_gap(struct address_space *mapping,
 }
 EXPORT_SYMBOL(page_cache_prev_gap);
 
+/*
+ * page_cache_pin() - Try to pin a page in the page cache.
+ * @xas: The XArray operation state.
+ * @pagep: The page which has been previously found at this location.
+ *
+ * On success, the page has an elevated refcount, but is not locked.
+ * This implements the lockless pagecache protocol as described in
+ * include/linux/pagemap.h; see page_cache_get_speculative().
+ *
+ * Return: True if the page is still in the cache.
+ */
+static bool page_cache_pin(struct xa_state *xas, struct page *page)
+{
+	struct page *head = compound_head(page);
+	bool got = page_cache_get_speculative(head);
+
+	if (likely(got && (xas_reload(xas) == page) &&
+						(compound_head(page) == head)))
+		return true;
+
+	if (got)
+		put_page(head);
+	xas_reset(xas);
+	return false;
+}
+
 /**
  * find_get_entry - find and get a page cache entry
  * @mapping: the address_space to search
@@ -1389,51 +1415,21 @@ EXPORT_SYMBOL(page_cache_prev_gap);
  */
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
-	void **pagep;
-	struct page *head, *page;
+	XA_STATE(xas, &mapping->i_pages, offset);
+	struct page *page;
 
 	rcu_read_lock();
-repeat:
-	page = NULL;
-	pagep = radix_tree_lookup_slot(&mapping->i_pages, offset);
-	if (pagep) {
-		page = radix_tree_deref_slot(pagep);
-		if (unlikely(!page))
-			goto out;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page))
-				goto repeat;
-			/*
-			 * A shadow entry of a recently evicted page,
-			 * or a swap entry from shmem/tmpfs.  Return
-			 * it without attempting to raise page count.
-			 */
-			goto out;
-		}
-
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
+	do {
+		page = xas_load(&xas);
+		if (xas_retry(&xas, page))
+			continue;
+		if (!page || xa_is_value(page))
+			break;
+		if (!page_cache_pin(&xas, page))
+			continue;
+	} while (0);
 
-		/*
-		 * Has the page moved?
-		 * This is part of the lockless pagecache protocol. See
-		 * include/linux/pagemap.h for details.
-		 */
-		if (unlikely(page != *pagep)) {
-			put_page(head);
-			goto repeat;
-		}
-	}
-out:
 	rcu_read_unlock();
-
 	return page;
 }
 EXPORT_SYMBOL(find_get_entry);
@@ -1460,7 +1456,7 @@ struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset)
 
 repeat:
 	page = find_get_entry(mapping, offset);
-	if (page && !radix_tree_exception(page)) {
+	if (page && !xa_is_value(page)) {
 		lock_page(page);
 		/* Has the page been truncated? */
 		if (unlikely(page_mapping(page) != mapping)) {
@@ -1593,50 +1589,21 @@ unsigned find_get_entries(struct address_space *mapping,
 			  pgoff_t start, unsigned int nr_entries,
 			  struct page **entries, pgoff_t *indices)
 {
-	void **slot;
+	XA_STATE(xas, &mapping->i_pages, start);
+	struct page *page;
 	unsigned int ret = 0;
-	struct radix_tree_iter iter;
 
 	if (!nr_entries)
 		return 0;
 
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, &mapping->i_pages, &iter, start) {
-		struct page *head, *page;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		if (unlikely(!page))
+	xas_for_each(&xas, page, ULONG_MAX) {
+		if (xas_retry(&xas, page))
+			continue;
+		if (!xa_is_value(page) && !page_cache_pin(&xas, page))
 			continue;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				slot = radix_tree_iter_retry(&iter);
-				continue;
-			}
-			/*
-			 * A shadow entry of a recently evicted page, a swap
-			 * entry from shmem/tmpfs or a DAX entry.  Return it
-			 * without attempting to raise page count.
-			 */
-			goto export;
-		}
-
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
 
-		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			put_page(head);
-			goto repeat;
-		}
-export:
-		indices[ret] = iter.index;
+		indices[ret] = xas.xa_index;
 		entries[ret] = page;
 		if (++ret == nr_entries)
 			break;
@@ -1670,56 +1637,26 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
 			      pgoff_t end, unsigned int nr_pages,
 			      struct page **pages)
 {
-	struct radix_tree_iter iter;
-	void **slot;
+	XA_STATE(xas, &mapping->i_pages, *start);
+	struct page *page;
 	unsigned ret = 0;
 
 	if (unlikely(!nr_pages))
 		return 0;
 
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, &mapping->i_pages, &iter, *start) {
-		struct page *head, *page;
-
-		if (iter.index > end)
-			break;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		if (unlikely(!page))
+	xas_for_each(&xas, page, end) {
+		if (xas_retry(&xas, page))
 			continue;
-
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				slot = radix_tree_iter_retry(&iter);
-				continue;
-			}
-			/*
-			 * A shadow entry of a recently evicted page,
-			 * or a swap entry from shmem/tmpfs.  Skip
-			 * over it.
-			 */
+		/* Skip over shadow or swap entries */
+		if (xa_is_value(page))
+			continue;
+		if (!page_cache_pin(&xas, page))
 			continue;
-		}
-
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
-		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			put_page(head);
-			goto repeat;
-		}
 
 		pages[ret] = page;
 		if (++ret == nr_pages) {
-			*start = pages[ret - 1]->index + 1;
+			*start = page->index + 1;
 			goto out;
 		}
 	}
@@ -1727,7 +1664,7 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
 	/*
 	 * We come here when there is no page beyond @end. We take care to not
 	 * overflow the index @start as it confuses some of the callers. This
-	 * breaks the iteration when there is page at index -1 but that is
+	 * breaks the iteration when there is a page at index -1 but that is
 	 * already broken anyway.
 	 */
 	if (end == (pgoff_t)-1)
@@ -1755,57 +1692,28 @@ unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
 unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 			       unsigned int nr_pages, struct page **pages)
 {
-	struct radix_tree_iter iter;
-	void **slot;
+	XA_STATE(xas, &mapping->i_pages, index);
+	struct page *page;
 	unsigned int ret = 0;
 
 	if (unlikely(!nr_pages))
 		return 0;
 
 	rcu_read_lock();
-	radix_tree_for_each_contig(slot, &mapping->i_pages, &iter, index) {
-		struct page *head, *page;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		/* The hole, there no reason to continue */
-		if (unlikely(!page))
-			break;
-
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				slot = radix_tree_iter_retry(&iter);
-				continue;
-			}
-			/*
-			 * A shadow entry of a recently evicted page,
-			 * or a swap entry from shmem/tmpfs.  Stop
-			 * looking for contiguous pages.
-			 */
+	for (page = xas_load(&xas); page; page = xas_next(&xas)) {
+		if (xas_retry(&xas, page))
+			continue;
+		if (xa_is_value(page))
 			break;
-		}
-
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
-		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			put_page(head);
-			goto repeat;
-		}
+		if (!page_cache_pin(&xas, page))
+			continue;
 
 		/*
 		 * must check mapping and index after taking the ref.
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page_to_pgoff(page) != iter.index) {
+		if (!page->mapping || page_to_pgoff(page) != xas.xa_index) {
 			put_page(page);
 			break;
 		}
@@ -1832,74 +1740,42 @@ EXPORT_SYMBOL(find_get_pages_contig);
  * @tag.   We update @index to index the next page for the traversal.
  */
 unsigned find_get_pages_range_tag(struct address_space *mapping, pgoff_t *index,
-			pgoff_t end, int tag, unsigned int nr_pages,
+			pgoff_t end, xa_tag_t tag, unsigned int nr_pages,
 			struct page **pages)
 {
-	struct radix_tree_iter iter;
-	void **slot;
+	XA_STATE(xas, &mapping->i_pages, *index);
+	struct page *page;
 	unsigned ret = 0;
 
 	if (unlikely(!nr_pages))
 		return 0;
 
 	rcu_read_lock();
-	radix_tree_for_each_tagged(slot, &mapping->i_pages, &iter, *index, tag) {
-		struct page *head, *page;
-
-		if (iter.index > end)
-			break;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		if (unlikely(!page))
+	xas_for_each_tag(&xas, page, end, tag) {
+		if (xas_retry(&xas, page))
 			continue;
-
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				slot = radix_tree_iter_retry(&iter);
-				continue;
-			}
-			/*
-			 * A shadow entry of a recently evicted page.
-			 *
-			 * Those entries should never be tagged, but
-			 * this tree walk is lockless and the tags are
-			 * looked up in bulk, one radix tree node at a
-			 * time, so there is a sizable window for page
-			 * reclaim to evict a page we saw tagged.
-			 *
-			 * Skip over it.
-			 */
+		/*
+		 * Shadow entries should never be tagged, but this iteration
+		 * is lockless so there is a window for page reclaim to evict
+		 * a page we saw tagged.  Skip over it.
+		 */
+		if (xa_is_value(page))
+			continue;
+		if (!page_cache_pin(&xas, page))
 			continue;
-		}
-
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
-		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			put_page(head);
-			goto repeat;
-		}
 
 		pages[ret] = page;
 		if (++ret == nr_pages) {
-			*index = pages[ret - 1]->index + 1;
+			*index = page->index + 1;
 			goto out;
 		}
 	}
 
 	/*
-	 * We come here when we got at @end. We take care to not overflow the
+	 * We come here when we got to @end. We take care to not overflow the
 	 * index @index as it confuses some of the callers. This breaks the
-	 * iteration when there is page at index -1 but that is already broken
-	 * anyway.
+	 * iteration when there is a page at index -1 but that is already
+	 * broken anyway.
 	 */
 	if (end == (pgoff_t)-1)
 		*index = (pgoff_t)-1;
@@ -1925,54 +1801,24 @@ EXPORT_SYMBOL(find_get_pages_range_tag);
  * @tag.
  */
 unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
-			int tag, unsigned int nr_entries,
+			xa_tag_t tag, unsigned int nr_entries,
 			struct page **entries, pgoff_t *indices)
 {
-	void **slot;
+	XA_STATE(xas, &mapping->i_pages, start);
+	struct page *page;
 	unsigned int ret = 0;
-	struct radix_tree_iter iter;
 
 	if (!nr_entries)
 		return 0;
 
 	rcu_read_lock();
-	radix_tree_for_each_tagged(slot, &mapping->i_pages, &iter, start, tag) {
-		struct page *head, *page;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		if (unlikely(!page))
+	xas_for_each_tag(&xas, page, ULONG_MAX, tag) {
+		if (xas_retry(&xas, page))
+			continue;
+		if (!xa_is_value(page) && !page_cache_pin(&xas, page))
 			continue;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				slot = radix_tree_iter_retry(&iter);
-				continue;
-			}
-
-			/*
-			 * A shadow entry of a recently evicted page, a swap
-			 * entry from shmem/tmpfs or a DAX entry.  Return it
-			 * without attempting to raise page count.
-			 */
-			goto export;
-		}
-
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
 
-		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			put_page(head);
-			goto repeat;
-		}
-export:
-		indices[ret] = iter.index;
+		indices[ret] = xas.xa_index;
 		entries[ret] = page;
 		if (++ret == nr_entries)
 			break;
@@ -2581,45 +2427,21 @@ EXPORT_SYMBOL(filemap_fault);
 void filemap_map_pages(struct vm_fault *vmf,
 		pgoff_t start_pgoff, pgoff_t end_pgoff)
 {
-	struct radix_tree_iter iter;
-	void **slot;
 	struct file *file = vmf->vma->vm_file;
 	struct address_space *mapping = file->f_mapping;
 	pgoff_t last_pgoff = start_pgoff;
 	unsigned long max_idx;
-	struct page *head, *page;
+	XA_STATE(xas, &mapping->i_pages, start_pgoff);
+	struct page *page;
 
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, &mapping->i_pages, &iter, start_pgoff) {
-		if (iter.index > end_pgoff)
-			break;
-repeat:
-		page = radix_tree_deref_slot(slot);
-		if (unlikely(!page))
-			goto next;
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				slot = radix_tree_iter_retry(&iter);
-				continue;
-			}
+	xas_for_each(&xas, page, end_pgoff) {
+		if (xas_retry(&xas, page))
+			continue;
+		if (xa_is_value(page))
 			goto next;
-		}
-
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
-		/* Has the page moved? */
-		if (unlikely(page != *slot)) {
-			put_page(head);
-			goto repeat;
-		}
+		if (!page_cache_pin(&xas, page))
+			continue;
 
 		if (!PageUptodate(page) ||
 				PageReadahead(page) ||
@@ -2638,10 +2460,10 @@ void filemap_map_pages(struct vm_fault *vmf,
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
 
-		vmf->address += (iter.index - last_pgoff) << PAGE_SHIFT;
+		vmf->address += (xas.xa_index - last_pgoff) << PAGE_SHIFT;
 		if (vmf->pte)
-			vmf->pte += iter.index - last_pgoff;
-		last_pgoff = iter.index;
+			vmf->pte += xas.xa_index - last_pgoff;
+		last_pgoff = xas.xa_index;
 		if (alloc_set_pte(vmf, NULL, page))
 			goto unlock;
 		unlock_page(page);
@@ -2654,8 +2476,6 @@ void filemap_map_pages(struct vm_fault *vmf,
 		/* Huge page is mapped? No need to proceed. */
 		if (pmd_trans_huge(*vmf->pmd))
 			break;
-		if (iter.index == end_pgoff)
-			break;
 	}
 	rcu_read_unlock();
 }
diff --git a/tools/testing/radix-tree/regression1.c b/tools/testing/radix-tree/regression1.c
index 0aece092f40e..cd84d7de45e6 100644
--- a/tools/testing/radix-tree/regression1.c
+++ b/tools/testing/radix-tree/regression1.c
@@ -58,7 +58,7 @@ static struct page *page_alloc(void)
 	struct page *p;
 	p = malloc(sizeof(struct page));
 	p->count = 1;
-	p->index = 1;
+	p->index = (unsigned long)p;
 	pthread_mutex_init(&p->lock, NULL);
 
 	return p;
@@ -77,53 +77,37 @@ static void page_free(struct page *p)
 	call_rcu(&p->rcu, page_rcu_free);
 }
 
+static bool page_cache_pin(struct xa_state *xas, struct page *page)
+{
+	pthread_mutex_lock(&page->lock);
+	if (!page->count) {
+		pthread_mutex_unlock(&page->lock);
+		goto fail;
+	}
+	/* don't actually update page refcount */
+	pthread_mutex_unlock(&page->lock);
+
+	/* Has the page moved? */
+	if (xas_reload(xas) == page)
+		return true;
+fail:
+	xas_reset(xas);
+	return false;
+}
+
 static unsigned find_get_pages(unsigned long start,
 			    unsigned int nr_pages, struct page **pages)
 {
-	unsigned int i;
-	unsigned int ret;
-	unsigned int nr_found;
+	XA_STATE(xas, &mt_tree, start);
+	struct page *page;
+	unsigned int ret = 0;
 
 	rcu_read_lock();
-restart:
-	nr_found = radix_tree_gang_lookup_slot(&mt_tree,
-				(void ***)pages, NULL, start, nr_pages);
-	ret = 0;
-	for (i = 0; i < nr_found; i++) {
-		struct page *page;
-repeat:
-		page = radix_tree_deref_slot((void **)pages[i]);
-		if (unlikely(!page))
+	xas_for_each(&xas, page, ULONG_MAX) {
+		if (xas_retry(&xas, page))
+			continue;
+		if (!page_cache_pin(&xas, page))
 			continue;
-
-		if (radix_tree_exception(page)) {
-			if (radix_tree_deref_retry(page)) {
-				/*
-				 * Transient condition which can only trigger
-				 * when entry at index 0 moves out of or back
-				 * to root: none yet gotten, safe to restart.
-				 */
-				assert((start | i) == 0);
-				goto restart;
-			}
-			/*
-			 * No exceptional entries are inserted in this test.
-			 */
-			assert(0);
-		}
-
-		pthread_mutex_lock(&page->lock);
-		if (!page->count) {
-			pthread_mutex_unlock(&page->lock);
-			goto repeat;
-		}
-		/* don't actually update page refcount */
-		pthread_mutex_unlock(&page->lock);
-
-		/* Has the page moved? */
-		if (unlikely(page != *((void **)pages[i]))) {
-			goto repeat;
-		}
 
 		pages[ret] = page;
 		ret++;
-- 
2.16.2
