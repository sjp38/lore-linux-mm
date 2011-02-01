Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2008D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:34:20 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p110EjWQ031899
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:14:45 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1DDD1728045
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:34:03 -0500 (EST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p110Y2Ki142014
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:34:02 -0500
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p110Y2V3009084
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:34:02 -0700
Subject: [RFC][PATCH 3/6] break out smaps_pte_entry() from smaps_pte_range()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 31 Jan 2011 16:34:01 -0800
References: <20110201003357.D6F0BE0D@kernel>
In-Reply-To: <20110201003357.D6F0BE0D@kernel>
Message-Id: <20110201003401.95CFBFA6@kernel>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


We will use smaps_pte_entry() in a moment to handle both small
and transparent large pages.  But, we must break it out of
smaps_pte_range() first.


---

 linux-2.6.git-dave/fs/proc/task_mmu.c |   85 ++++++++++++++++++----------------
 1 file changed, 46 insertions(+), 39 deletions(-)

diff -puN fs/proc/task_mmu.c~break-out-smaps_pte_entry fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~break-out-smaps_pte_entry	2011-01-27 11:03:06.761548697 -0800
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-01-27 11:03:06.773548685 -0800
@@ -333,56 +333,63 @@ struct mem_size_stats {
 	u64 pss;
 };
 
-static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
-			   struct mm_walk *walk)
+
+static void smaps_pte_entry(pte_t ptent, unsigned long addr,
+		struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
 	struct vm_area_struct *vma = mss->vma;
-	pte_t *pte, ptent;
-	spinlock_t *ptl;
 	struct page *page;
 	int mapcount;
 
-	split_huge_page_pmd(walk->mm, pmd);
-
-	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
-	for (; addr != end; pte++, addr += PAGE_SIZE) {
-		ptent = *pte;
+	if (is_swap_pte(ptent)) {
+		mss->swap += PAGE_SIZE;
+		return;
+	}
 
-		if (is_swap_pte(ptent)) {
-			mss->swap += PAGE_SIZE;
-			continue;
-		}
+	if (!pte_present(ptent))
+		return;
 
-		if (!pte_present(ptent))
-			continue;
+	page = vm_normal_page(vma, addr, ptent);
+	if (!page)
+		return;
+
+	if (PageAnon(page))
+		mss->anonymous += PAGE_SIZE;
+
+	mss->resident += PAGE_SIZE;
+	/* Accumulate the size in pages that have been accessed. */
+	if (pte_young(ptent) || PageReferenced(page))
+		mss->referenced += PAGE_SIZE;
+	mapcount = page_mapcount(page);
+	if (mapcount >= 2) {
+		if (pte_dirty(ptent) || PageDirty(page))
+			mss->shared_dirty += PAGE_SIZE;
+		else
+			mss->shared_clean += PAGE_SIZE;
+		mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
+	} else {
+		if (pte_dirty(ptent) || PageDirty(page))
+			mss->private_dirty += PAGE_SIZE;
+		else
+			mss->private_clean += PAGE_SIZE;
+		mss->pss += (PAGE_SIZE << PSS_SHIFT);
+	}
+}
 
-		page = vm_normal_page(vma, addr, ptent);
-		if (!page)
-			continue;
+static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
+			   struct mm_walk *walk)
+{
+	struct mem_size_stats *mss = walk->private;
+	struct vm_area_struct *vma = mss->vma;
+	pte_t *pte;
+	spinlock_t *ptl;
 
-		if (PageAnon(page))
-			mss->anonymous += PAGE_SIZE;
+	split_huge_page_pmd(walk->mm, pmd);
 
-		mss->resident += PAGE_SIZE;
-		/* Accumulate the size in pages that have been accessed. */
-		if (pte_young(ptent) || PageReferenced(page))
-			mss->referenced += PAGE_SIZE;
-		mapcount = page_mapcount(page);
-		if (mapcount >= 2) {
-			if (pte_dirty(ptent) || PageDirty(page))
-				mss->shared_dirty += PAGE_SIZE;
-			else
-				mss->shared_clean += PAGE_SIZE;
-			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
-		} else {
-			if (pte_dirty(ptent) || PageDirty(page))
-				mss->private_dirty += PAGE_SIZE;
-			else
-				mss->private_clean += PAGE_SIZE;
-			mss->pss += (PAGE_SIZE << PSS_SHIFT);
-		}
-	}
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE)
+		smaps_pte_entry(*pte, addr, walk);
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
 	return 0;
diff -puN mm/huge_memory.c~break-out-smaps_pte_entry mm/huge_memory.c
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
