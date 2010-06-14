Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C89AE6B01D0
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 07:18:05 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 04/12] tracing, vmscan: Add a postprocessing script for reclaim-related ftrace events
Date: Mon, 14 Jun 2010 12:17:45 +0100
Message-Id: <1276514273-27693-5-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This patch adds a simple post-processing script for the reclaim-related
trace events.  It can be used to give an indication of how much traffic
there is on the LRU lists and how severe latencies due to reclaim are.
Example output looks like the following

Reclaim latencies expressed as order-latency_in_ms
uname-3942             9-200.179000000004 9-98.7900000000373 9-99.8330000001006
kswapd0-311            0-662.097999999998 0-2.79700000002049 \
	0-149.100000000035 0-3295.73600000003 0-9806.31799999997 0-35528.833 \
	0-10043.197 0-129740.979 0-3.50500000000466 0-3.54899999999907 \
	0-9297.78999999992 0-3.48499999998603 0-3596.97999999998 0-3.92799999995623 \
	0-3.35000000009313 0-16729.017 0-3.57799999997951 0-47435.0630000001 \
	0-3.7819999998901 0-5864.06999999995 0-18635.334 0-10541.289 9-186011.565 \
	9-3680.86300000001 9-1379.06499999994 9-958571.115 9-66215.474 \
	9-6721.14699999988 9-1962.15299999993 9-1094806.125 9-2267.83199999994 \
	9-47120.9029999999 9-427653.886 9-2.6359999999404 9-632.148999999976 \
	9-476.753000000026 9-495.577000000048 9-8.45900000003166 9-6.6820000000298 \
	9-1.30500000016764 9-251.746000000043 9-383.905000000028 9-80.1419999999925 \
	9-281.160000000149 9-14.8780000000261 9-381.45299999998 9-512.07799999998 \
	9-49.5519999999087 9-167.439000000013 9-183.820999999996 9-239.527999999933 \
	9-19.9479999998584 9-148.747999999905 9-164.583000000101 9-16.9480000000913 \
	9-192.376000000164 9-64.1010000000242 9-1.40800000005402 9-3.60800000000745 \
	9-17.1359999999404 9-4.69500000006519 9-2.06400000001304 9-1582488.554 \
	9-6244.19499999983 9-348153.812 9-2.0999999998603 9-0.987999999895692 \
	0-32218.473 0-1.6140000000596 0-1.28100000019185 0-1.41300000017509 \
	0-1.32299999985844 0-602.584000000032 0-1.34400000004098 0-1.6929999999702 \
	1-22101.8190000001 9-174876.724 9-16.2420000000857 9-175.165999999736 \
	9-15.8589999997057 9-0.604999999981374 9-3061.09000000032 9-479.277000000235 \
	9-1.54499999992549 9-771.985000000335 9-4.88700000010431 9-15.0649999999441 \
	9-0.879999999888241 9-252.01500000013 9-1381.03600000031 9-545.689999999944 \
	9-3438.0129999998 9-3343.70099999988
