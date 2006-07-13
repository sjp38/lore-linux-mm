From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:29:10 +1000
Message-Id: <20060713042910.9978.15862.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 15/18] PTI - Change protection iterator abstraction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

1) Abstracts change protection iterator from mprotect.c and 
puts it in pt_default.c

2)  Abstracts smaps iterator from fs/proc/mmu_task.c and 
puts it in pt_default.c

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 fs/proc/task_mmu.c |  105 ++++++++++++-----------------------------------------
 mm/mprotect.c      |   73 +++++++-----------------------------
 mm/pt-default.c    |   77 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 116 insertions(+), 139 deletions(-)
Index: linux-2.6.17.2/mm/mprotect.c
===================================================================
--- linux-2.6.17.2.orig/mm/mprotect.c	2006-07-09 01:41:14.098069592 +1000
+++ linux-2.6.17.2/mm/mprotect.c	2006-07-09 01:41:21.556935672 +1000
@@ -19,82 +19,37 @@
 #include <linux/mempolicy.h>
 #include <linux/personality.h>
 #include <linux/syscalls.h>
+#include <linux/pt.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
 
-static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
-		unsigned long addr, unsigned long end, pgprot_t newprot)
-{
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
-	do {
-		if (pte_present(*pte)) {
-			pte_t ptent;
-
-			/* Avoid an SMP race with hardware updated dirty/clean
-			 * bits by wiping the pte and then setting the new pte
-			 * into place.
-			 */
-			ptent = pte_modify(ptep_get_and_clear(mm, addr, pte), newprot);
-			set_pte_at(mm, addr, pte, ptent);
-			lazy_mmu_prot_update(ptent);
-		}
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(pte - 1, ptl);
-}
-
-static inline void change_pmd_range(struct mm_struct *mm, pud_t *pud,
-		unsigned long addr, unsigned long end, pgprot_t newprot)
+void change_prot_pte(struct mm_struct *mm, pte_t *pte,
+	unsigned long address, pgprot_t newprot)
 {
-	pmd_t *pmd;
-	unsigned long next;
+	if (pte_present(*pte)) {
+		pte_t ptent;
 
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		change_pte_range(mm, pmd, addr, next, newprot);
-	} while (pmd++, addr = next, addr != end);
-}
-
-static inline void change_pud_range(struct mm_struct *mm, pgd_t *pgd,
-		unsigned long addr, unsigned long end, pgprot_t newprot)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		change_pmd_range(mm, pud, addr, next, newprot);
-	} while (pud++, addr = next, addr != end);
+		/* Avoid an SMP race with hardware updated dirty/clean
+		 * bits by wiping the pte and then setting the new pte
+		 * into place.
+		 */
+		ptent = pte_modify(ptep_get_and_clear(mm, address, pte), newprot);
+		set_pte_at(mm, addr, pte, ptent);
+		lazy_mmu_prot_update(ptent);
+	}
 }
 
 static void change_protection(struct vm_area_struct *vma,
 		unsigned long addr, unsigned long end, pgprot_t newprot)
 {
-	struct mm_struct *mm = vma->vm_mm;
-	pgd_t *pgd;
-	unsigned long next;
 	unsigned long start = addr;
 
 	BUG_ON(addr >= end);
-	pgd = pgd_offset(mm, addr);
 	flush_cache_range(vma, addr, end);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		change_pud_range(mm, pgd, addr, next, newprot);
-	} while (pgd++, addr = next, addr != end);
+	change_protection_read_iterator(vma, addr, end, newprot);
 	flush_tlb_range(vma, start, end);
 }
 
Index: linux-2.6.17.2/mm/pt-default.c
===================================================================
--- linux-2.6.17.2.orig/mm/pt-default.c	2006-07-09 01:41:14.098069592 +1000
+++ linux-2.6.17.2/mm/pt-default.c	2006-07-09 01:43:23.620379208 +1000
@@ -836,3 +836,80 @@
 	} while (pgd++, addr = next, addr != end);
 	return 0;
 }
