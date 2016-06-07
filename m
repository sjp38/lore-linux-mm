Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD41828E1
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 07:08:20 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ug1so68535639pab.3
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 04:08:20 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id g10si32695264pac.240.2016.06.07.04.01.05
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 04:01:05 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased 29/32] khugepaged: add support of collapse for tmpfs/shmem pages
Date: Tue,  7 Jun 2016 14:00:43 +0300
Message-Id: <1465297246-98985-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1465297246-98985-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch extends khugepaged to support collapse of tmpfs/shmem pages.
We share fair amount of infrastructure with anon-THP collapse.

Few design points:

  - First we are looking for VMA which can be suitable for mapping huge
    page;

  - If the VMA maps shmem file, the rest scan/collapse operations
    operates on page cache, not on page tables as in anon VMA case.

  - khugepaged_scan_shmem() finds a range which is suitable for huge
    page. The scan is lockless and shouldn't disturb system too much.

  - once the candidate for collapse is found, collapse_shmem() attempts
    to create a huge page:

      + scan over radix tree, making the range point to new huge page;

      + new huge page is not-uptodate, locked and freezed (refcount
        is 0), so nobody can touch them until we say so.

      + we swap in pages during the scan. khugepaged_scan_shmem()
        filters out ranges with more than khugepaged_max_ptes_swap
	swapped out pages. It's HPAGE_PMD_NR/8 by default.

      + old pages are isolated, unmapped and put to local list in case
        to be restored back if collapse failed.

  - if collapse succeed, we retract pte page tables from VMAs where huge
    pages mapping is possible. The huge page will be mapped as PMD on
    next minor fault into the range.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/shmem_fs.h           |  23 ++
 include/trace/events/huge_memory.h |   3 +-
 mm/khugepaged.c                    | 435 ++++++++++++++++++++++++++++++++++++-
 mm/shmem.c                         |  56 ++++-
 4 files changed, 500 insertions(+), 17 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index 94eaaa2c6ad9..0890f700a546 100644
--- a/include/linux/shmem_fs.h
+++ b/include/linux/shmem_fs.h
@@ -54,6 +54,7 @@ extern unsigned long shmem_get_unmapped_area(struct file *, unsigned long addr,
 		unsigned long len, unsigned long pgoff, unsigned long flags);
 extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 extern bool shmem_mapping(struct address_space *mapping);
+extern bool shmem_huge_enabled(struct vm_area_struct *vma);
 extern void shmem_unlock_mapping(struct address_space *mapping);
 extern struct page *shmem_read_mapping_page_gfp(struct address_space *mapping,
 					pgoff_t index, gfp_t gfp_mask);
@@ -64,6 +65,19 @@ extern unsigned long shmem_swap_usage(struct vm_area_struct *vma);
 extern unsigned long shmem_partial_swap_usage(struct address_space *mapping,
 						pgoff_t start, pgoff_t end);
 
+/* Flag allocation requirements to shmem_getpage */
+enum sgp_type {
+	SGP_READ,	/* don't exceed i_size, don't allocate page */
+	SGP_CACHE,	/* don't exceed i_size, may allocate page */
+	SGP_NOHUGE,	/* like SGP_CACHE, but no huge pages */
+	SGP_HUGE,	/* like SGP_CACHE, huge pages preferred */
+	SGP_WRITE,	/* may exceed i_size, may allocate !Uptodate page */
+	SGP_FALLOC,	/* like SGP_WRITE, but make existing page Uptodate */
+};
+
+extern int shmem_getpage(struct inode *inode, pgoff_t index,
+		struct page **pagep, enum sgp_type sgp);
+
 static inline struct page *shmem_read_mapping_page(
 				struct address_space *mapping, pgoff_t index)
 {
@@ -71,6 +85,15 @@ static inline struct page *shmem_read_mapping_page(
 					mapping_gfp_mask(mapping));
 }
 
+static inline bool shmem_file(struct file *file)
+{
+	if (!IS_ENABLED(CONFIG_SHMEM))
+		return false;
+	if (!file || !file->f_mapping)
+		return false;
+	return shmem_mapping(file->f_mapping);
+}
+
 extern bool shmem_charge(struct inode *inode, long pages);
 extern void shmem_uncharge(struct inode *inode, long pages);
 
