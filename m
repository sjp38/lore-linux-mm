Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 4A1F16B0096
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 12:15:12 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so66300eek.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 09:15:11 -0800 (PST)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 14/31] mm/mpol: Create special PROT_NONE infrastructure
Date: Tue, 13 Nov 2012 18:13:37 +0100
Message-Id: <1352826834-11774-15-git-send-email-mingo@kernel.org>
In-Reply-To: <1352826834-11774-1-git-send-email-mingo@kernel.org>
References: <1352826834-11774-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

In order to facilitate a lazy -- fault driven -- migration of pages,
create a special transient PROT_NONE variant, we can then use the
'spurious' protection faults to drive our migrations from.

Pages that already had an effective PROT_NONE mapping will not
be detected to generate these 'spuriuos' faults for the simple reason
that we cannot distinguish them on their protection bits, see
pte_numa().

This isn't a problem since PROT_NONE (and possible PROT_WRITE with
dirty tracking) aren't used or are rare enough for us to not care
about their placement.

Suggested-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Paul Turner <pjt@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Link: http://lkml.kernel.org/n/tip-0g5k80y4df8l83lha9j75xph@git.kernel.org
[ fixed various cross-arch and THP/!THP details ]
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 include/linux/huge_mm.h | 19 +++++++++++++
 include/linux/mm.h      | 18 ++++++++++++
 mm/huge_memory.c        | 32 +++++++++++++++++++++
 mm/memory.c             | 75 ++++++++++++++++++++++++++++++++++++++++++++-----
 mm/mprotect.c           | 24 +++++++++++-----
 5 files changed, 154 insertions(+), 14 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index b31cb7d..4f0f948 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -159,6 +159,13 @@ static inline struct page *compound_trans_head(struct page *page)
 	}
 	return page;
 }
+
+extern bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd);
+
+extern void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmd,
+				  unsigned int flags, pmd_t orig_pmd);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -195,6 +202,18 @@ static inline int pmd_trans_huge_lock(pmd_t *pmd,
 {
 	return 0;
 }
+
+static inline bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd)
+{
+	return false;
+}
+
+static inline void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+				  unsigned long address, pmd_t *pmd,
+				  unsigned int flags, pmd_t orig_pmd)
+{
+}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2a32cf8..0025bf9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1091,6 +1091,9 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
 extern unsigned long do_mremap(unsigned long addr,
 			       unsigned long old_len, unsigned long new_len,
 			       unsigned long flags, unsigned long new_addr);
+extern void change_protection(struct vm_area_struct *vma, unsigned long start,
+			      unsigned long end, pgprot_t newprot,
+			      int dirty_accountable);
 extern int mprotect_fixup(struct vm_area_struct *vma,
 			  struct vm_area_struct **pprev, unsigned long start,
 			  unsigned long end, unsigned long newflags);
@@ -1561,6 +1564,21 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
 }
 #endif
 
+static inline pgprot_t vma_prot_none(struct vm_area_struct *vma)
+{
+	/*
+	 * obtain PROT_NONE by removing READ|WRITE|EXEC privs
+	 */
+	vm_flags_t vmflags = vma->vm_flags & ~(VM_READ|VM_WRITE|VM_EXEC);
+	return pgprot_modify(vma->vm_page_prot, vm_get_page_prot(vmflags));
+}
+
+static inline void
+change_prot_none(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+{
+	change_protection(vma, start, end, vma_prot_none(vma), 0);
+}
+
 struct vm_area_struct *find_extend_vma(struct mm_struct *, unsigned long addr);
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 176fe3d..6924edf 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -725,6 +725,38 @@ out:
 	return handle_pte_fault(mm, vma, address, pte, pmd, flags);
 }
 
+bool pmd_numa(struct vm_area_struct *vma, pmd_t pmd)
+{
+	/*
+	 * See pte_numa().
+	 */
+	if (pmd_same(pmd, pmd_modify(pmd, vma->vm_page_prot)))
+		return false;
+
+	return pmd_same(pmd, pmd_modify(pmd, vma_prot_none(vma)));
+}
+
+void do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			   unsigned long address, pmd_t *pmd,
+			   unsigned int flags, pmd_t entry)
+{
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(*pmd, entry)))
+		goto out_unlock;
+
+	/* do fancy stuff */
+
+	/* change back to regular protection */
+	entry = pmd_modify(entry, vma->vm_page_prot);
+	if (pmdp_set_access_flags(vma, haddr, pmd, entry, 1))
+		update_mmu_cache_pmd(vma, address, entry);
+
+out_unlock:
+	spin_unlock(&mm->page_table_lock);
+}
+
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 		  struct vm_area_struct *vma)
diff --git a/mm/memory.c b/mm/memory.c
index fb135ba..e3e8ab2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1464,6 +1464,25 @@ int zap_vma_ptes(struct vm_area_struct *vma, unsigned long address,
 }
 EXPORT_SYMBOL_GPL(zap_vma_ptes);
 
