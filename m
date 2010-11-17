From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 00/13] IO-less dirty throttling v2
Date: Wed, 17 Nov 2010 12:27:20 +0800
Message-ID: <20101117042720.033773013@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PIZgJ-0001dP-3M
	for glkm-linux-mm-2@m.gmane.org; Wed, 17 Nov 2010 05:31:39 +0100
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A41A76B0108
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:31:32 -0500 (EST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

Andrew,

This is a revised subset of "[RFC] soft and dynamic dirty throttling limits"
<http://thread.gmane.org/gmane.linux.kernel.mm/52966>.

The basic idea is to introduce a small region under the bdi dirty threshold.
The task will be throttled gently when stepping into the bottom of region,
and get throttled more and more aggressively as bdi dirty+writeback pages
goes up closer to the top of region. At some point the application will be
throttled at the right bandwidth that balances with the device write bandwidth.
(the first patch and documentation has more details)

Changes from initial RFC:

- adaptive rate limiting, to reduce overheads when under throttle threshold
- prevent overrunning dirty limit on lots of concurrent dirtiers
- add Documentation/filesystems/writeback-throttling-design.txt
- lower max pause time from 200ms to 100ms; min pause time from 10ms to 1jiffy
- don't drop the laptop mode code
- update and comment the trace event
- benchmarks on concurrent dd and fs_mark covering both large and tiny files
- bdi->write_bandwidth updates should be rate limited on concurrent dirtiers,
  otherwise it will drift fast and fluctuate
- don't call balance_dirty_pages_ratelimit() when writing to already dirtied
  pages, otherwise the task will be throttled too much

The patches are based on 2.6.37-rc2 and Jan's sync livelock patches. For easier
access I put them in

git://git.kernel.org/pub/scm/linux/kernel/git/wfg/writeback.git dirty-throttling-v2

Wu Fengguang (12):
      writeback: IO-less balance_dirty_pages()
      writeback: consolidate variable names in balance_dirty_pages()
      writeback: per-task rate limit on balance_dirty_pages()
      writeback: prevent duplicate balance_dirty_pages_ratelimited() calls
      writeback: bdi write bandwidth estimation
      writeback: show bdi write bandwidth in debugfs
      writeback: quit throttling when bdi dirty pages dropped
      writeback: reduce per-bdi dirty threshold ramp up time
      writeback: make reasonable gap between the dirty/background thresholds
      writeback: scale down max throttle bandwidth on concurrent dirtiers
      writeback: add trace event for balance_dirty_pages()
      writeback: make nr_to_write a per-file limit

Jan Kara (1):
      writeback: account per-bdi accumulated written pages

 .../filesystems/writeback-throttling-design.txt    |  210 +++++++++++++
 fs/fs-writeback.c                                  |   16 +
 include/linux/backing-dev.h                        |    3 +
 include/linux/sched.h                              |    7 +
 include/linux/writeback.h                          |   14 +
 include/trace/events/writeback.h                   |   61 ++++-
 mm/backing-dev.c                                   |   29 +-
 mm/filemap.c                                       |    5 +-
 mm/memory_hotplug.c                                |    3 -
 mm/page-writeback.c                                |  320 +++++++++++---------
 10 files changed, 511 insertions(+), 157 deletions(-)

It runs smoothly on typical configurations. Under small memory system the pause
time will fluctuate much more due to the limited range for soft throttling.

The soft dirty threshold is now lowered to (background + dirty)/2=15%. So it
will be throttling the applications a bit earlier, and may be perceived by end
users as performance "slow down" if his application happens to dirty a bit more
than 15%. Note that vanilla kernel also has this limit at fresh boot: it starts
checking bdi limits when exceeding the global 15%, however the bdi limit ramps
up pretty slowly in common configurations, so the task is immediately throttled.

The task's think time is not considered for now when computing the pause time.
So it will throttle an "scp" over network way harder than a local "cp". When
to take the user space think time into account and ensure accurate throttle
bandwidth, we will effectively create a simple write I/O bandwidth controller.

On a simple test of 100 dd, it reduces the CPU %system time from 30% to 3%, and
improves IO throughput from 38MB/s to 42MB/s.

The fs_mark benchmark is interesting. The CPU overheads are almost reduced by
half. Before patch the benchmark is actually bounded by CPU. After patch it's
IO bound, but strangely the throughput becomes slightly slower.

#  ./fs_mark  -D  10000  -S0  -n  100000  -s  1  -L  63  -d  /mnt/scratch/0  -d  /mnt/scratch/1  -d  /mnt/scratch/2  -d /mnt/scratch/3  -d  /mnt/scratch/4  -d  /mnt/scratch/5  -d  /mnt/scratch/6  -d  /mnt/scratch/7  -d  /mnt/scratch/8  -d  /mnt/scratch/9  -d  /mnt/scratch/10  -d  /mnt/scratch/11 
#       Version 3.3, 12 thread(s) starting at Thu Nov 11 21:01:36 2010
#       Sync method: NO SYNC: Test does not issue sync() or fsync() calls.
#       Directories:  Time based hash between directories across 10000 subdirectories with 180 seconds per subdirectory.
#       File names: 40 bytes long, (16 initial bytes of time stamp with 24 random bytes at end of name)
#       Files info: size 1 bytes, written with an IO size of 16384 bytes per write
#       App overhead is time in microseconds spent in the test not doing file writing related system calls.
#

2.6.36
FSUse%        Count         Size    Files/sec     App Overhead
     0      1200000            1       1261.7        524762513
     0      2400000            1       1195.3        537844546
     0      3600000            1       1231.9        496441566
     1      4800000            1       1175.8        552421522
     1      6000000            1       1191.6        558529735
     1      7200000            1       1165.3        551178395
     2      8400000            1       1175.0        533209632
     2      9600000            1       1200.6        534862246
     2     10800000            1       1181.2        540616486
     2     12000000            1       1137.4        554551797
     3     13200000            1       1143.7        563319651
     3     14400000            1       1169.0        519527533
     3     15600000            1       1184.0        533550370
     4     16800000            1       1161.3        534358727
     4     18000000            1       1193.4        521610050
     4     19200000            1       1177.6        524117437
     5     20400000            1       1172.6        506166634
     5     21600000            1       1172.3        515725633

avg                                    1182.761      533488581.833

2.6.36+
FSUse%        Count         Size    Files/sec     App Overhead
     0      1200000            1       1125.0        357885976
     0      2400000            1       1155.6        288103795
     0      3600000            1       1172.4        296521755
     1      4800000            1       1136.0        301718887
     1      6000000            1       1156.7        303605077
     1      7200000            1       1102.9        288852150
     2      8400000            1       1140.9        294894485
     2      9600000            1       1148.0        314394450
     2     10800000            1       1099.7        296365560
     2     12000000            1       1153.6        316283083
     3     13200000            1       1087.9        339988006
     3     14400000            1       1183.9        270836344
     3     15600000            1       1122.7        276400918
     4     16800000            1       1132.1        285272223
     4     18000000            1       1154.8        283424055
     4     19200000            1       1202.5        294558877
     5     20400000            1       1158.1        293971332
     5     21600000            1       1159.4        287720335
     5     22800000            1       1150.1        282987509
     5     24000000            1       1150.7        283870613
     6     25200000            1       1123.8        288094185
     6     26400000            1       1152.1        296984323
     6     27600000            1       1190.7        282403174
     7     28800000            1       1088.6        290493643
     7     30000000            1       1144.1        290311419
     7     31200000            1       1186.0        290021271
     7     32400000            1       1213.9        279465138
     8     33600000            1       1117.3        275745401

avg                                    1146.768      294684785.143


I noticed that

1) BdiWriteback can grow very large. For example, bdi 8:16 has 72960KB
   writeback pages, however the disk IO queue can hold at most
   nr_request*max_sectors_kb=128*512kb=64MB writeback pages. Maybe xfs manages
   to create perfect sequential layouts and writes, and the other 8MB writeback
   pages are flying inside the disk?

	root@wfg-ne02 /cc/fs_mark-3.3/ne02-2.6.36+# g BdiWriteback /debug/bdi/8:*/*
	/debug/bdi/8:0/stats:BdiWriteback:            0 kB
	/debug/bdi/8:112/stats:BdiWriteback:        68352 kB
	/debug/bdi/8:128/stats:BdiWriteback:        62336 kB
	/debug/bdi/8:144/stats:BdiWriteback:        61824 kB
	/debug/bdi/8:160/stats:BdiWriteback:        67328 kB
	/debug/bdi/8:16/stats:BdiWriteback:        72960 kB
	/debug/bdi/8:176/stats:BdiWriteback:        57984 kB
	/debug/bdi/8:192/stats:BdiWriteback:        71936 kB
	/debug/bdi/8:32/stats:BdiWriteback:        68352 kB
	/debug/bdi/8:48/stats:BdiWriteback:        56704 kB
	/debug/bdi/8:64/stats:BdiWriteback:        50304 kB
	/debug/bdi/8:80/stats:BdiWriteback:        68864 kB
	/debug/bdi/8:96/stats:BdiWriteback:         2816 kB

