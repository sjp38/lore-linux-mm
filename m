Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 647D16B0253
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 03:15:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p2so1498115pfk.13
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 00:15:25 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id r21si3837884pgo.705.2017.11.01.00.15.22
        for <linux-mm@kvack.org>;
        Wed, 01 Nov 2017 00:15:23 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 2/2] mm:swap: unify cluster-based and vma-based swap readahead
Date: Wed,  1 Nov 2017 16:15:20 +0900
Message-Id: <1509520520-32367-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1509520520-32367-1-git-send-email-minchan@kernel.org>
References: <1509520520-32367-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Huang Ying <ying.huang@intel.com>, kernel-team <kernel-team@lge.com>, Minchan Kim <minchan@kernel.org>

This patch makes do_swap_page no need to be aware of two different
swap readahead algorithm. Just unify cluster-based and vma-based
readahead function call.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h | 27 ++++++++-------------------
 mm/memory.c          | 11 ++++-------
 mm/shmem.c           |  5 ++++-
 mm/swap_state.c      | 48 +++++++++++++++++++++++++++++++++++++-----------
 4 files changed, 53 insertions(+), 38 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7c7c8b344bc9..95fca979b1c1 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -403,7 +403,6 @@ int generic_swapfile_activate(struct swap_info_struct *, struct file *,
 #define SWAP_ADDRESS_SPACE_SHIFT	14
 #define SWAP_ADDRESS_SPACE_PAGES	(1 << SWAP_ADDRESS_SPACE_SHIFT)
 extern struct address_space *swapper_spaces[];
-extern bool swap_vma_readahead;
 #define swap_address_space(entry)			    \
 	(&swapper_spaces[swp_type(entry)][swp_offset(entry) \
 		>> SWAP_ADDRESS_SPACE_SHIFT])
@@ -425,10 +424,10 @@ extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
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
@@ -436,11 +435,6 @@ extern long total_swap_pages;
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
@@ -536,19 +530,14 @@ static inline void put_swap_page(struct page *page, swp_entry_t swp)
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
index 62dfdc097e44..d92923834d68 100644
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
index e3c535fcd2df..94e01413eb43 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -37,7 +37,7 @@ static const struct address_space_operations swap_aops = {
 
 struct address_space *swapper_spaces[MAX_SWAPFILES] __read_mostly;
 static unsigned int nr_swapper_spaces[MAX_SWAPFILES] __read_mostly;
-bool swap_vma_readahead __read_mostly = true;
+bool enable_vma_readahead __read_mostly = true;
 
 #define SWAP_RA_WIN_SHIFT	(PAGE_SHIFT / 2)
 #define SWAP_RA_HITS_MASK	((1UL << SWAP_RA_WIN_SHIFT) - 1)
@@ -321,6 +321,11 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
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
@@ -538,11 +543,10 @@ static unsigned long swapin_nr_pages(unsigned long offset)
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
@@ -554,10 +558,10 @@ static unsigned long swapin_nr_pages(unsigned long offset)
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
@@ -566,6 +570,8 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	unsigned long mask;
 	struct blk_plug plug;
 	bool do_poll = true, page_allocated;
+	struct vm_area_struct *vma = vmf->vma;
+	unsigned long addr = vmf->address;
 
 	mask = swapin_nr_pages(offset) - 1;
 	if (!mask)
@@ -719,7 +725,7 @@ static void swap_ra_info(struct vm_fault *vmf,
 	pte_unmap(orig_pte);
 }
 
-struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
+struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 				    struct vm_fault *vmf)
 {
 	struct blk_plug plug;
@@ -767,20 +773,40 @@ struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
