Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B77448D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:35:23 -0500 (EST)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p110T4R1018082
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:29:04 -0700
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p110Y3xs071746
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:34:03 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p110Y33t006333
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:34:03 -0700
Subject: [RFC][PATCH 4/6] pass pte size argument in to smaps_pte_entry()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 31 Jan 2011 16:34:02 -0800
References: <20110201003357.D6F0BE0D@kernel>
In-Reply-To: <20110201003357.D6F0BE0D@kernel>
Message-Id: <20110201003402.5FFC58F0@kernel>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>


This patch adds an argument to the new smaps_pte_entry()
function to let it account in things other than PAGE_SIZE
units.  I changed all of the PAGE_SIZE sites, even though
not all of them can be reached for transparent huge pages,
just so this will continue to work without changes as THPs
are improved.


---

 linux-2.6.git-dave/fs/proc/task_mmu.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff -puN fs/proc/task_mmu.c~give-smaps_pte_range-a-size-arg fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~give-smaps_pte_range-a-size-arg	2011-01-31 11:14:20.400194563 -0800
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-01-31 11:15:02.680162163 -0800
@@ -335,7 +335,7 @@ struct mem_size_stats {
 
 
 static void smaps_pte_entry(pte_t ptent, unsigned long addr,
-		struct mm_walk *walk)
+		unsigned long ptent_size, struct mm_walk *walk)
 {
 	struct mem_size_stats *mss = walk->private;
 	struct vm_area_struct *vma = mss->vma;
@@ -343,7 +343,7 @@ static void smaps_pte_entry(pte_t ptent,
 	int mapcount;
 
 	if (is_swap_pte(ptent)) {
-		mss->swap += PAGE_SIZE;
+		mss->swap += ptent_size;
 		return;
 	}
 
@@ -355,25 +355,25 @@ static void smaps_pte_entry(pte_t ptent,
 		return;
 
 	if (PageAnon(page))
-		mss->anonymous += PAGE_SIZE;
+		mss->anonymous += ptent_size;
 
-	mss->resident += PAGE_SIZE;
+	mss->resident += ptent_size;
 	/* Accumulate the size in pages that have been accessed. */
 	if (pte_young(ptent) || PageReferenced(page))
-		mss->referenced += PAGE_SIZE;
+		mss->referenced += ptent_size;
 	mapcount = page_mapcount(page);
 	if (mapcount >= 2) {
 		if (pte_dirty(ptent) || PageDirty(page))
-			mss->shared_dirty += PAGE_SIZE;
+			mss->shared_dirty += ptent_size;
 		else
-			mss->shared_clean += PAGE_SIZE;
-		mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
+			mss->shared_clean += ptent_size;
+		mss->pss += (ptent_size << PSS_SHIFT) / mapcount;
 	} else {
 		if (pte_dirty(ptent) || PageDirty(page))
-			mss->private_dirty += PAGE_SIZE;
+			mss->private_dirty += ptent_size;
 		else
-			mss->private_clean += PAGE_SIZE;
-		mss->pss += (PAGE_SIZE << PSS_SHIFT);
+			mss->private_clean += ptent_size;
+		mss->pss += (ptent_size << PSS_SHIFT);
 	}
 }
 
@@ -389,7 +389,7 @@ static int smaps_pte_range(pmd_t *pmd, u
 
 	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
 	for (; addr != end; pte++, addr += PAGE_SIZE)
-		smaps_pte_entry(*pte, addr, walk);
+		smaps_pte_entry(*pte, addr, PAGE_SIZE, walk);
 	pte_unmap_unlock(pte - 1, ptl);
 	cond_resched();
 	return 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
