Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 2B5C76B006C
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 12:19:26 -0400 (EDT)
Subject: [PATCH 1/3 v2] mm: Batch unmapping of file mapped pages in
 shrink_page_list
From: Tim Chen <tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 10 Sep 2012 09:19:25 -0700
Message-ID: <1347293965.9977.71.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Michal Hocko <mhocko@suse.cz>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>, Matthew Wilcox <willy@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>

We gather the pages that need to be unmapped in shrink_page_list.  We batch
the unmap to reduce the frequency of acquisition of
the tree lock protecting the mapping's radix tree. This is
possible as successive pages likely share the same mapping in 
__remove_mapping_batch routine.  This avoids excessive cache bouncing of
the tree lock when page reclamations are occurring simultaneously.

Tim
---
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
--- 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index aac5672..d4ab646 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -600,6 +600,85 @@ cannot_free:
 	return 0;
 }
 
+/* Same as __remove_mapping, but batching operations to minimize locking */
+/* Pages to be unmapped should be locked first */
+static int __remove_mapping_batch(struct list_head *unmap_pages,
+				  struct list_head *ret_pages,
+				  struct list_head *free_pages)
+{
+	struct address_space *mapping, *next;
+	LIST_HEAD(swap_pages);
+	swp_entry_t swap;
+	struct page *page;
+	int nr_reclaimed;
+
+	mapping = NULL;
+	nr_reclaimed = 0;
+	while (!list_empty(unmap_pages)) {
+
+		page = lru_to_page(unmap_pages);
+		BUG_ON(!PageLocked(page));
+
+		list_del(&page->lru);
+		next = page_mapping(page);
+		if (mapping != next) {
+			if (mapping)
+				spin_unlock_irq(&mapping->tree_lock);
+			mapping = next;
+			spin_lock_irq(&mapping->tree_lock);
+		}
+
+		if (!page_freeze_refs(page, 2))
+			goto cannot_free;
+		if (unlikely(PageDirty(page))) {
+			page_unfreeze_refs(page, 2);
+			goto cannot_free;
+		}
+
+		if (PageSwapCache(page)) {
+			__delete_from_swap_cache(page);
+			/* swapcache_free need to be called without tree_lock */
+			list_add(&page->lru, &swap_pages);
+		} else {
+			void (*freepage)(struct page *);
+
+			freepage = mapping->a_ops->freepage;
+
+			__delete_from_page_cache(page);
+			mem_cgroup_uncharge_cache_page(page);
+
+			if (freepage != NULL)
+				freepage(page);
+
+			unlock_page(page);
+			nr_reclaimed++;
+			list_add(&page->lru, free_pages);
+		}
+		continue;
+cannot_free:
+		unlock_page(page);
+		list_add(&page->lru, ret_pages);
+		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
+
+	}
+
+	if (mapping)
+		spin_unlock_irq(&mapping->tree_lock);
+
+	while (!list_empty(&swap_pages)) {
+		page = lru_to_page(&swap_pages);
+		list_del(&page->lru);
+
+		swap.val = page_private(page);
+		swapcache_free(swap, page);
+
+		unlock_page(page);
+		nr_reclaimed++;
+		list_add(&page->lru, free_pages);
+	}
+
+	return nr_reclaimed;
+}
 /*
  * Attempt to detach a locked page from its ->mapping.  If it is dirty or if
  * someone else has a ref on the page, abort and return 0.  If it was
@@ -771,6 +850,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
+	LIST_HEAD(unmap_pages);
 	int pgactivate = 0;
 	unsigned long nr_dirty = 0;
 	unsigned long nr_congested = 0;
@@ -969,17 +1049,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
-		if (!mapping || !__remove_mapping(mapping, page))
+		if (!mapping)
 			goto keep_locked;
 
-		/*
-		 * At this point, we have no other references and there is
-		 * no way to pick any more up (removed from LRU, removed
-		 * from pagecache). Can use non-atomic bitops now (and
-		 * we obviously don't have to worry about waking up a process
-		 * waiting on the page lock, because there are no references.
-		 */
-		__clear_page_locked(page);
+		/* remove pages from mapping in batch at end of loop */
+		list_add(&page->lru, &unmap_pages);
+		continue;
+
 free_it:
 		nr_reclaimed++;
 
@@ -1014,6 +1090,9 @@ keep_lumpy:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
+	nr_reclaimed += __remove_mapping_batch(&unmap_pages, &ret_pages,
+					       &free_pages);
+
 	/*
 	 * Tag a zone as congested if all the dirty pages encountered were
 	 * backed by a congested BDI. In this case, reclaimers should just










--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
