From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Thu, 13 Jul 2006 14:28:05 +1000
Message-Id: <20060713042805.9978.92291.sendpatchset@localhost.localdomain>
In-Reply-To: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
References: <20060713042630.9978.66924.sendpatchset@localhost.localdomain>
Subject: [PATCH 9/18] PTI - Call interface
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

Calls PTI across various files.
 * memory.c - follow page calls lookup_page_table.
            - get_user_pages calls lookup_gate_area
			- vmalloc_to_page calls lookup_page_table

 * fs/exec.c - make calls to build_page_table
 * rmap.c - call lookup_page table and absorb page_check_address
Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 fs/exec.c   |   14 ++++++---
 mm/fremap.c |   18 ++++++++----
 mm/memory.c |   73 ++++++++++--------------------------------------
 mm/rmap.c   |   90 ++++++++++++++++++++++++------------------------------------
 4 files changed, 73 insertions(+), 122 deletions(-)
Index: linux-2.6.17.2/mm/memory.c
===================================================================
--- linux-2.6.17.2.orig/mm/memory.c	2006-07-08 22:25:23.651317624 +1000
+++ linux-2.6.17.2/mm/memory.c	2006-07-08 22:25:25.380054816 +1000
@@ -656,40 +656,17 @@
 struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 			unsigned int flags)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *ptep, pte;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
 	struct page *page;
 	struct mm_struct *mm = vma->vm_mm;
 
-	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
-	if (!IS_ERR(page)) {
-		BUG_ON(flags & FOLL_GET);
-		goto out;
-	}
-
 	page = NULL;
-	pgd = pgd_offset(mm, address);
-	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		goto no_page_table;
-
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
-		goto no_page_table;
-	
-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
+	ptep = lookup_page_table(mm, address, &pt_path);
+	if (!ptep)
 		goto no_page_table;
 
-	if (pmd_huge(*pmd)) {
-		BUG_ON(flags & FOLL_GET);
-		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
-		goto out;
-	}
-
-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	lock_pte(mm, pt_path);
 	if (!ptep)
 		goto out;
 
@@ -711,7 +688,8 @@
 		mark_page_accessed(page);
 	}
 unlock:
-	pte_unmap_unlock(ptep, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 out:
 	return page;
 
@@ -752,23 +730,10 @@
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
@@ -855,6 +820,7 @@
 	} while (len);
 	return i;
 }
+
 EXPORT_SYMBOL(get_user_pages);
 
 static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
@@ -2061,23 +2027,14 @@
 {
 	unsigned long addr = (unsigned long) vmalloc_addr;
 	struct page *page = NULL;
-	pgd_t *pgd = pgd_offset_k(addr);
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *ptep, pte;
-  
-	if (!pgd_none(*pgd)) {
-		pud = pud_offset(pgd, addr);
-		if (!pud_none(*pud)) {
-			pmd = pmd_offset(pud, addr);
-			if (!pmd_none(*pmd)) {
-				ptep = pte_offset_map(pmd, addr);
-				pte = *ptep;
-				if (pte_present(pte))
-					page = pte_page(pte);
-				pte_unmap(ptep);
-			}
-		}
+
+	ptep = lookup_page_table(&init_mm, addr, NULL);
+	if(ptep) {
+		pte = *ptep;
+		if (pte_present(pte))
+			page = pte_page(pte);
+		pte_unmap(ptep);
 	}
 	return page;
 }
Index: linux-2.6.17.2/fs/exec.c
===================================================================
--- linux-2.6.17.2.orig/fs/exec.c	2006-07-08 22:25:23.652317472 +1000
+++ linux-2.6.17.2/fs/exec.c	2006-07-08 22:25:25.381054664 +1000
@@ -49,6 +49,7 @@
 #include <linux/rmap.h>
 #include <linux/acct.h>
 #include <linux/cn_proc.h>
+#include <linux/pt.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -307,17 +308,20 @@
 {
 	struct mm_struct *mm = vma->vm_mm;
 	pte_t * pte;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
 
 	if (unlikely(anon_vma_prepare(vma)))
 		goto out;
 
 	flush_dcache_page(page);
-	pte = get_locked_pte(mm, address, &ptl);
+	pte = build_page_table(mm, address, &pt_path);
+	lock_pte(mm, pt_path);
+
 	if (!pte)
 		goto out;
 	if (!pte_none(*pte)) {
-		pte_unmap_unlock(pte, ptl);
+		unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 		goto out;
 	}
 	inc_mm_counter(mm, anon_rss);
@@ -325,8 +329,8 @@
 	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
 					page, vma->vm_page_prot))));
 	page_add_new_anon_rmap(page, vma, address);
-	pte_unmap_unlock(pte, ptl);
-
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 	/* no need for flush_tlb */
 	return;
 out:
