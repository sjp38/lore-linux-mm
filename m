Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6EDDE6B0087
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 01:04:55 -0500 (EST)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN; charset=US-ASCII
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR003.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KFY00G2IWL1F860@VL-MO-MR003.ip.videotron.ca> for
 linux-mm@kvack.org; Wed, 04 Mar 2009 00:58:13 -0500 (EST)
Date: Wed, 04 Mar 2009 00:58:13 -0500 (EST)
From: Nicolas Pitre <nico@cam.org>
Subject: [RFC] atomic highmem kmap page pinning
Message-id: <alpine.LFD.2.00.0903040014140.5511@xanadu.home>
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>
List-ID: <linux-mm.kvack.org>

I've implemented highmem for ARM.  Yes, some ARM machines do have lots 
of memory...

The problem is that most ARM machines have a non IO coherent cache, 
meaning that the dma_map_* set of functions must clean and/or invalidate 
the affected memory manually.  And because the majority of those 
machines have a VIVT cache, the cache maintenance operations must be 
performed using virtual addresses.

In dma_map_page(), an highmem pages could still be mapped and cached 
even after kunmap() was called on it.  As long as highmem pages are 
mapped, page_address(page) is non null and we can use that to 
synchronize the cache.

It is unlikely but still possible for kmap() to race and recycle the 
obtained virtual address above, and use it for another page though.  In 
that case, the new mapping could end up with dirty cache lines for 
another page, and the unsuspecting cache invalidation loop in 
dma_map_page() won't notice resulting in data loss.  Hence the need for 
some kind of kmap page pinning which can be used in any context, 
including IRQ context.

This is a RFC patch implementing the necessary part in the core code, as 
suggested by RMK. Please comment.

diff --git a/mm/highmem.c b/mm/highmem.c
index b36b83b..548ca77 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -113,9 +113,9 @@ static void flush_all_zero_pkmaps(void)
  */
 void kmap_flush_unused(void)
 {
-	spin_lock(&kmap_lock);
+	spin_lock_irq(&kmap_lock);
 	flush_all_zero_pkmaps();
-	spin_unlock(&kmap_lock);
+	spin_unlock_irq(&kmap_lock);
 }
 
 static inline unsigned long map_new_virtual(struct page *page)
@@ -145,10 +145,10 @@ start:
 
 			__set_current_state(TASK_UNINTERRUPTIBLE);
 			add_wait_queue(&pkmap_map_wait, &wait);
-			spin_unlock(&kmap_lock);
+			spin_unlock_irq(&kmap_lock);
 			schedule();
 			remove_wait_queue(&pkmap_map_wait, &wait);
-			spin_lock(&kmap_lock);
+			spin_lock_irq(&kmap_lock);
 
 			/* Somebody else might have mapped it while we slept */
 			if (page_address(page))
@@ -184,19 +184,43 @@ void *kmap_high(struct page *page)
 	 * For highmem pages, we can't trust "virtual" until
 	 * after we have the lock.
 	 */
-	spin_lock(&kmap_lock);
+	spin_lock_irq(&kmap_lock);
 	vaddr = (unsigned long)page_address(page);
 	if (!vaddr)
 		vaddr = map_new_virtual(page);
 	pkmap_count[PKMAP_NR(vaddr)]++;
 	BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 2);
-	spin_unlock(&kmap_lock);
+	spin_unlock_irq(&kmap_lock);
 	return (void*) vaddr;
 }
 
 EXPORT_SYMBOL(kmap_high);
 
 /**
+ * kmap_high_get - pin a highmem page into memory
+ * @page: &struct page to pin
+ *
+ * Returns the page's current virtual memory address, or NULL if no mapping
+ * exists.  When and only when a non null address is returned then a
+ * matching call to kunmap_high() is necessary.
+ *
+ * This can be called from interrupt context.
+ */
+void *kmap_high_get(struct page *page)
+{
+	unsigned long vaddr, flags;
+
+	spin_lock_irqsave(&kmap_lock, flags);
+	vaddr = (unsigned long)page_address(page);
+	if (vaddr) {
+		BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 1);
+		pkmap_count[PKMAP_NR(vaddr)]++;
+	}
+	spin_unlock_irqrestore(&kmap_lock, flags);
+	return (void*) vaddr;
+}
+
+/**
  * kunmap_high - map a highmem page into memory
  * @page: &struct page to unmap
  */
@@ -204,9 +228,10 @@ void kunmap_high(struct page *page)
 {
 	unsigned long vaddr;
 	unsigned long nr;
+	unsigned long flags;
 	int need_wakeup;
 
-	spin_lock(&kmap_lock);
+	spin_lock_irqsave(&kmap_lock, flags);
 	vaddr = (unsigned long)page_address(page);
 	BUG_ON(!vaddr);
 	nr = PKMAP_NR(vaddr);
@@ -232,7 +257,7 @@ void kunmap_high(struct page *page)
 		 */
 		need_wakeup = waitqueue_active(&pkmap_map_wait);
 	}
-	spin_unlock(&kmap_lock);
+	spin_unlock_irqrestore(&kmap_lock, flags);
 
 	/* do wake-up, if needed, race-free outside of the spin lock */
 	if (need_wakeup)


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
