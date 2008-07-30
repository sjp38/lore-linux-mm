From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Wed, 30 Jul 2008 16:06:36 -0400
Message-Id: <20080730200636.24272.54065.sendpatchset@lts-notebook>
In-Reply-To: <20080730200618.24272.31756.sendpatchset@lts-notebook>
References: <20080730200618.24272.31756.sendpatchset@lts-notebook>
Subject: [PATCH 3/7] unevictable lru:  add event counting with statistics
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@surriel.com>, Eric.Whitney@hp.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Fix to unevictable-lru-page-statistics.patch

Add unevictable lru infrastructure vm events to the statistics patch.
Rename the "NORECL_" and "noreclaim_" symbols and text strings to
"UNEVICTABLE_" and "unevictable_", respectively.

Currently, both the infrastructure and the mlocked pages event are
added by a single patch later in the series.  This makes it difficult
to add or rework the incremental patches.  The events actually "belong"
with the stats, so pull them up to here.

Also, restore the event counting to putback_lru_page().  This was removed
from previous patch in series where it was "misplaced".  The actual events
weren't defined that early.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/vmstat.h |    5 +++++
 mm/vmscan.c            |    6 ++++++
 mm/vmstat.c            |    5 +++++
 3 files changed, 16 insertions(+)

Index: linux-2.6.27-rc1-mmotm-30jul/include/linux/vmstat.h
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/include/linux/vmstat.h	2008-07-30 12:56:30.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/include/linux/vmstat.h	2008-07-30 13:17:07.000000000 -0400
@@ -41,6 +41,11 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
+#ifdef CONFIG_UNEVICTABLE_LRU
+		UNEVICTABLE_PGCULLED,	/* culled to noreclaim list */
+		UNEVICTABLE_PGSCANNED,	/* scanned for reclaimability */
+		UNEVICTABLE_PGRESCUED,	/* rescued from noreclaim list */
+#endif
 		NR_VM_EVENT_ITEMS
 };
 
Index: linux-2.6.27-rc1-mmotm-30jul/mm/vmscan.c
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/mm/vmscan.c	2008-07-30 12:59:58.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/mm/vmscan.c	2008-07-30 13:17:21.000000000 -0400
@@ -484,6 +484,7 @@ void putback_lru_page(struct page *page)
 {
 	int lru;
 	int active = !!TestClearPageActive(page);
+	int was_unevictable = PageUnevictable(page);
 
 	VM_BUG_ON(PageLRU(page));
 
@@ -525,6 +526,11 @@ redo:
 		 */
 	}
 
+	if (was_unevictable && lru != LRU_UNEVICTABLE)
+		count_vm_event(UNEVICTABLE_PGRESCUED);
+	else if (!was_unevictable && lru == LRU_UNEVICTABLE)
+		count_vm_event(UNEVICTABLE_PGCULLED);
+
 	put_page(page);		/* drop ref from isolate */
 }
 
Index: linux-2.6.27-rc1-mmotm-30jul/mm/vmstat.c
===================================================================
--- linux-2.6.27-rc1-mmotm-30jul.orig/mm/vmstat.c	2008-07-30 13:08:07.000000000 -0400
+++ linux-2.6.27-rc1-mmotm-30jul/mm/vmstat.c	2008-07-30 13:16:17.000000000 -0400
@@ -663,6 +663,11 @@ static const char * const vmstat_text[] 
 	"htlb_buddy_alloc_success",
 	"htlb_buddy_alloc_fail",
 #endif
+#ifdef CONFIG_UNEVICTABLE_LRU
+	"unevictable_pgs_culled",
+	"unevictable_pgs_scanned",
+	"unevictable_pgs_rescued",
+#endif
 #endif
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
