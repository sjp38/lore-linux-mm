Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DAEC06007F5
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 09:11:40 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 1/8] vmscan: tracing: Roll up of patches currently in mmotm
Date: Mon, 19 Jul 2010 14:11:23 +0100
Message-Id: <1279545090-19169-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This is a roll-up of patches currently in an unreleased mmotm tree related to
stack reduction and tracing reclaim. The patches were taken from mm-commits
traffic. It is based on 2.6.35-rc5 and included for the convenience of
testing.

No signed off required.

--- 
 .../trace/postprocess/trace-vmscan-postprocess.pl  |  654 ++++++++++++++++++++
 include/linux/memcontrol.h                         |    5 -
 include/linux/mmzone.h                             |   15 -
 include/trace/events/gfpflags.h                    |   37 ++
 include/trace/events/kmem.h                        |   38 +--
 include/trace/events/vmscan.h                      |  184 ++++++
 mm/memcontrol.c                                    |   31 -
 mm/page_alloc.c                                    |    2 -
 mm/vmscan.c                                        |  414 +++++++------
 mm/vmstat.c                                        |    2 -
 10 files changed, 1089 insertions(+), 293 deletions(-)

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
new file mode 100644
index 0000000..d1ddc33
--- /dev/null
+++ b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
@@ -0,0 +1,654 @@
+#!/usr/bin/perl
+# This is a POC for reading the text representation of trace output related to
+# page reclaim. It makes an attempt to extract some high-level information on
+# what is going on. The accuracy of the parser may vary
+#
+# Example usage: trace-vmscan-postprocess.pl < /sys/kernel/debug/tracing/trace_pipe
+# other options
+#   --read-procstat	If the trace lacks process info, get it from /proc
+#   --ignore-pid	Aggregate processes of the same name together
+#
+# Copyright (c) IBM Corporation 2009
+# Author: Mel Gorman <mel@csn.ul.ie>
+use strict;
+use Getopt::Long;
+
+# Tracepoint events
+use constant MM_VMSCAN_DIRECT_RECLAIM_BEGIN	=> 1;
+use constant MM_VMSCAN_DIRECT_RECLAIM_END	=> 2;
+use constant MM_VMSCAN_KSWAPD_WAKE		=> 3;
+use constant MM_VMSCAN_KSWAPD_SLEEP		=> 4;
+use constant MM_VMSCAN_LRU_SHRINK_ACTIVE	=> 5;
+use constant MM_VMSCAN_LRU_SHRINK_INACTIVE	=> 6;
+use constant MM_VMSCAN_LRU_ISOLATE		=> 7;
+use constant MM_VMSCAN_WRITEPAGE_SYNC		=> 8;
+use constant MM_VMSCAN_WRITEPAGE_ASYNC		=> 9;
+use constant EVENT_UNKNOWN			=> 10;
+
+# Per-order events
+use constant MM_VMSCAN_DIRECT_RECLAIM_BEGIN_PERORDER => 11;
+use constant MM_VMSCAN_WAKEUP_KSWAPD_PERORDER 	=> 12;
+use constant MM_VMSCAN_KSWAPD_WAKE_PERORDER	=> 13;
+use constant HIGH_KSWAPD_REWAKEUP_PERORDER	=> 14;
+
+# Constants used to track state
+use constant STATE_DIRECT_BEGIN 		=> 15;
+use constant STATE_DIRECT_ORDER 		=> 16;
+use constant STATE_KSWAPD_BEGIN			=> 17;
+use constant STATE_KSWAPD_ORDER			=> 18;
+
+# High-level events extrapolated from tracepoints
+use constant HIGH_DIRECT_RECLAIM_LATENCY	=> 19;
+use constant HIGH_KSWAPD_LATENCY		=> 20;
+use constant HIGH_KSWAPD_REWAKEUP		=> 21;
+use constant HIGH_NR_SCANNED			=> 22;
+use constant HIGH_NR_TAKEN			=> 23;
+use constant HIGH_NR_RECLAIM			=> 24;
+use constant HIGH_NR_CONTIG_DIRTY		=> 25;
+
+my %perprocesspid;
+my %perprocess;
+my %last_procmap;
+my $opt_ignorepid;
+my $opt_read_procstat;
+
+my $total_wakeup_kswapd;
+my ($total_direct_reclaim, $total_direct_nr_scanned);
+my ($total_direct_latency, $total_kswapd_latency);
+my ($total_direct_writepage_sync, $total_direct_writepage_async);
+my ($total_kswapd_nr_scanned, $total_kswapd_wake);
+my ($total_kswapd_writepage_sync, $total_kswapd_writepage_async);
+
+# Catch sigint and exit on request
+my $sigint_report = 0;
+my $sigint_exit = 0;
+my $sigint_pending = 0;
+my $sigint_received = 0;
+sub sigint_handler {
+	my $current_time = time;
+	if ($current_time - 2 > $sigint_received) {
+		print "SIGINT received, report pending. Hit ctrl-c again to exit\n";
+		$sigint_report = 1;
+	} else {
+		if (!$sigint_exit) {
+			print "Second SIGINT received quickly, exiting\n";
+		}
+		$sigint_exit++;
+	}
+
+	if ($sigint_exit > 3) {
+		print "Many SIGINTs received, exiting now without report\n";
+		exit;
+	}
+
+	$sigint_received = $current_time;
+	$sigint_pending = 1;
+}
+$SIG{INT} = "sigint_handler";
+
+# Parse command line options
+GetOptions(
+	'ignore-pid'	 =>	\$opt_ignorepid,
+	'read-procstat'	 =>	\$opt_read_procstat,
+);
+
+# Defaults for dynamically discovered regex's
+my $regex_direct_begin_default = 'order=([0-9]*) may_writepage=([0-9]*) gfp_flags=([A-Z_|]*)';
+my $regex_direct_end_default = 'nr_reclaimed=([0-9]*)';
+my $regex_kswapd_wake_default = 'nid=([0-9]*) order=([0-9]*)';
+my $regex_kswapd_sleep_default = 'nid=([0-9]*)';
+my $regex_wakeup_kswapd_default = 'nid=([0-9]*) zid=([0-9]*) order=([0-9]*)';
+my $regex_lru_isolate_default = 'isolate_mode=([0-9]*) order=([0-9]*) nr_requested=([0-9]*) nr_scanned=([0-9]*) nr_taken=([0-9]*) contig_taken=([0-9]*) contig_dirty=([0-9]*) contig_failed=([0-9]*)';
+my $regex_lru_shrink_inactive_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_reclaimed=([0-9]*) priority=([0-9]*)';
+my $regex_lru_shrink_active_default = 'lru=([A-Z_]*) nr_scanned=([0-9]*) nr_rotated=([0-9]*) priority=([0-9]*)';
+my $regex_writepage_default = 'page=([0-9a-f]*) pfn=([0-9]*) sync_io=([0-9]*)';
+
+# Dyanically discovered regex
+my $regex_direct_begin;
+my $regex_direct_end;
+my $regex_kswapd_wake;
+my $regex_kswapd_sleep;
+my $regex_wakeup_kswapd;
+my $regex_lru_isolate;
+my $regex_lru_shrink_inactive;
+my $regex_lru_shrink_active;
+my $regex_writepage;
+
+# Static regex used. Specified like this for readability and for use with /o
+#                      (process_pid)     (cpus      )   ( time  )   (tpoint    ) (details)
+my $regex_traceevent = '\s*([a-zA-Z0-9-]*)\s*(\[[0-9]*\])\s*([0-9.]*):\s*([a-zA-Z_]*):\s*(.*)';
+my $regex_statname = '[-0-9]*\s\((.*)\).*';
+my $regex_statppid = '[-0-9]*\s\(.*\)\s[A-Za-z]\s([0-9]*).*';
+
+sub generate_traceevent_regex {
+	my $event = shift;
+	my $default = shift;
+	my $regex;
+
+	# Read the event format or use the default
+	if (!open (FORMAT, "/sys/kernel/debug/tracing/events/$event/format")) {
+		print("WARNING: Event $event format string not found\n");
+		return $default;
+	} else {
+		my $line;
+		while (!eof(FORMAT)) {
+			$line = <FORMAT>;
+			$line =~ s/, REC->.*//;
+			if ($line =~ /^print fmt:\s"(.*)".*/) {
+				$regex = $1;
+				$regex =~ s/%s/\([0-9a-zA-Z|_]*\)/g;
+				$regex =~ s/%p/\([0-9a-f]*\)/g;
+				$regex =~ s/%d/\([-0-9]*\)/g;
+				$regex =~ s/%ld/\([-0-9]*\)/g;
+				$regex =~ s/%lu/\([0-9]*\)/g;
+			}
+		}
+	}
+
+	# Can't handle the print_flags stuff but in the context of this
+	# script, it really doesn't matter
+	$regex =~ s/\(REC.*\) \? __print_flags.*//;
+
+	# Verify fields are in the right order
+	my $tuple;
+	foreach $tuple (split /\s/, $regex) {
+		my ($key, $value) = split(/=/, $tuple);
+		my $expected = shift;
+		if ($key ne $expected) {
+			print("WARNING: Format not as expected for event $event '$key' != '$expected'\n");
+			$regex =~ s/$key=\((.*)\)/$key=$1/;
+		}
+	}
+
+	if (defined shift) {
+		die("Fewer fields than expected in format");
+	}
+
+	return $regex;
+}
+
+$regex_direct_begin = generate_traceevent_regex(
+			"vmscan/mm_vmscan_direct_reclaim_begin",
+			$regex_direct_begin_default,
+			"order", "may_writepage",
+			"gfp_flags");
+$regex_direct_end = generate_traceevent_regex(
+			"vmscan/mm_vmscan_direct_reclaim_end",
+			$regex_direct_end_default,
+			"nr_reclaimed");
+$regex_kswapd_wake = generate_traceevent_regex(
+			"vmscan/mm_vmscan_kswapd_wake",
+			$regex_kswapd_wake_default,
+			"nid", "order");
+$regex_kswapd_sleep = generate_traceevent_regex(
+			"vmscan/mm_vmscan_kswapd_sleep",
+			$regex_kswapd_sleep_default,
+			"nid");
+$regex_wakeup_kswapd = generate_traceevent_regex(
+			"vmscan/mm_vmscan_wakeup_kswapd",
+			$regex_wakeup_kswapd_default,
+			"nid", "zid", "order");
+$regex_lru_isolate = generate_traceevent_regex(
+			"vmscan/mm_vmscan_lru_isolate",
+			$regex_lru_isolate_default,
+			"isolate_mode", "order",
+			"nr_requested", "nr_scanned", "nr_taken",
+			"contig_taken", "contig_dirty", "contig_failed");
+$regex_lru_shrink_inactive = generate_traceevent_regex(
+			"vmscan/mm_vmscan_lru_shrink_inactive",
+			$regex_lru_shrink_inactive_default,
+			"nid", "zid",
+			"lru",
+			"nr_scanned", "nr_reclaimed", "priority");
+$regex_lru_shrink_active = generate_traceevent_regex(
+			"vmscan/mm_vmscan_lru_shrink_active",
+			$regex_lru_shrink_active_default,
+			"nid", "zid",
+			"lru",
+			"nr_scanned", "nr_rotated", "priority");
+$regex_writepage = generate_traceevent_regex(
+			"vmscan/mm_vmscan_writepage",
+			$regex_writepage_default,
+			"page", "pfn", "sync_io");
+
+sub read_statline($) {
+	my $pid = $_[0];
+	my $statline;
+
+	if (open(STAT, "/proc/$pid/stat")) {
+		$statline = <STAT>;
+		close(STAT);
+	}
+
+	if ($statline eq '') {
+		$statline = "-1 (UNKNOWN_PROCESS_NAME) R 0";
+	}
+
+	return $statline;
+}
+
+sub guess_process_pid($$) {
+	my $pid = $_[0];
+	my $statline = $_[1];
+
+	if ($pid == 0) {
+		return "swapper-0";
+	}
+
+	if ($statline !~ /$regex_statname/o) {
+		die("Failed to math stat line for process name :: $statline");
+	}
+	return "$1-$pid";
+}
+
+# Convert sec.usec timestamp format
+sub timestamp_to_ms($) {
+	my $timestamp = $_[0];
+
+	my ($sec, $usec) = split (/\./, $timestamp);
+	return ($sec * 1000) + ($usec / 1000);
+}
+
+sub process_events {
+	my $traceevent;
+	my $process_pid;
+	my $cpus;
+	my $timestamp;
+	my $tracepoint;
+	my $details;
+	my $statline;
+
+	# Read each line of the event log
+EVENT_PROCESS:
+	while ($traceevent = <STDIN>) {
+		if ($traceevent =~ /$regex_traceevent/o) {
+			$process_pid = $1;
+			$timestamp = $3;
+			$tracepoint = $4;
+
+			$process_pid =~ /(.*)-([0-9]*)$/;
+			my $process = $1;
+			my $pid = $2;
+
+			if ($process eq "") {
+				$process = $last_procmap{$pid};
+				$process_pid = "$process-$pid";
+			}
+			$last_procmap{$pid} = $process;
+
+			if ($opt_read_procstat) {
+				$statline = read_statline($pid);
+				if ($opt_read_procstat && $process eq '') {
+					$process_pid = guess_process_pid($pid, $statline);
+				}
+			}
+		} else {
+			next;
+		}
+
+		# Perl Switch() sucks majorly
+		if ($tracepoint eq "mm_vmscan_direct_reclaim_begin") {
+			$timestamp = timestamp_to_ms($timestamp);
+			$perprocesspid{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN}++;
+			$perprocesspid{$process_pid}->{STATE_DIRECT_BEGIN} = $timestamp;
+
+			$details = $5;
+			if ($details !~ /$regex_direct_begin/o) {
+				print "WARNING: Failed to parse mm_vmscan_direct_reclaim_begin as expected\n";
+				print "         $details\n";
+				print "         $regex_direct_begin\n";
+				next;
+			}
+			my $order = $1;
+			$perprocesspid{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN_PERORDER}[$order]++;
+			$perprocesspid{$process_pid}->{STATE_DIRECT_ORDER} = $order;
+		} elsif ($tracepoint eq "mm_vmscan_direct_reclaim_end") {
+			# Count the event itself
+			my $index = $perprocesspid{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_END};
+			$perprocesspid{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_END}++;
+
+			# Record how long direct reclaim took this time
+			if (defined $perprocesspid{$process_pid}->{STATE_DIRECT_BEGIN}) {
+				$timestamp = timestamp_to_ms($timestamp);
+				my $order = $perprocesspid{$process_pid}->{STATE_DIRECT_ORDER};
+				my $latency = ($timestamp - $perprocesspid{$process_pid}->{STATE_DIRECT_BEGIN});
+				$perprocesspid{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index] = "$order-$latency";
+			}
+		} elsif ($tracepoint eq "mm_vmscan_kswapd_wake") {
+			$details = $5;
+			if ($details !~ /$regex_kswapd_wake/o) {
+				print "WARNING: Failed to parse mm_vmscan_kswapd_wake as expected\n";
+				print "         $details\n";
+				print "         $regex_kswapd_wake\n";
+				next;
+			}
+
+			my $order = $2;
+			$perprocesspid{$process_pid}->{STATE_KSWAPD_ORDER} = $order;
+			if (!$perprocesspid{$process_pid}->{STATE_KSWAPD_BEGIN}) {
+				$timestamp = timestamp_to_ms($timestamp);
+				$perprocesspid{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE}++;
+				$perprocesspid{$process_pid}->{STATE_KSWAPD_BEGIN} = $timestamp;
+				$perprocesspid{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE_PERORDER}[$order]++;
+			} else {
+				$perprocesspid{$process_pid}->{HIGH_KSWAPD_REWAKEUP}++;
+				$perprocesspid{$process_pid}->{HIGH_KSWAPD_REWAKEUP_PERORDER}[$order]++;
+			}
+		} elsif ($tracepoint eq "mm_vmscan_kswapd_sleep") {
+
+			# Count the event itself
+			my $index = $perprocesspid{$process_pid}->{MM_VMSCAN_KSWAPD_SLEEP};
+			$perprocesspid{$process_pid}->{MM_VMSCAN_KSWAPD_SLEEP}++;
+
+			# Record how long kswapd was awake
+			$timestamp = timestamp_to_ms($timestamp);
+			my $order = $perprocesspid{$process_pid}->{STATE_KSWAPD_ORDER};
+			my $latency = ($timestamp - $perprocesspid{$process_pid}->{STATE_KSWAPD_BEGIN});
+			$perprocesspid{$process_pid}->{HIGH_KSWAPD_LATENCY}[$index] = "$order-$latency";
+			$perprocesspid{$process_pid}->{STATE_KSWAPD_BEGIN} = 0;
+		} elsif ($tracepoint eq "mm_vmscan_wakeup_kswapd") {
+			$perprocesspid{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD}++;
+
+			$details = $5;
+			if ($details !~ /$regex_wakeup_kswapd/o) {
+				print "WARNING: Failed to parse mm_vmscan_wakeup_kswapd as expected\n";
+				print "         $details\n";
+				print "         $regex_wakeup_kswapd\n";
+				next;
+			}
+			my $order = $3;
+			$perprocesspid{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD_PERORDER}[$order]++;
+		} elsif ($tracepoint eq "mm_vmscan_lru_isolate") {
+			$details = $5;
+			if ($details !~ /$regex_lru_isolate/o) {
+				print "WARNING: Failed to parse mm_vmscan_lru_isolate as expected\n";
+				print "         $details\n";
+				print "         $regex_lru_isolate/o\n";
+				next;
+			}
+			my $nr_scanned = $4;
+			my $nr_contig_dirty = $7;
+			$perprocesspid{$process_pid}->{HIGH_NR_SCANNED} += $nr_scanned;
+			$perprocesspid{$process_pid}->{HIGH_NR_CONTIG_DIRTY} += $nr_contig_dirty;
+		} elsif ($tracepoint eq "mm_vmscan_writepage") {
+			$details = $5;
+			if ($details !~ /$regex_writepage/o) {
+				print "WARNING: Failed to parse mm_vmscan_writepage as expected\n";
+				print "         $details\n";
+				print "         $regex_writepage\n";
+				next;
+			}
+
+			my $sync_io = $3;
+			if ($sync_io) {
+				$perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC}++;
+			} else {
+				$perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC}++;
+			}
+		} else {
+			$perprocesspid{$process_pid}->{EVENT_UNKNOWN}++;
+		}
+
+		if ($sigint_pending) {
+			last EVENT_PROCESS;
+		}
+	}
+}
+
+sub dump_stats {
+	my $hashref = shift;
+	my %stats = %$hashref;
+
+	# Dump per-process stats
+	my $process_pid;
+	my $max_strlen = 0;
+
+	# Get the maximum process name
+	foreach $process_pid (keys %perprocesspid) {
+		my $len = length($process_pid);
+		if ($len > $max_strlen) {
+			$max_strlen = $len;
+		}
+	}
+	$max_strlen += 2;
+
+	# Work out latencies
+	printf("\n") if !$opt_ignorepid;
+	printf("Reclaim latencies expressed as order-latency_in_ms\n") if !$opt_ignorepid;
+	foreach $process_pid (keys %stats) {
+
+		if (!$stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[0] &&
+				!$stats{$process_pid}->{HIGH_KSWAPD_LATENCY}[0]) {
+			next;
+		}
+
+		printf "%-" . $max_strlen . "s ", $process_pid if !$opt_ignorepid;
+		my $index = 0;
+		while (defined $stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index] ||
+			defined $stats{$process_pid}->{HIGH_KSWAPD_LATENCY}[$index]) {
+
+			if ($stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index]) {
+				printf("%s ", $stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index]) if !$opt_ignorepid;
+				my ($dummy, $latency) = split(/-/, $stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index]);
+				$total_direct_latency += $latency;
+			} else {
+				printf("%s ", $stats{$process_pid}->{HIGH_KSWAPD_LATENCY}[$index]) if !$opt_ignorepid;
+				my ($dummy, $latency) = split(/-/, $stats{$process_pid}->{HIGH_KSWAPD_LATENCY}[$index]);
+				$total_kswapd_latency += $latency;
+			}
+			$index++;
+		}
+		print "\n" if !$opt_ignorepid;
+	}
+
+	# Print out process activity
+	printf("\n");
+	printf("%-" . $max_strlen . "s %8s %10s   %8s   %8s %8s %8s %8s\n", "Process", "Direct",  "Wokeup", "Pages",   "Pages",   "Pages",     "Time");
+	printf("%-" . $max_strlen . "s %8s %10s   %8s   %8s %8s %8s %8s\n", "details", "Rclms",   "Kswapd", "Scanned", "Sync-IO", "ASync-IO",  "Stalled");
+	foreach $process_pid (keys %stats) {
+
+		if (!$stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN}) {
+			next;
+		}
+
+		$total_direct_reclaim += $stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN};
+		$total_wakeup_kswapd += $stats{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD};
+		$total_direct_nr_scanned += $stats{$process_pid}->{HIGH_NR_SCANNED};
+		$total_direct_writepage_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC};
+		$total_direct_writepage_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC};
+
+		my $index = 0;
+		my $this_reclaim_delay = 0;
+		while (defined $stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index]) {
+			 my ($dummy, $latency) = split(/-/, $stats{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$index]);
+			$this_reclaim_delay += $latency;
+			$index++;
+		}
+
+		printf("%-" . $max_strlen . "s %8d %10d   %8u   %8u %8u %8.3f",
+			$process_pid,
+			$stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN},
+			$stats{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD},
+			$stats{$process_pid}->{HIGH_NR_SCANNED},
+			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC},
+			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC},
+			$this_reclaim_delay / 1000);
+
+		if ($stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN}) {
+			print "      ";
+			for (my $order = 0; $order < 20; $order++) {
+				my $count = $stats{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN_PERORDER}[$order];
+				if ($count != 0) {
+					print "direct-$order=$count ";
+				}
+			}
+		}
+		if ($stats{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD}) {
+			print "      ";
+			for (my $order = 0; $order < 20; $order++) {
+				my $count = $stats{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD_PERORDER}[$order];
+				if ($count != 0) {
+					print "wakeup-$order=$count ";
+				}
+			}
+		}
+		if ($stats{$process_pid}->{HIGH_NR_CONTIG_DIRTY}) {
+			print "      ";
+			my $count = $stats{$process_pid}->{HIGH_NR_CONTIG_DIRTY};
+			if ($count != 0) {
+				print "contig-dirty=$count ";
+			}
+		}
+
+		print "\n";
+	}
+
+	# Print out kswapd activity
+	printf("\n");
+	printf("%-" . $max_strlen . "s %8s %10s   %8s   %8s %8s %8s\n", "Kswapd",   "Kswapd",  "Order",     "Pages",   "Pages",  "Pages");
+	printf("%-" . $max_strlen . "s %8s %10s   %8s   %8s %8s %8s\n", "Instance", "Wakeups", "Re-wakeup", "Scanned", "Sync-IO", "ASync-IO");
+	foreach $process_pid (keys %stats) {
+
+		if (!$stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE}) {
+			next;
+		}
+
+		$total_kswapd_wake += $stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE};
+		$total_kswapd_nr_scanned += $stats{$process_pid}->{HIGH_NR_SCANNED};
+		$total_kswapd_writepage_sync += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC};
+		$total_kswapd_writepage_async += $stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC};
+
+		printf("%-" . $max_strlen . "s %8d %10d   %8u   %8i %8u",
+			$process_pid,
+			$stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE},
+			$stats{$process_pid}->{HIGH_KSWAPD_REWAKEUP},
+			$stats{$process_pid}->{HIGH_NR_SCANNED},
+			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC},
+			$stats{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC});
+
+		if ($stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE}) {
+			print "      ";
+			for (my $order = 0; $order < 20; $order++) {
+				my $count = $stats{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE_PERORDER}[$order];
+				if ($count != 0) {
+					print "wake-$order=$count ";
+				}
+			}
+		}
+		if ($stats{$process_pid}->{HIGH_KSWAPD_REWAKEUP}) {
+			print "      ";
+			for (my $order = 0; $order < 20; $order++) {
+				my $count = $stats{$process_pid}->{HIGH_KSWAPD_REWAKEUP_PERORDER}[$order];
+				if ($count != 0) {
+					print "rewake-$order=$count ";
+				}
+			}
+		}
+		printf("\n");
+	}
+
+	# Print out summaries
+	$total_direct_latency /= 1000;
+	$total_kswapd_latency /= 1000;
+	print "\nSummary\n";
+	print "Direct reclaims:     		$total_direct_reclaim\n";
+	print "Direct reclaim pages scanned:	$total_direct_nr_scanned\n";
+	print "Direct reclaim write sync I/O:	$total_direct_writepage_sync\n";
+	print "Direct reclaim write async I/O:	$total_direct_writepage_async\n";
+	print "Wake kswapd requests:		$total_wakeup_kswapd\n";
+	printf "Time stalled direct reclaim: 	%-1.2f ms\n", $total_direct_latency;
+	print "\n";
+	print "Kswapd wakeups:			$total_kswapd_wake\n";
+	print "Kswapd pages scanned:		$total_kswapd_nr_scanned\n";
+	print "Kswapd reclaim write sync I/O:	$total_kswapd_writepage_sync\n";
+	print "Kswapd reclaim write async I/O:	$total_kswapd_writepage_async\n";
+	printf "Time kswapd awake:		%-1.2f ms\n", $total_kswapd_latency;
+}
+
+sub aggregate_perprocesspid() {
+	my $process_pid;
+	my $process;
+	undef %perprocess;
+
+	foreach $process_pid (keys %perprocesspid) {
+		$process = $process_pid;
+		$process =~ s/-([0-9])*$//;
+		if ($process eq '') {
+			$process = "NO_PROCESS_NAME";
+		}
+
+		$perprocess{$process}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN} += $perprocesspid{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN};
+		$perprocess{$process}->{MM_VMSCAN_KSWAPD_WAKE} += $perprocesspid{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE};
+		$perprocess{$process}->{MM_VMSCAN_WAKEUP_KSWAPD} += $perprocesspid{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD};
+		$perprocess{$process}->{HIGH_KSWAPD_REWAKEUP} += $perprocesspid{$process_pid}->{HIGH_KSWAPD_REWAKEUP};
+		$perprocess{$process}->{HIGH_NR_SCANNED} += $perprocesspid{$process_pid}->{HIGH_NR_SCANNED};
+		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_SYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_SYNC};
+		$perprocess{$process}->{MM_VMSCAN_WRITEPAGE_ASYNC} += $perprocesspid{$process_pid}->{MM_VMSCAN_WRITEPAGE_ASYNC};
+
+		for (my $order = 0; $order < 20; $order++) {
+			$perprocess{$process}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN_PERORDER}[$order] += $perprocesspid{$process_pid}->{MM_VMSCAN_DIRECT_RECLAIM_BEGIN_PERORDER}[$order];
+			$perprocess{$process}->{MM_VMSCAN_WAKEUP_KSWAPD_PERORDER}[$order] += $perprocesspid{$process_pid}->{MM_VMSCAN_WAKEUP_KSWAPD_PERORDER}[$order];
+			$perprocess{$process}->{MM_VMSCAN_KSWAPD_WAKE_PERORDER}[$order] += $perprocesspid{$process_pid}->{MM_VMSCAN_KSWAPD_WAKE_PERORDER}[$order];
+
+		}
+
+		# Aggregate direct reclaim latencies
+		my $wr_index = $perprocess{$process}->{MM_VMSCAN_DIRECT_RECLAIM_END};
+		my $rd_index = 0;
+		while (defined $perprocesspid{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$rd_index]) {
+			$perprocess{$process}->{HIGH_DIRECT_RECLAIM_LATENCY}[$wr_index] = $perprocesspid{$process_pid}->{HIGH_DIRECT_RECLAIM_LATENCY}[$rd_index];
+			$rd_index++;
+			$wr_index++;
+		}
+		$perprocess{$process}->{MM_VMSCAN_DIRECT_RECLAIM_END} = $wr_index;
+
+		# Aggregate kswapd latencies
+		my $wr_index = $perprocess{$process}->{MM_VMSCAN_KSWAPD_SLEEP};
+		my $rd_index = 0;
+		while (defined $perprocesspid{$process_pid}->{HIGH_KSWAPD_LATENCY}[$rd_index]) {
+			$perprocess{$process}->{HIGH_KSWAPD_LATENCY}[$wr_index] = $perprocesspid{$process_pid}->{HIGH_KSWAPD_LATENCY}[$rd_index];
+			$rd_index++;
+			$wr_index++;
+		}
+		$perprocess{$process}->{MM_VMSCAN_DIRECT_RECLAIM_END} = $wr_index;
+	}
+}
+
+sub report() {
+	if (!$opt_ignorepid) {
+		dump_stats(\%perprocesspid);
+	} else {
+		aggregate_perprocesspid();
+		dump_stats(\%perprocess);
+	}
+}
+
+# Process events or signals until neither is available
+sub signal_loop() {
+	my $sigint_processed;
+	do {
+		$sigint_processed = 0;
+		process_events();
+
+		# Handle pending signals if any
+		if ($sigint_pending) {
+			my $current_time = time;
+
+			if ($sigint_exit) {
+				print "Received exit signal\n";
+				$sigint_pending = 0;
+			}
+			if ($sigint_report) {
+				if ($current_time >= $sigint_received + 2) {
+					report();
+					$sigint_report = 0;
+					$sigint_pending = 0;
+					$sigint_processed = 1;
+				}
+			}
+		}
+	} while ($sigint_pending || $sigint_processed);
+}
+
+signal_loop();
+report();
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 9411d32..9f1afd3 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -98,11 +98,6 @@ extern void mem_cgroup_end_migration(struct mem_cgroup *mem,
 /*
  * For memory reclaim.
  */
-extern int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem);
-extern void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem,
-							int priority);
-extern void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem,
-							int priority);
 int mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg);
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg);
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b4d109e..b578eee 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -348,21 +348,6 @@ struct zone {
 	atomic_long_t		vm_stat[NR_VM_ZONE_STAT_ITEMS];
 
 	/*
-	 * prev_priority holds the scanning priority for this zone.  It is
-	 * defined as the scanning priority at which we achieved our reclaim
-	 * target at the previous try_to_free_pages() or balance_pgdat()
-	 * invocation.
-	 *
-	 * We use prev_priority as a measure of how much stress page reclaim is
-	 * under - it drives the swappiness decision: whether to unmap mapped
-	 * pages.
-	 *
-	 * Access to both this field is quite racy even on uniprocessor.  But
-	 * it is expected to average out OK.
-	 */
-	int prev_priority;
-
-	/*
 	 * The target ratio of ACTIVE_ANON to INACTIVE_ANON pages on
 	 * this zone's LRU.  Maintained by the pageout code.
 	 */
diff --git a/include/trace/events/gfpflags.h b/include/trace/events/gfpflags.h
new file mode 100644
index 0000000..e3615c0
--- /dev/null
+++ b/include/trace/events/gfpflags.h
@@ -0,0 +1,37 @@
+/*
+ * The order of these masks is important. Matching masks will be seen
+ * first and the left over flags will end up showing by themselves.
+ *
+ * For example, if we have GFP_KERNEL before GFP_USER we wil get:
+ *
+ *  GFP_KERNEL|GFP_HARDWALL
+ *
+ * Thus most bits set go first.
+ */
+#define show_gfp_flags(flags)						\
+	(flags) ? __print_flags(flags, "|",				\
+	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"}, \
+	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
+	{(unsigned long)GFP_USER,		"GFP_USER"},		\
+	{(unsigned long)GFP_TEMPORARY,		"GFP_TEMPORARY"},	\
+	{(unsigned long)GFP_KERNEL,		"GFP_KERNEL"},		\
+	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		\
+	{(unsigned long)GFP_ATOMIC,		"GFP_ATOMIC"},		\
+	{(unsigned long)GFP_NOIO,		"GFP_NOIO"},		\
+	{(unsigned long)__GFP_HIGH,		"GFP_HIGH"},		\
+	{(unsigned long)__GFP_WAIT,		"GFP_WAIT"},		\
+	{(unsigned long)__GFP_IO,		"GFP_IO"},		\
+	{(unsigned long)__GFP_COLD,		"GFP_COLD"},		\
+	{(unsigned long)__GFP_NOWARN,		"GFP_NOWARN"},		\
+	{(unsigned long)__GFP_REPEAT,		"GFP_REPEAT"},		\
+	{(unsigned long)__GFP_NOFAIL,		"GFP_NOFAIL"},		\
+	{(unsigned long)__GFP_NORETRY,		"GFP_NORETRY"},		\
+	{(unsigned long)__GFP_COMP,		"GFP_COMP"},		\
+	{(unsigned long)__GFP_ZERO,		"GFP_ZERO"},		\
+	{(unsigned long)__GFP_NOMEMALLOC,	"GFP_NOMEMALLOC"},	\
+	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
+	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
+	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
+	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"}		\
+	) : "GFP_NOWAIT"
+
diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 3adca0c..a9c87ad 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -6,43 +6,7 @@
 
 #include <linux/types.h>
 #include <linux/tracepoint.h>
-
-/*
- * The order of these masks is important. Matching masks will be seen
- * first and the left over flags will end up showing by themselves.
- *
- * For example, if we have GFP_KERNEL before GFP_USER we wil get:
- *
- *  GFP_KERNEL|GFP_HARDWALL
- *
- * Thus most bits set go first.
- */
-#define show_gfp_flags(flags)						\
-	(flags) ? __print_flags(flags, "|",				\
-	{(unsigned long)GFP_HIGHUSER_MOVABLE,	"GFP_HIGHUSER_MOVABLE"}, \
-	{(unsigned long)GFP_HIGHUSER,		"GFP_HIGHUSER"},	\
-	{(unsigned long)GFP_USER,		"GFP_USER"},		\
-	{(unsigned long)GFP_TEMPORARY,		"GFP_TEMPORARY"},	\
-	{(unsigned long)GFP_KERNEL,		"GFP_KERNEL"},		\
-	{(unsigned long)GFP_NOFS,		"GFP_NOFS"},		\
-	{(unsigned long)GFP_ATOMIC,		"GFP_ATOMIC"},		\
-	{(unsigned long)GFP_NOIO,		"GFP_NOIO"},		\
-	{(unsigned long)__GFP_HIGH,		"GFP_HIGH"},		\
-	{(unsigned long)__GFP_WAIT,		"GFP_WAIT"},		\
-	{(unsigned long)__GFP_IO,		"GFP_IO"},		\
-	{(unsigned long)__GFP_COLD,		"GFP_COLD"},		\
-	{(unsigned long)__GFP_NOWARN,		"GFP_NOWARN"},		\
-	{(unsigned long)__GFP_REPEAT,		"GFP_REPEAT"},		\
-	{(unsigned long)__GFP_NOFAIL,		"GFP_NOFAIL"},		\
-	{(unsigned long)__GFP_NORETRY,		"GFP_NORETRY"},		\
-	{(unsigned long)__GFP_COMP,		"GFP_COMP"},		\
-	{(unsigned long)__GFP_ZERO,		"GFP_ZERO"},		\
-	{(unsigned long)__GFP_NOMEMALLOC,	"GFP_NOMEMALLOC"},	\
-	{(unsigned long)__GFP_HARDWALL,		"GFP_HARDWALL"},	\
-	{(unsigned long)__GFP_THISNODE,		"GFP_THISNODE"},	\
-	{(unsigned long)__GFP_RECLAIMABLE,	"GFP_RECLAIMABLE"},	\
-	{(unsigned long)__GFP_MOVABLE,		"GFP_MOVABLE"}		\
-	) : "GFP_NOWAIT"
+#include "gfpflags.h"
 
 DECLARE_EVENT_CLASS(kmem_alloc,
 
diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
new file mode 100644
index 0000000..f2da66a
--- /dev/null
+++ b/include/trace/events/vmscan.h
@@ -0,0 +1,184 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM vmscan
+
+#if !defined(_TRACE_VMSCAN_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_VMSCAN_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+#include "gfpflags.h"
+
+TRACE_EVENT(mm_vmscan_kswapd_sleep,
+
+	TP_PROTO(int nid),
+
+	TP_ARGS(nid),
+
+	TP_STRUCT__entry(
+		__field(	int,	nid	)
+	),
+
+	TP_fast_assign(
+		__entry->nid	= nid;
+	),
+
+	TP_printk("nid=%d", __entry->nid)
+);
+
+TRACE_EVENT(mm_vmscan_kswapd_wake,
+
+	TP_PROTO(int nid, int order),
+
+	TP_ARGS(nid, order),
+
+	TP_STRUCT__entry(
+		__field(	int,	nid	)
+		__field(	int,	order	)
+	),
+
+	TP_fast_assign(
+		__entry->nid	= nid;
+		__entry->order	= order;
+	),
+
+	TP_printk("nid=%d order=%d", __entry->nid, __entry->order)
+);
+
+TRACE_EVENT(mm_vmscan_wakeup_kswapd,
+
+	TP_PROTO(int nid, int zid, int order),
+
+	TP_ARGS(nid, zid, order),
+
+	TP_STRUCT__entry(
+		__field(	int,		nid	)
+		__field(	int,		zid	)
+		__field(	int,		order	)
+	),
+
+	TP_fast_assign(
+		__entry->nid		= nid;
+		__entry->zid		= zid;
+		__entry->order		= order;
+	),
+
+	TP_printk("nid=%d zid=%d order=%d",
+		__entry->nid,
+		__entry->zid,
+		__entry->order)
+);
+
+TRACE_EVENT(mm_vmscan_direct_reclaim_begin,
+
+	TP_PROTO(int order, int may_writepage, gfp_t gfp_flags),
+
+	TP_ARGS(order, may_writepage, gfp_flags),
+
+	TP_STRUCT__entry(
+		__field(	int,	order		)
+		__field(	int,	may_writepage	)
+		__field(	gfp_t,	gfp_flags	)
+	),
+
+	TP_fast_assign(
+		__entry->order		= order;
+		__entry->may_writepage	= may_writepage;
+		__entry->gfp_flags	= gfp_flags;
+	),
+
+	TP_printk("order=%d may_writepage=%d gfp_flags=%s",
+		__entry->order,
+		__entry->may_writepage,
+		show_gfp_flags(__entry->gfp_flags))
+);
+
+TRACE_EVENT(mm_vmscan_direct_reclaim_end,
+
+	TP_PROTO(unsigned long nr_reclaimed),
+
+	TP_ARGS(nr_reclaimed),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	nr_reclaimed	)
+	),
+
+	TP_fast_assign(
+		__entry->nr_reclaimed	= nr_reclaimed;
+	),
+
+	TP_printk("nr_reclaimed=%lu", __entry->nr_reclaimed)
+);
+
+TRACE_EVENT(mm_vmscan_lru_isolate,
+
+	TP_PROTO(int order,
+		unsigned long nr_requested,
+		unsigned long nr_scanned,
+		unsigned long nr_taken,
+		unsigned long nr_lumpy_taken,
+		unsigned long nr_lumpy_dirty,
+		unsigned long nr_lumpy_failed,
+		int isolate_mode),
+
+	TP_ARGS(order, nr_requested, nr_scanned, nr_taken, nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed, isolate_mode),
+
+	TP_STRUCT__entry(
+		__field(int, order)
+		__field(unsigned long, nr_requested)
+		__field(unsigned long, nr_scanned)
+		__field(unsigned long, nr_taken)
+		__field(unsigned long, nr_lumpy_taken)
+		__field(unsigned long, nr_lumpy_dirty)
+		__field(unsigned long, nr_lumpy_failed)
+		__field(int, isolate_mode)
+	),
+
+	TP_fast_assign(
+		__entry->order = order;
+		__entry->nr_requested = nr_requested;
+		__entry->nr_scanned = nr_scanned;
+		__entry->nr_taken = nr_taken;
+		__entry->nr_lumpy_taken = nr_lumpy_taken;
+		__entry->nr_lumpy_dirty = nr_lumpy_dirty;
+		__entry->nr_lumpy_failed = nr_lumpy_failed;
+		__entry->isolate_mode = isolate_mode;
+	),
+
+	TP_printk("isolate_mode=%d order=%d nr_requested=%lu nr_scanned=%lu nr_taken=%lu contig_taken=%lu contig_dirty=%lu contig_failed=%lu",
+		__entry->isolate_mode,
+		__entry->order,
+		__entry->nr_requested,
+		__entry->nr_scanned,
+		__entry->nr_taken,
+		__entry->nr_lumpy_taken,
+		__entry->nr_lumpy_dirty,
+		__entry->nr_lumpy_failed)
+);
+
+TRACE_EVENT(mm_vmscan_writepage,
+
+	TP_PROTO(struct page *page,
+		int sync_io),
+
+	TP_ARGS(page, sync_io),
+
+	TP_STRUCT__entry(
+		__field(struct page *, page)
+		__field(int, sync_io)
+	),
+
+	TP_fast_assign(
+		__entry->page = page;
+		__entry->sync_io = sync_io;
+	),
+
+	TP_printk("page=%p pfn=%lu sync_io=%d",
+		__entry->page,
+		page_to_pfn(__entry->page),
+		__entry->sync_io)
+);
+
+#endif /* _TRACE_VMSCAN_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 20a8193..31abd1c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -211,8 +211,6 @@ struct mem_cgroup {
 	*/
 	spinlock_t reclaim_param_lock;
 
-	int	prev_priority;	/* for recording reclaim priority */
-
 	/*
 	 * While reclaiming in a hierarchy, we cache the last child we
 	 * reclaimed from.
@@ -858,35 +856,6 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem)
 	return ret;
 }
 
-/*
- * prev_priority control...this will be used in memory reclaim path.
- */
-int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
-{
-	int prev_priority;
-
-	spin_lock(&mem->reclaim_param_lock);
-	prev_priority = mem->prev_priority;
-	spin_unlock(&mem->reclaim_param_lock);
-
-	return prev_priority;
-}
-
-void mem_cgroup_note_reclaim_priority(struct mem_cgroup *mem, int priority)
-{
-	spin_lock(&mem->reclaim_param_lock);
-	if (priority < mem->prev_priority)
-		mem->prev_priority = priority;
-	spin_unlock(&mem->reclaim_param_lock);
-}
-
-void mem_cgroup_record_reclaim_priority(struct mem_cgroup *mem, int priority)
-{
-	spin_lock(&mem->reclaim_param_lock);
-	mem->prev_priority = priority;
-	spin_unlock(&mem->reclaim_param_lock);
-}
-
 static int calc_inactive_ratio(struct mem_cgroup *memcg, unsigned long *present_pages)
 {
 	unsigned long active;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 431214b..0b0b629 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4081,8 +4081,6 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
 		zone_seqlock_init(zone);
 		zone->zone_pgdat = pgdat;
 
-		zone->prev_priority = DEF_PRIORITY;
-
 		zone_pcp_init(zone);
 		for_each_lru(l) {
 			INIT_LIST_HEAD(&zone->lru[l].list);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9c7e57c..e6ddba9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -48,6 +48,9 @@
 
 #include "internal.h"
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/vmscan.h>
+
 struct scan_control {
 	/* Incremented by the number of inactive pages that were scanned */
 	unsigned long nr_scanned;
@@ -290,13 +293,13 @@ static int may_write_to_queue(struct backing_dev_info *bdi)
  * prevents it from being freed up.  But we have a ref on the page and once
  * that page is locked, the mapping is pinned.
  *
- * We're allowed to run sleeping lock_page() here because we know the caller has
- * __GFP_FS.
+ * We're allowed to run sleeping lock_page_nosync() here because we know the
+ * caller has __GFP_FS.
  */
 static void handle_write_error(struct address_space *mapping,
 				struct page *page, int error)
 {
-	lock_page(page);
+	lock_page_nosync(page);
 	if (page_mapping(page) == mapping)
 		mapping_set_error(mapping, error);
 	unlock_page(page);
@@ -396,6 +399,8 @@ static pageout_t pageout(struct page *page, struct address_space *mapping,
 			/* synchronous write or broken a_ops? */
 			ClearPageReclaim(page);
 		}
+		trace_mm_vmscan_writepage(page,
+			sync_writeback == PAGEOUT_IO_SYNC);
 		inc_zone_page_state(page, NR_VMSCAN_WRITE);
 		return PAGE_SUCCESS;
 	}
@@ -615,6 +620,24 @@ static enum page_references page_check_references(struct page *page,
 	return PAGEREF_RECLAIM;
 }
 
+static noinline_for_stack void free_page_list(struct list_head *free_pages)
+{
+	struct pagevec freed_pvec;
+	struct page *page, *tmp;
+
+	pagevec_init(&freed_pvec, 1);
+
+	list_for_each_entry_safe(page, tmp, free_pages, lru) {
+		list_del(&page->lru);
+		if (!pagevec_add(&freed_pvec, page)) {
+			__pagevec_free(&freed_pvec);
+			pagevec_reinit(&freed_pvec);
+		}
+	}
+
+	pagevec_free(&freed_pvec);
+}
+
 /*
  * shrink_page_list() returns the number of reclaimed pages
  */
@@ -623,13 +646,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 					enum pageout_io sync_writeback)
 {
 	LIST_HEAD(ret_pages);
-	struct pagevec freed_pvec;
+	LIST_HEAD(free_pages);
 	int pgactivate = 0;
 	unsigned long nr_reclaimed = 0;
 
 	cond_resched();
 
-	pagevec_init(&freed_pvec, 1);
 	while (!list_empty(page_list)) {
 		enum page_references references;
 		struct address_space *mapping;
@@ -804,10 +826,12 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		__clear_page_locked(page);
 free_it:
 		nr_reclaimed++;
-		if (!pagevec_add(&freed_pvec, page)) {
-			__pagevec_free(&freed_pvec);
-			pagevec_reinit(&freed_pvec);
-		}
+
+		/*
+		 * Is there need to periodically free_page_list? It would
+		 * appear not as the counts should be low
+		 */
+		list_add(&page->lru, &free_pages);
 		continue;
 
 cull_mlocked:
@@ -830,9 +854,10 @@ keep:
 		list_add(&page->lru, &ret_pages);
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
+
+	free_page_list(&free_pages);
+
 	list_splice(&ret_pages, page_list);
-	if (pagevec_count(&freed_pvec))
-		__pagevec_free(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
 	return nr_reclaimed;
 }
@@ -914,6 +939,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		unsigned long *scanned, int order, int mode, int file)
 {
 	unsigned long nr_taken = 0;
+	unsigned long nr_lumpy_taken = 0, nr_lumpy_dirty = 0, nr_lumpy_failed = 0;
 	unsigned long scan;
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
@@ -991,12 +1017,25 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				list_move(&cursor_page->lru, dst);
 				mem_cgroup_del_lru(cursor_page);
 				nr_taken++;
+				nr_lumpy_taken++;
+				if (PageDirty(cursor_page))
+					nr_lumpy_dirty++;
 				scan++;
+			} else {
+				if (mode == ISOLATE_BOTH &&
+						page_count(cursor_page))
+					nr_lumpy_failed++;
 			}
 		}
 	}
 
 	*scanned = scan;
+
+	trace_mm_vmscan_lru_isolate(order,
+			nr_to_scan, scan,
+			nr_taken,
+			nr_lumpy_taken, nr_lumpy_dirty, nr_lumpy_failed,
+			mode);
 	return nr_taken;
 }
 
@@ -1033,7 +1072,8 @@ static unsigned long clear_active_flags(struct list_head *page_list,
 			ClearPageActive(page);
 			nr_active++;
 		}
-		count[lru]++;
+		if (count)
+			count[lru]++;
 	}
 
 	return nr_active;
