From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:38:21 +0200
Message-Id: <20060712143821.16998.55209.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 7/39] mm: pgrep: abstract the activation logic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Abstract page activation and the reclaimable condition.

API:

wether the page is reclaimable

	reclaim_t pgrep_reclaimable(struct page *);

	RECLAIM_KEEP		- keep the page
	RECLAIM_ACTIVATE	- keep the page and activate
	RECLAIM_REFERENCED	- try to pageout even though referenced
	RECLAIM_OK		- try to pageout
	
activate the page
	
	int pgrep_activate(struct page *page);

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h    |   11 ++++++++
 include/linux/mm_use_once_policy.h |   48 +++++++++++++++++++++++++++++++++++++
 mm/vmscan.c                        |   42 ++++++++++----------------------
 3 files changed, 72 insertions(+), 29 deletions(-)

Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:50.000000000 +0200
@@ -3,6 +3,9 @@
 
 #ifdef __KERNEL__
 
+#include <linux/fs.h>
+#include <linux/rmap.h>
+
 static inline void pgrep_hint_active(struct page *page)
 {
 	SetPageActive(page);
@@ -21,5 +24,50 @@ __pgrep_add(struct zone *zone, struct pa
 		add_page_to_inactive_list(zone, page);
 }
 
+/* Called without lock on whether page is mapped, so answer is unstable */
+static inline int page_mapping_inuse(struct page *page)
+{
+	struct address_space *mapping;
+
+	/* Page is in somebody's page tables. */
+	if (page_mapped(page))
+		return 1;
+
+	/* Be more reluctant to reclaim swapcache than pagecache */
+	if (PageSwapCache(page))
+		return 1;
+
+	mapping = page_mapping(page);
+	if (!mapping)
+		return 0;
+
+	/* File is mmap'd by somebody? */
+	return mapping_mapped(mapping);
+}
+
+static inline reclaim_t pgrep_reclaimable(struct page *page)
+{
+	int referenced;
+
+	if (PageActive(page))
+		BUG();
+
+	referenced = page_referenced(page, 1);
+	/* In active use or really unfreeable?  Activate it. */
+	if (referenced && page_mapping_inuse(page))
+		return RECLAIM_ACTIVATE;
+
+	if (referenced)
+		return RECLAIM_REFERENCED;
+
+	return RECLAIM_OK;
+}
+
+static inline int pgrep_activate(struct page *page)
+{
+	SetPageActive(page);
+	return 1;
+}
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_USEONCE_POLICY_H */
Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:53.000000000 +0200
@@ -17,6 +17,17 @@ extern void __pgrep_add_drain(unsigned i
 extern int pgrep_add_drain_all(void);
 extern void __pagevec_pgrep_add(struct pagevec *);
 
+typedef enum {
+	RECLAIM_KEEP,
+	RECLAIM_ACTIVATE,
+	RECLAIM_REFERENCED,
+	RECLAIM_OK,
+} reclaim_t;
+
+/* reclaim_t pgrep_reclaimable(struct page *); */
+/* int pgrep_activate(struct page *page); */
+
+
 #ifdef CONFIG_MM_POLICY_USEONCE
 #include <linux/mm_use_once_policy.h>
 #else
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:08:18.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:11:53.000000000 +0200
@@ -229,27 +229,6 @@ unsigned long shrink_slab(unsigned long 
 	return ret;
 }
 
-/* Called without lock on whether page is mapped, so answer is unstable */
-static inline int page_mapping_inuse(struct page *page)
-{
-	struct address_space *mapping;
-
-	/* Page is in somebody's page tables. */
-	if (page_mapped(page))
-		return 1;
-
-	/* Be more reluctant to reclaim swapcache than pagecache */
-	if (PageSwapCache(page))
-		return 1;
-
-	mapping = page_mapping(page);
-	if (!mapping)
-		return 0;
-
-	/* File is mmap'd by somebody? */
-	return mapping_mapped(mapping);
-}
-
 static inline int is_page_cache_freeable(struct page *page)
 {
 	return page_count(page) - !!PagePrivate(page) == 2;
@@ -419,7 +398,7 @@ static unsigned long shrink_page_list(st
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
-		int referenced;
+		int referenced = 0;
 
 		cond_resched();
 
@@ -429,8 +408,6 @@ static unsigned long shrink_page_list(st
 		if (TestSetPageLocked(page))
 			goto keep;
 
-		BUG_ON(PageActive(page));
-
 		sc->nr_scanned++;
 
 		if (!sc->may_swap && page_mapped(page))
@@ -443,10 +420,17 @@ static unsigned long shrink_page_list(st
 		if (PageWriteback(page))
 			goto keep_locked;
 
-		referenced = page_referenced(page, 1);
-		/* In active use or really unfreeable?  Activate it. */
-		if (referenced && page_mapping_inuse(page))
+		switch (pgrep_reclaimable(page)) {
+		case RECLAIM_KEEP:
+			goto keep_locked;
+		case RECLAIM_ACTIVATE:
 			goto activate_locked;
+		case RECLAIM_REFERENCED:
+			referenced = 1;
+			break;
+		case RECLAIM_OK:
+			break;
+		}
 
 #ifdef CONFIG_SWAP
 		/*
@@ -549,8 +533,8 @@ free_it:
 		continue;
 
 activate_locked:
-		SetPageActive(page);
-		pgactivate++;
+		if (pgrep_activate(page))
+			pgactivate++;
 keep_locked:
 		unlock_page(page);
 keep:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
