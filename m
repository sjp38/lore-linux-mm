Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA12539
	for <linux-mm@kvack.org>; Wed, 9 Dec 1998 15:49:28 -0500
Date: Wed, 9 Dec 1998 18:43:25 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <199812072204.WAA01733@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981209183310.3727A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Rik van Riel <H.H.vanRiel@phys.uu.nl>, Neil Conway <nconway.list@ukaea.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Dec 1998, Stephen C. Tweedie wrote:

>Right: 2.1.131 + Rik's fixes + my fix to Rik's fixes (see below) has set
>a new record for my 8MB benchmarks.  In 64MB, it is behaving much more

I think that my state = 0 in do_try_to_free_page() helped a lot to handle
the better kernel performance.

>--- mm/vmscan.c.~1~	Mon Dec  7 12:05:54 1998
>+++ mm/vmscan.c	Mon Dec  7 18:55:55 1998
>@@ -432,6 +432,8 @@
> 
> 	if (buffer_over_borrow() || pgcache_over_borrow())
> 		state = 0;
>+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster / 2)
>+		shrink_mmap(i, gfp_mask);
> 

Doing that we risk to shrink too much cache even if not necessary but this
part of the patch improve a _lot_ swapping performance even if I don' t know
why ;)

And why not to use GFP_USER in the userspace swaping code?

Index: linux/mm/swap_state.c
diff -u linux/mm/swap_state.c:1.1.3.2 linux/mm/swap_state.c:1.1.1.1.2.4
--- linux/mm/swap_state.c:1.1.3.2	Wed Dec  9 16:11:46 1998
+++ linux/mm/swap_state.c	Wed Dec  9 18:39:03 1998
@@ -261,7 +261,9 @@
 struct page * lookup_swap_cache(unsigned long entry)
 {
 	struct page *found;
+#ifdef	SWAP_CACHE_INFO
 	swap_cache_find_total++;
+#endif
 	
 	while (1) {
 		found = find_page(&swapper_inode, entry);
@@ -270,7 +272,9 @@
 		if (found->inode != &swapper_inode || !PageSwapCache(found))
 			goto out_bad;
 		if (!PageLocked(found)) {
+#ifdef	SWAP_CACHE_INFO
 			swap_cache_find_success++;
+#endif
 			return found;
 		}
 		__free_page(found);
@@ -308,7 +336,7 @@
 	if (found_page)
 		goto out;
 
-	new_page_addr = __get_free_page(GFP_KERNEL);
+	new_page_addr = __get_free_page(GFP_USER);
 	if (!new_page_addr)
 		goto out;	/* Out of memory */
 	new_page = mem_map + MAP_NR(new_page_addr);


Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
