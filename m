Date: Sun, 5 Sep 1999 04:55:41 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: [2.2.12 PATCH] Re: bdflush defaults bugreport
In-Reply-To: <Pine.LNX.4.10.9909050953540.247-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.990905043424.27200B-100000@mole.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@humbolt.geo.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>, alan@redhat.com
List-ID: <linux-mm.kvack.org>

Hey Rik,

> yesterday evening I've seen a 32MB machine failing to install because
> mke2fs was killed due to memory shortage -- memory shortage due to
> a too large number of dirty blocks (max 40% by default).
> 
> Lowering the number to 1% solved all problems, so I guess we should
> lower the number in the kernel to something like 10%, which should
> be _more_ than enough since the page cache can now be dirty too...
> 
> Btw, the problem happened on a 2.2.10 machine, so I guess we should
> lower the 2.2 default as well (to 15%? 20%?).

I don't quite think that changing the percentage dirty is the right thing
in this case.  Rather, the semantics of refile_buffer / wakeup_bdflush /
mark_buffer_clean need to be tweaked: as it stands, bdflush will wake
bdflush_done before the percentage of dirty buffers drops below the
threshhold.  The right fix should be to move the wake_up into the if
checking the threshhold right below it as the only user of bdflush_done is
from wake_bdflush when too many buffers are dirty.  Patch below (albeit
untested).  Alan/Stephen: comments?

		-ben

--- buffer.c.orig	Mon Aug  9 15:04:40 1999
+++ buffer.c	Sun Sep  5 04:35:06 1999
@@ -1813,11 +1813,12 @@
 			continue;
 		}
 		run_task_queue(&tq_disk);
-		wake_up(&bdflush_done);
 		
 		/* If there are still a lot of dirty buffers around, skip the sleep
 		   and flush some more */
 		if(ndirty == 0 || nr_buffers_type[BUF_DIRTY] <= nr_buffers * bdf_prm.b_un.nfract/100) {
+			wake_up(&bdflush_done);
+
 			spin_lock_irq(&current->sigmask_lock);
 			flush_signals(current);
 			spin_unlock_irq(&current->sigmask_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
