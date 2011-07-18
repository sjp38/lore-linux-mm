Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CC5979000C2
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 17:37:31 -0400 (EDT)
Message-ID: <4E24A761.7040504@bx.jp.nec.com>
Date: Mon, 18 Jul 2011 17:36:33 -0400
From: Keiichi KII <k-keiichi@bx.jp.nec.com>
MIME-Version: 1.0
Subject: [RFC PATCH -tip 3/5] perf tools: scripts for pagecache snapshooting
References: <4E24A61D.4060702@bx.jp.nec.com>
In-Reply-To: <4E24A61D.4060702@bx.jp.nec.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: Keiichi KII <k-keiichi@bx.jp.nec.com>, Ingo Molnar <mingo@elte.hu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Fr??d??ric Weisbecker <fweisbec@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, "BA, Moussa" <Moussa.BA@numonyx.com>

From: Keiichi Kii <k-keiichi@bx.jp.nec.com>

The "pagecache snapshooting" is implemented based on "pagecache object
collections" and the trace stream scripting support in perf tools.

To take pagecache snapshoots,
we can run "perf script pagecache-snapshoot <path of fs> <interval>
ex) perf script pagecache-snapshoot / 600
    => keep taking a snapshoot for "/" filesystem every 10 minutes.

The output consists of 2 parts. The following shows sample outputs.

o One part is to show pagecache usage in a system at a point.

pangecache snapshooting (time: 18501, path: /)
                             file name cache(B)  file(B)  ratio  ±(B)    age
-------------------------------------- -------- -------- ------ ------- ------
/var/lib/rpm/Packages                     68.5M    70.0M    97%   60.1M     12
/usr/lib64/thunderbird-3.1/thunderbird     8.8M    19.4M    45%       0  11899
/usr/bin/emacs-23.2                        4.3M    10.3M    41%       0  17192
/usr/share/anthy/anthy.dic                 3.0M    20.0M    14%       0  18402
/usr/lib64/libgtk-x11-2.0.so.0.2200.0      2.8M     4.5M    63%       0  18485
/usr/lib/locale/locale-archive             1.8M    94.6M     1%       0  18496
/usr/lib64/libpython2.7.so.1.0             1.5M     1.8M    87%       0  18417
/usr/bin/Xorg                              1.3M     1.9M    71%       0  18471
/usr/share/fonts/sazanami/mincho/sazan     1.3M    10.1M    12%       0   8634
/var/lib/rpm/__db.003                      1.3M     1.3M   100%       0     12
/usr/lib64/perl5/CORE/libperl.so           1.2M     1.5M    82%       0  13415
/lib64/libc-2.13.so                        1.2M     1.9M    64%       0  18497
/lib64/libdb-4.8.so                        1.2M     1.5M    79%       0  18474
/usr/bin/nautilus                       1008.0K     1.9M    53%       0  18418
/usr/lib64/libnss3.so                    992.0K     1.2M    78%       0  18491
/lib64/libcrypto.so.1.0.0d               948.0K     1.6M    58%       0  18477
/var/cache/hald/fdi-cache                880.0K   997.5K    88%       0  18479

o the other is to show statistics for pagecache changes between snapshoots
  after finishing taking snapshoots.

[stat]
o pagecache max
  1:    69.5MB /var/lib/rpm/Packages
  2:    37.6MB /var/cache/yum/x86_64/14/fedora/19091941
  3:    28.1MB /var/cache/yum/x86_64/14/updates/2d3f230
  4:     8.8MB /usr/lib64/thunderbird-3.1/thunderbird-b
  5:     7.1MB /var/cache/yum/x86_64/14/fedora-debuginf
  6:     6.8MB /var/cache/yum/x86_64/14/updates/updatei
  7:     4.3MB /usr/bin/emacs-23.2
  8:     3.0MB /usr/share/anthy/anthy.dic
  9:     2.8MB /usr/lib64/libgtk-x11-2.0.so.0.2200.0
 10:     2.6MB /var/cache/yum/x86_64/14/updates-debugin

