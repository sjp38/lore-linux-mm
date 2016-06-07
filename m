Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FED9828E1
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 07:08:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s73so275463252pfs.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:08:42 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id g10si32695264pac.240.2016.06.07.04.01.04
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 04:01:05 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased 24/32] shmem: add huge pages support
Date: Tue,  7 Jun 2016 14:00:38 +0300
Message-Id: <1465297246-98985-25-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's basic implementation of huge pages support for shmem/tmpfs.

It's all pretty streight-forward:

  - shmem_getpage() allcoates huge page if it can and try to inserd into
    radix tree with shmem_add_to_page_cache();

  - shmem_add_to_page_cache() puts the page onto radix-tree if there's
    space for it;

  - shmem_undo_range() removes huge pages, if it fully within range.
    Partial truncate of huge pages zero out this part of THP.

    This have visible effect on fallocate(FALLOC_FL_PUNCH_HOLE)
    behaviour. As we don't really create hole in this case,
    lseek(SEEK_HOLE) may have inconsistent results depending what
    pages happened to be allocated.

  - no need to change shmem_fault: core-mm will map an compound page as
    huge if VMA is suitable;

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h  |   2 +
 include/linux/shmem_fs.h |   3 +
 mm/filemap.c             |   7 +-
 mm/huge_memory.c         |   2 +
 mm/memory.c              |   2 +-
 mm/mempolicy.c           |   2 +-
 mm/page-writeback.c      |   1 +
 mm/shmem.c               | 380 ++++++++++++++++++++++++++++++++++++++---------
 mm/swap.c                |   2 +
 9 files changed, 331 insertions(+), 70 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 64dcd4e3fd72..7a0388c83aab 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -156,6 +156,8 @@ void put_huge_zero_page(void);
 
 #define transparent_hugepage_enabled(__vma) 0
 
+static inline void prep_transhuge_page(struct page *page) {}
+
 #define transparent_hugepage_flags 0UL
 static inline int
 split_huge_page_to_list(struct page *page, struct list_head *list)
diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index ff2de4bab61f..94eaaa2c6ad9 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -71,6 +71,9 @@ static inline struct page *shmem_read_mapping_page(
 					mapping_gfp_mask(mapping));
 }
 
+extern bool shmem_charge(struct inode *inode, long pages);
+extern void shmem_uncharge(struct inode *inode, long pages);
+
 #ifdef CONFIG_TMPFS
 
 extern int shmem_add_seals(struct file *file, unsigned int seals);
diff --git a/mm/filemap.c b/mm/filemap.c
index 98b8d71d54bc..89dd8794e788 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -219,8 +219,13 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 	/* hugetlb pages do not participate in page cache accounting. */
 	if (!PageHuge(page))
 		__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
-	if (PageSwapBacked(page))
+	if (PageSwapBacked(page)) {
 		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
+		if (PageTransHuge(page))
+			__dec_zone_page_state(page, NR_SHMEM_THPS);
+	} else {
+		VM_BUG_ON_PAGE(PageTransHuge(page) && !PageHuge(page), page);
+	}
 
 	/*
 	 * At this point page must be either written or cleaned by truncate.
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a67d7188a5af..d6235287f077 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3330,6 +3330,8 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 		if (head[i].index >= end) {
 			__ClearPageDirty(head + i);
 			__delete_from_page_cache(head + i, NULL);
+			if (IS_ENABLED(CONFIG_SHMEM) && PageSwapBacked(head))
+				shmem_uncharge(head->mapping->host, 1);
 			put_page(head + i);
 		}
 	}
diff --git a/mm/memory.c b/mm/memory.c
index a9501e2851d8..f93d71b04f1e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1142,7 +1142,7 @@ again:
 				 * unmap shared but keep private pages.
 				 */
 				if (details->check_mapping &&
-				    details->check_mapping != page->mapping)
+				    details->check_mapping != page_rmapping(page))
 					continue;
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index fe90e5051012..53e40d3f3933 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -531,7 +531,7 @@ retry:
 		nid = page_to_nid(page);
 		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
 			continue;
