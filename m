Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 812B96B005C
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 13:43:30 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 4/4] tracing, page-allocator: Add a postprocessing script for page-allocator-related ftrace events
Date: Tue,  4 Aug 2009 19:12:26 +0100
Message-Id: <1249409546-6343-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1249409546-6343-1-git-send-email-mel@csn.ul.ie>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: riel@redhat.com, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch adds a simple post-processing script for the page-allocator-related
trace events. It can be used to give an indication of who the most
allocator-intensive processes are and how often the zone lock was taken
during the tracing period. Example output looks like

find-2840
 o pages allocd            = 1877
 o pages allocd under lock = 1817
 o pages freed directly    = 9
 o pcpu refills            = 1078
 o migrate fallbacks       = 48
   - fragmentation causing = 48
     - severe              = 46
     - moderate            = 2
   - changed migratetype   = 7

The high number of fragmentation events were because 32 dd processes were
running at the same time under qemu, with limited memory with standard
min_free_kbytes so it's not a surprising outcome.

The postprocessor parses the text output of tracing. While there is a binary
format, the expectation is that the binary output can be readily translated
into text and post-processed offline. Obviously if the text format
changes, the parser will break but the regular expression parser is
fairly rudimentary so should be readily adjustable.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Rik van Riel <riel@redhat.com>
---
 .../postprocess/trace-pagealloc-postprocess.pl     |  131 ++++++++++++++++++++
 1 files changed, 131 insertions(+), 0 deletions(-)
 create mode 100755 Documentation/trace/postprocess/trace-pagealloc-postprocess.pl

