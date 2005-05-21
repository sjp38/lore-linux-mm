From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Sat, 21 May 2005 13:54:13 +1000 (EST)
Subject: [PATCH 7/15] PTI: continue calling interface
In-Reply-To: <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.61.0505211352170.28095@wagner.orchestra.cse.unsw.EDU.AU>
References: <20050521024331.GA6984@cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211250570.7134@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211305230.12627@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211313160.17972@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211325210.18258@wagner.orchestra.cse.unsw.EDU.AU>
 <Pine.LNX.4.61.0505211344350.24777@wagner.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Patch 7 of 15.

This patch continues to call the new interface.

 	*lookup_page_table is called in page_check_address in rmap.c
 	*build_page_table is called in handle_mm_fault.
 	*handle_pte_fault, do_file_page and do_anonymous_page are no
 	 longer passed pmds. lookup_page_table is called later on to
 	 avoid passing the pmds
 	*do_no_page is not passed a pmd anymore.  lookup_page_table
 	 is called instead to get the relevant pte.
 	*do_swap_page and do_wp_page are no longer passed pmds.
 	 lookup_page_table is called instead.

  mm/memory.c |   59 
++++++++++++++++++++++++-----------------------------------
  mm/rmap.c   |   27 ++++++++++-----------------
  2 files changed, 34 insertions(+), 52 deletions(-)

Index: linux-2.6.12-rc4/mm/rmap.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/rmap.c	2005-05-19 17:01:14.000000000 
+1000
+++ linux-2.6.12-rc4/mm/rmap.c	2005-05-19 18:01:20.000000000 +1000
@@ -53,6 +53,7 @@
  #include <linux/init.h>
  #include <linux/rmap.h>
  #include <linux/rcupdate.h>
+#include <linux/page_table.h>

  #include <asm/tlbflush.h>

@@ -250,9 +251,6 @@
  static pte_t *page_check_address(struct page *page, struct mm_struct *mm,
  					unsigned long address)
  {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
  	pte_t *pte;

  	/*
@@ -260,20 +258,15 @@
  	 * munmap, fork, etc...
  	 */
  	spin_lock(&mm->page_table_lock);
-	pgd = pgd_offset(mm, address);
-	if (likely(pgd_present(*pgd))) {
-		pud = pud_offset(pgd, address);
-		if (likely(pud_present(*pud))) {
-			pmd = pmd_offset(pud, address);
-			if (likely(pmd_present(*pmd))) {
-				pte = pte_offset_map(pmd, address);
-				if (likely(pte_present(*pte) &&
-					   page_to_pfn(page) == 
pte_pfn(*pte)))
-					return pte;
-				pte_unmap(pte);
-			}
-		}
-	}
+	pte = lookup_page_table(mm, address);
+	if(!pte)
+		goto out_unlock;
+	if (likely(pte_present(*pte) &&
+	   page_to_pfn(page) == pte_pfn(*pte)))
+		return pte;
+	pte_unmap(pte);
+
+out_unlock:
  	spin_unlock(&mm->page_table_lock);
  	return ERR_PTR(-ENOENT);
  }
Index: linux-2.6.12-rc4/mm/memory.c
===================================================================
--- linux-2.6.12-rc4.orig/mm/memory.c	2005-05-19 17:41:04.000000000 
+1000
+++ linux-2.6.12-rc4/mm/memory.c	2005-05-19 18:01:20.000000000 
+1000
@@ -993,7 +993,7 @@
   * with the page_table_lock released.
   */
  static int do_wp_page(struct mm_struct *mm, struct vm_area_struct * vma,
-	unsigned long address, pte_t *page_table, pmd_t *pmd, pte_t pte)
+	unsigned long address, pte_t *page_table, pte_t pte)
  {
  	struct page *old_page, *new_page;
  	unsigned long pfn = pte_pfn(pte);
@@ -1053,7 +1053,8 @@
  	 * Re-check the pte - we dropped the lock
  	 */
  	spin_lock(&mm->page_table_lock);
-	page_table = pte_offset_map(pmd, address);
+	page_table = lookup_page_table(mm, address);
+
  	if (likely(pte_same(*page_table, pte))) {
  		if (PageAnon(old_page))
  			dec_mm_counter(mm, anon_rss);
@@ -1405,7 +1406,7 @@
   */
  static int do_swap_page(struct mm_struct * mm,
  	struct vm_area_struct * vma, unsigned long address,
-	pte_t *page_table, pmd_t *pmd, pte_t orig_pte, int write_access)
+	pte_t *page_table, pte_t orig_pte, int write_access)
  {
  	struct page *page;
  	swp_entry_t entry = pte_to_swp_entry(orig_pte);
@@ -1424,7 +1425,7 @@
  			 * we released the page table lock.
  			 */
  			spin_lock(&mm->page_table_lock);
-			page_table = pte_offset_map(pmd, address);
+			page_table = lookup_page_table(mm, address);
  			if (likely(pte_same(*page_table, orig_pte)))
  				ret = VM_FAULT_OOM;
  			else
@@ -1448,7 +1449,7 @@
  	 * released the page table lock.
  	 */
  	spin_lock(&mm->page_table_lock);
-	page_table = pte_offset_map(pmd, address);
+	page_table = lookup_page_table(mm, address);
  	if (unlikely(!pte_same(*page_table, orig_pte))) {
  		pte_unmap(page_table);
  		spin_unlock(&mm->page_table_lock);
@@ -1478,7 +1479,7 @@

  	if (write_access) {
  		if (do_wp_page(mm, vma, address,
-				page_table, pmd, pte) == VM_FAULT_OOM)
+				page_table, pte) == VM_FAULT_OOM)
  			ret = VM_FAULT_OOM;
  		goto out;
  	}
@@ -1499,7 +1500,7 @@
   */
  static int
  do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		pte_t *page_table, pmd_t *pmd, int write_access,
+		pte_t *page_table, int write_access,
  		unsigned long addr)
  {
  	pte_t entry;
@@ -1521,8 +1522,7 @@
  			goto no_mem;

  		spin_lock(&mm->page_table_lock);
-		page_table = pte_offset_map(pmd, addr);
-
+		page_table = lookup_page_table(mm, addr);
  		if (!pte_none(*page_table)) {
  			pte_unmap(page_table);
  			page_cache_release(page);
@@ -1565,7 +1565,7 @@
   */
  static int
  do_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-	unsigned long address, int write_access, pte_t *page_table, pmd_t 
*pmd)
+	unsigned long address, int write_access, pte_t *page_table)
  {
  	struct page * new_page;
  	struct address_space *mapping = NULL;
@@ -1576,7 +1576,7 @@

  	if (!vma->vm_ops || !vma->vm_ops->nopage)
  		return do_anonymous_page(mm, vma, page_table,
-					pmd, write_access, address);
+					write_access, address);
  	pte_unmap(page_table);
  	spin_unlock(&mm->page_table_lock);

