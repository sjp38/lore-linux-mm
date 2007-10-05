Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l954EXwS013586
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 14:14:33 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l954I7ee264700
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 14:18:08 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l954EGw3004667
	for <linux-mm@kvack.org>; Fri, 5 Oct 2007 14:14:16 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Fri, 05 Oct 2007 09:44:06 +0530
Message-Id: <20071005041406.21236.88707.sendpatchset@balbir-laptop>
Subject: [RFC] [-mm PATCH] Memory controller fix swap charging context in unuse_pte()
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Linux MM Mailing List <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>


Found-by: Hugh Dickins <hugh@veritas.com>

mem_cgroup_charge() in unuse_pte() is called under a lock, the pte_lock. That's
clearly incorrect, since we pass GFP_KERNEL to mem_cgroup_charge() for
allocation of page_cgroup.

This patch release the lock and reacquires the lock after the call to
mem_cgroup_charge().

Tested on a powerpc box by calling swapoff in the middle of a cgroup
running a workload that pushes pages to swap.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 mm/swapfile.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff -puN mm/swapfile.c~memory-controller-fix-unuse-pte-charging mm/swapfile.c
--- linux-2.6.23-rc8/mm/swapfile.c~memory-controller-fix-unuse-pte-charging	2007-10-03 13:45:56.000000000 +0530
+++ linux-2.6.23-rc8-balbir/mm/swapfile.c	2007-10-05 08:49:54.000000000 +0530
@@ -507,11 +507,18 @@ unsigned int count_swap_pages(int type, 
  * just let do_wp_page work it out if a write is requested later - to
  * force COW, vm_page_prot omits write permission from any private vma.
  */
-static int unuse_pte(struct vm_area_struct *vma, pte_t *pte,
-		unsigned long addr, swp_entry_t entry, struct page *page)
+static int unuse_pte(struct vm_area_struct *vma, pte_t *pte, pmd_t *pmd,
+		unsigned long addr, swp_entry_t entry, struct page *page,
+		spinlock_t **ptl)
 {
-	if (mem_cgroup_charge(page, vma->vm_mm, GFP_KERNEL))
+	pte_unmap_unlock(pte - 1, *ptl);
+
+	if (mem_cgroup_charge(page, vma->vm_mm, GFP_KERNEL)) {
+		pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
 		return -ENOMEM;
+	}
+
+	pte_offset_map_lock(vma->vm_mm, pmd, addr, ptl);
 
 	inc_mm_counter(vma->vm_mm, anon_rss);
 	get_page(page);
@@ -543,7 +550,8 @@ static int unuse_pte_range(struct vm_are
 		 * Test inline before going to call unuse_pte.
 		 */
 		if (unlikely(pte_same(*pte, swp_pte))) {
-			ret = unuse_pte(vma, pte++, addr, entry, page);
+			ret = unuse_pte(vma, pte++, pmd, addr, entry, page,
+					&ptl);
 			break;
 		}
 	} while (pte++, addr += PAGE_SIZE, addr != end);
_

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
