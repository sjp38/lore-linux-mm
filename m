Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2A46B6B0047
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 06:47:38 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 01/10] tracing, vmscan: Add trace events for LRU list shrinking
Date: Mon,  6 Sep 2010 11:47:24 +0100
Message-Id: <1283770053-18833-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
References: <1283770053-18833-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch adds a trace event for shrink_inactive_list(). It can be used
to determine how many pages were reclaimed and for non-lumpy reclaim where
exactly the pages were reclaimed from.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 .../trace/postprocess/trace-vmscan-postprocess.pl  |   39 +++++++++++++-----
 include/trace/events/vmscan.h                      |   42 ++++++++++++++++++++
 mm/vmscan.c                                        |    6 +++
 3 files changed, 77 insertions(+), 10 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
index 1b55146..b3e73dd 100644
--- a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -46,7 +46,7 @@ use constant HIGH_KSWAPD_LATENCY		=> 20;
 use constant HIGH_KSWAPD_REWAKEUP		=> 21;
 use constant HIGH_NR_SCANNED			=> 22;
 use constant HIGH_NR_TAKEN			=> 23;
-use constant HIGH_NR_RECLAIM			=> 24;
+use constant HIGH_NR_RECLAIMED			=> 24;
 use constant HIGH_NR_CONTIG_DIRTY		=> 25;
 
 my %perprocesspid;
@@ -58,11 +58,13 @@ my $opt_read_procstat;
 my $total_wakeup_kswapd;
 my ($total_direct_reclaim, $total_direct_nr_scanned);
 my ($total_direct_latency, $total_kswapd_latency);
+my ($total_direct_nr_reclaimed);
 my ($total_direct_writepage_file_sync, $total_direct_writepage_file_async);
 my ($total_direct_writepage_anon_sync, $total_direct_writepage_anon_async);
 my ($total_kswapd_nr_scanned, $total_kswapd_wake);
 my ($total_kswapd_writepage_file_sync, $total_kswapd_writepage_file_async);
 my ($total_kswapd_writepage_anon_sync, $total_kswapd_writepage_anon_async);
+my ($total_kswapd_nr_reclaimed);
 
 # Catch sigint and exit on request
 my $sigint_report = 0;
@@ -104,7 +106,7 @@ my $regex_kswapd_wake_default = 'nid=([0-9]*) order=([0-9]*)';
 my $regex_kswapd_sleep_default = 'nid=([0-9]*)';
 my $regex_wakeup_kswapd_default = 'nid=([0-9]*) zid=([0-9]*) order=([0-9]*)';
 my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) order=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_taken=([0-9]*) contig_taken=([0-9]*) contig_dirty=([0-9]*) contig_failed=([0-9]*)';
-my $regex_lru_shrink_inactive_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) priority=([0-9]*)';
+my $regex_lru_shrink_inactive_default = 'nid=([0-9]*) zid=([0-9]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) priority=([0-9]*) flags=([A-Z_|]*)';
 my $regex_lru_shrink_active_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_rotated=([0-9]*) priority=([0-9]*)';
 my $regex_writepage_default = 'page=([0-9a-f]*) pfn=([0-9]*) flags=([A-Z_|]*)';
 
