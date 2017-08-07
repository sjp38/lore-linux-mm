Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 673ED6B02F3
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 01:42:09 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s14so88550732pgs.4
        for <linux-mm@kvack.org>; Sun, 06 Aug 2017 22:42:09 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a5si4812314pll.285.2017.08.06.22.42.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 06 Aug 2017 22:42:07 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -v4 3/5] mm, swap: VMA based swap readahead
Date: Mon,  7 Aug 2017 13:40:36 +0800
Message-Id: <20170807054038.1843-4-ying.huang@intel.com>
In-Reply-To: <20170807054038.1843-1-ying.huang@intel.com>
References: <20170807054038.1843-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

From: Huang Ying <ying.huang@intel.com>

The swap readahead is an important mechanism to reduce the swap in
latency.  Although pure sequential memory access pattern isn't very
popular for anonymous memory, the space locality is still considered
valid.

In the original swap readahead implementation, the consecutive blocks
in swap device are readahead based on the global space locality
estimation.  But the consecutive blocks in swap device just reflect
the order of page reclaiming, don't necessarily reflect the access
pattern in virtual memory.  And the different tasks in the system may
have different access patterns, which makes the global space locality
estimation incorrect.

In this patch, when page fault occurs, the virtual pages near the
fault address will be readahead instead of the swap slots near the
fault swap slot in swap device.  This avoid to readahead the unrelated
swap slots.  At the same time, the swap readahead is changed to work
on per-VMA from globally.  So that the different access patterns of
the different VMAs could be distinguished, and the different readahead
policy could be applied accordingly.  The original core readahead
detection and scaling algorithm is reused, because it is an effect
algorithm to detect the space locality.

The test and result is as follow,

Common test condition
=====================

Test Machine: Xeon E5 v3 (2 sockets, 72 threads, 32G RAM)
Swap device: NVMe disk

Micro-benchmark with combined access pattern
============================================

vm-scalability, sequential swap test case, 4 processes to eat 50G
virtual memory space, repeat the sequential memory writing until 300
seconds.  The first round writing will trigger swap out, the following
rounds will trigger sequential swap in and out.

At the same time, run vm-scalability random swap test case in
background, 8 processes to eat 30G virtual memory space, repeat the
random memory write until 300 seconds.  This will trigger random
swap-in in the background.

This is a combined workload with sequential and random memory
accessing at the same time.  The result (for sequential workload) is
as follow,

			Base		Optimized
			----		---------
throughput		345413 KB/s	414029 KB/s (+19.9%)
latency.average		97.14 us	61.06 us (-37.1%)
latency.50th		2 us		1 us
latency.60th		2 us		1 us
latency.70th		98 us		2 us
latency.80th		160 us		2 us
latency.90th		260 us		217 us
latency.95th		346 us		369 us
latency.99th		1.34 ms		1.09 ms
ra_hit%			52.69%		99.98%

The original swap readahead algorithm is confused by the background
random access workload, so readahead hit rate is lower.  The VMA-base
readahead algorithm works much better.

Linpack
=======

The test memory size is bigger than RAM to trigger swapping.

			Base		Optimized
			----		---------
elapsed_time		393.49 s	329.88 s (-16.2%)
ra_hit%			86.21%		98.82%

