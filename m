Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 13E946B010D
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 17:40:50 -0400 (EDT)
Message-ID: <4E24A833.2090208@bx.jp.nec.com>
Date: Mon, 18 Jul 2011 17:40:03 -0400
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: [RFC PATCH -tip 5/5] perf tools: scripts for continuous pagecache
 monitoring
References: <4E24A61D.4060702@bx.jp.nec.com>
In-Reply-To: <4E24A61D.4060702@bx.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Keiichi KII <k-keiichi@bx.jp.nec.com>, Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Fr??d??ric Weisbecker <fweisbec@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "BA, Moussa" <Moussa.BA@numonyx.com>

From: Keiichi Kii <k-keiichi@bx.jp.nec.com>

The "continuous pagecache monitoring" is implemented based on
"pagecache tracepoints" and the trace stream scripting support
in perf tools.

To monitor dynamic changes for pagecaches,
we can run "perf script pagecachetop {file|process}".
ex) perf script pagecachetop file
    => monitor pagecache behavior on the basis of file

This tool shows two types of the output.

o One is to show pagecache behavior on the basis of "file"

pagecache behavior per file (time:20207, interval:10)

                         find        hit    cache      add   remove  proc
                file    count      ratio pages(B) pages(B) pages(B) count
-------------------- -------- ---------- -------- -------- -------- -----
            Packages    32813    100.00%    69.5M        0        0     1
190919419ab3582cb090    30677    100.00%    37.6M        0        0     1
2d3f2307106003b599d2    10715    100.00%    17.0M        0        0     1
29fe4f91d89bab54d355     5545    100.00%     7.1M        0        0     1
c5ee54fd83797583e6c2     1823    100.00%     2.6M        0        0     1
        libc-2.13.so      830    100.00%     1.2M        0        0     9
            __db.003      540    100.00%     1.3M        0        0     1
8faff879329920b2638a      439    100.00%     1.4M        0        0     1
1b695937ce00a8c305ee      352    100.00%     1.5M        0        0     1
 libpython2.7.so.1.0      330    100.00%     1.5M        0        0     1
                bash      283    100.00%   828.0K        0        0     6
         ld.so.cache      227    100.00%   116.0K        0        0     5
        .zsh_history      196    100.00%   772.0K        0        0     1
fdc15d6feaec65abbfae      196    100.00%   464.0K        0        0     1
3b316befdc0469fa84b7      192    100.00%   324.0K        0        0     1

o The other is to show pagecache behaviors on the basis of "process"

pagecache behavior per process (time:20160, interval:10)

                         find        hit      add   remove  file
             process    count      ratio pages(B) pages(B) count
-------------------- -------- ---------- -------- -------- -----
            yum-9006    97210     99.25%    99.9M        0    40
           xmms-7768       43    100.00%   128.0K        0     1
          crond-1307        8    100.00%        0        0     1
       rsyslogd-7194        1    100.00%        0        0     1

Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
---

 tools/perf/scripts/perl/bin/pagecachetop-record |    3 
 tools/perf/scripts/perl/bin/pagecachetop-report |   21 ++
 tools/perf/scripts/perl/pagecachetop.pl         |  292 +++++++++++++++++++++++
 3 files changed, 316 insertions(+), 0 deletions(-)
 create mode 100644 tools/perf/scripts/perl/bin/pagecachetop-record
 create mode 100644 tools/perf/scripts/perl/bin/pagecachetop-report
 create mode 100644 tools/perf/scripts/perl/pagecachetop.pl


