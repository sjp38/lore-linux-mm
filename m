Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 313396B007E
	for <linux-mm@kvack.org>; Sun,  9 Aug 2009 22:58:54 -0400 (EDT)
Date: Mon, 10 Aug 2009 11:26:41 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [BUGFIX][1/2] mm: add_to_swap_cache() must not sleep
Message-Id: <20090810112641.02e1db72.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090810112326.3526b11d.nishimura@mxp.nes.nec.co.jp>
References: <20090810112326.3526b11d.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

After commit 355cfa73(mm: modify swap_map and add SWAP_HAS_CACHE flag),
read_swap_cache_async() will busy-wait while a entry doesn't on swap cache
but it has SWAP_HAS_CACHE flag.

Such entries can exist on add/delete path of swap cache.
On add path, add_to_swap_cache() is called soon after SWAP_HAS_CACHE flag
is set, and on delete path, swapcache_free() will be called (SWAP_HAS_CACHE
flag is cleared) soon after __delete_from_swap_cache() is called.
So, the busy-wait works well in most cases.

But this mechanism can cause soft lockup if add_to_swap_cache() sleeps
and read_swap_cache_async() tries to swap-in the same entry on the same cpu.

add_to_swap() and shmem_writepage() call add_to_swap_cache() w/o __GFP_WAIT,
but read_swap_cache_async() can call it w/ __GFP_WAIT, so it can cause
soft lockup.

This patch changes the gfp_mask of add_to_swap_cache() in read_swap_cache_async().

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/swap_state.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 42cd38e..3e6dd72 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -76,6 +76,7 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageSwapCache(page));
 	VM_BUG_ON(!PageSwapBacked(page));
+	VM_BUG_ON(gfp_mask & __GFP_WAIT);
 
 	error = radix_tree_preload(gfp_mask);
 	if (!error) {
@@ -307,7 +308,7 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 		 */
 		__set_page_locked(new_page);
 		SetPageSwapBacked(new_page);
-		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
+		err = add_to_swap_cache(new_page, entry, GFP_ATOMIC);
 		if (likely(!err)) {
 			/*
 			 * Initiate read into locked page and return.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
