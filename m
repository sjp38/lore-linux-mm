Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3218F6B0267
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 07:55:39 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id wk8so83633649pab.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 04:55:39 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id a68si39039746pfb.39.2016.09.15.04.55.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Sep 2016 04:55:36 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 07/41] mm, shmem: swich huge tmpfs to multi-order radix-tree entries
Date: Thu, 15 Sep 2016 14:54:49 +0300
Message-Id: <20160915115523.29737-8-kirill.shutemov@linux.intel.com>
In-Reply-To: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
References: <20160915115523.29737-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We would need to use multi-order radix-tree entires for ext4 and other
filesystems to have coherent view on tags (dirty/towrite) in the tree.

This patch converts huge tmpfs implementation to multi-order entries, so
we will be able to use the same code patch for all filesystems.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/filemap.c     | 320 +++++++++++++++++++++++++++++++++----------------------
 mm/huge_memory.c |  47 +++++---
 mm/khugepaged.c  |  26 ++---
 mm/shmem.c       |  36 ++-----
 4 files changed, 247 insertions(+), 182 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 8a287dfc5372..ac3a39b1fe6d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -114,7 +114,7 @@ static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
 	struct radix_tree_node *node;
-	int i, nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
+	int nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageTail(page), page);
@@ -132,36 +132,32 @@ static void page_cache_tree_delete(struct address_space *mapping,
 	}
 	mapping->nrpages -= nr;
 
-	for (i = 0; i < nr; i++) {
-		node = radix_tree_replace_clear_tags(&mapping->page_tree,
-				page->index + i, shadow);
-		if (!node) {
-			VM_BUG_ON_PAGE(nr != 1, page);
-			return;
-		}
+	node = radix_tree_replace_clear_tags(&mapping->page_tree,
+			page->index, shadow);
+	if (!node)
+		return;
 
-		workingset_node_pages_dec(node);
-		if (shadow)
-			workingset_node_shadows_inc(node);
-		else
-			if (__radix_tree_delete_node(&mapping->page_tree, node))
-				continue;
+	workingset_node_pages_dec(node);
+	if (shadow)
+		workingset_node_shadows_inc(node);
+	else
+		if (__radix_tree_delete_node(&mapping->page_tree, node))
+			return;
 
-		/*
-		 * Track node that only contains shadow entries. DAX mappings
-		 * contain no shadow entries and may contain other exceptional
-		 * entries so skip those.
-		 *
-		 * Avoid acquiring the list_lru lock if already tracked.
-		 * The list_empty() test is safe as node->private_list is
-		 * protected by mapping->tree_lock.
-		 */
-		if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
-				list_empty(&node->private_list)) {
-			node->private_data = mapping;
-			list_lru_add(&workingset_shadow_nodes,
-					&node->private_list);
-		}
+	/*
+	 * Track node that only contains shadow entries. DAX mappings
+	 * contain no shadow entries and may contain other exceptional
+	 * entries so skip those.
+	 *
+	 * Avoid acquiring the list_lru lock if already tracked.
+	 * The list_empty() test is safe as node->private_list is
+	 * protected by mapping->tree_lock.
+	 */
+	if (!dax_mapping(mapping) && !workingset_node_pages(node) &&
+			list_empty(&node->private_list)) {
+		node->private_data = mapping;
+		list_lru_add(&workingset_shadow_nodes,
+				&node->private_list);
 	}
 }
 
@@ -264,12 +260,7 @@ void delete_from_page_cache(struct page *page)
 	if (freepage)
 		freepage(page);
 
-	if (PageTransHuge(page) && !PageHuge(page)) {
-		page_ref_sub(page, HPAGE_PMD_NR);
-		VM_BUG_ON_PAGE(page_count(page) <= 0, page);
-	} else {
-		put_page(page);
-	}
+	put_page(page);
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
@@ -1073,7 +1064,7 @@ EXPORT_SYMBOL(page_cache_prev_hole);
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
 	void **pagep;
-	struct page *head, *page;
+	struct page *page;
 
 	rcu_read_lock();
 repeat:
