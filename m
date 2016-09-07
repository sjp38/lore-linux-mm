Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF64A6B0069
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 20:05:52 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g202so75641934pfb.3
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 17:05:52 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id y6si41974292pfy.74.2016.09.07.09.47.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Sep 2016 09:47:09 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v3 07/10] mm, THP, swap: Support to add/delete THP to/from swap cache
Date: Wed,  7 Sep 2016 09:46:06 -0700
Message-Id: <1473266769-2155-8-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
References: <1473266769-2155-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

With this patch, a THP (Transparent Huge Page) can be added/deleted
to/from the swap cache as a set of sub-pages (512 on x86_64).

This will be used for the THP (Transparent Huge Page) swap support.
Where one THP may be added/delted to/from the swap cache.  This will
batch the swap cache operations to reduce the lock acquire/release times
for the THP swap too.

Cc: Hugh Dickins <hughd@google.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 include/linux/page-flags.h |  2 +-
 mm/swap_state.c            | 57 +++++++++++++++++++++++++++++++---------------
 2 files changed, 40 insertions(+), 19 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 74e4dda..f5bcbea 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -314,7 +314,7 @@ PAGEFLAG_FALSE(HighMem)
 #endif
 
 #ifdef CONFIG_SWAP
-PAGEFLAG(SwapCache, swapcache, PF_NO_COMPOUND)
+PAGEFLAG(SwapCache, swapcache, PF_NO_TAIL)
 #else
 PAGEFLAG_FALSE(SwapCache)
 #endif
diff --git a/mm/swap_state.c b/mm/swap_state.c
index c335251..db2299f 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -43,6 +43,7 @@ struct address_space swapper_spaces[MAX_SWAPFILES] = {
 };
 
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
+#define ADD_CACHE_INFO(x, nr)	do { swap_cache_info.x += (nr); } while (0)
 
 static struct {
 	unsigned long add_total;
@@ -80,25 +81,32 @@ void show_swap_cache_info(void)
  */
 int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
-	int error;
+	int error, i, nr = hpage_nr_pages(page);
 	struct address_space *address_space;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-	get_page(page);
+	page_ref_add(page, nr);
 	SetPageSwapCache(page);
-	set_page_private(page, entry.val);
 
 	address_space = swap_address_space(entry);
 	spin_lock_irq(&address_space->tree_lock);
-	error = radix_tree_insert(&address_space->page_tree,
-					entry.val, page);
+	for (i = 0; i < nr; i++) {
+		struct page *cur_page = page + i;
+		unsigned long index = entry.val + i;
+
+		set_page_private(cur_page, index);
+		error = radix_tree_insert(&address_space->page_tree,
+					  index, cur_page);
+		if (unlikely(error))
+			break;
+	}
 	if (likely(!error)) {
-		address_space->nrpages++;
-		__inc_node_page_state(page, NR_FILE_PAGES);
-		INC_CACHE_INFO(add_total);
+		address_space->nrpages += nr;
+		__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, nr);
+		ADD_CACHE_INFO(add_total, nr);
 	}
 	spin_unlock_irq(&address_space->tree_lock);
 
@@ -109,9 +117,16 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 		 * So add_to_swap_cache() doesn't returns -EEXIST.
 		 */
 		VM_BUG_ON(error == -EEXIST);
-		set_page_private(page, 0UL);
 		ClearPageSwapCache(page);
-		put_page(page);
+		set_page_private(page + i, 0UL);
+		while (i--) {
+			struct page *cur_page = page + i;
+			unsigned long index = entry.val + i;
+
+			set_page_private(cur_page, 0UL);
+			radix_tree_delete(&address_space->page_tree, index);
+		}
+		page_ref_sub(page, nr);
 	}
 
 	return error;
@@ -122,7 +137,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
 {
 	int error;
 
-	error = radix_tree_maybe_preload(gfp_mask);
+	error = radix_tree_maybe_preload_order(gfp_mask, compound_order(page));
 	if (!error) {
 		error = __add_to_swap_cache(page, entry);
 		radix_tree_preload_end();
@@ -138,6 +153,7 @@ void __delete_from_swap_cache(struct page *page)
 {
 	swp_entry_t entry;
 	struct address_space *address_space;
+	int i, nr = hpage_nr_pages(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
@@ -145,12 +161,17 @@ void __delete_from_swap_cache(struct page *page)
 
 	entry.val = page_private(page);
 	address_space = swap_address_space(entry);
-	radix_tree_delete(&address_space->page_tree, page_private(page));
-	set_page_private(page, 0);
 	ClearPageSwapCache(page);
-	address_space->nrpages--;
-	__dec_node_page_state(page, NR_FILE_PAGES);
-	INC_CACHE_INFO(del_total);
+	for (i = 0; i < nr; i++) {
+		struct page *cur_page = page + i;
+
+		radix_tree_delete(&address_space->page_tree,
+				  page_private(cur_page));
+		set_page_private(cur_page, 0);
+	}
+	address_space->nrpages -= nr;
+	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
+	ADD_CACHE_INFO(del_total, nr);
 }
 
 /**
@@ -227,8 +248,8 @@ void delete_from_swap_cache(struct page *page)
 	__delete_from_swap_cache(page);
 	spin_unlock_irq(&address_space->tree_lock);
 
-	swapcache_free(entry);
-	put_page(page);
+	__swapcache_free(entry, PageTransHuge(page));
+	page_ref_sub(page, hpage_nr_pages(page));
 }
 
 /* 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