o pagecache average
  1:    24.4MB/   69.5MB(  35%) /var/lib/rpm/Packages
  2:     8.8MB/    8.8MB( 100%) /usr/lib64/thunderbird-3.1/thunderbird-b
  3:     6.3MB/   37.6MB(  16%) /var/cache/yum/x86_64/14/fedora/19091941
  4:     4.7MB/   28.1MB(  16%) /var/cache/yum/x86_64/14/updates/2d3f230
  5:     4.3MB/    4.3MB( 100%) /usr/bin/emacs-23.2
  6:     3.0MB/    3.0MB( 100%) /usr/share/anthy/anthy.dic
  7:     2.8MB/    2.8MB( 100%) /usr/lib64/libgtk-x11-2.0.so.0.2200.0
  8:     1.8MB/    1.8MB( 100%) /usr/lib/locale/locale-archive
  9:     1.4MB/    1.5MB(  87%) /usr/lib64/libpython2.7.so.1.0
 10:     1.3MB/    1.3MB( 100%) /usr/bin/Xorg

o increased pagecache total
  1:    69.5MB/   69.5MB( 100%) /var/lib/rpm/Packages
  2:    37.6MB/   37.6MB( 100%) /var/cache/yum/x86_64/14/fedora/19091941
  3:    28.1MB/   28.1MB( 100%) /var/cache/yum/x86_64/14/updates/2d3f230
  4:     7.1MB/    7.1MB( 100%) /var/cache/yum/x86_64/14/fedora-debuginf
  5:     6.8MB/    6.8MB( 100%) /var/cache/yum/x86_64/14/updates/updatei
  6:     2.6MB/    2.6MB( 100%) /var/cache/yum/x86_64/14/updates-debugin
  7:     1.5MB/    1.5MB( 100%) /var/cache/yum/x86_64/14/rpmfusion-free/
  8:     1.4MB/    1.4MB( 100%) /var/cache/yum/x86_64/14/rpmfusion-free-
  9:     1.3MB/    1.3MB( 100%) /var/lib/rpm/__db.003
 10:   808.0KB/    1.2MB(  66%) /lib64/libdb-4.8.so

o decreased pagecache total
  1:    69.5MB/   69.5MB( 100%) /var/lib/rpm/Packages
  2:    37.6MB/   37.6MB( 100%) /var/cache/yum/x86_64/14/fedora/19091941
  3:    28.1MB/   28.1MB( 100%) /var/cache/yum/x86_64/14/updates/2d3f230
  4:     7.1MB/    7.1MB( 100%) /var/cache/yum/x86_64/14/fedora-debuginf
  5:     6.8MB/    6.8MB( 100%) /var/cache/yum/x86_64/14/updates/updatei
  6:     2.6MB/    2.6MB( 100%) /var/cache/yum/x86_64/14/updates-debugin
  7:     1.5MB/    1.5MB( 100%) /var/cache/yum/x86_64/14/rpmfusion-free/
  8:     1.4MB/    1.4MB( 100%) /var/cache/yum/x86_64/14/rpmfusion-free-
  9:     1.3MB/    1.3MB( 100%) /var/lib/rpm/__db.003
 10:   808.0KB/    1.2MB(  66%) /lib64/libdb-4.8.so

Signed-off-by: Keiichi Kii <k-keiichi@bx.jp.nec.com>
---

 .../scripts/perl/bin/pagecache-snapshoot-record    |    3 
 .../scripts/perl/bin/pagecache-snapshoot-report    |   34 ++++
 tools/perf/scripts/perl/pagecache-snapshoot.pl     |  188 ++++++++++++++++++++
 3 files changed, 225 insertions(+), 0 deletions(-)
 create mode 100644 tools/perf/scripts/perl/bin/pagecache-snapshoot-record
 create mode 100644 tools/perf/scripts/perl/bin/pagecache-snapshoot-report
 create mode 100644 tools/perf/scripts/perl/pagecache-snapshoot.pl