@@ -1094,25 +1085,25 @@ repeat:
 			goto out;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto repeat;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
 		/*
 		 * Has the page moved?
 		 * This is part of the lockless pagecache protocol. See
 		 * include/linux/pagemap.h for details.
 		 */
 		if (unlikely(page != *pagep)) {
-			put_page(head);
+			put_page(page);
 			goto repeat;
 		}
+
+		/* For multi-order entries, find relevant subpage */
+		if (PageTransHuge(page)) {
+			VM_BUG_ON(offset - page->index < 0);
+			VM_BUG_ON(offset - page->index >= HPAGE_PMD_NR);
+			page += offset - page->index;
+		}
 	}
 out:
 	rcu_read_unlock();
@@ -1275,7 +1266,7 @@ unsigned find_get_entries(struct address_space *mapping,
 			  struct page **entries, pgoff_t *indices)
 {
 	void **slot;
-	unsigned int ret = 0;
+	unsigned int refs, ret = 0;
 	struct radix_tree_iter iter;
 
 	if (!nr_entries)
@@ -1283,7 +1274,10 @@ unsigned find_get_entries(struct address_space *mapping,
 
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		struct page *head, *page;
+		struct page *page;
+		unsigned long index = iter.index;
+		if (index < start)
+			index = start;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1301,26 +1295,38 @@ repeat:
 			goto export;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto repeat;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(head);
+			put_page(page);
 			goto repeat;
 		}
+
+		/* For multi-order entries, find relevant subpage */
+		if (PageTransHuge(page)) {
+			VM_BUG_ON(index - page->index < 0);
+			VM_BUG_ON(index - page->index >= HPAGE_PMD_NR);
+			page += index - page->index;
+		}
 export:
-		indices[ret] = iter.index;
+		indices[ret] = index;
 		entries[ret] = page;
 		if (++ret == nr_entries)
 			break;
+		if (radix_tree_exception(page) || !PageTransCompound(page))
+			continue;
+		for (refs = 0; ret < nr_entries &&
+				(index + 1) % HPAGE_PMD_NR;
+				ret++, refs++) {
+			indices[ret] = ++index;
+			entries[ret] = ++page;
+		}
+		if (refs)
+			page_ref_add(compound_head(page), refs);
+		if (ret == nr_entries)
+			break;
 	}
 	rcu_read_unlock();
 	return ret;
@@ -1347,14 +1353,17 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 {
 	struct radix_tree_iter iter;
 	void **slot;
-	unsigned ret = 0;
+	unsigned refs, ret = 0;
 
 	if (unlikely(!nr_pages))
 		return 0;
 
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		struct page *head, *page;
+		struct page *page;
+		unsigned long index = iter.index;
+		if (index < start)
+			index = start;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1373,25 +1382,35 @@ repeat:
 			continue;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto repeat;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(head);
+			put_page(page);
 			goto repeat;
 		}
 
+		/* For multi-order entries, find relevant subpage */
+		if (PageTransHuge(page)) {
+			VM_BUG_ON(index - page->index < 0);
+			VM_BUG_ON(index - page->index >= HPAGE_PMD_NR);
+			page += index - page->index;
+		}
+
 		pages[ret] = page;
 		if (++ret == nr_pages)
 			break;
+		if (!PageTransCompound(page))
+			continue;
+		for (refs = 0; ret < nr_pages &&
+				(index + 1) % HPAGE_PMD_NR;
+				ret++, refs++, index++)
+			pages[ret] = ++page;
+		if (refs)
+			page_ref_add(compound_head(page), refs);
+		if (ret == nr_pages)
+			break;
 	}
 
 	rcu_read_unlock();
@@ -1410,19 +1429,22 @@ repeat:
  *
  * find_get_pages_contig() returns the number of pages which were found.
  */
-unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
+unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t start,
 			       unsigned int nr_pages, struct page **pages)
 {
 	struct radix_tree_iter iter;
 	void **slot;
-	unsigned int ret = 0;
+	unsigned int refs, ret = 0;
 
 	if (unlikely(!nr_pages))
 		return 0;
 
 	rcu_read_lock();
-	radix_tree_for_each_contig(slot, &mapping->page_tree, &iter, index) {
-		struct page *head, *page;
+	radix_tree_for_each_contig(slot, &mapping->page_tree, &iter, start) {
+		struct page *page;
+		unsigned long index = iter.index;
+		if (index < start)
+			index = start;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		/* The hole, there no reason to continue */
@@ -1442,19 +1464,12 @@ repeat:
 			break;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto repeat;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(head);
+			put_page(page);
 			goto repeat;
 		}
 
@@ -1463,14 +1478,31 @@ repeat:
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page_to_pgoff(page) != iter.index) {
+		if (page->mapping == NULL || page_to_pgoff(page) != index) {
 			put_page(page);
 			break;
 		}
 
+		/* For multi-order entries, find relevant subpage */
+		if (PageTransHuge(page)) {
+			VM_BUG_ON(index - page->index < 0);
+			VM_BUG_ON(index - page->index >= HPAGE_PMD_NR);
+			page += index - page->index;
+		}
+
 		pages[ret] = page;
 		if (++ret == nr_pages)
 			break;
+		if (!PageTransCompound(page))
+			continue;
+		for (refs = 0; ret < nr_pages &&
+				(index + 1) % HPAGE_PMD_NR;
+				ret++, refs++, index++)
+			pages[ret] = ++page;
+		if (refs)
+			page_ref_add(compound_head(page), refs);
+		if (ret == nr_pages)
+			break;
 	}
 	rcu_read_unlock();
 	return ret;
@@ -1488,20 +1520,23 @@ EXPORT_SYMBOL(find_get_pages_contig);
  * Like find_get_pages, except we only return pages which are tagged with
  * @tag.   We update @index to index the next page for the traversal.
  */
-unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
+unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *indexp,
 			int tag, unsigned int nr_pages, struct page **pages)
 {
 	struct radix_tree_iter iter;
 	void **slot;
-	unsigned ret = 0;
+	unsigned refs, ret = 0;
 
 	if (unlikely(!nr_pages))
 		return 0;
 
 	rcu_read_lock();
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
-				   &iter, *index, tag) {
-		struct page *head, *page;
+				   &iter, *indexp, tag) {
+		struct page *page;
+		unsigned long index = iter.index;
+		if (index < *indexp)
+			index = *indexp;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1526,31 +1561,41 @@ repeat:
 			continue;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto repeat;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(head);
+			put_page(page);
 			goto repeat;
 		}
 
+		/* For multi-order entries, find relevant subpage */
+		if (PageTransHuge(page)) {
+			VM_BUG_ON(index - page->index < 0);
+			VM_BUG_ON(index - page->index >= HPAGE_PMD_NR);
+			page += index - page->index;
+		}
+
 		pages[ret] = page;
 		if (++ret == nr_pages)
 			break;
+		if (!PageTransCompound(page))
+			continue;
+		for (refs = 0; ret < nr_pages &&
+				(index + 1) % HPAGE_PMD_NR;
+				ret++, refs++, index++)
+			pages[ret] = ++page;
+		if (refs)
+			page_ref_add(compound_head(page), refs);
+		if (ret == nr_pages)
+			break;
 	}
 
 	rcu_read_unlock();
 
 	if (ret)
-		*index = pages[ret - 1]->index + 1;
+		*indexp = page_to_pgoff(pages[ret - 1]) + 1;
 
 	return ret;
 }
@@ -1573,7 +1618,7 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 			struct page **entries, pgoff_t *indices)
 {
 	void **slot;
-	unsigned int ret = 0;
+	unsigned int refs, ret = 0;
 	struct radix_tree_iter iter;
 
 	if (!nr_entries)
@@ -1582,7 +1627,10 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 	rcu_read_lock();
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
 				   &iter, start, tag) {
-		struct page *head, *page;
+		struct page *page;
+		unsigned long index = iter.index;
+		if (index < start)
+			index = start;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1601,26 +1649,38 @@ repeat:
 			goto export;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto repeat;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(head);
+			put_page(page);
 			goto repeat;
 		}
