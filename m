Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 415A66B025F
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 20:30:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id u190so215400888pfb.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 17:30:39 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id x64si5196980pfi.208.2016.04.15.17.24.21
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 17:24:21 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 29/29] khugepaged: add support of collapse for tmpfs/shmem pages
Date: Sat, 16 Apr 2016 03:24:00 +0300
Message-Id: <1460766240-84565-30-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
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
 include/linux/shmem_fs.h           |  24 +++
 include/trace/events/huge_memory.h |   3 +-
 mm/khugepaged.c                    | 359 ++++++++++++++++++++++++++++++++++++-
 mm/shmem.c                         |  83 +++++++--
 4 files changed, 452 insertions(+), 17 deletions(-)

diff --git a/include/linux/shmem_fs.h b/include/linux/shmem_fs.h
index ff2de4bab61f..7ecb7f54f64d 100644
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
@@ -71,6 +85,16 @@ static inline struct page *shmem_read_mapping_page(
 					mapping_gfp_mask(mapping));
 }
 
+static inline bool shmem_file(struct file *file)
+{
+       if (!file || !file->f_mapping)
+               return false;
+       return shmem_mapping(file->f_mapping);
+}
+
+extern bool shmem_charge(struct inode *inode, long pages);
+extern void shmem_uncharge(struct inode *inode, long pages);
+
 #ifdef CONFIG_TMPFS
 
 extern int shmem_add_seals(struct file *file, unsigned int seals);
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
index c4693fd12f76..dbea77a1356a 100644
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
@@ -292,7 +294,7 @@ struct attribute_group khugepaged_attr_group = {
 	.name = "khugepaged",
 };
 
-#define VM_NO_KHUGEPAGED (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
+#define VM_NO_KHUGEPAGED (VM_SPECIAL | VM_HUGETLB)
 
 int hugepage_madvise(struct vm_area_struct *vma,
 		     unsigned long *vm_flags, int advice)
@@ -813,6 +815,12 @@ static bool hugepage_vma_check(struct vm_area_struct *vma)
 	if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
 	    (vma->vm_flags & VM_NOHUGEPAGE))
 		return false;
+	if (shmem_file(vma->vm_file)) {
+		if (((vma->vm_start >> PAGE_SHIFT) & (HPAGE_PMD_NR - 1)) !=
+				(vma->vm_pgoff & (HPAGE_PMD_NR - 1)))
+			return false;
+		return true;
+	}
 	if (!vma->anon_vma || vma->vm_ops)
 		return false;
 	if (is_vma_temporary_stack(vma))
