Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5A5D66B01F7
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:56:16 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 21 of 67] This fixes some minor issues that bugged me while
	going over the code:
Message-Id: <bc95eb6f3d8080780550.1270691464@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:04 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

o adjust argument order of do_mincore() to match the syscall
o simplify range length calculation
o drop superfluous shift in huge tlb calculation, address is page aligned
o drop dead nr_huge calculation
o check pte_none() before pte_present()
o comment and whitespace fixes

No semantic changes intended.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

diff --git a/mm/mincore.c b/mm/mincore.c
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -54,7 +54,7 @@ static unsigned char mincore_page(struct
  * all the arguments, we hold the mmap semaphore: we should
  * just return the amount of info we're asked for.
  */
-static long do_mincore(unsigned long addr, unsigned char *vec, unsigned long pages)
+static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *vec)
 {
 	pgd_t *pgd;
 	pud_t *pud;
@@ -64,35 +64,29 @@ static long do_mincore(unsigned long add
 	unsigned long nr;
 	int i;
 	pgoff_t pgoff;
-	struct vm_area_struct *vma = find_vma(current->mm, addr);
+	struct vm_area_struct *vma;
 
-	/*
-	 * find_vma() didn't find anything above us, or we're
-	 * in an unmapped hole in the address space: ENOMEM.
-	 */
+	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
 
+	nr = min(pages, (vma->vm_end - addr) >> PAGE_SHIFT);
+
 #ifdef CONFIG_HUGETLB_PAGE
 	if (is_vm_hugetlb_page(vma)) {
 		struct hstate *h;
-		unsigned long nr_huge;
-		unsigned char present;
 
 		i = 0;
-		nr = min(pages, (vma->vm_end - addr) >> PAGE_SHIFT);
 		h = hstate_vma(vma);
-		nr_huge = ((addr + pages * PAGE_SIZE - 1) >> huge_page_shift(h))
-			  - (addr >> huge_page_shift(h)) + 1;
-		nr_huge = min(nr_huge,
-			      (vma->vm_end - addr) >> huge_page_shift(h));
 		while (1) {
-			/* hugepage always in RAM for now,
-			 * but generally it needs to be check */
+			unsigned char present;
+			/*
+			 * Huge pages are always in RAM for now, but
+			 * theoretically it needs to be checked.
+			 */
 			ptep = huge_pte_offset(current->mm,
 					       addr & huge_page_mask(h));
-			present = !!(ptep &&
-				     !huge_pte_none(huge_ptep_get(ptep)));
+			present = ptep && !huge_pte_none(huge_ptep_get(ptep));
 			while (1) {
 				vec[i++] = present;
 				addr += PAGE_SIZE;
@@ -100,8 +94,7 @@ static long do_mincore(unsigned long add
 				if (i == nr)
 					return nr;
 				/* check hugepage border */
-				if (!((addr & ~huge_page_mask(h))
-				      >> PAGE_SHIFT))
+				if (!(addr & ~huge_page_mask(h)))
 					break;
 			}
 		}
@@ -113,17 +106,7 @@ static long do_mincore(unsigned long add
 	 * Calculate how many pages there are left in the last level of the
 	 * PTE array for our address.
 	 */
-	nr = PTRS_PER_PTE - ((addr >> PAGE_SHIFT) & (PTRS_PER_PTE-1));
-
-	/*
-	 * Don't overrun this vma
-	 */
-	nr = min(nr, (vma->vm_end - addr) >> PAGE_SHIFT);
-
-	/*
-	 * Don't return more than the caller asked for
-	 */
-	nr = min(nr, pages);
+	nr = min(nr, PTRS_PER_PTE - ((addr >> PAGE_SHIFT) & (PTRS_PER_PTE-1)));
 
 	pgd = pgd_offset(vma->vm_mm, addr);
 	if (pgd_none_or_clear_bad(pgd))
@@ -137,43 +120,38 @@ static long do_mincore(unsigned long add
 
 	ptep = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (i = 0; i < nr; i++, ptep++, addr += PAGE_SIZE) {
-		unsigned char present;
 		pte_t pte = *ptep;
 
-		if (pte_present(pte)) {
-			present = 1;
-
-		} else if (pte_none(pte)) {
+		if (pte_none(pte)) {
 			if (vma->vm_file) {
 				pgoff = linear_page_index(vma, addr);
-				present = mincore_page(vma->vm_file->f_mapping,
-							pgoff);
+				vec[i] = mincore_page(vma->vm_file->f_mapping,
+						pgoff);
 			} else
-				present = 0;
-
-		} else if (pte_file(pte)) {
+				vec[i] = 0;
+		} else if (pte_present(pte))
+			vec[i] = 1;
+		else if (pte_file(pte)) {
 			pgoff = pte_to_pgoff(pte);
-			present = mincore_page(vma->vm_file->f_mapping, pgoff);
-
+			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
 		} else { /* pte is a swap entry */
 			swp_entry_t entry = pte_to_swp_entry(pte);
+
 			if (is_migration_entry(entry)) {
 				/* migration entries are always uptodate */
-				present = 1;
+				vec[i] = 1;
 			} else {
 #ifdef CONFIG_SWAP
 				pgoff = entry.val;
-				present = mincore_page(&swapper_space, pgoff);
+				vec[i] = mincore_page(&swapper_space, pgoff);
 #else
 				WARN_ON(1);
-				present = 1;
+				vec[i] = 1;
 #endif
 			}
 		}
-
-		vec[i] = present;
 	}
-	pte_unmap_unlock(ptep-1, ptl);
+	pte_unmap_unlock(ptep - 1, ptl);
 
 	return nr;
 
@@ -247,7 +225,7 @@ SYSCALL_DEFINE3(mincore, unsigned long, 
 		 * the temporary buffer size.
 		 */
 		down_read(&current->mm->mmap_sem);
-		retval = do_mincore(start, tmp, min(pages, PAGE_SIZE));
+		retval = do_mincore(start, min(pages, PAGE_SIZE), tmp);
 		up_read(&current->mm->mmap_sem);
 
 		if (retval <= 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
