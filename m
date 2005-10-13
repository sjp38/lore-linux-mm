Received: from hastur.corp.sgi.com (hastur.corp.sgi.com [198.149.32.33])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j9DIHIxT015987
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 13:17:18 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by hastur.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id j9DIHFeS202757504
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 11:17:15 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id j9DIHIsT91088651
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 11:17:18 -0700 (PDT)
Date: Thu, 13 Oct 2005 11:13:42 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Page eviction support in vmscan.c
Message-ID: <Pine.LNX.4.62.0510131109210.14810@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.62.0510131117120.14847@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lhms-devel@lists.sourceforge.net
Cc: linux-mm@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

This patch adds functions that allow the eviction of pages to swap space.
Page eviction may be useful to migrate pages, suspend programs or for
ummapping single pages (useful for faulty pages or pages with soft ECC
failures)

The process is as follows:

The function wanting to evict pages must first build a list of pages to be evicted
and take them off the lru lists. This is done using the isolate_lru_page function.
isolate_lru_page determines that a page is freeable based on the LRU bit set and
adds the page if it is indeed freeable to the list specified.
isolate_lru_page will return 0 for a page that is not freeable.

Then the actual swapout can happen by calling swapout_pages().

swapout_pages does its best to swapout the pages and does multiple passes over the list.
However, swapout_pages may not be able to evict all pages for a variety of reasons.

Remaining pages may be returned to the LRU lists using putback_lru_pages().

This patch is against 2.6.14-rc4 and was reviewed by Hugh.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc4/include/linux/swap.h
===================================================================
--- linux-2.6.14-rc4.orig/include/linux/swap.h	2005-10-10 18:19:19.000000000 -0700
+++ linux-2.6.14-rc4/include/linux/swap.h	2005-10-13 09:51:50.000000000 -0700
@@ -222,6 +222,10 @@ struct backing_dev_info;
 
 extern spinlock_t swap_lock;
 
+extern int isolate_lru_page(struct page *p, struct list_head *l);
+extern int swapout_pages(struct list_head *l);
+extern int putback_lru_pages(struct list_head *l);
+
 /* linux/mm/thrash.c */
 extern struct mm_struct * swap_token_mm;
 extern unsigned long swap_token_default_timeout;
