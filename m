Date: Tue, 16 Jan 2001 01:57:08 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Aggressive swapout with 2.4.1pre4+ 
Message-ID: <Pine.LNX.4.21.0101160138140.1556-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Linus, 

Currently swap_out() scans a fixed percentage of each process RSS without
taking into account how much memory we are out of.

The following patch changes that by making swap_out() stop when it
successfully moved the "needed" (calculated by refill_inactive()) amount
of pages to the swap cache. 

This should avoid the system to swap out to aggressively. 

Comments? 

Note: for background pte scanning, the "needed" argument to swap_out() can
point to "-1" so the scan does not stop.

diff -Nur linux.orig/mm/vmscan.c linux/mm/vmscan.c
--- linux.orig/mm/vmscan.c	Mon Jan 15 20:19:38 2001
+++ linux/mm/vmscan.c	Tue Jan 16 03:04:07 2001
@@ -35,21 +35,22 @@
  * using a process that no longer actually exists (it might
  * have died while we slept).
  */
-static void try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, struct page *page)
+static int try_to_swap_out(struct mm_struct * mm, struct vm_area_struct* vma, unsigned long address, pte_t * page_table, struct page *page)
 {
 	pte_t pte;
 	swp_entry_t entry;
+	int ret = 0;
 
 	/* Don't look at this pte if it's been accessed recently. */
 	if (ptep_test_and_clear_young(page_table)) {
 		page->age += PAGE_AGE_ADV;
 		if (page->age > PAGE_AGE_MAX)
 			page->age = PAGE_AGE_MAX;
-		return;
+		return ret;
 	}
 
 	if (TryLockPage(page))
-		return;
+		return ret;
 
 	/* From this point on, the odds are that we're going to
 	 * nuke this pte, so read and clear the pte.  This hook
@@ -77,7 +78,7 @@
 			deactivate_page(page);
 		UnlockPage(page);
 		page_cache_release(page);
-		return;
+		return ret;
 	}
 
 	/*
@@ -121,25 +122,26 @@
 	/* Add it to the swap cache and mark it dirty */
 	add_to_swap_cache(page, entry);
 	set_page_dirty(page);
+	ret = 1;
 	goto set_swap_pte;
 
 out_unlock_restore:
 	set_pte(page_table, pte);
 	UnlockPage(page);
-	return;
+	return ret;
 }
 
-static int swap_out_pmd(struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int count)
+static int swap_out_pmd(struct mm_struct * mm, struct vm_area_struct * vma, pmd_t *dir, unsigned long address, unsigned long end, int maxtry, int *count)
 {
 	pte_t * pte;
 	unsigned long pmd_end;
 
 	if (pmd_none(*dir))
-		return count;
+		return maxtry;
 	if (pmd_bad(*dir)) {
 		pmd_ERROR(*dir);
 		pmd_clear(dir);
-		return count;
+		return maxtry;
 	}
 	
 	pte = pte_offset(dir, address);
@@ -150,11 +152,16 @@
 
 	do {
 		if (pte_present(*pte)) {
+			int result;
 			struct page *page = pte_page(*pte);
 
 			if (VALID_PAGE(page) && !PageReserved(page)) {
-				try_to_swap_out(mm, vma, address, pte, page);
-				if (!--count)
+				*count -= try_to_swap_out(mm, vma, address, pte, page);
+				if (!*count) {
+					maxtry = 0;
+					break;
+				}
+				if (!--maxtry)
 					break;
 			}
 		}
@@ -162,20 +169,20 @@
 		pte++;
 	} while (address && (address < end));
 	mm->swap_address = address + PAGE_SIZE;
-	return count;
+	return maxtry;
 }
 
