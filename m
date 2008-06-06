Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m56ItOjE026943
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 14:55:24 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m56ItOJQ172212
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 12:55:24 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m56ItOex010620
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 12:55:24 -0600
Subject: [RFC v2][PATCH 2/2] fix large pages in pagemap
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 06 Jun 2008 11:55:22 -0700
References: <20080606185521.38CA3421@kernel>
In-Reply-To: <20080606185521.38CA3421@kernel>
Message-Id: <20080606185522.89DF8EEE@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Rosenfeld <hans.rosenfeld@amd.com>
Cc: Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

We were walking right into huge page areas in the pagemap
walker, and calling the pmds pmd_bad() and clearing them.

That leaked huge pages.  Bad.

This patch at least works around that for now.  It ignores
huge pages in the pagemap walker for the time being, and
won't leak those pages.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/fs/proc/task_mmu.c |   43 ++++++++++++++++++++++++++--------
 1 file changed, 34 insertions(+), 9 deletions(-)

diff -puN fs/proc/task_mmu.c~fix-large-pages-in-pagemap fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~fix-large-pages-in-pagemap	2008-06-06 11:31:48.000000000 -0700
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2008-06-06 11:41:22.000000000 -0700
@@ -563,24 +563,49 @@ static u64 swap_pte_to_pagemap_entry(pte
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
+	struct vm_area_struct *vma = find_vma(walk->mm, addr);
 	struct pagemapread *pm = walk->private;
 	pte_t *pte;
 	int err = 0;
 
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
+		/*
+		 * Remember that find_vma() returns the
+		 * first vma with a vm_end > addr, but
+		 * has no guarantee about addr and
+		 * vm_start.  That means we'll always
+		 * find a vma here, unless we're at
+		 * an addr higher than the highest vma.
+		 */
+		if (vma && (addr >= vma->vm_end))
+			vma = find_vma(walk->mm, addr);
+		if (vma && (vma->vm_start <= addr) &&
+		    !is_vm_hugetlb_page(vma)) {
+			pte = pte_offset_map(pmd, addr);
+			pfn = pte_to_pagemap_entry(*pte);
+			/*
+			 * unmap so we're not in atomic
+			 * when we copy to userspace
+			 */
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
