Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA13880
	for <linux-mm@kvack.org>; Sat, 9 Jan 1999 13:59:40 -0500
Date: Sat, 9 Jan 1999 19:58:25 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.2.0-pre[56] swap performance poor with > 1 thrashing task
In-Reply-To: <Pine.LNX.3.95.990108223729.3436D-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990109194152.2615C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Dax Kelson <dkelson@inconnect.com>, Steve Bergman <steve@netplus.net>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

I think there are problems with 2.2.0-pre6 VM (even if I have not tried it
yet really). Latest time I tried on previous kernel to use in
__get_free_pages() a try_to_free_pages weight > than MAX_SWAP_CLUSTER (aka
freepages.high - nr_free_pages) I had bad impact of VM balance under
swapping. 

The problem is try_to_free_pages() implementation. Using a lower weight as
in pre5 we was sure to return to shrink_mmap with more frequency and so
getting more balance. Instead now we return to risk to only swapout
without make real free memory space.

In the patch there's also some cosmetic change (like s/if/else if/). The
priority = 8 is to go in the swap path more easily.

Ah and probably we could reinsert the swapout_interval sysctl with default
value of HZ (not done yet due lack of time).

Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.11 linux/mm/vmscan.c:1.1.1.1.2.81
--- linux/mm/vmscan.c:1.1.1.11	Sat Jan  9 12:58:26 1999
+++ linux/mm/vmscan.c	Sat Jan  9 19:30:01 1999
@@ -10,6 +10,11 @@
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  */
 
+/*
+ * free_user_and_cache(), always async swapout.
+ * Copyright (C) 1999  Andrea Arcangeli
+ */
+
 #include <linux/slab.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
@@ -199,11 +204,11 @@
 
 	do {
 		int result;
-		tsk->swap_address = address + PAGE_SIZE;
 		result = try_to_swap_out(tsk, vma, address, pte, gfp_mask);
+		address += PAGE_SIZE;
+		tsk->swap_address = address;
 		if (result)
 			return result;
-		address += PAGE_SIZE;
 		pte++;
 	} while (address < end);
 	return 0;
@@ -325,7 +330,7 @@
 	counter = nr_tasks / (priority+1);
 	if (counter < 1)
 		counter = 1;
-	if (counter > nr_tasks)
+	else if (counter > nr_tasks)
 		counter = nr_tasks;
 
 	for (; counter >= 0; counter--) {
@@ -438,13 +443,22 @@
 		 * point is to make sure that the system doesn't stay
 		 * forever in a really bad memory squeeze.
 		 */
-		if (nr_free_pages < freepages.high)
-			try_to_free_pages(0, 16);
+		if (nr_free_pages < freepages.low)
+			try_to_free_pages(0, freepages.high - nr_free_pages);
 	}
 
 	return 0;
 }
 
+static int free_user_and_cache(int priority, int gfp_mask)
+{
+	if (shrink_mmap(priority, gfp_mask))
+		return 1;
+	if (swap_out(priority, gfp_mask))
+		return 1;
+	return 0;
+}
+
 /*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
@@ -457,33 +471,32 @@
 int try_to_free_pages(unsigned int gfp_mask, int count)
 {
 	int priority;
+	static int state = 0;
 
 	lock_kernel();
 
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(gfp_mask);
-
-	priority = 6;
-	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
-
-		/* Try to get rid of some shared memory pages.. */
-		while (shm_swap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
-	
-		/* Then, try to page stuff out.. */
-		while (swap_out(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
+	priority = 8;
+	switch (state)
+	{
+		do {
+		case 0:
+			while (free_user_and_cache(priority, gfp_mask)) {
+				if (!--count)
+					goto done;
+			}
+			state = 1;
+		case 1:
+			/* Try to get rid of some shared memory pages.. */
+			while (shm_swap(priority, gfp_mask)) {
+				if (!--count)
+					goto done;
+			}
+			state = 0;
 
-		shrink_dcache_memory(priority, gfp_mask);
-	} while (--priority >= 0);
+			kmem_cache_reap(gfp_mask);
+			shrink_dcache_memory(priority, gfp_mask);
+		} while (--priority >= 0);
+	}
 done:
 	unlock_kernel();
 


Another patch I consider right is this:

Index: linux/mm/page_alloc.c
diff -u linux/mm/page_alloc.c:1.1.1.7 linux/mm/page_alloc.c:1.1.1.1.2.25
--- linux/mm/page_alloc.c:1.1.1.7	Sat Jan  9 12:58:25 1999
+++ linux/mm/page_alloc.c	Fri Jan  8 00:57:18 1999
@@ -3,6 +3,7 @@
  *
  *  Copyright (C) 1991, 1992, 1993, 1994  Linus Torvalds
  *  Swap reorganised 29.12.95, Stephen Tweedie
+ *  trashing_memory heuristic. Copyright (C) 1999  Andrea Arcangeli
  */
 
 #include <linux/config.h>
@@ -265,10 +266,11 @@
 		if (nr_free_pages > freepages.min) {
 			if (!current->trashing_memory)
 				goto ok_to_allocate;
-			if (nr_free_pages > freepages.low) {
+			if (nr_free_pages > freepages.high) {
 				current->trashing_memory = 0;
 				goto ok_to_allocate;
-			}
+			} else if (nr_free_pages > freepages.low)
+				goto ok_to_allocate;
 		}
 		/*
 		 * Low priority (user) allocations must not


This will allow the system to be less close to freepages.min. Both the two
patches applyed to pre6 make arca-vm-13-against-pre5 and arca-vm-13 is
been reported by Steve to give the _same_ timing numbers as pre5 with its
latest bench (with the difference that arca-vm-13 was generating 1/2 of
swap hit than pre5). I guess he will try to do some other bench (as the
image test soon) next days though.

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
