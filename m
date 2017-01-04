Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B42E96B0267
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 05:19:57 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u144so83063769wmu.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:19:57 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id ey12si80853034wjc.243.2017.01.04.02.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 02:19:56 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id qs7so37298101wjc.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 02:19:56 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/7] mm, vmscan: show the number of skipped pages in mm_vmscan_lru_isolate
Date: Wed,  4 Jan 2017 11:19:38 +0100
Message-Id: <20170104101942.4860-4-mhocko@kernel.org>
In-Reply-To: <20170104101942.4860-1-mhocko@kernel.org>
References: <20170104101942.4860-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

mm_vmscan_lru_isolate shows the number of requested, scanned and taken
pages. This is mostly OK but on 32b systems the number of scanned pages
is quite misleading because it includes both the scanned and skipped
pages.  Moreover the skipped part is scaled based on the number of taken
pages. Let's report the exact numbers without any additional logic and
add the number of skipped pages. This should make the reported data much
more easier to interpret.

Acked-by: Minchan Kim <minchan@kernel.org>
Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/trace/events/vmscan.h |  8 ++++++--
 mm/vmscan.c                   | 10 +++++-----
 2 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 087c0b625ba7..36c999f806bf 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -274,17 +274,19 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
 		int order,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
+		unsigned long nr_skipped,
 		unsigned long nr_taken,
 		isolate_mode_t isolate_mode,
 		int file),
 
-	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file),
+	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_skipped, nr_taken, isolate_mode, file),
 
 	TP_STRUCT__entry(
 		__field(int, classzone_idx)
 		__field(int, order)
 		__field(unsigned long, nr_requested)
 		__field(unsigned long, nr_scanned)
+		__field(unsigned long, nr_skipped)
 		__field(unsigned long, nr_taken)
 		__field(isolate_mode_t, isolate_mode)
 		__field(int, file)
@@ -295,17 +297,19 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
 		__entry->order = order;
 		__entry->nr_requested = nr_requested;
 		__entry->nr_scanned = nr_scanned;
+		__entry->nr_skipped = nr_skipped;
 		__entry->nr_taken = nr_taken;
 		__entry->isolate_mode = isolate_mode;
 		__entry->file = file;
 	),
 
-	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu file=%d",
+	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_skipped=%lu nr_taken=%lu file=%d",
 		__entry->isolate_mode,
 		__entry->classzone_idx,
 		__entry->order,
 		__entry->nr_requested,
 		__entry->nr_scanned,
+		__entry->nr_skipped,
 		__entry->nr_taken,
 		__entry->file)
 );
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 70d1c55463c0..31c623d5acb4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1428,6 +1428,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_taken = 0;
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
+	unsigned long skipped = 0, total_skipped = 0;
 	unsigned long scan, nr_pages;
 	LIST_HEAD(pages_skipped);
 
@@ -1479,14 +1480,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	 */
 	if (!list_empty(&pages_skipped)) {
 		int zid;
-		unsigned long total_skipped = 0;
 
 		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 			if (!nr_skipped[zid])
 				continue;
 
 			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
-			total_skipped += nr_skipped[zid];
+			skipped += nr_skipped[zid];
 		}
 
 		/*
@@ -1494,13 +1494,13 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		 * close to unreclaimable. If the LRU list is empty, account
 		 * skipped pages as a full scan.
 		 */
-		scan += list_empty(src) ? total_skipped : total_skipped >> 2;
+		total_skipped = list_empty(src) ? skipped : skipped >> 2;
 
 		list_splice(&pages_skipped, src);
 	}
-	*nr_scanned = scan;
+	*nr_scanned = scan + total_skipped;
 	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
-				    nr_taken, mode, is_file_lru(lru));
+				    skipped, nr_taken, mode, is_file_lru(lru));
 	update_lru_sizes(lruvec, lru, nr_zone_taken, nr_taken);
 	return nr_taken;
 }
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
