Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A4A66B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 15:03:47 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 6so4316379plf.6
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 12:03:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g1-v6si2244410plk.422.2018.02.23.12.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 23 Feb 2018 12:03:45 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] mm: Report bad PTEs in lookup_swap_cache()
Date: Fri, 23 Feb 2018 12:03:41 -0800
Message-Id: <20180223200341.17627-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Huang Ying <ying.huang@intel.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

If we have garbage in the PTE, we can call the radix tree code with a
NULL radix tree head which leads to an OOPS.  Detect the case where
we've found a PTE that refers to a non-existent swap device and report
the error correctly.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/swap.h | 10 ++++------
 mm/memory.c          |  4 +---
 mm/shmem.c           |  2 +-
 mm/swap_state.c      | 35 ++++++++++++++++++++++-------------
 4 files changed, 28 insertions(+), 23 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7b6a59f722a3..045edb2ca8d0 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -415,9 +415,8 @@ extern void __delete_from_swap_cache(struct page *);
 extern void delete_from_swap_cache(struct page *);
 extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
-extern struct page *lookup_swap_cache(swp_entry_t entry,
-				      struct vm_area_struct *vma,
-				      unsigned long addr);
+extern struct page *lookup_swap_cache(swp_entry_t entry, bool vma_ra,
+				      struct vm_fault *vmf);
 extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr,
 			bool do_poll);
@@ -568,9 +567,8 @@ static inline int swap_writepage(struct page *p, struct writeback_control *wbc)
 	return 0;
 }
 
-static inline struct page *lookup_swap_cache(swp_entry_t swp,
-					     struct vm_area_struct *vma,
-					     unsigned long addr)
+static inline struct page *lookup_swap_cache(swp_entry_t swp, bool vma_ra,
+						struct vm_fault *vmf)
 {
 	return NULL;
 }
diff --git a/mm/memory.c b/mm/memory.c
index 5fcfc24904d1..1cfc4699db42 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2926,11 +2926,9 @@ int do_swap_page(struct vm_fault *vmf)
 		goto out;
 	}
 
-
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
 	if (!page) {
-		page = lookup_swap_cache(entry, vma_readahead ? vma : NULL,
-					 vmf->address);
+		page = lookup_swap_cache(entry, vma_readahead, vmf);
 		swapcache = page;
 	}
 
diff --git a/mm/shmem.c b/mm/shmem.c
index 1907688b75ee..8976f05823ba 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1650,7 +1650,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 
 	if (swap.val) {
 		/* Look it up and read it in.. */
-		page = lookup_swap_cache(swap, NULL, 0);
+		page = lookup_swap_cache(swap, false, NULL);
 		if (!page) {
 			/* Or update major stats only when swapin succeeds?? */
 			if (fault_type) {
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 39ae7cfad90f..5a7755ecbb03 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -328,14 +328,22 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
  * lock getting page table operations atomic even if we drop the page
  * lock before returning.
  */
-struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
-			       unsigned long addr)
+struct page *lookup_swap_cache(swp_entry_t entry, bool vma_ra,
+			struct vm_fault *vmf)
 {
 	struct page *page;
-	unsigned long ra_info;
-	int win, hits, readahead;
+	int readahead;
+	struct address_space *swapper_space = swap_address_space(entry);
 
-	page = find_get_page(swap_address_space(entry), swp_offset(entry));
+	if (!swapper_space) {
+		if (vmf)
+			pte_ERROR(vmf->orig_pte);
+		else
+			pr_err("Bad swp_entry: %lx\n", entry.val);
+		return NULL;
+	}
+
+	page = find_get_page(swapper_space, swp_offset(entry));
 
 	INC_CACHE_INFO(find_total);
 	if (page) {
@@ -343,18 +351,19 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
 		if (unlikely(PageTransCompound(page)))
 			return page;
 		readahead = TestClearPageReadahead(page);
-		if (vma) {
-			ra_info = GET_SWAP_RA_VAL(vma);
-			win = SWAP_RA_WIN(ra_info);
-			hits = SWAP_RA_HITS(ra_info);
+		if (vma_ra) {
+			unsigned long ra_info = GET_SWAP_RA_VAL(vmf->vma);
+			int win = SWAP_RA_WIN(ra_info);
+			int hits = SWAP_RA_HITS(ra_info);
+
 			if (readahead)
 				hits = min_t(int, hits + 1, SWAP_RA_HITS_MAX);
-			atomic_long_set(&vma->swap_readahead_info,
-					SWAP_RA_VAL(addr, win, hits));
+			atomic_long_set(&vmf->vma->swap_readahead_info,
+					SWAP_RA_VAL(vmf->address, win, hits));
 		}
 		if (readahead) {
 			count_vm_event(SWAP_RA_HIT);
-			if (!vma)
+			if (!vma_ra)
 				atomic_inc(&swapin_readahead_hits);
 		}
 	}
@@ -675,7 +684,7 @@ struct page *swap_readahead_detect(struct vm_fault *vmf,
 	entry = pte_to_swp_entry(vmf->orig_pte);
 	if ((unlikely(non_swap_entry(entry))))
 		return NULL;
-	page = lookup_swap_cache(entry, vma, faddr);
+	page = lookup_swap_cache(entry, true, vmf);
 	if (page)
 		return page;
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
