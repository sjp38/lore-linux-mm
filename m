From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:39:40 +0200
Message-Id: <20060712143940.16998.41841.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 14/39] mm: pgrep: manage page-state
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

API:

Copy/Clear the reclaim page state:

	void pgrep_copy_state(struct page *, struct page *);
	void pgrep_clear_state(struct page *);

Query activeness of the page, where 'active' is taken to mean: not likely
to be in the next candidate group.

	int pgrep_is_active(struct page *);
	

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl

 include/linux/mm_page_replace.h    |    3 +++
 include/linux/mm_use_once_policy.h |   17 +++++++++++++++++
 mm/mempolicy.c                     |    2 +-
 mm/migrate.c                       |    5 ++---
 mm/vmscan.c                        |    1 +
 5 files changed, 24 insertions(+), 4 deletions(-)

Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:45.000000000 +0200
@@ -81,6 +81,9 @@ typedef enum {
 extern unsigned long pgrep_shrink_zone(int priority, struct zone *zone,
 					struct scan_control *sc);
 /* void __pgrep_rotate_reclaimable(struct zone *, struct page *); */
+/* void pgrep_copy_state(struct page *, struct page *); */
+/* void pgrep_clear_state(struct page *); */
+/* int pgrep_is_active(struct page *); */
 
 
 #ifdef CONFIG_MM_POLICY_USEONCE
Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:45.000000000 +0200
@@ -103,5 +103,22 @@ static inline void __pgrep_rotate_reclai
 	}
 }
 
+static inline void pgrep_copy_state(struct page *dpage, struct page *spage)
+{
+	if (PageActive(spage))
+		SetPageActive(dpage);
+}
+
+static inline void pgrep_clear_state(struct page *page)
+{
+	if (PageActive(page))
+		ClearPageActive(page);
+}
+
+static inline int pgrep_is_active(struct page *page)
+{
+	return PageActive(page);
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_USEONCE_POLICY_H */
Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/mempolicy.c	2006-07-12 16:11:43.000000000 +0200
@@ -1749,7 +1749,7 @@ static void gather_stats(struct page *pa
 	if (PageSwapCache(page))
 		md->swapcache++;
 
-	if (PageActive(page))
+	if (pgrep_is_active(page))
 		md->active++;
 
 	if (PageWriteback(page))
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/migrate.c	2006-07-12 16:11:45.000000000 +0200
@@ -262,12 +262,11 @@ void migrate_page_copy(struct page *newp
 		SetPageReferenced(newpage);
 	if (PageUptodate(page))
 		SetPageUptodate(newpage);
-	if (PageActive(page))
-		SetPageActive(newpage);
 	if (PageChecked(page))
 		SetPageChecked(newpage);
 	if (PageMappedToDisk(page))
 		SetPageMappedToDisk(newpage);
+	pgrep_copy_state(newpage, page);
 
 	if (PageDirty(page)) {
 		clear_page_dirty_for_io(page);
@@ -275,8 +274,8 @@ void migrate_page_copy(struct page *newp
  	}
 
 	ClearPageSwapCache(page);
-	ClearPageActive(page);
 	ClearPagePrivate(page);
+	pgrep_clear_state(page);
 	set_page_private(page, 0);
 	page->mapping = NULL;
 
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:09:18.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:45.000000000 +0200
@@ -473,6 +473,7 @@ unsigned long shrink_page_list(struct li
 			goto keep_locked;
 
 free_it:
+		pgrep_clear_state(page);
 		unlock_page(page);
 		nr_reclaimed++;
 		if (!pagevec_add(&freed_pvec, page))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
