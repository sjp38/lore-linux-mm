Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD588D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:53:46 -0500 (EST)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1M1Yq75005292
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:34:52 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1M1rjIg208410
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:53:45 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1M1rimc021687
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 22:53:45 -0300
Subject: [PATCH 4/5] teach smaps_pte_range() about THP pmds
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 21 Feb 2011 17:53:43 -0800
References: <20110222015338.309727CA@kernel>
In-Reply-To: <20110222015338.309727CA@kernel>
Message-Id: <20110222015343.41586948@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, akpm@osdl.org, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>


v2 - used mm->page_table_lock to fix up locking bug that
	Mel pointed out.  Also remove Acks since things
	got changed significantly.

This adds code to explicitly detect  and handle
pmd_trans_huge() pmds.  It then passes HPAGE_SIZE units
in to the smap_pte_entry() function instead of PAGE_SIZE.

This means that using /proc/$pid/smaps now will no longer
cause THPs to be broken down in to small pages.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/fs/proc/task_mmu.c |   23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff -puN fs/proc/task_mmu.c~teach-smaps_pte_range-about-thp-pmds fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~teach-smaps_pte_range-about-thp-pmds	2011-02-14 09:59:44.034590716 -0800
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-02-21 15:12:46.144181298 -0800
@@ -1,5 +1,6 @@
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
+#include <linux/huge_mm.h>
 #include <linux/mount.h>
 #include <linux/seq_file.h>
 #include <linux/highmem.h>
@@ -7,6 +8,7 @@
 #include <linux/slab.h>
 #include <linux/pagemap.h>
 #include <linux/mempolicy.h>
+#include <linux/rmap.h>
 #include <linux/swap.h>
 #include <linux/swapops.h>
 
@@ -385,8 +387,25 @@ static int smaps_pte_range(pmd_t *pmd, u
 	pte_t *pte;
 	spinlock_t *ptl;
 
-	split_huge_page_pmd(walk->mm, pmd);
-
+	spin_lock(&walk->mm->page_table_lock);
+	if (pmd_trans_huge(*pmd)) {
+		if (pmd_trans_splitting(*pmd)) {
+			spin_unlock(&walk->mm->page_table_lock);
+			wait_split_huge_page(vma->anon_vma, pmd);
+		} else {
+			smaps_pte_entry(*(pte_t *)pmd, addr,
+					HPAGE_PMD_SIZE, walk);
+			spin_unlock(&walk->mm->page_table_lock);
+			return 0;
+		}
+	} else {
+		spin_unlock(&walk->mm->page_table_lock);
+	}
+	/*
+	 * The mmap_sem held all the way back in m_start() is what
+	 * keeps khugepaged out of here and from collapsing things
+	 * in here.
+	 */
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE)
 		smaps_pte_entry(*pte, addr, PAGE_SIZE, walk);
diff -puN mm/migrate.c~teach-smaps_pte_range-about-thp-pmds mm/migrate.c
diff -puN mm/mincore.c~teach-smaps_pte_range-about-thp-pmds mm/mincore.c
diff -puN include/linux/mm.h~teach-smaps_pte_range-about-thp-pmds include/linux/mm.h
diff -puN mm/mempolicy.c~teach-smaps_pte_range-about-thp-pmds mm/mempolicy.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
