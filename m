Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CA9686B0082
	for <linux-mm@kvack.org>; Sun, 21 Jun 2009 14:06:57 -0400 (EDT)
Date: Sun, 21 Jun 2009 19:07:03 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [patch v3] swap: virtual swap readahead
In-Reply-To: <20090618130121.GA1817@cmpxchg.org>
Message-ID: <Pine.LNX.4.64.0906211858560.3968@sister.anvils>
References: <1244626976.13761.11593.camel@twins> <20090610095950.GA514@localhost>
 <1244628314.13761.11617.camel@twins> <20090610113214.GA5657@localhost>
 <20090610102516.08f7300f@jbarnes-x200> <20090611052228.GA20100@localhost>
 <20090611101741.GA1974@cmpxchg.org> <20090612015927.GA6804@localhost>
 <20090615182216.GA1661@cmpxchg.org> <20090618091949.GA711@localhost>
 <20090618130121.GA1817@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "Barnes, Jesse" <jesse.barnes@intel.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Hannes,

On Thu, 18 Jun 2009, Johannes Weiner wrote:
> On Thu, Jun 18, 2009 at 05:19:49PM +0800, Wu Fengguang wrote:
> 
> Okay, evaluating this test-patch any further probably isn't worth it.
> It's too aggressive, I think readahead is stealing pages reclaimed by
> other allocations which in turn oom.
> 
> Back to the original problem: you detected increased latency for
> launching new applications, so they get less share of the IO bandwidth
> than without the patch.
> 
> I can see two reasons for this:
> 
>   a) the new heuristics don't work out and we read more unrelated
>   pages than before
> 
>   b) we readahead more pages in total as the old code would stop at
>   holes, as described above
> 
> We can verify a) by comparing major fault numbers between the two
> kernels with your testload.  If they increase with my patch, we
> anticipate the wrong slots and every fault has do the reading itself.
> 
> b) seems to be a trade-off.  After all, the IO resources you have less
> for new applications in your test is the bandwidth that is used by
> swapping applications.  My qsbench numbers are a sign for this as the
> only IO going on is swap.
> 
> Of course, the theory is not to improve swap performance by increasing
> the readahead window but to choose better readahead candidates.  So I
> will run your tests and qsbench with a smaller page cluster and see if
> this improves both loads.

Hmm, sounds rather pessimistic; but I've not decided about it either.

May I please hand over to you this collection of adjustments to your
v3 virtual swap readahead patch, for you to merge in or split up or
mess around with, generally take ownership of, however you wish?
So you can keep adjusting shmem.c to match memory.c if necessary.

I still think your method looks a very good idea, though results have
not yet convinced me that it necessarily works out better in practice;
and I probably won't be looking at it again for a while.

The base for this patch was 2.6.30 + your v3.

* shmem_getpage() call shmem_swap_cluster() to collect vector of swap
  entries for shmem_swapin(), while we still have them kmap'ped.

* Variable-sized arrays on stack are not popular: I forget whether the
  kernel build still supports any gccs which can't manage them, but they
  do obscure stack usage, and shmem_getpage is already a suspect for that
  (because of the pseudo-vma usage which I hope to remove): should be fine
  while you're experimenting, but in the end let's define PAGE_CLUSTER_MAX.

* Fix "> pmax" in swapin_readahead() to ">= pmax": of course this is
  only a heuristic, so it wasn't accusably wrong; but we are trying for
  a particular range, so it's right to reject < pmin and >= pmax there.

* Kamezawa-san's two one-liners to swap_readahead_ptes(), of course.

* Delete valid_swaphandles() once it's unused (though I can imagine a
  useful test patch in which we could switch between old and new methods).

* swapin_readahead() was always poorly named: while you're changing its
  behaviour, let's take the opportunity to rename it swapin_readaround();
  yes, that triviality would be better as a separate patch.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 include/linux/mm.h   |    6 ++++
 include/linux/swap.h |    5 +--
 kernel/sysctl.c      |    2 -
 mm/memory.c          |   16 ++++++------
 mm/shmem.c           |   47 +++++++++++++++++++++++++++++++++----
 mm/swap_state.c      |   46 +++---------------------------------
 mm/swapfile.c        |   52 -----------------------------------------
 71 files changed, 64 insertions(+), 110 deletions(-)

--- 2.6.30-hv3/include/linux/mm.h	2009-06-10 04:05:27.000000000 +0100
+++ 2.6.30-hv4/include/linux/mm.h	2009-06-21 14:59:27.000000000 +0100
@@ -26,6 +26,12 @@ extern unsigned long max_mapnr;
 
 extern unsigned long num_physpages;
 extern void * high_memory;