diff --git a/include/trace/events/huge_memory.h b/include/trace/events/huge_memory.h
index bda21183eb05..830d47d5ca41 100644
--- a/include/trace/events/huge_memory.h
+++ b/include/trace/events/huge_memory.h
@@ -29,7 +29,8 @@
 	EM( SCAN_DEL_PAGE_LRU,		"could_not_delete_page_from_lru")\
 	EM( SCAN_ALLOC_HUGE_PAGE_FAIL,	"alloc_huge_page_failed")	\
 	EM( SCAN_CGROUP_CHARGE_FAIL,	"ccgroup_charge_failed")	\
-	EMe( SCAN_EXCEED_SWAP_PTE,	"exceed_swap_pte")
+	EM( SCAN_EXCEED_SWAP_PTE,	"exceed_swap_pte")		\
+	EMe(SCAN_TRUNCATED,		"truncated")			\
 
 #undef EM
 #undef EMe
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index 84c2bf01ae42..8f333663510a 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -14,6 +14,7 @@
 #include <linux/userfaultfd_k.h>
 #include <linux/page_idle.h>
 #include <linux/swapops.h>
+#include <linux/shmem_fs.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -42,7 +43,8 @@ enum scan_result {
 	SCAN_DEL_PAGE_LRU,
 	SCAN_ALLOC_HUGE_PAGE_FAIL,
 	SCAN_CGROUP_CHARGE_FAIL,
-	SCAN_EXCEED_SWAP_PTE
+	SCAN_EXCEED_SWAP_PTE,
+	SCAN_TRUNCATED,
 };
 
 #define CREATE_TRACE_POINTS
@@ -296,7 +298,7 @@ struct attribute_group khugepaged_attr_group = {
 	.name = "khugepaged",
 };
 
-#define VM_NO_KHUGEPAGED (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
+#define VM_NO_KHUGEPAGED (VM_SPECIAL | VM_HUGETLB)
 
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
@@ -823,6 +825,10 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
 	    (vma->vm_flags & VM_NOHUGEPAGE))
 		return false;
+	if (shmem_file(vma->vm_file)) {
+		return IS_ALIGNED((vma->vm_start >> PAGE_SHIFT) - vma->vm_pgoff,
+				HPAGE_PMD_NR);
+	}
 	if (!vma->anon_vma || vma->vm_ops)
 		return false;
 	if (is_vma_temporary_stack(vma))
@@ -1203,6 +1209,412 @@ out:
 	return ret;
 }
 
