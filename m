Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2776B0282
	for <linux-mm@kvack.org>; Fri, 28 Oct 2016 01:56:40 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id rf5so37190669pab.3
        for <linux-mm@kvack.org>; Thu, 27 Oct 2016 22:56:40 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id ub3si9907965pab.52.2016.10.27.22.56.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 27 Oct 2016 22:56:39 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -v4 RESEND 6/9] mm, THP, swap: Support to add/delete THP to/from swap cache
Date: Fri, 28 Oct 2016 13:56:05 +0800
Message-Id: <20161028055608.1736-7-ying.huang@intel.com>
In-Reply-To: <20161028055608.1736-1-ying.huang@intel.com>
References: <20161028055608.1736-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Huang Ying <ying.huang@intel.com>

With this patch, a THP (Transparent Huge Page) can be added/deleted
to/from the swap cache as a set of (HPAGE_PMD_NR) sub-pages.

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
 mm/swap_state.c            | 58 ++++++++++++++++++++++++++++++++--------------
 2 files changed, 41 insertions(+), 19 deletions(-)

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
index d3f047b..3115762 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -43,6 +43,7 @@ struct address_space swapper_spaces[MAX_SWAPFILES] = {
 };
 
 #define INC_CACHE_INFO(x)	do { swap_cache_info.x++; } while (0)
+#define ADD_CACHE_INFO(x, nr)	do { swap_cache_info.x += (nr); } while (0)
 
 static struct {
 	unsigned long add_total;
@@ -80,25 +81,33 @@ void show_swap_cache_info(void)
  */
 int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 {
-	int error;
+	int error, i, nr = hpage_nr_pages(page);
 	struct address_space *address_space;
+	struct page *cur_page;
+	swp_entry_t cur_entry;
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(PageSwapCache(page), page);
 	VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
 
-	get_page(page);
+	page_ref_add(page, nr);
 	SetPageSwapCache(page);
-	set_page_private(page, entry.val);
 
 	address_space = swap_address_space(entry);
+	cur_page = page;
+	cur_entry.val = entry.val;
 	spin_lock_irq(&address_space->tree_lock);
-	error = radix_tree_insert(&address_space->page_tree,
-				  swp_offset(entry), page);
+	for (i = 0; i < nr; i++, cur_page++, cur_entry.val++) {
+		set_page_private(cur_page, cur_entry.val);
+		error = radix_tree_insert(&address_space->page_tree,
+					  swp_offset(cur_entry), cur_page);
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
 
@@ -109,9 +118,16 @@ int __add_to_swap_cache(struct page *page, swp_entry_t entry)
 		 * So add_to_swap_cache() doesn't returns -EEXIST.
 		 */
 		VM_BUG_ON(error == -EEXIST);
-		set_page_private(page, 0UL);
 		ClearPageSwapCache(page);
-		put_page(page);
+		set_page_private(cur_page, 0UL);
+		while (i--) {
+			cur_page--;
+			cur_entry.val--;
+			set_page_private(cur_page, 0UL);
+			radix_tree_delete(&address_space->page_tree,
+					  swp_offset(cur_entry));
+		}
+		page_ref_sub(page, nr);
 	}
 
 	return error;
@@ -122,7 +138,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
 {
 	int error;
 
-	error = radix_tree_maybe_preload(gfp_mask);
+	error = radix_tree_maybe_preload_order(gfp_mask, compound_order(page));
 	if (!error) {
 		error = __add_to_swap_cache(page, entry);
 		radix_tree_preload_end();
@@ -138,6 +154,7 @@ void __delete_from_swap_cache(struct page *page)
 {
 	swp_entry_t entry;
 	struct address_space *address_space;
+	int i, nr = hpage_nr_pages(page);
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageSwapCache(page), page);
@@ -145,12 +162,17 @@ void __delete_from_swap_cache(struct page *page)
 
 	entry.val = page_private(page);
 	address_space = swap_address_space(entry);
-	radix_tree_delete(&address_space->page_tree, swp_offset(entry));
-	set_page_private(page, 0);
 	ClearPageSwapCache(page);
-	address_space->nrpages--;
-	__dec_node_page_state(page, NR_FILE_PAGES);
-	INC_CACHE_INFO(del_total);
+	for (i = 0; i < nr; i++, entry.val++) {
+		struct page *cur_page = page + i;
+
+		radix_tree_delete(&address_space->page_tree,
+				  swp_offset(entry));
+		set_page_private(cur_page, 0);
+	}
+	address_space->nrpages -= nr;
+	__mod_node_page_state(page_pgdat(page), NR_FILE_PAGES, -nr);
+	ADD_CACHE_INFO(del_total, nr);
 }
 
 /**
@@ -227,8 +249,8 @@ void delete_from_swap_cache(struct page *page)
 	__delete_from_swap_cache(page);
 	spin_unlock_irq(&address_space->tree_lock);
 
-	swapcache_free(entry);
-	put_page(page);
+	__swapcache_free(entry, PageTransHuge(page));
+	page_ref_sub(page, hpage_nr_pages(page));
 }
 
 /* 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
