Date: Wed, 26 Jan 2000 01:20:48 +0100 (CET)
From: Rik van Riel <riel@nl.linux.org>
Subject: 2.2.15pre4 VM fix
Message-ID: <Pine.LNX.4.10.10001260118220.1373-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi Alan,

with the attached patch I hope to have fixed the 2.2.15pre4
VM problems. I didn't manage to break it myself, but maybe
one of the dear readers has a machine where they are able
to do so...

Please give this patch (against 2.2.15pre4) a solid beating
and report back to us. Thanks all!

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.


--- mm/page_alloc.c.orig	Tue Jan 25 00:01:43 2000
+++ mm/page_alloc.c	Wed Jan 26 01:16:21 2000
@@ -210,6 +210,12 @@
 	 */
 	if (!(current->flags & PF_MEMALLOC)) {
 		int freed;
+		if (current->state != TASK_RUNNING && (gfp_mask & __GFP_WAIT)) {
+			printk("gfp called by non-running (%d) task from %p!\n",
+				current->state, __builtin_return_address(0));
+			/* if we're not running, we can't sleep */
+			gfp_mask &= ~__GFP_WAIT;
+		}
 
 		if (nr_free_pages <= freepages.low) {
 			wake_up_interruptible(&kswapd_wait);
@@ -224,6 +230,9 @@
 		current->flags |= PF_MEMALLOC;
 		freed = try_to_free_pages(gfp_mask);
 		current->flags &= ~PF_MEMALLOC;
+
+		if ((gfp_mask & __GFP_MED) && nr_free_pages > freepages.min / 2)
+			goto ok_to_allocate;
 
 		if (!freed && !(gfp_mask & __GFP_HIGH))
 			goto nopage;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
