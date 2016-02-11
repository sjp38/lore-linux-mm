Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 42E056B0256
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:23:36 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id q63so30201464pfb.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:23:36 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id rk9si12923553pab.31.2016.02.11.06.23.00
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:23:01 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 28/28] shmem: add huge pages support
Date: Thu, 11 Feb 2016 17:21:56 +0300
Message-Id: <1455200516-132137-29-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Here's basic implementation of huge pages support for shmem/tmpfs.

It's all pretty streight-forward:

  - shmem_getpage() allcoates huge page if it can and try to inserd into
    radix tree with shmem_add_to_page_cache();

  - shmem_add_to_page_cache() puts the page onto radix-tree if there's
    space for it;

  - shmem_undo_range() removes huge pages, if it fully within range.
    Partial truncate of huge pages zero out this part of THP.

  - no need to change shmem_fault: core-mm will map an compound page as
    huge if VMA is suitable;

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |   2 +
 mm/memory.c             |   5 +-
 mm/mempolicy.c          |   2 +-
 mm/page-writeback.c     |   1 +
 mm/shmem.c              | 338 ++++++++++++++++++++++++++++++++++++------------
 mm/swap.c               |   2 +
 6 files changed, 265 insertions(+), 85 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a9ec30594a81..1e74ac5c9f67 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -159,6 +159,8 @@ struct page *get_huge_zero_page(void);
 
 #define transparent_hugepage_enabled(__vma) 0
 
+static inline void prep_transhuge_page(struct page *page) {}
+
 #define transparent_hugepage_flags 0UL
 static inline int
 split_huge_page_to_list(struct page *page, struct list_head *list)