2) the 12 disks are not all 100% utilized. Not even close: sdd, sdf, sdh, sdj
   are almost idle at the moment. Dozens of seconds later, some other disks
   become idle. This happens both before/after patch. There may be some hidden
   bugs (unrelated to this patchset).

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.17    0.00   97.87    1.08    0.00    0.88

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
sdc               0.00    63.00    0.00  125.00     0.00  1909.33    30.55     3.88   31.65   6.57  82.13
sdd               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
sde               0.00    19.00    0.00  112.00     0.00  1517.17    27.09     3.95   35.33   8.00  89.60
sdg               0.00    92.67    0.33  126.00     2.67  1773.33    28.12    14.83  120.78   7.73  97.60
sdf               0.00    32.33    0.00   91.67     0.00  1408.17    30.72     4.84   52.97   7.72  70.80
sdh               0.00    17.67    0.00    5.00     0.00   124.00    49.60     0.07   13.33   9.60   4.80
sdi               0.00    44.67    0.00    5.00     0.00   253.33   101.33     0.15   29.33  10.93   5.47
sdl               0.00   168.00    0.00  135.67     0.00  2216.33    32.67     6.41   45.42   5.75  78.00
sdk               0.00   225.00    0.00  123.00     0.00  2355.83    38.31     9.50   73.03   6.94  85.33
sdj               0.00     1.00    0.00    2.33     0.00    26.67    22.86     0.01    2.29   1.71   0.40
sdb               0.00    14.33    0.00  101.67     0.00  1278.00    25.14     2.02   19.95   7.16  72.80
sdm               0.00   150.33    0.00  144.33     0.00  2344.50    32.49     5.43   33.94   5.39  77.73

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.12    0.00   98.63    0.83    0.00    0.42

