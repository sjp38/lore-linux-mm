Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2A8016B0261
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 10:11:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id p129so14278163wmp.3
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:11:15 -0700 (PDT)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id 6si1701773uap.36.2016.07.21.07.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 07:11:04 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id AC7AC1C1FAA
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 15:11:03 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 5/5] mm, vmscan: Account for skipped pages as a partial scan
Date: Thu, 21 Jul 2016 15:11:01 +0100
Message-Id: <1469110261-7365-6-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Page reclaim determines whether a pgdat is unreclaimable by examining how
many pages have been scanned since a page was freed and comparing that to
the LRU sizes. Skipped pages are not reclaim candidates but contribute to
scanned. This can prematurely mark a pgdat as unreclaimable and trigger
an OOM kill.

This patch accounts for skipped pages as a partial scan so that an
unreclaimable pgdat will still be marked as such but by scaling the cost
of a skip, it'll avoid the pgdat being marked prematurely.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmscan.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6810d81f60c7..e5af357dd4ac 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1424,7 +1424,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
-					!list_empty(src); scan++) {
+					!list_empty(src);) {
 		struct page *page;
 
 		page = lru_to_page(src);
@@ -1438,6 +1438,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			continue;
 		}
 
+		/*
+		 * Account for scanned and skipped separetly to avoid the pgdat
+		 * being prematurely marked unreclaimable by pgdat_reclaimable.
+		 */
+		scan++;
+
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
 			nr_pages = hpage_nr_pages(page);
@@ -1465,14 +1471,24 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	 */
 	if (!list_empty(&pages_skipped)) {
 		int zid;
+		unsigned long total_skipped = 0;
 
-		list_splice(&pages_skipped, src);
 		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 			if (!nr_skipped[zid])
 				continue;
 
 			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
+			total_skipped += nr_skipped[zid];
 		}
+
+		/*
+		 * Account skipped pages as a partial scan as the pgdat may be
+		 * close to unreclaimable. If the LRU list is empty, account
+		 * skipped pages as a full scan.
+		 */
+		scan += list_empty(src) ? total_skipped : total_skipped >> 2;
+
+		list_splice(&pages_skipped, src);
 	}
 	*nr_scanned = scan;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
