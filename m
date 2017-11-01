Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6ACC76B025E
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 03:15:25 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r25so1668331pgn.23
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 00:15:25 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t13si4210478pfg.95.2017.11.01.00.15.22
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 00:15:23 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 1/2] mm:swap: clean up swap readahead
Date: Wed,  1 Nov 2017 16:15:19 +0900
Message-Id: <1509520520-32367-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1509520520-32367-1-git-send-email-minchan@kernel.org>
References: <1509520520-32367-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

When I see recent change of swap readahead, I am very unhappy
about current code structure which diverges two swap readahead
algorithm in do_swap_page. This patch is to clean it up.

Main motivation is that fault handler doesn't need to be aware of
readahead algorithms but just should call swapin_readahead.

As first step, this patch cleans up a little bit but not perfect
(I just separate for review easier) so next patch will make the goal
complete.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h | 17 ++--------
 mm/memory.c          | 17 +++-------
 mm/swap_state.c      | 89 ++++++++++++++++++++++++++++------------------------
 3 files changed, 55 insertions(+), 68 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 84255b3da7c1..7c7c8b344bc9 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -427,12 +427,8 @@ extern struct page *__read_swap_cache_async(swp_entry_t, gfp_t,
 			bool *new_page_allocated);
 extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
-
-extern struct page *swap_readahead_detect(struct vm_fault *vmf,
-					  struct vma_swap_readahead *swap_ra);
 extern struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
-					   struct vm_fault *vmf,
-					   struct vma_swap_readahead *swap_ra);
+					   struct vm_fault *vmf);
 
 /* linux/mm/swapfile.c */
 extern atomic_long_t nr_swap_pages;
@@ -551,15 +547,8 @@ static inline bool swap_use_vma_readahead(void)
 	return false;
 }
 
-static inline struct page *swap_readahead_detect(
-	struct vm_fault *vmf, struct vma_swap_readahead *swap_ra)
-{
-	return NULL;
-}
-
-static inline struct page *do_swap_page_readahead(
-	swp_entry_t fentry, gfp_t gfp_mask,
-	struct vm_fault *vmf, struct vma_swap_readahead *swap_ra)
+static inline struct page *do_swap_page_readahead(swp_entry_t fentry,
+				gfp_t gfp_mask, struct vm_fault *vmf)
 {
 	return NULL;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 8a0c410037d2..e955298e4290 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2849,21 +2849,14 @@ int do_swap_page(struct vm_fault *vmf)
 	struct vm_area_struct *vma = vmf->vma;
 	struct page *page = NULL, *swapcache = NULL;
 	struct mem_cgroup *memcg;
-	struct vma_swap_readahead swap_ra;
 	swp_entry_t entry;
 	pte_t pte;
 	int locked;
 	int exclusive = 0;
 	int ret = 0;
-	bool vma_readahead = swap_use_vma_readahead();
 
-	if (vma_readahead)
-		page = swap_readahead_detect(vmf, &swap_ra);
-	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte)) {
-		if (page)
-			put_page(page);
+	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
 		goto out;
-	}
 
 	entry = pte_to_swp_entry(vmf->orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
@@ -2889,9 +2882,7 @@ int do_swap_page(struct vm_fault *vmf)
 
 
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
-	if (!page)
-		page = lookup_swap_cache(entry, vma_readahead ? vma : NULL,
-					 vmf->address);
+	page = lookup_swap_cache(entry, vma, vmf->address);
 	if (!page) {
 		struct swap_info_struct *si = swp_swap_info(entry);
 
@@ -2907,9 +2898,9 @@ int do_swap_page(struct vm_fault *vmf)
 				swap_readpage(page, true);
 			}
 		} else {
-			if (vma_readahead)
+			if (swap_use_vma_readahead())
 				page = do_swap_page_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vmf, &swap_ra);
+					GFP_HIGHUSER_MOVABLE, vmf);
 			else
 				page = swapin_readahead(entry,
 				       GFP_HIGHUSER_MOVABLE, vma, vmf->address);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 6c017ced11e6..e3c535fcd2df 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -331,32 +331,38 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
 			       unsigned long addr)
 {
 	struct page *page;
-	unsigned long ra_info;
-	int win, hits, readahead;
 
 	page = find_get_page(swap_address_space(entry), swp_offset(entry));
 
 	INC_CACHE_INFO(find_total);
 	if (page) {
+		bool vma_ra = swap_use_vma_readahead();
+		bool readahead = TestClearPageReadahead(page);
+
 		INC_CACHE_INFO(find_success);
 		if (unlikely(PageTransCompound(page)))
 			return page;
-		readahead = TestClearPageReadahead(page);
-		if (vma) {
-			ra_info = GET_SWAP_RA_VAL(vma);
-			win = SWAP_RA_WIN(ra_info);
-			hits = SWAP_RA_HITS(ra_info);
+
+		if (vma && vma_ra) {
+			unsigned long ra_val;
+			int win, hits;
+
+			ra_val = GET_SWAP_RA_VAL(vma);
+			win = SWAP_RA_WIN(ra_val);
+			hits = SWAP_RA_HITS(ra_val);
 			if (readahead)
 				hits = min_t(int, hits + 1, SWAP_RA_HITS_MAX);
 			atomic_long_set(&vma->swap_readahead_info,
 					SWAP_RA_VAL(addr, win, hits));
 		}
+
 		if (readahead) {
 			count_vm_event(SWAP_RA_HIT);
-			if (!vma)
+			if (!vma || !vma_ra)
 				atomic_inc(&swapin_readahead_hits);
 		}
 	}
+
 	return page;
 }
 
@@ -645,16 +651,15 @@ static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
 		    PFN_DOWN((faddr & PMD_MASK) + PMD_SIZE));
 }
 