+
+		/* For multi-order entries, find relevant subpage */
+		if (PageTransHuge(page)) {
+			VM_BUG_ON(index - page->index < 0);
+			VM_BUG_ON(index - page->index >= HPAGE_PMD_NR);
+			page += index - page->index;
+		}
 export:
-		indices[ret] = iter.index;
+		indices[ret] = index;
 		entries[ret] = page;
 		if (++ret == nr_entries)
 			break;
+		if (radix_tree_exception(page) || !PageTransCompound(page))
+			continue;
+		for (refs = 0; ret < nr_entries &&
+				(index + 1) % HPAGE_PMD_NR;
+				ret++, refs++) {
+			indices[ret] = ++index;
+			entries[ret] = ++page;
+		}
+		if (refs)
+			page_ref_add(compound_head(page), refs);
+		if (ret == nr_entries)
+			break;
 	}
 	rcu_read_unlock();
 	return ret;
@@ -2202,12 +2262,15 @@ void filemap_map_pages(struct fault_env *fe,
 	struct address_space *mapping = file->f_mapping;
 	pgoff_t last_pgoff = start_pgoff;
 	loff_t size;
-	struct page *head, *page;
+	struct page *page;
 
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
 			start_pgoff) {
-		if (iter.index > end_pgoff)
+		unsigned long index = iter.index;
+		if (index < start_pgoff)
+			index = start_pgoff;
+		if (index > end_pgoff)
 			break;
 repeat:
 		page = radix_tree_deref_slot(slot);
@@ -2218,25 +2281,26 @@ repeat:
 				slot = radix_tree_iter_retry(&iter);
 				continue;
 			}
+			page = NULL;
 			goto next;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
+		if (!page_cache_get_speculative(page))
 			goto repeat;
 
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
-			goto repeat;
-		}
-
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(head);
+			put_page(page);
 			goto repeat;
 		}
 
+		/* For multi-order entries, find relevant subpage */
+		if (PageTransHuge(page)) {
+			VM_BUG_ON(index - page->index < 0);
+			VM_BUG_ON(index - page->index >= HPAGE_PMD_NR);
+			page += index - page->index;
+		}
+
 		if (!PageUptodate(page) ||
 				PageReadahead(page) ||
 				PageHWPoison(page))
@@ -2244,20 +2308,20 @@ repeat:
 		if (!trylock_page(page))
 			goto skip;
 
-		if (page->mapping != mapping || !PageUptodate(page))
+		if (page_mapping(page) != mapping || !PageUptodate(page))
 			goto unlock;
 
 		size = round_up(i_size_read(mapping->host), PAGE_SIZE);
-		if (page->index >= size >> PAGE_SHIFT)
+		if (compound_head(page)->index >= size >> PAGE_SHIFT)
 			goto unlock;
 
 		if (file->f_ra.mmap_miss > 0)
 			file->f_ra.mmap_miss--;
 
-		fe->address += (iter.index - last_pgoff) << PAGE_SHIFT;
+		fe->address += (index - last_pgoff) << PAGE_SHIFT;
 		if (fe->pte)
-			fe->pte += iter.index - last_pgoff;
-		last_pgoff = iter.index;
+			fe->pte += index - last_pgoff;
+		last_pgoff = index;
 		if (alloc_set_pte(fe, NULL, page))
 			goto unlock;
 		unlock_page(page);
@@ -2270,8 +2334,14 @@ next:
 		/* Huge page is mapped? No need to proceed. */
 		if (pmd_trans_huge(*fe->pmd))
 			break;
-		if (iter.index == end_pgoff)
+		if (index == end_pgoff)
 			break;
