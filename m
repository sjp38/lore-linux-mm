Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5BI2WlJ025622
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 14:02:32 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5BI2WVO178378
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 14:02:32 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5BI2W0O014007
	for <linux-mm@kvack.org>; Wed, 11 Jun 2008 14:02:32 -0400
Subject: [v4][PATCH 2/2] fix large pages in pagemap
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Wed, 11 Jun 2008 11:02:31 -0700
References: <20080611180228.12987026@kernel>
In-Reply-To: <20080611180228.12987026@kernel>
Message-Id: <20080611180230.7459973B@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Hans Rosenfeld <hans.rosenfeld@amd.com>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

We were walking right into huge page areas in the pagemap
walker, and calling the pmds pmd_bad() and clearing them.

That leaked huge pages.  Bad.

This patch at least works around that for now.  It ignores
huge pages in the pagemap walker for the time being, and
won't leak those pages.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
Acked-by: Matt Mackall <mpm@selenic.com>
---

 linux-2.6.git-dave/fs/proc/task_mmu.c |   39 ++++++++++++++++++++++++++--------
 1 file changed, 30 insertions(+), 9 deletions(-)

diff -puN fs/proc/task_mmu.c~fix-large-pages-in-pagemap fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~fix-large-pages-in-pagemap	2008-06-11 10:59:29.000000000 -0700
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2008-06-11 10:59:29.000000000 -0700
@@ -563,24 +563,45 @@ static u64 swap_pte_to_pagemap_entry(pte
 	return swp_type(e) | (swp_offset(e) << MAX_SWAPFILES_SHIFT);
 }
 
+static unsigned long pte_to_pagemap_entry(pte_t pte)
+{
+	unsigned long pme = 0;
+	if (is_swap_pte(pte))
+		pme = PM_PFRAME(swap_pte_to_pagemap_entry(pte))
+			| PM_PSHIFT(PAGE_SHIFT) | PM_SWAP;
+	else if (pte_present(pte))
+		pme = PM_PFRAME(pte_pfn(pte))
+			| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
+	return pme;
+}
+
 static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
+	struct vm_area_struct *vma;
 	struct pagemapread *pm = walk->private;
 	pte_t *pte;
 	int err = 0;
 
+	/* find the first VMA at or above 'addr' */
+	vma = find_vma(walk->mm, addr);
 	for (; addr != end; addr += PAGE_SIZE) {
 		u64 pfn = PM_NOT_PRESENT;
-		pte = pte_offset_map(pmd, addr);
-		if (is_swap_pte(*pte))
-			pfn = PM_PFRAME(swap_pte_to_pagemap_entry(*pte))
-				| PM_PSHIFT(PAGE_SHIFT) | PM_SWAP;
-		else if (pte_present(*pte))
-			pfn = PM_PFRAME(pte_pfn(*pte))
-				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
-		/* unmap so we're not in atomic when we copy to userspace */
-		pte_unmap(pte);
+
+		/* check to see if we've left 'vma' behind
+		 * and need a new, higher one */
+		if (vma && (addr >= vma->vm_end))
+			vma = find_vma(walk->mm, addr);
+
+		/* check that 'vma' actually covers this address,
+		 * and that it isn't a huge page vma */
+		if (vma && (vma->vm_start <= addr) &&
+		    !is_vm_hugetlb_page(vma)) {
+			pte = pte_offset_map(pmd, addr);
+			pfn = pte_to_pagemap_entry(*pte);
+			/* unmap before userspace copy */
+			pte_unmap(pte);
+		}
 		err = add_to_pagemap(addr, pfn, pm);
 		if (err)
 			return err;
diff -puN mm/pagewalk.c~fix-large-pages-in-pagemap mm/pagewalk.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
