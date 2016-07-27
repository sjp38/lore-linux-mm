Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 541616B025F
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 03:29:13 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id i199so34690020ioi.2
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 00:29:13 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d45si4110829ote.16.2016.07.27.00.29.11
        for <linux-mm@kvack.org>;
        Wed, 27 Jul 2016 00:29:12 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 1/2] mm: add skipped count and more lru information to trace
Date: Wed, 27 Jul 2016 16:29:47 +0900
Message-Id: <1469604588-6051-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>

The skipped count is important to investgate reclaim overhead problem
so let's add it. As well, isolation happens both active and inactive
lru list with decreasing priority so with that, it helps to identify
which lru list we are scanning at which priority now.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 .../trace/postprocess/trace-vmscan-postprocess.pl  | 10 +++---
 include/trace/events/vmscan.h                      | 39 ++++++++++++++++------
 mm/vmscan.c                                        |  6 ++--
 3 files changed, 37 insertions(+), 18 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
index 8f961ef..461203d 100644
--- a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -112,7 +112,7 @@ my $regex_direct_end_default = 'nr_reclaimed=([0-9]*)';
 my $regex_kswapd_wake_default = 'nid=([0-9]*) order=([0-9]*)';
 my $regex_kswapd_sleep_default = 'nid=([0-9]*)';
 my $regex_wakeup_kswapd_default = 'nid=([0-9]*) zid=([0-9]*) order=([0-9]*)';
-my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) order=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_taken=([0-9]*) file=([0-9]*)';
+my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) order=([0-9]*) priority=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_taken=([0-9]*) nr_skipped=([0-9]*) lru=([A-Z_]*)';
 my $regex_lru_shrink_inactive_default = 'nid=([0-9]*) zid=([0-9]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) priority=([0-9]*) flags=([A-Z_|]*)';
 my $regex_lru_shrink_active_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_rotated=([0-9]*) priority=([0-9]*)';
 my $regex_writepage_default = 'page=([0-9a-f]*) pfn=([0-9]*) flags=([A-Z_|]*)';