-		if (PageTransCompound(page) && PageAnon(page)) {
+		if (PageTransCompound(page)) {
 			get_page(page);
 			pte_unmap_unlock(pte, ptl);
 			lock_page(page);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index b9956fdee8f5..3619d88a5820 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2560,6 +2560,7 @@ int set_page_dirty(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 
+	page = compound_head(page);
 	if (likely(mapping)) {
 		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
 		/*
diff --git a/mm/shmem.c b/mm/shmem.c
index 0a564110b04d..c9d50d0802c8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -173,10 +173,13 @@ static inline int shmem_reacct_size(unsigned long flags,
  * shmem_getpage reports shmem_acct_block failure as -ENOSPC not -ENOMEM,
  * so that a failure on a sparse tmpfs mapping will give SIGBUS not OOM.
  */
-static inline int shmem_acct_block(unsigned long flags)
+static inline int shmem_acct_block(unsigned long flags, long pages)
 {
-	return (flags & VM_NORESERVE) ?
-		security_vm_enough_memory_mm(current->mm, VM_ACCT(PAGE_SIZE)) : 0;
+	if (!(flags & VM_NORESERVE))
+		return 0;
+
+	return security_vm_enough_memory_mm(current->mm,
+			pages * VM_ACCT(PAGE_SIZE));
 }
 
 static inline void shmem_unacct_blocks(unsigned long flags, long pages)
@@ -249,6 +252,51 @@ static void shmem_recalc_inode(struct inode *inode)
 	}
 }
 
+bool shmem_charge(struct inode *inode, long pages)
+{
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+
+	if (shmem_acct_block(info->flags, pages))
+		return false;
+	spin_lock(&info->lock);
+	info->alloced += pages;
+	inode->i_blocks += pages * BLOCKS_PER_PAGE;
+	shmem_recalc_inode(inode);
+	spin_unlock(&info->lock);
+	inode->i_mapping->nrpages += pages;
+
+	if (!sbinfo->max_blocks)
+		return true;
+	if (percpu_counter_compare(&sbinfo->used_blocks,
+				sbinfo->max_blocks - pages) > 0) {
+		inode->i_mapping->nrpages -= pages;
+		spin_lock(&info->lock);
+		info->alloced -= pages;
+		shmem_recalc_inode(inode);
+		spin_unlock(&info->lock);
+
+		return false;
+	}
+	percpu_counter_add(&sbinfo->used_blocks, pages);
+	return true;
+}
+
+void shmem_uncharge(struct inode *inode, long pages)
+{
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+
+	spin_lock(&info->lock);
+	info->alloced -= pages;
+	inode->i_blocks -= pages * BLOCKS_PER_PAGE;
+	shmem_recalc_inode(inode);
+	spin_unlock(&info->lock);
+
+	if (sbinfo->max_blocks)
+		percpu_counter_sub(&sbinfo->used_blocks, pages);
+}
+
 /*
  * Replace item expected in radix tree by a new item, while holding tree lock.
  */
@@ -376,30 +424,57 @@ static int shmem_add_to_page_cache(struct page *page,
 				   struct address_space *mapping,
 				   pgoff_t index, void *expected)
 {
-	int error;
+	int error, nr = hpage_nr_pages(page);
 
+	VM_BUG_ON_PAGE(PageTail(page), page);
+	VM_BUG_ON_PAGE(index != round_down(index, nr), page);
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+	VM_BUG_ON(expected && PageTransHuge(page));
 
-	get_page(page);
+	page_ref_add(page, nr);
 	page->mapping = mapping;
 	page->index = index;
 
 	spin_lock_irq(&mapping->tree_lock);
-	if (!expected)
+	if (PageTransHuge(page)) {
+		void __rcu **results;
+		pgoff_t idx;
+		int i;
+
+		error = 0;
+		if (radix_tree_gang_lookup_slot(&mapping->page_tree,
+					&results, &idx, index, 1) &&
+				idx < index + HPAGE_PMD_NR) {
+			error = -EEXIST;
+		}
+
+		if (!error) {
+			for (i = 0; i < HPAGE_PMD_NR; i++) {
+				error = radix_tree_insert(&mapping->page_tree,
+						index + i, page + i);
+				VM_BUG_ON(error);
+			}
+			count_vm_event(THP_FILE_ALLOC);
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
+		if (PageTransHuge(page))
+			__inc_zone_page_state(page, NR_SHMEM_THPS);
+		__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, nr);
+		__mod_zone_page_state(page_zone(page), NR_SHMEM, nr);
 		spin_unlock_irq(&mapping->tree_lock);
 	} else {
 		page->mapping = NULL;
 		spin_unlock_irq(&mapping->tree_lock);
-		put_page(page);
+		page_ref_sub(page, nr);
 	}
 	return error;
 }
@@ -412,6 +487,8 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 	struct address_space *mapping = page->mapping;
 	int error;
 
+	VM_BUG_ON_PAGE(PageCompound(page), page);
+
 	spin_lock_irq(&mapping->tree_lock);
 	error = shmem_radix_tree_replace(mapping, page->index, page, radswap);
 	page->mapping = NULL;
@@ -591,10 +668,33 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				continue;
 			}
 
+			VM_BUG_ON_PAGE(page_to_pgoff(page) != index, page);
+
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
+				VM_BUG_ON_PAGE(PageTail(page), page);
+				if (page_mapping(page) == mapping) {
 					VM_BUG_ON_PAGE(PageWriteback(page), page);
 					truncate_inode_page(mapping, page);
 				}
@@ -670,8 +770,36 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			}
 
 			lock_page(page);
