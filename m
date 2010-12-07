Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D7A076B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 06:24:32 -0500 (EST)
Date: Tue, 7 Dec 2010 11:24:14 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] mm: vmscan: tracepoint: Account for scanned pages
	similarly for both ftrace and vmstat
Message-ID: <20101207112414.GB5422@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

When correlating ftrace results with /proc/vmstat, I noticed that the
reporting scripts value for "pages scanned" differed significantly. Both
values were "right" depending on how you look at it.

The difference is due to vmstat only counting scanning of the inactive list
towards pages scanned. The analysis script for the tracepoint counts active
and inactive list yielding a far higher value than vmstat.  The resulting
scanning/reclaim ratio looks much worse.  The tracepoint is ok but this
patch updates the reporting script so that the report values for scanned
are similar to vmstat.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 .../trace/postprocess/trace-vmscan-postprocess.pl  |   11 ++++++++++-
 1 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
index b3e73dd..12cecc8 100644
--- a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -373,9 +373,18 @@ EVENT_PROCESS:
 				print "         $regex_lru_isolate/o\n";
 				next;
 			}
+			my $isolate_mode = $1;
 			my $nr_scanned = $4;
 			my $nr_contig_dirty = $7;
-			$perprocesspid{$process_pid}->{HIGH_NR_SCANNED} += $nr_scanned;
+
+			# To closer match vmstat scanning statistics, only count isolate_both
+			# and isolate_inactive as scanning. isolate_active is rotation
+			# isolate_inactive == 0
+			# isolate_active   == 1
+			# isolate_both     == 2
+			if ($isolate_mode != 1) {
+				$perprocesspid{$process_pid}->{HIGH_NR_SCANNED} += $nr_scanned;
+			}
 			$perprocesspid{$process_pid}->{HIGH_NR_CONTIG_DIRTY} += $nr_contig_dirty;
 		} elsif ($tracepoint eq "mm_vmscan_lru_shrink_inactive") {
 			$details = $5;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
