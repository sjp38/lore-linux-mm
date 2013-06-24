Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id B3F626B0073
	for <linux-mm@kvack.org>; Mon, 24 Jun 2013 07:04:28 -0400 (EDT)
Received: by mail-ob0-f173.google.com with SMTP id wc20so10727253obb.18
        for <linux-mm@kvack.org>; Mon, 24 Jun 2013 04:04:27 -0700 (PDT)
Date: Mon, 24 Jun 2013 19:04:16 +0800
From: Shaohua Li <shli@kernel.org>
Subject: [patch 3/4 v5]swap: fix races exposed by swap discard
Message-ID: <20130624110416.GC15796@kernel.org>
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
 mm/swapfile.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

Index: linux/mm/swapfile.c
===================================================================
--- linux.orig/mm/swapfile.c	2013-06-20 08:14:33.526326270 +0800
+++ linux/mm/swapfile.c	2013-06-20 08:14:40.214241379 +0800
@@ -357,7 +357,8 @@ static void dec_cluster_info_page(struct
 		 * instead of free it immediately. The cluster will be freed
 		 * after discard.
 		 */
-		if (p->flags & SWP_DISCARDABLE) {
+		if ((p->flags & (SWP_WRITEOK | SWP_DISCARDABLE)) ==
+				 (SWP_WRITEOK | SWP_DISCARDABLE)) {
 			swap_cluster_schedule_discard(p, idx);
 			return;
 		}
@@ -1255,7 +1256,7 @@ static unsigned int find_next_to_unuse(s
 			else
 				continue;
 		}
-		count = si->swap_map[i];
+		count = ACCESS_ONCE(si->swap_map[i]);
 		if (count && swap_count(count) != SWAP_MAP_BAD)
 			break;
 	}
@@ -1275,7 +1276,7 @@ int try_to_unuse(unsigned int type, bool
 {
 	struct swap_info_struct *si = swap_info[type];
 	struct mm_struct *start_mm;
-	unsigned char *swap_map;
+	volatile unsigned char *swap_map;	/* ACCESS_ONCE throughout */
 	unsigned char swcount;
 	struct page *page;
 	swp_entry_t entry;
@@ -1326,7 +1327,8 @@ int try_to_unuse(unsigned int type, bool
 			 * reused since sys_swapoff() already disabled
 			 * allocation from here, or alloc_page() failed.
 			 */
-			if (!*swap_map)
+			swcount = *swap_map;
+			if (!swcount || swcount == SWAP_MAP_BAD)
 				continue;
 			retval = -ENOMEM;
 			break;
@@ -2462,6 +2464,11 @@ static int __swap_duplicate(swp_entry_t
 		goto unlock_out;
 
 	count = p->swap_map[offset];
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
