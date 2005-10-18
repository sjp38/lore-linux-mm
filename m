Date: Mon, 17 Oct 2005 17:49:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20051018004937.3191.42181.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
References: <20051018004932.3191.30603.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/2] Page migration via Swap V2: Page Eviction
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, lhms-devel@lists.sourceforge.net, ak@suse.de, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

This patch adds functions that allow the eviction of pages to swap space.
Page eviction may be useful to migrate pages, to suspend programs or for
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

The remaining pages may be returned to the LRU lists using putback_lru_pages().

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc4-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.14-rc4-mm1.orig/include/linux/swap.h	2005-10-17 10:24:16.000000000 -0700
+++ linux-2.6.14-rc4-mm1/include/linux/swap.h	2005-10-17 17:29:49.000000000 -0700
@@ -176,6 +176,10 @@ extern int zone_reclaim(struct zone *, u
 extern int shrink_all_memory(int);
 extern int vm_swappiness;
 
+extern int isolate_lru_page(struct page *p, struct list_head *l);
+extern int swapout_pages(struct list_head *l);
+extern int putback_lru_pages(struct list_head *l);
+
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
 extern int shmem_unuse(swp_entry_t entry, struct page *page);
Index: linux-2.6.14-rc4-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.14-rc4-mm1.orig/mm/vmscan.c	2005-10-17 10:24:30.000000000 -0700
+++ linux-2.6.14-rc4-mm1/mm/vmscan.c	2005-10-17 16:19:21.000000000 -0700
@@ -564,6 +564,144 @@ keep:
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
+
+	current->flags |= PF_KSWAPD;
+
+redo:
+	retry = 0;
+	failed = 0;
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
+		if (pass > 2)
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
+		if (PageAnon(page) && !PageSwapCache(page)) {
+			if (!add_to_swap(page))
+				goto failed;
+		}
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
+		}
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
+		unlock_page(page);
+		put_page(page);
+		continue;
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
+	return failed + retry;
+}
+
+/*
  * zone->lru_lock is heavily contended.  Some of the functions that
  * shrink the lists perform better by taking out a batch of pages
  * and working on them outside the LRU lock.
@@ -612,6 +750,63 @@ static int isolate_lru_pages(int nr_to_s
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
+		smp_call_function(&lru_add_drain_per_cpu, NULL, 0, 1);
+		lru_add_drain();
+		if (PageLRU(page))
+			goto redo;
+	}
+	return rc;
+}
+
 /*
  * shrink_cache() adds the number of pages reclaimed to sc->nr_reclaimed
  */
@@ -678,6 +873,32 @@ done:
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
