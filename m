Date: Mon, 28 Jun 1999 12:35:24 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <199906280148.SAA94463@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9906281227550.364-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: torvalds@transmeta.com, sct@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 27 Jun 1999, Kanoj Sarcar wrote:

>This is the patch that tries to cure the swapoff races with processes
>forking, exiting, and (readahead) swapping by faulting. 

For the record: at least the read_swap_cache_async race I pointed out can
be fixed without grabbing the mmap semaphore. I agree that grabbing the
semaphore would fix the race though.

Here it is the alternate fix:

Index: mm/swap_state.c
===================================================================
RCS file: /var/cvs/linux/mm/swap_state.c,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 swap_state.c
--- mm/swap_state.c	1999/06/14 15:30:09	1.1.1.3
+++ mm/swap_state.c	1999/06/28 10:15:15
@@ -125,7 +125,7 @@
 		"swap_duplicate: entry %08lx, offset exceeds max\n", entry);
 	goto out;
 bad_unused:
-	printk(KERN_ERR
+	printk(KERN_WARNING
 		"swap_duplicate at %8p: entry %08lx, unused page\n", 
 	       __builtin_return_address(0), entry);
 	goto out;
@@ -291,20 +291,15 @@
 	       entry, wait ? ", wait" : "");
 #endif
 	/*
-	 * Make sure the swap entry is still in use.
-	 */
-	if (!swap_duplicate(entry))	/* Account for the swap cache */
-		goto out;
-	/*
 	 * Look for the page in the swap cache.
 	 */
 	found_page = lookup_swap_cache(entry);
 	if (found_page)
-		goto out_free_swap;
+		goto out;
 
 	new_page_addr = __get_free_page(GFP_USER);
 	if (!new_page_addr)
-		goto out_free_swap;	/* Out of memory */
+		goto out;	/* Out of memory */
 	new_page = mem_map + MAP_NR(new_page_addr);
 
 	/*
@@ -313,6 +308,11 @@
 	found_page = lookup_swap_cache(entry);
 	if (found_page)
 		goto out_free_page;
+	/*
+	 * Make sure the swap entry is still in use.
+	 */
+	if (!swap_duplicate(entry))	/* Account for the swap cache */
+		goto out_free_page;
 	/* 
 	 * Add it to the swap cache and read its contents.
 	 */
@@ -330,8 +330,6 @@
 
 out_free_page:
 	__free_page(new_page);
-out_free_swap:
-	swap_free(entry);
 out:
 	return found_page;
 }



NOTE: this will cause swap_duplicate to generate some warning message but
everything will work fine then, exactly because the swapin code just check
if the pte is changed (swapped in from swapoff) before looking if
read_swap_cache returned a NULL pointer. (also the shm.c swap-cache code
checks if the pte is changed before to go oom).

But probably the right thing to do is to grab the mm semaphore in swapoff
as you did since we don't risk to deadlock there :).

Comments?

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