@@ -1110,174 +1150,177 @@ static int too_many_isolated(struct zone *zone, int file,
 }
 
 /*
- * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
- * of reclaimed pages
+ * TODO: Try merging with migrations version of putback_lru_pages
  */
-static unsigned long shrink_inactive_list(unsigned long max_scan,
-			struct zone *zone, struct scan_control *sc,
-			int priority, int file)
+static noinline_for_stack void
+putback_lru_pages(struct zone *zone, struct scan_control *sc,
+				unsigned long nr_anon, unsigned long nr_file,
+				struct list_head *page_list)
 {
-	LIST_HEAD(page_list);
+	struct page *page;
 	struct pagevec pvec;
-	unsigned long nr_scanned = 0;
-	unsigned long nr_reclaimed = 0;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
-	while (unlikely(too_many_isolated(zone, file, sc))) {
-		congestion_wait(BLK_RW_ASYNC, HZ/10);
+	pagevec_init(&pvec, 1);
 
-		/* We are about to die and free our memory. Return now. */
-		if (fatal_signal_pending(current))
-			return SWAP_CLUSTER_MAX;
+	/*
+	 * Put back any unfreeable pages.
+	 */
+	spin_lock(&zone->lru_lock);
+	while (!list_empty(page_list)) {
+		int lru;
+		page = lru_to_page(page_list);
+		VM_BUG_ON(PageLRU(page));
+		list_del(&page->lru);
+		if (unlikely(!page_evictable(page, NULL))) {
+			spin_unlock_irq(&zone->lru_lock);
+			putback_lru_page(page);
+			spin_lock_irq(&zone->lru_lock);
+			continue;
+		}
+		SetPageLRU(page);
+		lru = page_lru(page);
+		add_page_to_lru_list(zone, page, lru);
+		if (is_active_lru(lru)) {
+			int file = is_file_lru(lru);
+			reclaim_stat->recent_rotated[file]++;
+		}
+		if (!pagevec_add(&pvec, page)) {
+			spin_unlock_irq(&zone->lru_lock);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
 	}
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 
+	spin_unlock_irq(&zone->lru_lock);
+	pagevec_release(&pvec);
+}
 
-	pagevec_init(&pvec, 1);
+static noinline_for_stack void update_isolated_counts(struct zone *zone,
+					struct scan_control *sc,
+					unsigned long *nr_anon,
+					unsigned long *nr_file,
+					struct list_head *isolated_list)
+{
+	unsigned long nr_active;
+	unsigned int count[NR_LRU_LISTS] = { 0, };
+	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
-	lru_add_drain();
-	spin_lock_irq(&zone->lru_lock);
-	do {
-		struct page *page;
-		unsigned long nr_taken;
-		unsigned long nr_scan;
-		unsigned long nr_freed;
-		unsigned long nr_active;
-		unsigned int count[NR_LRU_LISTS] = { 0, };
-		int mode = sc->lumpy_reclaim_mode ? ISOLATE_BOTH : ISOLATE_INACTIVE;
-		unsigned long nr_anon;
-		unsigned long nr_file;
+	nr_active = clear_active_flags(isolated_list, count);
+	__count_vm_events(PGDEACTIVATE, nr_active);
 
-		if (scanning_global_lru(sc)) {
-			nr_taken = isolate_pages_global(SWAP_CLUSTER_MAX,
-							&page_list, &nr_scan,
-							sc->order, mode,
-							zone, 0, file);
-			zone->pages_scanned += nr_scan;
-			if (current_is_kswapd())
-				__count_zone_vm_events(PGSCAN_KSWAPD, zone,
-						       nr_scan);
-			else
-				__count_zone_vm_events(PGSCAN_DIRECT, zone,
-						       nr_scan);
-		} else {
-			nr_taken = mem_cgroup_isolate_pages(SWAP_CLUSTER_MAX,
-							&page_list, &nr_scan,
-							sc->order, mode,
-							zone, sc->mem_cgroup,
-							0, file);
-			/*
-			 * mem_cgroup_isolate_pages() keeps track of
-			 * scanned pages on its own.
-			 */
-		}
+	__mod_zone_page_state(zone, NR_ACTIVE_FILE,
+			      -count[LRU_ACTIVE_FILE]);
+	__mod_zone_page_state(zone, NR_INACTIVE_FILE,
+			      -count[LRU_INACTIVE_FILE]);
+	__mod_zone_page_state(zone, NR_ACTIVE_ANON,
+			      -count[LRU_ACTIVE_ANON]);
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON,
+			      -count[LRU_INACTIVE_ANON]);
 
-		if (nr_taken == 0)
-			goto done;
+	*nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
+	*nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, *nr_anon);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, *nr_file);
 
-		nr_active = clear_active_flags(&page_list, count);
-		__count_vm_events(PGDEACTIVATE, nr_active);
+	reclaim_stat->recent_scanned[0] += *nr_anon;
+	reclaim_stat->recent_scanned[1] += *nr_file;
+}
 
