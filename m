From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:46:33 +1100
Message-Id: <20070113024633.29682.34136.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 10/29] Call simple PTI functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 10 summary:
 * Remove implementation dependent page table lookup code from memory.c,
 rmap.c and filemap_xip.c and replace with interface defined lookup_page_table.
   * Leaves hugetlb undisturbed for the default page table implementation.
 * Adjust prototype in rmap.h to align with page table interface.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 include/linux/rmap.h |    3 +-
 mm/filemap_xip.c     |    7 +++--
 mm/memory.c          |   61 +++++++++++++++------------------------------------
 mm/rmap.c            |   52 ++++++++++++++++++-------------------------
 4 files changed, 47 insertions(+), 76 deletions(-)
Index: linux-2.6.20-rc3/mm/memory.c
===================================================================
--- linux-2.6.20-rc3.orig/mm/memory.c	2007-01-09 12:17:31.550257000 +1100
+++ linux-2.6.20-rc3/mm/memory.c	2007-01-09 12:18:09.418257000 +1100
@@ -844,11 +844,8 @@
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
 
@@ -859,25 +856,14 @@
 	}
 
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
+	if(is_huge_page(mm, address, pt_path, flags, page))
 		goto out;
-	}
 
-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	lock_pte(mm, pt_path);
 	if (!ptep)
 		goto out;
 
@@ -899,7 +885,8 @@
 		mark_page_accessed(page);
 	}
 unlock:
-	pte_unmap_unlock(ptep, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(ptep);
 out:
 	return page;
 
@@ -2426,29 +2413,19 @@
  */
 struct page * vmalloc_to_page(void * vmalloc_addr)
 {
-	unsigned long addr = (unsigned long) vmalloc_addr;
-	struct page *page = NULL;
-	pgd_t *pgd = pgd_offset_k(addr);
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *ptep, pte;
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
-	}
-	return page;
+    unsigned long addr = (unsigned long) vmalloc_addr;
+    struct page *page = NULL;
+    pte_t *ptep, pte;
+
+    ptep = lookup_page_table(&init_mm, addr, NULL);
+    if(ptep) {
+        pte = *ptep;
+        if (pte_present(pte))
+            page = pte_page(pte);
+        pte_unmap(ptep);
+    }
+    return page;
 }
-
 EXPORT_SYMBOL(vmalloc_to_page);
 
 /*
Index: linux-2.6.20-rc3/mm/rmap.c
===================================================================
--- linux-2.6.20-rc3.orig/mm/rmap.c	2007-01-09 12:15:41.563902000 +1100
+++ linux-2.6.20-rc3/mm/rmap.c	2007-01-09 12:17:44.614257000 +1100
@@ -48,6 +48,7 @@
 #include <linux/rcupdate.h>
 #include <linux/module.h>
 #include <linux/kallsyms.h>
+#include <linux/pt.h>
 
 #include <asm/tlbflush.h>
 
@@ -243,43 +244,30 @@
  * On success returns with pte mapped and locked.
  */
 pte_t *page_check_address(struct page *page, struct mm_struct *mm,
-			  unsigned long address, spinlock_t **ptlp)
+			  unsigned long address, pt_path_t *ppt_path)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *pte;
-	spinlock_t *ptl;
-
-	pgd = pgd_offset(mm, address);
-	if (!pgd_present(*pgd))
-		return NULL;
+	pt_path_t pt_path;
 
-	pud = pud_offset(pgd, address);
-	if (!pud_present(*pud))
+	pte = lookup_page_table(mm, address, &pt_path);
+	if(!pte)
 		return NULL;
 
-	pmd = pmd_offset(pud, address);
-	if (!pmd_present(*pmd))
-		return NULL;
-
-	pte = pte_offset_map(pmd, address);
 	/* Make a quick check before getting the lock */
 	if (!pte_present(*pte)) {
 		pte_unmap(pte);
 		return NULL;
 	}
 
