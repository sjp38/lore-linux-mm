Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8D76B0007
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 03:53:38 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j21so1736856pff.12
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 00:53:38 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s89sor197662pfk.93.2018.02.20.00.53.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Feb 2018 00:53:37 -0800 (PST)
From: minchan@kernel.org
Subject: [PATCH RESEND 2/2] mm: swap: unify cluster-based and vma-based swap readahead
Date: Tue, 20 Feb 2018 17:52:49 +0900
Message-Id: <20180220085249.151400-3-minchan@kernel.org>
In-Reply-To: <20180220085249.151400-1-minchan@kernel.org>
References: <20180220085249.151400-1-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>

From: Minchan Kim <minchan@kernel.org>

This patch makes do_swap_page() not need to be aware of two different swap
readahead algorithms.  Just unify cluster-based and vma-based readahead
function call.

Link: http://lkml.kernel.org/r/1509520520-32367-3-git-send-email-minchan@kernel.org
Signed-off-by: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Huang Ying <ying.huang@intel.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h | 27 ++++++++-----------------
 mm/memory.c          | 11 ++++------
 mm/shmem.c           |  5 ++++-
 mm/swap_state.c      | 48 ++++++++++++++++++++++++++++++++++----------
 4 files changed, 53 insertions(+), 38 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index fa92177d863e..2417d288e016 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -400,7 +400,6 @@ int generic_swapfile_activate(struct swap_info_struct *, struct file *,
 #define SWAP_ADDRESS_SPACE_SHIFT	14
 #define SWAP_ADDRESS_SPACE_PAGES	(1 << SWAP_ADDRESS_SPACE_SHIFT)
 extern struct address_space *swapper_spaces[];
-extern bool swap_vma_readahead;
 #define swap_address_space(entry)			    \
 	(&swapper_spaces[swp_type(entry)][swp_offset(entry) \
 		>> SWAP_ADDRESS_SPACE_SHIFT])
@@ -422,10 +421,10 @@ extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
 extern struct page *__read_swap_cache_async(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr,
 			bool *new_page_allocated);
-extern struct page *swapin_readahead(swp_entry_t, gfp_t,
-			struct vm_area_struct *vma, unsigned long addr);
-extern struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
-					   struct vm_fault *vmf);
+extern struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t flag,
+				struct vm_fault *vmf);
+extern struct page *swapin_readahead(swp_entry_t entry, gfp_t flag,
+				struct vm_fault *vmf);
 
 /* linux/mm/swapfile.c */
 extern atomic_long_t nr_swap_pages;
@@ -433,11 +432,6 @@ extern long total_swap_pages;
 extern atomic_t nr_rotate_swap;
 extern bool has_usable_swap(void);
 
-static inline bool swap_use_vma_readahead(void)
-{
-	return READ_ONCE(swap_vma_readahead) && !atomic_read(&nr_rotate_swap);
-}
-
 /* Swap 50% full? Release swapcache more aggressively.. */
 static inline bool vm_swap_full(void)
 {
@@ -533,19 +527,14 @@ static inline void put_swap_page(struct page *page, swp_entry_t swp)
 {
 }
 
-static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
-			struct vm_area_struct *vma, unsigned long addr)
+static inline struct page *swap_cluster_readahead(swp_entry_t entry,
+				gfp_t gfp_mask, struct vm_fault *vmf)
 {
 	return NULL;
 }
 
