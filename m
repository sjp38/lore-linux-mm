Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id D30B56B0253
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 01:29:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v78so1418818pgb.18
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 22:29:02 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id n10si3804708pfi.256.2017.10.31.22.29.00
        for <linux-mm@kvack.org>;
        Tue, 31 Oct 2017 22:29:01 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/2] mm:swap: unify cluster-based and vma-based swap readahead
Date: Wed,  1 Nov 2017 14:28:23 +0900
Message-Id: <1509514103-17550-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1509514103-17550-1-git-send-email-minchan@kernel.org>
References: <1509514103-17550-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

This patch makes do_swap_page no need to be aware of two different
swap readahead algorithm. Just unify cluster-based and vma-based
readahead function call.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h | 17 ++++++++++++-----
 mm/memory.c          | 11 ++++-------
 mm/shmem.c           |  5 ++++-
 mm/swap_state.c      | 21 +++++++++++++++------
 4 files changed, 35 insertions(+), 19 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7c7c8b344bc9..9cc330360eac 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -425,9 +425,11 @@ extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
 extern struct page *__read_swap_cache_async(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr,
 			bool *new_page_allocated);
-extern struct page *swapin_readahead(swp_entry_t, gfp_t,
-			struct vm_area_struct *vma, unsigned long addr);
-extern struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
+extern struct page *cluster_readahead(swp_entry_t entry, gfp_t flag,
+				struct vm_fault *vmf);
+extern struct page *swapin_readahead(swp_entry_t entry, gfp_t flag,
+				struct vm_fault *vmf);
+extern struct page *vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 					   struct vm_fault *vmf);
 
 /* linux/mm/swapfile.c */
@@ -536,8 +538,13 @@ static inline void put_swap_page(struct page *page, swp_entry_t swp)
 {
 }
 
+static inline struct page *cluster_readahead(swp_entry_t, gfp_t gfp_mask
+						struct vm_fault *vmf)
+{
+}
+
 static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
-			struct vm_area_struct *vma, unsigned long addr)
+			struct vm_fault *vmf)
 {
 	return NULL;
 }
@@ -547,7 +554,7 @@ static inline bool swap_use_vma_readahead(void)
 	return false;
 }
 
-static inline struct page *do_swap_page_readahead(swp_entry_t fentry,
+static inline struct page *vma_readahead(swp_entry_t fentry,
 				gfp_t gfp_mask, struct vm_fault *vmf)
 {
 	return NULL;
diff --git a/mm/memory.c b/mm/memory.c
index e955298e4290..ce5e3d7ccc5c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2889,7 +2889,8 @@ int do_swap_page(struct vm_fault *vmf)
 		if (si->flags & SWP_SYNCHRONOUS_IO &&
 				__swap_count(si, entry) == 1) {
 			/* skip swapcache */
-			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
+			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
+							vmf->address);
 			if (page) {
 				__SetPageLocked(page);
 				__SetPageSwapBacked(page);
@@ -2898,12 +2899,8 @@ int do_swap_page(struct vm_fault *vmf)
 				swap_readpage(page, true);
 			}
 		} else {
-			if (swap_use_vma_readahead())
-				page = do_swap_page_readahead(entry,
-					GFP_HIGHUSER_MOVABLE, vmf);
-			else
-				page = swapin_readahead(entry,
-				       GFP_HIGHUSER_MOVABLE, vma, vmf->address);
+			page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE,
+						vmf);
 			swapcache = page;
 		}
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 62dfdc097e44..2522bc0958e1 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1413,9 +1413,12 @@ static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
 {
 	struct vm_area_struct pvma;
 	struct page *page;
+	struct vm_fault vmf;
 
 	shmem_pseudo_vma_init(&pvma, info, index);
-	page = swapin_readahead(swap, gfp, &pvma, 0);
+	vmf.vma = &pvma;
+	vmf.address = 0;
+	page = cluster_readahead(swap, gfp, &vmf);
 	shmem_pseudo_vma_destroy(&pvma);
 
 	return page;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index e3c535fcd2df..5ee53d4ee047 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -538,11 +538,10 @@ static unsigned long swapin_nr_pages(unsigned long offset)
 }
 
 /**
- * swapin_readahead - swap in pages in hope we need them soon
+ * cluster_readahead - swap in pages in hope we need them soon
  * @entry: swap entry of this memory
  * @gfp_mask: memory allocation flags
- * @vma: user vma this address belongs to
- * @addr: target address for mempolicy
+ * @vmf: fault information
  *
  * Returns the struct page for entry and addr, after queueing swapin.
  *
@@ -556,8 +555,8 @@ static unsigned long swapin_nr_pages(unsigned long offset)
  *
  * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
  */
-struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
-			struct vm_area_struct *vma, unsigned long addr)
+struct page *cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
+				struct vm_fault *vmf)
 {
 	struct page *page;
 	unsigned long entry_offset = swp_offset(entry);
@@ -566,6 +565,8 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	unsigned long mask;
 	struct blk_plug plug;
 	bool do_poll = true, page_allocated;
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned long addr = vmf->address;
 
 	mask = swapin_nr_pages(offset) - 1;
 	if (!mask)
@@ -603,6 +604,14 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	return read_swap_cache_async(entry, gfp_mask, vma, addr, do_poll);
 }
 
+struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
+				struct vm_fault *vmf)
+{
+	return swap_use_vma_readahead() ?
+				vma_readahead(entry, gfp_mask, vmf) :
+				cluster_readahead(entry, gfp_mask, vmf);
+}
+
 int init_swap_address_space(unsigned int type, unsigned long nr_pages)
 {
 	struct address_space *spaces, *space;
@@ -719,7 +728,7 @@ static void swap_ra_info(struct vm_fault *vmf,
 	pte_unmap(orig_pte);
 }
 
-struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
+struct page *vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 				    struct vm_fault *vmf)
 {
 	struct blk_plug plug;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