+
+static void change_pte_range(struct mm_struct *mm, pmd_t *pmd,
+		unsigned long addr, unsigned long end, pgprot_t newprot)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
+	do {
+		change_prot_pte(mm, pte, addr, newprot);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+}
+
+static inline void change_pmd_range(struct mm_struct *mm, pud_t *pud,
+		unsigned long addr, unsigned long end, pgprot_t newprot)
+{
+	pmd_t *pmd;
+	unsigned long next;
+
+	pmd = pmd_offset(pud, addr);
+	do {
+		next = pmd_addr_end(addr, end);
+		if (pmd_none_or_clear_bad(pmd))
+			continue;
+		change_pte_range(mm, pmd, addr, next, newprot);
+	} while (pmd++, addr = next, addr != end);
+}
+
+static inline void change_pud_range(struct mm_struct *mm, pgd_t *pgd,
+		unsigned long addr, unsigned long end, pgprot_t newprot)
+{
+	pud_t *pud;
+	unsigned long next;
+
+	pud = pud_offset(pgd, addr);
+	do {
+		next = pud_addr_end(addr, end);
+		if (pud_none_or_clear_bad(pud))
+			continue;
+		change_pmd_range(mm, pud, addr, next, newprot);
+	} while (pud++, addr = next, addr != end);
+}
+
+void change_protection_read_iterator(struct vm_area_struct *vma,
+		unsigned long addr, unsigned long end, pgprot_t newprot)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	pgd_t *pgd;
+	unsigned long next;
+
+	pgd = pgd_offset(mm, addr);
+	do {
+		next = pgd_addr_end(addr, end);
+		if (pgd_none_or_clear_bad(pgd)) {
+			continue;
+		}
+		change_pud_range(mm, pgd, addr, next, newprot);
+	} while (pgd++, addr = next, addr != end);
+}
+
+static void smaps_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+				unsigned long addr, unsigned long end,
+				struct mem_size_stats *mss)
+{
+	pte_t *pte;
+	spinlock_t *ptl;
+
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	do {
+
+		smaps_one_pte(vma, addr, pte, mss);
+	} while (pte++, addr += PAGE_SIZE, addr != end);
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+}
+
Index: linux-2.6.17.2/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.17.2.orig/fs/proc/task_mmu.c	2006-07-09 01:41:14.099069440 +1000
+++ linux-2.6.17.2/fs/proc/task_mmu.c	2006-07-09 01:41:21.557935520 +1000
@@ -190,88 +190,33 @@
 	return show_map_internal(m, v, NULL);
 }
 
-static void smaps_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-				unsigned long addr, unsigned long end,
-				struct mem_size_stats *mss)
+void smaps_one_pte(struct vm_area_struct *vma, unsigned long addr, pte_t *pte,
+			   struct mem_size_stats *mss)
 {
-	pte_t *pte, ptent;
-	spinlock_t *ptl;
+	pte_t ptent;
 	struct page *page;
 
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	do {
-		ptent = *pte;
-		if (!pte_present(ptent))
-			continue;
-
-		mss->resident += PAGE_SIZE;
-
-		page = vm_normal_page(vma, addr, ptent);
-		if (!page)
-			continue;
-
-		if (page_mapcount(page) >= 2) {
-			if (pte_dirty(ptent))
-				mss->shared_dirty += PAGE_SIZE;
-			else
-				mss->shared_clean += PAGE_SIZE;
-		} else {
-			if (pte_dirty(ptent))
-				mss->private_dirty += PAGE_SIZE;
-			else
-				mss->private_clean += PAGE_SIZE;
-		}
-	} while (pte++, addr += PAGE_SIZE, addr != end);
-	pte_unmap_unlock(pte - 1, ptl);
-	cond_resched();
-}
-
-static inline void smaps_pmd_range(struct vm_area_struct *vma, pud_t *pud,
-				unsigned long addr, unsigned long end,
-				struct mem_size_stats *mss)
-{
-	pmd_t *pmd;
-	unsigned long next;
-
-	pmd = pmd_offset(pud, addr);
-	do {
-		next = pmd_addr_end(addr, end);
-		if (pmd_none_or_clear_bad(pmd))
-			continue;
-		smaps_pte_range(vma, pmd, addr, next, mss);
-	} while (pmd++, addr = next, addr != end);
-}
-
-static inline void smaps_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
-				unsigned long addr, unsigned long end,
-				struct mem_size_stats *mss)
-{
-	pud_t *pud;
-	unsigned long next;
-
-	pud = pud_offset(pgd, addr);
-	do {
-		next = pud_addr_end(addr, end);
-		if (pud_none_or_clear_bad(pud))
-			continue;
-		smaps_pmd_range(vma, pud, addr, next, mss);
-	} while (pud++, addr = next, addr != end);
-}
-
-static inline void smaps_pgd_range(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long end,
-				struct mem_size_stats *mss)
-{
-	pgd_t *pgd;
-	unsigned long next;
-
-	pgd = pgd_offset(vma->vm_mm, addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		if (pgd_none_or_clear_bad(pgd))
-			continue;
-		smaps_pud_range(vma, pgd, addr, next, mss);
-	} while (pgd++, addr = next, addr != end);
+	ptent = *pte;
+	if (!pte_present(ptent))
+		return;
+
+	mss->resident += PAGE_SIZE;
+
+	page = vm_normal_page(vma, addr, ptent);
+	if (!page)
+		return;
+
+	if (page_mapcount(page) >= 2) {
+		if (pte_dirty(ptent))
+			mss->shared_dirty += PAGE_SIZE;
+		else
+			mss->shared_clean += PAGE_SIZE;
+	} else {
+		if (pte_dirty(ptent))
+			mss->private_dirty += PAGE_SIZE;
+		else
+			mss->private_clean += PAGE_SIZE;
+	}
 }
 
 static int show_smap(struct seq_file *m, void *v)
@@ -281,7 +226,7 @@
 
 	memset(&mss, 0, sizeof mss);
 	if (vma->vm_mm && !is_vm_hugetlb_page(vma))
-		smaps_pgd_range(vma, vma->vm_start, vma->vm_end, &mss);
+		smaps_read_range(vma, vma->vm_start, vma->vm_end, &mss);
 	return show_map_internal(m, v, &mss);
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