Device:         rrqm/s   wrqm/s     r/s     w/s    rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm  %util
sda               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
sdc               0.00   105.67    0.00  127.33     0.00  1810.17    28.43     4.39   32.43   6.67  84.93
sdd               0.00     5.33    0.00   10.67     0.00   128.00    24.00     0.03    2.50   1.25   1.33
sde               0.00   180.33    0.33  107.67     2.67  2109.33    39.11     8.11   73.93   8.99  97.07
sdg               0.00     7.67    0.00   63.67     0.00  1387.50    43.59     1.45   24.29  11.08  70.53
sdf               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
sdh               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
sdi               0.00    62.67    0.00   94.67     0.00  1743.50    36.83     3.28   34.68   8.52  80.67
sdl               0.00   162.00    0.00  141.67     0.00  2295.83    32.41     7.09   51.79   6.14  86.93
sdk               0.00    34.33    0.00  143.67     0.00  1910.17    26.59     5.07   38.90   6.26  90.00
sdj               0.00     0.00    0.00    0.00     0.00     0.00     0.00     0.00    0.00   0.00   0.00
sdb               0.00   195.00    0.00   96.67     0.00  1949.50    40.33     5.54   57.23   8.39  81.07
sdm               0.00   155.00    0.00  143.00     0.00  2357.50    32.97     5.21   39.98   5.71  81.60

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
