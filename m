Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m56HVlGg007115
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 13:31:47 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m56HVeGD085052
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 11:31:40 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m56HVdI4026120
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 11:31:39 -0600
Subject: [RFC][PATCH 2/2] fix large pages in pagemap
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 06 Jun 2008 10:31:38 -0700
References: <20080606173137.24513039@kernel>
In-Reply-To: <20080606173137.24513039@kernel>
Message-Id: <20080606173138.9BFE6272@kernel>
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

 linux-2.6.git-dave/fs/proc/task_mmu.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff -puN fs/proc/task_mmu.c~fix-large-pages-in-pagemap fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~fix-large-pages-in-pagemap	2008-06-06 09:44:45.000000000 -0700
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2008-06-06 09:48:44.000000000 -0700
@@ -567,12 +567,19 @@ static u64 swap_pte_to_pagemap_entry(pte
 static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			     struct mm_walk *walk)
 {
+	struct vm_area_struct *vma = NULL;
 	struct pagemapread *pm = walk->private;
 	pte_t *pte;
 	int err = 0;
 
 	for (; addr != end; addr += PAGE_SIZE) {
 		u64 pfn = PM_NOT_PRESENT;
+
+		if (!vma || addr >= vma->vm_end)
+			vma = find_vma(walk->mm, addr);
+		if (vma && is_vm_hugetlb_page(vma)) {
+			goto add:
+
 		pte = pte_offset_map(pmd, addr);
 		if (is_swap_pte(*pte))
 			pfn = PM_PFRAME(swap_pte_to_pagemap_entry(*pte))
@@ -582,6 +589,7 @@ static int pagemap_pte_range(pmd_t *pmd,
 				| PM_PSHIFT(PAGE_SHIFT) | PM_PRESENT;
 		/* unmap so we're not in atomic when we copy to userspace */
 		pte_unmap(pte);
+	add:
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
