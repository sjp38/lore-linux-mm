From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:46:17 +1100
Message-Id: <20070113024617.29682.90437.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 7/29] Continue calling simple PTI functions
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH 07
 * get_locked_pte removed from memory.c (it is now absorbed into the default
 page table implementation).
 * removes the prototype for get_locked_pte from mm.h
 * Goes through kernel code calling build_page_table in exec.c, fremap.c
 and memory.c. Call new macros to lock and unlock ptes.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 fs/exec.c          |   15 ++++++++++-----
 include/linux/mm.h |    2 --
 mm/fremap.c        |   20 ++++++++++++++------
 mm/memory.c        |   40 ++++++++++++----------------------------
 4 files changed, 36 insertions(+), 41 deletions(-)
Index: linux-2.6.20-rc4/fs/exec.c
===================================================================
--- linux-2.6.20-rc4.orig/fs/exec.c	2007-01-11 13:09:03.951868000 +1100
+++ linux-2.6.20-rc4/fs/exec.c	2007-01-11 13:11:42.147868000 +1100
@@ -50,6 +50,7 @@
 #include <linux/tsacct_kern.h>
 #include <linux/cn_proc.h>
 #include <linux/audit.h>
+#include <linux/pt.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
@@ -308,17 +309,21 @@
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
@@ -326,8 +331,8 @@
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
Index: linux-2.6.20-rc4/mm/fremap.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/fremap.c	2007-01-11 13:09:03.951868000 +1100
+++ linux-2.6.20-rc4/mm/fremap.c	2007-01-11 13:11:42.227868000 +1100
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/pt.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -56,9 +57,11 @@
 	int err = -ENOMEM;
 	pte_t *pte;
 	pte_t pte_val;
-	spinlock_t *ptl;
+	pt_path_t pt_path;
+
+	pte = build_page_table(mm, addr, &pt_path);
+	lock_pte(mm, pt_path);
 
-	pte = get_locked_pte(mm, addr, &ptl);
 	if (!pte)
 		goto out;
 
@@ -86,7 +89,8 @@
 	lazy_mmu_prot_update(pte_val);
 	err = 0;
 unlock:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 out:
 	return err;
 }
@@ -101,9 +105,11 @@
 {
 	int err = -ENOMEM;
 	pte_t *pte;
-	spinlock_t *ptl;
+ 	pt_path_t pt_path;
+
+ 	pte = build_page_table(mm, addr, &pt_path);
+ 	lock_pte(mm, pt_path);
 
-	pte = get_locked_pte(mm, addr, &ptl);
 	if (!pte)
 		goto out;
 
@@ -120,7 +126,9 @@
 	 * be mapped there when there's a fault (in a non-linear vma where
 	 * that's not obvious).
 	 */
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
+
 	err = 0;
 out:
 	return err;
Index: linux-2.6.20-rc4/mm/memory.c
===================================================================
--- linux-2.6.20-rc4.orig/mm/memory.c	2007-01-11 13:11:37.315868000 +1100
+++ linux-2.6.20-rc4/mm/memory.c	2007-01-11 13:11:42.227868000 +1100
@@ -50,6 +50,7 @@
 #include <linux/delayacct.h>
 #include <linux/init.h>
 #include <linux/writeback.h>
+#include <linux/pt.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -1134,18 +1135,6 @@
 	return err;
 }
 
-pte_t * fastcall get_locked_pte(struct mm_struct *mm, unsigned long addr, spinlock_t **ptl)
-{
-	pgd_t * pgd = pgd_offset(mm, addr);
-	pud_t * pud = pud_alloc(mm, pgd, addr);
-	if (pud) {
-		pmd_t * pmd = pmd_alloc(mm, pud, addr);
-		if (pmd)
-			return pte_alloc_map_lock(mm, pmd, addr, ptl);
-	}
-	return NULL;
-}
-
 /*
  * This is the old fallback for page remapping.
  *
@@ -1157,14 +1146,17 @@
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
+
+	pte = build_page_table(mm, addr, &pt_path);
+	lock_pte(mm, pt_path);
+
 	if (!pte)
 		goto out;
 	retval = -EBUSY;
@@ -1179,7 +1171,8 @@
 
 	retval = 0;
 out_unlock:
-	pte_unmap_unlock(pte, ptl);
+	unlock_pte(mm, pt_path);
+	pte_unmap(pte);
 out:
 	return retval;
 }
@@ -2385,13 +2378,12 @@
 /*
  * By the time we get here, we already hold the mm semaphore
  */
+
 int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, int write_access)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
 	pte_t *pte;
+	pt_path_t pt_path;
 
 	__set_current_state(TASK_RUNNING);
 
@@ -2400,20 +2392,12 @@
 	if (unlikely(is_vm_hugetlb_page(vma)))
 		return hugetlb_fault(mm, vma, address, write_access);
 
-	pgd = pgd_offset(mm, address);
-	pud = pud_alloc(mm, pgd, address);
-	if (!pud)
-		return VM_FAULT_OOM;
-	pmd = pmd_alloc(mm, pud, address);
-	if (!pmd)
-		return VM_FAULT_OOM;
-	pte = pte_alloc_map(mm, pmd, address);
+	pte = build_page_table(mm, address, &pt_path);
 	if (!pte)
 		return VM_FAULT_OOM;
 
-	return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
+	return handle_pte_fault(mm, vma, address, pte, pt_path.pmd, write_access);
 }
-
 EXPORT_SYMBOL_GPL(__handle_mm_fault);
 
 int make_pages_present(unsigned long addr, unsigned long end)
Index: linux-2.6.20-rc4/include/linux/mm.h
===================================================================
--- linux-2.6.20-rc4.orig/include/linux/mm.h	2007-01-11 13:11:38.999868000 +1100
+++ linux-2.6.20-rc4/include/linux/mm.h	2007-01-11 13:11:42.231868000 +1100
@@ -849,8 +849,6 @@
 		mapping_cap_account_dirty(vma->vm_file->f_mapping);
 }
 
-extern pte_t *FASTCALL(get_locked_pte(struct mm_struct *mm, unsigned long addr, spinlock_t **ptl));
-
 #ifdef CONFIG_PT_DEFAULT
 #include <linux/pt-default-mm.h>
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
