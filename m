From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Message-Id: <20060322223328.12658.43943.sendpatchset@twins.localnet>
In-Reply-To: <20060322223107.12658.14997.sendpatchset@twins.localnet>
References: <20060322223107.12658.14997.sendpatchset@twins.localnet>
Subject: [PATCH 14/34] mm: page-replace-remove-mm_inline.patch
Date: Wed, 22 Mar 2006 23:34:00 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Bob Picco <bob.picco@hp.com>, Andrew Morton <akpm@osdl.org>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Linus Torvalds <torvalds@osdl.org>, Rik van Riel <riel@redhat.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Remove mm_inline.h and abstract the removal of pages from the 
page replacement policy.

API:

remove the page from the care of the replacement policy's care

	void page_replace_remove(struct zone *, struct page *);

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

---

 include/linux/mm_inline.h          |   39 -------------------------------------
 include/linux/mm_page_replace.h    |    2 -
 include/linux/mm_use_once_policy.h |   25 +++++++++++++++++++++++
 mm/swap.c                          |    5 +---
 mm/useonce.c                       |    8 ++++++-
 mm/vmscan.c                        |    1 
 6 files changed, 35 insertions(+), 45 deletions(-)

Index: linux-2.6-git/include/linux/mm_inline.h
===================================================================
--- linux-2.6-git.orig/include/linux/mm_inline.h
+++ linux-2.6-git/include/linux/mm_inline.h
@@ -1,41 +1,2 @@
 
-static inline void
-add_page_to_active_list(struct zone *zone, struct page *page)
-{
-	list_add(&page->lru, &zone->active_list);
-	zone->nr_active++;
-}
-
-static inline void
-add_page_to_inactive_list(struct zone *zone, struct page *page)
-{
-	list_add(&page->lru, &zone->inactive_list);
-	zone->nr_inactive++;
-}
-
-static inline void
-del_page_from_active_list(struct zone *zone, struct page *page)
-{
-	list_del(&page->lru);
-	zone->nr_active--;
-}
-
-static inline void
-del_page_from_inactive_list(struct zone *zone, struct page *page)
-{
-	list_del(&page->lru);
-	zone->nr_inactive--;
-}
-
-static inline void
-del_page_from_lru(struct zone *zone, struct page *page)
-{
-	list_del(&page->lru);
-	if (PageActive(page)) {
-		ClearPageActive(page);
-		zone->nr_active--;
-	} else {
-		zone->nr_inactive--;
-	}
-}
 
Index: linux-2.6-git/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6-git.orig/include/linux/mm_use_once_policy.h
+++ linux-2.6-git/include/linux/mm_use_once_policy.h
@@ -12,6 +12,20 @@ static inline void page_replace_hint_act
 }
 
 static inline void
+del_page_from_inactive_list(struct zone *zone, struct page *page)
+{
+       list_del(&page->lru);
+       zone->nr_inactive--;
+}
+
+static inline void
+add_page_to_active_list(struct zone *zone, struct page *page)
+{
+	list_add(&page->lru, &zone->active_list);
+	zone->nr_active++;
+}
+
+static inline void
 add_page_to_inactive_list(struct zone *zone, struct page *page)
 {
 	list_add(&page->lru, &zone->policy.inactive_list);
@@ -102,5 +116,16 @@ static inline int page_replace_activate(
 	return 1;
 }
 
+static inline void page_replace_remove(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	if (PageActive(page)) {
+		ClearPageActive(page);
+		zone->nr_active--;
+	} else {
+		zone->nr_inactive--;
+	}
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_USEONCE_POLICY_H */
Index: linux-2.6-git/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6-git.orig/include/linux/mm_page_replace.h
+++ linux-2.6-git/include/linux/mm_page_replace.h
@@ -6,7 +6,6 @@
 #include <linux/mmzone.h>
 #include <linux/mm.h>
 #include <linux/pagevec.h>
-#include <linux/mm_inline.h>
 
 struct scan_control {
 	/* Ask refill_inactive_zone, or shrink_cache to scan this many pages */
@@ -89,6 +88,7 @@ typedef enum {
 extern void page_replace_reinsert(struct list_head *);
 extern void page_replace_shrink(struct zone *, struct scan_control *);
 /* void page_replace_mark_accessed(struct page *); */
+/* void page_replace_remove(struct zone *, struct page *); */
 
 #ifdef CONFIG_MIGRATION
 extern int page_replace_isolate(struct page *p);
Index: linux-2.6-git/mm/useonce.c
===================================================================
--- linux-2.6-git.orig/mm/useonce.c
+++ linux-2.6-git/mm/useonce.c
@@ -1,5 +1,4 @@
 #include <linux/mm_page_replace.h>
-#include <linux/mm_inline.h>
 #include <linux/swap.h>
 #include <linux/module.h>
 #include <linux/pagemap.h>
@@ -7,6 +6,13 @@
 #include <linux/buffer_head.h>	/* for try_to_release_page(),
 					buffer_heads_over_limit */
 
+static inline void
+del_page_from_active_list(struct zone *zone, struct page *page)
+{
+       list_del(&page->lru);
+       zone->nr_active--;
+}
+
 /**
  * lru_cache_add: add a page to the page lists
  * @page: the page to add
Index: linux-2.6-git/mm/swap.c
===================================================================
--- linux-2.6-git.orig/mm/swap.c
+++ linux-2.6-git/mm/swap.c
@@ -22,7 +22,6 @@
 #include <linux/pagevec.h>
 #include <linux/init.h>
 #include <linux/module.h>
-#include <linux/mm_inline.h>
 #include <linux/buffer_head.h>	/* for try_to_release_page() */
 #include <linux/module.h>
 #include <linux/percpu_counter.h>
@@ -118,7 +117,7 @@ void fastcall __page_cache_release(struc
 
 	spin_lock_irqsave(&zone->lru_lock, flags);
 	if (TestClearPageLRU(page))
-		del_page_from_lru(zone, page);
+		page_replace_remove(zone, page);
 	if (page_count(page) != 0)
 		page = NULL;
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
@@ -171,7 +170,7 @@ void release_pages(struct page **pages, 
 			spin_lock_irq(&zone->lru_lock);
 		}
 		if (TestClearPageLRU(page))
-			del_page_from_lru(zone, page);
+			page_replace_remove(zone, page);
 		if (page_count(page) == 0) {
 			if (!pagevec_add(&pages_to_free, page)) {
 				spin_unlock_irq(&zone->lru_lock);
Index: linux-2.6-git/mm/vmscan.c
===================================================================
--- linux-2.6-git.orig/mm/vmscan.c
+++ linux-2.6-git/mm/vmscan.c
@@ -24,7 +24,6 @@
 #include <linux/blkdev.h>
 #include <linux/buffer_head.h>	/* for try_to_release_page(),
 					buffer_heads_over_limit */
-#include <linux/mm_inline.h>
 #include <linux/pagevec.h>
 #include <linux/backing-dev.h>
 #include <linux/rmap.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