Index: linux-2.6.17.2/mm/fremap.c
===================================================================
--- linux-2.6.17.2.orig/mm/fremap.c	2006-07-08 22:25:23.651317624 +1000
+++ linux-2.6.17.2/mm/fremap.c	2006-07-08 22:25:25.381054664 +1000
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/pt.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -56,9 +57,10 @@
 	int err = -ENOMEM;
 	pte_t *pte;
 	pte_t pte_val;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
 
-	pte = get_locked_pte(mm, addr, &ptl);
+	pte = build_page_table(mm, addr, &pt_path);
+	lock_pte(mm, pt_path);
 	if (!pte)
 		goto out;
 
@@ -85,7 +87,9 @@
 	update_mmu_cache(vma, addr, pte_val);
 	err = 0;
 unlock:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
+
 out:
 	return err;
 }
@@ -101,9 +105,10 @@
 	int err = -ENOMEM;
 	pte_t *pte;
 	pte_t pte_val;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
 
-	pte = get_locked_pte(mm, addr, &ptl);
+	pte = build_page_table(mm, addr, &pt_path);
+	lock_pte(mm, pt_path);
 	if (!pte)
 		goto out;
 
@@ -115,7 +120,8 @@
 	set_pte_at(mm, addr, pte, pgoff_to_pte(pgoff));
 	pte_val = *pte;
 	update_mmu_cache(vma, addr, pte_val);
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 	err = 0;
 out:
 	return err;
Index: linux-2.6.17.2/mm/rmap.c
===================================================================
--- linux-2.6.17.2.orig/mm/rmap.c	2006-07-08 22:25:23.652317472 +1000
+++ linux-2.6.17.2/mm/rmap.c	2006-07-08 22:28:41.974167968 +1000
@@ -53,6 +53,7 @@
 #include <linux/rmap.h>
 #include <linux/rcupdate.h>
 #include <linux/module.h>
+#include <linux/pt.h>
 
 #include <asm/tlbflush.h>
 
@@ -281,49 +282,6 @@
 }
 
 /*
- * Check that @page is mapped at @address into @mm.
- *
- * On success returns with pte mapped and locked.
- */
-pte_t *page_check_address(struct page *page, struct mm_struct *mm,
-			  unsigned long address, spinlock_t **ptlp)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte;
-	spinlock_t *ptl;
-
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		return NULL;
-
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
-		return NULL;
-
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
-		return NULL;
-
-	pte = pte_offset_map(pmd, address);
-	/* Make a quick check before getting the lock */
-	if (!pte_present(*pte)) {
-		pte_unmap(pte);
-		return NULL;
-	}
-
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
-	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
-		*ptlp = ptl;
-		return pte;
-	}
-	pte_unmap_unlock(pte, ptl);
-	return NULL;
-}
-
-/*
  * Subfunctions of page_referenced: page_referenced_one called
  * repeatedly from either page_referenced_anon or page_referenced_file.
  */
@@ -333,16 +291,29 @@
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pte_t *pte;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
 	int referenced = 0;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl);
-	if (!pte)
+	pte = lookup_page_table(mm, address, &pt_path);
+	if(!pte)
+		goto out;
+
+	/* Make a quick check before getting the lock */
+	if (!pte_present(*pte)) {
+		pte_unmap(pte);
+		goto out;
+	}
+
+	lock_pte(mm, pt_path);
+	if (!(pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte))) {
+		unlock_pte(mm, pt_path);
+		pte_unmap(pte);
 		goto out;
+	}
 
 	if (ptep_clear_flush_young(vma, address, pte))
 		referenced++;
@@ -354,7 +325,8 @@
 		referenced++;
 
 	(*mapcount)--;
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 out:
 	return referenced;
 }
@@ -583,17 +555,30 @@
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pte_t *pte;
+	pt_path_t pt_path;
 	pte_t pteval;
-	spinlock_t *ptl;
 	int ret = SWAP_AGAIN;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl);
-	if (!pte)
+	pte = lookup_page_table(mm, address, &pt_path);
+	if(!pte)
+		goto out;
+
+	/* Make a quick check before getting the lock */
+	if (!pte_present(*pte)) {
+		pte_unmap(pte);
+		goto out;
+	}
+
+	lock_pte(mm, pt_path);
+	if (!(pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte))) {
+		unlock_pte(mm, pt_path);
+		pte_unmap(pte);
 		goto out;
+	}
 
 	/*
 	 * If the page is mlock()d, we cannot swap it out.
@@ -642,7 +627,8 @@
 	page_cache_release(page);
 
 out_unmap:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 out:
 	return ret;
 }
@@ -666,8 +652,6 @@
  * there there won't be many ptes located within the scan cluster.  In this case
  * maybe we could scan further - to the end of the pte page, perhaps.
  */
-#define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
-#define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))
 
 static void try_to_unmap_cluster(unsigned long cursor,
 	unsigned int *mapcount, struct vm_area_struct *vma)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
