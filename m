Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 74C116B0078
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 21:28:56 -0500 (EST)
Message-ID: <4B6B81B7.8040303@bx.jp.nec.com>
Date: Thu, 04 Feb 2010 21:25:59 -0500
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: [RFC PATCH -tip 2/2 v3] add scripts for pagecache analysis per process
References: <4B6B7FBF.9090005@bx.jp.nec.com>
In-Reply-To: <4B6B7FBF.9090005@bx.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, mingo@elte.hu
Cc: Keiichi KII <k-keiichi@bx.jp.nec.com>, lwoodman@redhat.com, linux-mm@kvack.org, Tom Zanussi <tzanussi@gmail.com>, riel@redhat.com, rostedt@goodmis.org, akpm@linux-foundation.org, fweisbec@gmail.com, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

The scripts are implemented based on the trace stream scripting support.
And the scripts implement the following and depend on the page cache 
tracepoints.

 - pagecache hit ratio per process
 - how many pagecaches each process has per each file
 - how many pages are cached per each file
 - how many pagecaches each process shares

To monitor pagecache hit ratio per process, run "pagecache-hit-ratio-record"
or "pref trace record pagecache-hit-ratio" to record perf data for 
"pagecache-hit-ration.pl" and run "pagecache-hit-ratio-report" or
"perf trace report pagecache-usage" to display.

The below outputs show execution sample.

[process list]
o yum-3215
                          cache find  cache hit  cache hit
        device      inode      count      count      ratio
  --------------------------------------------------------
         253:0         16      34434      34130     99.12%
         253:0        198       9692       9463     97.64%
         253:0        639        647        628     97.06%
         253:0        778         32         29     90.62%
         253:0       7305      50225      49005     97.57%
         253:0     144217         12         10     83.33%
         253:0     262775         16         13     81.25%
*snip*

To monitor pagecache usage per a process, run "pagecache-usage-record" or
"perf trace record pagecache-usage" to record perf data for 
"pagecache-usage.pl" and run "pagecache-usage-report" or "perf trace report
pagecache-usage" to display.

The below outputs show execution sample.

[file list]
        device              cached
     (maj:min)      inode    pages
  --------------------------------
         253:0         16     5752
         253:0        198     2233
         253:0        639       51
         253:0        778       86
         253:0       7305    12307
         253:0     144217       11
         253:0     262775       39
*snip*

[process list]
o yum-3215
        device              cached    added  removed      indirect
     (maj:min)      inode    pages    pages    pages removed pages
  ----------------------------------------------------------------
         253:0         16    34130     5752        0             0
         253:0        198     9463     2233        0             0
         253:0        639      628       51        0             0
         253:0        778       29       78        0             0
         253:0       7305    49005    12307        0             0
         253:0     144217       10       11        0             0
         253:0     262775       13       39        0             0
*snip*
  ----------------------------------------------------------------
  total:                    102346    26165        1             0

>From the output, we can know some information like:

- if "added pages" > "cached pages" on process list then
    It means repeating add/remove pagecache many times.
  => Bad case for pagecache usage

- if "added pages" <= "cached pages" on process list then
    It means no unnecessary I/O operations.
  => Good case for pagecache usage.

- if "caches" on file list > 
         sum "cached pages" per each file on process list then
    It means there are unneccessary pagecaches in the memory. 
  => Bad case for pagecache usage

Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
---
 tools/perf/scripts/perl/bin/pagecache-hit-ratio-record |    7 
 tools/perf/scripts/perl/bin/pagecache-hit-ratio-report |    6 
 tools/perf/scripts/perl/bin/pagecache-usage-record     |    7 
 tools/perf/scripts/perl/bin/pagecache-usage-report     |    6 
 tools/perf/scripts/perl/pagecache-hit-ratio.pl         |   75 +++++++++
 tools/perf/scripts/perl/pagecache-usage.pl             |  136 +++++++++++++++++
 6 files changed, 237 insertions(+)

