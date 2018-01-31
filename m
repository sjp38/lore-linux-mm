Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 547B96B000E
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 18:04:33 -0500 (EST)
Received: by mail-ua0-f199.google.com with SMTP id j3so11475363ual.3
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 15:04:33 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z206si1346621vkd.296.2018.01.31.15.04.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 15:04:32 -0800 (PST)
From: daniel.m.jordan@oracle.com
Subject: [RFC PATCH v1 04/13] mm: introduce struct lru_list_head in lruvec to hold per-LRU batch info
Date: Wed, 31 Jan 2018 18:04:04 -0500
Message-Id: <20180131230413.27653-5-daniel.m.jordan@oracle.com>
In-Reply-To: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
References: <20180131230413.27653-1-daniel.m.jordan@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, Dave.Dice@oracle.com, dave@stgolabs.net, khandual@linux.vnet.ibm.com, ldufour@linux.vnet.ibm.com, mgorman@suse.de, mhocko@kernel.org, pasha.tatashin@oracle.com, steven.sistare@oracle.com, yossi.lev@oracle.com

Add information about the first and last LRU batches in struct lruvec.

lruvec's list_head is replaced with a pseudo struct page to avoid
special-casing LRU batch handling at the front or back of the LRU.  This
pseudo page has its own lru_batch and lru_sentinel fields so that the
same code that deals with "inner" LRU pages (i.e. neither the first nor
the last page) can deal with the first and last pages.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
---
 include/linux/mm_inline.h |  4 ++--
 include/linux/mmzone.h    | 13 ++++++++++++-
 mm/mmzone.c               |  7 +++++--
 mm/swap.c                 |  2 +-
 mm/vmscan.c               |  4 ++--
 5 files changed, 22 insertions(+), 8 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index c30b32e3c862..d7fc46ebc33b 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -48,14 +48,14 @@ static __always_inline void add_page_to_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
 	update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
-	list_add(&page->lru, &lruvec->lists[lru]);
+	list_add(&page->lru, lru_head(&lruvec->lists[lru]));
 }
 
 static __always_inline void add_page_to_lru_list_tail(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
 	update_lru_size(lruvec, lru, page_zonenum(page), hpage_nr_pages(page));
-	list_add_tail(&page->lru, &lruvec->lists[lru]);
+	list_add_tail(&page->lru, lru_head(&lruvec->lists[lru]));
 }
 
 static __always_inline void del_page_from_lru_list(struct page *page,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5ffb36b3f665..feca75b8f492 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -18,6 +18,7 @@
 #include <linux/pageblock-flags.h>
 #include <linux/page-flags-layout.h>
 #include <linux/atomic.h>
+#include <linux/mm_types.h>
 #include <asm/page.h>
 
 /* Free memory management - zoned buddy allocator.  */
@@ -232,8 +233,18 @@ struct zone_reclaim_stat {
 	unsigned long		recent_scanned[2];
 };
 
+#define lru_head(lru_list_head)	(&(lru_list_head)->pseudo_page.lru)
+
+struct lru_list_head {
+	struct page		pseudo_page;
+	unsigned		first_batch_npages;
+	unsigned		first_batch_tag;
+	unsigned		last_batch_npages;
+	unsigned		last_batch_tag;
+};
+
 struct lruvec {
-	struct list_head		lists[NR_LRU_LISTS];
+	struct lru_list_head		lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat	reclaim_stat;
 	/* Evictions & activations on the inactive file list */
 	atomic_long_t			inactive_age;
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 4686fdc23bb9..c39fc6af3f13 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -92,8 +92,11 @@ void lruvec_init(struct lruvec *lruvec)
 
 	memset(lruvec, 0, sizeof(struct lruvec));
 
-	for_each_lru(lru)
-		INIT_LIST_HEAD(&lruvec->lists[lru]);
+	for_each_lru(lru) {
+		INIT_LIST_HEAD(lru_head(&lruvec->lists[lru]));
+		lruvec->lists[lru].pseudo_page.lru_sentinel = true;
+		lruvec->lists[lru].pseudo_page.lru_batch = NUM_LRU_BATCH_LOCKS;
+	}
 }
 
 #if defined(CONFIG_NUMA_BALANCING) && !defined(LAST_CPUPID_NOT_IN_PAGE_FLAGS)
diff --git a/mm/swap.c b/mm/swap.c
index 38e1b6374a97..286636bb6a4f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -561,7 +561,7 @@ static void lru_deactivate_file_fn(struct page *page, struct lruvec *lruvec,
 		 * The page's writeback ends up during pagevec
 		 * We moves tha page into tail of inactive.
 		 */
-		list_move_tail(&page->lru, &lruvec->lists[lru]);
+		list_move_tail(&page->lru, lru_head(&lruvec->lists[lru]));
 		__count_vm_event(PGROTATED);
 	}
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 47d5ced51f2d..aa629c4720dd 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1511,7 +1511,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		unsigned long *nr_scanned, struct scan_control *sc,
 		isolate_mode_t mode, enum lru_list lru)
 {
-	struct list_head *src = &lruvec->lists[lru];
+	struct list_head *src = lru_head(&lruvec->lists[lru]);
 	unsigned long nr_taken = 0;
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
@@ -1943,7 +1943,7 @@ static unsigned move_active_pages_to_lru(struct lruvec *lruvec,
 
 		nr_pages = hpage_nr_pages(page);
 		update_lru_size(lruvec, lru, page_zonenum(page), nr_pages);
-		list_move(&page->lru, &lruvec->lists[lru]);
+		list_move(&page->lru, lru_head(&lruvec->lists[lru]));
 
 		if (put_page_testzero(page)) {
 			__ClearPageLRU(page);
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