@@ -207,7 +207,7 @@ $regex_lru_isolate = generate_traceevent_regex(
 			$regex_lru_isolate_default,
 			"isolate_mode", "order",
 			"nr_requested", "nr_scanned", "nr_taken",
-			"file");
+			"nr_skipped", "lru");
 $regex_lru_shrink_inactive = generate_traceevent_regex(
 			"vmscan/mm_vmscan_lru_shrink_inactive",
 			$regex_lru_shrink_inactive_default,
@@ -381,8 +381,8 @@ sub process_events {
 				next;
 			}
 			my $isolate_mode = $1;
-			my $nr_scanned = $4;
-			my $file = $6;
+			my $nr_scanned = $5;
+			my $lru = $8;
 
 			# To closer match vmstat scanning statistics, only count isolate_both
 			# and isolate_inactive as scanning. isolate_active is rotation
@@ -391,7 +391,7 @@ sub process_events {
 			# isolate_both     == 3
 			if ($isolate_mode != 2) {
 				$perprocesspid{$process_pid}->{HIGH_NR_SCANNED} += $nr_scanned;
-				if ($file == 1) {
+				if ($lru =~ /file/) {
 					$perprocesspid{$process_pid}->{HIGH_NR_FILE_SCANNED} += $nr_scanned;
 				} else {
 					$perprocesspid{$process_pid}->{HIGH_NR_ANON_SCANNED} += $nr_scanned;
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index c88fd09..67f479d 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -273,55 +273,71 @@ DECLARE_EVENT_CLASS(mm_vmscan_lru_isolate_template,
 
 	TP_PROTO(int classzone_idx,
 		int order,
+		int priority,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
+		unsigned long nr_skipped,
 		isolate_mode_t isolate_mode,
-		int file),
+		enum lru_list lru),
 
-	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file),
+	TP_ARGS(classzone_idx, order, priority, nr_requested, nr_scanned,
+		nr_taken, nr_skipped, isolate_mode, lru),
 
 	TP_STRUCT__entry(
 		__field(int, classzone_idx)
 		__field(int, order)
+		__field(int, priority)
 		__field(unsigned long, nr_requested)
 		__field(unsigned long, nr_scanned)
 		__field(unsigned long, nr_taken)
+		__field(unsigned long, nr_skipped)
 		__field(isolate_mode_t, isolate_mode)
-		__field(int, file)
+		__field(enum lru_list, lru)
 	),
 
 	TP_fast_assign(
 		__entry->classzone_idx = classzone_idx;
 		__entry->order = order;
+		__entry->priority = priority;
 		__entry->nr_requested = nr_requested;
 		__entry->nr_scanned = nr_scanned;
 		__entry->nr_taken = nr_taken;
+		__entry->nr_skipped = nr_skipped;
 		__entry->isolate_mode = isolate_mode;
-		__entry->file = file;
+		__entry->lru = lru;
 	),
 
-	TP_printk("isolate_mode=%d classzone=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu file=%d",
+	TP_printk("isolate_mode=%d classzone=%d order=%d priority=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu nr_skipped=%lu lru=%s",
 		__entry->isolate_mode,
 		__entry->classzone_idx,
 		__entry->order,
+		__entry->priority,
 		__entry->nr_requested,
 		__entry->nr_scanned,
 		__entry->nr_taken,
-		__entry->file)
+		__entry->nr_skipped,
+		__print_symbolic(__entry->lru,
+			{ LRU_INACTIVE_ANON, "ia_anon"},
+			{ LRU_ACTIVE_ANON, "ac_anon"},
+			{ LRU_INACTIVE_FILE, "ia_file"},
+			{ LRU_ACTIVE_FILE, "ac_file"}))
 );
 
 DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_lru_isolate,
 
 	TP_PROTO(int classzone_idx,
 		int order,
+		int priority,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
+		unsigned long nr_skipped,
 		isolate_mode_t isolate_mode,
-		int file),
+		enum lru_list lru),
 
-	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
+	TP_ARGS(classzone_idx, order, priority, nr_requested, nr_scanned,
+		nr_taken, nr_skipped, isolate_mode, lru)
 
 );
 
@@ -329,13 +345,16 @@ DEFINE_EVENT(mm_vmscan_lru_isolate_template, mm_vmscan_memcg_isolate,
 
 	TP_PROTO(int classzone_idx,
 		int order,
+		int priority,
 		unsigned long nr_requested,
 		unsigned long nr_scanned,
 		unsigned long nr_taken,
+		unsigned long nr_skipped,
 		isolate_mode_t isolate_mode,
-		int file),
+		enum lru_list lru),
 
-	TP_ARGS(classzone_idx, order, nr_requested, nr_scanned, nr_taken, isolate_mode, file)
+	TP_ARGS(classzone_idx, order, priority, nr_requested, nr_scanned,
+		nr_taken, nr_skipped, isolate_mode, lru)
 
 );
 
diff --git a/mm/vmscan.c b/mm/vmscan.c
index e5af357..f8ded2b 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1421,6 +1421,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	unsigned long nr_zone_taken[MAX_NR_ZONES] = { 0 };
 	unsigned long nr_skipped[MAX_NR_ZONES] = { 0, };
 	unsigned long scan, nr_pages;
+	unsigned long total_skipped = 0;
 	LIST_HEAD(pages_skipped);
 
 	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
@@ -1471,7 +1472,6 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 	 */
 	if (!list_empty(&pages_skipped)) {
 		int zid;
-		unsigned long total_skipped = 0;
 
 		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
 			if (!nr_skipped[zid])
@@ -1491,8 +1491,8 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		list_splice(&pages_skipped, src);
 	}
 	*nr_scanned = scan;
-	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
-				    nr_taken, mode, is_file_lru(lru));
+	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, sc->priority,
+			nr_to_scan, scan, nr_taken, total_skipped, mode, lru);
 	update_lru_sizes(lruvec, lru, nr_zone_taken, nr_taken);
 	return nr_taken;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
