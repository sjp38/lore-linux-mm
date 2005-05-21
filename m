From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 13:47:01 +1000 (EST)
Subject: [PATCH 6/15] PTI: Start calling the interface
In-Reply-To: <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 6 of 15.

This patch starts calling the interface.  The mlpt now actually
starts to run through the interface.

 	*fork.c calls init_page_table and free_page_table to create
 	 and delete user page tables as part of the forking process.
 	*exec.c calls build_page_table in install_arg_page.
 	*fremap.c calls build_page_table in install_page and
 	 in install_file_pte.
 	*mremap.c calls lookup_nested_pte, lookup_page_table and
 	 build_page_table from the general interface in move_one_page.
 	*A number of functions look to have disappeared from mremap.c
 	 but this functionality has simply moved behind the page
 	 table interface.

  fs/exec.c     |   17 +++---------
  kernel/fork.c |    6 +---
  mm/fremap.c   |   33 ++-----------------------
  mm/mremap.c   |   76 
+++-------------------------------------------------------
  4 files changed, 14 insertions(+), 118 deletions(-)

Index: linux-2.6.12-rc4/kernel/fork.c
===================================================================
--- linux-2.6.12-rc4.orig/kernel/fork.c	2005-05-19 17:24:20.000000000 
+1000
+++ linux-2.6.12-rc4/kernel/fork.c	2005-05-19 17:55:08.000000000 
+1000
@@ -41,9 +41,7 @@
  #include <linux/profile.h>
  #include <linux/rmap.h>
  #include <linux/acct.h>
-
-#include <asm/pgtable.h>
-#include <asm/pgalloc.h>
+#include <linux/page_table.h>
  #include <asm/uaccess.h>
  #include <asm/mmu_context.h>
  #include <asm/cacheflush.h>