+
+/*
+ * page_cluster limits swapin_readaround: tuned by /proc/sys/vm/page-cluster
+ * 1 << page_cluster is the maximum number of pages which may be read
+ */
+#define PAGE_CLUSTER_MAX	5
 extern int page_cluster;
 
 #ifdef CONFIG_SYSCTL
--- 2.6.30-hv3/include/linux/swap.h	2009-06-11 19:10:34.000000000 +0100
+++ 2.6.30-hv4/include/linux/swap.h	2009-06-21 14:59:27.000000000 +0100
@@ -291,7 +291,7 @@ extern void free_pages_and_swap_cache(st
 extern struct page *lookup_swap_cache(swp_entry_t);
 extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
-extern struct page *swapin_readahead(swp_entry_t, gfp_t,
+extern struct page *swapin_readaround(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr,
 			swp_entry_t *entries, int nr_entries,
 			unsigned long cluster);
@@ -303,7 +303,6 @@ extern void si_swapinfo(struct sysinfo *
 extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int swap_duplicate(swp_entry_t);
-extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern void swap_free(swp_entry_t);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
@@ -378,7 +377,7 @@ static inline void swap_free(swp_entry_t
 {
 }
 
-static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
+static inline struct page *swapin_readaround(swp_entry_t swp, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr)
 {
 	return NULL;
--- 2.6.30-hv3/kernel/sysctl.c	2009-06-11 19:10:34.000000000 +0100
+++ 2.6.30-hv4/kernel/sysctl.c	2009-06-21 14:59:27.000000000 +0100
@@ -112,7 +112,7 @@ static int min_percpu_pagelist_fract = 8
 
 static int ngroups_max = NGROUPS_MAX;
 
-static int page_cluster_max = 5;
+static int page_cluster_max = PAGE_CLUSTER_MAX;
 
 #ifdef CONFIG_MODULES
 extern char modprobe_path[];
--- 2.6.30-hv3/mm/memory.c	2009-06-21 14:55:44.000000000 +0100
+++ 2.6.30-hv4/mm/memory.c	2009-06-21 14:59:27.000000000 +0100
@@ -2440,9 +2440,9 @@ int vmtruncate_range(struct inode *inode
 }
 
 /*
- * The readahead window is the virtual area around the faulting page,
+ * The readaround window is the virtual area around the faulting page,
  * where the physical proximity of the swap slots is taken into
- * account as well in swapin_readahead().
+ * account as well in swapin_readaround().
  *
  * While the swap allocation algorithm tries to keep LRU-related pages
  * together on the swap backing, it is not reliable on heavy thrashing
@@ -2455,7 +2455,7 @@ int vmtruncate_range(struct inode *inode
  * By taking both aspects into account, we get a good approximation of
  * which pages are sensible to read together with the faulting one.
  */
-static int swap_readahead_ptes(struct mm_struct *mm,
+static int swap_readaround_ptes(struct mm_struct *mm,
 			unsigned long addr, pmd_t *pmd,
 			swp_entry_t *entries,
 			unsigned long cluster)
@@ -2467,7 +2467,7 @@ static int swap_readahead_ptes(struct mm
 
 	window = cluster << PAGE_SHIFT;
 	min = addr & ~(window - 1);
-	max = min + cluster;
+	max = min + window;
 	/*
 	 * To keep the locking/highpte mapping simple, stay
 	 * within the PTE range of one PMD entry.
@@ -2478,7 +2478,7 @@ static int swap_readahead_ptes(struct mm
 	limit = pmd_addr_end(addr, max);
 	if (limit < max)
 		max = limit;
-	limit = max - min;
+	limit = (max - min) >> PAGE_SHIFT;
 	ptep = pte_offset_map_lock(mm, pmd, min, &ptl);
 	for (i = nr = 0; i < limit; i++)
 		if (is_swap_pte(ptep[i]))
@@ -2515,11 +2515,11 @@ static int do_swap_page(struct mm_struct
 	page = lookup_swap_cache(entry);
 	if (!page) {
 		int nr, cluster = 1 << page_cluster;
-		swp_entry_t entries[cluster];
+		swp_entry_t entries[1 << PAGE_CLUSTER_MAX];
 
 		grab_swap_token(); /* Contend for token _before_ read-in */
-		nr = swap_readahead_ptes(mm, address, pmd, entries, cluster);
-		page = swapin_readahead(entry,
+		nr = swap_readaround_ptes(mm, address, pmd, entries, cluster);
+		page = swapin_readaround(entry,
 					GFP_HIGHUSER_MOVABLE, vma, address,
 					entries, nr, cluster);
 		if (!page) {
--- 2.6.30-hv3/mm/shmem.c	2009-06-11 19:10:34.000000000 +0100
+++ 2.6.30-hv4/mm/shmem.c	2009-06-21 14:59:27.000000000 +0100
@@ -1134,7 +1134,8 @@ static struct mempolicy *shmem_get_sbmpo
 #endif /* CONFIG_TMPFS */
 
 static struct page *shmem_swapin(swp_entry_t entry, gfp_t gfp,
-			struct shmem_inode_info *info, unsigned long idx)
+		struct shmem_inode_info *info, unsigned long idx,
+		swp_entry_t *entries, int nr_entries, unsigned long cluster)
 {
 	struct mempolicy mpol, *spol;
 	struct vm_area_struct pvma;
@@ -1148,7 +1149,8 @@ static struct page *shmem_swapin(swp_ent
 	pvma.vm_pgoff = idx;
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = spol;
-	page = swapin_readahead(entry, gfp, &pvma, 0, NULL, 0, 0);
+	page = swapin_readaround(entry, gfp, &pvma, 0,
+				entries, nr_entries, cluster);
 	return page;
 }
 
@@ -1176,9 +1178,11 @@ static inline void shmem_show_mpol(struc
 #endif /* CONFIG_TMPFS */
 
 static inline struct page *shmem_swapin(swp_entry_t entry, gfp_t gfp,
-			struct shmem_inode_info *info, unsigned long idx)
+		struct shmem_inode_info *info, unsigned long idx,
+		swp_entry_t *entries, int nr_entries, unsigned long cluster)
 {
-	return swapin_readahead(entry, gfp, NULL, 0, NULL, 0, 0);
+	return swapin_readaround(entry, gfp, NULL, 0,
+				entries, nr_entries, cluster);
 }
 
 static inline struct page *shmem_alloc_page(gfp_t gfp,
@@ -1195,6 +1199,33 @@ static inline struct mempolicy *shmem_ge
 }
 #endif
 
+static int shmem_swap_cluster(swp_entry_t *entry, unsigned long idx,
+				swp_entry_t *entries, unsigned long cluster)
+{
+	unsigned long min, max, limit;
+	int i, nr;
+
+	limit = SHMEM_NR_DIRECT;
+	if (idx >= SHMEM_NR_DIRECT) {
+		idx -= SHMEM_NR_DIRECT;
+		idx %= ENTRIES_PER_PAGE;
+		limit = ENTRIES_PER_PAGE;
+	}
+
+	min = idx & ~(cluster - 1);
+	max = min + cluster;
+	if (max > limit)
+		max = limit;
+	entry -= (idx - min);
+	limit = max - min;
+
+	for (i = nr = 0; i < limit; i++) {
+		if (entry[i].val)
+			entries[nr++] = entry[i];
+	}
+	return nr;
+}
+
 /*
  * shmem_getpage - either get the page from swap or allocate a new one
  *
@@ -1261,6 +1292,11 @@ repeat:
 		/* Look it up and read it in.. */
 		swappage = lookup_swap_cache(swap);
 		if (!swappage) {
+			int nr_entries, cluster = 1 << page_cluster;
+			swp_entry_t entries[1 << PAGE_CLUSTER_MAX];
+
+			nr_entries = shmem_swap_cluster(entry, idx,
+							entries, cluster);
 			shmem_swp_unmap(entry);
 			/* here we actually do the io */
 			if (type && !(*type & VM_FAULT_MAJOR)) {
@@ -1268,7 +1304,8 @@ repeat:
 				*type |= VM_FAULT_MAJOR;
 			}
 			spin_unlock(&info->lock);
-			swappage = shmem_swapin(swap, gfp, info, idx);
+			swappage = shmem_swapin(swap, gfp, info, idx,
+						entries, nr_entries, cluster);
 			if (!swappage) {
 				spin_lock(&info->lock);
 				entry = shmem_swp_alloc(info, idx, sgp);
--- 2.6.30-hv3/mm/swap_state.c	2009-06-11 19:10:34.000000000 +0100
+++ 2.6.30-hv4/mm/swap_state.c	2009-06-21 14:59:27.000000000 +0100
@@ -325,58 +325,24 @@ struct page *read_swap_cache_async(swp_e
 	return found_page;
 }
 
-/*
- * Primitive swap readahead code. We simply read an aligned block of
- * (1 << page_cluster) entries in the swap area. This method is chosen
- * because it doesn't cost us any seek time.  We also make sure to queue
- * the 'original' request together with the readahead ones...
- */
-static struct page *swapin_readahead_phys(swp_entry_t entry, gfp_t gfp_mask,
-				struct vm_area_struct *vma, unsigned long addr)
-{
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
-		if (!page)
-			break;
-		page_cache_release(page);
-	}
-	lru_add_drain();	/* Push any new pages onto the LRU now */
-	return read_swap_cache_async(entry, gfp_mask, vma, addr);
-}
-
 /**
- * swapin_readahead - swap in pages in hope we need them soon
+ * swapin_readaround - swap in pages in hope we need them soon
  * @entry: swap entry of this memory
  * @gfp_mask: memory allocation flags
  * @vma: user vma this address belongs to
  * @addr: target address for mempolicy
  * @entries: swap slots to consider reading
  * @nr_entries: number of @entries
- * @cluster: readahead window size in swap slots
+ * @cluster: readaround window size in swap slots
  *
  * Returns the struct page for entry and addr, after queueing swapin.
  *
  * This has been extended to use the NUMA policies from the mm
- * triggering the readahead.
+ * triggering the readaround.
  *
  * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
  */
-struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
+struct page *swapin_readaround(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr,
 			swp_entry_t *entries, int nr_entries,
 			unsigned long cluster)
@@ -384,8 +350,6 @@ struct page *swapin_readahead(swp_entry_
 	unsigned long pmin, pmax;
 	int i;
 
-	if (!entries)	/* XXX: shmem case */
-		return swapin_readahead_phys(entry, gfp_mask, vma, addr);
 	pmin = swp_offset(entry) & ~(cluster - 1);
 	pmax = pmin + cluster;
 	for (i = 0; i < nr_entries; i++) {
@@ -394,7 +358,7 @@ struct page *swapin_readahead(swp_entry_
 
 		if (swp_type(swp) != swp_type(entry))
 			continue;
-		if (swp_offset(swp) > pmax)
+		if (swp_offset(swp) >= pmax)
 			continue;
 		if (swp_offset(swp) < pmin)
 			continue;
--- 2.6.30-hv3/mm/swapfile.c	2009-03-23 23:12:14.000000000 +0000
+++ 2.6.30-hv4/mm/swapfile.c	2009-06-21 14:59:27.000000000 +0100
@@ -1984,55 +1984,3 @@ get_swap_info_struct(unsigned type)
 {
 	return &swap_info[type];
 }
-
-/*
- * swap_lock prevents swap_map being freed. Don't grab an extra
- * reference on the swaphandle, it doesn't matter if it becomes unused.
- */
-int valid_swaphandles(swp_entry_t entry, unsigned long *offset)
-{
-	struct swap_info_struct *si;
-	int our_page_cluster = page_cluster;
-	pgoff_t target, toff;
-	pgoff_t base, end;
-	int nr_pages = 0;
-
-	if (!our_page_cluster)	/* no readahead */
-		return 0;
-
-	si = &swap_info[swp_type(entry)];
-	target = swp_offset(entry);
-	base = (target >> our_page_cluster) << our_page_cluster;
-	end = base + (1 << our_page_cluster);
-	if (!base)		/* first page is swap header */
-		base++;
-
-	spin_lock(&swap_lock);
-	if (end > si->max)	/* don't go beyond end of map */
-		end = si->max;
-
-	/* Count contiguous allocated slots above our target */
-	for (toff = target; ++toff < end; nr_pages++) {
-		/* Don't read in free or bad pages */
-		if (!si->swap_map[toff])
-			break;
-		if (si->swap_map[toff] == SWAP_MAP_BAD)
-			break;
-	}
-	/* Count contiguous allocated slots below our target */
-	for (toff = target; --toff >= base; nr_pages++) {
-		/* Don't read in free or bad pages */
-		if (!si->swap_map[toff])
-			break;
-		if (si->swap_map[toff] == SWAP_MAP_BAD)
-			break;
-	}
-	spin_unlock(&swap_lock);
-
-	/*
-	 * Indicate starting offset, and return number of pages to get:
-	 * if only 1, say 0, since there's then no readahead to be done.
-	 */
-	*offset = ++toff;
-	return nr_pages? ++nr_pages: 0;
-}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
