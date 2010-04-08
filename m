Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id F1F76600490
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:57:03 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 22 of 67] Split out functions to handle hugetlb ranges,
	pte ranges and unmapped
Message-Id: <2e302ed815d707d3dda8.1270691465@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:05 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

ranges, to improve readability but also to prepare the file structure for
nested page table walks.

No semantic changes intended.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

diff --git a/mm/mincore.c b/mm/mincore.c
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -19,6 +19,42 @@
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 
+static void mincore_hugetlb_page_range(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long nr,
+				unsigned char *vec)
+{
+#ifdef CONFIG_HUGETLB_PAGE
+	struct hstate *h;
+	int i;
+
+	i = 0;
+	h = hstate_vma(vma);
+	while (1) {
+		unsigned char present;
+		pte_t *ptep;
+		/*
+		 * Huge pages are always in RAM for now, but
+		 * theoretically it needs to be checked.
+		 */
+		ptep = huge_pte_offset(current->mm,
+				       addr & huge_page_mask(h));
+		present = ptep && !huge_pte_none(huge_ptep_get(ptep));
+		while (1) {
+			vec[i++] = present;
+			addr += PAGE_SIZE;
+			/* reach buffer limit */
+			if (i == nr)
+				return;
+			/* check hugepage border */
+			if (!(addr & ~huge_page_mask(h)))
+				break;
+		}
+	}
+#else
+	BUG();
+#endif
+}
+
 /*
  * Later we can get more picky about what "in core" means precisely.
  * For now, simply check to see if the page is in the page cache,
@@ -49,87 +85,40 @@ static unsigned char mincore_page(struct
 	return present;
 }
 
-/*
- * Do a chunk of "sys_mincore()". We've already checked
- * all the arguments, we hold the mmap semaphore: we should
- * just return the amount of info we're asked for.
- */
-static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *vec)
+static void mincore_unmapped_range(struct vm_area_struct *vma,
+				unsigned long addr, unsigned long nr,
+				unsigned char *vec)
 {
-	pgd_t *pgd;
-	pud_t *pud;
-	pmd_t *pmd;
+	int i;
+
+	if (vma->vm_file) {
+		pgoff_t pgoff;
+
+		pgoff = linear_page_index(vma, addr);
+		for (i = 0; i < nr; i++, pgoff++)
+			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
+	} else {
+		for (i = 0; i < nr; i++)
+			vec[i] = 0;
+	}
+}
+
+static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+			unsigned long addr, unsigned long nr,
+			unsigned char *vec)
+{
+	spinlock_t *ptl;
 	pte_t *ptep;
-	spinlock_t *ptl;
-	unsigned long nr;
 	int i;
-	pgoff_t pgoff;
-	struct vm_area_struct *vma;
-
-	vma = find_vma(current->mm, addr);
-	if (!vma || addr < vma->vm_start)
-		return -ENOMEM;
-
-	nr = min(pages, (vma->vm_end - addr) >> PAGE_SHIFT);
-
-#ifdef CONFIG_HUGETLB_PAGE
-	if (is_vm_hugetlb_page(vma)) {
-		struct hstate *h;
-
-		i = 0;
-		h = hstate_vma(vma);
-		while (1) {
-			unsigned char present;
-			/*
-			 * Huge pages are always in RAM for now, but
-			 * theoretically it needs to be checked.
-			 */
-			ptep = huge_pte_offset(current->mm,
-					       addr & huge_page_mask(h));
-			present = ptep && !huge_pte_none(huge_ptep_get(ptep));
-			while (1) {
-				vec[i++] = present;
-				addr += PAGE_SIZE;
-				/* reach buffer limit */
-				if (i == nr)
-					return nr;
-				/* check hugepage border */
-				if (!(addr & ~huge_page_mask(h)))
-					break;
-			}
-		}
-		return nr;
-	}
-#endif
-
-	/*
-	 * Calculate how many pages there are left in the last level of the
-	 * PTE array for our address.
-	 */
-	nr = min(nr, PTRS_PER_PTE - ((addr >> PAGE_SHIFT) & (PTRS_PER_PTE-1)));
-
-	pgd = pgd_offset(vma->vm_mm, addr);
-	if (pgd_none_or_clear_bad(pgd))
-		goto none_mapped;
-	pud = pud_offset(pgd, addr);
-	if (pud_none_or_clear_bad(pud))
-		goto none_mapped;
-	pmd = pmd_offset(pud, addr);
-	if (pmd_none_or_clear_bad(pmd))
-		goto none_mapped;
 
 	ptep = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (i = 0; i < nr; i++, ptep++, addr += PAGE_SIZE) {
 		pte_t pte = *ptep;
+		pgoff_t pgoff;
 
-		if (pte_none(pte)) {
-			if (vma->vm_file) {
-				pgoff = linear_page_index(vma, addr);
-				vec[i] = mincore_page(vma->vm_file->f_mapping,
-						pgoff);
-			} else
-				vec[i] = 0;
-		} else if (pte_present(pte))
+		if (pte_none(pte))
+			mincore_unmapped_range(vma, addr, 1, vec);
+		else if (pte_present(pte))
 			vec[i] = 1;
 		else if (pte_file(pte)) {
 			pgoff = pte_to_pgoff(pte);
@@ -152,19 +141,53 @@ static long do_mincore(unsigned long add
 		}
 	}
 	pte_unmap_unlock(ptep - 1, ptl);
+}
 
+/*
+ * Do a chunk of "sys_mincore()". We've already checked
+ * all the arguments, we hold the mmap semaphore: we should
+ * just return the amount of info we're asked for.
+ */
+static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *vec)
+{
+	pgd_t *pgd;
+	pud_t *pud;
+	pmd_t *pmd;
+	unsigned long nr;
+	struct vm_area_struct *vma;
+
+	vma = find_vma(current->mm, addr);
+	if (!vma || addr < vma->vm_start)
+		return -ENOMEM;
+
+	nr = min(pages, (vma->vm_end - addr) >> PAGE_SHIFT);
+
+	if (is_vm_hugetlb_page(vma)) {
+		mincore_hugetlb_page_range(vma, addr, nr, vec);
+		return nr;
+	}
+
+	/*
+	 * Calculate how many pages there are left in the last level of the
+	 * PTE array for our address.
+	 */
+	nr = min(nr, PTRS_PER_PTE - ((addr >> PAGE_SHIFT) & (PTRS_PER_PTE-1)));
+
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
+	mincore_pte_range(vma, pmd, addr, nr, vec);
 	return nr;
 
 none_mapped:
-	if (vma->vm_file) {
-		pgoff = linear_page_index(vma, addr);
-		for (i = 0; i < nr; i++, pgoff++)
-			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
-	} else {
-		for (i = 0; i < nr; i++)
-			vec[i] = 0;
-	}
-
+	mincore_unmapped_range(vma, addr, nr, vec);
 	return nr;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