@@ -286,7 +284,7 @@

  static inline int mm_alloc_pgd(struct mm_struct * mm)
  {
-	mm->pgd = pgd_alloc(mm);
+	mm->pgd = init_page_table();
  	if (unlikely(!mm->pgd))
  		return -ENOMEM;
  	return 0;
Index: linux-2.6.12-rc4/fs/exec.c
===================================================================
--- linux-2.6.12-rc4.orig/fs/exec.c	2005-05-19 17:24:20.000000000 
+1000
+++ linux-2.6.12-rc4/fs/exec.c	2005-05-19 17:55:08.000000000 +1000
@@ -48,6 +48,7 @@
  #include <linux/syscalls.h>
  #include <linux/rmap.h>
  #include <linux/acct.h>
+#include <linux/page_table.h>

  #include <asm/uaccess.h>
  #include <asm/mmu_context.h>
@@ -302,25 +303,15 @@
  			struct page *page, unsigned long address)
  {
  	struct mm_struct *mm = vma->vm_mm;
-	pgd_t * pgd;
-	pud_t * pud;
-	pmd_t * pmd;
  	pte_t * pte;

  	if (unlikely(anon_vma_prepare(vma)))
  		goto out_sig;
-
+
  	flush_dcache_page(page);
-	pgd = pgd_offset(mm, address);
+	spin_lock(&mm->page_table_lock);

-	spin_lock(&mm->page_table_lock);
-	pud = pud_alloc(mm, pgd, address);
-	if (!pud)
-		goto out;
-	pmd = pmd_alloc(mm, pud, address);
-	if (!pmd)
-		goto out;
-	pte = pte_alloc_map(mm, pmd, address);
+	pte = build_page_table(mm, address);
  	if (!pte)
  		goto out;
  	if (!pte_none(*pte)) {
Index: linux-2.6.12-rc4/mm/fremap.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/fremap.c	2005-05-19 17:24:20.000000000 
+1000
+++ linux-2.6.12-rc4/mm/fremap.c	2005-05-19 17:55:08.000000000 
+1000
@@ -15,6 +15,7 @@
  #include <linux/rmap.h>
  #include <linux/module.h>
  #include <linux/syscalls.h>
+#include <linux/page_table.h>

  #include <asm/mmu_context.h>
  #include <asm/cacheflush.h>
@@ -60,23 +61,10 @@
  	pgoff_t size;
  	int err = -ENOMEM;
  	pte_t *pte;
-	pmd_t *pmd;
-	pud_t *pud;
-	pgd_t *pgd;
  	pte_t pte_val;

-	pgd = pgd_offset(mm, addr);
  	spin_lock(&mm->page_table_lock);
-
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		goto err_unlock;
-
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		goto err_unlock;
-
-	pte = pte_alloc_map(mm, pmd, addr);
+	pte = build_page_table(mm, addr);
  	if (!pte)
  		goto err_unlock;

@@ -107,7 +95,6 @@
  }
  EXPORT_SYMBOL(install_page);

-
  /*
   * Install a file pte to a given virtual memory address, release any
   * previously existing mapping.
@@ -117,23 +104,10 @@
  {
  	int err = -ENOMEM;
  	pte_t *pte;
-	pmd_t *pmd;
-	pud_t *pud;
-	pgd_t *pgd;
  	pte_t pte_val;

-	pgd = pgd_offset(mm, addr);
  	spin_lock(&mm->page_table_lock);
-
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		goto err_unlock;
-
-	pmd = pmd_alloc(mm, pud, addr);
-	if (!pmd)
-		goto err_unlock;
-
-	pte = pte_alloc_map(mm, pmd, addr);
+	pte = build_page_table(mm, addr);
  	if (!pte)
  		goto err_unlock;

@@ -151,7 +125,6 @@
  	return err;
  }

-
  /***
   * sys_remap_file_pages - remap arbitrary pages of a shared backing store
   *                        file within an existing vma.
Index: linux-2.6.12-rc4/mm/mremap.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/mremap.c	2005-05-19 17:24:20.000000000 
+1000
+++ linux-2.6.12-rc4/mm/mremap.c	2005-05-19 17:55:08.000000000 
+1000
@@ -17,78 +17,12 @@
  #include <linux/highmem.h>
  #include <linux/security.h>
  #include <linux/syscalls.h>
+#include <linux/page_table.h>

  #include <asm/uaccess.h>
  #include <asm/cacheflush.h>
  #include <asm/tlbflush.h>

-static pte_t *get_one_pte_map_nested(struct mm_struct *mm, unsigned long 
addr)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte = NULL;
-
-	pgd = pgd_offset(mm, addr);
-	if (pgd_none_or_clear_bad(pgd))
-		goto end;
-
-	pud = pud_offset(pgd, addr);
-	if (pud_none_or_clear_bad(pud))
-		goto end;
-
-	pmd = pmd_offset(pud, addr);
-	if (pmd_none_or_clear_bad(pmd))
-		goto end;
-
-	pte = pte_offset_map_nested(pmd, addr);
-	if (pte_none(*pte)) {
-		pte_unmap_nested(pte);
-		pte = NULL;
-	}
-end:
-	return pte;
-}
-
-static pte_t *get_one_pte_map(struct mm_struct *mm, unsigned long addr)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-
-	pgd = pgd_offset(mm, addr);
-	if (pgd_none_or_clear_bad(pgd))
-		return NULL;
-
-	pud = pud_offset(pgd, addr);
-	if (pud_none_or_clear_bad(pud))
-		return NULL;
-
-	pmd = pmd_offset(pud, addr);
-	if (pmd_none_or_clear_bad(pmd))
-		return NULL;
-
-	return pte_offset_map(pmd, addr);
-}
-
-static inline pte_t *alloc_one_pte_map(struct mm_struct *mm, unsigned 
long addr)
-{
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
-	pte_t *pte = NULL;
-
-	pgd = pgd_offset(mm, addr);
-
-	pud = pud_alloc(mm, pgd, addr);
-	if (!pud)
-		return NULL;
-	pmd = pmd_alloc(mm, pud, addr);
-	if (pmd)
-		pte = pte_alloc_map(mm, pmd, addr);
-	return pte;
-}
-
  static int
  move_one_page(struct vm_area_struct *vma, unsigned long old_addr,
  		struct vm_area_struct *new_vma, unsigned long new_addr)
@@ -113,25 +47,25 @@
  	}
  	spin_lock(&mm->page_table_lock);

-	src = get_one_pte_map_nested(mm, old_addr);
+	src = lookup_nested_pte(mm, old_addr);
  	if (src) {
  		/*
  		 * Look to see whether alloc_one_pte_map needs to perform 
a
  		 * memory allocation.  If it does then we need to drop the
  		 * atomic kmap
  		 */
-		dst = get_one_pte_map(mm, new_addr);
+		dst = lookup_page_table(mm, new_addr);
  		if (unlikely(!dst)) {
  			pte_unmap_nested(src);
  			if (mapping)
  				spin_unlock(&mapping->i_mmap_lock);
-			dst = alloc_one_pte_map(mm, new_addr);
+			dst = build_page_table(mm, new_addr);
  			if (mapping && 
!spin_trylock(&mapping->i_mmap_lock)) {
  				spin_unlock(&mm->page_table_lock);
  				spin_lock(&mapping->i_mmap_lock);
  				spin_lock(&mm->page_table_lock);
  			}
-			src = get_one_pte_map_nested(mm, old_addr);
+			src = lookup_nested_pte(mm, old_addr);
  		}
  		/*
  		 * Since alloc_one_pte_map can drop and re-acquire

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
