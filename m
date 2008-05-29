From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Thu, 29 May 2008 15:51:34 -0400
Message-Id: <20080529195134.27159.17534.sendpatchset@lts-notebook>
In-Reply-To: <20080529195030.27159.66161.sendpatchset@lts-notebook>
References: <20080529195030.27159.66161.sendpatchset@lts-notebook>
Subject: [PATCH 22/25] Noreclaim and Mlocked pages vm events
Sender: owner-linux-mm@kvack.org
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kosaki Motohiro <kosaki.motohiro@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Against:  2.6.26-rc2-mm1

Add some event counters to vmstats for testing noreclaim/mlock.  
Some of these might be interesting enough to keep around.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/vmstat.h |   11 +++++++++++
 mm/internal.h          |    4 +++-
 mm/mlock.c             |   33 +++++++++++++++++++++++++--------
 mm/vmscan.c            |   16 +++++++++++++++-
 mm/vmstat.c            |   12 ++++++++++++
 5 files changed, 66 insertions(+), 10 deletions(-)

Index: linux-2.6.26-rc2-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/include/linux/vmstat.h	2008-05-28 13:01:13.000000000 -0400
+++ linux-2.6.26-rc2-mm1/include/linux/vmstat.h	2008-05-28 13:03:10.000000000 -0400
@@ -41,6 +41,17 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
+#ifdef CONFIG_NORECLAIM_LRU
+		NORECL_PGCULLED,	/* culled to noreclaim list */
+		NORECL_PGSCANNED,	/* scanned for reclaimability */
+		NORECL_PGRESCUED,	/* rescued from noreclaim list */
+#ifdef CONFIG_NORECLAIM_MLOCK
+		NORECL_PGMLOCKED,
+		NORECL_PGMUNLOCKED,
+		NORECL_PGCLEARED,
+		NORECL_PGSTRANDED,	/* unable to isolate on unlock */
+#endif
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
Index: linux-2.6.26-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/vmscan.c	2008-05-28 13:02:55.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/vmscan.c	2008-05-28 13:03:10.000000000 -0400
@@ -453,12 +453,13 @@ int putback_lru_page(struct page *page)
 {
 	int lru;
 	int ret = 1;
+	int was_nonreclaimable;
 
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageLRU(page));
 
 	lru = !!TestClearPageActive(page);
-	ClearPageNoreclaim(page);	/* for page_reclaimable() */
+	was_nonreclaimable = TestClearPageNoreclaim(page);
 
 	if (unlikely(!page->mapping)) {
 		/*
@@ -478,6 +479,10 @@ int putback_lru_page(struct page *page)
 		lru += page_file_cache(page);
 		lru_cache_add_lru(page, lru);
 		mem_cgroup_move_lists(page, lru);
+#ifdef CONFIG_NORECLAIM_LRU
+		if (was_nonreclaimable)
+			count_vm_event(NORECL_PGRESCUED);
+#endif
 	} else {
 		/*
 		 * Put non-reclaimable pages directly on zone's noreclaim
@@ -485,6 +490,10 @@ int putback_lru_page(struct page *page)
 		 */
 		add_page_to_noreclaim_list(page);
 		mem_cgroup_move_lists(page, LRU_NORECLAIM);
+#ifdef CONFIG_NORECLAIM_LRU
+		if (!was_nonreclaimable)
+			count_vm_event(NORECL_PGCULLED);
+#endif
 	}
 
 	put_page(page);		/* drop ref from isolate */