@@ -1146,6 +1154,334 @@ out:
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
+		/* We need exclusive mmap_sem to retract page table */
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
+	int nr = 0, result = SCAN_SUCCEED;
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
+
+	BUG_ON(!page_ref_freeze(new_page, 1));
+
+	index = start;
+	spin_lock_irq(&mapping->tree_lock);
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, start) {
+		int n = min(iter.index, end) - index;
+
+		if (n && !shmem_charge(mapping->host, n)) {
+			result = SCAN_FAIL;
+			break;
+		}
+		for (; index < min(iter.index, end); index++) {
+			radix_tree_insert(&mapping->page_tree, index,
+					new_page + (index % HPAGE_PMD_NR));
+		}
+		nr += n;
+
+		if (index >= end)
+			break;
+		page = radix_tree_deref_slot_protected(slot,
+				&mapping->tree_lock);
+		if (radix_tree_exceptional_entry(page)) {
+			spin_unlock_irq(&mapping->tree_lock);
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
+		if (!page_ref_freeze(page, 3)) {
+			result = SCAN_PAGE_COUNT;
+			goto out_lru;
+		}
+
+		list_add_tail(&page->lru, &pagelist);
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
+	if (result == SCAN_SUCCEED && index < end) {
+		int n = end - index;
+
+		if (!shmem_charge(mapping->host, n)) {
+			result = SCAN_FAIL;
+			goto tree_locked;
+		}
+
+		for (; index < n; index++) {
+			radix_tree_insert(&mapping->page_tree, index,
+					new_page + (index % HPAGE_PMD_NR));
+		}
+		nr += n;
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
+		if (nr) {
+			__mod_zone_page_state(zone, NR_FILE_PAGES, nr);
+			__mod_zone_page_state(zone, NR_SHMEM, nr);
+		}
+		local_irq_restore(flags);
+
+		retract_page_tables(mapping, start);
+
+		page_ref_unfreeze(new_page, HPAGE_PMD_NR);
+		SetPageUptodate(new_page);
+		mem_cgroup_commit_charge(new_page, memcg, false, true);
+		lru_cache_add_anon(new_page);
+		unlock_page(new_page);
+
+		*hpage = NULL;
+	} else {
+		shmem_uncharge(mapping->host, nr);
+		spin_lock_irq(&mapping->tree_lock);
+		radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
+				start) {
+			VM_BUG_ON(iter.index >= end);
+			page = list_first_entry_or_null(&pagelist,
+					struct page, lru);
+			if (!page || iter.index < page->index) {
+				if (!nr)
+					break;
+				radix_tree_replace_slot(slot, NULL);
+				nr--;
+				continue;
+			}
+
+			VM_BUG_ON_PAGE(page->index != iter.index, page);
+
+			list_del(&page->lru);
+			page_ref_unfreeze(page, 2);
+			radix_tree_replace_slot(slot, page);
+			spin_unlock_irq(&mapping->tree_lock);
+			putback_lru_page(page);
+			unlock_page(page);
+			spin_lock_irq(&mapping->tree_lock);
+		}
+		VM_BUG_ON(nr);
+		spin_unlock_irq(&mapping->tree_lock);
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
+	pgoff_t pgoff = start;
+	int present, swap;
+	int node = NUMA_NO_NODE;
+	int result = SCAN_SUCCEED;
+
+restart:
+	present = 0;
+	swap = 0;
+	memset(khugepaged_node_load, 0, sizeof(khugepaged_node_load));
+
+	rcu_read_lock();
+	radix_tree_for_each_slot(slot, &mapping->page_tree, &iter, pgoff) {
+		if (iter.index > start + HPAGE_PMD_NR)
+			break;
+
+		page = radix_tree_deref_slot(slot);
+		if (radix_tree_deref_retry(page))
+			goto restart;
+
+		if (radix_tree_exception(page)) {
+			if (++swap > khugepaged_max_ptes_swap) {
+				result = SCAN_EXCEED_SWAP_PTE;
+				break;
+			}
+			continue;
+		}
+
+		if (PageCompound(page)) {
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
+		/* XXX: need PageReferenced()/page_is_yound() checks ? */
+
+		present++;
+
+		if (need_resched()) {
+			cond_resched_rcu();
+			pgoff = iter.index + 1;
+			goto restart;
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
 static void collect_mm_slot(struct mm_slot *mm_slot)
 {
 	struct mm_struct *mm = mm_slot->mm;
@@ -1222,6 +1558,8 @@ skip:
 		if (khugepaged_scan.address < hstart)
 			khugepaged_scan.address = hstart;
 		VM_BUG_ON(khugepaged_scan.address & ~HPAGE_PMD_MASK);
+		if (shmem_file(vma->vm_file) && !shmem_huge_enabled(vma))
+			goto skip;
 
 		while (khugepaged_scan.address < hend) {
 			int ret;
@@ -1232,9 +1570,20 @@ skip:
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
index 0ebf2e3a2239..2f378a928213 100644
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
@@ -190,6 +181,33 @@ static inline void shmem_unacct_blocks(unsigned long flags, long pages)
 		vm_unacct_memory(pages * VM_ACCT(PAGE_SIZE));
 }
 
+bool shmem_charge(struct inode *inode, long pages)
+{
+	struct shmem_inode_info *info = SHMEM_I(inode);
+	struct shmem_sb_info *sbinfo = SHMEM_SB(inode->i_sb);
+
+	if (shmem_acct_block(info->flags, pages))
+		return false;
+	if (!sbinfo->max_blocks)
+		return true;
+	if (percpu_counter_compare(&sbinfo->used_blocks,
+					sbinfo->max_blocks + pages) > 0) {
+		shmem_unacct_blocks(info->flags, pages);
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
+	percpu_counter_sub(&sbinfo->used_blocks, pages);
+	shmem_unacct_blocks(info->flags, pages);
+}
+
 static const struct super_operations shmem_ops;
 static const struct address_space_operations shmem_aops;
 static const struct file_operations shmem_file_operations;
@@ -1852,6 +1870,11 @@ static int shmem_mmap(struct file *file, struct vm_area_struct *vma)
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
 
@@ -3752,6 +3775,37 @@ static ssize_t shmem_enabled_store(struct kobject *kobj,
 
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
@@ -3931,6 +3985,13 @@ int shmem_zero_setup(struct vm_area_struct *vma)
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
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
