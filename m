Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B04776B02E1
	for <linux-mm@kvack.org>; Thu, 11 May 2017 22:21:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c10so33332436pfg.10
        for <linux-mm@kvack.org>; Thu, 11 May 2017 19:21:28 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id s184si1909783pfb.65.2017.05.11.19.21.27
        for <linux-mm@kvack.org>;
        Thu, 11 May 2017 19:21:27 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 2/2] mm: swap: move anonymous THP split logic to vmscan
Date: Fri, 12 May 2017 11:21:24 +0900
Message-ID: <1494555684-11982-2-git-send-email-minchan@kernel.org>
In-Reply-To: <1494555684-11982-1-git-send-email-minchan@kernel.org>
References: <87h90sb4jq.fsf@yhuang-dev.intel.com>
 <1494555684-11982-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

The add_to_swap aims to allocate swap_space(ie, swap slot and
swapcache) so if it fails due to lack of space in case of THP
or something(hdd swap but tries THP swapout) *caller* rather
than add_to_swap itself should split the THP page and retry it
with base page which is more natural.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 include/linux/swap.h |  4 ++--
 mm/swap_state.c      | 23 ++++++-----------------
 mm/vmscan.c          | 17 ++++++++++++++++-
 3 files changed, 24 insertions(+), 20 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 8f12f67e869f..87cca2169d44 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -359,7 +359,7 @@ extern struct address_space *swapper_spaces[];
 		>> SWAP_ADDRESS_SPACE_SHIFT])
 extern unsigned long total_swapcache_pages(void);
 extern void show_swap_cache_info(void);
-extern int add_to_swap(struct page *, struct list_head *list);
+extern int add_to_swap(struct page *);
 extern int add_to_swap_cache(struct page *, swp_entry_t, gfp_t);
 extern int __add_to_swap_cache(struct page *page, swp_entry_t entry);
 extern void __delete_from_swap_cache(struct page *);
@@ -479,7 +479,7 @@ static inline struct page *lookup_swap_cache(swp_entry_t swp)
 	return NULL;
 }
 
-static inline int add_to_swap(struct page *page, struct list_head *list)
+static inline int add_to_swap(struct page *page)
 {
 	return 0;
 }
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 0ad214d7a7ad..9c71b6b2562f 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -184,7 +184,7 @@ void __delete_from_swap_cache(struct page *page)
  * Allocate swap space for the page and add the page to the
  * swap cache.  Caller needs to hold the page lock. 
  */
-int add_to_swap(struct page *page, struct list_head *list)
+int add_to_swap(struct page *page)
 {
 	swp_entry_t entry;
 	int err;
@@ -192,12 +192,12 @@ int add_to_swap(struct page *page, struct list_head *list)
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 	VM_BUG_ON_PAGE(!PageUptodate(page), page);
 
-retry:
 	entry = get_swap_page(page);
 	if (!entry.val)
-		goto fail;
+		return 0;
+
 	if (mem_cgroup_try_charge_swap(page, entry))
-		goto fail_free;
+		goto fail;
 
 	/*
 	 * Radix-tree node allocations from PF_MEMALLOC contexts could
@@ -218,23 +218,12 @@ int add_to_swap(struct page *page, struct list_head *list)
 		 * add_to_swap_cache() doesn't return -EEXIST, so we can safely
 		 * clear SWAP_HAS_CACHE flag.
 		 */
-		goto fail_free;
-
-	if (PageTransHuge(page)) {
-		err = split_huge_page_to_list(page, list);
-		if (err) {
-			delete_from_swap_cache(page);
-			return 0;
-		}
-	}
+		goto fail;
 
 	return 1;
 
-fail_free:
-	put_swap_page(page, entry);
 fail:
-	if (PageTransHuge(page) && !split_huge_page_to_list(page, list))
-		goto retry;
+	put_swap_page(page, entry);
 	return 0;
 }
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 57268c0c8fcf..767e20856080 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1125,8 +1125,23 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		    !PageSwapCache(page)) {
 			if (!(sc->gfp_mask & __GFP_IO))
 				goto keep_locked;
-			if (!add_to_swap(page, page_list))
+			if (!add_to_swap(page)) {
+				if (!PageTransHuge(page))
+					goto activate_locked;
+				/* Split THP and swap individual base pages */
+				if (split_huge_page_to_list(page, page_list))
+					goto activate_locked;
+				if (!add_to_swap(page))
+					goto activate_locked;
+			}
+
+			/* XXX: We don't support THP writes */
+			if (PageTransHuge(page) &&
+				  split_huge_page_to_list(page, page_list)) {
+				delete_from_swap_cache(page);
 				goto activate_locked;
+			}
+
 			may_enter_fs = 1;
 
 			/* Adding to swap updated mapping */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