bench-stresshig-3942   9-7063.33900000004 9-129960.482 9-2062.27500000002 \
	9-3845.59399999992 9-171.82799999998 9-16493.821 9-7615.23900000006 \
	9-10217.848 9-983.138000000035 9-2698.39999999991 9-4016.1540000001 \
	9-5522.37700000009 9-21630.429 \
	9-15061.048 9-10327.953 9-542.69700000016 9-317.652000000002 \
	9-8554.71699999995 9-1786.61599999992 9-1899.31499999994 9-2093.41899999999 \
	9-4992.62400000007 9-942.648999999976 9-1923.98300000001 9-3.7980000001844 \
	9-5.99899999983609 9-0.912000000011176 9-1603.67700000014 9-1.98300000000745 \
	9-3.96500000008382 9-0.902999999932945 9-2802.72199999983 9-1078.24799999991 \
	9-2155.82900000014 9-10.058999999892 9-1984.723 9-1687.97999999998 \
	9-1136.05300000007 9-3183.61699999985 9-458.731000000145 9-6.48600000003353 \
	9-1013.25200000009 9-8415.22799999989 9-10065.584 9-2076.79600000009 \
	9-3792.65699999989 9-71.2010000001173 9-2560.96999999997 9-2260.68400000012 \
	9-2862.65799999982 9-1255.81500000018 9-15.7440000001807 9-4.33499999996275 \
	9-1446.63800000004 9-238.635000000009 9-60.1790000000037 9-4.38800000003539 \
	9-639.567000000039 9-306.698000000091 9-31.4070000001229 9-74.997999999905 \
	9-632.725999999791 9-1625.93200000003 9-931.266000000061 9-98.7749999999069 \
	9-984.606999999844 9-225.638999999966 9-421.316000000108 9-653.744999999879 \
	9-572.804000000004 9-769.158999999985 9-603.918000000063 9-4.28499999991618 \
	9-626.21399999992 9-1721.25 9-0.854999999981374 9-572.39599999995 \
	9-681.881999999983 9-1345.12599999993 9-363.666999999899 9-3823.31099999999 \
	9-2991.28200000012 9-4.27099999994971 9-309.76500000013 9-3068.35700000008 \
	9-788.25 9-3515.73999999999 9-2065.96100000013 9-286.719999999972 \
	9-316.076000000117 9-344.151000000071 9-2.51000000000931 9-306.688000000082 \
	9-1515.00099999993 9-336.528999999864 9-793.491999999853 9-457.348999999929 \
	9-13620.155 9-119.933999999892 9-35.0670000000391 9-918.266999999993 \
	9-828.569000000134 9-4863.81099999999 9-105.222000000067 9-894.23900000006 \
	9-110.964999999851 9-0.662999999942258 9-12753.3150000002 9-12.6129999998957 \
	9-13368.0899999999 9-12.4199999999255 9-1.00300000002608 9-1.41100000008009 \
	9-10300.5290000001 9-16.502000000095 9-30.7949999999255 9-6283.0140000002 \
	9-4320.53799999994 9-6826.27300000004 9-3.07299999985844 9-1497.26799999992 \
	9-13.4040000000969 9-3.12999999988824 9-3.86100000003353 9-11.3539999998175 \
	9-0.10799999977462 9-21.780999999959 9-209.695999999996 9-299.647000000114 \
	9-6.01699999999255 9-20.8349999999627 9-22.5470000000205 9-5470.16800000006 \
	9-7.60499999998137 9-0.821000000229105 9-1.56600000010803 9-14.1669999998994 \
	9-0.209000000031665 9-1.82300000009127 9-1.70000000018626 9-19.9429999999702 \
	9-124.266999999993 9-0.0389999998733401 9-6.71400000015274 9-16.7710000001825 \
	9-31.0409999999683 9-0.516999999992549 9-115.888000000035 9-5.19900000002235 \
	9-222.389999999898 9-11.2739999999758 9-80.9050000000279 9-8.14500000001863 \
	9-4.44599999999627 9-0.218999999808148 9-0.715000000083819 9-0.233000000007451
\
	9-48.2630000000354 9-248.560999999987 9-374.96800000011 9-644.179000000004 \
	9-0.835999999893829 9-79.0060000000522 9-128.447999999858 9-0.692000000039116 \
	9-5.26500000013039 9-128.449000000022 9-2.04799999995157 9-12.0990000001621 \
	9-8.39899999997579 9-10.3860000001732 9-11.9310000000987 9-53.4450000000652 \
	9-0.46999999997206 9-2.96299999998882 9-17.9699999999721 9-0.776000000070781 \
	9-25.2919999998994 9-33.1110000000335 9-0.434000000124797 9-0.641000000061467 \
	9-0.505000000121072 9-1.12800000002608 9-149.222000000067 9-1.17599999997765 \
	9-3247.33100000001 9-10.7439999999478 9-153.523000000045 9-1.38300000014715 \
	9-794.762000000104 9-3.36199999996461 9-128.765999999829 9-181.543999999994 \
	9-78149.8229999999 9-176.496999999974 9-89.9940000001807 9-9.12700000009499 \
	9-250.827000000048 9-0.224999999860302 9-0.388999999966472 9-1.16700000036508 \
	9-32.1740000001155 9-12.6800000001676 9-0.0720000001601875 9-0.274999999906868