diff --git a/tools/perf/scripts/perl/bin/pagecachetop-record b/tools/perf/scripts/perl/bin/pagecachetop-record
new file mode 100644
index 0000000..2c05539
--- /dev/null
+++ b/tools/perf/scripts/perl/bin/pagecachetop-record
@@ -0,0 +1,3 @@
+#!/bin/bash
+
+perf record -D -e filemap:find_get_page -e filemap:add_to_page_cache -e filemap:remove_from_page_cache -e mm:dump_inode --filter "nrpages>10" $@
diff --git a/tools/perf/scripts/perl/bin/pagecachetop-report b/tools/perf/scripts/perl/bin/pagecachetop-report
new file mode 100644
index 0000000..62c54bb
--- /dev/null
+++ b/tools/perf/scripts/perl/bin/pagecachetop-report
@@ -0,0 +1,21 @@
+#!/bin/bash
+# description: continuous pagecache monitoring per file
+
+for i in "$@"
+do
+    if expr match "$i" "-" > /dev/null; then
+        break
+    fi
+    n_args=$(( $n_args + 1 ))
+done
+
+if [ "$n_args" -eq 1 ] ; then
+    mode=$1
+    shift
+else
+    echo "usage: pagecachetop {file|process}"
+    echo $@
+    exit
+fi
+
+perf script $@ -s "$PERF_EXEC_PATH"/scripts/perl/pagecachetop.pl $mode
diff --git a/tools/perf/scripts/perl/pagecachetop.pl b/tools/perf/scripts/perl/pagecachetop.pl
new file mode 100644
index 0000000..ec77f89
--- /dev/null
+++ b/tools/perf/scripts/perl/pagecachetop.pl
@@ -0,0 +1,292 @@
+#!/usr/bin/perl -w
+# (C) 2011, Keiichi Kii <k-keiichi@bx.jp.nec.com>
+# Licensed under the terms of the GNU GPL License version 2
+
+# pagecache top
+#
+# Periodically display system-wide pagecache activity focusing on
+# process or file. If "process" arg is specified, it displays
+# pagecache behavior per each process. If "file" arg is specified,
+# it displays pagecache behavior per each file.
+
+use 5.010000;
+use strict;
+use warnings;
+
+use lib "$ENV{'PERF_EXEC_PATH'}/scripts/perl/Perf-Trace-Util/lib";
+use lib "./Perf-Trace-Util/lib";
+use Perf::Trace::Core;
+use Perf::Trace::Context;
+use Perf::Trace::Util;
+use File::Basename qw/basename/;
+
+my %files;
+my %processes;
+my $interval = 10;
+my $pre_print_time = 0;
+my $print_limit = 20;
+my $debugfs_mountpoint;
+my $mode = shift;
+
+sub trace_begin {
+    $debugfs_mountpoint = find_debugfs_mntpt();
+}
+
+sub find_debugfs_mntpt() {
+    my $path = "";
+    open my $fh, "<", "/proc/mounts"
+        or die "Can't open /proc/mounts: $!";
+    while (my $l = <$fh>) {
+        if ($l =~ /debugfs/) {
+            $path = (split(/\s/, $l))[1];
+        }
+    }
+    close($fh);
+    return $path;
+}
+
+sub mm::dump_inode {
+    my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
+        $common_pid, $common_comm,
+        $ino, $size, $nrpages, $age, 
+        $state, $dev, $file) = @_;
+
+    my $f = get_file($dev, $ino);
+    return if !$f;
+
+    $$f{path} = $file;
+    $$f{cache} = $nrpages;
+}
+
+sub filemap::remove_from_page_cache {
+    my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
+        $common_pid, $common_comm,
+        $s_dev, $i_ino, $offset) = @_;
+
+    my $s = get_stat($common_pid, $common_comm, $s_dev, $i_ino);
+    return if !$s;
+
+    $$s{remove}++;
+    print_check($common_secs);
+}
+
+sub filemap::add_to_page_cache {
+    my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
+        $common_pid, $common_comm,
+        $s_dev, $i_ino, $offset) = @_;
+
+    my $s = get_stat($common_pid, $common_comm, $s_dev, $i_ino);
+    return if !$s;
+
+    $$s{add}++;
+    print_check($common_secs);
+}
+
+sub filemap::find_get_page {
+    my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
+        $common_pid, $common_comm,
+        $s_dev, $i_ino, $offset, $page) = @_;
+
+    my $s = get_stat($common_pid, $common_comm, $s_dev, $i_ino);
+    return if !$s;
+
+    $$s{find}++;
+    if ($page != 0) {
+        $$s{hit}++;
+    }
+
+    print_check($common_secs);
+}
+
+sub get_file {
+    my ($dev, $inode) = @_;
+
+    return if major($dev) == 0;
+
+    if (!defined($files{$dev.":".$inode})) {
+        $files{$dev.":".$inode} = init_file($dev, $inode);
+    }
+
+    return $files{$dev.":".$inode};
+}
+
+sub get_stat {
+    my ($pid, $cmd, $dev, $inode) = @_;
+    my %stat = (find => 0, hit => 0, add => 0, remove => 0);
+
+    return if major($dev) == 0;
+
+    if (!defined($processes{$pid})) {
+        $processes{$pid} = init_process($pid, $cmd);
+    }
+    if (!defined($files{$dev.":".$inode})) {
+        $files{$dev.":".$inode} = init_file($dev, $inode);
+    }
+    if (!defined($processes{$pid}{file}{$dev.":".$inode})) {
+        $files{$dev.":".$inode}{process}{$pid} = \%stat;
+        $processes{$pid}{file}{$dev.":".$inode} = \%stat;
+        return \%stat;
+    }
+    return $files{$dev.":".$inode}{process}{$pid};
+}
+
+sub init_file() {
+    my ($dev, $inode) = @_;
+    my %f;
+
+    $f{path} = major($dev).":".minor($dev).",".$inode;
+    $f{cache} = 0;
+    $f{stat} = {find => 0, hit => 0, add => 0, remove => 0};
+    $f{process} = {};
+
+    return \%f;
+}
+
+sub init_process() {
+    my ($pid, $cmd) = @_;
+    my %p;
+
+    $p{name} = $cmd."-".$pid;
+    $p{stat} = {find => 0, hit => 0, add => 0, remove => 0};
+    $p{file} = {};
+
+    return \%p;
+}
+
+sub print_check() {
+    my $cur_sec = shift;
+
+    if ($pre_print_time == 0) {
+        $pre_print_time = $cur_sec;
+        return
+    }
+    if ($cur_sec - $pre_print_time > $interval) {
+        dump_fs_pagecache("/");
+        clear_term();
+        if ($mode eq "file") {
+            print_files($cur_sec);
+        } elsif ($mode eq "process") {
+            print_processes($cur_sec);
+        }
+        clear_stats();
+        $pre_print_time = $cur_sec;
+    }
+}
+
+sub clear_stats {
+    foreach my $f (values %files) {
+        $$f{stat} = {find => 0, hit => 0, add => 0, remove => 0};
+        $$f{process} = ();
+    }
+    %processes = ();
+}
+
+sub minor {
+    my $dev = shift;
+    return $dev & ((1 << 20) - 1);
+}
+
+sub major {
+    my $dev = shift;
+    return $dev >> 20;
+}
+
+sub print_files {
+    my $cur_sec = shift;
+    my $i = 0;
+
+    foreach my $f (values %files) {
+        foreach my $s (values %{$$f{process}}) {
+            add_stat($$f{stat}, $s);
+        }
+    }
+
+    printf "pagecache behavior per file (time:%d, interval:%d)\n\n"
+        ,$cur_sec, $interval;
+    printf("%20s %8s %10s %8s %8s %8s %5s\n",
+           "", "find", "hit", "cache", "add", "remove", "proc");
+    printf("%20s %8s %10s %8s %8s %8s %5s\n", "file", "count", "ratio",
+           "pages(B)", "pages(B)", "pages(B)", "count");
+    printf("%20s %8s %10s %8s %8s %8s %5s\n",
+           '-'x20, '-'x8, '-'x10, '-'x8, '-'x8, '-'x8, '-'x5);
+    foreach my $f (sort {$$b{stat}{find} <=> $$a{stat}{find}} values %files) {
+        $i++;
+        my $pcount = scalar(keys(%{$$f{process}}));
+        if ($pcount != 0) {
+            printf("%20s %8s %9.2f%% %8s %8s %8s %5d\n",
+                   substr(basename($$f{path}), 0, 20),
+                   $$f{stat}{find},
+                   ($$f{stat}{find} == 0) ?
+                   0 : $$f{stat}{hit} / $$f{stat}{find} * 100,
+                   ($$f{cache} != 0) ? convert_unit($$f{cache} * 4096): "N/A",
+                   convert_unit($$f{stat}{add} * 4096),
+                   convert_unit($$f{stat}{remove} * 4096),
+                   $pcount);
+        }
+        last if $i >= $print_limit;
+    }
+}
+
+sub print_processes {
+    my $cur_sec = shift;
+    my $i = 0;
+
+    foreach my $p (values %processes) {
+        foreach my $s (values %{$$p{file}}) {
+            add_stat($$p{stat}, $s);
+        }
+    }
+
+    printf "pagecache behavior per process (time:%d, interval:%d)\n\n"
+        ,$cur_sec, $interval;
+    printf("%20s %8s %10s %8s %8s %5s\n",
+           "", "find", "hit", "add", "remove", "file");
+    printf("%20s %8s %10s %8s %8s %5s\n", "process", "count", "ratio",
+           "pages(B)", "pages(B)", "count");
+    printf("%20s %8s %10s %8s %8s %5s\n",
+           '-'x20, '-'x8, '-'x10, '-'x8, '-'x8, '-'x5);
+    foreach my $p (sort {$$b{stat}{find} <=> $$a{stat}{find}} values %processes) {
+        $i++;
+        my $fcount = scalar(keys(%{$$p{file}}));
+        if ($fcount != 0) {
+            printf("%20s %8s %9.2f%% %8s %8s %5d\n",
+                   substr(basename($$p{name}), 0, 20),
+                   $$p{stat}{find},
+                   ($$p{stat}{find} == 0) ?
+                   0 : $$p{stat}{hit} / $$p{stat}{find} * 100,
+                   convert_unit($$p{stat}{add} * 4096),
+                   convert_unit($$p{stat}{remove} * 4096),
+                   $fcount);
+        }
+        last if $i >= $print_limit;
+    }
+}
+
+my @unit = ("K", "M", "G", "T");
+sub convert_unit() {
+    my $size = shift;
+
+     for (my $i=$#unit; $i >= 0; $i--) {
+        if (abs($size) >= 1024 ** ($i+1)) {
+            return sprintf("%.1f%s", $size/1024 ** ($i+1) , $unit[$i]);
+        }
+    }
+    return $size
+}
+
+sub dump_fs_pagecache() {
+    my $path = shift;
+    open my $fh, ">", "$debugfs_mountpoint/tracing/objects/mm/pages/walk-fs"
+        or die "Can't open tracing/objects/mm/pages/walk-fs: $!";
+    print $fh "$path\n";
+    close($fh);
+}
+
+sub add_stat {
+    my ($s1, $s2) = @_;
+
+    $$s1{find} += $$s2{find};
+    $$s1{hit} += $$s2{hit};
+    $$s1{add} += $$s2{add};
+    $$s1{remove} += $$s2{remove};
+}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
