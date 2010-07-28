Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 30A2D6B02AA
	for <linux-mm@kvack.org>; Wed, 28 Jul 2010 06:27:29 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 3/9] vmscan: tracing: Update post-processing script to distinguish between anon and file IO from page reclaim
Date: Wed, 28 Jul 2010 11:27:17 +0100
Message-Id: <1280312843-11789-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
References: <1280312843-11789-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

It is useful to distinguish between IO for anon and file pages. This patch
updates
vmscan-tracing-add-a-postprocessing-script-for-reclaim-related-ftrace-events.patch
so the post-processing script can handle the additional information.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 .../trace/postprocess/trace-vmscan-postprocess.pl  |   96 +++++++++++++-------
 1 files changed, 64 insertions(+), 32 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
index d1ddc33..f87f56e 100644
--- a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -21,9 +21,12 @@ use constant MM_VMSCAN_KSWAPD_SLEEP		=> 4;
 use constant MM_VMSCAN_LRU_SHRINK_ACTIVE	=> 5;
 use constant MM_VMSCAN_LRU_SHRINK_INACTIVE	=> 6;
 use constant MM_VMSCAN_LRU_ISOLATE		=> 7;
-use constant MM_VMSCAN_WRITEPAGE_SYNC		=> 8;
-use constant MM_VMSCAN_WRITEPAGE_ASYNC		=> 9;
-use constant EVENT_UNKNOWN			=> 10;
+use constant MM_VMSCAN_WRITEPAGE_FILE_SYNC	=> 8;
+use constant MM_VMSCAN_WRITEPAGE_ANON_SYNC	=> 9;
+use constant MM_VMSCAN_WRITEPAGE_FILE_ASYNC	=> 10;
+use constant MM_VMSCAN_WRITEPAGE_ANON_ASYNC	=> 11;
+use constant MM_VMSCAN_WRITEPAGE_ASYNC		=> 12;
+use constant EVENT_UNKNOWN			=> 13;
 
 # Per-order events
 use constant MM_VMSCAN_DIRECT_RECLAIM_BEGIN_PERORDER => 11;
@@ -55,9 +58,11 @@ my $opt_read_procstat;
 my $total_wakeup_kswapd;
 my ($total_direct_reclaim, $total_direct_nr_scanned);
 my ($total_direct_latency, $total_kswapd_latency);
-my ($total_direct_writepage_sync, $total_direct_writepage_async);
+my ($total_direct_writepage_file_sync, $total_direct_writepage_file_async);
+my ($total_direct_writepage_anon_sync, $total_direct_writepage_anon_async);
 my ($total_kswapd_nr_scanned, $total_kswapd_wake);
-my ($total_kswapd_writepage_sync, $total_kswapd_writepage_async);
+my ($total_kswapd_writepage_file_sync, $total_kswapd_writepage_file_async);
+my ($total_kswapd_writepage_anon_sync, $total_kswapd_writepage_anon_async);
 
 # Catch sigint and exit on request
 my $sigint_report = 0;
@@ -101,7 +106,7 @@ my $regex_wakeup_kswapd_default = 'nid=([0-9]*) zid=([0-9]*) order=([0-9]*)';
 my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) order=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_taken=([0-9]*) contig_taken=([0-9]*) contig_dirty=([0-9]*) contig_failed=([0-9]*)';
 my $regex_lru_shrink_inactive_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) priority=([0-9]*)';
 my $regex_lru_shrink_active_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_rotated=([0-9]*) priority=([0-9]*)';
-my $regex_writepage_default = 'page=([0-9a-f]*) pfn=([0-9]*) sync_io=([0-9]*)';
+my $regex_writepage_default = 'page=([0-9a-f]*) pfn=([0-9]*) flags=([A-Z_|]*)';
 
 # Dyanically discovered regex
 my $regex_direct_begin;
@@ -209,7 +214,7 @@ $regex_lru_shrink_active = generate_traceevent_regex(
 $regex_writepage = generate_traceevent_regex(
 			"vmscan/mm_vmscan_writepage",
 			$regex_writepage_default,
-			"page", "pfn", "sync_io");
+			"page", "pfn", "flags");
 
 sub read_statline($) {
 	my $pid = $_[0];
@@ -379,11 +384,27 @@ EVENT_PROCESS:
 				next;
 			}
 
-			my $sync_io = $3;
+			my $flags = $3;
+			my $file = 0;
+			my $sync_io = 0;
+			if ($flags =~ /RECLAIM_WB_FILE/) {
+				$file = 1;
+			}
+			if ($flags =~ /RECLAIM_WB_SYNC/) {
+				$sync_io = 1;
+			}
 			if ($sync_io) {
-				$perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC}++;
+				if ($file) {
+					$perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC}++;
+				} else {
+					$perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC}++;
+				}
 			} else {
-				$perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC}++;
+				if ($file) {
+					$perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC}++;
+				} else {
+					$perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_ASYNC}++;
+				}
 			}
 		} else {
 			$perprocesspid{$process_pid}->{EVENT_UNKNOWN}++;
@@ -427,7 +448,7 @@ sub dump_stats {
 		while (defined $stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index] ||
 			defined $stats{$process_pid}->{HIGH_KSWAPD_LATENCY}[$index]) {
 
-			if ($stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index]) {
+			if ($stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index]) { 
 				printf("%s ", $stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index]) if !$opt_ignorepid;
 				my ($dummy, $latency) = split(/-/, $stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index]);
 				$total_direct_latency += $latency;