@@ -203,8 +205,8 @@ $regex_lru_shrink_inactive = generate_traceevent_regex(
 			"vmscan/mm_vmscan_lru_shrink_inactive",
 			$regex_lru_shrink_inactive_default,
 			"nid", "zid",
-			"lru",
-			"nr_scanned", "nr_reclaimed", "priority");
+			"nr_scanned", "nr_reclaimed", "priority",
+			"flags");
 $regex_lru_shrink_active = generate_traceevent_regex(
 			"vmscan/mm_vmscan_lru_shrink_active",
 			$regex_lru_shrink_active_default,
@@ -375,6 +377,16 @@ EVENT_PROCESS:
 			my $nr_contig_dirty = $7;
 			$perprocesspid{$process_pid}->{HIGH_NR_SCANNED} += $nr_scanned;
 			$perprocesspid{$process_pid}->{HIGH_NR_CONTIG_DIRTY} += $nr_contig_dirty;
+		} elsif ($tracepoint eq "mm_vmscan_lru_shrink_inactive") {
+			$details = $5;
+			if ($details !~ /$regex_lru_shrink_inactive/o) {
+				print "WARNING: Failed to parse mm_vmscan_lru_shrink_inactive as expected\n";
+				print "         $details\n";
+				print "         $regex_lru_shrink_inactive/o\n";
+				next;
+			}
+			my $nr_reclaimed = $4;
+			$perprocesspid{$process_pid}->{HIGH_NR_RECLAIMED} += $nr_reclaimed;
 		} elsif ($tracepoint eq "mm_vmscan_writepage") {
 			$details = $5;
 			if ($details !~ /$regex_writepage/o) {
@@ -464,8 +476,8 @@ sub dump_stats {
 
 	# Print out process activity
 	printf("\n");
-	printf("%-" . $max_strlen . "s %8s %10s   %8s   %8s %8s %8s %8s\n", "Process", "Direct",  "Wokeup", "Pages",   "Pages",   "Pages",     "Time");
-	printf("%-" . $max_strlen . "s %8s %10s   %8s   %8s %8s %8s %8s\n", "details", "Rclms",   "Kswapd", "Scanned", "Sync-IO", "ASync-IO",  "Stalled");
+	printf("%-" . $max_strlen . "s %8s %10s   %8s %8s  %8s %8s %8s %8s\n", "Process", "Direct",  "Wokeup", "Pages",   "Pages",   "Pages",   "Pages",     "Time");
+	printf("%-" . $max_strlen . "s %8s %10s   %8s %8s  %8s %8s %8s %8s\n", "details", "Rclms",   "Kswapd", "Scanned", "Rclmed",  "Sync-IO", "ASync-IO",  "Stalled");
 	foreach $process_pid (keys %stats) {
 
 		if (!$stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN}) {
@@ -475,6 +487,7 @@ sub dump_stats {
 		$total_direct_reclaim += $stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN};
 		$total_wakeup_kswapd += $stats{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD};
 		$total_direct_nr_scanned += $stats{$process_pid}->{HIGH_NR_SCANNED};
+		$total_direct_nr_reclaimed += $stats{$process_pid}->{HIGH_NR_RECLAIMED};
 		$total_direct_writepage_file_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC};
 		$total_direct_writepage_anon_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC};
 		$total_direct_writepage_file_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC};
@@ -489,11 +502,12 @@ sub dump_stats {
 			$index++;
 		}
 
-		printf("%-" . $max_strlen . "s %8d %10d   %8u   %8u %8u %8.3f",
+		printf("%-" . $max_strlen . "s %8d %10d   %8u %8u  %8u %8u %8.3f",
 			$process_pid,
 			$stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN},
 			$stats{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD},
 			$stats{$process_pid}->{HIGH_NR_SCANNED},
+			$stats{$process_pid}->{HIGH_NR_RECLAIMED},
 			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC} + $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC},
 			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC} + $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_ASYNC},
 			$this_reclaim_delay / 1000);
@@ -529,8 +543,8 @@ sub dump_stats {
 
 	# Print out kswapd activity
 	printf("\n");
-	printf("%-" . $max_strlen . "s %8s %10s   %8s   %8s %8s %8s\n", "Kswapd",   "Kswapd",  "Order",     "Pages",   "Pages",  "Pages");
-	printf("%-" . $max_strlen . "s %8s %10s   %8s   %8s %8s %8s\n", "Instance", "Wakeups", "Re-wakeup", "Scanned", "Sync-IO", "ASync-IO");
+	printf("%-" . $max_strlen . "s %8s %10s   %8s   %8s %8s %8s\n", "Kswapd",   "Kswapd",  "Order",     "Pages",   "Pages",   "Pages",  "Pages");
+	printf("%-" . $max_strlen . "s %8s %10s   %8s   %8s %8s %8s\n", "Instance", "Wakeups", "Re-wakeup", "Scanned", "Rclmed",  "Sync-IO", "ASync-IO");
 	foreach $process_pid (keys %stats) {
 
 		if (!$stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE}) {
@@ -539,16 +553,18 @@ sub dump_stats {
 
 		$total_kswapd_wake += $stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE};
 		$total_kswapd_nr_scanned += $stats{$process_pid}->{HIGH_NR_SCANNED};
+		$total_kswapd_nr_reclaimed += $stats{$process_pid}->{HIGH_NR_RECLAIMED};
 		$total_kswapd_writepage_file_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC};
 		$total_kswapd_writepage_anon_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC};
 		$total_kswapd_writepage_file_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC};
 		$total_kswapd_writepage_anon_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_ASYNC};
 
-		printf("%-" . $max_strlen . "s %8d %10d   %8u   %8i %8u",
+		printf("%-" . $max_strlen . "s %8d %10d   %8u %8u  %8i %8u",
 			$process_pid,
 			$stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE},
 			$stats{$process_pid}->{HIGH_KSWAPD_REWAKEUP},
 			$stats{$process_pid}->{HIGH_NR_SCANNED},
+			$stats{$process_pid}->{HIGH_NR_RECLAIMED},
 			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC} + $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC},
 			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC} + $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_ASYNC});
 