diff --git a/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl b/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
new file mode 100755
index 0000000..d4332c3
--- /dev/null
+++ b/Documentation/trace/postprocess/trace-pagealloc-postprocess.pl
@@ -0,0 +1,131 @@
+#!/usr/bin/perl
+# This is a POC (proof of concept or piece of crap, take your pick) for reading the
+# text representation of trace output related to page allocation. It makes an attempt
+# to extract some high-level information on what is going on. The accuracy of the parser
+# may vary considerably
+#
+# Copyright (c) Mel Gorman 2009
+use Switch;
+use strict;
+
+my $traceevent;
+my %perprocess;
+
+while ($traceevent = <>) {
+	my $process_pid;
+	my $cpus;
+	my $timestamp;
+	my $tracepoint;
+	my $details;
+
+	#                      (process_pid)     (cpus      )   ( time  )   (tpoint    ) (details)
+	if ($traceevent =~ /\s*([a-zA-Z0-9-]*)\s*(\[[0-9]*\])\s*([0-9.]*):\s*([a-zA-Z_]*):\s*(.*)/) {
+		$process_pid = $1;
+		$cpus = $2;
+		$timestamp = $3;
+		$tracepoint = $4;
+		$details = $5;
+
+	} else {
+		next;
+	}
+
+	switch ($tracepoint) {
+	case "mm_page_alloc" {
+		$perprocess{$process_pid}->{"mm_page_alloc"}++;
+	}
+	case "mm_page_free_direct" {
+		$perprocess{$process_pid}->{"mm_page_free_direct"}++;
+	}
+	case "mm_pagevec_free" {
+		$perprocess{$process_pid}->{"mm_pagevec_free"}++;
+	}
+	case "mm_page_pcpu_drain" {
+		$perprocess{$process_pid}->{"mm_page_pcpu_drain"}++;
+		$perprocess{$process_pid}->{"mm_page_pcpu_drain-pagesdrained"}++;
+	}
+	case "mm_page_alloc_zone_locked" {
+		$perprocess{$process_pid}->{"mm_page_alloc_zone_locked"}++;
+		$perprocess{$process_pid}->{"mm_page_alloc_zone_locked-pagesrefilled"}++;
+	}
+	case "mm_page_alloc_extfrag" {
+		$perprocess{$process_pid}->{"mm_page_alloc_extfrag"}++;
+		my ($page, $pfn);
+		my ($alloc_order, $fallback_order, $pageblock_order);
+		my ($alloc_migratetype, $fallback_migratetype);
+		my ($fragmenting, $change_ownership);
+
+		$details =~ /page=([0-9a-f]*) pfn=([0-9]*) alloc_order=([0-9]*) fallback_order=([0-9]*) pageblock_order=([0-9]*) alloc_migratetype=([0-9]*) fallback_migratetype=([0-9]*) fragmenting=([0-9]) change_ownership=([0-9])/;
+		$page = $1;
+		$pfn = $2;
+		$alloc_order = $3;
+		$fallback_order = $4;
+		$pageblock_order = $5;
+		$alloc_migratetype = $6;
+		$fallback_migratetype = $7;
+		$fragmenting = $8;
+		$change_ownership = $9;
+
+		if ($fragmenting) {
+			$perprocess{$process_pid}->{"mm_page_alloc_extfrag-fragmenting"}++;
+			if ($fallback_order <= 3) {
+				$perprocess{$process_pid}->{"mm_page_alloc_extfrag-fragmenting-severe"}++;
+			} else {
+				$perprocess{$process_pid}->{"mm_page_alloc_extfrag-fragmenting-moderate"}++;
+			}
+		}
+		if ($change_ownership) {
+			$perprocess{$process_pid}->{"mm_page_alloc_extfrag-changetype"}++;
+		}
+	}
+	else {
+		$perprocess{$process_pid}->{"unknown"}++;
+	}
+	}
+
+	# Catch a full pcpu drain event
+	if ($perprocess{$process_pid}->{"mm_page_pcpu_drain-pagesdrained"} &&
+			$tracepoint ne "mm_page_pcpu_drain") {
+
+		$perprocess{$process_pid}->{"mm_page_pcpu_drain-drains"}++;
+		$perprocess{$process_pid}->{"mm_page_pcpu_drain-pagesdrained"} = 0;
+	}
+
+	# Catch a full pcpu refill event
+	if ($perprocess{$process_pid}->{"mm_page_alloc_zone_locked-pagesrefilled"} &&
+			$tracepoint ne "mm_page_alloc_zone_locked") {
+		$perprocess{$process_pid}->{"mm_page_alloc_zone_locked-refills"}++;
+		$perprocess{$process_pid}->{"mm_page_alloc_zone_locked-pagesrefilled"} = 0;
+	}
+}
+
+# Dump per-process stats
+my $process_pid;
+foreach $process_pid (keys %perprocess) {
+	# Dump final aggregates
+	if ($perprocess{$process_pid}->{"mm_page_pcpu_drain-pagesdrained"}) {
+		$perprocess{$process_pid}->{"mm_page_pcpu_drain-drains"}++;
+		$perprocess{$process_pid}->{"mm_page_pcpu_drain-pagesdrained"} = 0;
+	}
+	if ($perprocess{$process_pid}->{"mm_page_alloc_zone_locked-pagesrefilled"}) {
+		$perprocess{$process_pid}->{"mm_page_alloc_zone_locked-refills"}++;
+		$perprocess{$process_pid}->{"mm_page_alloc_zone_locked-pagesrefilled"} = 0;
+	}
+
+	my %process = $perprocess{$process_pid};
+	printf("$process_pid\n");
+	printf(" o pages allocd            = %d\n", $perprocess{$process_pid}->{"mm_page_alloc"});
+	printf(" o pages allocd under lock = %d\n", $perprocess{$process_pid}->{"mm_page_alloc_zone_locked"});
+	printf(" o pages freed directly    = %d\n", $perprocess{$process_pid}->{"mm_page_free_direct"});
+	printf(" o pages freed via pagevec = %d\n", $perprocess{$process_pid}->{"mm_pagevec_free"});
+	printf(" o pcpu pages drained      = %d\n", $perprocess{$process_pid}->{"mm_page_pcpu_drain"});
+	printf(" o pcpu drains             = %d\n", $perprocess{$process_pid}->{"mm_page_pcpu_drain-drains"});
+	printf(" o pcpu refills            = %d\n", $perprocess{$process_pid}->{"mm_page_alloc_zone_locked-refills"});
+	printf(" o migrate fallbacks       = %d\n", $perprocess{$process_pid}->{"mm_page_alloc_extfrag"});
+	printf("   - fragmentation causing = %d\n", $perprocess{$process_pid}->{"mm_page_alloc_extfrag-fragmenting"});
+	printf("     - severe              = %d\n", $perprocess{$process_pid}->{"mm_page_alloc_extfrag-fragmenting-severe"});
+	printf("     - moderate            = %d\n", $perprocess{$process_pid}->{"mm_page_alloc_extfrag-fragmenting-moderate"});
+	printf("   - changed migratetype   = %d\n", $perprocess{$process_pid}->{"mm_page_alloc_extfrag-changetype"});
+	printf(" o unknown events          = %d\n", $perprocess{$process_pid}->{"unknown"});
+	printf("\n");
+}
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
