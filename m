Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C179D8D0039
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:53:45 -0500 (EST)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1M1YptZ005281
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:34:51 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1M1rhAq138058
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 20:53:43 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1M1rh5O006923
	for <linux-mm@kvack.org>; Mon, 21 Feb 2011 18:53:43 -0700
Subject: [PATCH 3/5] pass pte size argument in to smaps_pte_entry()
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 21 Feb 2011 17:53:42 -0800
References: <20110222015338.309727CA@kernel>
In-Reply-To: <20110222015338.309727CA@kernel>
Message-Id: <20110222015342.5DD9FC72@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Michael J Wolf <mjwolf@us.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, akpm@osdl.org, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>


This patch adds an argument to the new smaps_pte_entry()
function to let it account in things other than PAGE_SIZE
units.  I changed all of the PAGE_SIZE sites, even though
not all of them can be reached for transparent huge pages,
just so this will continue to work without changes as THPs
are improved.

Acked-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/fs/proc/task_mmu.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff -puN fs/proc/task_mmu.c~give-smaps_pte_range-a-size-arg fs/proc/task_mmu.c
--- linux-2.6.git/fs/proc/task_mmu.c~give-smaps_pte_range-a-size-arg	2011-02-14 09:59:43.530575814 -0800
+++ linux-2.6.git-dave/fs/proc/task_mmu.c	2011-02-14 09:59:43.538576050 -0800
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
