Date: Sat, 4 Aug 2001 00:34:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108032318330.14842-100000@touchme.toronto.redhat.com>
Message-ID: <Pine.LNX.4.33L.0108040032030.2526-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, Daniel Phillips <phillips@bonn-fries.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2001, Ben LaHaise wrote:

> See, after applying this patch, it no longer deadlocks on io.  The
> jerky interactive performance still exists,

Would something like this help ?

(yes, there's a small SMP race, but since the system survives
the starvation bug today that isn't critical)


--- ./ll_rw_blk.c.batch	Sat Aug  4 00:30:55 2001
+++ ./ll_rw_blk.c	Sat Aug  4 00:33:48 2001
@@ -1031,15 +1031,19 @@

 	for (i = 0; i < nr; i++) {
 		struct buffer_head *bh = bhs[i];
+		static int queued_sector_waiters;

 		/*
 		 * don't lock any more buffers if we are above the high
 		 * water mark. instead start I/O on the queued stuff.
 		 */
-		if (atomic_read(&queued_sectors) >= high_queued_sectors) {
+		if (atomic_read(&queued_sectors) >= high_queued_sectors
+				|| queued_sector_waiters) {
 			run_task_queue(&tq_disk);
+			queued_sector_waiters = 1;
 			wait_event(blk_buffers_wait,
 			 atomic_read(&queued_sectors) < low_queued_sectors);
+			queued_sector_waiters = 0;
 		}

 		/* Only one thread can actually submit the I/O. */


Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
