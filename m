Date: Mon, 14 May 2001 19:41:00 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH] v2.4.4-ac9 highmem deadlock
Message-ID: <Pine.LNX.4.33.0105141930270.11830-100000@toomuch.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: alan@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hey folks,

The patch below consists of 3 seperate fixes for helping remove the
deadlocks present in current kernels with respect to highmem systems.
Each fix is to a seperate file, so please accept/reject as such.

The first patch adding __GFP_FAIL to GFP_BUFFER is needed to fix a
livelock caused by the kswapd -> swap out -> create_page_buffers ->
GFP_BUFFER allocation -> waits for kswapd to wake up and free memory code
path.

Second patch (to highmem.c) silences the critical shortage messages that
make viewing any console output impossible, as well as managing to slow
the machine down to a crawl when running with a serial console.

The third patch (to vmscan.c) adds a SCHED_YIELD to the page launder code
before starting a launder loop.  This one needs discussion, but what I'm
attempting to accomplish is that when kswapd is cycling through
page_launder repeatedly, bdflush or some other task submitting io via the
bounce buffers needs to be given a chance to run and complete their io
again.  Failure to do so limits the rate of progress under extremely high
load when the vast majority of io will be transferred via bounce buffers.

Comments?

		-ben

====start of v2.4.4-ac9-highmem-1.diff====
diff -ur v2.4.4-ac9/include/linux/mm.h work/include/linux/mm.h
--- v2.4.4-ac9/include/linux/mm.h	Mon May 14 15:22:17 2001
+++ work/include/linux/mm.h	Mon May 14 18:33:21 2001
@@ -528,7 +528,7 @@


 #define GFP_BOUNCE	(__GFP_HIGH | __GFP_FAIL)
-#define GFP_BUFFER	(__GFP_HIGH | __GFP_WAIT)
+#define GFP_BUFFER	(__GFP_HIGH | __GFP_FAIL | __GFP_WAIT)
 #define GFP_ATOMIC	(__GFP_HIGH)
 #define GFP_USER	(             __GFP_WAIT | __GFP_IO)
 #define GFP_HIGHUSER	(             __GFP_WAIT | __GFP_IO | __GFP_HIGHMEM)
diff -ur v2.4.4-ac9/mm/highmem.c work/mm/highmem.c
--- v2.4.4-ac9/mm/highmem.c	Mon May 14 14:57:00 2001
+++ work/mm/highmem.c	Mon May 14 15:39:03 2001
@@ -279,6 +279,7 @@

 struct page *alloc_bounce_page (void)
 {
+	static int buffer_warning;
 	struct list_head *tmp;
 	struct page *page;

@@ -308,7 +309,8 @@
 	if (page)
 		return page;

-	printk(KERN_WARNING "mm: critical shortage of bounce buffers.\n");
+	if (!buffer_warning++)
+		printk(KERN_WARNING "mm: critical shortage of bounce buffers.\n");


 	current->policy |= SCHED_YIELD;
@@ -319,6 +321,7 @@

 struct buffer_head *alloc_bounce_bh (void)
 {
+	static int bh_warning;
 	struct list_head *tmp;
 	struct buffer_head *bh;

@@ -348,7 +351,8 @@
 	if (bh)
 		return bh;

-	printk(KERN_WARNING "mm: critical shortage of bounce bh's.\n");
+	if (!bh_warning++)
+		printk(KERN_WARNING "mm: critical shortage of bounce bh's.\n");


 	current->policy |= SCHED_YIELD;
diff -ur v2.4.4-ac9/mm/vmscan.c work/mm/vmscan.c
--- v2.4.4-ac9/mm/vmscan.c	Mon May 14 14:57:00 2001
+++ work/mm/vmscan.c	Mon May 14 16:43:05 2001
@@ -636,6 +636,12 @@
 	 */
 	shortage = free_shortage();
 	if (can_get_io_locks && !launder_loop && shortage) {
+		if (gfp_mask & __GFP_WAIT) {
+			__set_current_state(TASK_RUNNING);
+			current->policy |= SCHED_YIELD;
+			schedule();
+		}
+
 		launder_loop = 1;

 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