diff --git a/tools/perf/scripts/perl/bin/pagecache-snapshoot-record b/tools/perf/scripts/perl/bin/pagecache-snapshoot-record
new file mode 100644
index 0000000..7ece9c9
--- /dev/null
+++ b/tools/perf/scripts/perl/bin/pagecache-snapshoot-record
@@ -0,0 +1,3 @@
+#!/bin/bash
+
+perf record -D -e mm:dump_inode --filter "nrpages>20" -e mm:dump_header $@
diff --git a/tools/perf/scripts/perl/bin/pagecache-snapshoot-report b/tools/perf/scripts/perl/bin/pagecache-snapshoot-report
new file mode 100644
index 0000000..228c9d2
--- /dev/null
+++ b/tools/perf/scripts/perl/bin/pagecache-snapshoot-report
@@ -0,0 +1,34 @@
+#!/bin/bash
+# description: snapshoot pagecache usage
+# args: <path> <interval>
+
+function find_debugfs_path {
+  echo `cat /proc/mounts | grep debugfs | awk 'NR == 1 {print $2}'`
+}
+
+for i in "$@"
+do
+    if expr match "$i" "-" > /dev/null; then
+        break
+    fi
+    n_args=$(( $n_args + 1 ))
+done
+
+if [ "$n_args" -eq 2 ]; then
+    path=$1
+    interval=$2
+    shift 2
+else
+    echo "usage: pagecache-snapshoot <path> <interval>"
+    exit
+fi
+
+CUR_PID=$$
+while true;
+do
+  test `ps -e | grep $CUR_PID | wc -l` = 0 && break;
+  echo $path > `find_debugfs_path`/tracing/objects/mm/pages/walk-fs
+  sleep $interval
+done&
+
+perf script $@ -s "$PERF_EXEC_PATH"/scripts/perl/pagecache-snapshoot.pl
diff --git a/tools/perf/scripts/perl/pagecache-snapshoot.pl b/tools/perf/scripts/perl/pagecache-snapshoot.pl
new file mode 100644
index 0000000..f87f3fc
--- /dev/null
+++ b/tools/perf/scripts/perl/pagecache-snapshoot.pl
@@ -0,0 +1,188 @@
+#!/usr/bin/perl -w
+# (C) 2011, Keiichi Kii <k-keiichi@bx.jp.nec.com>
+# Licensed under the terms of the GNU GPL License version 2
+
+# Take pagecache snapshoot in system.
+
+use lib "$ENV{'PERF_EXEC_PATH'}/scripts/perl/Perf-Trace-Util/lib";
+use lib "./Perf-Trace-Util/lib";
+use Perf::Trace::Core;
+use Perf::Trace::Context;
+use Perf::Trace::Util;
+use File::Basename qw/basename/;
+use threads;
+use Getopt::Std;
+
+my $interval;
+my $cur_mode = $ARGV[0];
+my $cur_record;
+my $limit = 17;
+my @records;
+my @stats;
+
+sub trace_end {
+    clear_term();
+    analyze();
+    print_stats();
+}
+
+sub mm::dump_header
+{
+    my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
+        $common_pid, $common_comm,
+        $object_name, $input_data) = @_;
+
+    clear_term();
+    print_files($cur_record);
+    switch_record($input_data, $common_secs);
+}
+
+sub switch_record() {
+    my ($path, $time) = @_;
+    my %new_record = ();
+
+    $$cur_record{complete} = 1;
+    $new_record{path} = $path;
+    $new_record{time} = $time;
+    $new_record{files} = ();
+    $new_record{complete} = 0;
+
+    if (@records > 0) {
+        foreach my $f (keys %{$$cur_record{files}}) {
+            if ($$cur_record{files}{$f}{pages} == 0) {
+                $new_record{files}{$f} = {cached => 0, pages => 0};
+            } else {
+                %{$new_record{files}{$f}} = %{$$cur_record{files}{$f}};
+                $new_record{files}{$f}{cached} = 1;
+                $new_record{files}{$f}{pages} = 0;
+                $new_record{files}{$f}{change} =
+                    -$$cur_record{files}{$f}{pages};
+            }
+        }
+    }
+    $cur_record = \%new_record;
+    push(@records, \%new_record);
+}
+
+sub mm::dump_inode
+{
+    my ($event_name, $context, $common_cpu, $common_secs, $common_nsecs,
+        $common_pid, $common_comm,
+        $ino, $size, $nrpages, $age, 
+        $state, $dev, $file) = @_;
+
+    if ($file =~ /$$cur_record{path}/ and $nrpages != 0) {
+        if (defined($$cur_record{files}{$dev.":".$ino})) {
+            $$cur_record{files}{$dev.":".$ino}{path} = $file;
+            $$cur_record{files}{$dev.":".$ino}{size} = $size;
+            $$cur_record{files}{$dev.":".$ino}{pages} = $nrpages;
+            $$cur_record{files}{$dev.":".$ino}{change} += $nrpages;
+            $$cur_record{files}{$dev.":".$ino}{cached} = 1;
+            $$cur_record{files}{$dev.":".$ino}{age} = $age;
+        } else {
+            $$cur_record{files}{$dev.":".$ino} =
+                {cached => 1, path => $file, size => $size, pages => $nrpages,
+                 change => (@records == 1) ? 0 : $nrpages, age => $age};
+        }
+    }
+}
+
+sub print_files() {
+    my $record = shift;
+    my $i = 0;
+    my $file_name ="";
+
+    printf("pagecache snapshooting (time: %d, path: %s)\n",
+        $$record{time}, $$record{path});
+    printf("%38s %8s %8s %6s %7s %6s\n",
+           "file name", "cache(B)", "file(B)", "ratio", "+/-(B)", "age");
+    printf("%38s %8s %8s %6s %7s %6s\n",
+           '-'x38, '-'x8, '-'x8, '-'x6, '-'x7, '-'x6);
+    foreach my $f (sort {$$b{pages} <=> $$a{pages}} values %{$$record{files}}) {
+        next if $$f{cached} == 0;
+        $i++;
+        printf("%-38s %8s %8s %5d%% %7s %6d\n", get_file_name($$f{path}, 38),
+               convert_unit($$f{pages} * 4096), convert_unit($$f{size}),
+               ($$f{size} == 0) ? 0 : ($$f{pages} * 4096) / $$f{size} * 100,
+               convert_unit($$f{change} * 4096),
+               $$f{age} / 1000);
+        last if $i >= $limit;
+    }
+}
+
+sub analyze() {
+    foreach my $key (keys %{$records[$#records]{files}}) {
+        my (@result, $total);
+	my %stat = (max => 0, increase => 0, decrease => 0, average => 0);
+
+        @result = grep $$_{files}{$key}{cached} == 1 &&
+            $$_{complete} == 1, @records;
+        $total = grep $$_{complete} == 1, @records;
+	$stat{max} = 0;
+        foreach my $r (@result) {
+            $stat{path} = $$r{files}{$key}{path};
+            if ($stat{max} < $$r{files}{$key}{pages}) {
+                $stat{max} = $$r{files}{$key}{pages};
+            }
+            $stat{average} += $$r{files}{$key}{pages} / $total;
+            if ($$r{files}{$key}{change} > 0) {
+                $stat{increase} += $$r{files}{$key}{change};
+            } else {
+                $stat{decrease} += -$$r{files}{$key}{change};
+            }
+        }
+        $stats{files}{$key} = \%stat;
+    }
+}
+
+sub print_stats() {
+    print "[stat]\n";
+    print "o pagecache max\n";
+    print_stats_elem("max", 10);
+    print "o pagecache average\n";
+    print_stats_elem("average", 10);
+    print "o increased pagecache total\n";
+    print_stats_elem("increase", 10);
+    print "o decreased pagecache total\n";
+    print_stats_elem("decrease", 10);
+}
+
+sub print_stats_elem() {
+    my ($type, $num) = @_;
+    my $i = 1;
+
+    foreach my $s (sort {$$b{$type} <=> $$a{$type}} values %{$stats{files}}) {
+        next if $$s{$type} == 0;
+        if ($type eq "max") {
+            printf("%3d: %8sB %-40s\n", $i, convert_unit($$s{$type} * 4096),
+                   get_file_name($$s{path}, 40));
+        } else {
+            printf("%3d: %8sB/%8sB(%4d%%) %-40s\n", $i,
+                   convert_unit($$s{$type} * 4096),
+                   convert_unit($$s{max} * 4096),
+                   $$s{$type} / $$s{max} * 100, get_file_name($$s{path}, 40));
+        }
+        $i++;
+        last if $i > $num;
+    }
+    print "\n";
+}
+
+@unit = ("K", "M", "G", "T");
+sub convert_unit() {
+    my $size = shift;
+
+    for (my $i=$#unit; $i >= 0; $i--) {
+        if (abs($size) >= 1024 ** ($i+1)) {
+            return sprintf("%.1f%s", $size/1024 ** ($i+1) , $unit[$i]);
+        }
+    }
+    return $size
+}
+
+
+sub get_file_name() {
+    my ($f, $length) = @_;
+
+    return substr($f, 0, $length);
+}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
