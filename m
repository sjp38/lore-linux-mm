Received: From weill.orchestra.cse.unsw.EDU.AU ([129.94.242.49]) (ident-user root)
	(for <linux-mm@kvack.org>) By note With Smtp ;
	Tue, 30 May 2006 17:21:30 +1000
From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Tue, 30 May 2006 17:21:29 +1000 (EST)
Subject: [Patch 6/17] PTI: call interface A
Message-ID: <Pine.LNX.4.61.0605301718500.10816@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  Remove reference to pgds in fork.c and call create and destroy user page
  table functions.

  Start calling lookup_page_table in memory.c

  fs/exec.c     |   14 +++++++--
  kernel/fork.c |   22 +++++++--------
  mm/fremap.c   |   15 ++++++----
  mm/memory.c   |   82 
++++++++++++----------------------------------------------
  4 files changed, 48 insertions(+), 85 deletions(-)
Index: linux-rc5/mm/memory.c
===================================================================
--- linux-rc5.orig/mm/memory.c	2006-05-28 19:15:09.366160160 +1000
+++ linux-rc5/mm/memory.c	2006-05-28 19:15:10.203032936 +1000
@@ -666,40 +666,17 @@
  struct page *follow_page(struct vm_area_struct *vma, unsigned long 
address,
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
-
-	page = follow_huge_addr(mm, address, flags & FOLL_WRITE);
-	if (!IS_ERR(page)) {
-		BUG_ON(flags & FOLL_GET);
-		goto out;
-	}
-
-	page = NULL;
-	pgd = pgd_offset(mm, address);
-	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
-		goto no_page_table;
-
-	pud = pud_offset(pgd, address);
-	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
-		goto no_page_table;

-	pmd = pmd_offset(pud, address);
-	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
+	page = NULL;
+	ptep = lookup_page_table(mm, address, &pt_path);
+	if (!ptep)
  		goto no_page_table;

-	if (pmd_huge(*pmd)) {
-		BUG_ON(flags & FOLL_GET);
-		page = follow_huge_pmd(mm, address, pmd, flags & 
FOLL_WRITE);
-		goto out;
-	}
-
-	ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
+	lock_pte(mm, pt_path);
  	if (!ptep)
  		goto out;

@@ -721,7 +698,8 @@
  		mark_page_accessed(page);
  	}
  unlock:
-	pte_unmap_unlock(ptep, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
  out:
  	return page;

@@ -967,14 +945,14 @@
  {
  	int retval;
  	pte_t *pte;
-	spinlock_t *ptl;
+	pt_path_t pt_path;

  	retval = -EINVAL;
  	if (PageAnon(page))
  		goto out;
  	retval = -ENOMEM;
  	flush_dcache_page(page);
-	pte = get_locked_pte(mm, addr, &ptl);
+	pte = build_page_table(mm, addr, &pt_path);
  	if (!pte)
  		goto out;
  	retval = -EBUSY;
@@ -989,7 +967,8 @@

  	retval = 0;
  out_unlock:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
  out:
  	return retval;
  }
@@ -1158,22 +1137,6 @@
  	return same;
  }

-static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
-				pte_t *page_table, pte_t orig_pte)
-{
-	int same = 1;
-#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
-	if (sizeof(pte_t) > sizeof(unsigned long)) {
-		spinlock_t *ptl = pte_lockptr(mm, pmd);
-		spin_lock(ptl);
-		same = pte_same(*page_table, orig_pte);
-		spin_unlock(ptl);
-	}
-#endif
-	pte_unmap(page_table);
-	return same;
-}
-
  /*
   * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
   * servicing faults for write access.  In the normal case, do always want
@@ -2107,23 +2070,14 @@
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
Index: linux-rc5/fs/exec.c
===================================================================
--- linux-rc5.orig/fs/exec.c	2006-05-28 19:15:03.001127792 +1000
+++ linux-rc5/fs/exec.c	2006-05-28 19:15:10.205032632 +1000
@@ -49,6 +49,7 @@
  #include <linux/rmap.h>
  #include <linux/acct.h>
  #include <linux/cn_proc.h>
+#include <linux/default-pt.h>

  #include <asm/uaccess.h>
  #include <asm/mmu_context.h>
@@ -307,17 +308,21 @@
  {
  	struct mm_struct *mm = vma->vm_mm;
  	pte_t * pte;
-	spinlock_t *ptl;
+	pt_path_t pt_path;

  	if (unlikely(anon_vma_prepare(vma)))
  		goto out;

  	flush_dcache_page(page);
-	pte = get_locked_pte(mm, address, &ptl);
+
+	pte = build_page_table(mm, address, &pt_path);
+	lock_pte(mm, pt_path);
+
  	if (!pte)
  		goto out;
  	if (!pte_none(*pte)) {
-		pte_unmap_unlock(pte, ptl);
+		unlock_pte(mm, pt_path);
+		pte_unmap(pte);
  		goto out;
  	}
  	inc_mm_counter(mm, anon_rss);
@@ -325,7 +330,8 @@
  	set_pte_at(mm, address, pte, pte_mkdirty(pte_mkwrite(mk_pte(
  					page, vma->vm_page_prot))));
  	page_add_new_anon_rmap(page, vma, address);
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);

  	/* no need for flush_tlb */
  	return;
