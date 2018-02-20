Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5AB6B0006
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 03:53:35 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c5so4549731pfn.17
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 00:53:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g6-v6sor16893pll.120.2018.02.20.00.53.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Feb 2018 00:53:33 -0800 (PST)
From: minchan@kernel.org
Subject: [PATCH RESEND 1/2] mm: swap: clean up swap readahead
Date: Tue, 20 Feb 2018 17:52:48 +0900
Message-Id: <20180220085249.151400-2-minchan@kernel.org>
In-Reply-To: <20180220085249.151400-1-minchan@kernel.org>
References: <20180220085249.151400-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>

From: Minchan Kim <minchan@kernel.org>

When I see recent change of swap readahead, I am very unhappy about
current code structure which diverges two swap readahead algorithm in
do_swap_page.  This patch is to clean it up.

Main motivation is that fault handler doesn't need to be aware of
readahead algorithms but just should call swapin_readahead.

As first step, this patch cleans up a little bit but not perfect (I just
separate for review easier) so next patch will make the goal complete.

Link: http://lkml.kernel.org/r/1509520520-32367-2-git-send-email-minchan@kernel.org
Signed-off-by: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Huang Ying <ying.huang@intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h | 17 ++-------
 mm/memory.c          | 26 +++----------
 mm/swap_state.c      | 89 ++++++++++++++++++++++++--------------------
 3 files changed, 57 insertions(+), 75 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index a1a3f4ed94ce..fa92177d863e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -424,12 +424,8 @@ extern struct page *__read_swap_cache_async(swp_entry_t, gfp_t,
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
@@ -548,15 +544,8 @@ static inline bool swap_use_vma_readahead(void)
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
index 5ec6433d6a5c..5b6e29d927c8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2883,26 +2883,16 @@ EXPORT_SYMBOL(unmap_mapping_range);
 int do_swap_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct page *page = NULL, *swapcache = NULL;
+	struct page *page = NULL, *swapcache;
 	struct mem_cgroup *memcg;
-	struct vma_swap_readahead swap_ra;
 	swp_entry_t entry;
 	pte_t pte;
 	int locked;
 	int exclusive = 0;
 	int ret = 0;
-	bool vma_readahead = swap_use_vma_readahead();
 
-	if (vma_readahead) {
-		page = swap_readahead_detect(vmf, &swap_ra);
-		swapcache = page;
-	}
-
-	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte)) {
-		if (page)
-			put_page(page);
+	if (!pte_unmap_same(vma->vm_mm, vmf->pmd, vmf->pte, vmf->orig_pte))
 		goto out;
-	}
 
 	entry = pte_to_swp_entry(vmf->orig_pte);
 	if (unlikely(non_swap_entry(entry))) {
@@ -2928,11 +2918,8 @@ int do_swap_page(struct vm_fault *vmf)
 
 
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
-	if (!page) {
-		page = lookup_swap_cache(entry, vma_readahead ? vma : NULL,
-					 vmf->address);
-		swapcache = page;
-	}
+	page = lookup_swap_cache(entry, vma, vmf->address);
+	swapcache = page;
 
 	if (!page) {
 		struct swap_info_struct *si = swp_swap_info(entry);
@@ -2949,9 +2936,9 @@ int do_swap_page(struct vm_fault *vmf)
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
@@ -2982,7 +2969,6 @@ int do_swap_page(struct vm_fault *vmf)
 		 */
 		ret = VM_FAULT_HWPOISON;
 		delayacct_clear_flag(DELAYACCT_PF_SWAPIN);
-		swapcache = page;
 		goto out_release;
 	}
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 39ae7cfad90f..c56cce64b2c3 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -332,32 +332,38 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
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
 
@@ -649,16 +655,15 @@ static inline void swap_ra_clamp_pfn(struct vm_area_struct *vma,
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
@@ -667,30 +672,32 @@ struct page *swap_readahead_detect(struct vm_fault *vmf,
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
@@ -703,23 +710,21 @@ struct page *swap_readahead_detect(struct vm_fault *vmf,
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
@@ -728,12 +733,14 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
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
@@ -749,7 +756,7 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 			continue;
 		if (page_allocated) {
 			swap_readpage(page, false);
-			if (i != swap_ra->offset &&
+			if (i != ra_info.offset &&
 			    likely(!PageTransCompound(page))) {
 				SetPageReadahead(page);
 				count_vm_event(SWAP_RA);
@@ -761,7 +768,7 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 	lru_add_drain();
 skip:
 	return read_swap_cache_async(fentry, gfp_mask, vma, vmf->address,
-				     swap_ra->win == 1);
+				     ra_info.win == 1);
 }
 
 #ifdef CONFIG_SYSFS
-- 
2.16.1.291.g4437f3f132-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
