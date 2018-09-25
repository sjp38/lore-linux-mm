Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id B10948E009E
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 11:30:21 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id h26-v6so7646041qtp.18
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 08:30:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j9-v6sor878274qvi.147.2018.09.25.08.30.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 08:30:20 -0700 (PDT)
From: Josef Bacik <josef@toxicpanda.com>
Subject: [PATCH 3/8] mm: clean up swapcache lookup and creation function names
Date: Tue, 25 Sep 2018 11:30:06 -0400
Message-Id: <20180925153011.15311-4-josef@toxicpanda.com>
In-Reply-To: <20180925153011.15311-1-josef@toxicpanda.com>
References: <20180925153011.15311-1-josef@toxicpanda.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, linux-btrfs@vger.kernel.org, riel@redhat.com, hannes@cmpxchg.org, tj@kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Johannes Weiner <jweiner@fb.com>

From: Johannes Weiner <jweiner@fb.com>

__read_swap_cache_async() has a misleading name. All it does is look
up or create a page in swapcache; it doesn't initiate any IO.

The swapcache has many parallels to the page cache, and shares naming
schemes with it elsewhere. Analogous to the cache lookup and creation
API, rename __read_swap_cache_async() find_or_create_swap_cache() and
lookup_swap_cache() to find_swap_cache().

Signed-off-by: Johannes Weiner <jweiner@fb.com>
Signed-off-by: Josef Bacik <josef@toxicpanda.com>
---
 include/linux/swap.h | 14 ++++++++------
 mm/memory.c          |  2 +-
 mm/shmem.c           |  2 +-
 mm/swap_state.c      | 43 ++++++++++++++++++++++---------------------
 mm/zswap.c           |  8 ++++----
 5 files changed, 36 insertions(+), 33 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8e2c11e692ba..293a84c34448 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -412,15 +412,17 @@ extern void __delete_from_swap_cache(struct page *);
 extern void delete_from_swap_cache(struct page *);
 extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
-extern struct page *lookup_swap_cache(swp_entry_t entry,
-				      struct vm_area_struct *vma,
-				      unsigned long addr);
+extern struct page *find_swap_cache(swp_entry_t entry,
+				    struct vm_area_struct *vma,
+				    unsigned long addr);
+extern struct page *find_or_create_swap_cache(swp_entry_t entry,
+					      gfp_t gfp_mask,
+					      struct vm_area_struct *vma,
+					      unsigned long addr,
+					      bool *created);
 extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr,
 			bool do_poll);
