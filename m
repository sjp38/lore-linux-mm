From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:40:03 +0200
Message-Id: <20060712144003.16998.93543.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 16/39] mm: pgrep: remove mm_inline.h
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Move whatever is needed from mm_inline into the use-once policy header.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_inline.h          |   47 -------------------------------------
 include/linux/mm_page_replace.h    |    1 
 include/linux/mm_use_once_policy.h |   28 ++++++++++++++++++++++
 mm/migrate.c                       |    1 
 mm/swap.c                          |    1 
 mm/vmscan.c                        |    1 
 6 files changed, 28 insertions(+), 51 deletions(-)

Index: linux-2.6/include/linux/mm_inline.h
===================================================================
--- linux-2.6.orig/include/linux/mm_inline.h	2006-07-12 16:08:18.000000000 +0200
+++ /dev/null	1970-01-01 00:00:00.000000000 +0000
@@ -1,47 +0,0 @@
-#ifndef _LINUX_MM_INLINE_H_
-#define _LINUX_MM_INLINE_H_
-
-#ifdef __KERNEL__
-
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
-		__ClearPageActive(page);
-		zone->nr_active--;
-	} else {
-		zone->nr_inactive--;
-	}
-}
-
-#endif /* __KERNEL__ */
-#endif /* _LINUX_MM_INLINE_H_ */
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:43.000000000 +0200
@@ -6,7 +6,6 @@
 #include <linux/mmzone.h>
 #include <linux/mm.h>
 #include <linux/pagevec.h>
-#include <linux/mm_inline.h>
 
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:39.000000000 +0200
@@ -6,6 +6,34 @@
 #include <linux/fs.h>
 #include <linux/rmap.h>
 
+static inline void
+add_page_to_active_list(struct zone *zone, struct page *page)
+{
+	list_add(&page->lru, &zone->active_list);
+	zone->nr_active++;
+}
+
+static inline void
+add_page_to_inactive_list(struct zone *zone, struct page *page)
+{
+	list_add(&page->lru, &zone->inactive_list);
+	zone->nr_inactive++;
+}
+
+static inline void
+del_page_from_active_list(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	zone->nr_active--;
+}
+
+static inline void
+del_page_from_inactive_list(struct zone *zone, struct page *page)
+{
+	list_del(&page->lru);
+	zone->nr_inactive--;
+}
+
 static inline void pgrep_hint_active(struct page *page)
 {
 	SetPageActive(page);
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/migrate.c	2006-07-12 16:11:43.000000000 +0200
@@ -17,7 +17,6 @@
 #include <linux/swap.h>
 #include <linux/pagemap.h>
 #include <linux/buffer_head.h>
-#include <linux/mm_inline.h>
 #include <linux/pagevec.h>
 #include <linux/rmap.h>
 #include <linux/topology.h>
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/swap.c	2006-07-12 16:09:18.000000000 +0200
@@ -22,7 +22,6 @@
 #include <linux/pagevec.h>
 #include <linux/init.h>
 #include <linux/module.h>
-#include <linux/mm_inline.h>
 #include <linux/buffer_head.h>	/* for try_to_release_page() */
 #include <linux/module.h>
 #include <linux/percpu_counter.h>
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:39.000000000 +0200
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