+#ifdef CONFIG_SHMEM
+static void retract_page_tables(struct address_space *mapping, pgoff_t pgoff)
+{
+	struct vm_area_struct *vma;
+	unsigned long addr;
+	pmd_t *pmd, _pmd;
+
+	i_mmap_lock_write(mapping);
+	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
+		/* probably overkill */
+		if (vma->anon_vma)
+			continue;
+		addr = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
+		if (addr & ~HPAGE_PMD_MASK)
+			continue;
+		if (vma->vm_end < addr + HPAGE_PMD_SIZE)
+			continue;
+		pmd = mm_find_pmd(vma->vm_mm, addr);
+		if (!pmd)
+			continue;
+		/*
+		 * We need exclusive mmap_sem to retract page table.
+		 * If trylock fails we would end up with pte-mapped THP after
+		 * re-fault. Not ideal, but it's more important to not disturb
+		 * the system too much.
+		 */
+		if (down_write_trylock(&vma->vm_mm->mmap_sem)) {
+			spinlock_t *ptl = pmd_lock(vma->vm_mm, pmd);
+			/* assume page table is clear */
+			_pmd = pmdp_collapse_flush(vma, addr, pmd);
+			spin_unlock(ptl);
+			up_write(&vma->vm_mm->mmap_sem);
+			atomic_long_dec(&vma->vm_mm->nr_ptes);
+			pte_free(vma->vm_mm, pmd_pgtable(_pmd));
+		}
+	}
+	i_mmap_unlock_write(mapping);
+}
+
+/**
+ * collapse_shmem - collapse small tmpfs/shmem pages into huge one.
+ *
+ * Basic scheme is simple, details are more complex:
+ *  - allocate and freeze a new huge page;
+ *  - scan over radix tree replacing old pages the new one
+ *    + swap in pages if necessary;
+ *    + fill in gaps;
+ *    + keep old pages around in case if rollback is required;
+ *  - if replacing succeed:
+ *    + copy data over;
+ *    + free old pages;
+ *    + unfreeze huge page;
+ *  - if replacing failed;
+ *    + put all pages back and unfreeze them;
+ *    + restore gaps in the radix-tree;
+ *    + free huge page;
+ */
+static void collapse_shmem(struct mm_struct *mm,
+		struct address_space *mapping, pgoff_t start,
+		struct page **hpage, int node)
+{
+	gfp_t gfp;
+	struct page *page, *new_page, *tmp;
+	struct mem_cgroup *memcg;
+	pgoff_t index, end = start + HPAGE_PMD_NR;
+	LIST_HEAD(pagelist);
+	struct radix_tree_iter iter;
+	void **slot;
+	int nr_none = 0, result = SCAN_SUCCEED;
+
+	VM_BUG_ON(start & (HPAGE_PMD_NR - 1));
+
+	/* Only allocate from the target node */
+	gfp = alloc_hugepage_khugepaged_gfpmask() |
+		__GFP_OTHER_NODE | __GFP_THISNODE;
+
+	new_page = khugepaged_alloc_page(hpage, gfp, node);
+	if (!new_page) {
+		result = SCAN_ALLOC_HUGE_PAGE_FAIL;
+		goto out;
+	}
+
+	if (unlikely(mem_cgroup_try_charge(new_page, mm, gfp, &memcg, true))) {
+		result = SCAN_CGROUP_CHARGE_FAIL;
+		goto out;
+	}
+
+	new_page->index = start;
+	new_page->mapping = mapping;
+	__SetPageSwapBacked(new_page);
+	__SetPageLocked(new_page);
+	BUG_ON(!page_ref_freeze(new_page, 1));
+
+
+	/*
+	 * At this point the new_page is 'frozen' (page_count() is zero), locked
+	 * and not up-to-date. It's safe to insert it into radix tree, because
+	 * nobody would be able to map it or use it in other way until we
+	 * unfreeze it.
+	 */
+
+	index = start;
+	spin_lock_irq(&mapping->tree_lock);
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+		int n = min(iter.index, end) - index;
+
+		/*
+		 * Handle holes in the radix tree: charge it from shmem and
+		 * insert relevant subpage of new_page into the radix-tree.
+		 */
+		if (n && !shmem_charge(mapping->host, n)) {
+			result = SCAN_FAIL;
+			break;
+		}
+		nr_none += n;
+		for (; index < min(iter.index, end); index++) {
+			radix_tree_insert(&mapping->page_tree, index,
+					new_page + (index % HPAGE_PMD_NR));
+		}
+
+		/* We are done. */
+		if (index >= end)
+			break;
+
+		page = radix_tree_deref_slot_protected(slot,
+				&mapping->tree_lock);
+		if (radix_tree_exceptional_entry(page) || !PageUptodate(page)) {
+			spin_unlock_irq(&mapping->tree_lock);
+			/* swap in or instantiate fallocated page */
+			if (shmem_getpage(mapping->host, index, &page,
+						SGP_NOHUGE)) {
+				result = SCAN_FAIL;
+				goto tree_unlocked;
+			}
+			spin_lock_irq(&mapping->tree_lock);
+		} else if (trylock_page(page)) {
+			get_page(page);
+		} else {
+			result = SCAN_PAGE_LOCK;
+			break;
+		}
+
+		/*
+		 * The page must be locked, so we can drop the tree_lock
+		 * without racing with truncate.
+		 */
+		VM_BUG_ON_PAGE(!PageLocked(page), page);
+		VM_BUG_ON_PAGE(!PageUptodate(page), page);
+		VM_BUG_ON_PAGE(PageTransCompound(page), page);
+
+		if (page_mapping(page) != mapping) {
+			result = SCAN_TRUNCATED;
+			goto out_unlock;
+		}
+		spin_unlock_irq(&mapping->tree_lock);
+
+		if (isolate_lru_page(page)) {
+			result = SCAN_DEL_PAGE_LRU;
+			goto out_isolate_failed;
+		}
+
+		if (page_mapped(page))
+			unmap_mapping_range(mapping, index << PAGE_SHIFT,
+					PAGE_SIZE, 0);
+
+		spin_lock_irq(&mapping->tree_lock);
+
+		VM_BUG_ON_PAGE(page_mapped(page), page);
+
+		/*
+		 * The page is expected to have page_count() == 3:
+		 *  - we hold a pin on it;
+		 *  - one reference from radix tree;
+		 *  - one from isolate_lru_page;
+		 */
+		if (!page_ref_freeze(page, 3)) {
+			result = SCAN_PAGE_COUNT;
+			goto out_lru;
+		}
+
+		/*
+		 * Add the page to the list to be able to undo the collapse if
+		 * something go wrong.
+		 */
+		list_add_tail(&page->lru, &pagelist);
+
+		/* Finally, replace with the new page. */
+		radix_tree_replace_slot(slot,
+				new_page + (index % HPAGE_PMD_NR));
+
+		index++;
+		continue;
+out_lru:
+		spin_unlock_irq(&mapping->tree_lock);
+		putback_lru_page(page);
+out_isolate_failed:
+		unlock_page(page);
+		put_page(page);
+		goto tree_unlocked;
+out_unlock:
+		unlock_page(page);
+		put_page(page);
+		break;
+	}
+
+	/*
+	 * Handle hole in radix tree at the end of the range.
+	 * This code only triggers if there's nothing in radix tree
+	 * beyond 'end'.
+	 */
+	if (result == SCAN_SUCCEED && index < end) {
+		int n = end - index;
+
+		if (!shmem_charge(mapping->host, n)) {
+			result = SCAN_FAIL;
+			goto tree_locked;
+		}
+
+		for (; index < end; index++) {
+			radix_tree_insert(&mapping->page_tree, index,
+					new_page + (index % HPAGE_PMD_NR));
+		}
+		nr_none += n;
+	}
+
+tree_locked:
+	spin_unlock_irq(&mapping->tree_lock);
+tree_unlocked:
+
+	if (result == SCAN_SUCCEED) {
+		unsigned long flags;
+		struct zone *zone = page_zone(new_page);
+
+		/*
+		 * Replacing old pages with new one has succeed, now we need to
+		 * copy the content and free old pages.
+		 */
+		list_for_each_entry_safe(page, tmp, &pagelist, lru) {
+			copy_highpage(new_page + (page->index % HPAGE_PMD_NR),
+					page);
+			list_del(&page->lru);
+			unlock_page(page);
+			page_ref_unfreeze(page, 1);
+			page->mapping = NULL;
+			ClearPageActive(page);
+			ClearPageUnevictable(page);
+			put_page(page);
+		}
+
+		local_irq_save(flags);
+		__inc_zone_page_state(new_page, NR_SHMEM_THPS);
+		if (nr_none) {
+			__mod_zone_page_state(zone, NR_FILE_PAGES, nr_none);
+			__mod_zone_page_state(zone, NR_SHMEM, nr_none);
+		}
+		local_irq_restore(flags);
+
+		/*
+		 * Remove pte page tables, so we can re-faulti
+		 * the page as huge.
+		 */
+		retract_page_tables(mapping, start);
+
+		/* Everything is ready, let's unfreeze the new_page */
+		set_page_dirty(new_page);
+		SetPageUptodate(new_page);
+		page_ref_unfreeze(new_page, HPAGE_PMD_NR);
+		mem_cgroup_commit_charge(new_page, memcg, false, true);
+		lru_cache_add_anon(new_page);
+		unlock_page(new_page);
+
+		*hpage = NULL;
+	} else {
+		/* Something went wrong: rollback changes to the radix-tree */
+		shmem_uncharge(mapping->host, nr_none);
+		spin_lock_irq(&mapping->tree_lock);
+		radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
+				start) {
+			if (iter.index >= end)
+				break;
+			page = list_first_entry_or_null(&pagelist,
+					struct page, lru);
+			if (!page || iter.index < page->index) {
+				if (!nr_none)
+					break;
+				/* Put holes back where they were */
+				radix_tree_replace_slot(slot, NULL);
+				nr_none--;
+				continue;
+			}
+
+			VM_BUG_ON_PAGE(page->index != iter.index, page);
+
+			/* Unfreeze the page. */
+			list_del(&page->lru);
+			page_ref_unfreeze(page, 2);
+			radix_tree_replace_slot(slot, page);
+			spin_unlock_irq(&mapping->tree_lock);
+			putback_lru_page(page);
+			unlock_page(page);
+			spin_lock_irq(&mapping->tree_lock);
+		}
+		VM_BUG_ON(nr_none);
+		spin_unlock_irq(&mapping->tree_lock);
+
+		/* Unfreeze new_page, caller would take care about freeing it */
+		page_ref_unfreeze(new_page, 1);
+		mem_cgroup_cancel_charge(new_page, memcg, true);
+		unlock_page(new_page);
+		new_page->mapping = NULL;
+	}
+out:
+	VM_BUG_ON(!list_empty(&pagelist));
+	/* TODO: tracepoints */
+}
+
+static void khugepaged_scan_shmem(struct mm_struct *mm,
+		struct address_space *mapping,
+		pgoff_t start, struct page **hpage)
+{
+	struct page *page = NULL;
+	struct radix_tree_iter iter;
+	void **slot;
+	int present, swap;
+	int node = NUMA_NO_NODE;
+	int result = SCAN_SUCCEED;
+
+	present = 0;
+	swap = 0;
+	memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
+	rcu_read_lock();
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+		if (iter.index >= start + HPAGE_PMD_NR)
+			break;
+
+		page = radix_tree_deref_slot(slot);
+		if (radix_tree_deref_retry(page)) {
+			slot = radix_tree_iter_retry(&iter);
+			continue;
+		}
+
+		if (radix_tree_exception(page)) {
+			if (++swap > khugepaged_max_ptes_swap) {
+				result = SCAN_EXCEED_SWAP_PTE;
+				break;
+			}
+			continue;
+		}
+
+		if (PageTransCompound(page)) {
+			result = SCAN_PAGE_COMPOUND;
+			break;
+		}
+
+		node = page_to_nid(page);
+		if (khugepaged_scan_abort(node)) {
+			result = SCAN_SCAN_ABORT;
+			break;
+		}
+		khugepaged_node_load[node]++;
+
+		if (!PageLRU(page)) {
+			result = SCAN_PAGE_LRU;
+			break;
+		}
+
+		if (page_count(page) != 1 + page_mapcount(page)) {
+			result = SCAN_PAGE_COUNT;
+			break;
+		}
+
+		/*
+		 * We probably should check if the page is referenced here, but
+		 * nobody would transfer pte_young() to PageReferenced() for us.
+		 * And rmap walk here is just too costly...
+		 */
+
+		present++;
+
+		if (need_resched()) {
+			cond_resched_rcu();
+			slot = radix_tree_iter_next(&iter);
+		}
+	}
+	rcu_read_unlock();
+
+	if (result == SCAN_SUCCEED) {
+		if (present < HPAGE_PMD_NR - khugepaged_max_ptes_none) {
+			result = SCAN_EXCEED_NONE_PTE;
+		} else {
+			node = khugepaged_find_target_node();
+			collapse_shmem(mm, mapping, start, hpage, node);
+		}
+	}
+
+	/* TODO: tracepoints */
+}
+#else
+static void khugepaged_scan_shmem(struct mm_struct *mm,
+		struct address_space *mapping,
+		pgoff_t start, struct page **hpage)
+{
+	BUILD_BUG();
+}
+#endif
+
 static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
 					    struct page **hpage)
 	__releases(&khugepaged_mm_lock)