-extern struct page *__read_swap_cache_async(swp_entry_t, gfp_t,
-			struct vm_area_struct *vma, unsigned long addr,
-			bool *new_page_allocated);
 extern struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t flag,
 				struct vm_fault *vmf);
 extern struct page *swapin_readahead(swp_entry_t entry, gfp_t flag,
diff --git a/mm/memory.c b/mm/memory.c
index 9152c2a2c9f6..f27295c1c91d 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2935,7 +2935,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
 
 
 	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
-	page = lookup_swap_cache(entry, vma, vmf->address);
+	page = find_swap_cache(entry, vma, vmf->address);
 	swapcache = page;
 
 	if (!page) {
diff --git a/mm/shmem.c b/mm/shmem.c
index 0376c124b043..9854903ae92f 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1679,7 +1679,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 
 	if (swap.val) {
 		/* Look it up and read it in.. */
-		page = lookup_swap_cache(swap, NULL, 0);
+		page = find_swap_cache(swap, NULL, 0);
 		if (!page) {
 			/* Or update major stats only when swapin succeeds?? */
 			if (fault_type) {
diff --git a/mm/swap_state.c b/mm/swap_state.c
index ecee9c6c4cc1..bae758e19f7a 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -330,8 +330,8 @@ static inline bool swap_use_vma_readahead(void)
  * lock getting page table operations atomic even if we drop the page
  * lock before returning.
  */
-struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
-			       unsigned long addr)
+struct page *find_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
+			     unsigned long addr)
 {
 	struct page *page;
 
@@ -374,19 +374,20 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
 	return page;
 }
 
-struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
+struct page *find_or_create_swap_cache(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr,
-			bool *new_page_allocated)
+			bool *created)
 {
 	struct page *found_page, *new_page = NULL;
 	struct address_space *swapper_space = swap_address_space(entry);
 	int err;
-	*new_page_allocated = false;
+
+	*created = false;
 
 	do {
 		/*
 		 * First check the swap cache.  Since this is normally
-		 * called after lookup_swap_cache() failed, re-calling
+		 * called after find_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
 		found_page = find_get_page(swapper_space, swp_offset(entry));
@@ -449,7 +450,7 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			 * Initiate read into locked page and return.
 			 */
 			lru_cache_add_anon(new_page);
-			*new_page_allocated = true;
+			*created = true;
 			return new_page;
 		}
 		radix_tree_preload_end();
@@ -475,14 +476,14 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		struct vm_area_struct *vma, unsigned long addr, bool do_poll)
 {
-	bool page_was_allocated;
-	struct page *retpage = __read_swap_cache_async(entry, gfp_mask,
-			vma, addr, &page_was_allocated);
+	struct page *page;
+	bool created;
 
-	if (page_was_allocated)
-		swap_readpage(retpage, do_poll);
+	page = find_or_create_swap_cache(entry, gfp_mask, vma, addr, &created);
+	if (created)
+		swap_readpage(page, do_poll);
 
-	return retpage;
+	return page;
 }
 
 static unsigned int __swapin_nr_pages(unsigned long prev_offset,
@@ -573,7 +574,7 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	unsigned long mask;
 	struct swap_info_struct *si = swp_swap_info(entry);
 	struct blk_plug plug;
-	bool do_poll = true, page_allocated;
+	bool do_poll = true, created;
 	struct vm_area_struct *vma = vmf->vma;
 	unsigned long addr = vmf->address;
 
@@ -593,12 +594,12 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	blk_start_plug(&plug);
 	for (offset = start_offset; offset <= end_offset ; offset++) {
 		/* Ok, do the async read-ahead now */
-		page = __read_swap_cache_async(
+		page = find_or_create_swap_cache(
 			swp_entry(swp_type(entry), offset),
-			gfp_mask, vma, addr, &page_allocated);
+			gfp_mask, vma, addr, &created);
 		if (!page)
 			continue;
-		if (page_allocated) {
+		if (created) {
 			swap_readpage(page, false);
 			if (offset != entry_offset) {
 				SetPageReadahead(page);
@@ -738,7 +739,7 @@ static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 	pte_t *pte, pentry;
 	swp_entry_t entry;
 	unsigned int i;
-	bool page_allocated;
+	bool created;
 	struct vma_swap_readahead ra_info = {0,};
 
 	swap_ra_info(vmf, &ra_info);
@@ -756,11 +757,11 @@ static struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 		entry = pte_to_swp_entry(pentry);
 		if (unlikely(non_swap_entry(entry)))
 			continue;
-		page = __read_swap_cache_async(entry, gfp_mask, vma,
-					       vmf->address, &page_allocated);
+		page = find_or_create_swap_cache(entry, gfp_mask, vma,
+					 vmf->address, &created);
 		if (!page)
 			continue;
-		if (page_allocated) {
+		if (created) {
 			swap_readpage(page, false);
 			if (i != ra_info.offset) {
 				SetPageReadahead(page);
diff --git a/mm/zswap.c b/mm/zswap.c
index cd91fd9d96b8..6f05faa75766 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -823,11 +823,11 @@ enum zswap_get_swap_ret {
 static int zswap_get_swap_cache_page(swp_entry_t entry,
 				struct page **retpage)
 {
-	bool page_was_allocated;
+	bool created;
 
-	*retpage = __read_swap_cache_async(entry, GFP_KERNEL,
-			NULL, 0, &page_was_allocated);
-	if (page_was_allocated)
+	*retpage = find_or_create_swap_cache(entry, GFP_KERNEL,
+					     NULL, 0, &created);
+	if (created)
 		return ZSWAP_SWAPCACHE_NEW;
 	if (!*retpage)
 		return ZSWAP_SWAPCACHE_FAIL;
-- 
2.14.3
