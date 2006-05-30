Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:23:49 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:23:49 +1000 (EST)
Subject: [Patch 7/17] PTI: Call Interface B
Message-ID: <Pine.LNX.4.61.0605301721470.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Call lookup_page_table in rmap.c and filemap_xip.c

  include/linux/default-pt.h |    6 --
  mm/filemap_xip.c           |    8 +--
  mm/memory.c                |   16 ------
  mm/rmap.c                  |  113 
++++++++++++++++-----------------------------
  4 files changed, 51 insertions(+), 92 deletions(-)
Index: linux-rc5/mm/rmap.c
===================================================================
--- linux-rc5.orig/mm/rmap.c	2006-05-28 19:16:17.735766400 +1000
+++ linux-rc5/mm/rmap.c	2006-05-28 19:16:25.534580800 +1000
@@ -53,6 +53,7 @@
  #include <linux/rmap.h>
  #include <linux/rcupdate.h>
  #include <linux/module.h>
+#include <linux/default-pt.h>

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
@@ -333,17 +291,30 @@
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
  		goto out;

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
+		goto out;
+	}
+
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
@@ -583,18 +555,31 @@
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
  		goto out;

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
+		goto out;
+	}
+
  	/*
  	 * If the page is mlock()d, we cannot swap it out.
  	 * If it's recently referenced (perhaps page_referenced
@@ -642,7 +627,8 @@
  	page_cache_release(page);

  out_unmap:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
  out:
  	return ret;
  }
@@ -666,19 +652,14 @@
   * there there won't be many ptes located within the scan cluster.  In 
this case
   * maybe we could scan further - to the end of the pte page, perhaps.
   */
-#define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
-#define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))

  static void try_to_unmap_cluster(unsigned long cursor,
  	unsigned int *mapcount, struct vm_area_struct *vma)
  {
  	struct mm_struct *mm = vma->vm_mm;
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
  	pte_t *pte;
+	pt_path_t pt_path;
  	pte_t pteval;
-	spinlock_t *ptl;
  	struct page *page;
  	unsigned long address;
  	unsigned long end;
@@ -690,19 +671,8 @@
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
@@ -733,7 +703,8 @@
  		dec_mm_counter(mm, file_rss);
  		(*mapcount)--;
  	}
-	pte_unmap_unlock(pte - 1, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
  }

  static int try_to_unmap_anon(struct page *page, int ignore_refs)
Index: linux-rc5/include/linux/default-pt.h
===================================================================
--- linux-rc5.orig/include/linux/default-pt.h	2006-05-28 
19:16:22.481045008 +1000
+++ linux-rc5/include/linux/default-pt.h	2006-05-28 
19:16:25.536580496 +1000
@@ -144,10 +144,8 @@
  void free_page_table_range(struct mmu_gather **tlb, unsigned long addr,
  		unsigned long end, unsigned long floor, unsigned long 
ceiling);

-
-
-
-
+#define CLUSTER_SIZE	min(32*PAGE_SIZE, PMD_SIZE)
+#define CLUSTER_MASK	(~(CLUSTER_SIZE - 1))

  static inline void coallesce_vmas(struct vm_area_struct **vma_p,
  		struct vm_area_struct **next_p)
Index: linux-rc5/mm/memory.c
===================================================================
--- linux-rc5.orig/mm/memory.c	2006-05-28 19:16:24.599722920 +1000
+++ linux-rc5/mm/memory.c	2006-05-28 19:16:25.545579128 +1000
@@ -740,23 +740,10 @@
  		if (!vma && in_gate_area(tsk, start)) {
  			unsigned long pg = start & PAGE_MASK;
  			struct vm_area_struct *gate_vma = 
get_gate_vma(tsk);
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
@@ -843,6 +830,7 @@
  	} while (len);
  	return i;
  }
+
  EXPORT_SYMBOL(get_user_pages);

  static int zeromap_pte_range(struct mm_struct *mm, pmd_t *pmd,
Index: linux-rc5/mm/filemap_xip.c
===================================================================
--- linux-rc5.orig/mm/filemap_xip.c	2006-05-28 19:16:17.735766400 
+1000
+++ linux-rc5/mm/filemap_xip.c	2006-05-28 19:16:25.546578976 +1000
@@ -13,6 +13,7 @@
  #include <linux/module.h>
  #include <linux/uio.h>
  #include <linux/rmap.h>
+#include <linux/default_pt.h>
  #include <asm/tlbflush.h>
  #include "filemap.h"

@@ -173,8 +174,8 @@
  	struct prio_tree_iter iter;
  	unsigned long address;
  	pte_t *pte;
+	pt_path_t pt_path;
  	pte_t pteval;
-	spinlock_t *ptl;
  	struct page *page;

  	spin_lock(&mapping->i_mmap_lock);
@@ -184,7 +185,7 @@
  			((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
  		BUG_ON(address < vma->vm_start || address >= vma->vm_end);
  		page = ZERO_PAGE(address);
-		pte = page_check_address(page, mm, address, &ptl);
+		pte = lookup_page_table(mm, address, &pt_path);
  		if (pte) {
  			/* Nuke the page table entry. */
  			flush_cache_page(vma, address, pte_pfn(*pte));
@@ -192,7 +193,8 @@
  			page_remove_rmap(page);
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