@@ -1266,6 +1678,8 @@ skip:
 		if (khugepaged_scan.address < hstart)
 			khugepaged_scan.address = hstart;
 		VM_BUG_ON(khugepaged_scan.address & ~HPAGE_PMD_MASK);
+		if (shmem_file(vma->vm_file) && !shmem_huge_enabled(vma))
+			goto skip;
 
 		while (khugepaged_scan.address < hend) {
 			int ret;
@@ -1276,9 +1690,20 @@ skip:
 			VM_BUG_ON(khugepaged_scan.address < hstart ||
 				  khugepaged_scan.address + HPAGE_PMD_SIZE >
 				  hend);
-			ret = khugepaged_scan_pmd(mm, vma,
-						  khugepaged_scan.address,
-						  hpage);
+			if (shmem_file(vma->vm_file)) {
+				struct file *file = get_file(vma->vm_file);
+				pgoff_t pgoff = linear_page_index(vma,
+						khugepaged_scan.address);
+				up_read(&mm->mmap_sem);
+				ret = 1;
+				khugepaged_scan_shmem(mm, file->f_mapping,
+						pgoff, hpage);
+				fput(file);
+			} else {
+				ret = khugepaged_scan_pmd(mm, vma,
+						khugepaged_scan.address,
+						hpage);
+			}
 			/* move to next address */
 			khugepaged_scan.address += HPAGE_PMD_SIZE;
 			progress += HPAGE_PMD_NR;
diff --git a/mm/shmem.c b/mm/shmem.c
index 6766eeadf48a..a63bc49903e8 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -32,6 +32,7 @@
 #include <linux/export.h>
 #include <linux/swap.h>
 #include <linux/uio.h>
+#include <linux/khugepaged.h>
 
 static struct vfsmount *shm_mnt;
 
@@ -97,16 +98,6 @@ struct shmem_falloc {
 	pgoff_t nr_unswapped;	/* how often writepage refused to swap out */
 };
 
-/* Flag allocation requirements to shmem_getpage */
-enum sgp_type {
-	SGP_READ,	/* don't exceed i_size, don't allocate page */
-	SGP_CACHE,	/* don't exceed i_size, may allocate page */
-	SGP_NOHUGE,	/* like SGP_CACHE, but no huge pages */
-	SGP_HUGE,	/* like SGP_CACHE, huge pages preferred */
-	SGP_WRITE,	/* may exceed i_size, may allocate !Uptodate page */
-	SGP_FALLOC,	/* like SGP_WRITE, but make existing page Uptodate */
-};
-
 #ifdef CONFIG_TMPFS
 static unsigned long shmem_default_max_blocks(void)
 {
@@ -126,7 +117,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp,
 		gfp_t gfp, struct mm_struct *fault_mm, int *fault_type);
 
-static inline int shmem_getpage(struct inode *inode, pgoff_t index,
+int shmem_getpage(struct inode *inode, pgoff_t index,
 		struct page **pagep, enum sgp_type sgp)
 {
 	return shmem_getpage_gfp(inode, index, pagep, sgp,
@@ -1899,6 +1890,11 @@ static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
 {
 	file_accessed(file);
 	vma->vm_ops = &shmem_vm_ops;
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+			((vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK) <
+			(vma->vm_end & HPAGE_PMD_MASK)) {
+		khugepaged_enter(vma, vma->vm_flags);
+	}
 	return 0;
 }
 
@@ -3801,6 +3797,37 @@ static ssize_t shmem_enabled_store(struct kobject *kobj,
 
 struct kobj_attribute shmem_enabled_attr =
 	__ATTR(shmem_enabled, 0644, shmem_enabled_show, shmem_enabled_store);
+
+bool shmem_huge_enabled(struct vm_area_struct *vma)
+{
+	struct inode *inode = file_inode(vma->vm_file);
+	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+	loff_t i_size;
+	pgoff_t off;
+
+	if (shmem_huge == SHMEM_HUGE_FORCE)
+		return true;
+	if (shmem_huge == SHMEM_HUGE_DENY)
+		return false;
+	switch (sbinfo->huge) {
+		case SHMEM_HUGE_NEVER:
+			return false;
+		case SHMEM_HUGE_ALWAYS:
+			return true;
+		case SHMEM_HUGE_WITHIN_SIZE:
+			off = round_up(vma->vm_pgoff, HPAGE_PMD_NR);
+			i_size = round_up(i_size_read(inode), PAGE_SIZE);
+			if (i_size >= HPAGE_PMD_SIZE &&
+					i_size >> PAGE_SHIFT >= off)
+				return true;
+		case SHMEM_HUGE_ADVISE:
+			/* TODO: implement fadvise() hints */
+			return (vma->vm_flags & VM_HUGEPAGE);
+		default:
+			VM_BUG_ON(1);
+			return false;
+	}
+}
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE && CONFIG_SYSFS */
 
 #else /* !CONFIG_SHMEM */
@@ -3980,6 +4007,13 @@ int shmem_zero_setup(struct vm_area_struct *vma)
 		fput(vma->vm_file);
 	vma->vm_file = file;
 	vma->vm_ops = &shmem_vm_ops;
+
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE) &&
+			((vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK) <
+			(vma->vm_end & HPAGE_PMD_MASK)) {
+		khugepaged_enter(vma, vma->vm_flags);
+	}
+
 	return 0;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
