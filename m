Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2E09003C8
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 05:28:16 -0400 (EDT)
Received: by wiga1 with SMTP id a1so93552828wig.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 02:28:15 -0700 (PDT)
Received: from mail-wi0-x242.google.com (mail-wi0-x242.google.com. [2a00:1450:400c:c05::242])
        by mx.google.com with ESMTPS id a6si1878165wix.99.2015.07.14.02.28.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 02:28:14 -0700 (PDT)
Received: by wilh8 with SMTP id h8so1089942wil.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 02:28:14 -0700 (PDT)
From: Dmitry Safonov <0x7f454c46@gmail.com>
Subject: [PATCH] mm: swap: zswap: maybe_preload & refactoring
Date: Tue, 14 Jul 2015 12:28:52 +0300
Message-Id: <1436866132-16331-1-git-send-email-0x7f454c46@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sjennings@variantweb.net
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, mhocko@suse.cz, hughd@google.com, 0x7f454c46@gmail.com, minchan@kernel.org, tj@kernel.org, axboe@fb.com, hch@lst.de, dh.herrmann@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

zswap_get_swap_cache_page and read_swap_cache_async have pretty the same
code with only significant difference in return value and usage of
swap_readpage.
I made helper function __read_swap_cache_async with the common code.
Behavior change: now zswap_get_swap_cache_page will use
radix_tree_maybe_preload instead radix_tree_preload. Looks like, this
wasn't changed only by the reason of code duplication.

Signed-off-by: Dmitry Safonov <0x7f454c46@gmail.com>
---
 include/linux/swap.h |  3 +++
 mm/swap_state.c      | 37 ++++++++++++++++++--------
 mm/zswap.c           | 73 +++++-----------------------------------------------
 3 files changed, 35 insertions(+), 78 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 3887472..cd2926e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -398,6 +398,9 @@ extern void free_pages_and_swap_cache(struct page **, int);
 extern struct page *lookup_swap_cache(swp_entry_t);
 extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
+extern struct page *__read_swap_cache_async(swp_entry_t, gfp_t,
+			struct vm_area_struct *vma, unsigned long addr,
+			bool *new_page_allocated);
 extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 8bc8e66..d504adb 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -288,17 +288,14 @@ struct page * lookup_swap_cache(swp_entry_t entry)
 	return page;
 }
 
-/* 
- * Locate a page of swap in physical memory, reserving swap cache space
- * and reading the disk if it is not already cached.
- * A failure return means that either the page allocation failed or that
- * the swap entry is no longer in use.
- */
-struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
-			struct vm_area_struct *vma, unsigned long addr)
+struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
+			struct vm_area_struct *vma, unsigned long addr,
+			bool *new_page_allocated)
 {
 	struct page *found_page, *new_page = NULL;
+	struct address_space *swapper_space = swap_address_space(entry);
 	int err;
+	*new_page_allocated = false;
 
 	do {
 		/*
@@ -306,8 +303,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 * called after lookup_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
-		found_page = find_get_page(swap_address_space(entry),
-					entry.val);
+		found_page = find_get_page(swapper_space, entry.val);
 		if (found_page)
 			break;
 
@@ -366,7 +362,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			 * Initiate read into locked page and return.
 			 */
 			lru_cache_add_anon(new_page);
-			swap_readpage(new_page);
+			*new_page_allocated = true;
 			return new_page;
 		}
 		radix_tree_preload_end();
@@ -384,6 +380,25 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 	return found_page;
 }
 
+/*
+ * Locate a page of swap in physical memory, reserving swap cache space
+ * and reading the disk if it is not already cached.
+ * A failure return means that either the page allocation failed or that
+ * the swap entry is no longer in use.
+ */
+struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
+			struct vm_area_struct *vma, unsigned long addr)
+{
+	bool page_was_allocated;
+	struct page *retpage = __read_swap_cache_async(entry, gfp_mask,
+			vma, addr, &page_was_allocated);
+
+	if (page_was_allocated)
+		swap_readpage(retpage);
+
+	return retpage;
+}
+
 static unsigned long swapin_nr_pages(unsigned long offset)
 {
 	static unsigned long prev_offset;
diff --git a/mm/zswap.c b/mm/zswap.c
index 2d5727b..09208c7 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -446,75 +446,14 @@ enum zswap_get_swap_ret {
 static int zswap_get_swap_cache_page(swp_entry_t entry,
 				struct page **retpage)
 {
-	struct page *found_page, *new_page = NULL;
-	struct address_space *swapper_space = swap_address_space(entry);
-	int err;
+	bool page_was_allocated;
 
-	*retpage = NULL;
-	do {
-		/*
-		 * First check the swap cache.  Since this is normally
-		 * called after lookup_swap_cache() failed, re-calling
-		 * that would confuse statistics.
-		 */
-		found_page = find_get_page(swapper_space, entry.val);
-		if (found_page)
-			break;
-
-		/*
-		 * Get a new page to read into from swap.
-		 */
-		if (!new_page) {
-			new_page = alloc_page(GFP_KERNEL);
-			if (!new_page)
-				break; /* Out of memory */
-		}
-
-		/*
-		 * call radix_tree_preload() while we can wait.
-		 */
-		err = radix_tree_preload(GFP_KERNEL);
-		if (err)
-			break;
-
-		/*
-		 * Swap entry may have been freed since our caller observed it.
-		 */
-		err = swapcache_prepare(entry);
-		if (err == -EEXIST) { /* seems racy */
-			radix_tree_preload_end();
-			continue;
-		}
-		if (err) { /* swp entry is obsolete ? */
-			radix_tree_preload_end();
-			break;
-		}
-
-		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
-		__set_page_locked(new_page);
-		SetPageSwapBacked(new_page);
-		err = __add_to_swap_cache(new_page, entry);
-		if (likely(!err)) {
-			radix_tree_preload_end();
-			lru_cache_add_anon(new_page);
-			*retpage = new_page;
-			return ZSWAP_SWAPCACHE_NEW;
-		}
-		radix_tree_preload_end();
-		ClearPageSwapBacked(new_page);
-		__clear_page_locked(new_page);
-		/*
-		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
-		 * clear SWAP_HAS_CACHE flag.
-		 */
-		swapcache_free(entry);
-	} while (err != -ENOMEM);
-
-	if (new_page)
-		page_cache_release(new_page);
-	if (!found_page)
+	*retpage = __read_swap_cache_async(entry, GFP_KERNEL,
+			NULL, 0, &page_was_allocated);
+	if (page_was_allocated)
+		return ZSWAP_SWAPCACHE_NEW;
+	if (!*retpage)
 		return ZSWAP_SWAPCACHE_FAIL;
-	*retpage = found_page;
 	return ZSWAP_SWAPCACHE_EXIST;
 }
 
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
