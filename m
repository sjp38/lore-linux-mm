Received: (from arjanv@localhost)
	by devserv.devel.redhat.com (8.11.0/8.11.0) id f3SLZGM13206
	for linux-mm@kvack.org; Sat, 28 Apr 2001 17:35:16 -0400
Resent-Message-Id: <200104282135.f3SLZGM13206@devserv.devel.redhat.com>
Date: Sat, 28 Apr 2001 17:06:48 -0400
From: Arjan van de Ven <arjanv@redhat.com>
Subject: RFC: Bouncebuffer fixes
Message-ID: <20010428170648.A10582@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Resent-To: linux-mm@kvack.org
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@nl.linux.org
Cc: alan@lxorguk.ukuu.org.uk
List-ID: <linux-mm.kvack.org>

Hi,

The following patch changes the emergency-bouncebuffer pool as present in
2.4.3-ac to be 1) bigger and 2) half reserved for threads with PF_MEMALLOC.
2) is needed to make sure that the vm kernelthreads actually can allocate 
bouncebuffers if they need to free memory. The original code gave out
all emergency bouncebuffers to anyone, even to reads from "random" user
threads.


--- linux/mm/highmem.c.org	Fri Apr 27 21:40:49 2001
+++ linux/mm/highmem.c	Fri Apr 27 21:43:41 2001
@@ -160,7 +160,7 @@
 	spin_unlock(&kmap_lock);
 }
 
-#define POOL_SIZE 32
+#define POOL_SIZE 64
 
 /*
  * This lock gets no contention at all, normally.
@@ -294,7 +294,7 @@
 	 */
 	tmp = &emergency_pages;
 	spin_lock_irq(&emergency_lock);
-	if (!list_empty(tmp)) {
+	if (!list_empty(tmp) && ((current->flags&PF_MEMALLOC)||(nr_emergency_pages>POOL_SIZE/2))) {
 		page = list_entry(tmp->next, struct page, list);
 		list_del(tmp->next);
 		nr_emergency_pages--;
@@ -337,7 +337,7 @@
 	 */
 	tmp = &emergency_bhs;
 	spin_lock_irq(&emergency_lock);
-	if (!list_empty(tmp)) {
+	if (!list_empty(tmp) && ((current->flags&PF_MEMALLOC)||(nr_emergency_bhs>POOL_SIZE/2))) {
 		bh = list_entry(tmp->next, struct buffer_head, b_inode_buffers);
 		list_del(tmp->next);
 		nr_emergency_bhs--;


The following patch, incremental to the previous one, removes
flush_dirty_buffers() from alloc_bounce_buffers to prevent the following
recursion:
bdflsh->flush_dirty_buffers->ll_rw_block->submit_bh->generic_make_request->
__make_request->create_bounce->alloc_bounce_page->flush_dirty_buffers

It also makes sure the tq_disk queue is run everytime an emergency
bouncebuffer is used, instead of only in the event we are out of
emergency buffers. If we are using emergency bounce-buffers, we should
start any pending physical IO asap.

--- linux/mm/highmem.c.org	Sat Apr 28 18:40:52 2001
+++ linux/mm/highmem.c	Sat Apr 28 19:02:54 2001
@@ -285,9 +285,9 @@
 	 * No luck. First, try to flush some low memory buffers.
 	 * This will throttle highmem writes when low memory gets full.
 	 */
-	flush_dirty_buffers(0, 1);
 
 	wakeup_bdflush(0);
+	run_task_queue(&tq_disk);
 
 	/*
 	 * Try to allocate from the emergency pool.
@@ -306,7 +306,6 @@
 	if (!buffer_warned++)
 		printk(KERN_WARNING "mm: critical shortage of bounce buffers.\n");
 
-	run_task_queue(&tq_disk);
 
 	current->policy |= SCHED_YIELD;
 	__set_current_state(TASK_RUNNING);
@@ -328,9 +327,9 @@
 	 * No luck. First, try to flush some low memory buffers.
 	 * This will throttle highmem writes when low memory gets full.
 	 */
-	flush_dirty_buffers(0, 1);
 	
 	wakeup_bdflush(0);
+	run_task_queue(&tq_disk);
 
 	/*
 	 * Try to allocate from the emergency pool.
@@ -349,7 +348,6 @@
 	if (!bh_warned++)
 		printk(KERN_WARNING "mm: critical shortage of bounce bh's.\n");
 
-	run_task_queue(&tq_disk);
 
 	current->policy |= SCHED_YIELD;
 	__set_current_state(TASK_RUNNING);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
