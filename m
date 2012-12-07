Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id ECEF66B0099
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 05:24:23 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 15/49] mm: numa: Create basic numa page hinting infrastructure
Date: Fri,  7 Dec 2012 10:23:18 +0000
Message-Id: <1354875832-9700-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Note: This patch started as "mm/mpol: Create special PROT_NONE
	infrastructure" and preserves the basic idea but steals *very*
	heavily from "autonuma: numa hinting page faults entry points" for
	the actual fault handlers without the migration parts.	The end
	result is barely recognisable as either patch so all Signed-off
	and Reviewed-bys are dropped. If Peter, Ingo and Andrea are ok with
	this version, I will re-add the signed-offs-by to reflect the history.

In order to facilitate a lazy -- fault driven -- migration of pages, create
a special transient PAGE_NUMA variant, we can then use the 'spurious'
protection faults to drive our migrations from.

The meaning of PAGE_NUMA depends on the architecture but on x86 it is
effectively PROT_NONE. Actual PROT_NONE mappings will not generate these
NUMA faults for the reason that the page fault code checks the permission on
the VMA (and will throw a segmentation fault on actual PROT_NONE mappings),
before it ever calls handle_mm_fault.

[dhillf@gmail.com: Fix typo]
Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 include/linux/huge_mm.h |   10 +++++
 mm/huge_memory.c        |   22 ++++++++++
 mm/memory.c             |  112 +++++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 141 insertions(+), 3 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index b31cb7d..a1d26a9 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -159,6 +159,10 @@ static inline struct page *compound_trans_head(struct page *page)
 	}
 	return page;
 }
+
+extern int do_huge_pmd_numa_page(struct mm_struct *mm, unsigned long addr,
+				  pmd_t pmd, pmd_t *pmdp);
+
 #else /* CONFIG_TRANSPARENT_HUGEPAGE */
 #define HPAGE_PMD_SHIFT ({ BUILD_BUG(); 0; })
 #define HPAGE_PMD_MASK ({ BUILD_BUG(); 0; })
@@ -195,6 +199,12 @@ static inline int pmd_trans_huge_lock(pmd_t *pmd,
 {
 	return 0;
 }
+
+static inline int do_huge_pmd_numa_page(struct mm_struct *mm, unsigned long addr,
+					pmd_t pmd, pmd_t *pmdp)
+{
+}
+
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3aaf242..f1b2d63 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1017,6 +1017,28 @@ out:
 	return page;
 }
 