@@ -579,6 +595,7 @@ sub dump_stats {
 	print "\nSummary\n";
 	print "Direct reclaims:     			$total_direct_reclaim\n";
 	print "Direct reclaim pages scanned:		$total_direct_nr_scanned\n";
+	print "Direct reclaim pages reclaimed:		$total_direct_nr_reclaimed\n";
 	print "Direct reclaim write file sync I/O:	$total_direct_writepage_file_sync\n";
 	print "Direct reclaim write anon sync I/O:	$total_direct_writepage_anon_sync\n";
 	print "Direct reclaim write file async I/O:	$total_direct_writepage_file_async\n";
@@ -588,6 +605,7 @@ sub dump_stats {
 	print "\n";
 	print "Kswapd wakeups:				$total_kswapd_wake\n";
 	print "Kswapd pages scanned:			$total_kswapd_nr_scanned\n";
+	print "Kswapd pages reclaimed:			$total_kswapd_nr_reclaimed\n";
 	print "Kswapd reclaim write file sync I/O:	$total_kswapd_writepage_file_sync\n";
 	print "Kswapd reclaim write anon sync I/O:	$total_kswapd_writepage_anon_sync\n";
 	print "Kswapd reclaim write file async I/O:	$total_kswapd_writepage_file_async\n";
@@ -612,6 +630,7 @@ sub aggregate_perprocesspid() {
 		$perprocess{$process}->{MM_VMSCAN_WAKEUP_KSWAPD} += $perprocesspid{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD};
 		$perprocess{$process}->{HIGH_KSWAPD_REWAKEUP} += $perprocesspid{$process_pid}->{HIGH_KSWAPD_REWAKEUP};
 		$perprocess{$process}->{HIGH_NR_SCANNED} += $perprocesspid{$process_pid}->{HIGH_NR_SCANNED};
+		$perprocess{$process}->{HIGH_NR_RECLAIMED} += $perprocesspid{$process_pid}->{HIGH_NR_RECLAIMED};
 		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC};
 		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC};
 		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC};
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
index 370aa5a..14c1586 100644
--- a/include/trace/events/vmscan.h
+++ b/include/trace/events/vmscan.h
@@ -10,6 +10,7 @@
 
 #define RECLAIM_WB_ANON		0x0001u
 #define RECLAIM_WB_FILE		0x0002u
+#define RECLAIM_WB_MIXED	0x0010u
 #define RECLAIM_WB_SYNC		0x0004u
 #define RECLAIM_WB_ASYNC	0x0008u
 
@@ -17,6 +18,7 @@
 	(flags) ? __print_flags(flags, "|",			\
 		{RECLAIM_WB_ANON,	"RECLAIM_WB_ANON"},	\
 		{RECLAIM_WB_FILE,	"RECLAIM_WB_FILE"},	\
+		{RECLAIM_WB_MIXED,	"RECLAIM_WB_MIXED"},	\
 		{RECLAIM_WB_SYNC,	"RECLAIM_WB_SYNC"},	\
 		{RECLAIM_WB_ASYNC,	"RECLAIM_WB_ASYNC"}	\
 		) : "RECLAIM_WB_NONE"
@@ -26,6 +28,12 @@
 	(sync == PAGEOUT_IO_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC)   \
 	)
 
+#define trace_shrink_flags(file, sync) ( \
+	(sync == PAGEOUT_IO_SYNC ? RECLAIM_WB_MIXED : \
+			(file ? RECLAIM_WB_FILE : RECLAIM_WB_ANON)) |  \
+	(sync == PAGEOUT_IO_SYNC ? RECLAIM_WB_SYNC : RECLAIM_WB_ASYNC) \
+	)
+
 TRACE_EVENT(mm_vmscan_kswapd_sleep,
 
 	TP_PROTO(int nid),
@@ -269,6 +277,40 @@ TRACE_EVENT(mm_vmscan_writepage,
 		show_reclaim_flags(__entry->reclaim_flags))
 );
 
+TRACE_EVENT(mm_vmscan_lru_shrink_inactive,
+
+	TP_PROTO(int nid, int zid,
+			unsigned long nr_scanned, unsigned long nr_reclaimed,
+			int priority, int reclaim_flags),
+
+	TP_ARGS(nid, zid, nr_scanned, nr_reclaimed, priority, reclaim_flags),
+
+	TP_STRUCT__entry(
+		__field(int, nid)
+		__field(int, zid)
+		__field(unsigned long, nr_scanned)
+		__field(unsigned long, nr_reclaimed)
+		__field(int, priority)
+		__field(int, reclaim_flags)
+	),
+
+	TP_fast_assign(
+		__entry->nid = nid;
+		__entry->zid = zid;
+		__entry->nr_scanned = nr_scanned;
+		__entry->nr_reclaimed = nr_reclaimed;
+		__entry->priority = priority;
+		__entry->reclaim_flags = reclaim_flags;
+	),
+
+	TP_printk("nid=%d zid=%d nr_scanned=%ld nr_reclaimed=%ld priority=%d flags=%s",
+		__entry->nid, __entry->zid,
+		__entry->nr_scanned, __entry->nr_reclaimed,
+		__entry->priority,
+		show_reclaim_flags(__entry->reclaim_flags))
+);
+
+
 #endif /* _TRACE_VMSCAN_H */
 
 /* This part must be outside protection */
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c391c32..652650f 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1359,6 +1359,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
 	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
 	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
+
+	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
+		zone_idx(zone),
+		nr_scanned, nr_reclaimed,
+		priority,
+		trace_shrink_flags(file, sc->lumpy_reclaim_mode));
 	return nr_reclaimed;
 }
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