The score of base and optimized kernel hasn't visible changes.  But
the elapsed time reduced and readahead hit rate improved, so the
optimized kernel runs better for startup and tear down stages.  And
the absolute value of readahead hit rate is high, shows that the space
locality is still valid in some practical workloads.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 include/linux/mm_types.h |   1 +
 include/linux/swap.h     |  57 ++++++++++++-
 mm/memory.c              |  23 +++--
 mm/shmem.c               |   2 +-
 mm/swap_state.c          | 215 +++++++++++++++++++++++++++++++++++++++++++----
 5 files changed, 273 insertions(+), 25 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7f384bb62d8e..5c02027050a2 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -335,6 +335,7 @@ struct vm_area_struct {
 	struct file * vm_file;		/* File we map to (can be NULL). */
 	void * vm_private_data;		/* was vm_pte (shared mem) */
 
+	atomic_long_t swap_readahead_info;
 #ifndef CONFIG_MMU
 	struct vm_region *vm_region;	/* NOMMU mapping region */
 #endif
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 76f1632eea5a..61d63379e956 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -251,6 +251,25 @@ struct swap_info_struct {
 	struct swap_cluster_list discard_clusters; /* discard clusters list */
 };
 
+#ifdef CONFIG_64BIT
+#define SWAP_RA_ORDER_CEILING	5
+#else
+/* Avoid stack overflow, because we need to save part of page table */
+#define SWAP_RA_ORDER_CEILING	3
+#define SWAP_RA_PTE_CACHE_SIZE	(1 << SWAP_RA_ORDER_CEILING)
+#endif
+
+struct vma_swap_readahead {
+	unsigned short win;
+	unsigned short offset;
+	unsigned short nr_pte;
+#ifdef CONFIG_64BIT
+	pte_t *ptes;
+#else
+	pte_t ptes[SWAP_RA_PTE_CACHE_SIZE];
+#endif
+};
+
 /* linux/mm/workingset.c */
 void *workingset_eviction(struct address_space *mapping, struct page *page);
 bool workingset_refault(void *shadow);
@@ -350,6 +369,7 @@ int generic_swapfile_activate(struct swap_info_struct *, struct file *,
 #define SWAP_ADDRESS_SPACE_SHIFT	14
 #define SWAP_ADDRESS_SPACE_PAGES	(1 << SWAP_ADDRESS_SPACE_SHIFT)
 extern struct address_space *swapper_spaces[];
+extern bool swap_vma_readahead;
 #define swap_address_space(entry)			    \
 	(&swapper_spaces[swp_type(entry)][swp_offset(entry) \
 		>> SWAP_ADDRESS_SPACE_SHIFT])
@@ -362,7 +382,9 @@ extern void __delete_from_swap_cache(struct page *);
 extern void delete_from_swap_cache(struct page *);
 extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
-extern struct page *lookup_swap_cache(swp_entry_t);
+extern struct page *lookup_swap_cache(swp_entry_t entry,
+				      struct vm_area_struct *vma,
+				      unsigned long addr);
 extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr,
 			bool do_poll);
@@ -372,6 +394,17 @@ extern struct page *__read_swap_cache_async(swp_entry_t, gfp_t,
 extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
 
+extern struct page *swap_readahead_detect(struct vm_fault *vmf,
+					  struct vma_swap_readahead *swap_ra);
+extern struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
+					   struct vm_fault *vmf,
+					   struct vma_swap_readahead *swap_ra);
+
+static inline bool swap_use_vma_readahead(void)
+{
+	return READ_ONCE(swap_vma_readahead);
+}
+
 /* linux/mm/swapfile.c */
 extern atomic_long_t nr_swap_pages;
 extern long total_swap_pages;
@@ -466,12 +499,32 @@ static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
 	return NULL;
 }
 
+static inline bool swap_use_vma_readahead(void)
+{
+	return false;
+}
+
+static inline struct page *swap_readahead_detect(
+	struct vm_fault *vmf, struct vma_swap_readahead *swap_ra)
+{
+	return NULL;
+}
+
+static inline struct page *do_swap_page_readahead(
+	swp_entry_t fentry, gfp_t gfp_mask,
+	struct vm_fault *vmf, struct vma_swap_readahead *swap_ra)
+{
+	return NULL;
+}
+
 static inline int swap_writepage(struct page *p, struct writeback_control *wbc)
 {
 	return 0;
 }
 
