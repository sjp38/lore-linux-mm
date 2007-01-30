Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id C1DE8122A7
	for <linux-mm@kvack.org>; Tue, 30 Jan 2007 12:37:20 +0100 (CET)
Date: Tue, 30 Jan 2007 12:37:20 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: make mincore work for general mappings
Message-ID: <20070130113720.GA3038@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Make mincore work for anon mappings, nonlinear, and migration entries.
Based on patch from Linus Torvalds <torvalds@linux-foundation.org>.

Signed-off-by: Nick Piggin <npiggin@suse.de>
Acked-by: Hugh Dickins <hugh@veritas.com>

Index: linux-2.6/mm/mincore.c
===================================================================
--- linux-2.6.orig/mm/mincore.c
+++ linux-2.6/mm/mincore.c
@@ -12,6 +12,8 @@
 #include <linux/mm.h>
 #include <linux/mman.h>
 #include <linux/syscalls.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
@@ -22,14 +24,12 @@
  * and is up to date; i.e. that no page-in operation would be required
  * at this time if an application were to map and access this page.
  */
-static unsigned char mincore_page(struct vm_area_struct * vma,
-	unsigned long pgoff)
+static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
 {
 	unsigned char present = 0;
-	struct address_space * as = vma->vm_file->f_mapping;
-	struct page * page;
+	struct page *page;
 
-	page = find_get_page(as, pgoff);
+	page = find_get_page(mapping, pgoff);
 	if (page) {
 		present = PageUptodate(page);
 		page_cache_release(page);
@@ -45,7 +45,13 @@ static unsigned char mincore_page(struct
  */
 static long do_mincore(unsigned long addr, unsigned char *vec, unsigned long pages)
 {
-	unsigned long i, nr, pgoff;
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *ptep;
+	spinlock_t *ptl;
+	unsigned long i, nr;
+	pgoff_t pgoff;
 	struct vm_area_struct *vma = find_vma(current->mm, addr);
 
 	/*
@@ -56,31 +62,68 @@ static long do_mincore(unsigned long add
 		return -ENOMEM;
 
 	/*
-	 * Ok, got it. But check whether it's a segment we support
-	 * mincore() on. Right now, we don't do any anonymous mappings.
-	 *
-	 * FIXME: This is just stupid. And returning ENOMEM is 
-	 * stupid too. We should just look at the page tables. But
-	 * this is what we've traditionally done, so we'll just
-	 * continue doing it.
+	 * Calculate how many pages there are left in the last level of the
+	 * PTE array for our address.
 	 */
-	if (!vma->vm_file)
-		return -ENOMEM;
-
-	/*
-	 * Calculate how many pages there are left in the vma, and
-	 * what the pgoff is for our address.
-	 */
-	nr = (vma->vm_end - addr) >> PAGE_SHIFT;
+	nr = PTRS_PER_PTE - ((addr >> PAGE_SHIFT) & (PTRS_PER_PTE-1));
 	if (nr > pages)
 		nr = pages;
 
-	pgoff = (addr - vma->vm_start) >> PAGE_SHIFT;
-	pgoff += vma->vm_pgoff;
+	pgd = pgd_offset(vma->vm_mm, addr);
+	if (pgd_none_or_clear_bad(pgd))
+		goto none_mapped;
+	pud = pud_offset(pgd, addr);
+	if (pud_none_or_clear_bad(pud))
+		goto none_mapped;
+	pmd = pmd_offset(pud, addr);
+	if (pmd_none_or_clear_bad(pmd))
+		goto none_mapped;
+
+	ptep = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (i = 0; i < nr; i++, ptep++, addr += PAGE_SIZE) {
+		unsigned char present;
+		pte_t pte = *ptep;
+
+		if (pte_present(pte)) {
+			present = 1;
+
+		} else if (pte_none(pte)) {
+			if (vma->vm_file) {
+				pgoff = linear_page_index(vma, addr);
+				present = mincore_page(vma->vm_file->f_mapping,
+							pgoff);
+			} else
+				present = 0;
+
+		} else if (pte_file(pte)) {
+			pgoff = pte_to_pgoff(pte);
+			present = mincore_page(vma->vm_file->f_mapping, pgoff);
+
+		} else {
+			swp_entry_t entry = pte_to_swp_entry(pte);
+			if (is_migration_entry(entry)) {
+				/* migration entries are always uptodate */
+				present = 1;
+			} else {
+				/*
+				 * This won't be 100% accurate for tmpfs, which
+				 * moves pages between filecache and swapcache
+				 */
+				pgoff = entry.val;
+				present = mincore_page(&swapper_space, pgoff);
+			}
+		}
+	}
+	pte_unmap_unlock(ptep-1, ptl);
+
+	return nr;
 
-	/* And then we just fill the sucker in.. */
-	for (i = 0 ; i < nr; i++, pgoff++)
-		vec[i] = mincore_page(vma, pgoff);
+none_mapped:
+	if (vma->vm_file) {
+		pgoff = linear_page_index(vma, addr);
+		for (i = 0; i < nr; i++, pgoff++)
+			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
+	}
 
 	return nr;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