-struct page *swap_readahead_detect(struct vm_fault *vmf,
-				   struct vma_swap_readahead *swap_ra)
+static void swap_ra_info(struct vm_fault *vmf,
+			struct vma_swap_readahead *ra_info)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	unsigned long swap_ra_info;
-	struct page *page;
+	unsigned long ra_val;
 	swp_entry_t entry;
 	unsigned long faddr, pfn, fpfn;
 	unsigned long start, end;
-	pte_t *pte;
+	pte_t *pte, *orig_pte;
 	unsigned int max_win, hits, prev_win, win, left;
 #ifndef CONFIG_64BIT
 	pte_t *tpte;
@@ -663,30 +668,32 @@ struct page *swap_readahead_detect(struct vm_fault *vmf,
 	max_win = 1 << min_t(unsigned int, READ_ONCE(page_cluster),
 			     SWAP_RA_ORDER_CEILING);
 	if (max_win == 1) {
-		swap_ra->win = 1;
-		return NULL;
+		ra_info->win = 1;
+		return;
 	}
 
 	faddr = vmf->address;
-	entry = pte_to_swp_entry(vmf->orig_pte);
-	if ((unlikely(non_swap_entry(entry))))
-		return NULL;
-	page = lookup_swap_cache(entry, vma, faddr);
-	if (page)
-		return page;
+	orig_pte = pte = pte_offset_map(vmf->pmd, faddr);
+	entry = pte_to_swp_entry(*pte);
+	if ((unlikely(non_swap_entry(entry)))) {
+		pte_unmap(orig_pte);
+		return;
+	}
 
 	fpfn = PFN_DOWN(faddr);
-	swap_ra_info = GET_SWAP_RA_VAL(vma);
-	pfn = PFN_DOWN(SWAP_RA_ADDR(swap_ra_info));
-	prev_win = SWAP_RA_WIN(swap_ra_info);
-	hits = SWAP_RA_HITS(swap_ra_info);
-	swap_ra->win = win = __swapin_nr_pages(pfn, fpfn, hits,
+	ra_val = GET_SWAP_RA_VAL(vma);
+	pfn = PFN_DOWN(SWAP_RA_ADDR(ra_val));
+	prev_win = SWAP_RA_WIN(ra_val);
+	hits = SWAP_RA_HITS(ra_val);
+	ra_info->win = win = __swapin_nr_pages(pfn, fpfn, hits,
 					       max_win, prev_win);
 	atomic_long_set(&vma->swap_readahead_info,
 			SWAP_RA_VAL(faddr, win, 0));
 
-	if (win == 1)
-		return NULL;
+	if (win == 1) {
+		pte_unmap(orig_pte);
+		return;
+	}
 
 	/* Copy the PTEs because the page table may be unmapped */
 	if (fpfn == pfn + 1)
@@ -699,23 +706,21 @@ struct page *swap_readahead_detect(struct vm_fault *vmf,
 		swap_ra_clamp_pfn(vma, faddr, fpfn - left, fpfn + win - left,
 				  &start, &end);
 	}
-	swap_ra->nr_pte = end - start;
-	swap_ra->offset = fpfn - start;
-	pte = vmf->pte - swap_ra->offset;
+	ra_info->nr_pte = end - start;
+	ra_info->offset = fpfn - start;
+	pte -= ra_info->offset;
 #ifdef CONFIG_64BIT
-	swap_ra->ptes = pte;
+	ra_info->ptes = pte;
 #else
-	tpte = swap_ra->ptes;
+	tpte = ra_info->ptes;
 	for (pfn = start; pfn != end; pfn++)
 		*tpte++ = *pte++;
 #endif
-
-	return NULL;
+	pte_unmap(orig_pte);
 }
 
 struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
-				    struct vm_fault *vmf,
-				    struct vma_swap_readahead *swap_ra)
+				    struct vm_fault *vmf)
 {
 	struct blk_plug plug;
 	struct vm_area_struct *vma = vmf->vma;
@@ -724,12 +729,14 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 	swp_entry_t entry;
 	unsigned int i;
 	bool page_allocated;
+	struct vma_swap_readahead ra_info = {0,};
 
-	if (swap_ra->win == 1)
+	swap_ra_info(vmf, &ra_info);
+	if (ra_info.win == 1)
 		goto skip;
 
 	blk_start_plug(&plug);
-	for (i = 0, pte = swap_ra->ptes; i < swap_ra->nr_pte;
+	for (i = 0, pte = ra_info.ptes; i < ra_info.nr_pte;
 	     i++, pte++) {
 		pentry = *pte;
 		if (pte_none(pentry))
@@ -745,7 +752,7 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 			continue;
 		if (page_allocated) {
 			swap_readpage(page, false);
-			if (i != swap_ra->offset &&
+			if (i != ra_info.offset &&
 			    likely(!PageTransCompound(page))) {
 				SetPageReadahead(page);
 				count_vm_event(SWAP_RA);
@@ -757,7 +764,7 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 	lru_add_drain();
 skip:
 	return read_swap_cache_async(fentry, gfp_mask, vma, vmf->address,
-				     swap_ra->win == 1);
+				     ra_info.win == 1);
 }
 
 #ifdef CONFIG_SYSFS
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