+static bool pte_numa(struct vm_area_struct *vma, pte_t pte)
+{
+	/*
+	 * If we have the normal vma->vm_page_prot protections we're not a
+	 * 'special' PROT_NONE page.
+	 *
+	 * This means we cannot get 'special' PROT_NONE faults from genuine
+	 * PROT_NONE maps, nor from PROT_WRITE file maps that do dirty
+	 * tracking.
+	 *
+	 * Neither case is really interesting for our current use though so we
+	 * don't care.
+	 */
+	if (pte_same(pte, pte_modify(pte, vma->vm_page_prot)))
+		return false;
+
+	return pte_same(pte, pte_modify(pte, vma_prot_none(vma)));
+}
+
 /**
  * follow_page - look up a page descriptor from a user-virtual address
  * @vma: vm_area_struct mapping @address
@@ -3433,6 +3452,41 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
+static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			unsigned long address, pte_t *ptep, pmd_t *pmd,
+			unsigned int flags, pte_t entry)
+{
+	spinlock_t *ptl;
+	int ret = 0;
+
+	if (!pte_unmap_same(mm, pmd, ptep, entry))
+		goto out;
+
+	/*
+	 * Do fancy stuff...
+	 */
+
+	/*
+	 * OK, nothing to do,.. change the protection back to what it
+	 * ought to be.
+	 */
+	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (unlikely(!pte_same(*ptep, entry)))
+		goto unlock;
+
+	flush_cache_page(vma, address, pte_pfn(entry));
+
+	ptep_modify_prot_start(mm, address, ptep);
+	entry = pte_modify(entry, vma->vm_page_prot);
+	ptep_modify_prot_commit(mm, address, ptep, entry);
+
+	update_mmu_cache(vma, address, ptep);
+unlock:
+	pte_unmap_unlock(ptep, ptl);
+out:
+	return ret;
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3471,6 +3525,9 @@ int handle_pte_fault(struct mm_struct *mm,
 					pte, pmd, flags, entry);
 	}
 
+	if (pte_numa(vma, entry))
+		return do_numa_page(mm, vma, address, pte, pmd, flags, entry);
+
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*pte, entry)))
@@ -3535,13 +3592,16 @@ retry:
 							  pmd, flags);
 	} else {
 		pmd_t orig_pmd = *pmd;
-		int ret;
+		int ret = 0;
 
 		barrier();
-		if (pmd_trans_huge(orig_pmd)) {
-			if (flags & FAULT_FLAG_WRITE &&
-			    !pmd_write(orig_pmd) &&
-			    !pmd_trans_splitting(orig_pmd)) {
+		if (pmd_trans_huge(orig_pmd) && !pmd_trans_splitting(orig_pmd)) {
+			if (pmd_numa(vma, orig_pmd)) {
+				do_huge_pmd_numa_page(mm, vma, address, pmd,
+						      flags, orig_pmd);
+			}
+
+			if ((flags & FAULT_FLAG_WRITE) && !pmd_write(orig_pmd)) {
 				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
 							  orig_pmd);
 				/*
@@ -3551,12 +3611,13 @@ retry:
 				 */
 				if (unlikely(ret & VM_FAULT_OOM))
 					goto retry;
-				return ret;
 			}
-			return 0;
+
+			return ret;
 		}
 	}
 
+
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
 	 * run pte_offset_map on the pmd, if an huge pmd could
diff --git a/mm/mprotect.c b/mm/mprotect.c
index e97b0d6..392b124 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -112,7 +112,7 @@ static inline void change_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 	} while (pud++, addr = next, addr != end);
 }
 
-static void change_protection(struct vm_area_struct *vma,
+static void change_protection_range(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable)
 {
@@ -134,6 +134,20 @@ static void change_protection(struct vm_area_struct *vma,
 	flush_tlb_range(vma, start, end);
 }
 
+void change_protection(struct vm_area_struct *vma, unsigned long start,
+		       unsigned long end, pgprot_t newprot,
+		       int dirty_accountable)
+{
+	struct mm_struct *mm = vma->vm_mm;
+
+	mmu_notifier_invalidate_range_start(mm, start, end);
+	if (is_vm_hugetlb_page(vma))
+		hugetlb_change_protection(vma, start, end, newprot);
+	else
+		change_protection_range(vma, start, end, newprot, dirty_accountable);
+	mmu_notifier_invalidate_range_end(mm, start, end);
+}
+
 int
 mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 	unsigned long start, unsigned long end, unsigned long newflags)
@@ -206,12 +220,8 @@ success:
 		dirty_accountable = 1;
 	}
 
-	mmu_notifier_invalidate_range_start(mm, start, end);
-	if (is_vm_hugetlb_page(vma))
-		hugetlb_change_protection(vma, start, end, vma->vm_page_prot);
-	else
-		change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
-	mmu_notifier_invalidate_range_end(mm, start, end);
+	change_protection(vma, start, end, vma->vm_page_prot, dirty_accountable);
+
 	vm_stat_account(mm, oldflags, vma->vm_file, -nrpages);
 	vm_stat_account(mm, newflags, vma->vm_file, nrpages);
 	perf_event_mmap(vma);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