+		if (page && PageTransCompound(page) &&
+				(index & (HPAGE_PMD_NR - 1)) !=
+				HPAGE_PMD_NR - 1) {
+			index++;
+			goto repeat;
+		}
 	}
 	rcu_read_unlock();
 }
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a6abd76baa72..a6a25080469c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1824,6 +1824,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	struct page *head = compound_head(page);
 	struct zone *zone = page_zone(head);
 	struct lruvec *lruvec;
+	struct page *subpage;
 	pgoff_t end = -1;
 	int i;
 
@@ -1832,8 +1833,26 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	/* complete memcg works before add pages to LRU */
 	mem_cgroup_split_huge_fixup(head);
 
-	if (!PageAnon(page))
-		end = DIV_ROUND_UP(i_size_read(head->mapping->host), PAGE_SIZE);
+	if (!PageAnon(head)) {
+		struct address_space *mapping = head->mapping;
+		struct radix_tree_iter iter;
+		void **slot;
+
+		__dec_node_page_state(head, NR_SHMEM_THPS);
+
+		radix_tree_split(&mapping->page_tree, head->index, 0);
+		radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
+				head->index) {
+			if (iter.index >= head->index + HPAGE_PMD_NR)
+				break;
+			subpage = head + iter.index - head->index;
+			radix_tree_replace_slot(slot, subpage);
+			VM_BUG_ON_PAGE(compound_head(subpage) != head, subpage);
+		}
+		radix_tree_preload_end();
+
+		end = DIV_ROUND_UP(i_size_read(mapping->host), PAGE_SIZE);
+	}
 
 	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		__split_huge_page_tail(head, i, lruvec, list);
@@ -1862,7 +1881,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	unfreeze_page(head);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
-		struct page *subpage = head + i;
+		subpage = head + i;
 		if (subpage == page)
 			continue;
 		unlock_page(subpage);
@@ -2019,8 +2038,8 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			goto out;
 		}
 
-		/* Addidional pins from radix tree */
-		extra_pins = HPAGE_PMD_NR;
+		/* Addidional pin from radix tree */
+		extra_pins = 1;
 		anon_vma = NULL;
 		i_mmap_lock_read(mapping);
 	}
@@ -2042,6 +2061,12 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	if (mlocked)
 		lru_add_drain();
 
+	if (mapping && radix_tree_split_preload(HPAGE_PMD_ORDER, 0,
+				GFP_KERNEL)) {
+		ret = -ENOMEM;
+		goto unfreeze;
+	}
+
 	/* prevent PageLRU to go away from under us, and freeze lru stats */
 	spin_lock_irqsave(zone_lru_lock(page_zone(head)), flags);
 
@@ -2051,10 +2076,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 		spin_lock(&mapping->tree_lock);
 		pslot = radix_tree_lookup_slot(&mapping->page_tree,
 				page_index(head));
-		/*
-		 * Check if the head page is present in radix tree.
-		 * We assume all tail are present too, if head is there.
-		 */
+		/* Check if the page is present in radix tree */
 		if (radix_tree_deref_slot_protected(pslot,
 					&mapping->tree_lock) != head)
 			goto fail;
@@ -2069,8 +2091,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			pgdata->split_queue_len--;
 			list_del(page_deferred_list(head));
 		}
-		if (mapping)
-			__dec_node_page_state(page, NR_SHMEM_THPS);
 		spin_unlock(&pgdata->split_queue_lock);
 		__split_huge_page(page, list, flags);
 		ret = 0;
@@ -2084,9 +2104,12 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			BUG();
 		}
 		spin_unlock(&pgdata->split_queue_lock);
-fail:		if (mapping)
+fail:		if (mapping) {
 			spin_unlock(&mapping->tree_lock);
+			radix_tree_preload_end();
+		}
 		spin_unlock_irqrestore(zone_lru_lock(page_zone(head)), flags);
+unfreeze:
 		unfreeze_page(head);
 		ret = -EBUSY;
 	}
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 79c52d0061af..9929414b170c 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1348,10 +1348,8 @@ static void collapse_shmem(struct mm_struct *mm,
 			break;
 		}
 		nr_none += n;