@@ -1631,7 +1631,7 @@
  		page_cache_release(new_page);
  		goto retry;
  	}
-	page_table = pte_offset_map(pmd, address);
+	page_table = lookup_page_table(mm, address);

  	/*
  	 * This silly early PAGE_DIRTY setting removes a race
@@ -1685,7 +1685,7 @@
   * nonlinear vmas.
   */
  static int do_file_page(struct mm_struct * mm, struct vm_area_struct * 
vma,
-	unsigned long address, int write_access, pte_t *pte, pmd_t *pmd)
+	unsigned long address, int write_access, pte_t *pte)
  {
  	unsigned long pgoff;
  	int err;
@@ -1698,7 +1698,7 @@
  	if (!vma->vm_ops || !vma->vm_ops->populate ||
  			(write_access && !(vma->vm_flags & VM_SHARED))) {
  		pte_clear(mm, address, pte);
-		return do_no_page(mm, vma, address, write_access, pte, 
pmd);
+		return do_no_page(mm, vma, address, write_access, pte);
  	}

  	pgoff = pte_to_pgoff(*pte);
@@ -1706,7 +1706,8 @@
  	pte_unmap(pte);
  	spin_unlock(&mm->page_table_lock);

-	err = vma->vm_ops->populate(vma, address & PAGE_MASK, PAGE_SIZE, 
vma->vm_page_prot, pgoff, 0);
+	err = vma->vm_ops->populate(vma, address & PAGE_MASK, PAGE_SIZE,
+		vma->vm_page_prot, pgoff, 0);
  	if (err == -ENOMEM)
  		return VM_FAULT_OOM;
  	if (err)
@@ -1737,8 +1738,8 @@
   */
  static inline int handle_pte_fault(struct mm_struct *mm,
  	struct vm_area_struct * vma, unsigned long address,
-	int write_access, pte_t *pte, pmd_t *pmd)
-{
+	int write_access, pte_t *pte)
+{
  	pte_t entry;

  	entry = *pte;
@@ -1749,15 +1750,15 @@
  		 * drop the lock.
  		 */
  		if (pte_none(entry))
-			return do_no_page(mm, vma, address, write_access, 
pte, pmd);
+			return do_no_page(mm, vma, address, write_access, 
pte);
  		if (pte_file(entry))
-			return do_file_page(mm, vma, address, 
write_access, pte, pmd);
-		return do_swap_page(mm, vma, address, pte, pmd, entry, 
write_access);
+			return do_file_page(mm, vma, address, 
write_access, pte);
+		return do_swap_page(mm, vma, address, pte, entry, 
write_access);
  	}

  	if (write_access) {
  		if (!pte_write(entry))
-			return do_wp_page(mm, vma, address, pte, pmd, 
entry);
+			return do_wp_page(mm, vma, address, pte, entry);

  		entry = pte_mkdirty(entry);
  	}
@@ -1776,9 +1777,6 @@
  int handle_mm_fault(struct mm_struct *mm, struct vm_area_struct * vma,
  		unsigned long address, int write_access)
  {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
  	pte_t *pte;

  	__set_current_state(TASK_RUNNING);
@@ -1792,22 +1790,13 @@
  	 * We need the page table lock to synchronize with kswapd
  	 * and the SMP-safe atomic PTE updates.
  	 */
-	pgd = pgd_offset(mm, address);
  	spin_lock(&mm->page_table_lock);

-	pud = pud_alloc(mm, pgd, address);
-	if (!pud)
-		goto oom;
-
-	pmd = pmd_alloc(mm, pud, address);
-	if (!pmd)
-		goto oom;
-
-	pte = pte_alloc_map(mm, pmd, address);
+	pte = build_page_table(mm, address);
  	if (!pte)
  		goto oom;

-	return handle_pte_fault(mm, vma, address, write_access, pte, pmd);
+	return handle_pte_fault(mm, vma, address, write_access, pte);

   oom:
  	spin_unlock(&mm->page_table_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
