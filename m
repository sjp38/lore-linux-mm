From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:46:38 +1100
Message-Id: <20070113024638.29682.41909.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 11/29] Call simple PTI functions cont...
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 11
 * Abstract the implementation dependent page table lookup from
 get_user_pages and make call from page table interface.
 * Abstract implementation dependent page table lookups from rmap.c.
 Abstract CLUSTER_SIZE to pt_default.h since it is implementation 
 dependent.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 memory.c  |   15 +--------------
 migrate.c |   27 +++++++--------------------
 rmap.c    |   25 ++++++-------------------
 3 files changed, 14 insertions(+), 53 deletions(-)
Index: linux-2.6.20-rc3/mm/rmap.c
===================================================================
--- linux-2.6.20-rc3.orig/mm/rmap.c	2007-01-06 16:35:41.714144000 +1100
+++ linux-2.6.20-rc3/mm/rmap.c	2007-01-06 16:35:52.362144000 +1100
@@ -709,19 +709,16 @@
  * there there won't be many ptes located within the scan cluster.  In this case
  * maybe we could scan further - to the end of the pte page, perhaps.
  */
-#define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
+
 #define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
 
 static void try_to_unmap_cluster(unsigned long cursor,
 	unsigned int *mapcount, struct vm_area_struct *vma)
 {
 	struct mm_struct *mm = vma->vm_mm;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *pte;
 	pte_t pteval;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
 	struct page *page;
 	unsigned long address;
 	unsigned long end;
@@ -733,19 +730,8 @@
 	if (end > vma->vm_end)
 		end = vma->vm_end;
 
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		return;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		return;
-
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
-		return;
-
-	pte = pte_offset_map_lock(mm, pmd, address, &ptl);
+	pte = lookup_page_table(mm, address, &pt_path);
+	lock_pte(mm, pt_path);
 
 	/* Update high watermark before we lower rss */
 	update_hiwater_rss(mm);
@@ -776,7 +762,8 @@
 		dec_mm_counter(mm, file_rss);
 		(*mapcount)--;
 	}
-	pte_unmap_unlock(pte - 1, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte-1);
 }
 
 static int try_to_unmap_anon(struct page *page, int migration)
Index: linux-2.6.20-rc3/mm/migrate.c
===================================================================
--- linux-2.6.20-rc3.orig/mm/migrate.c	2007-01-06 13:01:46.930183000 +1100
+++ linux-2.6.20-rc3/mm/migrate.c	2007-01-06 16:35:52.366144000 +1100
@@ -28,6 +28,7 @@
 #include <linux/mempolicy.h>
 #include <linux/vmalloc.h>
 #include <linux/security.h>
+#include <linux/pt.h>
 
 #include "internal.h"
 
@@ -128,37 +129,22 @@
 {
 	struct mm_struct *mm = vma->vm_mm;
 	swp_entry_t entry;
- 	pgd_t *pgd;
- 	pud_t *pud;
- 	pmd_t *pmd;
+	pt_path_t pt_path;
 	pte_t *ptep, pte;
- 	spinlock_t *ptl;
 	unsigned long addr = page_address_in_vma(new, vma);
 
 	if (addr == -EFAULT)
 		return;
 
- 	pgd = pgd_offset(mm, addr);
-	if (!pgd_present(*pgd))
-                return;
-
-	pud = pud_offset(pgd, addr);
-	if (!pud_present(*pud))
-                return;
-
-	pmd = pmd_offset(pud, addr);
-	if (!pmd_present(*pmd))
-		return;
-
-	ptep = pte_offset_map(pmd, addr);
+	ptep = lookup_page_table(mm, addr, &pt_path);
 
 	if (!is_swap_pte(*ptep)) {
 		pte_unmap(ptep);
  		return;
  	}
 
- 	ptl = pte_lockptr(mm, pmd);
- 	spin_lock(ptl);
+	lock_pte(mm, pt_path);
+
 	pte = *ptep;
 	if (!is_swap_pte(pte))
 		goto out;
@@ -184,7 +170,8 @@
 	lazy_mmu_prot_update(pte);
 
 out:
-	pte_unmap_unlock(ptep, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 }
 
 /*
Index: linux-2.6.20-rc3/mm/memory.c
===================================================================
--- linux-2.6.20-rc3.orig/mm/memory.c	2007-01-06 16:34:55.534144000 +1100
+++ linux-2.6.20-rc3/mm/memory.c	2007-01-06 16:35:52.366144000 +1100
@@ -927,23 +927,10 @@
 		if (!vma && in_gate_area(tsk, start)) {
 			unsigned long pg = start & PAGE_MASK;
 			struct vm_area_struct *gate_vma = get_gate_vma(tsk);
-			pgd_t *pgd;
-			pud_t *pud;
-			pmd_t *pmd;
 			pte_t *pte;
 			if (write) /* user gate pages are read-only */
 				return i ? : -EFAULT;
-			if (pg > TASK_SIZE)
-				pgd = pgd_offset_k(pg);
-			else
-				pgd = pgd_offset_gate(mm, pg);
-			BUG_ON(pgd_none(*pgd));
-			pud = pud_offset(pgd, pg);
-			BUG_ON(pud_none(*pud));
-			pmd = pmd_offset(pud, pg);
-			if (pmd_none(*pmd))
-				return i ? : -EFAULT;
-			pte = pte_offset_map(pmd, pg);
+			pte = lookup_gate_area(mm, pg);
 			if (pte_none(*pte)) {
 				pte_unmap(pte);
 				return i ? : -EFAULT;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
