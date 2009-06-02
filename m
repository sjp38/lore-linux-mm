Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 856F16B005D
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 10:39:44 -0400 (EDT)
Date: Wed, 3 Jun 2009 00:37:39 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch][v2] swap: virtual swap readahead
Message-ID: <20090602223738.GA15475@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

I redid the qsbench runs with a bigger page cluster (2^4).  It shows
improvement on both versions, the patched one still performing better.
Rik hinted me that we can make the default even bigger when we are
better at avoiding reading unrelated pages.  I am currently testing
this.  Here are the timings for 2^4 (i.e. twice the) ra pages:

vanilla:
1 x 2048M [20 runs]  user 101.41/101.06 [1.42] system 11.02/10.83 [0.92] real 368.44/361.31 [48.47]
2 x 1024M [20 runs]  user 101.42/101.23 [0.66] system 12.98/13.01 [0.56] real 338.45/338.56 [2.94]
4 x 540M [20 runs]  user 101.75/101.62 [1.03] system 10.05/9.52 [1.53] real 371.97/351.88 [77.69]
8 x 280M [20 runs]  user 103.35/103.33 [0.63] system 9.80/9.59 [1.72] real 453.48/473.21 [115.61]
16 x 128M [20 runs]  user 91.04/91.00 [0.86] system 8.95/9.41 [2.06] real 312.16/342.29 [100.53]

vswapra:
1 x 2048M [20 runs]  user 98.47/98.32 [1.33] system 9.85/9.90 [0.92] real 373.95/382.64 [26.77]
2 x 1024M [20 runs]  user 96.89/97.00 [0.44] system 9.52/9.48 [1.49] real 288.43/281.55 [53.12]
4 x 540M [20 runs]  user 98.74/98.70 [0.92] system 7.62/7.83 [1.25] real 291.15/296.94 [54.85]
8 x 280M [20 runs]  user 100.68/100.59 [0.53] system 7.59/7.62 [0.41] real 305.12/311.29 [26.09]
16 x 128M [20 runs]  user 88.67/88.50 [1.02] system 6.06/6.22 [0.72] real 205.29/221.65 [42.06]

Furthermore I changed the patch to leave shmem alone for now and added
documentation for the new approach.  And I adjusted the changelog a
bit.

Andi, I think the NUMA policy is already taken care of.  Can you have
another look at it?  Other than that you gave positive feedback - can
I add your acked-by?

	Hannes

---
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

Another approximation for LRU-relation is the VMA order as groups of
VMA-related pages are usually used together.

This patch combines both the physical and the virtual hint to get a
good approximation of pages that are sensible to read ahead.

When both diverge, we either read unrelated data, seek heavily for
related data, or, what this patch does, just decrease the readahead
efforts.

To achieve this, we have essentially two readahead windows of the same
size: one spans the virtual, the other one the physical neighborhood
of the faulting page.  We only read where both areas overlap.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Rik van Riel <riel@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andi Kleen <andi@firstfloor.org>
---
 mm/swap_state.c |  115 ++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 99 insertions(+), 16 deletions(-)

version 2:
  o fall back to physical ra window for shmem
  o add documentation to the new ra algorithm

qsbench, 20 runs, 1.7GB RAM, 2GB swap, "mean (standard deviation) median":

		vanilla				vswapra

1  x 2048M	391.25 ( 71.76) 384.56		445.55 (83.19) 415.41
2  x 1024M	384.25 ( 75.00) 423.08		290.26 (31.38) 299.51
4  x  540M	553.91 (100.02) 554.57		336.58 (52.49) 331.52
8  x  280M	561.08 ( 82.36) 583.12		319.13 (43.17) 307.69
16 x  128M	285.51 (113.20) 236.62		214.24 (62.37) 214.15

--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -325,27 +325,14 @@ struct page *read_swap_cache_async(swp_e
 	return found_page;
 }
 
-/**
- * swapin_readahead - swap in pages in hope we need them soon
- * @entry: swap entry of this memory
- * @gfp_mask: memory allocation flags
- * @vma: user vma this address belongs to
- * @addr: target address for mempolicy
- *
- * Returns the struct page for entry and addr, after queueing swapin.
- *
+/*
  * Primitive swap readahead code. We simply read an aligned block of
  * (1 << page_cluster) entries in the swap area. This method is chosen
  * because it doesn't cost us any seek time.  We also make sure to queue
  * the 'original' request together with the readahead ones...
- *
- * This has been extended to use the NUMA policies from the mm triggering
- * the readahead.
- *
- * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
  */
-struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
-			struct vm_area_struct *vma, unsigned long addr)
+static struct page *swapin_readahead_phys(swp_entry_t entry, gfp_t gfp_mask,
+				struct vm_area_struct *vma, unsigned long addr)
 {
 	int nr_pages;
 	struct page *page;
@@ -371,3 +358,99 @@ struct page *swapin_readahead(swp_entry_
 	lru_add_drain();	/* Push any new pages onto the LRU now */
 	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }
+
+/**
+ * swapin_readahead - swap in pages in hope we need them soon
+ * @entry: swap entry of this memory
+ * @gfp_mask: memory allocation flags
+ * @vma: user vma this address belongs to
+ * @addr: target address for mempolicy
+ *
+ * Returns the struct page for entry and addr, after queueing swapin.
+ *
+ * The readahead window is the virtual area around the faulting page,
+ * where the physical proximity of the swap slots is taken into
+ * account as well.
+ *
+ * While the swap allocation algorithm tries to keep LRU-related pages
+ * together on the swap backing, it is not reliable on heavy thrashing
+ * systems where concurrent reclaimers allocate swap slots and/or most
+ * anonymous memory pages are already in swap cache.
+ *
+ * On the virtual side, subgroups of VMA-related pages are usually
+ * used together, which gives another hint to LRU relationship.
+ *
+ * By taking both aspects into account, we get a good approximation of
+ * which pages are sensible to read together with the faulting one.
+ *
+ * This has been extended to use the NUMA policies from the mm
+ * triggering the readahead.
+ *
+ * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
+ */
+struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
+			struct vm_area_struct *vma, unsigned long addr)
+{
+	unsigned long start, pos, end;
+	unsigned long pmin, pmax;
+	int cluster, window;
+
+	if (!vma || !vma->vm_mm)	/* XXX: shmem case */
+		return swapin_readahead_phys(entry, gfp_mask, vma, addr);
+
+	cluster = 1 << page_cluster;
+	window = cluster << PAGE_SHIFT;
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
+		if (!page)
+			continue;
+		page_cache_release(page);
+	}
+	lru_add_drain();	/* Push any new pages onto the LRU now */
+	return read_swap_cache_async(entry, gfp_mask, vma, addr);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
