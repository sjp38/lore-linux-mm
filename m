Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C01D56B025C
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:25:54 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so61422863pab.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:25:54 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id un9si7295761pac.89.2015.11.18.15.25.51
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 15:25:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 9/9] WIP: shmem: add huge pages support
Date: Thu, 19 Nov 2015 01:25:36 +0200
Message-Id: <1447889136-6928-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is very early prototype of huge pages support in shmem/tmpfs.
I'm still learning how shmem works. A lot of work is ahead.

Currently, it's able to handle only very basic use-cases.

Some notes:

 - we allocate pages only within i_size for now;

 - split_huge_page() in not implemented yet: always fails;

 - shmem_undo_range() doesn't split page if part of huge page is in the
   range: only zero it out;

 - no knobs to control huge page allocation;

 - no proper accounting at the moment;

 - fallocate() known to cause problems: need to look more careful on
   page flags handling, PG_uptodate in particular;

 - khugepaged knows nothing about file pages;
---
 include/linux/page-flags.h |   2 +-
 mm/filemap.c               | 129 ++++++++++++++++++----------
 mm/huge_memory.c           |   5 +-
 mm/shmem.c                 | 208 +++++++++++++++++++++++++++++++++------------
 mm/swap.c                  |   2 +
 mm/truncate.c              |   5 +-
 6 files changed, 247 insertions(+), 104 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index dab6cff11e18..a0acf64e9b5f 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -299,7 +299,7 @@ PAGEFLAG(OwnerPriv1, owner_priv_1, PF_ANY)
  */
 TESTPAGEFLAG(Writeback, writeback, PF_NO_COMPOUND)
 	TESTSCFLAG(Writeback, writeback, PF_NO_COMPOUND)
-PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_COMPOUND)
+PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_TAIL)
 
 /* PG_readahead is only used for reads; PG_reclaim is only for writes */
 PAGEFLAG(Reclaim, reclaim, PF_NO_COMPOUND)
diff --git a/mm/filemap.c b/mm/filemap.c
index 11c5be3d350d..ac84c80d2d95 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -109,43 +109,18 @@
  *   ->tasklist_lock            (memory_failure, collect_procs_ao)
  */
 
-static void page_cache_tree_delete(struct address_space *mapping,
-				   struct page *page, void *shadow)
+static void __page_cache_tree_delete(struct address_space *mapping,
+		struct radix_tree_node *node, void **slot, unsigned long index,
+		void *shadow)
 {
-	struct radix_tree_node *node;
-	unsigned long index;
-	unsigned int offset;
 	unsigned int tag;
-	void **slot;
 
-	VM_BUG_ON(!PageLocked(page));
-
-	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
-
-	if (shadow) {
-		mapping->nrshadows++;
-		/*
-		 * Make sure the nrshadows update is committed before
-		 * the nrpages update so that final truncate racing
-		 * with reclaim does not see both counters 0 at the
-		 * same time and miss a shadow entry.
-		 */
-		smp_wmb();
-	}
-	mapping->nrpages--;
-
-	if (!node) {
-		/* Clear direct pointer tags in root node */
-		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
-		radix_tree_replace_slot(slot, shadow);
-		return;
-	}
+	VM_BUG_ON(node == NULL);
+	VM_BUG_ON(*slot == NULL);
 
 	/* Clear tree tags for the removed page */
-	index = page->index;
-	offset = index & RADIX_TREE_MAP_MASK;
 	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
-		if (test_bit(offset, node->tags[tag]))
+		if (test_bit(index & RADIX_TREE_MAP_MASK, node->tags[tag]))
 			radix_tree_tag_clear(&mapping->page_tree, index, tag);
 	}
 
@@ -172,6 +147,54 @@ static void page_cache_tree_delete(struct address_space *mapping,
 	}
 }
 