+/* NUMA hinting page fault entry point for trans huge pmds */
+int do_huge_pmd_numa_page(struct mm_struct *mm, unsigned long addr,
+				pmd_t pmd, pmd_t *pmdp)
+{
+	struct page *page;
+	unsigned long haddr = addr & HPAGE_PMD_MASK;
+
+	spin_lock(&mm->page_table_lock);
+	if (unlikely(!pmd_same(pmd, *pmdp)))
+		goto out_unlock;
+
+	page = pmd_page(pmd);
+	pmd = pmd_mknonnuma(pmd);
+	set_pmd_at(mm, haddr, pmdp, pmd);
+	VM_BUG_ON(pmd_numa(*pmdp));
+	update_mmu_cache_pmd(vma, addr, pmdp);
+
+out_unlock:
+	spin_unlock(&mm->page_table_lock);
+	return 0;
+}
+
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 73834e7..4d005a3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3448,6 +3448,103 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
+int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		   unsigned long addr, pte_t pte, pte_t *ptep, pmd_t *pmd)
+{
+	struct page *page;
+	spinlock_t *ptl;
+
+	/*
+	* The "pte" at this point cannot be used safely without
+	* validation through pte_unmap_same(). It's of NUMA type but
+	* the pfn may be screwed if the read is non atomic.
+	*
+	* ptep_modify_prot_start is not called as this is clearing
+	* the _PAGE_NUMA bit and it is not really expected that there
+	* would be concurrent hardware modifications to the PTE.
+	*/
+	ptl = pte_lockptr(mm, pmd);
+	spin_lock(ptl);
+	if (unlikely(!pte_same(*ptep, pte)))
+		goto out_unlock;
+	pte = pte_mknonnuma(pte);
+	set_pte_at(mm, addr, ptep, pte);
+	update_mmu_cache(vma, addr, ptep);
+
+	page = vm_normal_page(vma, addr, pte);
+	if (!page) {
+		pte_unmap_unlock(ptep, ptl);
+		return 0;
+	}
+
+out_unlock:
+	pte_unmap_unlock(ptep, ptl);
+	return 0;
+}
+
+/* NUMA hinting page fault entry point for regular pmds */
+#ifdef CONFIG_BALANCE_NUMA
+static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		     unsigned long addr, pmd_t *pmdp)
+{
+	pmd_t pmd;
+	pte_t *pte, *orig_pte;
+	unsigned long _addr = addr & PMD_MASK;
+	unsigned long offset;
+	spinlock_t *ptl;
+	bool numa = false;
+
+	spin_lock(&mm->page_table_lock);
+	pmd = *pmdp;
+	if (pmd_numa(pmd)) {
+		set_pmd_at(mm, _addr, pmdp, pmd_mknonnuma(pmd));
+		numa = true;
+	}
+	spin_unlock(&mm->page_table_lock);
+
+	if (!numa)
+		return 0;
+
+	/* we're in a page fault so some vma must be in the range */
+	BUG_ON(!vma);
+	BUG_ON(vma->vm_start >= _addr + PMD_SIZE);
+	offset = max(_addr, vma->vm_start) & ~PMD_MASK;
+	VM_BUG_ON(offset >= PMD_SIZE);
+	orig_pte = pte = pte_offset_map_lock(mm, pmdp, _addr, &ptl);
+	pte += offset >> PAGE_SHIFT;
+	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
+		pte_t pteval = *pte;
+		struct page *page;
+		if (!pte_present(pteval))
+			continue;
+		if (!pte_numa(pteval))
+			continue;
+		if (addr >= vma->vm_end) {
+			vma = find_vma(mm, addr);
+			/* there's a pte present so there must be a vma */
+			BUG_ON(!vma);
+			BUG_ON(addr < vma->vm_start);
+		}
+		if (pte_numa(pteval)) {
+			pteval = pte_mknonnuma(pteval);
+			set_pte_at(mm, addr, pte, pteval);
+		}
+		page = vm_normal_page(vma, addr, pteval);
+		if (unlikely(!page))
+			continue;
+	}
+	pte_unmap_unlock(orig_pte, ptl);
+
+	return 0;
+}
+#else
+static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
+		     unsigned long addr, pmd_t *pmdp)
+{
+	BUG();
+}
+#endif /* CONFIG_BALANCE_NUMA */
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3486,6 +3583,9 @@ int handle_pte_fault(struct mm_struct *mm,
 					pte, pmd, flags, entry);
 	}
 
+	if (pte_numa(entry))
+		return do_numa_page(mm, vma, address, entry, pte, pmd);
+
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*pte, entry)))
@@ -3554,9 +3654,11 @@ retry:
 
 		barrier();
 		if (pmd_trans_huge(orig_pmd)) {
-			if (flags & FAULT_FLAG_WRITE &&
-			    !pmd_write(orig_pmd) &&
-			    !pmd_trans_splitting(orig_pmd)) {
+			if (pmd_numa(*pmd))
+				return do_huge_pmd_numa_page(mm, address,
+							     orig_pmd, pmd);
+
+			if ((flags & FAULT_FLAG_WRITE) && !pmd_write(orig_pmd)) {
 				ret = do_huge_pmd_wp_page(mm, vma, address, pmd,
 							  orig_pmd);
 				/*
@@ -3568,10 +3670,14 @@ retry:
 					goto retry;
 				return ret;
 			}
+
 			return 0;
 		}
 	}
 
+	if (pmd_numa(*pmd))
+		return do_pmd_numa_page(mm, vma, address, pmd);
+
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
 	 * run pte_offset_map on the pmd, if an huge pmd could
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
