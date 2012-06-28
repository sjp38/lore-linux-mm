Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id CBB316B009D
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 08:57:10 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 30/40] autonuma: numa hinting page faults entry points
Date: Thu, 28 Jun 2012 14:56:10 +0200
Message-Id: <1340888180-15355-31-git-send-email-aarcange@redhat.com>
In-Reply-To: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This is where the numa hinting page faults are detected and are passed
over to the AutoNUMA core logic.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/huge_mm.h |    2 ++
 mm/huge_memory.c        |   17 +++++++++++++++++
 mm/memory.c             |   31 +++++++++++++++++++++++++++++++
 3 files changed, 50 insertions(+), 0 deletions(-)

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
index ae20409..4fcdaf7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1037,6 +1037,23 @@ out:
 	return page;
 }
 
+#ifdef CONFIG_AUTONUMA
+pmd_t __huge_pmd_numa_fixup(struct mm_struct *mm, unsigned long addr,
+			    pmd_t pmd, pmd_t *pmdp)
+{
+	spin_lock(&mm->page_table_lock);
+	if (pmd_same(pmd, *pmdp)) {
+		struct page *page = pmd_page(pmd);
+		pmd = pmd_mknotnuma(pmd);
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
index 78b6acc..d72aafd 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/autonuma.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3406,6 +3407,31 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
@@ -3448,6 +3474,7 @@ int handle_pte_fault(struct mm_struct *mm,
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
+	entry = pte_numa_fixup(mm, vma, address, entry, pte);
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address,
@@ -3512,6 +3539,8 @@ retry:
 
 		barrier();
 		if (pmd_trans_huge(orig_pmd)) {
+			orig_pmd = huge_pmd_numa_fixup(mm, address,
+						       orig_pmd, pmd);
 			if (flags & FAULT_FLAG_WRITE &&
 			    !pmd_write(orig_pmd) &&
 			    !pmd_trans_splitting(orig_pmd)) {
@@ -3530,6 +3559,8 @@ retry:
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