-	ptl = pte_lockptr(mm, pmd);
-	spin_lock(ptl);
+	lock_pte(mm, pt_path);
 	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
-		*ptlp = ptl;
+		set_pt_path(pt_path, ppt_path);
 		return pte;
 	}
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 	return NULL;
 }
-
 /*
  * Subfunctions of page_referenced: page_referenced_one called
  * repeatedly from either page_referenced_anon or page_referenced_file.
@@ -290,14 +278,14 @@
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pte_t *pte;
-	spinlock_t *ptl;
 	int referenced = 0;
+	pt_path_t pt_path;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl);
+	pte = page_check_address(page, mm, address, &pt_path);
 	if (!pte)
 		goto out;
 
@@ -311,7 +299,8 @@
 		referenced++;
 
 	(*mapcount)--;
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 out:
 	return referenced;
 }
@@ -434,14 +423,14 @@
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
 	pte_t *pte;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
 	int ret = 0;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl);
+	pte = page_check_address(page, mm, address, &pt_path);
 	if (!pte)
 		goto out;
 
@@ -457,7 +446,9 @@
 		ret = 1;
 	}
 
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
+
 out:
 	return ret;
 }
@@ -615,14 +606,14 @@
 	unsigned long address;
 	pte_t *pte;
 	pte_t pteval;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
 	int ret = SWAP_AGAIN;
 
 	address = vma_address(page, vma);
 	if (address == -EFAULT)
 		goto out;
 
-	pte = page_check_address(page, mm, address, &ptl);
+	pte = page_check_address(page, mm, address, &pt_path);
 	if (!pte)
 		goto out;
 
@@ -693,7 +684,8 @@
 	page_cache_release(page);
 
 out_unmap:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 out:
 	return ret;
 }
Index: linux-2.6.20-rc3/include/linux/rmap.h
===================================================================
--- linux-2.6.20-rc3.orig/include/linux/rmap.h	2007-01-09 12:15:41.563902000 +1100
+++ linux-2.6.20-rc3/include/linux/rmap.h	2007-01-09 12:17:44.618257000 +1100
@@ -8,6 +8,7 @@
 #include <linux/slab.h>
 #include <linux/mm.h>
 #include <linux/spinlock.h>
+#include <linux/pt.h>
 
 /*
  * The anon_vma heads a list of private "related" vmas, to scan if
@@ -96,7 +97,7 @@
  * Called from mm/filemap_xip.c to unmap empty zero page
  */
 pte_t *page_check_address(struct page *, struct mm_struct *,
-				unsigned long, spinlock_t **);
+				unsigned long, pt_path_t *);
 
 /*
  * Used by swapoff to help locate where page is expected in vma.
Index: linux-2.6.20-rc3/mm/filemap_xip.c
===================================================================
--- linux-2.6.20-rc3.orig/mm/filemap_xip.c	2007-01-09 12:15:41.563902000 +1100
+++ linux-2.6.20-rc3/mm/filemap_xip.c	2007-01-09 12:17:44.618257000 +1100
@@ -174,7 +174,7 @@
 	unsigned long address;
 	pte_t *pte;
 	pte_t pteval;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
 	struct page *page;
 
 	spin_lock(&mapping->i_mmap_lock);
@@ -184,7 +184,7 @@
 			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
 		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 		page = ZERO_PAGE(address);
-		pte = page_check_address(page, mm, address, &ptl);
+		pte = page_check_address(page, mm, address, &pt_path);
 		if (pte) {
 			/* Nuke the page table entry. */
 			flush_cache_page(vma, address, pte_pfn(*pte));
@@ -192,7 +192,8 @@
 			page_remove_rmap(page, vma);
 			dec_mm_counter(mm, file_rss);
 			BUG_ON(pte_dirty(pteval));
-			pte_unmap_unlock(pte, ptl);
+			unlock_pte(mm, pt_path);
+			pte_unmap(pte);
 			page_cache_release(page);
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