-		__mod_zone_page_state(zone, NR_ACTIVE_FILE,
-						-count[LRU_ACTIVE_FILE]);
-		__mod_zone_page_state(zone, NR_INACTIVE_FILE,
-						-count[LRU_INACTIVE_FILE]);
-		__mod_zone_page_state(zone, NR_ACTIVE_ANON,
-						-count[LRU_ACTIVE_ANON]);
-		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
-						-count[LRU_INACTIVE_ANON]);
+/*
+ * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
+ * of reclaimed pages
+ */
+static noinline_for_stack unsigned long
+shrink_inactive_list(unsigned long nr_to_scan, struct zone *zone,
+			struct scan_control *sc, int priority, int file)
+{
+	LIST_HEAD(page_list);
+	unsigned long nr_scanned;
+	unsigned long nr_reclaimed = 0;
+	unsigned long nr_taken;
+	unsigned long nr_active;
+	unsigned long nr_anon;
+	unsigned long nr_file;
 
-		nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
-		nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
-		__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
-		__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
+	while (unlikely(too_many_isolated(zone, file, sc))) {
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
-		reclaim_stat->recent_scanned[0] += nr_anon;
-		reclaim_stat->recent_scanned[1] += nr_file;
+		/* We are about to die and free our memory. Return now. */
+		if (fatal_signal_pending(current))
+			return SWAP_CLUSTER_MAX;
+	}
 
-		spin_unlock_irq(&zone->lru_lock);
 
-		nr_scanned += nr_scan;
-		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
+	lru_add_drain();
+	spin_lock_irq(&zone->lru_lock);
 
+	if (scanning_global_lru(sc)) {
+		nr_taken = isolate_pages_global(nr_to_scan,
+			&page_list, &nr_scanned, sc->order,
+			sc->lumpy_reclaim_mode ?
+				ISOLATE_BOTH : ISOLATE_INACTIVE,
+			zone, 0, file);
+		zone->pages_scanned += nr_scanned;
+		if (current_is_kswapd())
+			__count_zone_vm_events(PGSCAN_KSWAPD, zone,
+					       nr_scanned);
+		else
+			__count_zone_vm_events(PGSCAN_DIRECT, zone,
+					       nr_scanned);
+	} else {
+		nr_taken = mem_cgroup_isolate_pages(nr_to_scan,
+			&page_list, &nr_scanned, sc->order,
+			sc->lumpy_reclaim_mode ?
+				ISOLATE_BOTH : ISOLATE_INACTIVE,
+			zone, sc->mem_cgroup,
+			0, file);
 		/*
-		 * If we are direct reclaiming for contiguous pages and we do
-		 * not reclaim everything in the list, try again and wait
-		 * for IO to complete. This will stall high-order allocations
-		 * but that should be acceptable to the caller
+		 * mem_cgroup_isolate_pages() keeps track of
+		 * scanned pages on its own.
 		 */
-		if (nr_freed < nr_taken && !current_is_kswapd() &&
-		    sc->lumpy_reclaim_mode) {
-			congestion_wait(BLK_RW_ASYNC, HZ/10);
+	}
 
-			/*
-			 * The attempt at page out may have made some
-			 * of the pages active, mark them inactive again.
-			 */
-			nr_active = clear_active_flags(&page_list, count);
-			count_vm_events(PGDEACTIVATE, nr_active);
+	if (nr_taken == 0) {
+		spin_unlock_irq(&zone->lru_lock);
+		return 0;
+	}
 
-			nr_freed += shrink_page_list(&page_list, sc,
-							PAGEOUT_IO_SYNC);
-		}
+	update_isolated_counts(zone, sc, &nr_anon, &nr_file, &page_list);
 
-		nr_reclaimed += nr_freed;
+	spin_unlock_irq(&zone->lru_lock);
 
-		local_irq_disable();
-		if (current_is_kswapd())
-			__count_vm_events(KSWAPD_STEAL, nr_freed);
-		__count_zone_vm_events(PGSTEAL, zone, nr_freed);
+	nr_reclaimed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
+
+	/*
+	 * If we are direct reclaiming for contiguous pages and we do
+	 * not reclaim everything in the list, try again and wait
+	 * for IO to complete. This will stall high-order allocations
+	 * but that should be acceptable to the caller
+	 */
+	if (nr_reclaimed < nr_taken && !current_is_kswapd() &&
+			sc->lumpy_reclaim_mode) {
+		congestion_wait(BLK_RW_ASYNC, HZ/10);
 
-		spin_lock(&zone->lru_lock);
 		/*
-		 * Put back any unfreeable pages.
+		 * The attempt at page out may have made some
+		 * of the pages active, mark them inactive again.
 		 */
-		while (!list_empty(&page_list)) {
-			int lru;
-			page = lru_to_page(&page_list);
-			VM_BUG_ON(PageLRU(page));
-			list_del(&page->lru);
-			if (unlikely(!page_evictable(page, NULL))) {
-				spin_unlock_irq(&zone->lru_lock);
-				putback_lru_page(page);
-				spin_lock_irq(&zone->lru_lock);
-				continue;
-			}
-			SetPageLRU(page);
-			lru = page_lru(page);
-			add_page_to_lru_list(zone, page, lru);
-			if (is_active_lru(lru)) {
-				int file = is_file_lru(lru);
-				reclaim_stat->recent_rotated[file]++;
-			}
-			if (!pagevec_add(&pvec, page)) {
-				spin_unlock_irq(&zone->lru_lock);
-				__pagevec_release(&pvec);
-				spin_lock_irq(&zone->lru_lock);
-			}
-		}
-		__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
-		__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
+		nr_active = clear_active_flags(&page_list, NULL);
+		count_vm_events(PGDEACTIVATE, nr_active);
 
-  	} while (nr_scanned < max_scan);
+		nr_reclaimed += shrink_page_list(&page_list, sc, PAGEOUT_IO_SYNC);
+	}
 