-static inline struct page *lookup_swap_cache(swp_entry_t swp)
+static inline struct page *lookup_swap_cache(swp_entry_t swp,
+					     struct vm_area_struct *vma,
+					     unsigned long addr)
 {
 	return NULL;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 5cd37032ca67..e44fba697fd7 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2733,16 +2733,23 @@ noinline int swap_lock_page_or_retry(struct page *page, struct mm_struct *mm,
 int do_swap_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct page *page, *swapcache;
+	struct page *page = NULL, *swapcache;
 	struct mem_cgroup *memcg;
+	struct vma_swap_readahead swap_ra;
 	swp_entry_t entry;
 	pte_t pte;
 	int locked;
 	int exclusive = 0;
 	int ret = 0;
+	bool vma_readahead = swap_use_vma_readahead();
 
-	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
+	if (vma_readahead)
+		page = swap_readahead_detect(vmf, &swap_ra);
+	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte)) {
+		if (page)
+			put_page(page);
 		goto out;
+	}
 
 	entry = pte_to_swp_entry(vmf->orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
@@ -2758,10 +2765,16 @@ int do_swap_page(struct vm_fault *vmf)
 		goto out;
 	}
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
-	page = lookup_swap_cache(entry);
+	if (!page)
+		page = lookup_swap_cache(entry, vma_readahead ? vma : NULL,
+					 vmf->address);
 	if (!page) {
-		page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE, vma,
-					vmf->address);
+		if (vma_readahead)
+			page = do_swap_page_readahead(entry,
+				GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
+		else
+			page = swapin_readahead(entry,
+				GFP_HIGHUSER_MOVABLE, vma, vmf->address);
 		if (!page) {
 			/*
 			 * Back out if somebody else faulted in this pte
diff --git a/mm/shmem.c b/mm/shmem.c
index 3c381ef18c30..3d366c6e5608 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1645,7 +1645,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 
 	if (swap.val) {
 		/* Look it up and read it in.. */
-		page = lookup_swap_cache(swap);
+		page = lookup_swap_cache(swap, NULL, 0);
 		if (!page) {
 			/* Or update major stats only when swapin succeeds?? */
 			if (fault_type) {
diff --git a/mm/swap_state.c b/mm/swap_state.c
index a901afe9da61..3885fef7bdf5 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -37,6 +37,29 @@ static const struct address_space_operations swap_aops = {
 
 struct address_space *swapper_spaces[MAX_SWAPFILES];
 static unsigned int nr_swapper_spaces[MAX_SWAPFILES];
+bool swap_vma_readahead = true;
+
+#define SWAP_RA_MAX_ORDER_DEFAULT	3
+
+static int swap_ra_max_order = SWAP_RA_MAX_ORDER_DEFAULT;
+
+#define SWAP_RA_WIN_SHIFT	(PAGE_SHIFT / 2)
+#define SWAP_RA_HITS_MASK	((1UL << SWAP_RA_WIN_SHIFT) - 1)
+#define SWAP_RA_HITS_MAX	SWAP_RA_HITS_MASK
+#define SWAP_RA_WIN_MASK	(~PAGE_MASK & ~SWAP_RA_HITS_MASK)
+
+#define SWAP_RA_HITS(v)		((v) & SWAP_RA_HITS_MASK)
+#define SWAP_RA_WIN(v)		(((v) & SWAP_RA_WIN_MASK) >> SWAP_RA_WIN_SHIFT)
+#define SWAP_RA_ADDR(v)		((v) & PAGE_MASK)
+
+#define SWAP_RA_VAL(addr, win, hits)				\
+	(((addr) & PAGE_MASK) |					\
+	 (((win) << SWAP_RA_WIN_SHIFT) & SWAP_RA_WIN_MASK) |	\
+	 ((hits) & SWAP_RA_HITS_MASK))
+
+/* Initial readahead hits is 4 to start up with a small window */
+#define GET_SWAP_RA_VAL(vma)					\
+	(atomic_long_read(&(vma)->swap_readahead_info) ? : 4)
 
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
 #define ADD_CACHE_INFO(x, nr)	do { swap_cache_info.x += (nr); } while (0)
@@ -297,21 +320,36 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
  * lock getting page table operations atomic even if we drop the page
  * lock before returning.
  */
-struct page * lookup_swap_cache(swp_entry_t entry)
+struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
+			       unsigned long addr)
 {
 	struct page *page;
+	unsigned long ra_info;
+	int win, hits, readahead;
 
 	page = find_get_page(swap_address_space(entry), swp_offset(entry));
 
-	if (page && likely(!PageTransCompound(page))) {
+	INC_CACHE_INFO(find_total);
+	if (page) {
 		INC_CACHE_INFO(find_success);
-		if (TestClearPageReadahead(page)) {
-			atomic_inc(&swapin_readahead_hits);
+		if (unlikely(PageTransCompound(page)))
+			return page;
+		readahead = TestClearPageReadahead(page);
+		if (vma) {
+			ra_info = GET_SWAP_RA_VAL(vma);
+			win = SWAP_RA_WIN(ra_info);
+			hits = SWAP_RA_HITS(ra_info);
+			if (readahead)
+				hits = min_t(int, hits + 1, SWAP_RA_HITS_MAX);
+			atomic_long_set(&vma->swap_readahead_info,
+					SWAP_RA_VAL(addr, win, hits));
+		}
+		if (readahead) {
 			count_vm_event(SWAP_RA_HIT);
+			if (!vma)
+				atomic_inc(&swapin_readahead_hits);
 		}
 	}
-
-	INC_CACHE_INFO(find_total);
 	return page;
 }
 
@@ -426,22 +464,20 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 	return retpage;
 }
 
-static unsigned long swapin_nr_pages(unsigned long offset)
+static unsigned int __swapin_nr_pages(unsigned long prev_offset,
+				      unsigned long offset,
+				      int hits,
+				      int max_pages,
+				      int prev_win)
 {
-	static unsigned long prev_offset;
-	unsigned int pages, max_pages, last_ra;
-	static atomic_t last_readahead_pages;
-
-	max_pages = 1 << READ_ONCE(page_cluster);
-	if (max_pages <= 1)
-		return 1;
+	unsigned int pages, last_ra;
 
 	/*
 	 * This heuristic has been found to work well on both sequential and
 	 * random loads, swapping to hard disk or to SSD: please don't ask
 	 * what the "+ 2" means, it just happens to work well, that's all.
 	 */
-	pages = atomic_xchg(&swapin_readahead_hits, 0) + 2;
+	pages = hits + 2;
 	if (pages == 2) {
 		/*
 		 * We can have no readahead hits to judge by: but must not get
@@ -450,7 +486,6 @@ static unsigned long swapin_nr_pages(unsigned long offset)
 		 */
 		if (offset != prev_offset + 1 && offset != prev_offset - 1)
 			pages = 1;
-		prev_offset = offset;
 	} else {
 		unsigned int roundup = 4;
 		while (roundup < pages)
@@ -462,9 +497,28 @@ static unsigned long swapin_nr_pages(unsigned long offset)
 		pages = max_pages;
 
 	/* Don't shrink readahead too fast */
-	last_ra = atomic_read(&last_readahead_pages) / 2;
+	last_ra = prev_win / 2;
 	if (pages < last_ra)
 		pages = last_ra;
+
+	return pages;
+}
+
+static unsigned long swapin_nr_pages(unsigned long offset)
+{
+	static unsigned long prev_offset;
+	unsigned int hits, pages, max_pages;
+	static atomic_t last_readahead_pages;
+
+	max_pages = 1 << READ_ONCE(page_cluster);
+	if (max_pages <= 1)
+		return 1;
+
+	hits = atomic_xchg(&swapin_readahead_hits, 0);
+	pages = __swapin_nr_pages(prev_offset, offset, hits, max_pages,
+				  atomic_read(&last_readahead_pages));
+	if (!hits)
+		prev_offset = offset;
 	atomic_set(&last_readahead_pages, pages);
 
 	return pages;
@@ -570,3 +624,130 @@ void exit_swap_address_space(unsigned int type)
 	synchronize_rcu();
 	kvfree(spaces);
 }
+
+static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
+				     unsigned long faddr,
+				     unsigned long lpfn,
+				     unsigned long rpfn,
+				     unsigned long *start,
+				     unsigned long *end)
+{
+	*start = max3(lpfn, PFN_DOWN(vma->vm_start),
+		      PFN_DOWN(faddr & PMD_MASK));
+	*end = min3(rpfn, PFN_DOWN(vma->vm_end),
+		    PFN_DOWN((faddr & PMD_MASK) + PMD_SIZE));
+}
+
+struct page *swap_readahead_detect(struct vm_fault *vmf,
+				   struct vma_swap_readahead *swap_ra)
+{
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned long swap_ra_info;
+	struct page *page;
+	swp_entry_t entry;
+	unsigned long faddr, pfn, fpfn;
+	unsigned long start, end;
+	pte_t *pte;
+	unsigned int max_win, hits, prev_win, win, left;
+#ifndef CONFIG_64BIT
+	pte_t *tpte;
+#endif
+
+	faddr = vmf->address;
+	entry = pte_to_swp_entry(vmf->orig_pte);
+	if ((unlikely(non_swap_entry(entry))))
+		return NULL;
+	page = lookup_swap_cache(entry, vma, faddr);
+	if (page)
+		return page;
+
+	max_win = 1 << READ_ONCE(swap_ra_max_order);
+	if (max_win == 1) {
+		swap_ra->win = 1;
+		return NULL;
+	}
+
+	fpfn = PFN_DOWN(faddr);
+	swap_ra_info = GET_SWAP_RA_VAL(vma);
+	pfn = PFN_DOWN(SWAP_RA_ADDR(swap_ra_info));
+	prev_win = SWAP_RA_WIN(swap_ra_info);
+	hits = SWAP_RA_HITS(swap_ra_info);
+	swap_ra->win = win = __swapin_nr_pages(pfn, fpfn, hits,
+					       max_win, prev_win);
+	atomic_long_set(&vma->swap_readahead_info,
+			SWAP_RA_VAL(faddr, win, 0));
+
+	if (win == 1)
+		return NULL;
+
+	/* Copy the PTEs because the page table may be unmapped */
+	if (fpfn == pfn + 1)
+		swap_ra_clamp_pfn(vma, faddr, fpfn, fpfn + win, &start, &end);
+	else if (pfn == fpfn + 1)
+		swap_ra_clamp_pfn(vma, faddr, fpfn - win + 1, fpfn + 1,
+				  &start, &end);
+	else {
+		left = (win - 1) / 2;
+		swap_ra_clamp_pfn(vma, faddr, fpfn - left, fpfn + win - left,
+				  &start, &end);
+	}
+	swap_ra->nr_pte = end - start;
+	swap_ra->offset = fpfn - start;
+	pte = vmf->pte - swap_ra->offset;
+#ifdef CONFIG_64BIT
+	swap_ra->ptes = pte;
+#else
+	tpte = swap_ra->ptes;
+	for (pfn = start; pfn != end; pfn++)
+		*tpte++ = *pte++;
+#endif
+
+	return NULL;
+}
+
+struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
+				    struct vm_fault *vmf,
+				    struct vma_swap_readahead *swap_ra)
+{
+	struct blk_plug plug;
+	struct vm_area_struct *vma = vmf->vma;
+	struct page *page;
+	pte_t *pte, pentry;
+	swp_entry_t entry;
+	unsigned int i;
+	bool page_allocated;
+
+	if (swap_ra->win == 1)
+		goto skip;
+
+	blk_start_plug(&plug);
+	for (i = 0, pte = swap_ra->ptes; i < swap_ra->nr_pte;
+	     i++, pte++) {
+		pentry = *pte;
+		if (pte_none(pentry))
+			continue;
+		if (pte_present(pentry))
+			continue;
+		entry = pte_to_swp_entry(pentry);
+		if (unlikely(non_swap_entry(entry)))
+			continue;
+		page = __read_swap_cache_async(entry, gfp_mask, vma,
+					       vmf->address, &page_allocated);
+		if (!page)
+			continue;
+		if (page_allocated) {
+			swap_readpage(page, false);
+			if (i != swap_ra->offset &&
+			    likely(!PageTransCompound(page))) {
+				SetPageReadahead(page);
+				count_vm_event(SWAP_RA);
+			}
+		}
+		put_page(page);
+	}
+	blk_finish_plug(&plug);
+	lru_add_drain();
+skip:
+	return read_swap_cache_async(fentry, gfp_mask, vma, vmf->address,
+				     swap_ra->win == 1);
+}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
