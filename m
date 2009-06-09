Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 950866B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 15:03:52 -0400 (EDT)
Date: Tue, 9 Jun 2009 21:01:28 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch v3] swap: virtual swap readahead
Message-ID: <20090609190128.GA1785@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.org.uk>, Andi Kleen <andi@firstfloor.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

[resend with lists cc'd, sorry]

Hi,

here is a new iteration of the virtual swap readahead.  Per Hugh's
suggestion, I moved the pte collecting to the callsite and thus out
ouf swap code.  Unfortunately, I had to bound page_cluster due to an
array of that many swap entries on the stack, but I think it is better
to limit the cluster size to a sane maximum than using dynamic
allocation for this purpose.

Thanks all for the helpful suggestions.  KAMEZAWA-san and Minchan, I
didn't incorporate your ideas in this patch as I think they belong in
a different one with their own justifications.  I didn't ignore them.

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
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/swap.h |    4 ++-
 kernel/sysctl.c      |    7 ++++-
 mm/memory.c          |   55 +++++++++++++++++++++++++++++++++++++++++
 mm/shmem.c           |    4 +--
 mm/swap_state.c      |   67 ++++++++++++++++++++++++++++++++++++++-------------
 5 files changed, 116 insertions(+), 21 deletions(-)

version 3:
  o move pte selection to callee (per Hugh)
  o limit ra ptes to one pmd entry to avoid multiple
    locking/mapping of highptes (per Hugh)

version 2:
  o fall back to physical ra window for shmem
  o add documentation to the new ra algorithm (per Andrew)

--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -327,27 +327,14 @@ struct page *read_swap_cache_async(swp_e
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
@@ -373,3 +360,51 @@ struct page *swapin_readahead(swp_entry_
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
+ * @entries: swap slots to consider reading
+ * @nr_entries: number of @entries
+ * @cluster: readahead window size in swap slots
+ *
+ * Returns the struct page for entry and addr, after queueing swapin.
+ *
+ * This has been extended to use the NUMA policies from the mm
+ * triggering the readahead.
+ *
+ * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
+ */
+struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
+			struct vm_area_struct *vma, unsigned long addr,
+			swp_entry_t *entries, int nr_entries,
+			unsigned long cluster)
+{
+	unsigned long pmin, pmax;
+	int i;
+
+	if (!entries)	/* XXX: shmem case */
+		return swapin_readahead_phys(entry, gfp_mask, vma, addr);
+	pmin = swp_offset(entry) & ~(cluster - 1);
+	pmax = pmin + cluster;
+	for (i = 0; i < nr_entries; i++) {
+		swp_entry_t swp = entries[i];
+		struct page *page;
+
+		if (swp_type(swp) != swp_type(entry))
+			continue;
+		if (swp_offset(swp) > pmax)
+			continue;
+		if (swp_offset(swp) < pmin)
+			continue;
+		page = read_swap_cache_async(swp, gfp_mask, vma, addr);
+		if (!page)
+			break;
+		page_cache_release(page);
+	}
+	lru_add_drain();	/* Push any new pages onto the LRU now */
+	return read_swap_cache_async(entry, gfp_mask, vma, addr);
+}
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -292,7 +292,9 @@ extern struct page *lookup_swap_cache(sw
 extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
 extern struct page *swapin_readahead(swp_entry_t, gfp_t,
-			struct vm_area_struct *vma, unsigned long addr);
+			struct vm_area_struct *vma, unsigned long addr,
+			swp_entry_t *entries, int nr_entries,
+			unsigned long cluster);
 
 /* linux/mm/swapfile.c */
 extern long nr_swap_pages;
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2440,6 +2440,54 @@ int vmtruncate_range(struct inode *inode
 }
 
 /*
+ * The readahead window is the virtual area around the faulting page,
+ * where the physical proximity of the swap slots is taken into
+ * account as well in swapin_readahead().
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
+ */
+static int swap_readahead_ptes(struct mm_struct *mm,
+			unsigned long addr, pmd_t *pmd,
+			swp_entry_t *entries,
+			unsigned long cluster)
+{
+	unsigned long window, min, max, limit;
+	spinlock_t *ptl;
+	pte_t *ptep;
+	int i, nr;
+
+	window = cluster << PAGE_SHIFT;
+	min = addr & ~(window - 1);
+	max = min + cluster;
+	/*
+	 * To keep the locking/highpte mapping simple, stay
+	 * within the PTE range of one PMD entry.
+	 */
+	limit = addr & PMD_MASK;
+	if (limit > min)
+		min = limit;
+	limit = pmd_addr_end(addr, max);
+	if (limit < max)
+		max = limit;
+	limit = max - min;
+	ptep = pte_offset_map_lock(mm, pmd, min, &ptl);
+	for (i = nr = 0; i < limit; i++)
+		if (is_swap_pte(ptep[i]))
+			entries[nr++] = pte_to_swp_entry(ptep[i]);
+	pte_unmap_unlock(ptep, ptl);
+	return nr;
+}
+
+/*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
@@ -2466,9 +2514,14 @@ static int do_swap_page(struct mm_struct
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	page = lookup_swap_cache(entry);
 	if (!page) {
+		int nr, cluster = 1 << page_cluster;
+		swp_entry_t entries[cluster];
+
 		grab_swap_token(); /* Contend for token _before_ read-in */
+		nr = swap_readahead_ptes(mm, address, pmd, entries, cluster);
 		page = swapin_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vma, address);
+					GFP_HIGHUSER_MOVABLE, vma, address,
+					entries, nr, cluster);
 		if (!page) {
 			/*
 			 * Back out if somebody else faulted in this pte
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1148,7 +1148,7 @@ static struct page *shmem_swapin(swp_ent
 	pvma.vm_pgoff = idx;
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = spol;
-	page = swapin_readahead(entry, gfp, &pvma, 0);
+	page = swapin_readahead(entry, gfp, &pvma, 0, NULL, 0, 0);
 	return page;
 }
 
@@ -1178,7 +1178,7 @@ static inline void shmem_show_mpol(struc
 static inline struct page *shmem_swapin(swp_entry_t entry, gfp_t gfp,
 			struct shmem_inode_info *info, unsigned long idx)
 {
-	return swapin_readahead(entry, gfp, NULL, 0);
+	return swapin_readahead(entry, gfp, NULL, 0, NULL, 0, 0);
 }
 
 static inline struct page *shmem_alloc_page(gfp_t gfp,
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -112,6 +112,8 @@ static int min_percpu_pagelist_fract = 8
 
 static int ngroups_max = NGROUPS_MAX;
 
+static int page_cluster_max = 5;
+
 #ifdef CONFIG_MODULES
 extern char modprobe_path[];
 #endif
@@ -966,7 +968,10 @@ static struct ctl_table vm_table[] = {
 		.data		= &page_cluster,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &page_cluster_max,
 	},
 	{
 		.ctl_name	= VM_DIRTY_BACKGROUND,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