+
+			if (PageTransTail(page)) {
+				/* Middle of THP: zero out the page */
+				clear_highpage(page);
+				unlock_page(page);
+				/*
+				 * Partial thp truncate due 'start' in middle
+				 * of THP: don't need to look on these pages
+				 * again on !pvec.nr restart.
+				 */
+				if (index != round_down(end, HPAGE_PMD_NR))
+					start++;
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
@@ -929,6 +1057,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	swp_entry_t swap;
 	pgoff_t index;
 
+	VM_BUG_ON_PAGE(PageCompound(page), page);
 	BUG_ON(!PageLocked(page));
 	mapping = page->mapping;
 	index = page->index;
@@ -1065,24 +1194,63 @@ static inline struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
 #define vm_policy vm_private_data
 #endif
 
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
+	shmem_pseudo_vma_destroy(&pvma);
 
-	/* Drop reference taken by mpol_shared_policy_lookup() */
-	mpol_cond_put(pvma.vm_policy);
+	return page;
+}
+
+static struct page *shmem_alloc_hugepage(gfp_t gfp,
+		struct shmem_inode_info *info, pgoff_t index)
+{
+	struct vm_area_struct pvma;
+	struct inode *inode = &info->vfs_inode;
+	struct address_space *mapping = inode->i_mapping;
+	pgoff_t idx, hindex = round_down(index, HPAGE_PMD_NR);
+	void __rcu **results;
+	struct page *page;
 
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		return NULL;
+
+	rcu_read_lock();
+	if (radix_tree_gang_lookup_slot(&mapping->page_tree, &results, &idx,
+				hindex, 1) && idx < hindex + HPAGE_PMD_NR) {
+		rcu_read_unlock();
+		return NULL;
+	}
+	rcu_read_unlock();
+
+	shmem_pseudo_vma_init(&pvma, info, hindex);
+	page = alloc_pages_vma(gfp | __GFP_COMP | __GFP_NORETRY | __GFP_NOWARN,
+			HPAGE_PMD_ORDER, &pvma, 0, numa_node_id(), true);
+	shmem_pseudo_vma_destroy(&pvma);
+	if (page)
+		prep_transhuge_page(page);
 	return page;
 }
 
