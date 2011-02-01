Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B96CB8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:34:07 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p110AGGP000937
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:10:18 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 5BEC772804D
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:34:05 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p110Y4242371712
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:34:04 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p110Y4al019578
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 22:34:04 -0200
Subject: [RFC][PATCH 5/6] teach smaps_pte_range() about THP pmds
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 31 Jan 2011 16:34:03 -0800
References: <20110201003357.D6F0BE0D@kernel>
In-Reply-To: <20110201003357.D6F0BE0D@kernel>
Message-Id: <20110201003403.736A24DF@kernel>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


This adds code to explicitly detect  and handle
pmd_trans_huge() pmds.  It then passes HPAGE_SIZE units
in to the smap_pte_entry() function instead of PAGE_SIZE.

This means that using /proc/$pid/smaps now will no longer
cause THPs to be broken down in to small pages.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/fs/proc/task_mmu.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff -puN fs/proc/task_mmu.c~teach-smaps_pte_range-about-thp-pmds fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~teach-smaps_pte_range-about-thp-pmds	2011-01-31 15:10:55.387856566 -0800
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-01-31 15:25:12.231239775 -0800
@@ -1,5 +1,6 @@
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
+#include <linux/huge_mm.h>
 #include <linux/mount.h>
 #include <linux/seq_file.h>
 #include <linux/highmem.h>
@@ -385,6 +386,17 @@ static int smaps_pte_range(pmd_t *pmd, u
 	pte_t *pte;
 	spinlock_t *ptl;
 
+	if (pmd_trans_huge(*pmd)) {
+		if (pmd_trans_splitting(*pmd)) {
+			spin_unlock(&walk->mm->page_table_lock);
+			wait_split_huge_page(vma->anon_vma, pmd);
+			spin_lock(&walk->mm->page_table_lock);
+			goto normal_ptes;
+		}
+		smaps_pte_entry(*(pte_t *)pmd, addr, HPAGE_SIZE, walk);
+		return 0;
+	}
+normal_ptes:
 	split_huge_page_pmd(walk->mm, pmd);
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
diff -puN mm/vmscan.c~teach-smaps_pte_range-about-thp-pmds mm/vmscan.c
diff -puN include/trace/events/vmscan.h~teach-smaps_pte_range-about-thp-pmds include/trace/events/vmscan.h
diff -puN mm/pagewalk.c~teach-smaps_pte_range-about-thp-pmds mm/pagewalk.c
diff -puN mm/huge_memory.c~teach-smaps_pte_range-about-thp-pmds mm/huge_memory.c
diff -puN mm/memory.c~teach-smaps_pte_range-about-thp-pmds mm/memory.c
diff -puN include/linux/huge_mm.h~teach-smaps_pte_range-about-thp-pmds include/linux/huge_mm.h
diff -puN mm/internal.h~teach-smaps_pte_range-about-thp-pmds mm/internal.h
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
