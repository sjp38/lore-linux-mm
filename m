Received: (from arjanv@localhost)
	by devserv.devel.redhat.com (8.11.0/8.11.0) id f7SGCt918560
	for linux-mm@kvack.org; Tue, 28 Aug 2001 12:12:55 -0400
Resent-Message-Id: <200108281612.f7SGCt918560@devserv.devel.redhat.com>
Date: Tue, 28 Aug 2001 11:17:34 -0400
From: Arjan van de Ven <arjanv@redhat.com>
Subject: vm patch for highmem 
Message-ID: <20010828111734.A5857@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Resent-To: linux-mm@kvack.org
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hi

The patch below changes the highmem bouncebuffers to increase performance.
Initial reports are that it matters A LOT.

What it does: it 1) increases the emergemcy pool and 2) it tries to grab a
page from the pool for EVERY bounce first, until the pool is half empty, and
only THEN does it try to get a page from the VM.
While this penalizes the low zone by making it have less pages, it also
leaves the VM totally alone for normal loads; only under more extreme loads
does the vm get involved.

Comments?

Greetings,
   Arjan van de Ven

--- linux/mm/highmem.c.org	Thu Aug 23 09:23:11 2001
+++ linux/mm/highmem.c	Thu Aug 23 10:21:33 2001
@@ -159,7 +159,11 @@
 	spin_unlock(&kmap_lock);
 }
 
-#define POOL_SIZE 32
+#ifdef CONFIG_HIGHMEM64G
+#define POOL_SIZE 256
+#else
+#define POOL_SIZE 64
+#endif
 
 /*
  * This lock gets no contention at all, normally.
@@ -306,10 +310,24 @@
 struct page *alloc_bounce_page (void)
 {
 	struct list_head *tmp;
-	struct page *page;
+	struct page *page = NULL;
+	int estimated_left;
+	int iteration=0;
 
 repeat_alloc:
-	page = alloc_page(GFP_NOIO);
+
+	spin_lock_irq(&emergency_lock);
+	estimated_left = nr_emergency_pages;
+	spin_unlock_irq(&emergency_lock);
+
+	/* If there are plenty of spare pages, use some of them first. If the
+	   pool is at least half depleted, use the VM to allocate memory.
+	   This allows moderate loads to continue without blocking here,
+	   while higher loads get throttled by the VM.
+        */
+	if ((estimated_left<=POOL_SIZE/2)&&(!iteration))
+		page = alloc_page(GFP_NOIO);
+	
 	if (page)
 		return page;
 	/*
@@ -338,16 +356,30 @@
 	current->policy |= SCHED_YIELD;
 	__set_current_state(TASK_RUNNING);
 	schedule();
+	iteration++;
 	goto repeat_alloc;
 }
 
 struct buffer_head *alloc_bounce_bh (void)
 {
 	struct list_head *tmp;
-	struct buffer_head *bh;
+	struct buffer_head *bh = NULL;
+	int estimated_left;
+	int iteration=0;
 
 repeat_alloc:
-	bh = kmem_cache_alloc(bh_cachep, SLAB_NOIO);
+
+	spin_lock_irq(&emergency_lock);
+	estimated_left = nr_emergency_bhs;
+	spin_unlock_irq(&emergency_lock);
+
+	/* If there are plenty of spare bh's, use some of them first. If the
+	   pool is at least half depleted, use the VM to allocate memory.
+	   This allows moderate loads to continue without blocking here,
+	   while higher loads get throttled by the VM.
+        */
+	if ((estimated_left<=POOL_SIZE/2)&&(!iteration))
+		bh = kmem_cache_alloc(bh_cachep, SLAB_NOIO);
 	if (bh)
 		return bh;
 	/*
@@ -376,6 +408,7 @@
 	current->policy |= SCHED_YIELD;
 	__set_current_state(TASK_RUNNING);
 	schedule();
+	iteration++;
 	goto repeat_alloc;
 }
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