@@ -1092,23 +1260,51 @@ static struct page *shmem_alloc_page(gfp_t gfp,
 	struct vm_area_struct pvma;
 	struct page *page;
 
-	/* Create a pseudo vma that just contains the policy */
-	pvma.vm_start = 0;
-	/* Bias interleave by inode number to distribute better across nodes */
-	pvma.vm_pgoff = index + info->vfs_inode.i_ino;
-	pvma.vm_ops = NULL;
-	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+	shmem_pseudo_vma_init(&pvma, info, index);
+	page = alloc_page_vma(gfp, &pvma, 0);
+	shmem_pseudo_vma_destroy(&pvma);
+
+	return page;
+}
+
+static struct page *shmem_alloc_and_acct_page(gfp_t gfp,
+		struct shmem_inode_info *info, struct shmem_sb_info *sbinfo,
+		pgoff_t index, bool huge)
+{
+	struct page *page;
+	int nr;
+	int err = -ENOSPC;
+
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		huge = false;
+	nr = huge ? HPAGE_PMD_NR : 1;
+
+	if (shmem_acct_block(info->flags, nr))
+		goto failed;
+	if (sbinfo->max_blocks) {
+		if (percpu_counter_compare(&sbinfo->used_blocks,
+					sbinfo->max_blocks - nr) > 0)
+			goto unacct;
+		percpu_counter_add(&sbinfo->used_blocks, nr);
+	}
 
-	page = alloc_pages_vma(gfp, 0, &pvma, 0, numa_node_id(), false);
+	if (huge)
+		page = shmem_alloc_hugepage(gfp, info, index);
+	else
+		page = shmem_alloc_page(gfp, info, index);
 	if (page) {
 		__SetPageLocked(page);
 		__SetPageSwapBacked(page);
+		return page;
 	}
 
-	/* Drop reference taken by mpol_shared_policy_lookup() */
-	mpol_cond_put(pvma.vm_policy);
-
-	return page;
+	err = -ENOMEM;
+	if (sbinfo->max_blocks)
+		percpu_counter_add(&sbinfo->used_blocks, -nr);
+unacct:
+	shmem_unacct_blocks(info->flags, nr);
+failed:
+	return ERR_PTR(err);
 }
 
 /*
@@ -1213,6 +1409,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct mem_cgroup *memcg;
 	struct page *page;
 	swp_entry_t swap;
+	pgoff_t hindex = index;
 	int error;
 	int once = 0;
 	int alloced = 0;
@@ -1334,47 +1531,74 @@ repeat:
 		swap_free(swap);
 
 	} else {
-		if (shmem_acct_block(info->flags)) {
-			error = -ENOSPC;
-			goto failed;
-		}
-		if (sbinfo->max_blocks) {
-			if (percpu_counter_compare(&sbinfo->used_blocks,
-						sbinfo->max_blocks) >= 0) {
-				error = -ENOSPC;
-				goto unacct;
-			}
-			percpu_counter_inc(&sbinfo->used_blocks);
+		/* shmem_symlink() */
+		if (mapping->a_ops != &shmem_aops)
+			goto alloc_nohuge;
+		if (shmem_huge == SHMEM_HUGE_DENY)
+			goto alloc_nohuge;
+		if (shmem_huge == SHMEM_HUGE_FORCE)
+			goto alloc_huge;
+		switch (sbinfo->huge) {
+			loff_t i_size;
+			pgoff_t off;
+		case SHMEM_HUGE_NEVER:
+			goto alloc_nohuge;
+		case SHMEM_HUGE_WITHIN_SIZE:
+			off = round_up(index, HPAGE_PMD_NR);
+			i_size = round_up(i_size_read(inode), PAGE_SIZE);
+			if (i_size >= HPAGE_PMD_SIZE &&
+					i_size >> PAGE_SHIFT >= off)
+				goto alloc_huge;
+			/* fallthrough */
+		case SHMEM_HUGE_ADVISE:
+			/* TODO: wire up fadvise()/madvise() */
+			goto alloc_nohuge;
 		}
 
-		page = shmem_alloc_page(gfp, info, index);
-		if (!page) {
-			error = -ENOMEM;
-			goto decused;
+alloc_huge:
+		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
+				index, true);
+		if (IS_ERR(page)) {
+alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
+					index, false);
+		}
+		if (IS_ERR(page)) {
+			error = PTR_ERR(page);
+			page = NULL;
+			goto failed;
 		}
