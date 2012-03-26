Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 47A386B004D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:18:42 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 33/39] autonuma: numa hinting page faults entry points
Date: Mon, 26 Mar 2012 19:46:20 +0200
Message-Id: <1332783986-24195-34-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

This is where the numa hinting page faults are detected and are passed
over to the AutoNUMA core logic.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/huge_mm.h |    2 ++
 mm/huge_memory.c        |   17 +++++++++++++++++
 mm/memory.c             |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 51 insertions(+), 0 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index c8af7a2..72eac1d 100644
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
index 76bdc48..017c0a3 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1030,6 +1030,23 @@ out:
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
index a0f35cd..9dcfc35 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/autonuma.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3401,6 +3402,32 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
+				  struct vm_area_struct *vma,
+				  unsigned long addr, pmd_t *pmd)
+{
+	if (pmd_numa(*pmd))
+		__pmd_numa_fixup(mm, vma, addr, pmd);
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
@@ -3443,6 +3470,7 @@ int handle_pte_fault(struct mm_struct *mm,
 	spin_lock(ptl);
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
+	entry = pte_numa_fixup(mm, vma, address, entry, pte);
 	if (flags & FAULT_FLAG_WRITE) {
 		if (!pte_write(entry))
 			return do_wp_page(mm, vma, address,
@@ -3504,6 +3532,8 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		pmd_t orig_pmd = *pmd;
 		barrier();
 		if (pmd_trans_huge(orig_pmd)) {
+			orig_pmd = huge_pmd_numa_fixup(mm, address,
+						       orig_pmd, pmd);
 			if (flags & FAULT_FLAG_WRITE &&
 			    !pmd_write(orig_pmd) &&
 			    !pmd_trans_splitting(orig_pmd))
@@ -3513,6 +3543,8 @@ int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 	}
 
+	pmd_numa_fixup(mm, vma, address, pmd);
+
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
 	 * run pte_offset_map on the pmd, if an huge pmd could

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