diff --git a/mm/memory.c b/mm/memory.c
index 19eff2164e5b..2a35fdde7796 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1094,7 +1094,7 @@ again:
 				 * unmap shared but keep private pages.
 				 */
 				if (details->check_mapping &&
-				    details->check_mapping != page->mapping)
+				    details->check_mapping != page_rmapping(page))
 					continue;
 			}
 			ptent = ptep_get_and_clear_full(mm, addr, pte,
@@ -1185,7 +1185,8 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
 		next = pmd_addr_end(addr, end);
 		if (pmd_trans_huge(*pmd) || pmd_devmap(*pmd)) {
 			if (next - addr != HPAGE_PMD_SIZE) {
-				VM_BUG_ON_VMA(!rwsem_is_locked(&tlb->mm->mmap_sem), vma);
+				VM_BUG_ON_VMA(vma_is_anonymous(vma) &&
+						!rwsem_is_locked(&tlb->mm->mmap_sem), vma);
 				split_huge_pmd(vma, pmd, addr);
 			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
 				goto next;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 5742271a026d..30befece3782 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -534,7 +534,7 @@ retry:
 		nid = page_to_nid(page);
 		if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
 			continue;
-		if (PageTail(page) && PageAnon(page)) {
+		if (PageTransCompound(page)) {
 			get_page(page);
 			pte_unmap_unlock(pte, ptl);
 			lock_page(page);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 11ff8f758631..2c8d5386665d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2554,6 +2554,7 @@ int set_page_dirty(struct page *page)
 {
 	struct address_space *mapping = page_mapping(page);
 
+	page = compound_head(page);
 	if (likely(mapping)) {
 		int (*spd)(struct page *) = mapping->a_ops->set_page_dirty;
 		/*
diff --git a/mm/shmem.c b/mm/shmem.c
index 6069062d93b0..27d21a8a671a 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -174,10 +174,13 @@ static inline int shmem_reacct_size(unsigned long flags,
  * shmem_getpage reports shmem_acct_block failure as -ENOSPC not -ENOMEM,
  * so that a failure on a sparse tmpfs mapping will give SIGBUS not OOM.
  */
-static inline int shmem_acct_block(unsigned long flags)
+static inline int shmem_acct_block(unsigned long flags, long pages)
 {
-	return (flags & VM_NORESERVE) ?
-		security_vm_enough_memory_mm(current->mm, VM_ACCT(PAGE_CACHE_SIZE)) : 0;
+	if (!(flags & VM_NORESERVE))
+		return 0;
+
+	return security_vm_enough_memory_mm(current->mm,
+			pages * VM_ACCT(PAGE_CACHE_SIZE));
 }
 
 static inline void shmem_unacct_blocks(unsigned long flags, long pages)
@@ -315,30 +318,55 @@ static int shmem_add_to_page_cache(struct page *page,
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
 
-	page_cache_get(page);
+	atomic_add(nr, &page->_count);
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
@@ -351,6 +379,8 @@ static void shmem_delete_from_page_cache(struct page *page, void *radswap)
 	struct address_space *mapping = page->mapping;
 	int error;
 
+	VM_BUG_ON_PAGE(PageCompound(page), page);
+
 	spin_lock_irq(&mapping->tree_lock);
 	error = shmem_radix_tree_replace(mapping, page->index, page, radswap);
 	page->mapping = NULL;
@@ -526,6 +556,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 			index = indices[i];
 			if (index >= end)
 				break;
+			VM_BUG_ON_PAGE(page_to_pgoff(page) != index, page);
 
 			if (radix_tree_exceptional_entry(page)) {
 				if (unfalloc)
@@ -537,8 +568,29 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 
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
@@ -614,8 +666,36 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
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
@@ -874,6 +954,7 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	swp_entry_t swap;
 	pgoff_t index;
 
+	VM_BUG_ON_PAGE(PageCompound(page), page);
 	BUG_ON(!PageLocked(page));
 	mapping = page->mapping;
 	index = page->index;
@@ -973,8 +1054,8 @@ redirty:
 	return 0;
 }
 
-#ifdef CONFIG_NUMA
 #ifdef CONFIG_TMPFS
+#ifdef CONFIG_NUMA
 static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
 {
 	char buffer[64];
@@ -998,68 +1079,129 @@ static struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
 	}
 	return mpol;
 }
+
+#else
+
+static void shmem_show_mpol(struct seq_file *seq, struct mempolicy *mpol)
+{
+}
+#endif /* CONFIG_NUMA */
 #endif /* CONFIG_TMPFS */
 
+static void shmem_pseudo_vma_init(struct vm_area_struct *vma,
+		struct shmem_inode_info *info, pgoff_t index)
+{
+	/* Create a pseudo vma that just contains the policy */
+	vma->vm_start = 0;
+	/* Bias interleave by inode number to distribute better across nodes */
+	vma->vm_pgoff = index + info->vfs_inode.i_ino;
+	vma->vm_ops = NULL;
+
+#ifdef CONFIG_NUMA
+	vma->vm_policy = mpol_shared_policy_lookup(&info->policy, index);
+#endif /* CONFIG_NUMA */
+}
+
+static void shmem_pseudo_vma_destroy(struct vm_area_struct *vma)
+{
+#ifdef CONFIG_NUMA
+	/* Drop reference taken by mpol_shared_policy_lookup() */
+	mpol_cond_put(vma->vm_policy);
+#endif
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
-
-	page = alloc_page_vma(gfp, &pvma, 0);
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
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
+	struct vm_area_struct pvma;
+	struct page *page;
+
+	shmem_pseudo_vma_init(&pvma, info, index);
+	page = alloc_page_vma(gfp, &pvma, 0);
+	shmem_pseudo_vma_destroy(&pvma);
+
+	return page;
 }
 
-static inline struct page *shmem_alloc_page(gfp_t gfp,
-			struct shmem_inode_info *info, pgoff_t index)
+static struct page *shmem_alloc_and_acct_page(gfp_t gfp,
+		struct shmem_inode_info *info, struct shmem_sb_info *sbinfo,
+		pgoff_t index, bool huge)
 {
-	return alloc_page(gfp);
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
+					sbinfo->max_blocks + nr) > 0)
+			goto unacct;
+		percpu_counter_add(&sbinfo->used_blocks, nr);
+	}
+
+	if (huge)
+		page = shmem_alloc_hugepage(gfp, info, index);
+	else
+		page = shmem_alloc_page(gfp, info, index);
+	if (page)
+		return page;
+
+	err = -ENOMEM;
+	if (sbinfo->max_blocks)
+		percpu_counter_add(&sbinfo->used_blocks, -nr);
+unacct:
+	shmem_unacct_blocks(info->flags, nr);
+failed:
+	return ERR_PTR(err);
 }
-#endif /* CONFIG_NUMA */
 
 #if !defined(CONFIG_NUMA) || !defined(CONFIG_TMPFS)
 static inline struct mempolicy *shmem_get_sbmpol(struct shmem_sb_info *sbinfo)
@@ -1167,6 +1309,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 	struct mem_cgroup *memcg;
 	struct page *page;
 	swp_entry_t swap;
+	pgoff_t hindex = index;
 	int error;
 	int once = 0;
 	int alloced = 0;
@@ -1283,24 +1426,30 @@ repeat:
 		swap_free(swap);
 
 	} else {
-		if (shmem_acct_block(info->flags)) {
-			error = -ENOSPC;
-			goto failed;
+		/* shmem_symlink() */
+		if (mapping->a_ops != &shmem_aops)
+			goto alloc_nohuge;
+		if (shmem_huge == SHMEM_HUGE_DENY)
+			goto alloc_nohuge;
+		if (shmem_huge != SHMEM_HUGE_FORCE && !sbinfo->huge)
+			goto alloc_nohuge;
+
+		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
+				index, true);
+		if (IS_ERR(page)) {
+alloc_nohuge:		page = shmem_alloc_and_acct_page(gfp, info, sbinfo,
+					index, false);
 		}
-		if (sbinfo->max_blocks) {
-			if (percpu_counter_compare(&sbinfo->used_blocks,
-						sbinfo->max_blocks) >= 0) {
-				error = -ENOSPC;
-				goto unacct;
-			}
-			percpu_counter_inc(&sbinfo->used_blocks);
+		if (IS_ERR(page)) {
+			error = PTR_ERR(page);
+			page = NULL;
+			goto failed;
 		}
 
-		page = shmem_alloc_page(gfp, info, index);
-		if (!page) {
-			error = -ENOMEM;
-			goto decused;
-		}
+		if (PageTransHuge(page))
+			hindex = round_down(index, HPAGE_PMD_NR);
+		else
+			hindex = index;
 
 		__SetPageSwapBacked(page);
 		__SetPageLocked(page);
@@ -1308,25 +1457,28 @@ repeat:
 			__SetPageReferenced(page);
 
 		error = mem_cgroup_try_charge(page, current->mm, gfp, &memcg,
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
@@ -1342,10 +1494,15 @@ clear:
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
 		if (sgp == SGP_DIRTY)
 			set_page_dirty(page);
@@ -1364,17 +1521,23 @@ clear:
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
+		percpu_counter_add(&sbinfo->used_blocks,
+				1 << compound_order(page));
+	shmem_unacct_blocks(info->flags, 1 << compound_order(page));
+
+	if (PageTransHuge(page)) {
+		unlock_page(page);
+		page_cache_release(page);
+		goto alloc_nohuge;
+	}
 failed:
 	if (swap.val && !shmem_confirm_swap(mapping, index, swap))
 		error = -EEXIST;
@@ -1715,12 +1878,23 @@ shmem_write_end(struct file *file, struct address_space *mapping,
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
 		if (copied < PAGE_CACHE_SIZE) {
 			unsigned from = pos & (PAGE_CACHE_SIZE - 1);
 			zero_user_segments(page, 0, from,
 					from + copied, PAGE_CACHE_SIZE);
 		}
-		SetPageUptodate(page);
+		SetPageUptodate(head);
 	}
 	set_page_dirty(page);
 	unlock_page(page);
diff --git a/mm/swap.c b/mm/swap.c
index 09fe5e97714a..5ee5118f45d4 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -291,6 +291,7 @@ static bool need_activate_page_drain(int cpu)
 
 void activate_page(struct page *page)
 {
+	page = compound_head(page);
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
 		struct pagevec *pvec = &get_cpu_var(activate_page_pvecs);
 
@@ -315,6 +316,7 @@ void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 
+	page = compound_head(page);
 	spin_lock_irq(&zone->lru_lock);
 	__activate_page(page, mem_cgroup_page_lruvec(page, zone), NULL);
 	spin_unlock_irq(&zone->lru_lock);
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