+
+		if (PageTransHuge(page))
+			hindex = round_down(index, HPAGE_PMD_NR);
+		else
+			hindex = index;
+
 		if (sgp == SGP_WRITE)
 			__SetPageReferenced(page);
 
 		error = mem_cgroup_try_charge(page, charge_mm, gfp, &memcg,
-				false);
+				PageTransHuge(page));
 		if (error)
-			goto decused;
-		error = radix_tree_maybe_preload(gfp & GFP_RECLAIM_MASK);
+			goto unacct;
+		error = radix_tree_maybe_preload_order(gfp & GFP_RECLAIM_MASK,
+				compound_order(page));
 		if (!error) {
-			error = shmem_add_to_page_cache(page, mapping, index,
+			error = shmem_add_to_page_cache(page, mapping, hindex,
 							NULL);
 			radix_tree_preload_end();
 		}
 		if (error) {
-			mem_cgroup_cancel_charge(page, memcg, false);
-			goto decused;
+			mem_cgroup_cancel_charge(page, memcg,
+					PageTransHuge(page));
+			goto unacct;
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
@@ -1390,10 +1614,15 @@ clear:
 		 * but SGP_FALLOC on a page fallocated earlier must initialize
 		 * it now, lest undo on failure cancel our earlier guarantee.
 		 */
-		if (sgp != SGP_WRITE) {
-			clear_highpage(page);
-			flush_dcache_page(page);
-			SetPageUptodate(page);
+		if (sgp != SGP_WRITE && !PageUptodate(page)) {
+			struct page *head = compound_head(page);
+			int i;
+
+			for (i = 0; i < (1 << compound_order(head)); i++) {
+				clear_highpage(head + i);
+				flush_dcache_page(head + i);
+			}
+			SetPageUptodate(head);
 		}
 	}
 
@@ -1410,17 +1639,23 @@ clear:
 		error = -EINVAL;
 		goto unlock;
 	}
-	*pagep = page;
+	*pagep = page + index - hindex;
 	return 0;
 
 	/*
 	 * Error recovery.
 	 */
-decused:
-	if (sbinfo->max_blocks)
-		percpu_counter_add(&sbinfo->used_blocks, -1);
 unacct:
-	shmem_unacct_blocks(info->flags, 1);
+	if (sbinfo->max_blocks)
+		percpu_counter_sub(&sbinfo->used_blocks,
+				1 << compound_order(page));
+	shmem_unacct_blocks(info->flags, 1 << compound_order(page));
+
+	if (PageTransHuge(page)) {
+		unlock_page(page);
+		put_page(page);
+		goto alloc_nohuge;
+	}
 failed:
 	if (swap.val && !shmem_confirm_swap(mapping, index, swap))
 		error = -EEXIST;
@@ -1758,12 +1993,23 @@ shmem_write_end(struct file *file, struct address_space *mapping,
 		i_size_write(inode, pos + copied);
 
 	if (!PageUptodate(page)) {
+		struct page *head = compound_head(page);
+		if (PageTransCompound(page)) {
+			int i;
+
+			for (i = 0; i < HPAGE_PMD_NR; i++) {
+				if (head + i == page)
+					continue;
+				clear_highpage(head + i);
+				flush_dcache_page(head + i);
+			}
+		}
 		if (copied < PAGE_SIZE) {
 			unsigned from = pos & (PAGE_SIZE - 1);
 			zero_user_segments(page, 0, from,
 					from + copied, PAGE_SIZE);
 		}
-		SetPageUptodate(page);
+		SetPageUptodate(head);
 	}
 	set_page_dirty(page);
 	unlock_page(page);
diff --git a/mm/swap.c b/mm/swap.c
index 59f5fafa6e1f..43a46b09416c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -292,6 +292,7 @@ static bool need_activate_page_drain(int cpu)
 
 void activate_page(struct page *page)
 {
+	page = compound_head(page);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
 
@@ -316,6 +317,7 @@ void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 
+	page = compound_head(page);
 	spin_lock_irq(&zone->lru_lock);
 	__activate_page(page, mem_cgroup_page_lruvec(page, zone), NULL);
 	spin_unlock_irq(&zone->lru_lock);
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