Index: linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-usage-record
===================================================================
--- /dev/null
+++ linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-usage-record
@@ -0,0 +1,7 @@
+#!/bin/bash
+perf record -c 1 -f -a -M -R -e filemap:add_to_page_cache -e filemap:find_get_page -e filemap:remove_from_page_cache
+
+
+
+
+
Index: linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-usage-report
===================================================================
--- /dev/null
+++ linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-usage-report
@@ -0,0 +1,6 @@
+#!/bin/bash
+# description: pagecache usage per process
+perf trace -s ~/libexec/perf-core/scripts/perl/pagecache-usage.pl
+
+
+
Index: linux-2.6-tip/tools/perf/scripts/perl/pagecache-usage.pl
===================================================================
--- /dev/null
+++ linux-2.6-tip/tools/perf/scripts/perl/pagecache-usage.pl
@@ -0,0 +1,136 @@
+#!/usr/bin/perl -w
+# (C) 2010, Keiichi Kii <k-keiichi@bx.jp.nec.com>
+# Licensed under the terms of the GNU GPL License version 2
+
+# Display pagecache usage per a process
+
+use lib "$ENV{'PERF_EXEC_PATH'}/scripts/perl/Perf-Trace-Util/lib";
+use lib "./Perf-Trace-Util/lib";
+use Perf::Trace::Core;
+use Perf::Trace::Context;
+use Perf::Trace::Util;
+use List::Util qw/sum/;
+
+my %files;
+my %processes;
+my %records;
+
+sub trace_end
+{
+	print_pagecache_usage_per_file();
+	print "\n";
+	print_pagecache_usage_per_process();
+}
+
+sub filemap::remove_from_page_cache
+{
+	my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
+	    $common_pid, $common_comm,
+	    $s_dev, $i_ino, $offset) = @_;
+	my ($f, $r) = get_record($common_comm."-".$common_pid, $s_dev, $i_ino);
+
+	delete $$f{$offset};
+	if (defined $$r{added}{$offset}) {
+	    $$r{removed}++;
+	} else {
+	    $$r{indirect_removed}++;
+	}
+}
+
+sub filemap::add_to_page_cache
+{
+	my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
+	    $common_pid, $common_comm,
+	    $s_dev, $i_ino, $offset) = @_;
+	my ($f, $r) = get_record($common_comm."-".$common_pid, $s_dev, $i_ino);
+
+	$$f{$offset}++;
+	$$r{added}{$offset}++;
+}
+
+sub filemap::find_get_page
+{
+	my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
+	    $common_pid, $common_comm,
+	    $s_dev, $i_ino, $offset, $page) = @_;
+	my ($f, $r) = get_record($common_comm."-".$common_pid, $s_dev, $i_ino);
+
+	if ($page != 0) {
+	    $$f{$offset}++;
+	    $$r{cached}++;
+	}
+}
+
+sub get_record
+{
+	my ($p, $dev, $inode) = @_;
+
+	unless (defined($files{$dev}{$inode})) {
+	    $files{$dev}{$inode} = {};
+	}
+	$f = $files{$dev}{$inode};
+	unless (defined($records{$p}{$f})) {
+	    $records{$p}{$f} =
+	      {inode => $inode, dev => $dev, added => {},
+	       cached => 0, removed => 0, indirect_removed => 0};
+	}
+	return $f, $records{$p}{$f};
+}
+
+sub minor
+{
+	my $dev = shift;
+	return $dev & ((1 << 20) - 1);
+}
+
+sub major
+{
+	my $dev = shift;
+	return $dev >> 20;
+}
+
+sub print_pagecache_usage_per_file
+{
+	print "[file list]\n";
+	printf("  %12s %10s %8s\n", "device", "", "cached");
+	printf("  %12s %10s %8s\n", "(maj:min)", "inode", "pages");
+	printf("  %s\n", '-' x 32);
+	while(my($dev, $file) = each(%files)) {
+	    foreach my $inode (sort { $a <=> $b } keys %$file) {
+		my $count = values %{$$file{$inode}};
+		next if $count == 0;
+		printf("  %12s %10d %8d\n",
+		       major($dev).":".minor($dev), $inode, $count);
+	    }
+	}
+}
+
+sub print_pagecache_usage_per_process
+{
+	print "[process list]\n";
+	while(my ($pid, $v) = each(%records)) {
+	    my ($sum_cached, $sum_added, $sum_removed, $sum_indirect_removed);
+	    print "o $pid\n";
+	    printf("  %12s %10s %8s %8s %8s %13s\n", "device", "",
+		   "cached", "added", "removed", "indirect");
+	    printf("  %12s %10s %8s %8s %8s %13s\n", "(maj:min)", "inode",
+		   "pages", "pages", "pages", "removed pages");
+	    printf("  %s\n", '-' x 64);
+	    foreach my $r (sort { $$a{inode} <=> $$b{inode} } values %$v) {
+		my $added_num = scalar(keys %{$$r{added}}) == 0 ?
+		    0 : List::Util::sum(values %{$$r{added}});
+		$sum_cached += $$r{cached};
+		$sum_added += $added_num;
+		$sum_removed += $$r{removed};
+		$sum_indirect_removed += $$r{indirect_removed};
+		printf("  %12s %10d %8d %8d %8d %13d\n",
+		       major($$r{dev}).":".minor($$r{dev}), $$r{inode},
+		       $$r{cached}, $added_num, $$r{removed},
+		       $$r{indirect_removed});
+	    }
+	    printf("  %s\n", '-' x 64);
+	    printf("  total: %5s %10s %8d %8d %8d %13d\n", "", "", $sum_cached,
+		   $sum_added, $sum_removed, $sum_indirect_removed);
+	    print "\n";
+	}
+}
Index: linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-hit-ratio-record
===================================================================
--- /dev/null
+++ linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-hit-ratio-record
@@ -0,0 +1,7 @@
+#!/bin/bash
+perf record -c 1 -f -a -M -R -e filemap:find_get_page
+
+
+
+
+
Index: linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-hit-ratio-report
===================================================================
--- /dev/null
+++ linux-2.6-tip/tools/perf/scripts/perl/bin/pagecache-hit-ratio-report
@@ -0,0 +1,6 @@
+#!/bin/bash
+# description: monitor pagecache hit ratio per process
+perf trace -s ~/libexec/perf-core/scripts/perl/pagecache-hit-ratio.pl
+
+
+
Index: linux-2.6-tip/tools/perf/scripts/perl/pagecache-hit-ratio.pl
===================================================================
--- /dev/null
+++ linux-2.6-tip/tools/perf/scripts/perl/pagecache-hit-ratio.pl
@@ -0,0 +1,75 @@
+#!/usr/bin/perl -w
+# (C) 2010, Keiichi Kii <k-keiichi@bx.jp.nec.com>
+# Licensed under the terms of the GNU GPL License version 2
+
+# Display pagecache hit ratio per process
+
+use lib "$ENV{'PERF_EXEC_PATH'}/scripts/perl/Perf-Trace-Util/lib";
+use lib "./Perf-Trace-Util/lib";
+use Perf::Trace::Core;
+use Perf::Trace::Context;
+use Perf::Trace::Util;
+
+my %records;
+
+sub trace_end
+{
+	print_pagecache_hit_ratio();
+}
+
+sub filemap::find_get_page
+{
+	my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
+	    $common_pid, $common_comm,
+	    $s_dev, $i_ino, $offset, $page) = @_;
+	my $r = get_record($common_comm."-".$common_pid, $s_dev, $i_ino);
+
+	if ($page != 0) {
+	    $$r{hit}++;
+	} else {
+	    $$r{miss}++;
+	}
+}
+
+sub get_record
+{
+	my ($p, $dev, $inode) = @_;
+
+	unless (defined($records{$p}{$dev.":".$inode})) {
+	    $records{$p}{$dev.":".$inode} = {inode => $inode, dev => $dev,
+					    hit => 0, miss => 0};
+	}
+	return $records{$p}{$dev.":".$inode};
+}
+
+sub minor
+{
+	my $dev = shift;
+	return $dev & ((1 << 20) - 1);
+}
+
+sub major
+{
+	my $dev = shift;
+	return $dev >> 20;
+}
+
+sub print_pagecache_hit_ratio
+{
+	print "[process list]\n";
+	while(my ($pid, $v) = each(%records)) {
+	    print "o $pid\n";
+	    printf("  %12s %10s %10s %10s %10s\n", "", "",
+		   "cache find", "cache hit", "cache hit");
+	    printf("  %12s %10s %10s %10s %10s\n", "device", "inode",
+		   "count", "count", "ratio");
+	    printf("  %s\n", '-' x 56);
+	    foreach my $r (sort { $$a{inode} <=> $$b{inode} } values %$v) {
+		printf("  %12s %10d %10d %10d %9.2f%%\n",
+		       major($$r{dev}).":".minor($$r{dev}), $$r{inode},
+		       $$r{miss} + $$r{hit}, $$r{hit},
+		       $$r{hit} / ($$r{miss} + $$r{hit}) * 100);
+	    }
+	    print "\n";
+	}
+}




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
