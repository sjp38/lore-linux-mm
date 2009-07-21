Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B4D216B004F
	for <linux-mm@kvack.org>; Tue, 21 Jul 2009 04:57:37 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/4] mm: return boolean from page_is_file_cache()
Date: Tue, 21 Jul 2009 10:56:33 +0200
Message-Id: <1248166594-8859-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

page_is_file_cache() has been used for both boolean checks and LRU
arithmetic, which was always a bit weird.

Now that page_lru_type() exists for LRU arithmetic, make
page_is_file_cache() a real predicate function and adjust the
boolean-using callsites to drop those pesky double negations.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/mm_inline.h |    8 ++------
 mm/migrate.c              |    6 +++---
 mm/swap.c                 |    2 +-
 mm/vmscan.c               |    2 +-
 4 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index ec975f2..54edae1 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -5,7 +5,7 @@
  * page_is_file_cache - should the page be on a file LRU or anon LRU?
  * @page: the page to test
  *
- * Returns LRU_FILE if @page is page cache page backed by a regular filesystem,
+ * Returns 1 if @page is page cache page backed by a regular filesystem,
  * or 0 if @page is anonymous, tmpfs or otherwise ram or swap backed.
  * Used by functions that manipulate the LRU lists, to sort a page
  * onto the right LRU list.
@@ -16,11 +16,7 @@
  */
 static inline int page_is_file_cache(struct page *page)
 {
-	if (PageSwapBacked(page))
-		return 0;
-
-	/* The page is page cache backed by a normal filesystem. */
-	return LRU_FILE;
+	return !PageSwapBacked(page);
 }
 
 static inline void
diff --git a/mm/migrate.c b/mm/migrate.c
index b535a2c..e97e513 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -68,7 +68,7 @@ int putback_lru_pages(struct list_head *l)
 	list_for_each_entry_safe(page, page2, l, lru) {
 		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
-				    !!page_is_file_cache(page));
+				page_is_file_cache(page));
 		putback_lru_page(page);
 		count++;
 	}
@@ -701,7 +701,7 @@ unlock:
  		 */
  		list_del(&page->lru);
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
-				    !!page_is_file_cache(page));
+				page_is_file_cache(page));
 		putback_lru_page(page);
 	}
 
@@ -751,7 +751,7 @@ int migrate_pages(struct list_head *from,
 	local_irq_save(flags);
 	list_for_each_entry(page, from, lru)
 		__inc_zone_page_state(page, NR_ISOLATED_ANON +
-				      !!page_is_file_cache(page));
+				page_is_file_cache(page));
 	local_irq_restore(flags);
 
 	if (!swapwrite)
diff --git a/mm/swap.c b/mm/swap.c
index 8f84638..230589c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -189,7 +189,7 @@ void activate_page(struct page *page)
 		add_page_to_lru_list(zone, page, lru);
 		__count_vm_event(PGACTIVATE);
 
-		update_page_reclaim_stat(zone, page, !!file, 1);
+		update_page_reclaim_stat(zone, page, file, 1);
 	}
 	spin_unlock_irq(&zone->lru_lock);
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 758f628..6b368d3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -816,7 +816,7 @@ int __isolate_lru_page(struct page *page, int mode, int file)
 	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
 		return ret;
 
-	if (mode != ISOLATE_BOTH && (!page_is_file_cache(page) != !file))
+	if (mode != ISOLATE_BOTH && page_is_file_cache(page) != file)
 		return ret;
 
 	/*
-- 
1.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
