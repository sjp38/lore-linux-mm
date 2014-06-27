Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id CA5456B0031
	for <linux-mm@kvack.org>; Fri, 27 Jun 2014 03:53:40 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id un15so4242277pbc.41
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 00:53:40 -0700 (PDT)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id kr8si13098994pbc.32.2014.06.27.00.53.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 27 Jun 2014 00:53:39 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id uo5so4254162pbc.12
        for <linux-mm@kvack.org>; Fri, 27 Jun 2014 00:53:39 -0700 (PDT)
From: Chen Yucong <slaoub@gmail.com>
Subject: [PATCH] mm:vmscan: update the trace-vmscan-postprocess.pl for event vmscan/mm_vmscan_lru_isolate
Date: Fri, 27 Jun 2014 15:53:26 +0800
Message-Id: <1403855607-26857-1-git-send-email-slaoub@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Yucong <slaoub@gmail.com>

When using *trace-vmscan-postprocess.pl* for checking the file/anon rate of scanning,
we can find that it can not be performed. At the same time, the following message will
be reported.

WARNING: Format not as expected for event vmscan/mm_vmscan_lru_isolate 'file' != 'contig_taken'
Fewer fields than expected in format at ./trace-vmscan-postprocess.pl line 171, <FORMAT> line 76.

In trace-vmscan-postprocess.pl, (contig_taken, contig_dirty, and contig_failed) are be
associated respectively to (nr_lumpy_taken, nr_lumpy_dirty, and nr_lumpy_failed) for lumpy
reclaim. Via commit c53919adc045b(mm: vmscan: remove lumpy reclaim), lumpy reclaim had
already been removed by Mel, but the update for trace-vmscan-postprocess.pl was missed.

Signed-off-by: Chen Yucong <slaoub@gmail.com>
---
 .../trace/postprocess/trace-vmscan-postprocess.pl        |   14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
index 00e425f..78c9a7b 100644
--- a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -47,7 +47,6 @@ use constant HIGH_KSWAPD_REWAKEUP		=> 21;
 use constant HIGH_NR_SCANNED			=> 22;
 use constant HIGH_NR_TAKEN			=> 23;
 use constant HIGH_NR_RECLAIMED			=> 24;
-use constant HIGH_NR_CONTIG_DIRTY		=> 25;
 
 my %perprocesspid;
 my %perprocess;
@@ -105,7 +104,7 @@ my $regex_direct_end_default = 'nr_reclaimed=([0-9]*)';
 my $regex_kswapd_wake_default = 'nid=([0-9]*) order=([0-9]*)';
 my $regex_kswapd_sleep_default = 'nid=([0-9]*)';
 my $regex_wakeup_kswapd_default = 'nid=([0-9]*) zid=([0-9]*) order=([0-9]*)';
-my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) order=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_taken=([0-9]*) contig_taken=([0-9]*) contig_dirty=([0-9]*) contig_failed=([0-9]*)';
+my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) order=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_taken=([0-9]*) file=([0-9]*)';
 my $regex_lru_shrink_inactive_default = 'nid=([0-9]*) zid=([0-9]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) priority=([0-9]*) flags=([A-Z_|]*)';
 my $regex_lru_shrink_active_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_rotated=([0-9]*) priority=([0-9]*)';
 my $regex_writepage_default = 'page=([0-9a-f]*) pfn=([0-9]*) flags=([A-Z_|]*)';
@@ -200,7 +199,7 @@ $regex_lru_isolate = generate_traceevent_regex(
 			$regex_lru_isolate_default,
 			"isolate_mode", "order",
 			"nr_requested", "nr_scanned", "nr_taken",
-			"contig_taken", "contig_dirty", "contig_failed");
+			"file");
 $regex_lru_shrink_inactive = generate_traceevent_regex(
 			"vmscan/mm_vmscan_lru_shrink_inactive",
 			$regex_lru_shrink_inactive_default,
@@ -375,7 +374,6 @@ EVENT_PROCESS:
 			}
 			my $isolate_mode = $1;
 			my $nr_scanned = $4;
-			my $nr_contig_dirty = $7;
 
 			# To closer match vmstat scanning statistics, only count isolate_both
 			# and isolate_inactive as scanning. isolate_active is rotation
@@ -385,7 +383,6 @@ EVENT_PROCESS:
 			if ($isolate_mode != 2) {
 				$perprocesspid{$process_pid}->{HIGH_NR_SCANNED} += $nr_scanned;
 			}
-			$perprocesspid{$process_pid}->{HIGH_NR_CONTIG_DIRTY} += $nr_contig_dirty;
 		} elsif ($tracepoint eq "mm_vmscan_lru_shrink_inactive") {
 			$details = $6;
 			if ($details !~ /$regex_lru_shrink_inactive/o) {
@@ -539,13 +536,6 @@ sub dump_stats {
 				}
 			}
 		}
-		if ($stats{$process_pid}->{HIGH_NR_CONTIG_DIRTY}) {
-			print "      ";
-			my $count = $stats{$process_pid}->{HIGH_NR_CONTIG_DIRTY};
-			if ($count != 0) {
-				print "contig-dirty=$count ";
-			}
-		}
 
 		print "\n";
 	}
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