-static inline bool swap_use_vma_readahead(void)
-{
-	return false;
-}
-
-static inline struct page *do_swap_page_readahead(swp_entry_t fentry,
-				gfp_t gfp_mask, struct vm_fault *vmf)
+static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
+			struct vm_fault *vmf)
 {
 	return NULL;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 5b6e29d927c8..394078c97a98 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2927,7 +2927,8 @@ int do_swap_page(struct vm_fault *vmf)
 		if (si->flags & SWP_SYNCHRONOUS_IO &&
 				__swap_count(si, entry) == 1) {
 			/* skip swapcache */
-			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
+			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
+							vmf->address);
 			if (page) {
 				__SetPageLocked(page);
 				__SetPageSwapBacked(page);
@@ -2936,12 +2937,8 @@ int do_swap_page(struct vm_fault *vmf)
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
index 1907688b75ee..e493c5095b5f 100644
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
+	page = swap_cluster_readahead(swap, gfp, &vmf);
 	shmem_pseudo_vma_destroy(&pvma);
 
 	return page;
diff --git a/mm/swap_state.c b/mm/swap_state.c
index c56cce64b2c3..0b8ae361981f 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -38,7 +38,7 @@ static const struct address_space_operations swap_aops = {
 
 struct address_space *swapper_spaces[MAX_SWAPFILES] __read_mostly;
 static unsigned int nr_swapper_spaces[MAX_SWAPFILES] __read_mostly;
-bool swap_vma_readahead __read_mostly = true;
+bool enable_vma_readahead __read_mostly = true;
 
 #define SWAP_RA_WIN_SHIFT	(PAGE_SHIFT / 2)
 #define SWAP_RA_HITS_MASK	((1UL << SWAP_RA_WIN_SHIFT) - 1)
@@ -322,6 +322,11 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
 	release_pages(pagep, nr);
 }
 
+static inline bool swap_use_vma_readahead(void)
+{
+	return READ_ONCE(enable_vma_readahead) && !atomic_read(&nr_rotate_swap);
+}
+
 /*
  * Lookup a swap entry in the swap cache. A found page will be returned
  * unlocked and with its refcount incremented - we rely on the kernel
@@ -539,11 +544,10 @@ static unsigned long swapin_nr_pages(unsigned long offset)
 }
 
 /**
- * swapin_readahead - swap in pages in hope we need them soon
+ * swap_cluster_readahead - swap in pages in hope we need them soon
  * @entry: swap entry of this memory
  * @gfp_mask: memory allocation flags
- * @vma: user vma this address belongs to
- * @addr: target address for mempolicy
+ * @vmf: fault information
  *
  * Returns the struct page for entry and addr, after queueing swapin.
  *
@@ -555,10 +559,10 @@ static unsigned long swapin_nr_pages(unsigned long offset)
  * This has been extended to use the NUMA policies from the mm triggering
  * the readahead.
  *
- * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
+ * Caller must hold down_read on the vma->vm_mm if vmf->vma is not NULL.
  */
-struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
-			struct vm_area_struct *vma, unsigned long addr)
+struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
+				struct vm_fault *vmf)
 {
 	struct page *page;
 	unsigned long entry_offset = swp_offset(entry);
@@ -568,6 +572,8 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	struct swap_info_struct *si = swp_swap_info(entry);
 	struct blk_plug plug;
 	bool do_poll = true, page_allocated;
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned long addr = vmf->address;
 
 	mask = swapin_nr_pages(offset) - 1;
 	if (!mask)
@@ -723,7 +729,7 @@ static void swap_ra_info(struct vm_fault *vmf,
 	pte_unmap(orig_pte);
 }
 
-struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
+struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 				    struct vm_fault *vmf)
 {
 	struct blk_plug plug;
@@ -771,20 +777,40 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 				     ra_info.win == 1);
 }
 
+/**
+ * swapin_readahead - swap in pages in hope we need them soon
+ * @entry: swap entry of this memory
+ * @gfp_mask: memory allocation flags
+ * @vmf: fault information
+ *
+ * Returns the struct page for entry and addr, after queueing swapin.
+ *
+ * It's a main entry function for swap readahead. By the configuration,
+ * it will read ahead blocks by cluster-based(ie, physical disk based)
+ * or vma-based(ie, virtual address based on faulty address) readahead.
+ */
+struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
+				struct vm_fault *vmf)
+{
+	return swap_use_vma_readahead() ?
+			swap_vma_readahead(entry, gfp_mask, vmf) :
+			swap_cluster_readahead(entry, gfp_mask, vmf);
+}
+
 #ifdef CONFIG_SYSFS
 static ssize_t vma_ra_enabled_show(struct kobject *kobj,
 				     struct kobj_attribute *attr, char *buf)
 {
-	return sprintf(buf, "%s\n", swap_vma_readahead ? "true" : "false");
+	return sprintf(buf, "%s\n", enable_vma_readahead ? "true" : "false");
 }
 static ssize_t vma_ra_enabled_store(struct kobject *kobj,
 				      struct kobj_attribute *attr,
 				      const char *buf, size_t count)
 {
 	if (!strncmp(buf, "true", 4) || !strncmp(buf, "1", 1))
-		swap_vma_readahead = true;
+		enable_vma_readahead = true;
 	else if (!strncmp(buf, "false", 5) || !strncmp(buf, "0", 1))
-		swap_vma_readahead = false;
+		enable_vma_readahead = false;
 	else
 		return -EINVAL;
 
-- 
2.16.1.291.g4437f3f132-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
