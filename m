Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA29577
	for <linux-mm@kvack.org>; Thu, 26 Feb 1998 10:22:11 -0500
Date: Thu, 26 Feb 1998 16:18:50 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: [PATCH] small thrashing improvement
Message-ID: <Pine.LNX.3.91.980226161400.696A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus and Stephen,

here's a (very small) patch that improves the
responsiveness of interactive programs when the
system is thrashing.

Basically, it just adds the page aging capability
to the page cache (but _not_ to the buffer cache, since
we really want to get rid of buffers when memory is
tight).

I think it's trivial enough to go into 2.1.89, but
that's just MHO...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
               ____________
-------------->| cut here |<--------------------
               `~~~~~~~~~~'

--- linux2188orig/mm/filemap.c	Wed Feb 25 16:40:55 1998
+++ linux-2.1.88/mm/filemap.c	Thu Feb 26 15:43:16 1998
@@ -25,6 +25,7 @@
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/blkdev.h>
+#include <linux/swapctl.h>
 
 #include <asm/system.h>
 #include <asm/pgtable.h>
@@ -158,12 +159,15 @@
 
 		switch (atomic_read(&page->count)) {
 			case 1:
-				/* If it has been referenced recently, don't free it */
-				if (test_and_clear_bit(PG_referenced, &page->flags))
-					break;
-
 				/* is it a page cache page? */
 				if (page->inode) {
+					if (test_and_clear_bit(PG_referenced, &page->flags)) {
+						touch_page(page);
+						break;
+					}
+					age_page(page);
+					if (page->age)
+						break;
 					if (page->inode == &swapper_inode)
 						panic ("Shrinking a swap cache page");
 					remove_page_from_hash_queue(page);
@@ -171,6 +175,10 @@
 					__free_page(page);
 					return 1;
 				}
+
+				/* If it has been referenced recently, don't free it */
+				if (test_and_clear_bit(PG_referenced, &page->flags))
+					break;
 
 				/* is it a buffer cache page? */
 				if ((gfp_mask & __GFP_IO) && bh && try_to_free_buffer(bh, &bh, 6))
