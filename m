Date: Tue, 15 Jul 2008 04:26:16 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 8/9] vmstat-unevictable-and-mlocked-pages-vm-events.patch
In-Reply-To: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080715042411.F707.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch name: vmstat-unevictable-and-mlocked-pages-vm-events.patch
Against: mmotm Jul 14

unevictable-lru-infrastructure-putback_lru_page-rework.patch makes following patch failure hunk.
Then, remove it. (latter patch restore it properly)

	---------------------------------------------------------
	@@ -486,6 +486,7 @@ int putback_lru_page(struct page *page)
	 {
	 	int lru;
	 	int ret = 1;
	+	int was_unevictable;
	 
	 	VM_BUG_ON(!PageLocked(page));
	 	VM_BUG_ON(PageLRU(page));
	
	 	lru = !!TestClearPageActive(page);
	-	ClearPageUnevictable(page);	/* for page_evictable() */
	+	was_unevictable = TestClearPageUnevictable(page); /* for page_evictable() */
	 
	 	if (unlikely(!page->mapping)) {
	 		/*
	@@ -511,6 +512,10 @@ int putback_lru_page(struct page *page)
	 		lru += page_is_file_cache(page);
	 		lru_cache_add_lru(page, lru);
	 		mem_cgroup_move_lists(page, lru);
	+#ifdef CONFIG_UNEVICTABLE_LRU
	+		if (was_unevictable)
	+			count_vm_event(NORECL_PGRESCUED);
	+#endif
	 	} else {
	 		/*
	 		 * Put unevictable pages directly on zone's unevictable
	@@ -518,7 +523,10 @@ int putback_lru_page(struct page *page)
 			 */
 			add_page_to_unevictable_list(page);
	 		mem_cgroup_move_lists(page, LRU_UNEVICTABLE);
	+#ifdef CONFIG_UNEVICTABLE_LRU
	+		if (!was_unevictable)
	+			count_vm_event(NORECL_PGCULLED);
	+#endif
	 	}
	 
	 	put_page(page);		/* drop ref from isolate */
	---------------------------------------------------------



=======================================
From: Lee Schermerhorn <lee.schermerhorn@hp.com>

Add some event counters to vmstats for testing unevictable/mlock.  Some of
these might be interesting enough to keep around.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/vmstat.h |    9 +++++++++
 mm/internal.h          |    4 +++-
 mm/mlock.c             |   33 +++++++++++++++++++++++++--------
 mm/vmscan.c            |    5 +++++
 mm/vmstat.c            |   10 ++++++++++
 5 files changed, 52 insertions(+), 9 deletions(-)

Index: b/include/linux/vmstat.h
===================================================================
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -41,6 +41,15 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
+#ifdef CONFIG_UNEVICTABLE_LRU
+		NORECL_PGCULLED,	/* culled to noreclaim list */
+		NORECL_PGSCANNED,	/* scanned for reclaimability */
+		NORECL_PGRESCUED,	/* rescued from noreclaim list */
+		NORECL_PGMLOCKED,
+		NORECL_PGMUNLOCKED,
+		NORECL_PGCLEARED,
+		NORECL_PGSTRANDED,	/* unable to isolate on unlock */
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -101,8 +101,10 @@ static inline int is_mlocked_vma(struct 
 	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) != VM_LOCKED))
 		return 0;
 
-	if (!TestSetPageMlocked(page))
+	if (!TestSetPageMlocked(page)) {
 		inc_zone_page_state(page, NR_MLOCK);
+		count_vm_event(NORECL_PGMLOCKED);
+	}
 	return 1;
 }
 
Index: b/mm/mlock.c
===================================================================
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -18,6 +18,7 @@
 #include <linux/rmap.h>
 #include <linux/mmzone.h>
 #include <linux/hugetlb.h>
+#include <linux/vmstat.h>
 
 #include "internal.h"
 
@@ -61,6 +62,7 @@ void __clear_page_mlock(struct page *pag
 	}
 
 	dec_zone_page_state(page, NR_MLOCK);
+	count_vm_event(NORECL_PGCLEARED);
 	if (!isolate_lru_page(page)) {
 		putback_lru_page(page);
 	} else {
@@ -70,6 +72,8 @@ void __clear_page_mlock(struct page *pag
 		lru_add_drain_all();
 		if (!isolate_lru_page(page))
 			putback_lru_page(page);
+		else if (PageUnevictable(page))
+			count_vm_event(NORECL_PGSTRANDED);
 	}
 }
 
@@ -83,6 +87,7 @@ void mlock_vma_page(struct page *page)
 
 	if (!TestSetPageMlocked(page)) {
 		inc_zone_page_state(page, NR_MLOCK);
+		count_vm_event(NORECL_PGMLOCKED);
 		if (!isolate_lru_page(page))
 			putback_lru_page(page);
 	}
@@ -113,16 +118,28 @@ static void munlock_vma_page(struct page
 	if (TestClearPageMlocked(page)) {
 		dec_zone_page_state(page, NR_MLOCK);
 		if (!isolate_lru_page(page)) {
-			try_to_munlock(page);	/* maybe relock the page */
+			int ret = try_to_munlock(page);
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
+			if (PageUnevictable(page))
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
 
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2416,6 +2416,7 @@ retry:
 		__dec_zone_state(zone, NR_UNEVICTABLE);
 		list_move(&page->lru, &zone->lru[l].list);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
+		__count_vm_event(NORECL_PGRESCUED);
 	} else {
 		/*
 		 * rotate unevictable list
@@ -2449,6 +2450,7 @@ void scan_mapping_unevictable_pages(stru
 	while (next < end &&
 		pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		int i;
+		int pg_scanned = 0;
 
 		zone = NULL;
 
@@ -2457,6 +2459,7 @@ void scan_mapping_unevictable_pages(stru
 			pgoff_t page_index = page->index;
 			struct zone *pagezone = page_zone(page);
 
+			pg_scanned++;
 			if (page_index > next)
 				next = page_index;
 			next++;
@@ -2474,6 +2477,8 @@ void scan_mapping_unevictable_pages(stru
 		if (zone)
 			spin_unlock_irq(&zone->lru_lock);
 		pagevec_release(&pvec);
+
+		count_vm_events(NORECL_PGSCANNED, pg_scanned);
 	}
 
 }
Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -664,6 +664,16 @@ static const char * const vmstat_text[] 
 	"htlb_buddy_alloc_success",
 	"htlb_buddy_alloc_fail",
 #endif
+
+#ifdef CONFIG_UNEVICTABLE_LRU
+	"noreclaim_pgs_culled",
+	"noreclaim_pgs_scanned",
+	"noreclaim_pgs_rescued",
+	"noreclaim_pgs_mlocked",
+	"noreclaim_pgs_munlocked",
+	"noreclaim_pgs_cleared",
+	"noreclaim_pgs_stranded",
+#endif
 #endif
 };
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