Index: linux-rc5/mm/fremap.c
===================================================================
--- linux-rc5.orig/mm/fremap.c	2006-05-28 19:15:03.001127792 +1000
+++ linux-rc5/mm/fremap.c	2006-05-28 19:15:10.215031112 +1000
@@ -15,6 +15,7 @@
  #include <linux/rmap.h>
  #include <linux/module.h>
  #include <linux/syscalls.h>
+#include <linux/default-pt.h>

  #include <asm/mmu_context.h>
  #include <asm/cacheflush.h>
@@ -56,9 +57,9 @@
  	int err = -ENOMEM;
  	pte_t *pte;
  	pte_t pte_val;
-	spinlock_t *ptl;
+	pt_path_t pt_path;

-	pte = get_locked_pte(mm, addr, &ptl);
+	pte = build_page_table(mm, addr, &pt_path);
  	if (!pte)
  		goto out;

@@ -85,7 +86,8 @@
  	update_mmu_cache(vma, addr, pte_val);
  	err = 0;
  unlock:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
  out:
  	return err;
  }
@@ -101,9 +103,9 @@
  	int err = -ENOMEM;
  	pte_t *pte;
  	pte_t pte_val;
-	spinlock_t *ptl;
+	pt_path_t pt_path;

-	pte = get_locked_pte(mm, addr, &ptl);
+	pte = build_page_table(mm, addr, &pt_path);
  	if (!pte)
  		goto out;

@@ -115,7 +117,8 @@
  	set_pte_at(mm, addr, pte, pgoff_to_pte(pgoff));
  	pte_val = *pte;
  	update_mmu_cache(vma, addr, pte_val);
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
  	err = 0;
  out:
  	return err;
Index: linux-rc5/kernel/fork.c
===================================================================
--- linux-rc5.orig/kernel/fork.c	2006-05-28 19:15:03.001127792 
+1000
+++ linux-rc5/kernel/fork.c	2006-05-28 19:15:10.216030960 +1000
@@ -44,9 +44,9 @@
  #include <linux/rmap.h>
  #include <linux/acct.h>
  #include <linux/cn_proc.h>
+#include <linux/default-pt.h>

  #include <asm/pgtable.h>
-#include <asm/pgalloc.h>
  #include <asm/uaccess.h>
  #include <asm/mmu_context.h>
  #include <asm/cacheflush.h>
@@ -286,22 +286,22 @@
  	goto out;
  }

-static inline int mm_alloc_pgd(struct mm_struct * mm)
+static inline int mm_alloc_page_table(struct mm_struct * mm)
  {
-	mm->pgd = pgd_alloc(mm);
-	if (unlikely(!mm->pgd))
+	if(!create_user_page_table(mm))
  		return -ENOMEM;
  	return 0;
  }

-static inline void mm_free_pgd(struct mm_struct * mm)
+static inline void mm_free_page_table(struct mm_struct * mm)
  {
-	pgd_free(mm->pgd);
+  	destroy_user_page_table(mm);
  }
+
  #else
  #define dup_mmap(mm, oldmm)	(0)
-#define mm_alloc_pgd(mm)	(0)
-#define mm_free_pgd(mm)
+#define mm_alloc_page_table(mm)	(0)
+#define mm_free_page_table(mm)
  #endif /* CONFIG_MMU */

   __cacheline_aligned_in_smp DEFINE_SPINLOCK(mmlist_lock);
@@ -327,7 +327,7 @@
  	mm->free_area_cache = TASK_UNMAPPED_BASE;
  	mm->cached_hole_size = ~0UL;

-	if (likely(!mm_alloc_pgd(mm))) {
+	if (likely(!mm_alloc_page_table(mm))) {
  		mm->def_flags = 0;
  		return mm;
  	}
@@ -358,7 +358,7 @@
  void fastcall __mmdrop(struct mm_struct *mm)
  {
  	BUG_ON(mm == &init_mm);
-	mm_free_pgd(mm);
+	mm_free_page_table(mm);
  	destroy_context(mm);
  	free_mm(mm);
  }
@@ -490,7 +490,7 @@
  	 * If init_new_context() failed, we cannot use mmput() to free the 
mm
  	 * because it calls destroy_context()
  	 */
-	mm_free_pgd(mm);
+	mm_free_page_table(mm);
  	free_mm(mm);
  	return NULL;
  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