\
	9-0.724000000394881 9-266.866000000387 9-45.5709999999963 9-4.54399999976158 \
	9-8.27199999988079 9-4.38099999958649 9-0.512000000104308 9-0.0640000002458692
\
	9-5.20000000018626 9-0.0839999997988343 9-12.816000000108 9-0.503000000026077 \
	9-0.507999999914318 9-6.23999999975786 9-3.35100000025705 9-18.8530000001192 \
	9-25.2220000000671 9-68.2309999996796 9-98.9939999999478 9-0.441000000108033 \
	9-4.24599999981001 9-261.702000000048 9-3.01599999982864 9-0.0749999997206032 \
	9-0.0370000000111759 9-4.375 9-3.21800000034273 9-11.3960000001825 \
	9-0.0540000000037253 9-0.286000000312924 9-0.865999999921769 \
	9-0.294999999925494 9-6.45999999996275 9-4.31099999975413 9-128.248999999836 \
	9-0.282999999821186 9-102.155000000261 9-0.0860000001266599 \
	9-0.0540000000037253 9-0.935000000055879 9-0.0670000002719462 \
	9-5.8640000000596 9-19.9860000000335 9-4.18699999991804 9-0.566000000108033 \
	9-2.55099999997765 9-0.702000000048429 9-131.653999999631 9-0.638999999966472 \
	9-14.3229999998584 9-183.398000000045 9-178.095999999903 9-3.22899999981746 \
	9-7.31399999978021 9-22.2400000002235 9-11.7979999999516 9-108.10599999968 \
	9-99.0159999998286 9-102.640999999829 9-38.414000000339
