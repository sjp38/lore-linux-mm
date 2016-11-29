Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 174666B0266
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 06:23:27 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 17so254525109pfy.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 03:23:27 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id b34si30876221pli.224.2016.11.29.03.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Nov 2016 03:23:25 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv5 01/36] mm, shmem: swich huge tmpfs to multi-order radix-tree entries
Date: Tue, 29 Nov 2016 14:22:29 +0300
Message-Id: <20161129112304.90056-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
References: <20161129112304.90056-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We would need to use multi-order radix-tree entires for ext4 and other
filesystems to have coherent view on tags (dirty/towrite) in the tree.

This patch converts huge tmpfs implementation to multi-order entries, so
we will be able to use the same code patch for all filesystems.

We also change interface for page-cache lookup function:

  - functions that lookup for pages[1] would return subpages of THP
    relevant for requested indexes;

  - functions that lookup for entries[2] would return one entry per-THP
    and index will point to index of head page (basically, round down to
    HPAGE_PMD_NR);

This would provide balanced exposure of multi-order entires to the rest
of the kernel.

[1] find_get_pages(), pagecache_get_page(), pagevec_lookup(), etc.
[2] find_get_entry(), find_get_entries(), pagevec_lookup_entries(), etc.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/pagemap.h |   9 ++
 mm/filemap.c            | 236 ++++++++++++++++++++++++++----------------------
 mm/huge_memory.c        |  48 +++++++---
 mm/khugepaged.c         |  26 ++----
 mm/shmem.c              | 117 ++++++++++--------------
 mm/truncate.c           |  15 ++-
 6 files changed, 235 insertions(+), 216 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 7dbe9148b2f8..f88d69e2419d 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -332,6 +332,15 @@ static inline struct page *grab_cache_page_nowait(struct address_space *mapping,
 			mapping_gfp_mask(mapping));
 }
 
+static inline struct page *find_subpage(struct page *page, pgoff_t offset)
+{
+	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG_ON_PAGE(page->index > offset, page);
+	VM_BUG_ON_PAGE(page->index + (1 << compound_order(page)) < offset,
+			page);
+	return page - page->index + offset;
+}
+
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset);
 struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset);
 unsigned find_get_entries(struct address_space *mapping, pgoff_t start,
diff --git a/mm/filemap.c b/mm/filemap.c
index 235021e361eb..f8607ab7b7e4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -150,7 +150,9 @@ static int page_cache_tree_insert(struct address_space *mapping,
 static void page_cache_tree_delete(struct address_space *mapping,
 				   struct page *page, void *shadow)
 {
-	int i, nr;
+	struct radix_tree_node *node;
+	void **slot;
+	int nr;
 
 	/* hugetlb pages are represented by one entry in the radix tree */
 	nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
@@ -159,19 +161,12 @@ static void page_cache_tree_delete(struct address_space *mapping,
 	VM_BUG_ON_PAGE(PageTail(page), page);
 	VM_BUG_ON_PAGE(nr != 1 && shadow, page);
 
-	for (i = 0; i < nr; i++) {
-		struct radix_tree_node *node;
-		void **slot;
+	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
+	VM_BUG_ON_PAGE(!node && nr != 1, page);
 
-		__radix_tree_lookup(&mapping->page_tree, page->index + i,
-				    &node, &slot);
-
-		VM_BUG_ON_PAGE(!node && nr != 1, page);
-
-		radix_tree_clear_tags(&mapping->page_tree, node, slot);
-		__radix_tree_replace(&mapping->page_tree, node, slot, shadow,
-				     workingset_update_node, mapping);
-	}
+	radix_tree_clear_tags(&mapping->page_tree, node, slot);
+	__radix_tree_replace(&mapping->page_tree, node, slot, shadow,
+			workingset_update_node, mapping);
 
 	if (shadow) {
 		mapping->nrexceptional += nr;
@@ -285,12 +280,7 @@ void delete_from_page_cache(struct page *page)
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
 
@@ -1035,7 +1025,7 @@ EXPORT_SYMBOL(page_cache_prev_hole);
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
 	void **pagep;
-	struct page *head, *page;
+	struct page *page;
 
 	rcu_read_lock();
 repeat:
@@ -1056,15 +1046,8 @@ struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 			goto out;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
+		if (!page_cache_get_speculative(page))
 			goto repeat;
-		}
 
 		/*
 		 * Has the page moved?
@@ -1072,7 +1055,7 @@ struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 		 * include/linux/pagemap.h for details.
 		 */
 		if (unlikely(page != *pagep)) {
-			put_page(head);
+			put_page(page);
 			goto repeat;
 		}
 	}
@@ -1113,7 +1096,6 @@ struct page *find_lock_entry(struct address_space *mapping, pgoff_t offset)
 			put_page(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
 	}
 	return page;
 }
@@ -1170,7 +1152,6 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 			put_page(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page->index != offset, page);
 	}
 
 	if (page && (fgp_flags & FGP_ACCESSED))
@@ -1205,6 +1186,8 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		}
 	}
 
