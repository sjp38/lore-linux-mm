Received: (from arjanv@localhost)
	by devserv.devel.redhat.com (8.11.0/8.11.0) id f3T7qkZ14488
	for linux-mm@kvack.org; Sun, 29 Apr 2001 03:52:46 -0400
Resent-Message-Id: <200104290752.f3T7qkZ14488@devserv.devel.redhat.com>
Date: Sun, 29 Apr 2001 02:07:57 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: RFC: Bouncebuffer fixes
Message-ID: <20010429020757.C816@athlon.random>
References: <20010428170648.A10582@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010428170648.A10582@devserv.devel.redhat.com>; from arjanv@redhat.com on Sat, Apr 28, 2001 at 05:06:48PM -0400
Resent-To: linux-mm@kvack.org
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm@nl.linux.org, alan@lxorguk.ukuu.org.uk, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 28, 2001 at 05:06:48PM -0400, Arjan van de Ven wrote:
> Hi,
> 
> The following patch changes the emergency-bouncebuffer pool as present in
> 2.4.3-ac to be 1) bigger and 2) half reserved for threads with PF_MEMALLOC.
> 2) is needed to make sure that the vm kernelthreads actually can allocate 
> bouncebuffers if they need to free memory. The original code gave out

it is _not_ needed. If an emergency entry was used, we also have the
guarantee that it will be released soon after we unplug the tq_disk.
This is the *whole* point of the emergency pool and *why* it fixes the
deadlock.  So it's perfectly ok to unplug tq_disk and wait for it to be
released as we do right now.

> The following patch, incremental to the previous one, removes
> flush_dirty_buffers() from alloc_bounce_buffers to prevent the following
> recursion:
> bdflsh->flush_dirty_buffers->ll_rw_block->submit_bh->generic_make_request->
> __make_request->create_bounce->alloc_bounce_page->flush_dirty_buffers

Hmm I cannot remeber any flush_dirty_buffers called by alloc_bounce_page in
any patch floating around, certainly there isn't any in my tree, so the
above recursion certainly cannot happen here.

The oom highmem bounce-buffer deadlock fix that I recomment to Linus to
merge is this one:

	ftp://ftp.us.kernel.org/pub/linux/kernel/people/andrea/kernels/v2.4/2.4.4aa1/00_highmem-deadlock-3

Nothing else is necessary to fix such deadlock as far I can tell.

Most of the credit for such fix goes to Ingo (I only audited it and
fixed a few bugs in his original patch before merging it).

I inline it in this email for Linus:

diff -urN 2.4.4/mm/highmem.c highmem-deadlock/mm/highmem.c
--- 2.4.4/mm/highmem.c	Sat Apr 28 05:24:48 2001
+++ highmem-deadlock/mm/highmem.c	Sat Apr 28 18:21:24 2001
@@ -159,6 +159,19 @@
 	spin_unlock(&kmap_lock);
 }
 
+#define POOL_SIZE 32
+
+/*
+ * This lock gets no contention at all, normally.
+ */
+static spinlock_t emergency_lock = SPIN_LOCK_UNLOCKED;
+
+int nr_emergency_pages;
+static LIST_HEAD(emergency_pages);
+
+int nr_emergency_bhs;
+static LIST_HEAD(emergency_bhs);
+
 /*
  * Simple bounce buffer support for highmem pages.
  * This will be moved to the block layer in 2.5.
@@ -203,17 +216,72 @@
 
 static inline void bounce_end_io (struct buffer_head *bh, int uptodate)
 {
+	struct page *page;
 	struct buffer_head *bh_orig = (struct buffer_head *)(bh->b_private);
+	unsigned long flags;
 
 	bh_orig->b_end_io(bh_orig, uptodate);
-	__free_page(bh->b_page);
+
+	page = bh->b_page;
+
+	spin_lock_irqsave(&emergency_lock, flags);
+	if (nr_emergency_pages >= POOL_SIZE)
+		__free_page(page);
+	else {
+		/*
+		 * We are abusing page->list to manage
+		 * the highmem emergency pool:
+		 */
+		list_add(&page->list, &emergency_pages);
+		nr_emergency_pages++;
+	}
+	
+	if (nr_emergency_bhs >= POOL_SIZE) {
 #ifdef HIGHMEM_DEBUG
-	/* Don't clobber the constructed slab cache */
-	init_waitqueue_head(&bh->b_wait);
+		/* Don't clobber the constructed slab cache */
+		init_waitqueue_head(&bh->b_wait);
 #endif
-	kmem_cache_free(bh_cachep, bh);
+		kmem_cache_free(bh_cachep, bh);
+	} else {
+		/*
+		 * Ditto in the bh case, here we abuse b_inode_buffers:
+		 */
+		list_add(&bh->b_inode_buffers, &emergency_bhs);
+		nr_emergency_bhs++;
+	}
+	spin_unlock_irqrestore(&emergency_lock, flags);
 }
 