+static void page_cache_tree_delete(struct address_space *mapping,
+				   struct page *page, void *shadow)
+{
+	struct radix_tree_node *node;
+	unsigned long index;
+	void **slot;
+	int i, nr = PageHuge(page) ? 1 : hpage_nr_pages(page);
+
+	VM_BUG_ON_PAGE(!PageLocked(page), page);
+	VM_BUG_ON_PAGE(PageTail(page), page);
+
+	__radix_tree_lookup(&mapping->page_tree, page->index, &node, &slot);
+
+	if (shadow) {
+		mapping->nrshadows += nr;
+		/*
+		 * Make sure the nrshadows update is committed before
+		 * the nrpages update so that final truncate racing
+		 * with reclaim does not see both counters 0 at the
+		 * same time and miss a shadow entry.
+		 */
+		smp_wmb();
+	}
+	mapping->nrpages -= nr;
+
+	if (!node) {
+		/* Clear direct pointer tags in root node */
+		mapping->page_tree.gfp_mask &= __GFP_BITS_MASK;
+		VM_BUG_ON(nr != 1);
+		radix_tree_replace_slot(slot, shadow);
+		return;
+	}
+
+	index = page->index;
+	VM_BUG_ON_PAGE(index & (nr - 1), page);
+	for (i = 0; i < nr; i++) {
+		/* Cross node border */
+		if (i && ((index + i) & RADIX_TREE_MAP_MASK) == 0) {
+			__radix_tree_lookup(&mapping->page_tree,
+					page->index + i, &node, &slot);
+		}
+
+		__page_cache_tree_delete(mapping, node,
+				slot + (i & RADIX_TREE_MAP_MASK), index + i,
+				shadow);
+	}
+}
+
 /*
  * Delete a page from the page cache and free it. Caller has to make
  * sure the page is locked and that nobody else uses it - or that usage
@@ -182,6 +205,7 @@ void __delete_from_page_cache(struct page *page, void *shadow,
 			      struct mem_cgroup *memcg)
 {
 	struct address_space *mapping = page->mapping;
+	int nr = hpage_nr_pages(page);
 
 	trace_mm_filemap_delete_from_page_cache(page);
 	/*
@@ -201,9 +225,10 @@ void __delete_from_page_cache(struct page *page, void *shadow,
 
 	/* hugetlb pages do not participate in page cache accounting. */
 	if (!PageHuge(page))
-		__dec_zone_page_state(page, NR_FILE_PAGES);
+		__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
 	if (PageSwapBacked(page))
-		__dec_zone_page_state(page, NR_SHMEM);
+		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	VM_BUG_ON_PAGE(page_mapped(page), page);
 
 	/*
@@ -229,10 +254,9 @@ void __delete_from_page_cache(struct page *page, void *shadow,
  */
 void delete_from_page_cache(struct page *page)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	struct mem_cgroup *memcg;
 	unsigned long flags;
-
 	void (*freepage)(struct page *);
 
 	BUG_ON(!PageLocked(page));
@@ -247,7 +271,13 @@ void delete_from_page_cache(struct page *page)
 
 	if (freepage)
 		freepage(page);
-	page_cache_release(page);
+
+	if (PageTransHuge(page) && !PageHuge(page)) {
+		atomic_sub(HPAGE_PMD_NR, &page->_count);
+		VM_BUG_ON_PAGE(atomic_read(&page->_count) <= 0, page);
+	} else {
+		page_cache_release(page);
+	}
 }
 EXPORT_SYMBOL(delete_from_page_cache);
 
@@ -1033,7 +1063,7 @@ EXPORT_SYMBOL(page_cache_prev_hole);
 struct page *find_get_entry(struct address_space *mapping, pgoff_t offset)
 {
 	void **pagep;
-	struct page *page;
+	struct page *head, *page;
 
 	rcu_read_lock();
 repeat:
@@ -1053,9 +1083,13 @@ repeat:
 			 */
 			goto out;
 		}
-		if (!page_cache_get_speculative(page))
+
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
 			goto repeat;
 