@@ -2363,6 +2372,7 @@ static void check_move_noreclaim_page(st
 		__dec_zone_state(zone, NR_NORECLAIM);
 		list_move(&page->lru, &zone->list[l]);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
+		__count_vm_event(NORECL_PGRESCUED);
 	} else {
 		/*
 		 * rotate noreclaim list
@@ -2394,6 +2404,7 @@ void scan_mapping_noreclaim_pages(struct
 	while (next < end &&
 		pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		int i;
+		int pg_scanned = 0;
 
 		zone = NULL;
 
@@ -2402,6 +2413,7 @@ void scan_mapping_noreclaim_pages(struct
 			pgoff_t page_index = page->index;
 			struct zone *pagezone = page_zone(page);
 
+			pg_scanned++;
 			if (page_index > next)
 				next = page_index;
 			next++;
@@ -2432,6 +2444,8 @@ void scan_mapping_noreclaim_pages(struct
 		if (zone)
 			spin_unlock_irq(&zone->lru_lock);
 		pagevec_release(&pvec);
+
+		count_vm_events(NORECL_PGSCANNED, pg_scanned);
 	}
 
 }
Index: linux-2.6.26-rc2-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/vmstat.c	2008-05-28 13:03:06.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/vmstat.c	2008-05-28 13:03:10.000000000 -0400
@@ -759,6 +759,18 @@ static const char * const vmstat_text[] 
 	"htlb_buddy_alloc_success",
 	"htlb_buddy_alloc_fail",
 #endif
+
+#ifdef CONFIG_NORECLAIM_LRU
+	"noreclaim_pgs_culled",
+	"noreclaim_pgs_scanned",
+	"noreclaim_pgs_rescued",
+#ifdef CONFIG_NORECLAIM_MLOCK
+	"noreclaim_pgs_mlocked",
+	"noreclaim_pgs_munlocked",
+	"noreclaim_pgs_cleared",
+	"noreclaim_pgs_stranded",
+#endif
+#endif
 #endif
 };
 
Index: linux-2.6.26-rc2-mm1/mm/mlock.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/mlock.c	2008-05-28 13:03:06.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/mlock.c	2008-05-28 13:03:10.000000000 -0400
@@ -18,6 +18,7 @@
 #include <linux/rmap.h>
 #include <linux/mmzone.h>
 #include <linux/hugetlb.h>
+#include <linux/vmstat.h>
 
 #include "internal.h"
 
@@ -57,6 +58,7 @@ void __clear_page_mlock(struct page *pag
 	VM_BUG_ON(!PageLocked(page));	/* for LRU islolate/putback */
 
 	dec_zone_page_state(page, NR_MLOCK);
+	count_vm_event(NORECL_PGCLEARED);
 	if (!isolate_lru_page(page)) {
 		putback_lru_page(page);
 	} else {
@@ -66,6 +68,8 @@ void __clear_page_mlock(struct page *pag
 		lru_add_drain_all();
 		if (!isolate_lru_page(page))
 			putback_lru_page(page);
+		else if (PageNoreclaim(page))
+			count_vm_event(NORECL_PGSTRANDED);
 	}
 }
 
@@ -79,6 +83,7 @@ void mlock_vma_page(struct page *page)
 
 	if (!TestSetPageMlocked(page)) {
 		inc_zone_page_state(page, NR_MLOCK);
+		count_vm_event(NORECL_PGMLOCKED);
 		if (!isolate_lru_page(page))
 			putback_lru_page(page);
 	}
@@ -109,16 +114,28 @@ static void munlock_vma_page(struct page
 	if (TestClearPageMlocked(page)) {
 		dec_zone_page_state(page, NR_MLOCK);
 		if (!isolate_lru_page(page)) {
-			try_to_unlock(page);	/* maybe relock the page */
+			int ret = try_to_unlock(page);
+			/*
+			 * did try_to_unlock() succeed or punt?
+			 */
+			if (ret == SWAP_SUCCESS || ret == SWAP_AGAIN)
+				count_vm_event(NORECL_PGMUNLOCKED);
+
 			putback_lru_page(page);
+		} else {
+			/*
+			 * We lost the race.  let try_to_unmap() deal
+			 * with it.  At least we get the page state and
+			 * mlock stats right.  However, page is still on
+			 * the noreclaim list.  We'll fix that up when
+			 * the page is eventually freed or we scan the
+			 * noreclaim list.
+			 */
+			if (PageNoreclaim(page))
+				count_vm_event(NORECL_PGSTRANDED);
+			else
+				count_vm_event(NORECL_PGMUNLOCKED);
 		}
-		/*
-		 * Else we lost the race.  let try_to_unmap() deal with it.
-		 * At least we get the page state and mlock stats right.
-		 * However, page is still on the noreclaim list.  We'll fix
-		 * that up when the page is eventually freed or we scan the
-		 * noreclaim list.
-		 */
 	}
 }
 
Index: linux-2.6.26-rc2-mm1/mm/internal.h
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/internal.h	2008-05-28 13:03:06.000000000 -0400
+++ linux-2.6.26-rc2-mm1/mm/internal.h	2008-05-28 13:03:10.000000000 -0400
@@ -107,8 +107,10 @@ static inline int is_mlocked_vma(struct 
 	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
 		return 0;
 
-	if (!TestSetPageMlocked(page))
+	if (!TestSetPageMlocked(page)) {
 		inc_zone_page_state(page, NR_MLOCK);
+		count_vm_event(NORECL_PGMLOCKED);
+	}
 	return 1;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