-done:
-	spin_unlock_irq(&zone->lru_lock);
-	pagevec_release(&pvec);
-	return nr_reclaimed;
-}
+	local_irq_disable();
+	if (current_is_kswapd())
+		__count_vm_events(KSWAPD_STEAL, nr_reclaimed);
+	__count_zone_vm_events(PGSTEAL, zone, nr_reclaimed);
 
-/*
- * We are about to scan this zone at a certain priority level.  If that priority
- * level is smaller (ie: more urgent) than the previous priority, then note
- * that priority level within the zone.  This is done so that when the next
- * process comes in to scan this zone, it will immediately start out at this
- * priority level rather than having to build up its own scanning priority.
- * Here, this priority affects only the reclaim-mapped threshold.
- */
-static inline void note_zone_scanning_priority(struct zone *zone, int priority)
-{
-	if (priority < zone->prev_priority)
-		zone->prev_priority = priority;
+	putback_lru_pages(zone, sc, nr_anon, nr_file, &page_list);
+	return nr_reclaimed;
 }
 
 /*
@@ -1727,13 +1770,12 @@ static void shrink_zone(int priority, struct zone *zone,
 static bool shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
-	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	struct zoneref *z;
 	struct zone *zone;
 	bool all_unreclaimable = true;
 
-	for_each_zone_zonelist_nodemask(zone, z, zonelist, high_zoneidx,
-					sc->nodemask) {
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+					gfp_zone(sc->gfp_mask), sc->nodemask) {
 		if (!populated_zone(zone))
 			continue;
 		/*
@@ -1743,17 +1785,8 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 		if (scanning_global_lru(sc)) {
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
-			note_zone_scanning_priority(zone, priority);
-
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;	/* Let kswapd poll it */
-		} else {
-			/*
-			 * Ignore cpuset limitation here. We just want to reduce
-			 * # of used pages by us regardless of memory shortage.
-			 */
-			mem_cgroup_note_reclaim_priority(sc->mem_cgroup,
-							priority);
 		}
 
 		shrink_zone(priority, zone, sc);