+		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+
 		/*
 		 * Has the page moved?
 		 * This is part of the lockless pagecache protocol. See
@@ -1098,12 +1132,12 @@ repeat:
 	if (page && !radix_tree_exception(page)) {
 		lock_page(page);
 		/* Has the page been truncated? */
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_mapping(page) != mapping)) {
 			unlock_page(page);
 			page_cache_release(page);
 			goto repeat;
 		}
-		VM_BUG_ON_PAGE(page->index != offset, page);
+		VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
 	}
 	return page;
 }
@@ -1236,7 +1270,7 @@ unsigned find_get_entries(struct address_space *mapping,
 	rcu_read_lock();
 restart:
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
-		struct page *page;
+		struct page *head, *page;
 repeat:
 		page = radix_tree_deref_slot(slot);
 		if (unlikely(!page))
@@ -1251,8 +1285,10 @@ repeat:
 			 */
 			goto export;
 		}
-		if (!page_cache_get_speculative(page))
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
 			goto repeat;
+		VM_BUG_ON_PAGE(compound_head(page) != head, page);
 
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
@@ -1403,7 +1439,7 @@ repeat:
 		 * otherwise we can get both false positives and false
 		 * negatives, which is just confusing to the caller.
 		 */
-		if (page->mapping == NULL || page->index != iter.index) {
+		if (page->mapping == NULL || page_to_pgoff(page) != iter.index) {
 			page_cache_release(page);
 			break;
 		}
@@ -2061,7 +2097,7 @@ void filemap_map_pages(struct fault_env *fe,
 	struct address_space *mapping = file->f_mapping;
 	pgoff_t last_pgoff = start_pgoff;
 	loff_t size;
-	struct page *page;
+	struct page *head, *page;
 
 	rcu_read_lock();
 	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
@@ -2079,9 +2115,12 @@ repeat:
 				goto next;
 		}
 
-		if (!page_cache_get_speculative(page))
+		head = compound_head(page);
+		if (!page_cache_get_speculative(head))
 			goto repeat;
 
+		VM_BUG_ON_PAGE(compound_head(page) != head, page);
+
 		/* Has the page moved? */
 		if (unlikely(page != *slot)) {
 			page_cache_release(page);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index acd367b04730..125cdb4ce2e4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3251,8 +3251,11 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	struct anon_vma *anon_vma;
 	int count, mapcount, ret;
 
+	/* TODO: file pages support */
+	if (!PageAnon(page))
+		return -EBUSY;
+
 	VM_BUG_ON_PAGE(is_huge_zero_page(page), page);
-	VM_BUG_ON_PAGE(!PageAnon(page), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 	VM_BUG_ON_PAGE(!PageCompound(page), page);
diff --git a/mm/shmem.c b/mm/shmem.c
index 529a7d5083f1..ea7cdcdbaec2 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -295,30 +295,53 @@ static int shmem_add_to_page_cache(struct page *page,
 				   struct address_space *mapping,
 				   pgoff_t index, void *expected)
 {
-	int error;
+	int error, nr = hpage_nr_pages(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+	VM_BUG_ON(expected && PageTransHuge(page));
 
-	page_cache_get(page);
+	index = round_down(index, nr);
+	atomic_add(nr, &page->_count);
 	page->mapping = mapping;
 	page->index = index;
 
 	spin_lock_irq(&mapping->tree_lock);
-	if (!expected)
+	if (PageTransHuge(page)) {
+		void __rcu **results;
+		pgoff_t idx, hindex = round_down(index, HPAGE_PMD_NR);
+		int i;
+
+		error = 0;
+		if (radix_tree_gang_lookup_slot(&mapping->page_tree,
+					&results, &idx, hindex, 1) &&
+				idx < hindex + HPAGE_PMD_NR) {
+			error = -EEXIST;
+		}
+
+		if (!error) {
+			for (i = 0; i < HPAGE_PMD_NR; i++) {
+				error = radix_tree_insert(&mapping->page_tree,
+						hindex + i, page + i);
+				VM_BUG_ON(error);
+			}
+		}
+	} else if (!expected) {
 		error = radix_tree_insert(&mapping->page_tree, index, page);
-	else
+	} else {
 		error = shmem_radix_tree_replace(mapping, index, expected,
 								 page);
+	}
+
 	if (!error) {
-		mapping->nrpages++;
-		__inc_zone_page_state(page, NR_FILE_PAGES);
-		__inc_zone_page_state(page, NR_SHMEM);
+		mapping->nrpages += nr;
+		__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
+		__mod_zone_page_state(page_zone(page), NR_SHMEM, nr);
 		spin_unlock_irq(&mapping->tree_lock);
 	} else {
 		page->mapping = NULL;
 		spin_unlock_irq(&mapping->tree_lock);
-		page_cache_release(page);
+		atomic_sub(nr, &page->_count);
 	}
 	return error;
 }
@@ -333,6 +356,7 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 
 	spin_lock_irq(&mapping->tree_lock);
 	error = shmem_radix_tree_replace(mapping, page->index, page, radswap);
+	VM_BUG_ON_PAGE(PageCompound(page), page);
 	page->mapping = NULL;
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
@@ -425,6 +449,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			index = indices[i];
 			if (index >= end)
 				break;
+			VM_BUG_ON_PAGE(page_to_pgoff(page) != index, page);
 
 			if (radix_tree_exceptional_entry(page)) {
 				if (unfalloc)
@@ -436,8 +461,28 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 
 			if (!trylock_page(page))
 				continue;
+
+			if (PageTransTail(page)) {
+				/* Middle of THP: zero out the page */
+				clear_highpage(page);
+				unlock_page(page);
+				continue;
+			} else if (PageTransHuge(page)) {
+				if (index == round_down(end, HPAGE_PMD_NR)) {
+					/*
+					 * Range ends in the middle of THP:
+					 * zero out the page
+					 */
+					clear_highpage(page);
+					unlock_page(page);
+					continue;
+				}
+				index += HPAGE_PMD_NR - 1;
+				i += HPAGE_PMD_NR - 1;
+			}
+
 			if (!unfalloc || !PageUptodate(page)) {
-				if (page->mapping == mapping) {
+				if (page_mapping(page) == mapping) {
 					VM_BUG_ON_PAGE(PageWriteback(page), page);
 					truncate_inode_page(mapping, page);
 				}
@@ -513,8 +558,29 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			}
 
 			lock_page(page);
+
+			if (PageTransTail(page)) {
+				/* Middle of THP: zero out the page */
+				clear_highpage(page);
+				unlock_page(page);
+				continue;
+			} else if (PageTransHuge(page)) {
+				if (index == round_down(end, HPAGE_PMD_NR)) {
+					/*
+					 * Range ends in the middle of THP:
+					 * zero out the page
+					 */
+					clear_highpage(page);
+					unlock_page(page);
+					continue;
+				}
+				index += HPAGE_PMD_NR - 1;
+				i += HPAGE_PMD_NR - 1;
+			}
+
 			if (!unfalloc || !PageUptodate(page)) {
-				if (page->mapping == mapping) {
+				VM_BUG_ON_PAGE(PageTail(page), page);
+				if (page_mapping(page) == mapping) {
 					VM_BUG_ON_PAGE(PageWriteback(page), page);
 					truncate_inode_page(mapping, page);
 				} else {
@@ -868,7 +934,6 @@ redirty:
 	return 0;
 }
 
-#ifdef CONFIG_NUMA
 #ifdef CONFIG_TMPFS
 static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
@@ -895,66 +960,83 @@ static struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
 }
 #endif /* CONFIG_TMPFS */
 
+static void shmem_pseudo_vma_init(struct vm_area_struct *vma,
+		struct shmem_inode_info *info, pgoff_t index)
+{
+	/* Create a pseudo vma that just contains the policy */
+	vma->vm_start = 0;
+	/* Bias interleave by inode number to distribute better across nodes */
+	vma->vm_pgoff = index + info->vfs_inode.i_ino;
+	vma->vm_ops = NULL;
+	vma->vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+}
+
+static void shmem_pseudo_vma_destroy(struct vm_area_struct *vma)
+{
+	/* Drop reference taken by mpol_shared_policy_lookup() */
+	mpol_cond_put(vma->vm_policy);
+}
+
 static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
 			struct shmem_inode_info *info, pgoff_t index)
 {
 	struct vm_area_struct pvma;
 	struct page *page;
 
-	/* Create a pseudo vma that just contains the policy */
-	pvma.vm_start = 0;
-	/* Bias interleave by inode number to distribute better across nodes */
-	pvma.vm_pgoff = index + info->vfs_inode.i_ino;
-	pvma.vm_ops = NULL;
-	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
-
+	shmem_pseudo_vma_init(&pvma, info, index);
 	page = swapin_readahead(swap, gfp, &pvma, 0);
-
-	/* Drop reference taken by mpol_shared_policy_lookup() */
-	mpol_cond_put(pvma.vm_policy);
+	shmem_pseudo_vma_destroy(&pvma);
 
 	return page;
 }
 
-static struct page *shmem_alloc_page(gfp_t gfp,
-			struct shmem_inode_info *info, pgoff_t index)
+static struct page *shmem_alloc_hugepage(gfp_t gfp,
+		struct shmem_inode_info *info, pgoff_t index)
 {
 	struct vm_area_struct pvma;
+	struct inode *inode = &info->vfs_inode;
+	struct address_space *mapping = inode->i_mapping;
+	pgoff_t idx, hindex = round_down(index, HPAGE_PMD_NR);
+	void __rcu **results;
 	struct page *page;
 
-	/* Create a pseudo vma that just contains the policy */
-	pvma.vm_start = 0;
-	/* Bias interleave by inode number to distribute better across nodes */
-	pvma.vm_pgoff = index + info->vfs_inode.i_ino;
-	pvma.vm_ops = NULL;
-	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		return NULL;
 
-	page = alloc_page_vma(gfp, &pvma, 0);
+	/* XXX: too strong condition ? */
+	if (round_up(i_size_read(inode), PAGE_CACHE_SIZE) >> PAGE_CACHE_SHIFT <
+		       hindex + HPAGE_PMD_NR)
+		return NULL;
 
-	/* Drop reference taken by mpol_shared_policy_lookup() */
-	mpol_cond_put(pvma.vm_policy);
+	rcu_read_lock();
+	if (radix_tree_gang_lookup_slot(&mapping->page_tree, &results, &idx,
+				hindex, 1) && idx < hindex + HPAGE_PMD_NR) {
+		rcu_read_unlock();
+		return NULL;
+	}
+	rcu_read_unlock();
 
+	shmem_pseudo_vma_init(&pvma, info, hindex);
+	page = alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN,
+			HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(), true);
+	shmem_pseudo_vma_destroy(&pvma);
+	if (page)
+		prep_transhuge_page(page);
 	return page;
 }
-#else /* !CONFIG_NUMA */
-#ifdef CONFIG_TMPFS
-static inline void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
-{
-}
-#endif /* CONFIG_TMPFS */
 
-static inline struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
+static struct page *shmem_alloc_page(gfp_t gfp,
 			struct shmem_inode_info *info, pgoff_t index)
 {
-	return swapin_readahead(swap, gfp, NULL, 0);
-}
+	struct vm_area_struct pvma;
+	struct page *page;
 
-static inline struct page *shmem_alloc_page(gfp_t gfp,
-			struct shmem_inode_info *info, pgoff_t index)
-{
-	return alloc_page(gfp);
+	shmem_pseudo_vma_init(&pvma, info, index);
+	page = alloc_page_vma(gfp, &pvma, 0);
+	shmem_pseudo_vma_destroy(&pvma);
+
+	return page;
 }
-#endif /* CONFIG_NUMA */
 
 #if !defined(CONFIG_NUMA) || !defined(CONFIG_TMPFS)
 static inline struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
@@ -1191,7 +1273,9 @@ repeat:
 			percpu_counter_inc(&sbinfo->used_blocks);
 		}
 
-		page = shmem_alloc_page(gfp, info, index);
+		page = shmem_alloc_hugepage(gfp, info, index);
+alloc_nohuge:	if (!page)
+			page = shmem_alloc_page(gfp, info, index);
 		if (!page) {
 			error = -ENOMEM;
 			goto decused;
@@ -1203,25 +1287,39 @@ repeat:
 			__SetPageReferenced(page);
 
 		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg,
-				false);
-		if (error)
+				PageTransHuge(page));
+		if (error) {
+			if (PageTransHuge(page)) {
+				__free_pages(page, compound_order(page));
+				page = NULL;
+				goto alloc_nohuge;
+			}
 			goto decused;
-		error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
+		}
+		error = radix_tree_maybe_preload_order(gfp & GFP_RECLAIM_MASK,
+				compound_order(page));
 		if (!error) {
 			error = shmem_add_to_page_cache(page, mapping, index,
 							NULL);
 			radix_tree_preload_end();
 		}
 		if (error) {
-			mem_cgroup_cancel_charge(page, memcg, false);
+			mem_cgroup_cancel_charge(page, memcg,
+					PageTransHuge(page));
+			if (PageTransHuge(page)) {
+				__free_pages(page, compound_order(page));
+				page = NULL;
+				goto alloc_nohuge;
+			}
 			goto decused;
 		}
-		mem_cgroup_commit_charge(page, memcg, false, false);
+		mem_cgroup_commit_charge(page, memcg, false,
+				PageTransHuge(page));
 		lru_cache_add_anon(page);
 
 		spin_lock(&info->lock);
-		info->alloced++;
-		inode->i_blocks += BLOCKS_PER_PAGE;
+		info->alloced += 1 << compound_order(page);
+		inode->i_blocks += BLOCKS_PER_PAGE << compound_order(page);
 		shmem_recalc_inode(inode);
 		spin_unlock(&info->lock);
 		alloced = true;
@@ -1267,7 +1365,7 @@ trunc:
 	delete_from_page_cache(page);
 	spin_lock(&info->lock);
 	info->alloced--;
-	inode->i_blocks -= BLOCKS_PER_PAGE;
+	inode->i_blocks -= BLOCKS_PER_PAGE << compound_order(page);
 	spin_unlock(&info->lock);
 decused:
 	sbinfo = SHMEM_SB(inode->i_sb);
diff --git a/mm/swap.c b/mm/swap.c
index abffc33bb975..b04be86b1bd4 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -289,6 +289,7 @@ static bool need_activate_page_drain(int cpu)
 
 void activate_page(struct page *page)
 {
+	page = compound_head(page);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
 
@@ -313,6 +314,7 @@ void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 
+	page = compound_head(page);
 	spin_lock_irq(&zone->lru_lock);
 	__activate_page(page, mem_cgroup_page_lruvec(page, zone), NULL);
 	spin_unlock_irq(&zone->lru_lock);
diff --git a/mm/truncate.c b/mm/truncate.c
index 76e35ad97102..bcb1a87d1a81 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -148,10 +148,11 @@ invalidate_complete_page(struct address_space *mapping, struct page *page)
 
 int truncate_inode_page(struct address_space *mapping, struct page *page)
 {
+	VM_BUG_ON_PAGE(PageTail(page), page);
 	if (page_mapped(page)) {
 		unmap_mapping_range(mapping,
 				   (loff_t)page->index << PAGE_CACHE_SHIFT,
-				   PAGE_CACHE_SIZE, 0);
+				   PageTransHuge(page) ? HPAGE_SIZE : PAGE_CACHE_SIZE, 0);
 	}
 	return truncate_complete_page(mapping, page);
 }
@@ -480,7 +481,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 
 			if (!trylock_page(page))
 				continue;
-			WARN_ON(page->index != index);
+			WARN_ON(page_to_pgoff(page) != index);
 			ret = invalidate_inode_page(page);
 			unlock_page(page);
 			/*
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