-static inline int swap_out_pgd(struct mm_struct * mm, struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int count)
+static inline int swap_out_pgd(struct mm_struct * mm, struct vm_area_struct * vma, pgd_t *dir, unsigned long address, unsigned long end, int maxtry, int *count)
 {
 	pmd_t * pmd;
 	unsigned long pgd_end;
 
 	if (pgd_none(*dir))
-		return count;
+		return maxtry;
 	if (pgd_bad(*dir)) {
 		pgd_ERROR(*dir);
 		pgd_clear(dir);
-		return count;
+		return maxtry;
 	}
 
 	pmd = pmd_offset(dir, address);
@@ -185,23 +192,23 @@
 		end = pgd_end;
 	
 	do {
-		count = swap_out_pmd(mm, vma, pmd, address, end, count);
-		if (!count)
+		maxtry = swap_out_pmd(mm, vma, pmd, address, end, maxtry, count);
+		if (!maxtry)
 			break;
 		address = (address + PMD_SIZE) & PMD_MASK;
 		pmd++;
 	} while (address && (address < end));
-	return count;
+	return maxtry;
 }
 
-static int swap_out_vma(struct mm_struct * mm, struct vm_area_struct * vma, unsigned long address, int count)
+static int swap_out_vma(struct mm_struct * mm, struct vm_area_struct * vma, unsigned long address, int maxtry, int *count)
 {
 	pgd_t *pgdir;
 	unsigned long end;
 
 	/* Don't swap out areas which are locked down */
 	if (vma->vm_flags & (VM_LOCKED|VM_RESERVED))
-		return count;
+		return maxtry;
 
 	pgdir = pgd_offset(mm, address);
 
@@ -209,16 +216,16 @@
 	if (address >= end)
 		BUG();
 	do {
-		count = swap_out_pgd(mm, vma, pgdir, address, end, count);
-		if (!count)
+		maxtry = swap_out_pgd(mm, vma, pgdir, address, end, maxtry, count);
+		if (!maxtry)
 			break;
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		pgdir++;
 	} while (address && (address < end));
-	return count;
+	return maxtry;
 }
 
-static int swap_out_mm(struct mm_struct * mm, int count)
+static int swap_out_mm(struct mm_struct * mm, int maxtry, int *count)
 {
 	unsigned long address;
 	struct vm_area_struct* vma;
@@ -239,8 +246,8 @@
 			address = vma->vm_start;
 
 		for (;;) {
-			count = swap_out_vma(mm, vma, address, count);
-			if (!count)
+			maxtry = swap_out_vma(mm, vma, address, maxtry, count);
+			if (!maxtry)
 				goto out_unlock;
 			vma = vma->vm_next;
 			if (!vma)
@@ -253,7 +260,7 @@
 
 out_unlock:
 	spin_unlock(&mm->page_table_lock);
-	return !count;
+	return !maxtry;
 }
 
 /*
@@ -269,15 +276,17 @@
 	return nr < SWAP_MIN ? SWAP_MIN : nr;
 }
 
-static int swap_out(unsigned int priority, int gfp_mask)
+static int swap_out(unsigned int priority, int *needed, int gfp_mask)
 {
-	int counter;
-	int retval = 0;
+	int counter, retval = 0;
 	struct mm_struct *mm = current->mm;
 
 	/* Always start by trying to penalize the process that is allocating memory */
-	if (mm)
-		retval = swap_out_mm(mm, swap_amount(mm));
+	if (mm) {
+		retval = swap_out_mm(mm, swap_amount(mm), needed);
+		if(!*needed)
+			return 1;
+	}
 
 	/* Then, look at the other mm's */
 	counter = mmlist_nr >> priority;
@@ -299,8 +308,10 @@
 		spin_unlock(&mmlist_lock);
 
 		/* Walk about 6% of the address space each time */
-		retval |= swap_out_mm(mm, swap_amount(mm));
+		retval |= swap_out_mm(mm, swap_amount(mm), needed);
 		mmput(mm);
+		if (!*needed)
+			return retval;
 	} while (--counter >= 0);
 	return retval;
 
@@ -806,7 +817,10 @@
 		}
 
 		/* If refill_inactive_scan failed, try to page stuff out.. */
-		swap_out(DEF_PRIORITY, gfp_mask);
+		swap_out(DEF_PRIORITY, &count, gfp_mask);
+
+		if (count <= 0) 
+			goto done;
 
 		if (--maxtry <= 0)
 				return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