@@ -1788,7 +1821,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	unsigned long lru_pages = 0;
 	struct zoneref *z;
 	struct zone *zone;
-	enum zone_type high_zoneidx = gfp_zone(sc->gfp_mask);
 	unsigned long writeback_threshold;
 
 	get_mems_allowed();
@@ -1800,7 +1832,8 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	 * mem_cgroup will not do shrink_slab.
 	 */
 	if (scanning_global_lru(sc)) {
-		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+		for_each_zone_zonelist(zone, z, zonelist,
+				gfp_zone(sc->gfp_mask)) {
 
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
@@ -1859,17 +1892,6 @@ out:
 	if (priority < 0)
 		priority = 0;
 
-	if (scanning_global_lru(sc)) {
-		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
-
-			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
-				continue;
-
-			zone->prev_priority = priority;
-		}
-	} else
-		mem_cgroup_record_reclaim_priority(sc->mem_cgroup, priority);
-
 	delayacct_freepages_end();
 	put_mems_allowed();
 
@@ -1886,6 +1908,7 @@ out:
 unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 				gfp_t gfp_mask, nodemask_t *nodemask)
 {
+	unsigned long nr_reclaimed;
 	struct scan_control sc = {
 		.gfp_mask = gfp_mask,
 		.may_writepage = !laptop_mode,
@@ -1898,7 +1921,15 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 		.nodemask = nodemask,
 	};
 
-	return do_try_to_free_pages(zonelist, &sc);
+	trace_mm_vmscan_direct_reclaim_begin(order,
+				sc.may_writepage,
+				gfp_mask);
+
+	nr_reclaimed = do_try_to_free_pages(zonelist, &sc);
+
+	trace_mm_vmscan_direct_reclaim_end(nr_reclaimed);
+
+	return nr_reclaimed;
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
@@ -2026,22 +2057,12 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, int order)
 		.order = order,
 		.mem_cgroup = NULL,
 	};
