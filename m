Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7AFB96B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 04:28:12 -0500 (EST)
From: Huang Shijie <b32955@freescale.com>
Subject: [PATCH] swap : check the return value of swap_readpage()
Date: Fri, 14 Jan 2011 17:30:21 +0800
Message-ID: <1294997421-8971-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, b20596@freescale.com, Huang Shijie <b32955@freescale.com>
List-ID: <linux-mm.kvack.org>

The read_swap_cache_async() does not check the return value
of swap_readpage().

If swap_readpage() returns -ENOMEM, the read_swap_cache_async()
still returns the `new_page` which has nothing. The caller will
do some wrong operations on the `new_page` such as copy.

The patch fixs the problem.

Also remove the unlock_ page() in swap_readpage() in the wrong case
, since __delete_from_swap_cache() needs a locked page.

Signed-off-by: Huang Shijie <b32955@freescale.com>
---
 mm/page_io.c    |    1 -
 mm/swap_state.c |   12 +++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/page_io.c b/mm/page_io.c
index 2dee975..5c759f2 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -124,7 +124,6 @@ int swap_readpage(struct page *page)
 	VM_BUG_ON(PageUptodate(page));
 	bio = get_swap_bio(GFP_KERNEL, page, end_swap_bio_read);
 	if (bio == NULL) {
-		unlock_page(page);
 		ret = -ENOMEM;
 		goto out;
 	}
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 5c8cfab..3bd7238 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -331,16 +331,18 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		__set_page_locked(new_page);
 		SetPageSwapBacked(new_page);
 		err = __add_to_swap_cache(new_page, entry);
+		radix_tree_preload_end();
 		if (likely(!err)) {
-			radix_tree_preload_end();
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_anon(new_page);
-			swap_readpage(new_page);
-			return new_page;
+			err = swap_readpage(new_page);
+			if (likely(!err)) {
+				lru_cache_add_anon(new_page);
+				return new_page;
+			}
+			__delete_from_swap_cache(new_page);
 		}
-		radix_tree_preload_end();
 		ClearPageSwapBacked(new_page);
 		__clear_page_locked(new_page);
 		/*
-- 
1.7.3.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
