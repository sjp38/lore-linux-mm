Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA23725
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 02:23:34 -0700 (PDT)
Message-ID: <3D7C6C0A.1BBEBB2D@digeo.com>
Date: Mon, 09 Sep 2002 02:38:18 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] modified segq for 2.5
References: <Pine.LNX.4.44L.0208151119190.23404-100000@imladris.surriel.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: William Lee Irwin III <wli@holomorphy.com>, sfkaplan@cs.amherst.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> Hi,
> 
> here is a patch that implements a modified SEGQ replacement
> for the 2.5 kernel.
> 
> - new pages start out on the active list
> - once a page reaches the end of the active list:
>   - if it is (mapped && referenced) it goes to the front of the active list
>   - otherwise, it gets moved to the front of the inactive list
> - linear IO drops pages to the inactive list after it is done with them
> - once a page reaches the end of the inactive list:
>   - if it is referenced, it goes to the front of the active list
>   - otherwise, it is reclaimed
> 
> This means accesses to not mapped pagecache pages while that
> page is on the active list get ignored, while accesses to
> process pages on the active list get counted.  I hope this
> bias will help keeping the working set of processes in RAM.
> 
> (note that the patch was made against 2.5.29, but it should be
> trivial to port to newer kernels)
> 
>


I ported this up.  The below patch applies with or without my recent
vmscan.c maulings.

I haven't really had time to test it much.  Running `make -j6 dep'
on a setup where userspace has 14M available seems to be in the
operating region.  That's fairly swappy but not ridiculously so.

Didn't seem to make much difference in that particular dot on the
spectrum.  105 seconds all up.   2.4.19 does it in 80 or so, but
I wasn't very careful in making sure that both kernels had the
same available memory - half a meg here or there could make a big
difference.

I fiddled with it a bit:  did you forget to move the write(2) pages
to the inactive list?  I changed it to do that at IO completion.
It had little effect.  Probably should be looking at the page state
before doing that.

One thing this patch did do was to speed up the initial untar of
the kernel source - 50 seconds down to 25.  That'll be due to not
having so much dirt on the inactive list.  The "nonblocking page
reclaim" code (needs a better name...) does that in 18 secs.

The inactive list was smaller with this patch.  Around 10%
of allocatable memory usually.

btw, I've added the `page_mapped()' helper to replace open-coded
testing of page->pte.chain.  Because with highpte and HIGHMEM_64G,
page->pte.chain is wrong.  pte.direct is 64-bit and we need to
test all those bits to see if the page is in pagetables.

With nonblocking-vm and slabasap, the test took 150 seconds.
Removing slabasap took it down to 98 seconds.  The slab rework
seemed to leave an extra megabyte average in cache.  Which is not
to say that the algorithms in there are wrong, but perhaps we should
push it a bit harder if there's swapout pressure.

And the fact that a meg makes that much difference indicates that it's
right on the knee of the curve and perhaps not a very interesting test.

I like the way in which the patch improves the reclaim success rate.
It went from 50% to 80 or 90%.

It worries me that the inactive list is so small.  But I need to
test it more.