Index: linux-2.6.14-rc4/mm/vmscan.c
===================================================================
--- linux-2.6.14-rc4.orig/mm/vmscan.c	2005-10-10 18:19:19.000000000 -0700
+++ linux-2.6.14-rc4/mm/vmscan.c	2005-10-13 09:55:21.000000000 -0700
@@ -556,6 +556,148 @@ keep:
 }
 
 /*
+ * Swapout evicts the pages on the list to swap space.
+ * This is essentially a dumbed down version of shrink_list
+ *
+ * returns the number of pages that were not evictable
+ *
+ * Multiple passes are performed over the list. The first
+ * pass avoids waiting on locks and triggers writeout
+ * actions. Later passes begin to wait on locks in order
+ * to have a better chance of acquiring the lock.
+ */
+int swapout_pages(struct list_head *l)
+{
+	int retry;
+	int failed;
+	int pass = 0;
+	struct page *page;
+	struct page *page2;
+	struct pagevec freed_pvec;
+
+	current->flags |= PF_KSWAPD;
+
+redo:
+	retry = 0;
+	failed = 0;
+	pagevec_init(&freed_pvec, 1);
+
+	list_for_each_entry_safe(page, page2, l, lru) {
+		struct address_space *mapping;
+
+		cond_resched();
+
+		/*
+		 * Skip locked pages during the first two passes to give the
+		 * functions holding the lock time to release the page. Later we use
+		 * lock_page to have a higher chance of acquiring the lock.
+		 */
+		if (pass > 1)
+			lock_page(page);
+		else
+			if (TestSetPageLocked(page))
+				goto retry_later;
+
+		/*
+		 * Only wait on writeback if we have already done a pass where
+		 * we we may have triggered writeouts for lots of pages.
+		 */
+		if (pass > 0)
+			wait_on_page_writeback(page);
+		else
+			if (PageWriteback(page))
+				goto retry_later_locked;
+
+#ifdef CONFIG_SWAP
+                if (PageAnon(page) && !PageSwapCache(page)) {
+                        if (!add_to_swap(page))
+				goto failed;
+                }
+#endif /* CONFIG_SWAP */
+
+		mapping = page_mapping(page);
+		if (page_mapped(page) && mapping)
+			if (try_to_unmap(page) != SWAP_SUCCESS)
+				goto retry_later_locked;
+
+		if (PageDirty(page)) {
+			/* Page is dirty, try to write it out here */
+			switch(pageout(page, mapping)) {
+			case PAGE_KEEP:
+			case PAGE_ACTIVATE:
+				goto retry_later_locked;
+			case PAGE_SUCCESS:
+				goto retry_later;
+			case PAGE_CLEAN:
+				; /* try to free the page below */
+			}
+                }
+
+		if (PagePrivate(page)) {
+			if (!try_to_release_page(page, GFP_KERNEL))
+				goto retry_later_locked;
+			if (!mapping && page_count(page) == 1)
+				goto free_it;
+		}
+
+		if (!mapping)
+			goto retry_later_locked;       /* truncate got there first */
+
+		write_lock_irq(&mapping->tree_lock);
+
+		if (page_count(page) != 2 || PageDirty(page)) {
+			write_unlock_irq(&mapping->tree_lock);
+			goto retry_later_locked;
+		}
+
+#ifdef CONFIG_SWAP
+		if (PageSwapCache(page)) {
+			swp_entry_t swap = { .val = page->private };
+			__delete_from_swap_cache(page);
+			write_unlock_irq(&mapping->tree_lock);
+			swap_free(swap);
+			__put_page(page);       /* The pagecache ref */
+			goto free_it;
+		}
+#endif /* CONFIG_SWAP */
+
+		__remove_from_page_cache(page);
+		write_unlock_irq(&mapping->tree_lock);
+		__put_page(page);
+
+free_it:
+		/*
+		 * We may free pages that were taken off the active list
+		 * by isolate_lru_page. However, free_hot_cold_page will check
+		 * if the active bit is set. So clear it.
+		 */
+		ClearPageActive(page);
+
+		list_del(&page->lru);
+                unlock_page(page);
+		put_page(page);
+                continue;
+
+failed:
+		failed++;
+		unlock_page(page);
+		continue;
+
+retry_later_locked:
+		unlock_page(page);
+retry_later:
+		retry++;
+	}
+	if (retry && pass++ < 10)
+		goto redo;
+
+	current->flags &= ~PF_KSWAPD;
+	if (pagevec_count(&freed_pvec))
+		__pagevec_release_nonlru(&freed_pvec);
+	return failed + retrieable;
+}
+
+/*
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
@@ -604,6 +746,62 @@ static int isolate_lru_pages(int nr_to_s
 	return nr_taken;
 }
 
+static void lru_add_drain_per_cpu(void *dummy)
+{
+	lru_add_drain();
+}
+
+/*
+ * Isolate one page from the LRU lists and put it on the
+ * indicated list.
+ *
+ * Result:
+ *  0 = page not on LRU list
+ *  1 = page removed from LRU list and added to the specified list.
+ * -1 = page is being freed elsewhere.
+ */
+int isolate_lru_page(struct page *page, struct list_head *l)
+{
+	int rc = 0;
+	struct zone *zone = page_zone(page);
+
+redo:
+	spin_lock_irq(&zone->lru_lock);
+	if (TestClearPageLRU(page)) {
+		list_del(&page->lru);
+		if (get_page_testone(page)) {
+			/*
+			 * It is being freed elsewhere
+			 */
+			__put_page(page);
+			SetPageLRU(page);
+			if (PageActive(page))
+				list_add(&page->lru, &zone->active_list);
+			else
+				list_add(&page->lru, &zone->inactive_list);
+			rc = -1;
+		} else {
+			list_add(&page->lru, l);
+			if (PageActive(page))
+				zone->nr_active--;
+			else
+				zone->nr_inactive--;
+			rc = 1;
+		}
+	}
+	spin_unlock_irq(&zone->lru_lock);
+	if (rc == 0) {
+		/*
+		 * Maybe this page is still waiting for a cpu to drain it
+		 * from one of the lru lists?
+		 */
+		smp_call_function(&lru_add_drain_per_cpu, NULL, 0 , 1);
+		if (PageLRU(page))
+			goto redo;
+	}
+	return rc;
+}
+
 /*
  * shrink_cache() adds the number of pages reclaimed to sc->nr_reclaimed
  */
@@ -670,6 +868,32 @@ done:
 }
 
 /*
+ * Add isolated pages back on the LRU lists
+ */
+int putback_lru_pages(struct list_head *l)
+{
+	struct page * page;
+	struct page * page2;
+	int count = 0;
+
+	list_for_each_entry_safe(page, page2, l, lru) {
+		struct zone *zone = page_zone(page);
+
+		spin_lock_irq(&zone->lru_lock);
+		list_del(&page->lru);
+		if (!TestSetPageLRU(page)) {
+			if (PageActive(page))
+				add_page_to_active_list(zone, page);
+			else
+				add_page_to_inactive_list(zone, page);
+			count++;
+		}
+		spin_unlock_irq(&zone->lru_lock);
+	}
+	return count;
+}
+
+/*
  * This moves pages from the active list to the inactive list.
  *
  * We move them the other way if the page is referenced by one or more

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
