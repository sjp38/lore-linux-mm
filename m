Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id ED71A6B0036
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 06:06:42 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so6881829pbb.19
        for <linux-mm@kvack.org>; Mon, 22 Jul 2013 03:06:42 -0700 (PDT)
Date: Mon, 22 Jul 2013 18:06:18 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 3/4 v6]swap: fix races exposed by swap discard
Message-ID: <20130722100618.GC17386@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com, aquini@redhat.com


Last patch can expose races, according to Hugh:

swapoff was sometimes failing with "Cannot allocate memory", coming from
try_to_unuse()'s -ENOMEM: it needs to allow for swap_duplicate() failing on a
free entry temporarily SWAP_MAP_BAD while being discarded.

We should use ACCESS_ONCE() there, and whenever accessing swap_map locklessly;
but rather than peppering it throughout try_to_unuse(), just declare *swap_map
with volatile.

try_to_unuse() is accustomed to *swap_map going down racily, but not
necessarily to it jumping up from 0 to SWAP_MAP_BAD: we'll be safer to prevent
that transition once SWP_WRITEOK is switched off, when it's a waste of time to
issue discards anyway (swapon can do a whole discard).

Another issue is:

In swapin_readahead(), read_swap_cache_async() can read a bad swap entry,
because we don't check if readahead swap entry is bad. This doesn't break
anything but such swapin page is wasteful and can only be freed at page
reclaim. We should avoid read such swap entry. And in discard, we mark swap
entry SWAP_MAP_BAD and then switch it to normal when discard is finished. If
readahead reads such swap entry, we have the same issue, so we much check if
swap entry is bad too.

Thanks Hugh to inspire swapin_readahead could use bad swap entry.

[include Hugh's patch 'swap: fix swapoff ENOMEMs from discard']
Signed-off-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Shaohua Li <shli@fusionio.com>
---
 mm/swapfile.c |   31 +++++++++++++++++++++++++++----
 1 file changed, 27 insertions(+), 4 deletions(-)

Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2013-07-22 10:03:44.426840704 +0800
+++ linux/mm/swapfile.c	2013-07-22 10:07:27.484038790 +0800
@@ -370,7 +370,8 @@ static void dec_cluster_info_page(struct
 		 * instead of free it immediately. The cluster will be freed
 		 * after discard.
 		 */
-		if (p->flags & SWP_PAGE_DISCARD) {
+		if ((p->flags & (SWP_WRITEOK | SWP_PAGE_DISCARD)) ==
+				 (SWP_WRITEOK | SWP_PAGE_DISCARD)) {
 			swap_cluster_schedule_discard(p, idx);
 			return;
 		}
@@ -1273,7 +1274,7 @@ static unsigned int find_next_to_unuse(s
 			else
 				continue;
 		}
-		count = si->swap_map[i];
+		count = ACCESS_ONCE(si->swap_map[i]);
 		if (count && swap_count(count) != SWAP_MAP_BAD)
 			break;
 	}
@@ -1293,7 +1294,11 @@ int try_to_unuse(unsigned int type, bool
 {
 	struct swap_info_struct *si = swap_info[type];
 	struct mm_struct *start_mm;
-	unsigned char *swap_map;
+	volatile unsigned char *swap_map; /* swap_map is accessed without
+					   * locking. Mark it as volatile
+					   * to prevent compiler doing
+					   * something odd.
+					   */
 	unsigned char swcount;
 	struct page *page;
 	swp_entry_t entry;
@@ -1344,7 +1349,15 @@ int try_to_unuse(unsigned int type, bool
 			 * reused since sys_swapoff() already disabled
 			 * allocation from here, or alloc_page() failed.
 			 */
-			if (!*swap_map)
+			swcount = *swap_map;
+			/*
+			 * We don't hold lock here, so the swap entry could be
+			 * SWAP_MAP_BAD (when the cluster is discarding).
+			 * Instead of fail out, We can just skip the swap
+			 * entry because swapoff will wait for discarding
+			 * finish anyway.
+			 */
+			if (!swcount || swcount == SWAP_MAP_BAD)
 				continue;
 			retval = -ENOMEM;
 			break;
@@ -2528,6 +2541,16 @@ static int __swap_duplicate(swp_entry_t
 		goto unlock_out;
 
 	count = p->swap_map[offset];
+
+	/*
+	 * swapin_readahead() doesn't check if a swap entry is valid, so the
+	 * swap entry could be SWAP_MAP_BAD. Check here with lock held.
+	 */
+	if (unlikely(swap_count(count) == SWAP_MAP_BAD)) {
+		err = -ENOENT;
+		goto unlock_out;
+	}
+
 	has_cache = count & SWAP_HAS_CACHE;
 	count &= ~SWAP_HAS_CACHE;
 	err = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
