Date: Fri, 3 Aug 2001 23:26:54 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [RFC][DATA] re "ongoing vm suckage"
In-Reply-To: <Pine.LNX.4.33.0108032003200.15155-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33.0108032318330.14842-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Phillips <phillips@bonn-fries.net>, Rik van Riel <riel@conectiva.com.br>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Aug 2001, Linus Torvalds wrote:

> Please just remove the code instead. I don't think it buys you anything.

No.  Here's the bug in the block layer that was causing the throttling not
to work.  Leave the logic in, it has good reason -- think of batching of
io, where you don't want to add just one page at a time.  Bah.  Get some
diagnostics to backup the assertions first, that's the whole point I'm
arguing for.

See, after applying this patch, it no longer deadlocks on io.  The jerky
interactive performance still exists, but it's now sync_page_buffers
that's waiting too long.  That can be fixed by waiting for writes to
complete, which blk_buffers_wait is quite useful for.

		-ben

diff -ur v2.4.7/drivers/block/ll_rw_blk.c vm-2.4.7/drivers/block/ll_rw_blk.c
--- v2.4.7/drivers/block/ll_rw_blk.c	Sun Jul 22 19:17:15 2001
+++ vm-2.4.7/drivers/block/ll_rw_blk.c	Fri Aug  3 20:03:39 2001
@@ -122,14 +122,14 @@
  * queued sectors for all devices, used to make sure we don't fill all
  * of memory with locked buffers
  */
+DECLARE_WAIT_QUEUE_HEAD(blk_buffers_wait);
 atomic_t queued_sectors;

 /*
  * high and low watermark for above
  */
-static int high_queued_sectors, low_queued_sectors;
+int high_queued_sectors, low_queued_sectors;
 static int batch_requests, queue_nr_requests;
-static DECLARE_WAIT_QUEUE_HEAD(blk_buffers_wait);

 static inline int get_max_sectors(kdev_t dev)
 {
diff -ur v2.4.7/include/linux/blkdev.h vm-2.4.7/include/linux/blkdev.h
--- v2.4.7/include/linux/blkdev.h	Fri Aug  3 16:07:23 2001
+++ vm-2.4.7/include/linux/blkdev.h	Fri Aug  3 20:04:07 2001
@@ -176,7 +176,9 @@

 extern int * max_segments[MAX_BLKDEV];

+extern wait_queue_head_t blk_buffers_wait;
 extern atomic_t queued_sectors;
+extern int low_queued_sectors;

 #define MAX_SEGMENTS 128
 #define MAX_SECTORS 255
@@ -205,12 +207,15 @@
 		return 512;
 }

-#define blk_finished_io(nsects)				\
+#define blk_finished_io(nsects) do {			\
 	atomic_sub(nsects, &queued_sectors);		\
 	if (atomic_read(&queued_sectors) < 0) {		\
 		printk("block: queued_sectors < 0\n");	\
 		atomic_set(&queued_sectors, 0);		\
-	}
+	}						\
+	if (atomic_read(&queued_sectors) < low_queued_sectors) \
+		wake_up(&blk_buffers_wait);		\
+} while (0)

 #define blk_started_io(nsects)				\
 	atomic_add(nsects, &queued_sectors);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
