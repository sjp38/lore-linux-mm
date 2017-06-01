Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1366B6B0390
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 05:33:19 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b84so8666848wmh.0
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 02:33:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si34167776wmh.96.2017.06.01.02.33.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 02:33:17 -0700 (PDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 29/35] mm: Make pagevec_lookup_entries() update index
Date: Thu,  1 Jun 2017 11:32:39 +0200
Message-Id: <20170601093245.29238-30-jack@suse.cz>
In-Reply-To: <20170601093245.29238-1-jack@suse.cz>
References: <20170601093245.29238-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>, David Howells <dhowells@redhat.com>, linux-afs@lists.infradead.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com, Jaegeuk Kim <jaegeuk@kernel.org>, linux-f2fs-devel@lists.sourceforge.net, tytso@mit.edu, linux-ext4@vger.kernel.org, Ilya Dryomov <idryomov@gmail.com>, "Yan, Zheng" <zyan@redhat.com>, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, David Sterba <dsterba@suse.com>, "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>, Jan Kara <jack@suse.cz>

Make pagevec_lookup_entries() (and underlying find_get_entries()) update
index to the next page where iteration should continue. This is mostly
for consistency with pagevec_lookup() and future
pagevec_lookup_entries_range().

Signed-off-by: Jan Kara <jack@suse.cz>
---
 include/linux/pagemap.h |  2 +-
 include/linux/pagevec.h |  2 +-
 mm/filemap.c            | 11 ++++++---
 mm/shmem.c              | 57 +++++++++++++++++++++++--------------------
 mm/swap.c               |  4 +--
 mm/truncate.c           | 65 +++++++++++++++++++++++--------------------------
 6 files changed, 72 insertions(+), 69 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index a2d3534a514f..283d191c18be 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -333,7 +333,7 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
 struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
-unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
+unsigned find_get_entries(struct address_space *mapping, pgoff_t *start,
 			  unsigned int nr_entries, struct page **entries,
 			  pgoff_t *indices);
 unsigned find_get_pages_range(struct address_space *mapping, pgoff_t *start,
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index f3f2b9690764..3798c142338d 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -24,7 +24,7 @@ void __pagevec_release(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
 unsigned pagevec_lookup_entries(struct pagevec *pvec,
 				struct address_space *mapping,
-				pgoff_t start, unsigned nr_entries,
+				pgoff_t *start, unsigned nr_entries,
 				pgoff_t *indices);
 void pagevec_remove_exceptionals(struct pagevec *pvec);
 unsigned pagevec_lookup_range(struct pagevec *pvec,
diff --git a/mm/filemap.c b/mm/filemap.c
index 910f2e39fef2..de12b7355821 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1373,11 +1373,11 @@ EXPORT_SYMBOL(pagecache_get_page);
  * Any shadow entries of evicted pages, or swap entries from
  * shmem/tmpfs, are included in the returned array.
  *
- * find_get_entries() returns the number of pages and shadow entries
- * which were found.
+ * find_get_entries() returns the number of pages and shadow entries which were
+ * found. It also updates @start to index the next page for the traversal.
  */
 unsigned find_get_entries(struct address_space *mapping,
-			  pgoff_t start, unsigned int nr_entries,
+			  pgoff_t *start, unsigned int nr_entries,
 			  struct page **entries, pgoff_t *indices)
 {
 	void **slot;
@@ -1388,7 +1388,7 @@ unsigned find_get_entries(struct address_space *mapping,
 		return 0;
 
 	rcu_read_lock();
-	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, *start) {
 		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
@@ -1429,6 +1429,9 @@ unsigned find_get_entries(struct address_space *mapping,
 			break;
 	}
 	rcu_read_unlock();
+
+	if (ret)
+		*start = indices[ret - 1] + 1;
 	return ret;
 }
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 8a6fddec27a1..f9c4afbdd70c 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -768,26 +768,25 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index < end) {
-		if (!pagevec_lookup_entries(&pvec, mapping, index,
+		if (!pagevec_lookup_entries(&pvec, mapping, &index,
 				min(end - index, (pgoff_t)PAGEVEC_SIZE),
 				indices))
 			break;
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			index = indices[i];
-			if (index >= end)
+			if (indices[i] >= end)
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
 				if (unfalloc)
 					continue;
 				nr_swaps_freed += !shmem_free_swap(mapping,
-								index, page);
+							indices[i], page);
 				continue;
 			}
 
-			VM_BUG_ON_PAGE(page_to_pgoff(page) != index, page);
+			VM_BUG_ON_PAGE(page_to_pgoff(page) != indices[i], page);
 
 			if (!trylock_page(page))
 				continue;
@@ -798,7 +797,8 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				unlock_page(page);
 				continue;
 			} else if (PageTransHuge(page)) {
-				if (index == round_down(end, HPAGE_PMD_NR)) {
+				if (indices[i] ==
+						round_down(end, HPAGE_PMD_NR)) {
 					/*
 					 * Range ends in the middle of THP:
 					 * zero out the page
@@ -807,7 +807,8 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 					unlock_page(page);
 					continue;
 				}
-				index += HPAGE_PMD_NR - 1;
+				if (indices[i] + HPAGE_PMD_NR > index)
+					index = indices[i] + HPAGE_PMD_NR;
 				i += HPAGE_PMD_NR - 1;
 			}
 
@@ -823,7 +824,6 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
 	}
 
 	if (partial_start) {
@@ -856,13 +856,15 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 
 	index = start;
 	while (index < end) {
+		pgoff_t lookup_start = index;
+
 		cond_resched();
 
-		if (!pagevec_lookup_entries(&pvec, mapping, index,
+		if (!pagevec_lookup_entries(&pvec, mapping, &index,
 				min(end - index, (pgoff_t)PAGEVEC_SIZE),
 				indices)) {
 			/* If all gone or hole-punch or unfalloc, we're done */
-			if (index == start || end != -1)
+			if (lookup_start == start || end != -1)
 				break;
 			/* But if truncating, restart to make sure all gone */
 			index = start;
@@ -871,16 +873,16 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
-			index = indices[i];
-			if (index >= end)
+			if (indices[i] >= end)
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
 				if (unfalloc)
 					continue;
-				if (shmem_free_swap(mapping, index, page)) {
+				if (shmem_free_swap(mapping, indices[i],
+						    page)) {
 					/* Swap was replaced by page: retry */
-					index--;
+					index = indices[i];
 					break;
 				}
 				nr_swaps_freed++;
@@ -898,11 +900,12 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				 * of THP: don't need to look on these pages
 				 * again on !pvec.nr restart.
 				 */
-				if (index != round_down(end, HPAGE_PMD_NR))
+				if (indices[i] != round_down(end, HPAGE_PMD_NR))
 					start++;
 				continue;
 			} else if (PageTransHuge(page)) {
-				if (index == round_down(end, HPAGE_PMD_NR)) {
+				if (indices[i] ==
+						round_down(end, HPAGE_PMD_NR)) {
 					/*
 					 * Range ends in the middle of THP:
 					 * zero out the page
@@ -911,7 +914,8 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 					unlock_page(page);
 					continue;
 				}
-				index += HPAGE_PMD_NR - 1;
+				if (indices[i] + HPAGE_PMD_NR > index)
+					index = indices[i] + HPAGE_PMD_NR;
 				i += HPAGE_PMD_NR - 1;
 			}
 
@@ -923,7 +927,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				} else {
 					/* Page was replaced by swap: retry */
 					unlock_page(page);
-					index--;
+					index = indices[i];
 					break;
 				}
 			}
@@ -931,7 +935,6 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		}
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
-		index++;
 	}
 
 	spin_lock_irq(&info->lock);
@@ -2487,31 +2490,33 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 	pgoff_t indices[PAGEVEC_SIZE];
 	bool done = false;
 	int i;
+	pgoff_t last;
 
 	pagevec_init(&pvec, 0);
 	pvec.nr = 1;		/* start small: we may be there already */
 	while (!done) {
-		pvec.nr = find_get_entries(mapping, index,
+		last = index;
+		pvec.nr = find_get_entries(mapping, &index,
 					pvec.nr, pvec.pages, indices);
 		if (!pvec.nr) {
 			if (whence == SEEK_DATA)
-				index = end;
+				last = end;
 			break;
 		}
-		for (i = 0; i < pvec.nr; i++, index++) {
-			if (index < indices[i]) {
+		for (i = 0; i < pvec.nr; i++, last++) {
+			if (last < indices[i]) {
 				if (whence == SEEK_HOLE) {
 					done = true;
 					break;
 				}
-				index = indices[i];
+				last = indices[i];
 			}
 			page = pvec.pages[i];
 			if (page && !radix_tree_exceptional_entry(page)) {
 				if (!PageUptodate(page))
 					page = NULL;
 			}
-			if (index >= end ||
+			if (last >= end ||
 			    (page && whence == SEEK_DATA) ||
 			    (!page && whence == SEEK_HOLE)) {
 				done = true;
@@ -2523,7 +2528,7 @@ static pgoff_t shmem_seek_hole_data(struct address_space *mapping,
 		pvec.nr = PAGEVEC_SIZE;
 		cond_resched();
 	}
-	return index;
+	return last;
 }
 
 static loff_t shmem_file_llseek(struct file *file, loff_t offset, int whence)
diff --git a/mm/swap.c b/mm/swap.c
index dc63970f79b9..6ba3dab6e905 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -906,11 +906,11 @@ EXPORT_SYMBOL(__pagevec_lru_add);
  * not-present entries.
  *
  * pagevec_lookup_entries() returns the number of entries which were
- * found.
+ * found. It also updates @start to index the next page for the traversal.
  */
 unsigned pagevec_lookup_entries(struct pagevec *pvec,
 				struct address_space *mapping,
-				pgoff_t start, unsigned nr_pages,
+				pgoff_t *start, unsigned nr_pages,
 				pgoff_t *indices)
 {
 	pvec->nr = find_get_entries(mapping, start, nr_pages,
diff --git a/mm/truncate.c b/mm/truncate.c
index 2330223841fb..9efc82f18b74 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -289,26 +289,25 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index < end && pagevec_lookup_entries(&pvec, mapping, index,
+	while (index < end && pagevec_lookup_entries(&pvec, mapping, &index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE),
 			indices)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
-			index = indices[i];
-			if (index >= end)
+			if (indices[i] >= end)
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
-				truncate_exceptional_entry(mapping, index,
+				truncate_exceptional_entry(mapping, indices[i],
 							   page);
 				continue;
 			}
 
 			if (!trylock_page(page))
 				continue;
-			WARN_ON(page_to_index(page) != index);
+			WARN_ON(page_to_index(page) != indices[i]);
 			if (PageWriteback(page)) {
 				unlock_page(page);
 				continue;
@@ -319,7 +318,6 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
 	}
 
 	if (partial_start) {
@@ -363,17 +361,19 @@ void truncate_inode_pages_range(struct address_space *mapping,
 
 	index = start;
 	for ( ; ; ) {
+		pgoff_t lookup_start = index;
+
 		cond_resched();
-		if (!pagevec_lookup_entries(&pvec, mapping, index,
+		if (!pagevec_lookup_entries(&pvec, mapping, &index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE), indices)) {
 			/* If all gone from start onwards, we're done */
-			if (index == start)
+			if (lookup_start == start)
 				break;
 			/* Otherwise restart to make sure all gone */
 			index = start;
 			continue;
 		}
-		if (index == start && indices[0] >= end) {
+		if (lookup_start == start && indices[0] >= end) {
 			/* All gone out of hole to be punched, we're done */
 			pagevec_remove_exceptionals(&pvec);
 			pagevec_release(&pvec);
@@ -383,28 +383,26 @@ void truncate_inode_pages_range(struct address_space *mapping,
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
-			index = indices[i];
-			if (index >= end) {
+			if (indices[i] >= end) {
 				/* Restart punch to make sure all gone */
-				index = start - 1;
+				index = start;
 				break;
 			}
 
 			if (radix_tree_exceptional_entry(page)) {
-				truncate_exceptional_entry(mapping, index,
+				truncate_exceptional_entry(mapping, indices[i],
 							   page);
 				continue;
 			}
 
 			lock_page(page);
-			WARN_ON(page_to_index(page) != index);
+			WARN_ON(page_to_index(page) != indices[i]);
 			wait_on_page_writeback(page);
 			truncate_inode_page(mapping, page);
 			unlock_page(page);
 		}
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
-		index++;
 	}
 
 out:
@@ -501,44 +499,44 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 	int i;
 
 	pagevec_init(&pvec, 0);
-	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
+	while (index <= end && pagevec_lookup_entries(&pvec, mapping, &index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
-			index = indices[i];
-			if (index > end)
+			if (indices[i] > end)
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
-				invalidate_exceptional_entry(mapping, index,
-							     page);
+				invalidate_exceptional_entry(mapping,
+							     indices[i], page);
 				continue;
 			}
 
 			if (!trylock_page(page))
 				continue;
 
-			WARN_ON(page_to_index(page) != index);
+			WARN_ON(page_to_index(page) != indices[i]);
 
 			/* Middle of THP: skip */
 			if (PageTransTail(page)) {
 				unlock_page(page);
 				continue;
 			} else if (PageTransHuge(page)) {
-				index += HPAGE_PMD_NR - 1;
-				i += HPAGE_PMD_NR - 1;
+				if (index < indices[i] + HPAGE_PMD_NR)
+					index = indices[i] + HPAGE_PMD_NR;
 				/*
 				 * 'end' is in the middle of THP. Don't
 				 * invalidate the page as the part outside of
 				 * 'end' could be still useful.
 				 */
-				if (index > end) {
+				if (indices[i] + HPAGE_PMD_NR - 1 > end) {
 					unlock_page(page);
-					continue;
+					break;
 				}
+				i += HPAGE_PMD_NR - 1;
 			}
 
 			ret = invalidate_inode_page(page);
@@ -554,7 +552,6 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
 	}
 	return count;
 }
@@ -632,26 +629,25 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 
 	pagevec_init(&pvec, 0);
 	index = start;
-	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
+	while (index <= end && pagevec_lookup_entries(&pvec, mapping, &index,
 			min(end - index, (pgoff_t)PAGEVEC_SIZE - 1) + 1,
 			indices)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
 			struct page *page = pvec.pages[i];
 
 			/* We rely upon deletion not changing page->index */
-			index = indices[i];
-			if (index > end)
+			if (indices[i] > end)
 				break;
 
 			if (radix_tree_exceptional_entry(page)) {
 				if (!invalidate_exceptional_entry2(mapping,
-								   index, page))
+							indices[i], page))
 					ret = -EBUSY;
 				continue;
 			}
 
 			lock_page(page);
-			WARN_ON(page_to_index(page) != index);
+			WARN_ON(page_to_index(page) != indices[i]);
 			if (page->mapping != mapping) {
 				unlock_page(page);
 				continue;
@@ -663,8 +659,8 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 					 * Zap the rest of the file in one hit.
 					 */
 					unmap_mapping_range(mapping,
-					   (loff_t)index << PAGE_SHIFT,
-					   (loff_t)(1 + end - index)
+					   (loff_t)indices[i] << PAGE_SHIFT,
+					   (loff_t)(1 + end - indices[i])
 							 << PAGE_SHIFT,
 							 0);
 					did_range_unmap = 1;
@@ -673,7 +669,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 					 * Just zap this page
 					 */
 					unmap_mapping_range(mapping,
-					   (loff_t)index << PAGE_SHIFT,
+					   (loff_t)indices[i] << PAGE_SHIFT,
 					   PAGE_SIZE, 0);
 				}
 			}
@@ -690,7 +686,6 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
 	}
 	/*
 	 * For DAX we invalidate page tables after invalidating radix tree.  We
-- 
2.12.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