(This patch looks a lot like NRU - what's the difference?)

 include/linux/mm_inline.h |    9 ++++++++
 include/linux/pagevec.h   |    7 ++++++
 mm/filemap.c              |   14 +++----------
 mm/readahead.c            |   46 +++++++++++++++++++++++++++++++++++++++++++
 mm/rmap.c                 |    4 +++
 mm/swap.c                 |   49 +++++++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c               |    8 +++++--
 7 files changed, 124 insertions(+), 13 deletions(-)

--- 2.5.33/mm/filemap.c~segq	Mon Sep  9 01:44:49 2002
+++ 2.5.33-akpm/mm/filemap.c	Mon Sep  9 02:03:48 2002
@@ -24,6 +24,8 @@
 #include <linux/writeback.h>
 #include <linux/pagevec.h>
 #include <linux/security.h>
+#include <linux/mm_inline.h>
+
 /*
  * This is needed for the following functions:
  *  - try_to_release_page
@@ -685,6 +687,7 @@ void end_page_writeback(struct page *pag
 	smp_mb__after_clear_bit(); 
 	if (waitqueue_active(waitqueue))
 		wake_up_all(waitqueue);
+	deactivate_page(page);
 }
 EXPORT_SYMBOL(end_page_writeback);
 
@@ -868,20 +871,11 @@ grab_cache_page_nowait(struct address_sp
 
 /*
  * Mark a page as having seen activity.
- *
- * inactive,unreferenced	->	inactive,referenced
- * inactive,referenced		->	active,unreferenced
- * active,unreferenced		->	active,referenced
  */
 void mark_page_accessed(struct page *page)
 {
-	if (!PageActive(page) && PageReferenced(page)) {
-		activate_page(page);
-		ClearPageReferenced(page);
-		return;
-	} else if (!PageReferenced(page)) {
+	if (!PageReferenced(page))
 		SetPageReferenced(page);
-	}
 }
 
 /*
--- 2.5.33/mm/readahead.c~segq	Mon Sep  9 01:44:49 2002
+++ 2.5.33-akpm/mm/readahead.c	Mon Sep  9 01:44:49 2002
@@ -213,6 +213,45 @@ check_ra_success(struct file_ra_state *r
 }
 
 /*
+ * Since we're less likely to use the pages we've already read than the pages
+ * we're about to read we move the pages from the past window to the inactive
+ * list.
+ */
+static void
+drop_behind(struct address_space *mapping, pgoff_t offset, unsigned long size)
+{
+	unsigned long page_idx;
+	unsigned long lower_limit = 0;
+	struct page *page;
+	struct pagevec pvec;
+
+	/* We're re-using already present data or just started reading. */
+	if (size == -1UL || offset == 0)
+		return;
+
+	if (offset > size)
+		lower_limit = offset - size;
+
+	pagevec_init(&pvec);
+	read_lock(&mapping->page_lock);
+	for (page_idx = offset; page_idx > lower_limit; page_idx--) {
+		page = radix_tree_lookup(&mapping->page_tree, page_idx);
+
+		if (!page || (!PageActive(page) && !PageReferenced(page)))
+			break;
+
+		page_cache_get(page);
+		if (!pagevec_add(&pvec, page)) {
+			read_unlock(&mapping->page_lock);
+			__pagevec_deactivate_active(&pvec);
+			read_lock(&mapping->page_lock);
+		}
+	}
+	read_unlock(&mapping->page_lock);
+	pagevec_deactivate_active(&pvec);
+}
+
+/*
  * page_cache_readahead is the main function.  If performs the adaptive
  * readahead window size management and submits the readahead I/O.
  */
@@ -296,6 +335,13 @@ void page_cache_readahead(struct file *f
 			ra->ahead_start = 0;
 			ra->ahead_size = 0;
 			/*
+			 * Drop the pages from the old window into the
+			 * inactive list.
+			 */
+			drop_behind(file->f_dentry->d_inode->i_mapping,
+					offset, ra->size);
+
+			/*
 			 * Control now returns, probably to sleep until I/O
 			 * completes against the first ahead page.
 			 * When the second page in the old ahead window is
--- 2.5.33/include/linux/pagevec.h~segq	Mon Sep  9 01:44:49 2002
+++ 2.5.33-akpm/include/linux/pagevec.h	Mon Sep  9 01:44:49 2002
@@ -18,6 +18,7 @@ void __pagevec_release(struct pagevec *p
 void __pagevec_release_nonlru(struct pagevec *pvec);
 void __pagevec_free(struct pagevec *pvec);
 void __pagevec_lru_add(struct pagevec *pvec);
+void __pagevec_deactivate_active(struct pagevec *pvec);
 void lru_add_drain(void);
 void pagevec_deactivate_inactive(struct pagevec *pvec);
 void pagevec_strip(struct pagevec *pvec);
@@ -69,3 +70,9 @@ static inline void pagevec_lru_add(struc
 	if (pagevec_count(pvec))
 		__pagevec_lru_add(pvec);
 }
+
+static inline void pagevec_deactivate_active(struct pagevec *pvec)
+{
+	if (pagevec_count(pvec))
+		__pagevec_deactivate_active(pvec);
+}
--- 2.5.33/mm/swap.c~segq	Mon Sep  9 01:44:49 2002
+++ 2.5.33-akpm/mm/swap.c	Mon Sep  9 01:44:49 2002
@@ -196,6 +196,38 @@ void pagevec_deactivate_inactive(struct 
 }
 
 /*
+ * Move all the active pages to the head of the inactive list and release them.
+ * Reinitialises the caller's pagevec.
+ */
+void __pagevec_deactivate_active(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (!PageActive(page) || !PageLRU(page))
+				continue;
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		if (PageActive(page) && PageLRU(page)) {
+			del_page_from_active_list(zone, page);
+			ClearPageActive(page);
+			add_page_to_inactive_list(zone, page);
+		}
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	__pagevec_release(pvec);
+}
+
+/*
  * Add the passed pages to the inactive_list, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
@@ -216,7 +248,8 @@ void __pagevec_lru_add(struct pagevec *p
 		}
 		if (TestSetPageLRU(page))
 			BUG();
-		add_page_to_inactive_list(zone, page);
+		add_page_to_active_list(zone, page);
+		SetPageActive(page);
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
@@ -240,6 +273,20 @@ void pagevec_strip(struct pagevec *pvec)
 	}
 }
 
+void __deactivate_page(struct page *page)
+{
+	struct zone *zone = page_zone(page);
+	unsigned long flags;
+
+	spin_lock_irqsave(&zone->lru_lock, flags);
+	if (PageLRU(page) && PageActive(page)) {
+		del_page_from_active_list(zone, page);
+		ClearPageActive(page);
+		add_page_to_inactive_list(zone, page);
+	}
+	spin_unlock_irqrestore(&zone->lru_lock, flags);
+}
+
 /*
  * Perform any setup for the swap system
  */
--- 2.5.33/mm/vmscan.c~segq	Mon Sep  9 01:44:49 2002
+++ 2.5.33-akpm/mm/vmscan.c	Mon Sep  9 01:44:49 2002
@@ -126,7 +126,7 @@ shrink_list(struct list_head *page_list,
 		}
 
 		pte_chain_lock(page);
-		if (page_referenced(page) && page_mapping_inuse(page)) {
+		if (page_referenced(page)) {
 			/* In active use or really unfreeable.  Activate it. */
 			pte_chain_unlock(page);
 			goto activate_locked;
@@ -411,9 +411,13 @@ refill_inactive_zone(struct zone *zone, 
 	while (!list_empty(&l_hold)) {
 		page = list_entry(l_hold.prev, struct page, lru);
 		list_del(&page->lru);
+		if (TestClearPageReferenced(page)) {
+			list_add(&page->lru, &l_active);
+			continue;
+		}
 		if (page_mapped(page)) {
 			pte_chain_lock(page);
-			if (page_mapped(page) && page_referenced(page)) {
+			if (page_referenced(page) && page_mapping_inuse(page)) {
 				pte_chain_unlock(page);
 				list_add(&page->lru, &l_active);
 				continue;
--- 2.5.33/mm/rmap.c~segq	Mon Sep  9 01:44:49 2002
+++ 2.5.33-akpm/mm/rmap.c	Mon Sep  9 01:44:49 2002
@@ -125,6 +125,9 @@ int page_referenced(struct page * page)
 	if (TestClearPageReferenced(page))
 		referenced++;
 
+	if (!page_mapped(page))
+		goto out;
+
 	if (PageDirect(page)) {
 		pte_t *pte = rmap_ptep_map(page->pte.direct);
 		if (ptep_test_and_clear_young(pte))
@@ -158,6 +161,7 @@ int page_referenced(struct page * page)
 			pte_chain_free(pc);
 		}
 	}
+out:
 	return referenced;
 }
 
--- 2.5.33/include/linux/mm_inline.h~segq	Mon Sep  9 01:44:49 2002
+++ 2.5.33-akpm/include/linux/mm_inline.h	Mon Sep  9 01:44:49 2002
@@ -38,3 +38,12 @@ del_page_from_lru(struct zone *zone, str
 		zone->nr_inactive--;
 	}
 }
+
+
+void __deactivate_page(struct page *page);
+
+static inline void deactivate_page(struct page *page)
+{
+	if (PageLRU(page) && PageActive(page))
+		__deactivate_page(page);
+}

.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
