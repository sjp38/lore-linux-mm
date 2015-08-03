Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 54CFA9003CB
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 06:19:38 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so72259384pdb.0
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 03:19:38 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id f2si25588955pat.213.2015.08.03.03.19.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Aug 2015 03:19:37 -0700 (PDT)
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSI01TMU4OMG7A0@mailout4.samsung.com> for linux-mm@kvack.org;
 Mon, 03 Aug 2015 19:19:34 +0900 (KST)
From: Jaewon Kim <jaewon31.kim@samsung.com>
Subject: [PATCH] vmscan: reclaim_clean_pages_from_list() must count mlocked
 pages
Date: Mon, 03 Aug 2015 19:18:27 +0900
Message-id: <1438597107-18329-1-git-send-email-jaewon31.kim@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jaewon31.kim@gmail.com, Jaewon Kim <jaewon31.kim@samsung.com>

reclaim_clean_pages_from_list() decreases NR_ISOLATED_FILE by returned
value from shrink_page_list(). But mlocked pages in the isolated
clean_pages page list would be removed from the list but not counted as
nr_reclaimed. Fix this miscounting by returning the number of mlocked
pages and count it.

Signed-off-by: Jaewon Kim <jaewon31.kim@samsung.com>
---
 mm/vmscan.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 5e8eadd..5837695 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -849,6 +849,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				      unsigned long *ret_nr_congested,
 				      unsigned long *ret_nr_writeback,
 				      unsigned long *ret_nr_immediate,
+				      unsigned long *ret_nr_mlocked,
 				      bool force_reclaim)
 {
 	LIST_HEAD(ret_pages);
@@ -1158,6 +1159,7 @@ cull_mlocked:
 			try_to_free_swap(page);
 		unlock_page(page);
 		putback_lru_page(page);
+		(*ret_nr_mlocked)++;
 		continue;
 
 activate_locked:
@@ -1197,6 +1199,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 		.may_unmap = 1,
 	};
 	unsigned long ret, dummy1, dummy2, dummy3, dummy4, dummy5;
+	unsigned long nr_mlocked = 0;
 	struct page *page, *next;
 	LIST_HEAD(clean_pages);
 
@@ -1210,8 +1213,10 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 
 	ret = shrink_page_list(&clean_pages, zone, &sc,
 			TTU_UNMAP|TTU_IGNORE_ACCESS,
-			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
+			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5,
+			&nr_mlocked, true);
 	list_splice(&clean_pages, page_list);
+	ret += nr_mlocked;
 	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
 	return ret;
 }
@@ -1523,6 +1528,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	unsigned long nr_unqueued_dirty = 0;
 	unsigned long nr_writeback = 0;
 	unsigned long nr_immediate = 0;
+	unsigned long nr_mlocked = 0;
 	isolate_mode_t isolate_mode = 0;
 	int file = is_file_lru(lru);
 	struct zone *zone = lruvec_zone(lruvec);
@@ -1565,7 +1571,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 
 	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
 				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
-				&nr_writeback, &nr_immediate,
+				&nr_writeback, &nr_immediate, &nr_mlocked,
 				false);
 
 	spin_lock_irq(&zone->lru_lock);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