+	if (page)
+		page = find_subpage(page, offset);
 	return page;
 }
 EXPORT_SYMBOL(pagecache_get_page);
@@ -1245,7 +1228,7 @@ unsigned find_get_entries(struct address_space *mapping,
 
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		struct page *head, *page;
+		struct page *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1263,19 +1246,12 @@ unsigned find_get_entries(struct address_space *mapping,
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
 export:
@@ -1309,14 +1285,17 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
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
@@ -1335,25 +1314,35 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 			continue;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
+		if (!page_cache_get_speculative(page))
 			goto repeat;
-		}
 
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
@@ -1363,7 +1352,7 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
 /**
  * find_get_pages_contig - gang contiguous pagecache lookup
  * @mapping:	The address_space to search
- * @index:	The starting page index
+ * @start:	The starting page index
  * @nr_pages:	The maximum number of pages
  * @pages:	Where the resulting pages are placed
  *
@@ -1372,19 +1361,22 @@ unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
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
@@ -1404,19 +1396,12 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
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
 
@@ -1425,14 +1410,31 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
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
@@ -1442,7 +1444,7 @@ EXPORT_SYMBOL(find_get_pages_contig);
 /**
  * find_get_pages_tag - find and return pages that match @tag
  * @mapping:	the address_space to search
- * @index:	the starting page index
+ * @indexp:	the starting page index
  * @tag:	the tag index
  * @nr_pages:	the maximum number of pages
  * @pages:	where the resulting pages are placed
@@ -1450,20 +1452,23 @@ EXPORT_SYMBOL(find_get_pages_contig);
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
@@ -1488,31 +1493,41 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 			continue;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
+		if (!page_cache_get_speculative(page))
 			goto repeat;
-		}
 
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
@@ -1544,7 +1559,7 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 	rcu_read_lock();
 	radix_tree_for_each_tagged(slot, &mapping->page_tree,
 				   &iter, start, tag) {
-		struct page *head, *page;
+		struct page *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1563,19 +1578,12 @@ unsigned find_get_entries_tag(struct address_space *mapping, pgoff_t start,
 			goto export;
 		}
 
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			goto repeat;
-
-		/* The page was split under us? */
-		if (compound_head(page) != head) {
-			put_page(head);
+		if (!page_cache_get_speculative(page))
 			goto repeat;
-		}
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
-			put_page(head);
+			put_page(page);
 			goto repeat;
 		}
 export:
@@ -2173,12 +2181,15 @@ void filemap_map_pages(struct vm_fault *vmf,
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
@@ -2189,25 +2200,26 @@ void filemap_map_pages(struct vm_fault *vmf,
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
@@ -2215,20 +2227,20 @@ void filemap_map_pages(struct vm_fault *vmf,
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
 
-		vmf->address += (iter.index - last_pgoff) << PAGE_SHIFT;
+		vmf->address += (index - last_pgoff) << PAGE_SHIFT;
 		if (vmf->pte)
-			vmf->pte += iter.index - last_pgoff;
-		last_pgoff = iter.index;
+			vmf->pte += index - last_pgoff;
+		last_pgoff = index;
 		if (alloc_set_pte(vmf, NULL, page))
 			goto unlock;
 		unlock_page(page);
@@ -2241,8 +2253,14 @@ void filemap_map_pages(struct vm_fault *vmf,
 		/* Huge page is mapped? No need to proceed. */
 		if (pmd_trans_huge(*vmf->pmd))
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
index 0957e654b3c9..7680797b287e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1922,6 +1922,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	struct page *head = compound_head(page);
 	struct zone *zone = page_zone(head);
 	struct lruvec *lruvec;
+	struct page *subpage;
 	pgoff_t end = -1;
 	int i;
 
@@ -1930,8 +1931,27 @@ static void __split_huge_page(struct page *page, struct list_head *list,
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
+			radix_tree_replace_slot(&mapping->page_tree,
+					slot, subpage);
+			VM_BUG_ON_PAGE(compound_head(subpage) != head, subpage);
+		}
+		radix_tree_preload_end();
+
+		end = DIV_ROUND_UP(i_size_read(mapping->host), PAGE_SIZE);
+	}
 
 	for (i = HPAGE_PMD_NR - 1; i >= 1; i--) {
 		__split_huge_page_tail(head, i, lruvec, list);
@@ -1960,7 +1980,7 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 	unfreeze_page(head);
 
 	for (i = 0; i < HPAGE_PMD_NR; i++) {
-		struct page *subpage = head + i;
+		subpage = head + i;
 		if (subpage == page)
 			continue;
 		unlock_page(subpage);
@@ -2117,8 +2137,8 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			goto out;
 		}
 
-		/* Addidional pins from radix tree */
-		extra_pins = HPAGE_PMD_NR;
+		/* Addidional pin from radix tree */
+		extra_pins = 1;
 		anon_vma = NULL;
 		i_mmap_lock_read(mapping);
 	}
@@ -2140,6 +2160,12 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
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
 
@@ -2149,10 +2175,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
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
@@ -2167,8 +2190,6 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			pgdata->split_queue_len--;
 			list_del(page_deferred_list(head));
 		}
-		if (mapping)
-			__dec_node_page_state(page, NR_SHMEM_THPS);
 		spin_unlock(&pgdata->split_queue_lock);
 		__split_huge_page(page, list, flags);
 		ret = 0;
@@ -2182,9 +2203,12 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
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
index e32389a97030..7e9ec33d3575 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1368,10 +1368,8 @@ static void collapse_shmem(struct mm_struct *mm,
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
@@ -1443,8 +1441,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		list_add_tail(&page->lru, &pagelist);
 
 		/* Finally, replace with the new page. */
-		radix_tree_replace_slot(&mapping->page_tree, slot,
-				new_page + (index % HPAGE_PMD_NR));
+		radix_tree_replace_slot(&mapping->page_tree, slot, new_page);
 
 		slot = radix_tree_iter_resume(slot, &iter);
 		index++;
@@ -1462,24 +1459,17 @@ static void collapse_shmem(struct mm_struct *mm,
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
index 0dd83bbe44a8..183d2937157e 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -544,33 +544,14 @@ static int shmem_add_to_page_cache(struct page *page,
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
@@ -578,15 +559,17 @@ static int shmem_add_to_page_cache(struct page *page,
 
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
@@ -727,8 +710,9 @@ void shmem_unlock_mapping(struct address_space *mapping)
 					   PAGEVEC_SIZE, pvec.pages, indices);
 		if (!pvec.nr)
 			break;
-		index = indices[pvec.nr - 1] + 1;
 		pagevec_remove_exceptionals(&pvec);
+		index = indices[pvec.nr - 1] +
+			hpage_nr_pages(pvec.pages[pvec.nr - 1]);
 		check_move_unevictable_pages(pvec.pages, pvec.nr);
 		pagevec_release(&pvec);
 		cond_resched();
@@ -785,23 +769,25 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			if (!trylock_page(page))
 				continue;
 
-			if (PageTransTail(page)) {
-				/* Middle of THP: zero out the page */
-				clear_highpage(page);
-				unlock_page(page);
-				continue;
-			} else if (PageTransHuge(page)) {
+			if (PageTransHuge(page)) {
+				/* Range starts in the middle of THP */
+				if (start > page->index) {
+					pgoff_t i;
+					index += HPAGE_PMD_NR;
+					page += start - page->index;
+					for (i = start; i < index; i++, page++)
+						clear_highpage(page);
+					unlock_page(page - 1);
+					continue;
+				}
+
+				/* Range ends in the middle of THP */
 				if (index == round_down(end, HPAGE_PMD_NR)) {
-					/*
-					 * Range ends in the middle of THP:
-					 * zero out the page
-					 */
-					clear_highpage(page);
+					while (index++ < end)
+						clear_highpage(page++);
 					unlock_page(page);
 					continue;
 				}
-				index += HPAGE_PMD_NR - 1;
-				i += HPAGE_PMD_NR - 1;
 			}
 
 			if (!unfalloc || !PageUptodate(page)) {
@@ -814,9 +800,9 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			unlock_page(page);
 		}
 		pagevec_remove_exceptionals(&pvec);
+		index += pvec.nr ? hpage_nr_pages(pvec.pages[pvec.nr - 1]) : 1;
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
 	}
 
 	if (partial_start) {
@@ -874,8 +860,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 					continue;
 				if (shmem_free_swap(mapping, index, page)) {
 					/* Swap was replaced by page: retry */
-					index--;
-					break;
+					goto retry;
 				}
 				nr_swaps_freed++;
 				continue;
@@ -883,30 +868,24 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 
 			lock_page(page);
 
-			if (PageTransTail(page)) {
-				/* Middle of THP: zero out the page */
-				clear_highpage(page);
-				unlock_page(page);
-				/*
-				 * Partial thp truncate due 'start' in middle
-				 * of THP: don't need to look on these pages
-				 * again on !pvec.nr restart.
-				 */
-				if (index != round_down(end, HPAGE_PMD_NR))
-					start++;
-				continue;
-			} else if (PageTransHuge(page)) {
+			if (PageTransHuge(page)) {
+				/* Range starts in the middle of THP */
+				if (start > page->index) {
+					index += HPAGE_PMD_NR;
+					page += start - page->index;
+					while (start++ < index)
+						clear_highpage(page++);
+					unlock_page(page - 1);
+					continue;
+				}
+
+				/* Range ends in the middle of THP */
 				if (index == round_down(end, HPAGE_PMD_NR)) {
-					/*
-					 * Range ends in the middle of THP:
-					 * zero out the page
-					 */
-					clear_highpage(page);
+					while (index++ < end)
+						clear_highpage(page++);
 					unlock_page(page);
 					continue;
 				}
-				index += HPAGE_PMD_NR - 1;
-				i += HPAGE_PMD_NR - 1;
 			}
 
 			if (!unfalloc || !PageUptodate(page)) {
@@ -917,15 +896,18 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				} else {
 					/* Page was replaced by swap: retry */
 					unlock_page(page);
-					index--;
-					break;
+					goto retry;
 				}
 			}
 			unlock_page(page);
 		}
 		pagevec_remove_exceptionals(&pvec);
+		index += pvec.nr ? hpage_nr_pages(pvec.pages[pvec.nr - 1]) : 1;
+		pagevec_release(&pvec);
+		continue;
+retry:
+		pagevec_remove_exceptionals(&pvec);
 		pagevec_release(&pvec);
-		index++;
 	}
 
 	spin_lock_irq(&info->lock);
@@ -1762,8 +1744,7 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
 				PageTransHuge(page));
 		if (error)
 			goto unacct;
-		error = radix_tree_maybe_preload_order(gfp & GFP_RECLAIM_MASK,
-				compound_order(page));
+		error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, hindex,
 							NULL);
@@ -1837,7 +1818,7 @@ alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
 		error = -EINVAL;
 		goto unlock;
 	}
-	*pagep = page + index - hindex;
+	*pagep = find_subpage(page, index);
 	return 0;
 
 	/*
diff --git a/mm/truncate.c b/mm/truncate.c
index fd97f1dbce29..eb3a3a45feb6 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -479,16 +479,13 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 
 			WARN_ON(page_to_index(page) != index);
 
-			/* Middle of THP: skip */
-			if (PageTransTail(page)) {
+			/* Is 'start' or 'end' in the middle of THP ? */
+			if (PageTransHuge(page) &&
+				(start > index ||
+				 (index ==  round_down(end, HPAGE_PMD_NR)))) {
+				/* skip */
 				unlock_page(page);
 				continue;
-			} else if (PageTransHuge(page)) {
-				index += HPAGE_PMD_NR - 1;
-				i += HPAGE_PMD_NR - 1;
-				/* 'end' is in the middle of THP */
-				if (index ==  round_down(end, HPAGE_PMD_NR))
-					continue;
 			}
 
 			ret = invalidate_inode_page(page);
@@ -502,9 +499,9 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			count += ret;
 		}
 		pagevec_remove_exceptionals(&pvec);
+		index += pvec.nr ? hpage_nr_pages(pvec.pages[pvec.nr - 1]) : 1;
 		pagevec_release(&pvec);
 		cond_resched();
-		index++;
 	}
 	return count;
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
