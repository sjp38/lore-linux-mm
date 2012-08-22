Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 36B4A6B006C
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:02 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 24/36] autonuma: numa hinting page faults entry points
Date: Wed, 22 Aug 2012 16:59:08 +0200
Message-Id: <1345647560-30387-25-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This is where the numa hinting page faults are detected and are passed
over to the AutoNUMA core logic.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/huge_mm.h |    2 ++
 mm/huge_memory.c        |   18 ++++++++++++++++++
 mm/memory.c             |   31 +++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index ad4e2e0..5270c81 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -11,6 +11,8 @@ extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 extern int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			       unsigned long address, pmd_t *pmd,
 			       pmd_t orig_pmd);
+extern pmd_t __huge_pmd_numa_fixup(struct mm_struct *mm, unsigned long addr,
+				   pmd_t pmd, pmd_t *pmdp);
 extern pgtable_t get_pmd_huge_pte(struct mm_struct *mm);
 extern struct page *follow_trans_huge_pmd(struct mm_struct *mm,
 					  unsigned long addr,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 0d2a12f..067cba1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1037,6 +1037,24 @@ out:
 	return page;
 }
 
+#ifdef CONFIG_AUTONUMA
+/* NUMA hinting page fault entry point for trans huge pmds */
+pmd_t __huge_pmd_numa_fixup(struct mm_struct *mm, unsigned long addr,
+			    pmd_t pmd, pmd_t *pmdp)
+{
+	spin_lock(&mm->page_table_lock);
+	if (pmd_same(pmd, *pmdp)) {
+		struct page *page = pmd_page(pmd);
+		pmd = pmd_mknonnuma(pmd);
+		set_pmd_at(mm, addr & HPAGE_PMD_MASK, pmdp, pmd);
+		numa_hinting_fault(page, HPAGE_PMD_NR);
+		VM_BUG_ON(pmd_numa(pmd));
+	}
+	spin_unlock(&mm->page_table_lock);
+	return pmd;
+}
+#endif
+
 int zap_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		 pmd_t *pmd, unsigned long addr)
 {
diff --git a/mm/memory.c b/mm/memory.c
index 71282f5..00f1ae7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/autonuma.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3418,6 +3419,31 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
+static inline pte_t pte_numa_fixup(struct mm_struct *mm,
+				   struct vm_area_struct *vma,
+				   unsigned long addr, pte_t pte, pte_t *ptep)
+{
+	if (pte_numa(pte))
+		pte = __pte_numa_fixup(mm, vma, addr, pte, ptep);
+	return pte;
+}
+
+static inline void pmd_numa_fixup(struct mm_struct *mm,
+				  unsigned long addr, pmd_t *pmd)
+{
+	if (pmd_numa(*pmd))
+		__pmd_numa_fixup(mm, addr, pmd);
+}
+
+static inline pmd_t huge_pmd_numa_fixup(struct mm_struct *mm,
+					unsigned long addr,
+					pmd_t pmd, pmd_t *pmdp)
+{
+	if (pmd_numa(pmd))
+		pmd = __huge_pmd_numa_fixup(mm, addr, pmd, pmdp);
+	return pmd;
+}
+
 /*
  * These routines also need to handle stuff like marking pages dirty
  * and/or accessed for architectures that don't do it in hardware (most
@@ -3460,6 +3486,7 @@ int handle_pte_fault(struct mm_struct *mm,
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
+	entry = pte_numa_fixup(mm, vma, address, entry, pte);
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address,
@@ -3530,6 +3557,8 @@ retry:
 		 */
 		orig_pmd = ACCESS_ONCE(*pmd);
 		if (pmd_trans_huge(orig_pmd)) {
+			orig_pmd = huge_pmd_numa_fixup(mm, address,
+						       orig_pmd, pmd);
 			if (flags & FAULT_FLAG_WRITE &&
 			    !pmd_write(orig_pmd) &&
 			    !pmd_trans_splitting(orig_pmd)) {
@@ -3548,6 +3577,8 @@ retry:
 		}
 	}
 
+	pmd_numa_fixup(mm, address, pmd);
+
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
 	 * run pte_offset_map on the pmd, if an huge pmd could

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