+static __init int init_emergency_pool(void)
+{
+	spin_lock_irq(&emergency_lock);
+	while (nr_emergency_pages < POOL_SIZE) {
+		struct page * page = alloc_page(GFP_ATOMIC);
+		if (!page) {
+			printk("couldn't refill highmem emergency pages");
+			break;
+		}
+		list_add(&page->list, &emergency_pages);
+		nr_emergency_pages++;
+	}
+	while (nr_emergency_bhs < POOL_SIZE) {
+		struct buffer_head * bh = kmem_cache_alloc(bh_cachep, SLAB_ATOMIC);
+		if (!bh) {
+			printk("couldn't refill highmem emergency bhs");
+			break;
+		}
+		list_add(&bh->b_inode_buffers, &emergency_bhs);
+		nr_emergency_bhs++;
+	}
+	spin_unlock_irq(&emergency_lock);
+	printk("allocated %d pages and %d bhs reserved for the highmem bounces\n",
+	       nr_emergency_pages, nr_emergency_bhs);
+
+	return 0;
+}
+
+__initcall(init_emergency_pool);
+
 static void bounce_end_io_write (struct buffer_head *bh, int uptodate)
 {
 	bounce_end_io(bh, uptodate);
@@ -228,6 +296,82 @@
 	bounce_end_io(bh, uptodate);
 }
 
+struct page *alloc_bounce_page (void)
+{
+	struct list_head *tmp;
+	struct page *page;
+
+repeat_alloc:
+	page = alloc_page(GFP_BUFFER);
+	if (page)
+		return page;
+	/*
+	 * No luck. First, kick the VM so it doesnt idle around while
+	 * we are using up our emergency rations.
+	 */
+	wakeup_bdflush(0);
+
+	/*
+	 * Try to allocate from the emergency pool.
+	 */
+	tmp = &emergency_pages;
+	spin_lock_irq(&emergency_lock);
+	if (!list_empty(tmp)) {
+		page = list_entry(tmp->next, struct page, list);
+		list_del(tmp->next);
+		nr_emergency_pages--;
+	}
+	spin_unlock_irq(&emergency_lock);
+	if (page)
+		return page;
+
+	/* we need to wait I/O completion */
+	run_task_queue(&tq_disk);
+
+	current->policy |= SCHED_YIELD;
+	__set_current_state(TASK_RUNNING);
+	schedule();
+	goto repeat_alloc;
+}
+
+struct buffer_head *alloc_bounce_bh (void)
+{
+	struct list_head *tmp;
+	struct buffer_head *bh;
+
+repeat_alloc:
+	bh = kmem_cache_alloc(bh_cachep, SLAB_BUFFER);
+	if (bh)
+		return bh;
+	/*
+	 * No luck. First, kick the VM so it doesnt idle around while
+	 * we are using up our emergency rations.
+	 */
+	wakeup_bdflush(0);
+
+	/*
+	 * Try to allocate from the emergency pool.
+	 */
+	tmp = &emergency_bhs;
+	spin_lock_irq(&emergency_lock);
+	if (!list_empty(tmp)) {
+		bh = list_entry(tmp->next, struct buffer_head, b_inode_buffers);
+		list_del(tmp->next);
+		nr_emergency_bhs--;
+	}
+	spin_unlock_irq(&emergency_lock);
+	if (bh)
+		return bh;
+
+	/* we need to wait I/O completion */
+	run_task_queue(&tq_disk);
+
+	current->policy |= SCHED_YIELD;
+	__set_current_state(TASK_RUNNING);
+	schedule();
+	goto repeat_alloc;
+}
+
 struct buffer_head * create_bounce(int rw, struct buffer_head * bh_orig)
 {
 	struct page *page;
@@ -236,24 +380,15 @@
 	if (!PageHighMem(bh_orig->b_page))
 		return bh_orig;
 
-repeat_bh:
-	bh = kmem_cache_alloc(bh_cachep, SLAB_BUFFER);
-	if (!bh) {
-		wakeup_bdflush(1);  /* Sets task->state to TASK_RUNNING */
-		goto repeat_bh;
-	}
+	bh = alloc_bounce_bh();
 	/*
 	 * This is wasteful for 1k buffers, but this is a stopgap measure
 	 * and we are being ineffective anyway. This approach simplifies
 	 * things immensly. On boxes with more than 4GB RAM this should
 	 * not be an issue anyway.
 	 */
-repeat_page:
-	page = alloc_page(GFP_BUFFER);
-	if (!page) {
-		wakeup_bdflush(1);  /* Sets task->state to TASK_RUNNING */
-		goto repeat_page;
-	}
+	page = alloc_bounce_page();
+
 	set_bh_page(bh, page, 0);
 
 	bh->b_next = NULL;

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
