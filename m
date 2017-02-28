Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2585F6B0391
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 16:46:32 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id q39so9391105wrb.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 13:46:32 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id j59si3965427wrj.283.2017.02.28.13.46.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 13:46:31 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 8/9] Revert "mm, vmscan: account for skipped pages as a partial scan"
Date: Tue, 28 Feb 2017 16:40:06 -0500
Message-Id: <20170228214007.5621-9-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-1-hannes@cmpxchg.org>
References: <20170228214007.5621-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jia He <hejianet@gmail.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

This reverts commit d7f05528eedb047efe2288cff777676b028747b6.

Now that reclaimability of a node is no longer based on the ratio
between pages scanned and theoretically reclaimable pages, we can
remove accounting tricks for pages skipped due to zone constraints.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/vmscan.c | 22 ++++------------------
 1 file changed, 4 insertions(+), 18 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 35b791a8922b..ddcff8a11c1e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1471,12 +1471,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_taken = 0;
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
-	unsigned long skipped = 0, total_skipped = 0;
+	unsigned long skipped = 0;
 	unsigned long scan, nr_pages;
 	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
-					!list_empty(src);) {
+					!list_empty(src); scan++) {
 		struct page *page;
 
 		page = lru_to_page(src);
@@ -1490,12 +1490,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			continue;
 		}
 
-		/*
-		 * Account for scanned and skipped separetly to avoid the pgdat
-		 * being prematurely marked unreclaimable by pgdat_reclaimable.
-		 */
-		scan++;
-
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			nr_pages = hpage_nr_pages(page);
@@ -1524,6 +1518,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	if (!list_empty(&pages_skipped)) {
 		int zid;
 
+		list_splice(&pages_skipped, src);
 		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 			if (!nr_skipped[zid])
 				continue;
@@ -1531,17 +1526,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
 			skipped += nr_skipped[zid];
 		}
-
-		/*
-		 * Account skipped pages as a partial scan as the pgdat may be
-		 * close to unreclaimable. If the LRU list is empty, account
-		 * skipped pages as a full scan.
-		 */
-		total_skipped = list_empty(src) ? skipped : skipped >> 2;
-
-		list_splice(&pages_skipped, src);
 	}
-	*nr_scanned = scan + total_skipped;
+	*nr_scanned = scan;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan,
 				    scan, skipped, nr_taken, mode, lru);
 	update_lru_sizes(lruvec, lru, nr_zone_taken);
-- 
2.11.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
