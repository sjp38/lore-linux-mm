Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA18224
	for <linux-mm@kvack.org>; Wed, 13 Jan 1999 12:43:43 -0500
Date: Wed, 13 Jan 1999 17:43:18 GMT
Message-Id: <199901131743.RAA06360@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: [PATCH] Fix for swapin bug
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Stephen Tweedie <sct@redhat.com>, Alan Cox <number6@the-village.bc.nu>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Bill Hawes <whawes@star.net>
List-ID: <linux-mm.kvack.org>

Hi,

In the swap readahead code, we correctly avoid trying to read in swap
pages which already have a swap count of zero.  However,
read_swap_page_async() can block between this point and the
swap_duplicate(); there is no guarantee that the page on disk is still
in use by the time we come to perform the swap IO, so swap_duplicate()
can fail with messages like

	morn kernel: swap_duplicate at    44400: entry 00044400, unused page 

The reason we don't see the same problem in normal swapping is simply
that the mm semaphore prevents multiple threads from trying to swap the
same page in concurrently, so we always guarantee that the current pte's
reference to the swap page is still valid after read_swap_page_async()
blocks. 

The fix is to perform the swap_duplicate at the very top of
read_swap_page_async(), before we have a chance to block.

--Stephen
----------------------------------------------------------------
--- mm/swap_state.c~	Tue Jan 12 17:04:49 1999
+++ mm/swap_state.c	Wed Jan 13 17:22:24 1999
@@ -283,7 +283,7 @@
 
 struct page * read_swap_cache_async(unsigned long entry, int wait)
 {
-	struct page *found_page, *new_page;
+	struct page *found_page = 0, *new_page;
 	unsigned long new_page_addr;
 	
 #ifdef DEBUG_SWAP
@@ -291,15 +291,20 @@
 	       entry, wait ? ", wait" : "");
 #endif
 	/*
+	 * Make sure the swap entry is still in use.
+	 */
+	if (!swap_duplicate(entry))	/* Account for the swap cache */
+		goto out;
+	/*
 	 * Look for the page in the swap cache.
 	 */
 	found_page = lookup_swap_cache(entry);
 	if (found_page)
-		goto out;
+		goto out_free_swap;
 
 	new_page_addr = __get_free_page(GFP_USER);
 	if (!new_page_addr)
-		goto out;	/* Out of memory */
+		goto out_free_swap;	/* Out of memory */
 	new_page = mem_map + MAP_NR(new_page_addr);
 
 	/*
@@ -308,11 +313,6 @@
 	found_page = lookup_swap_cache(entry);
 	if (found_page)
 		goto out_free_page;
-	/*
-	 * Make sure the swap entry is still in use.
-	 */
-	if (!swap_duplicate(entry))	/* Account for the swap cache */
-		goto out_free_page;
 	/* 
 	 * Add it to the swap cache and read its contents.
 	 */
@@ -330,6 +330,8 @@
 
 out_free_page:
 	__free_page(new_page);
+out_free_swap:
+	swap_free(entry);
 out:
 	return found_page;
 }

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