-		for (; index < min(iter.index, end); index++) {
-			radix_tree_insert(&mapping->page_tree, index,
-					new_page + (index % HPAGE_PMD_NR));
-		}
+		for (; index < min(iter.index, end); index++)
+			radix_tree_insert(&mapping->page_tree, index, new_page);
 
 		/* We are done. */
 		if (index >= end)
@@ -1420,8 +1418,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		list_add_tail(&page->lru, &pagelist);
 
 		/* Finally, replace with the new page. */
-		radix_tree_replace_slot(slot,
-				new_page + (index % HPAGE_PMD_NR));
+		radix_tree_replace_slot(slot, new_page);
 
 		index++;
 		continue;
@@ -1438,24 +1435,17 @@ out_unlock:
 		break;
 	}
 
-	/*
-	 * Handle hole in radix tree at the end of the range.
-	 * This code only triggers if there's nothing in radix tree
-	 * beyond 'end'.
-	 */
-	if (result == SCAN_SUCCEED && index < end) {
+	if (result == SCAN_SUCCEED) {
 		int n = end - index;
 
-		if (!shmem_charge(mapping->host, n)) {
+		if (n && !shmem_charge(mapping->host, n)) {
 			result = SCAN_FAIL;
 			goto tree_locked;
 		}
-
-		for (; index < end; index++) {
-			radix_tree_insert(&mapping->page_tree, index,
-					new_page + (index % HPAGE_PMD_NR));
-		}
 		nr_none += n;
+
+		radix_tree_join(&mapping->page_tree, start,
+				HPAGE_PMD_ORDER, new_page);
 	}
 
 tree_locked:
diff --git a/mm/shmem.c b/mm/shmem.c
index ac3c35665ad7..ad47b131b2ef 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -540,33 +540,14 @@ static int shmem_add_to_page_cache(struct page *page,
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 	VM_BUG_ON(expected && PageTransHuge(page));
 
-	page_ref_add(page, nr);
+	get_page(page);
 	page->mapping = mapping;
 	page->index = index;
 
 	spin_lock_irq(&mapping->tree_lock);
-	if (PageTransHuge(page)) {
-		void __rcu **results;
-		pgoff_t idx;
-		int i;
-
-		error = 0;
-		if (radix_tree_gang_lookup_slot(&mapping->page_tree,
-					&results, &idx, index, 1) &&
-				idx < index + HPAGE_PMD_NR) {
-			error = -EEXIST;
-		}
-
-		if (!error) {
-			for (i = 0; i < HPAGE_PMD_NR; i++) {
-				error = radix_tree_insert(&mapping->page_tree,
-						index + i, page + i);
-				VM_BUG_ON(error);
-			}
-			count_vm_event(THP_FILE_ALLOC);
-		}
-	} else if (!expected) {
-		error = radix_tree_insert(&mapping->page_tree, index, page);
+	if (!expected) {
+		error = __radix_tree_insert(&mapping->page_tree, index,
+				compound_order(page), page);
 	} else {
 		error = shmem_radix_tree_replace(mapping, index, expected,
 								 page);
@@ -574,15 +555,17 @@ static int shmem_add_to_page_cache(struct page *page,
 
 	if (!error) {
 		mapping->nrpages += nr;
-		if (PageTransHuge(page))
+		if (PageTransHuge(page)) {
+			count_vm_event(THP_FILE_ALLOC);
 			__inc_node_page_state(page, NR_SHMEM_THPS);
+		}
 		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, nr);
 		__mod_node_page_state(page_pgdat(page), NR_SHMEM, nr);
 		spin_unlock_irq(&mapping->tree_lock);
 	} else {
 		page->mapping = NULL;
 		spin_unlock_irq(&mapping->tree_lock);
-		page_ref_sub(page, nr);
+		put_page(page);
 	}
 	return error;
 }
@@ -1734,8 +1717,7 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
 				PageTransHuge(page));
 		if (error)
 			goto unacct;
-		error = radix_tree_maybe_preload_order(gfp & GFP_RECLAIM_MASK,
-				compound_order(page));
+		error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, hindex,
 							NULL);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
