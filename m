Received: from renko.ucs.ed.ac.uk (renko.ucs.ed.ac.uk [129.215.13.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA04391
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 08:51:04 -0400
Date: Thu, 23 Jul 1998 13:48:28 +0100
Message-Id: <199807231248.NAA04764@dax.dcs.ed.ac.uk>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Good and bad news on 2.1.110, and a fix
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>, Alan Cox <number6@the-village.bc.nu>, "David S. Miller" <davem@dm.cobaltmicro.com>, Bill Hawes <whawes@star.net>, Ingo Molnar <mingo@valerie.inf.elte.hu>, Mark Hemment <markhe@nextd.demon.co.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

As the subject says, 2.1.110 is both very very promising and a stability
nightmare depending on what you are doing with it.  Fortunately, a very
simple failsafe mechanism against the observed problems seems to deal
with them extremely efficiently without any other performance impact,
and the resulting VM appears to be very stable.


The new memory code in get_free_pages is founded on a good principle: if
you don't let non-atomic consumers at the last few pages, then the last
high order pages get reserved for atomic use.

That's great as far as it goes.  When 2.1.110 gets going, it works a
treat: the performance on low memory is by *far* the best of any recent
kernels, and approaches 2.0 performance.  I'm seriously impressed.

However, if the memory useage pattern just happens by chance to fail to
leave any high order pages free, then the free_memory_available just
gives up in disgust.  My first attempt at booting 2.1.110 on a
low-memory setup failed because 4k nfs deadlocked during logon.
Shift-scrlck showed all the free memory in 4k and 8k pages, but 4k nfs
requires 16k pages.

The problem is twofold.  First of all, with low memory it is enormously
harder to get 16k free pages than 8k free pages.  With the default
SLAB_BREAK_GFP_ORDER setting of two, the slab allocator tries to
allocate 16k slabs for every object over 2048 bytes.  Setting this to
one instead improved things dramatically, and I haven't been able to
reproduce the problem since.  This does make some allocations less
efficient, but since it is primarily networking which creates atomic
demand for higher order pages than 8k, we can expect the allocations to
be sufficiently short-lived that the packing density is not important.

The second problem is more serious: the free_memory_available simply
doesn't care about page orders any more, and if you don't have enough
high order pages then you won't be given any.  A "ping -s 3000" to a
2.1.110 box doing NFS will kill it, even on a 16MB configuration.
Depending on the amount of background VM activity (eg. cron), it may
unstick itself after a few minutes once the attack stops, but a complete
session freeze for 4 or 5 minutes is still pretty bad.  Shift-scrlck on
the 16MB box in this mode shows all 97 free pages being of order 0;
there are no higher order pages available, at all, even after the ping
flood.


Linus, the patch at the end fixes these two problems for me, in a
painless manner.  The patch to slab.c simply makes SLAB_BREAK_GFP_ORDER
dependent on the memory size, and defaults to 1 instead of 2 if the
machine has less than 16MB.

The patch to page_alloc.c is a minimal fix for the fragmentation
problem.  It simply records allocation failures for high-order pages,
and forces free_memory_available to return false until a page of at
least that order becomes available.  The impact should be low, since
with the SLAB_BREAK_GFP_ORDER patch 2.1.111-pre1 seems to survive pretty
well anyway (and hence won't invoke the new mechanism), but in cases of
major atomic allocation load, the patch allows even low memory machines
to survive the ping attack handsomely (even with 8k NFS on a 6.5MB
configuration).  I get tons of "IP: queue_glue: no memory for gluing
queue" failures, but enough NFS retries get through even during the ping
flood to prevent any NFS server unreachables happening.


2.1.110 has fixed most of the VM problems I've been tracking.  It
eliminates the rusting memory death: a "find /" can still increase the
inode cache enough to cause a small but perceptible and permanent
performance drop on low memory, but at least it is stable, does not
appear to be cumulative, and does not result in swap deaths.  The page
cache is trimmed very nicely, and compiles are running more smoothly
than ever on 2.1.  The only stability problems I found were the atomic
allocation failures: preventing boot is a _serious_ problem.  With these
fixes in place, even that problem appears to have vanished.

It's looking good.  Comments?

--Stephen
----------------------------------------------------------------
--- mm/page_alloc.c.~1~	Wed Jul 22 14:48:23 1998
+++ mm/page_alloc.c	Thu Jul 23 13:00:54 1998
@@ -31,6 +31,8 @@
 int nr_swap_pages = 0;
 int nr_free_pages = 0;
 
+static int max_failed_order;
+
 /*
  * Free area management
  *
@@ -114,6 +116,23 @@
 {
 	static int available = 1;
 
+	/* First, perform a very simple test for fragmentation */
+	if (max_failed_order) {
+		unsigned long flags;
+		struct free_area_struct * list;
+		spin_lock_irqsave(&page_alloc_lock, flags);
+		for (list = free_area+max_failed_order;
+		     list < free_area+NR_MEM_LISTS;
+		     list++) {
+			if (list->next != memory_head(list))
+				break;
+		}
+		spin_unlock_irqrestore(&page_alloc_lock, flags);
+		if (list == free_area+NR_MEM_LISTS)
+			return 0;
+		max_failed_order = 0;
+	}
+	
 	if (nr_free_pages < freepages.low) {
 		available = 0;
 		return 0;
@@ -209,6 +228,8 @@
 				nr_free_pages -= 1 << order; \
 				EXPAND(ret, map_nr, order, new_order, area); \
 				spin_unlock_irqrestore(&page_alloc_lock, flags); \
+				if (order >= max_failed_order) \
+					max_failed_order = 0; \
 				return ADDRESS(map_nr); \
 			} \
 			prev = ret; \
@@ -263,6 +284,8 @@
 	spin_lock_irqsave(&page_alloc_lock, flags);
 	RMQUEUE(order, (gfp_mask & GFP_DMA));
 	spin_unlock_irqrestore(&page_alloc_lock, flags);
+	if (order > max_failed_order)
+		max_failed_order = order;
 nopage:
 	return 0;
 }
--- mm/slab.c.~1~	Wed Jul  8 14:35:46 1998
+++ mm/slab.c	Thu Jul 23 12:41:57 1998
@@ -313,7 +313,9 @@
 /* If the num of objs per slab is <= SLAB_MIN_OBJS_PER_SLAB,
  * then the page order must be less than this before trying the next order.
  */
-#define	SLAB_BREAK_GFP_ORDER	2
+#define	SLAB_BREAK_GFP_ORDER_HI	2
+#define	SLAB_BREAK_GFP_ORDER_LO	1
+static int slab_break_gfp_order = SLAB_BREAK_GFP_ORDER_LO;
 
 /* Macros for storing/retrieving the cachep and or slab from the
  * global 'mem_map'.  With off-slab bufctls, these are used to find the
@@ -447,6 +449,11 @@
 	cache_cache.c_colour = (i-(cache_cache.c_num*size))/L1_CACHE_BYTES;
 	cache_cache.c_colour_next = cache_cache.c_colour;
 
+	/* Fragmentation resistance on low memory */
+	if ((num_physpages * PAGE_SIZE) < 16 * 1024 * 1024)
+		slab_break_gfp_order = SLAB_BREAK_GFP_ORDER_LO;
+	else
+		slab_break_gfp_order = SLAB_BREAK_GFP_ORDER_HI;
 	return start;
 }
 
@@ -869,7 +876,7 @@
 		 * bad for the gfp()s.
 		 */
 		if (cachep->c_num <= SLAB_MIN_OBJS_PER_SLAB) {
-			if (cachep->c_gfporder < SLAB_BREAK_GFP_ORDER)
+			if (cachep->c_gfporder < slab_break_gfp_order)
 				goto next;
 		}
 

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
