Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 79D2B6B00F3
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 05:38:52 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id rp16so813674pbb.24
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:38:51 -0700 (PDT)
Received: from mail-pb0-x234.google.com (mail-pb0-x234.google.com [2607:f8b0:400e:c01::234])
        by mx.google.com with ESMTPS id qn15si488700pab.176.2014.06.12.02.38.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 02:38:51 -0700 (PDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so817710pbb.39
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:38:50 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] mm/vmscan.c: wrap five parameters into arg_container in shrink_page_list()
Date: Thu, 12 Jun 2014 17:36:35 +0800
Message-Id: <1402565795-706-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, hannes@cmpxchg.org, mhocko@suse.cz, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Yucong <slaoub@gmail.com>

shrink_page_list() has too many arguments that have already reached ten.
Some of those arguments and temporary variables introduces extra 80 bytes
on the stack.

This patch wraps five parameters into arg_container and removes some temporary
variables, thus making shrink_page_list() to consume fewer stack space.

Before mm/vmscan.c is modified:
   text	   data	    bss	    dec	    hex	filename
6876698	 957224	 966656	8800578	 864942	vmlinux-3.15

After mm/vmscan.c is changed:
   text	   data	    bss	    dec	    hex	filename
6876506	 957224	 966656	8800386	 864882	vmlinux-3.15

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 mm/vmscan.c |   64 +++++++++++++++++++++++++++--------------------------------
 1 file changed, 29 insertions(+), 35 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index a8ffe4e..538cdcf 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -790,6 +790,14 @@ static void page_check_dirty_writeback(struct page *page,
 		mapping->a_ops->is_dirty_writeback(page, dirty, writeback);
 }
 
+struct arg_container {
+	unsigned long nr_dirty;
+	unsigned long nr_unqueued_dirty;
+	unsigned long nr_congested;
+	unsigned long nr_writeback;
+	unsigned long nr_immediate;
+};
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -797,22 +805,13 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      struct zone *zone,
 				      struct scan_control *sc,
 				      enum ttu_flags ttu_flags,
-				      unsigned long *ret_nr_dirty,
-				      unsigned long *ret_nr_unqueued_dirty,
-				      unsigned long *ret_nr_congested,
-				      unsigned long *ret_nr_writeback,
-				      unsigned long *ret_nr_immediate,
+				      struct arg_container *ac,
 				      bool force_reclaim)
 {
 	LIST_HEAD(ret_pages);
 	LIST_HEAD(free_pages);
 	int pgactivate = 0;
-	unsigned long nr_unqueued_dirty = 0;
-	unsigned long nr_dirty = 0;
-	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
-	unsigned long nr_writeback = 0;
-	unsigned long nr_immediate = 0;
 
 	cond_resched();
 
@@ -858,10 +857,10 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 */
 		page_check_dirty_writeback(page, &dirty, &writeback);
 		if (dirty || writeback)
-			nr_dirty++;
+			ac->nr_dirty++;
 
 		if (dirty && !writeback)
-			nr_unqueued_dirty++;
+			ac->nr_unqueued_dirty++;
 
 		/*
 		 * Treat this page as congested if the underlying BDI is or if
@@ -872,7 +871,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		mapping = page_mapping(page);
 		if ((mapping && bdi_write_congested(mapping->backing_dev_info)) ||
 		    (writeback && PageReclaim(page)))
-			nr_congested++;
+			ac->nr_congested++;
 
 		/*
 		 * If a page at the tail of the LRU is under writeback, there
@@ -916,7 +915,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			if (current_is_kswapd() &&
 			    PageReclaim(page) &&
 			    zone_is_reclaim_writeback(zone)) {
-				nr_immediate++;
+				ac->nr_immediate++;
 				goto keep_locked;
 
 			/* Case 2 above */
@@ -934,7 +933,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				 * and it's also appropriate in global reclaim.
 				 */
 				SetPageReclaim(page);
-				nr_writeback++;
+				ac->nr_writeback++;
 
 				goto keep_locked;
 
@@ -1132,11 +1131,6 @@ keep:
 	list_splice(&ret_pages, page_list);
 	count_vm_events(PGACTIVATE, pgactivate);
 	mem_cgroup_uncharge_end();
-	*ret_nr_dirty += nr_dirty;
-	*ret_nr_congested += nr_congested;
-	*ret_nr_unqueued_dirty += nr_unqueued_dirty;
-	*ret_nr_writeback += nr_writeback;
-	*ret_nr_immediate += nr_immediate;
 	return nr_reclaimed;
 }
 
@@ -1148,7 +1142,8 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		.priority = DEF_PRIORITY,
 		.may_unmap = 1,
 	};
-	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
+	unsigned long ret;
+	struct arg_container dummy;
 	struct page *page, *next;
 	LIST_HEAD(clean_pages);
 
@@ -1161,8 +1156,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 	}
 
 	ret = shrink_page_list(&clean_pages, zone, &sc,
-			TTU_UNMAP|TTU_IGNORE_ACCESS,
-			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
+			TTU_UNMAP|TTU_IGNORE_ACCESS, &dummy, true);
 	list_splice(&clean_pages, page_list);
 	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
 	return ret;
@@ -1469,11 +1463,13 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_scanned;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_taken;
-	unsigned long nr_dirty = 0;
-	unsigned long nr_congested = 0;
-	unsigned long nr_unqueued_dirty = 0;
-	unsigned long nr_writeback = 0;
-	unsigned long nr_immediate = 0;
+	struct arg_container ac = {
+		.nr_dirty = 0,
+		.nr_congested = 0,
+		.nr_unqueued_dirty = 0,
+		.nr_writeback = 0,
+		.nr_immediate = 0,
+	};
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct zone *zone = lruvec_zone(lruvec);
@@ -1515,9 +1511,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		return 0;
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
-				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
-				&nr_writeback, &nr_immediate,
-				false);
+					&ac, false);
 
 	spin_lock_irq(&zone->lru_lock);
 
@@ -1554,7 +1548,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 * of pages under pages flagged for immediate reclaim and stall if any
 	 * are encountered in the nr_immediate check below.
 	 */
-	if (nr_writeback && nr_writeback == nr_taken)
+	if (ac.nr_writeback && ac.nr_writeback == nr_taken)
 		zone_set_flag(zone, ZONE_WRITEBACK);
 
 	/*
@@ -1566,7 +1560,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * Tag a zone as congested if all the dirty pages scanned were
 		 * backed by a congested BDI and wait_iff_congested will stall.
 		 */
-		if (nr_dirty && nr_dirty == nr_congested)
+		if (ac.nr_dirty && ac.nr_dirty == ac.nr_congested)
 			zone_set_flag(zone, ZONE_CONGESTED);
 
 		/*
@@ -1576,7 +1570,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * pages from reclaim context. It will forcibly stall in the
 		 * next check.
 		 */
-		if (nr_unqueued_dirty == nr_taken)
+		if (ac.nr_unqueued_dirty == nr_taken)
 			zone_set_flag(zone, ZONE_TAIL_LRU_DIRTY);
 
 		/*
@@ -1585,7 +1579,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 		 * implies that pages are cycling through the LRU faster than
 		 * they are written so also forcibly stall.
 		 */
-		if ((nr_unqueued_dirty == nr_taken || nr_immediate) &&
+		if ((ac.nr_unqueued_dirty == nr_taken || ac.nr_immediate) &&
 		    current_may_throttle())
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
