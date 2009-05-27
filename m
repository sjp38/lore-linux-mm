Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6E66B005D
	for <linux-mm@kvack.org>; Wed, 27 May 2009 11:06:44 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [rfc][patch] swap: virtual swap readahead
Date: Wed, 27 May 2009 17:05:46 +0200
Message-Id: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

The current swap readahead implementation reads a physically
contiguous group of swap slots around the faulting page to take
advantage of the disk head's position and in the hope that the
surrounding pages will be needed soon as well.

This works as long as the physical swap slot order approximates the
LRU order decently, otherwise it wastes memory and IO bandwidth to
read in pages that are unlikely to be needed soon.

However, the physical swap slot layout diverges from the LRU order
with increasing swap activity, i.e. high memory pressure situations,
and this is exactly the situation where swapin should not waste any
memory or IO bandwidth as both are the most contended resources at
this point.

This patch makes swap-in base its readaround window on the virtual
proximity of pages in the faulting VMA, as an indicator for pages
needed in the near future, while still taking physical locality of
swap slots into account.

This has the advantage of reading in big batches when the LRU order
matches the swap slot order while automatically throttling readahead
when the system is thrashing and swap slots are no longer nicely
grouped by LRU order.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Rik van Riel <riel@redhat.com>
---
 mm/swap_state.c |   80 +++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 57 insertions(+), 23 deletions(-)

qsbench, 20 runs each, 1.7GB RAM, 2GB swap, 4 cores:

         "mean (standard deviation) median"

All values are given in seconds.  I used a t-test to make sure there
is a statistical difference of at least 95% probability in the
compared runs for the given number of samples, arithmetic mean and
standard deviation.

1 x 2048M
vanilla: 391.25 ( 71.76) 384.56
vswapra: 445.55 ( 83.19) 415.41

	This is an actual regression.  I am not yet quite sure why
	this happens and I am undecided whether one humonguous active
	vma in the system is a common workload.

	It's also the only regression I found, with qsbench anyway.  I
	started out with powers of two and tweaked the parameters
	until the results between the two kernel versions differed.

2 x 1024M
vanilla: 384.25 ( 75.00) 423.08
vswapra: 290.26 ( 31.38) 299.51

4 x 540M
vanilla: 553.91 (100.02) 554.57
vswapra: 336.58 ( 52.49) 331.52

8 x 280M
vanilla: 561.08 ( 82.36) 583.12
vswapra: 319.13 ( 43.17) 307.69

16 x 128M
vanilla: 285.51 (113.20) 236.62
vswapra: 214.24 ( 62.37) 214.15

	All these show a nice improvement in performance and runtime
	stability.

The missing shmem support is a big TODO, I will try to find time to
tackle this when the overall idea is not refused in the first place.

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3ecea98..8f8daaa 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -336,11 +336,6 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
  *
  * Returns the struct page for entry and addr, after queueing swapin.
  *
- * Primitive swap readahead code. We simply read an aligned block of
- * (1 << page_cluster) entries in the swap area. This method is chosen
- * because it doesn't cost us any seek time.  We also make sure to queue
- * the 'original' request together with the readahead ones...
- *
  * This has been extended to use the NUMA policies from the mm triggering
  * the readahead.
  *
@@ -349,27 +344,66 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr)
 {
-	int nr_pages;
-	struct page *page;
-	unsigned long offset;
-	unsigned long end_offset;
-
-	/*
-	 * Get starting offset for readaround, and number of pages to read.
-	 * Adjust starting address by readbehind (for NUMA interleave case)?
-	 * No, it's very unlikely that swap layout would follow vma layout,
-	 * more likely that neighbouring swap pages came from the same node:
-	 * so use the same "addr" to choose the same node for each swap read.
-	 */
-	nr_pages = valid_swaphandles(entry, &offset);
-	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
-		/* Ok, do the async read-ahead now */
-		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
-						gfp_mask, vma, addr);
+	int cluster = 1 << page_cluster;
+	int window = cluster << PAGE_SHIFT;
+	unsigned long start, pos, end;
+	unsigned long pmin, pmax;
+
+	/* XXX: fix this for shmem */
+	if (!vma || !vma->vm_mm)
+		goto nora;
+
+	/* Physical range to read from */
+	pmin = swp_offset(entry) & ~(cluster - 1);
+	pmax = pmin + cluster;
+
+	/* Virtual range to read from */
+	start = addr & ~(window - 1);
+	end = start + window;
+
+	for (pos = start; pos < end; pos += PAGE_SIZE) {
+		struct page *page;
+		swp_entry_t swp;
+		spinlock_t *ptl;
+		pgd_t *pgd;
+		pud_t *pud;
+		pmd_t *pmd;
+		pte_t *pte;
+
+		pgd = pgd_offset(vma->vm_mm, pos);
+		if (!pgd_present(*pgd))
+			continue;
+		pud = pud_offset(pgd, pos);
+		if (!pud_present(*pud))
+			continue;
+		pmd = pmd_offset(pud, pos);
+		if (!pmd_present(*pmd))
+			continue;
+		pte = pte_offset_map_lock(vma->vm_mm, pmd, pos, &ptl);
+		if (!is_swap_pte(*pte)) {
+			pte_unmap_unlock(pte, ptl);
+			continue;
+		}
+		swp = pte_to_swp_entry(*pte);
+		pte_unmap_unlock(pte, ptl);
+
+		if (swp_type(swp) != swp_type(entry))
+			continue;
+		/*
+		 * Dont move the disk head too far away.  This also
+		 * throttles readahead while thrashing, where virtual
+		 * order diverges more and more from physical order.
+		 */
+		if (swp_offset(swp) > pmax)
+			continue;
+		if (swp_offset(swp) < pmin)
+			continue;
+		page = read_swap_cache_async(swp, gfp_mask, vma, pos);
 		if (!page)
-			break;
+			continue;
 		page_cache_release(page);
 	}
 	lru_add_drain();	/* Push any new pages onto the LRU now */
+nora:
 	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