-	/*
-	 * temp_priority is used to remember the scanning priority at which
-	 * this zone was successfully refilled to
-	 * free_pages == high_wmark_pages(zone).
-	 */
-	int temp_priority[MAX_NR_ZONES];
-
 loop_again:
 	total_scanned = 0;
 	sc.nr_reclaimed = 0;
 	sc.may_writepage = !laptop_mode;
 	count_vm_event(PAGEOUTRUN);
 
-	for (i = 0; i < pgdat->nr_zones; i++)
-		temp_priority[i] = DEF_PRIORITY;
-
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
 		int end_zone = 0;	/* Inclusive.  0 = ZONE_DMA */
 		unsigned long lru_pages = 0;
@@ -2109,9 +2130,7 @@ loop_again:
 			if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 				continue;
 
-			temp_priority[i] = priority;
 			sc.nr_scanned = 0;
-			note_zone_scanning_priority(zone, priority);
 
 			nid = pgdat->node_id;
 			zid = zone_idx(zone);
@@ -2184,16 +2203,6 @@ loop_again:
 			break;
 	}
 out:
-	/*
-	 * Note within each zone the priority level at which this zone was
-	 * brought into a happy state.  So that the next thread which scans this
-	 * zone will start out at that priority level.
-	 */
-	for (i = 0; i < pgdat->nr_zones; i++) {
-		struct zone *zone = pgdat->node_zones + i;
-
-		zone->prev_priority = temp_priority[i];
-	}
 	if (!all_zones_ok) {
 		cond_resched();
 
@@ -2297,9 +2306,10 @@ static int kswapd(void *p)
 				 * premature sleep. If not, then go fully
 				 * to sleep until explicitly woken up
 				 */
-				if (!sleeping_prematurely(pgdat, order, remaining))
+				if (!sleeping_prematurely(pgdat, order, remaining)) {
+					trace_mm_vmscan_kswapd_sleep(pgdat->node_id);
 					schedule();
-				else {
+				} else {
 					if (remaining)
 						count_vm_event(KSWAPD_LOW_WMARK_HIT_QUICKLY);
 					else
@@ -2319,8 +2329,10 @@ static int kswapd(void *p)
 		 * We can speed up thawing tasks if we don't call balance_pgdat
 		 * after returning from the refrigerator
 		 */
-		if (!ret)
+		if (!ret) {
+			trace_mm_vmscan_kswapd_wake(pgdat->node_id, order);
 			balance_pgdat(pgdat, order);
+		}
 	}
 	return 0;
 }
@@ -2340,6 +2352,7 @@ void wakeup_kswapd(struct zone *zone, int order)
 		return;
 	if (pgdat->kswapd_max_order < order)
 		pgdat->kswapd_max_order = order;
+	trace_mm_vmscan_wakeup_kswapd(pgdat->node_id, zone_idx(zone), order);
 	if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 		return;
 	if (!waitqueue_active(&pgdat->kswapd_wait))
@@ -2609,7 +2622,6 @@ static int __zone_reclaim(struct zone *zone, gfp_t gfp_mask, unsigned int order)
 		 */
 		priority = ZONE_RECLAIM_PRIORITY;
 		do {
-			note_zone_scanning_priority(zone, priority);
 			shrink_zone(priority, zone, &sc);
 			priority--;
 		} while (priority >= 0 && sc.nr_reclaimed < nr_pages);
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7759941..5c0b1b6 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -853,11 +853,9 @@ static void zoneinfo_show_print(struct seq_file *m, pg_data_t *pgdat,
 	}
 	seq_printf(m,
 		   "\n  all_unreclaimable: %u"
-		   "\n  prev_priority:     %i"
 		   "\n  start_pfn:         %lu"
 		   "\n  inactive_ratio:    %u",
 		   zone->all_unreclaimable,
-		   zone->prev_priority,
 		   zone->zone_start_pfn,
 		   zone->inactive_ratio);
 	seq_putc(m, '\n');

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
