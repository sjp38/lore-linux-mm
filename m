Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A6CF6B01F5
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 22:56:20 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 23 of 67] Instead of passing a start address and a number of
	pages into the helper
Message-Id: <e64f6884b5301d6128a8.1270691466@v2.random>
In-Reply-To: <patchbomb.1270691443@v2.random>
References: <patchbomb.1270691443@v2.random>
Date: Thu, 08 Apr 2010 03:51:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

functions, convert them to use a start and an end address.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

diff --git a/mm/mincore.c b/mm/mincore.c
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -20,14 +20,12 @@
 #include <asm/pgtable.h>
 
 static void mincore_hugetlb_page_range(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long nr,
+				unsigned long addr, unsigned long end,
 				unsigned char *vec)
 {
 #ifdef CONFIG_HUGETLB_PAGE
 	struct hstate *h;
-	int i;
 
-	i = 0;
 	h = hstate_vma(vma);
 	while (1) {
 		unsigned char present;
@@ -40,10 +38,10 @@ static void mincore_hugetlb_page_range(s
 				       addr & huge_page_mask(h));
 		present = ptep && !huge_pte_none(huge_ptep_get(ptep));
 		while (1) {
-			vec[i++] = present;
+			*vec = present;
+			vec++;
 			addr += PAGE_SIZE;
-			/* reach buffer limit */
-			if (i == nr)
+			if (addr == end)
 				return;
 			/* check hugepage border */
 			if (!(addr & ~huge_page_mask(h)))
@@ -86,9 +84,10 @@ static unsigned char mincore_page(struct
 }
 
 static void mincore_unmapped_range(struct vm_area_struct *vma,
-				unsigned long addr, unsigned long nr,
+				unsigned long addr, unsigned long end,
 				unsigned char *vec)
 {
+	unsigned long nr = (end - addr) >> PAGE_SHIFT;
 	int i;
 
 	if (vma->vm_file) {
@@ -104,42 +103,44 @@ static void mincore_unmapped_range(struc
 }
 
 static void mincore_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
-			unsigned long addr, unsigned long nr,
+			unsigned long addr, unsigned long end,
 			unsigned char *vec)
 {
+	unsigned long next;
 	spinlock_t *ptl;
 	pte_t *ptep;
-	int i;
 
 	ptep = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	for (i = 0; i < nr; i++, ptep++, addr += PAGE_SIZE) {
+	do {
 		pte_t pte = *ptep;
 		pgoff_t pgoff;
 
+		next = addr + PAGE_SIZE;
 		if (pte_none(pte))
-			mincore_unmapped_range(vma, addr, 1, vec);
+			mincore_unmapped_range(vma, addr, next, vec);
 		else if (pte_present(pte))
-			vec[i] = 1;
+			*vec = 1;
 		else if (pte_file(pte)) {
 			pgoff = pte_to_pgoff(pte);
-			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
+			*vec = mincore_page(vma->vm_file->f_mapping, pgoff);
 		} else { /* pte is a swap entry */
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
 			if (is_migration_entry(entry)) {
 				/* migration entries are always uptodate */
-				vec[i] = 1;
+				*vec = 1;
 			} else {
 #ifdef CONFIG_SWAP
 				pgoff = entry.val;
-				vec[i] = mincore_page(&swapper_space, pgoff);
+				*vec = mincore_page(&swapper_space, pgoff);
 #else
 				WARN_ON(1);
-				vec[i] = 1;
+				*vec = 1;
 #endif
 			}
 		}
-	}
+		vec++;
+	} while (ptep++, addr = next, addr != end);
 	pte_unmap_unlock(ptep - 1, ptl);
 }
 
@@ -153,25 +154,21 @@ static long do_mincore(unsigned long add
 	pgd_t *pgd;
 	pud_t *pud;
 	pmd_t *pmd;
-	unsigned long nr;
 	struct vm_area_struct *vma;
+	unsigned long end;
 
 	vma = find_vma(current->mm, addr);
 	if (!vma || addr < vma->vm_start)
 		return -ENOMEM;
 
-	nr = min(pages, (vma->vm_end - addr) >> PAGE_SHIFT);
+	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
 
 	if (is_vm_hugetlb_page(vma)) {
-		mincore_hugetlb_page_range(vma, addr, nr, vec);
-		return nr;
+		mincore_hugetlb_page_range(vma, addr, end, vec);
+		return (end - addr) >> PAGE_SHIFT;
 	}
 
-	/*
-	 * Calculate how many pages there are left in the last level of the
-	 * PTE array for our address.
-	 */
-	nr = min(nr, PTRS_PER_PTE - ((addr >> PAGE_SHIFT) & (PTRS_PER_PTE-1)));
+	end = pmd_addr_end(addr, end);
 
 	pgd = pgd_offset(vma->vm_mm, addr);
 	if (pgd_none_or_clear_bad(pgd))
@@ -183,12 +180,12 @@ static long do_mincore(unsigned long add
 	if (pmd_none_or_clear_bad(pmd))
 		goto none_mapped;
 
-	mincore_pte_range(vma, pmd, addr, nr, vec);
-	return nr;
+	mincore_pte_range(vma, pmd, addr, end, vec);
+	return (end - addr) >> PAGE_SHIFT;
 
 none_mapped:
-	mincore_unmapped_range(vma, addr, nr, vec);
-	return nr;
+	mincore_unmapped_range(vma, addr, end, vec);
+	return (end - addr) >> PAGE_SHIFT;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