Process                  Direct     Wokeup      Pages      Pages    Pages
details                   Rclms     Kswapd    Scanned    Sync-IO ASync-IO
cc1-30800                     0          1          0          0        0      wakeup-0=1
cc1-24260                     0          1          0          0        0      wakeup-0=1
cc1-24152                     0         12          0          0        0      wakeup-0=12
cc1-8139                      0          1          0          0        0      wakeup-0=1
cc1-4390                      0          1          0          0        0      wakeup-0=1
cc1-4648                      0          7          0          0        0      wakeup-0=7
cc1-4552                      0          3          0          0        0      wakeup-0=3
dd-4550                       0         31          0          0        0      wakeup-0=31
date-4898                     0          1          0          0        0      wakeup-0=1
cc1-6549                      0          7          0          0        0      wakeup-0=7
as-22202                      0         17          0          0        0      wakeup-0=17
cc1-6495                      0          9          0          0        0      wakeup-0=9
cc1-8299                      0          1          0          0        0      wakeup-0=1
cc1-6009                      0          1          0          0        0      wakeup-0=1
cc1-2574                      0          2          0          0        0      wakeup-0=2
cc1-30568                     0          1          0          0        0      wakeup-0=1
cc1-2679                      0          6          0          0        0      wakeup-0=6
sh-13747                      0         12          0          0        0      wakeup-0=12
cc1-22193                     0         18          0          0        0      wakeup-0=18
cc1-30725                     0          2          0          0        0      wakeup-0=2
as-4392                       0          2          0          0        0      wakeup-0=2
cc1-28180                     0         14          0          0        0      wakeup-0=14
cc1-13697                     0          2          0          0        0      wakeup-0=2
cc1-22207                     0          8          0          0        0      wakeup-0=8
cc1-15270                     0        179          0          0        0      wakeup-0=179
cc1-22011                     0         82          0          0        0      wakeup-0=82
cp-14682                      0          1          0          0        0      wakeup-0=1
as-11926                      0          2          0          0        0      wakeup-0=2
cc1-6016                      0          5          0          0        0      wakeup-0=5
make-18554                    0         13          0          0        0      wakeup-0=13
cc1-8292                      0         12          0          0        0      wakeup-0=12
make-24381                    0          1          0          0        0      wakeup-1=1
date-18681                    0         33          0          0        0      wakeup-0=33
cc1-32276                     0          1          0          0        0      wakeup-0=1
timestamp-outpu-2809          0        253          0          0        0      wakeup-0=240 wakeup-1=13
date-18624                    0          7          0          0        0      wakeup-0=7
cc1-30960                     0          9          0          0        0      wakeup-0=9
cc1-4014                      0          1          0          0        0      wakeup-0=1
cc1-30706                     0         22          0          0        0      wakeup-0=22
uname-3942                    4          1        306          0       17      direct-9=4       wakeup-9=1
cc1-28207                     0          1          0          0        0      wakeup-0=1
cc1-30563                     0          9          0          0        0      wakeup-0=9
cc1-22214                     0         10          0          0        0      wakeup-0=10
cc1-28221                     0         11          0          0        0      wakeup-0=11
cc1-28123                     0          6          0          0        0      wakeup-0=6
kswapd0-311                   0          7     357302          0    34233      wakeup-0=7
cc1-5988                      0          7          0          0        0      wakeup-0=7
as-30734                      0        161          0          0        0      wakeup-0=161
cc1-22004                     0         45          0          0        0      wakeup-0=45
date-4590                     0          4          0          0        0      wakeup-0=4
cc1-15279                     0        213          0          0        0      wakeup-0=213
date-30735                    0          1          0          0        0      wakeup-0=1
cc1-30583                     0          4          0          0        0      wakeup-0=4
cc1-32324                     0          2          0          0        0      wakeup-0=2
cc1-23933                     0          3          0          0        0      wakeup-0=3
cc1-22001                     0         36          0          0        0      wakeup-0=36
bench-stresshig-3942        287        287      80186       6295    12196      direct-9=287       wakeup-9=287
cc1-28170                     0          7          0          0        0      wakeup-0=7
date-7932                     0         92          0          0        0      wakeup-0=92
cc1-22222                     0          6          0          0        0      wakeup-0=6
cc1-32334                     0         16          0          0        0      wakeup-0=16
cc1-2690                      0          6          0          0        0      wakeup-0=6
cc1-30733                     0          9          0          0        0      wakeup-0=9
cc1-32298                     0          2          0          0        0      wakeup-0=2
cc1-13743                     0         18          0          0        0      wakeup-0=18
cc1-22186                     0          4          0          0        0      wakeup-0=4
cc1-28214                     0         11          0          0        0      wakeup-0=11
cc1-13735                     0          1          0          0        0      wakeup-0=1
updatedb-8173                 0         18          0          0        0      wakeup-0=18
cc1-13750                     0          3          0          0        0      wakeup-0=3
cat-2808                      0          2          0          0        0      wakeup-0=2
cc1-15277                     0        169          0          0        0      wakeup-0=169
date-18317                    0          1          0          0        0      wakeup-0=1
cc1-15274                     0        197          0          0        0      wakeup-0=197
cc1-30732                     0          1          0          0        0      wakeup-0=1

Kswapd                   Kswapd      Order      Pages      Pages    Pages
Instance                Wakeups  Re-wakeup    Scanned    Sync-IO ASync-IO
kswapd0-311                  91         24     357302          0    34233      wake-0=31 wake-1=1 wake-9=59       rewake-0=10 rewake-1=1 rewake-9=13

Summary
Direct reclaims:     		291
Direct reclaim pages scanned:	437794
Direct reclaim write sync I/O:	6295
Direct reclaim write async I/O:	46446
Wake kswapd requests:		2152
Time stalled direct reclaim: 	519.163009000002 ms

Kswapd wakeups:			91
Kswapd pages scanned:		357302
Kswapd reclaim write sync I/O:	0
Kswapd reclaim write async I/O:	34233
Time kswapd awake:		5282.749757 ms

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 .../trace/postprocess/trace-vmscan-postprocess.pl  |  654 ++++++++++++++++++++
 1 files changed, 654 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/trace/postprocess/trace-vmscan-postprocess.pl

diff --git a/Documentation/trace/postprocess/trace-vmscan-postprocess.pl b/Documentation/trace/postprocess/trace-vmscan-postprocess.pl
new file mode 100644
index 0000000..b48d968
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
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
