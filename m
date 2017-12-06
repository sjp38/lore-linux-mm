Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0BA6B02BF
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 19:43:46 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j3so1608984pfh.16
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 16:43:46 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s18si979166pfd.67.2017.12.05.16.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 16:42:11 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 32/73] mm: Convert add_to_swap_cache to XArray
Date: Tue,  5 Dec 2017 16:41:18 -0800
Message-Id: <20171206004159.3755-33-willy@infradead.org>
In-Reply-To: <20171206004159.3755-1-willy@infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Combine __add_to_swap_cache and add_to_swap_cache into one function
since there is no more need to preload.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/swap_state.c | 93 ++++++++++++++++++---------------------------------------
 1 file changed, 29 insertions(+), 64 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3f95e8fc4cb2..117b5da9dc01 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -107,14 +107,15 @@ void show_swap_cache_info(void)
 }
 
 /*
- * __add_to_swap_cache resembles add_to_page_cache_locked on swapper_space,
+ * add_to_swap_cache resembles add_to_page_cache_locked on swapper_space,
  * but sets SwapCache flag and private instead of mapping and index.
  */
-int __add_to_swap_cache(struct page *page, swp_entry_t entry)
+int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp)
 {
-	int error, i, nr = hpage_nr_pages(page);
-	struct address_space *address_space;
+	struct address_space *address_space = swap_address_space(entry);
 	pgoff_t idx = swp_offset(entry);
+	XA_STATE(xas, &address_space->pages, idx);
+	unsigned int i, nr = compound_order(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapCache(page), page);
@@ -123,50 +124,30 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 	page_ref_add(page, nr);
 	SetPageSwapCache(page);
 
-	address_space = swap_address_space(entry);
-	xa_lock_irq(&address_space->pages);
-	for (i = 0; i < nr; i++) {
-		set_page_private(page + i, entry.val + i);
-		error = radix_tree_insert(&address_space->pages,
-					  idx + i, page + i);
-		if (unlikely(error))
-			break;
-	}
-	if (likely(!error)) {
+	do {
+		xas_lock_irq(&xas);
+		xas_create_range(&xas, idx + nr - 1);
+		if (xas_error(&xas))
+			goto unlock;
+		for (i = 0; i < nr; i++) {
+			VM_BUG_ON_PAGE(xas.xa_index != idx + i, page);
+			set_page_private(page + i, entry.val + i);
+			xas_store(&xas, page + i);
+			xas_next(&xas);
+		}
 		address_space->nrpages += nr;
 		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, nr);
 		ADD_CACHE_INFO(add_total, nr);
-	} else {
-		/*
-		 * Only the context which have set SWAP_HAS_CACHE flag
-		 * would call add_to_swap_cache().
-		 * So add_to_swap_cache() doesn't returns -EEXIST.
-		 */
-		VM_BUG_ON(error == -EEXIST);
-		set_page_private(page + i, 0UL);
-		while (i--) {
-			radix_tree_delete(&address_space->pages, idx + i);
-			set_page_private(page + i, 0UL);
-		}
-		ClearPageSwapCache(page);
-		page_ref_sub(page, nr);
-	}
-	xa_unlock_irq(&address_space->pages);
+unlock:
+		xas_unlock_irq(&xas);
+	} while (xas_nomem(&xas, gfp));
 
-	return error;
-}
-
-
-int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
-{
-	int error;
+	if (!xas_error(&xas))
+		return 0;
 
-	error = radix_tree_maybe_preload_order(gfp_mask, compound_order(page));
-	if (!error) {
-		error = __add_to_swap_cache(page, entry);
-		radix_tree_preload_end();
-	}
-	return error;
+	ClearPageSwapCache(page);
+	page_ref_sub(page, nr);
+	return xas_error(&xas);
 }
 
 /*
@@ -220,7 +201,7 @@ int add_to_swap(struct page *page)
 		goto fail;
 
 	/*
-	 * Radix-tree node allocations from PF_MEMALLOC contexts could
+	 * XArray node allocations from PF_MEMALLOC contexts could
 	 * completely exhaust the page allocator. __GFP_NOMEMALLOC
 	 * stops emergency reserves from being allocated.
 	 *
@@ -232,7 +213,6 @@ int add_to_swap(struct page *page)
 	 */
 	err = add_to_swap_cache(page, entry,
 			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
-	/* -ENOMEM radix-tree allocation failure */
 	if (err)
 		/*
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
@@ -400,19 +380,11 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 				break;		/* Out of memory */
 		}
 
-		/*
-		 * call radix_tree_preload() while we can wait.
-		 */
-		err = radix_tree_maybe_preload(gfp_mask & GFP_KERNEL);
-		if (err)
-			break;
-
 		/*
 		 * Swap entry may have been freed since our caller observed it.
 		 */
 		err = swapcache_prepare(entry);
 		if (err == -EEXIST) {
-			radix_tree_preload_end();
 			/*
 			 * We might race against get_swap_page() and stumble
 			 * across a SWAP_HAS_CACHE swap_map entry whose page
@@ -420,26 +392,19 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			 */
 			cond_resched();
 			continue;
-		}
-		if (err) {		/* swp entry is obsolete ? */
-			radix_tree_preload_end();
+		} else if (err)		/* swp entry is obsolete ? */
 			break;
-		}
 
-		/* May fail (-ENOMEM) if radix-tree node allocation failed. */
+		/* May fail (-ENOMEM) if XArray node allocation failed. */
 		__SetPageLocked(new_page);
 		__SetPageSwapBacked(new_page);
-		err = __add_to_swap_cache(new_page, entry);
+		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
 		if (likely(!err)) {
-			radix_tree_preload_end();
-			/*
-			 * Initiate read into locked page and return.
-			 */
+			/* Initiate read into locked page */
 			lru_cache_add_anon(new_page);
 			*new_page_allocated = true;
 			return new_page;
 		}
-		radix_tree_preload_end();
 		__ClearPageLocked(new_page);
 		/*
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
