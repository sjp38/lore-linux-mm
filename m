Date: Fri, 21 Jan 2000 03:36:12 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.1{3,4,5} VM fix
In-Reply-To: <Pine.LNX.4.21.0001210220190.4332-100000@alpha.random>
Message-ID: <Pine.LNX.4.21.0001210332210.4332-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Andrea Arcangeli wrote:

>I'll try to send a patch against 2.2.14 for the atomic allocation thing
>that I think to see ASAP.

Ok this should fix the atomic allocation problem (that was present as well
in 2.2.13 and previous). It should also improve performance freeing memory
in parallel with the task that is allocating memory.

Way too late to try it out now in practice, but I checked it compiles and
looks strightforward:

--- 2.2.14-kswapd/mm/vmscan.c.~1~	Wed Jan  5 14:16:56 2000
+++ 2.2.14-kswapd/mm/vmscan.c	Fri Jan 21 03:25:59 2000
@@ -437,7 +437,7 @@
        printk ("Starting kswapd v%.*s\n", i, s);
 }
 
-static struct wait_queue * kswapd_wait = NULL;
+struct wait_queue * kswapd_wait;
 
 /*
  * The background pageout daemon, started as a kernel thread
@@ -485,7 +485,7 @@
 		 * the processes needing more memory will wake us
 		 * up on a more timely basis.
 		 */
-		interruptible_sleep_on_timeout(&kswapd_wait, HZ);
+		interruptible_sleep_on(&kswapd_wait);
 		while (nr_free_pages < freepages.high)
 		{
 			if (do_try_to_free_pages(GFP_KSWAPD))
@@ -519,7 +519,6 @@
 {
 	int retval = 1;
 
-	wake_up_interruptible(&kswapd_wait);
 	if (gfp_mask & __GFP_WAIT)
 		retval = do_try_to_free_pages(gfp_mask);
 	return retval;
--- 2.2.14-kswapd/mm/page_alloc.c.~1~	Wed Jan  5 14:16:56 2000
+++ 2.2.14-kswapd/mm/page_alloc.c	Fri Jan 21 03:29:40 2000
@@ -211,14 +211,20 @@
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
 		int freed;
+		extern struct wait_queue * kswapd_wait;
 
-		if (nr_free_pages > freepages.min) {
-			if (!low_on_memory)
-				goto ok_to_allocate;
-			if (nr_free_pages >= freepages.high) {
+		if (nr_free_pages >= freepages.high)
+		{
+			/* share RO cachelines in fast path */
+			if (low_on_memory)
 				low_on_memory = 0;
+			goto ok_to_allocate;
+		}
+		else
+		{
+			wake_up_interruptible(&kswapd_wait);
+			if (nr_free_pages > freepages.min && !low_on_memory)
 				goto ok_to_allocate;
-			}
 		}
 
 		low_on_memory = 1;

Please if you have problematic atomic allocation try the above patch.

It's downloadable also from here:

	ftp://ftp.*.kernel.org/pub/linux/kernel/people/andrea/patches/v2.2/2.2.14/atomic-allocations-1.gz

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