@@ -454,8 +475,11 @@ sub dump_stats {
 		$total_direct_reclaim += $stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN};
 		$total_wakeup_kswapd += $stats{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD};
 		$total_direct_nr_scanned += $stats{$process_pid}->{HIGH_NR_SCANNED};
-		$total_direct_writepage_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC};
-		$total_direct_writepage_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC};
+		$total_direct_writepage_file_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC};
+		$total_direct_writepage_anon_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC};
+		$total_direct_writepage_file_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC};
+
+		$total_direct_writepage_anon_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_ASYNC};
 
 		my $index = 0;
 		my $this_reclaim_delay = 0;
@@ -470,8 +494,8 @@ sub dump_stats {
 			$stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN},
 			$stats{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD},
 			$stats{$process_pid}->{HIGH_NR_SCANNED},
-			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC},
-			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC},
+			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC} + $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC},
+			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC} + $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_ASYNC},
 			$this_reclaim_delay / 1000);
 
 		if ($stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN}) {
@@ -515,16 +539,18 @@ sub dump_stats {
 
 		$total_kswapd_wake += $stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE};
 		$total_kswapd_nr_scanned += $stats{$process_pid}->{HIGH_NR_SCANNED};
-		$total_kswapd_writepage_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC};
-		$total_kswapd_writepage_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC};
+		$total_kswapd_writepage_file_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC};
+		$total_kswapd_writepage_anon_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC};
+		$total_kswapd_writepage_file_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC};
+		$total_kswapd_writepage_anon_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_ASYNC};
 
 		printf("%-" . $max_strlen . "s %8d %10d   %8u   %8i %8u",
 			$process_pid,
 			$stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE},
 			$stats{$process_pid}->{HIGH_KSWAPD_REWAKEUP},
 			$stats{$process_pid}->{HIGH_NR_SCANNED},
-			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC},
-			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC});
+			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC} + $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC},
+			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC} + $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_ASYNC});
 
 		if ($stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE}) {
 			print "      ";
@@ -551,18 +577,22 @@ sub dump_stats {
 	$total_direct_latency /= 1000;
 	$total_kswapd_latency /= 1000;
 	print "\nSummary\n";
-	print "Direct reclaims:     		$total_direct_reclaim\n";
-	print "Direct reclaim pages scanned:	$total_direct_nr_scanned\n";
-	print "Direct reclaim write sync I/O:	$total_direct_writepage_sync\n";
-	print "Direct reclaim write async I/O:	$total_direct_writepage_async\n";
-	print "Wake kswapd requests:		$total_wakeup_kswapd\n";
-	printf "Time stalled direct reclaim: 	%-1.2f ms\n", $total_direct_latency;
+	print "Direct reclaims:     			$total_direct_reclaim\n";
+	print "Direct reclaim pages scanned:		$total_direct_nr_scanned\n";
+	print "Direct reclaim write file sync I/O:	$total_direct_writepage_file_sync\n";
+	print "Direct reclaim write anon sync I/O:	$total_direct_writepage_anon_sync\n";
+	print "Direct reclaim write file async I/O:	$total_direct_writepage_file_async\n";
+	print "Direct reclaim write anon async I/O:	$total_direct_writepage_anon_async\n";
+	print "Wake kswapd requests:			$total_wakeup_kswapd\n";
+	printf "Time stalled direct reclaim: 		%-1.2f ms\n", $total_direct_latency;
 	print "\n";
-	print "Kswapd wakeups:			$total_kswapd_wake\n";
-	print "Kswapd pages scanned:		$total_kswapd_nr_scanned\n";
-	print "Kswapd reclaim write sync I/O:	$total_kswapd_writepage_sync\n";
-	print "Kswapd reclaim write async I/O:	$total_kswapd_writepage_async\n";
-	printf "Time kswapd awake:		%-1.2f ms\n", $total_kswapd_latency;
+	print "Kswapd wakeups:				$total_kswapd_wake\n";
+	print "Kswapd pages scanned:			$total_kswapd_nr_scanned\n";
+	print "Kswapd reclaim write file sync I/O:	$total_kswapd_writepage_file_sync\n";
+	print "Kswapd reclaim write anon sync I/O:	$total_kswapd_writepage_anon_sync\n";
+	print "Kswapd reclaim write file async I/O:	$total_kswapd_writepage_file_async\n";
+	print "Kswapd reclaim write anon async I/O:	$total_kswapd_writepage_anon_async\n";
+	printf "Time kswapd awake:			%-1.2f ms\n", $total_kswapd_latency;
 }
 
 sub aggregate_perprocesspid() {
@@ -582,8 +612,10 @@ sub aggregate_perprocesspid() {
 		$perprocess{$process}->{MM_VMSCAN_WAKEUP_KSWAPD} += $perprocesspid{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD};
 		$perprocess{$process}->{HIGH_KSWAPD_REWAKEUP} += $perprocesspid{$process_pid}->{HIGH_KSWAPD_REWAKEUP};
 		$perprocess{$process}->{HIGH_NR_SCANNED} += $perprocesspid{$process_pid}->{HIGH_NR_SCANNED};
-		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_SYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC};
-		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_ASYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC};
+		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_SYNC};
+		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_SYNC};
+		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_FILE_ASYNC};
+		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_ANON_ASYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_ANON_ASYNC};
 
 		for (my $order = 0; $order < 20; $order++) {
 			$perprocess{$process}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN_PERORDER}[$order] += $perprocesspid{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN_PERORDER}[$order];
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
