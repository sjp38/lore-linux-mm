Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A19936B01CA
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 07:17:59 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/12] Avoid overflowing of stack during page reclaim V2
Date: Mon, 14 Jun 2010 12:17:41 +0100
Message-Id: <1276514273-27693-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

This is a merging of two series - the first of which reduces stack usage
in page reclaim and the second which writes contiguous pages during reclaim
and avoids writeback in direct reclaimers.

Changelog since V1
  o Merge with series that reduces stack usage in page reclaim in general
  o Allow memcg to writeback pages as they are not expected to overflow stack
  o Drop the contiguous-write patch for the moment

There is a problem in the stack depth usage of page reclaim. Particularly
during direct reclaim, it is possible to overflow the stack if it calls
into the filesystems writepage function. This patch series aims to trace
writebacks so it can be evaulated how many dirty pages are being written,
reduce stack usage of page reclaim in general and avoid direct reclaim
writing back pages and overflowing the stack.

The first 4 patches are a forward-port of trace points that are partly based
on trace points defined by Larry Woodman but never merged. They trace parts of
kswapd, direct reclaim, LRU page isolation and page writeback. The tracepoints
can be used to evaluate what is happening within reclaim and whether things
are getting better or worse. They do not have to be part of the final series
but might be useful during discussion and for later regression testing -
particularly around the percentage of time spent in reclaim.

The 6 patches after that reduce the stack footprint of page reclaim by moving
large allocations out of the main call path. Functionally they should be
similar although there is a timing change on when pages get freed exactly.
This is aimed at giving filesystems as much stack as possible if kswapd is
to writeback pages directly.

Patch 11 puts dirty pages as it finds them onto a temporary list and then
writes them all out with a helper function. This simplifies patch 12 and
also increases the chances that IO requests can be optimally merged.

Patch 12 prevents direct reclaim writing out pages at all and instead dirty
pages are put back on the LRU. For lumpy reclaim, the caller will briefly
wait on dirty pages to be written out before trying to reclaim the dirty
pages a second time. This increases the responsibility of kswapd somewhat
because it's now cleaning pages on behalf of direct reclaimers but kswapd
seemed a better fit than background flushers to clean pages as it knows
where the pages needing cleaning are. As it's async IO, it should not cause
kswapd to stall (at least until the queue is congested) but the order that
pages are reclaimed on the LRU is altered. Dirty pages that would have been
reclaimed by direct reclaimers are getting another lap on the LRU. The
dirty pages could have been put on a dedicated list but this increased
counter overhead and the number of lists and it is unclear if it is necessary.

Apologies for the length of the rest of the mail. Measuring the impact of
this is not exactly straight-forward.

I ran a number of tests with monitoring on X86, X86-64 and PPC64 and I'll
cover what the X86-64 results were here. It's an AMD Phenom 4-core machine
with 2G of RAM with a single disk and the onboard IO controller. Dirty
ratio was left at 20 (tests with 40 are in progress). The filesystem all
the tests were run on was XFS.

Three kernels are compared.

traceonly-v2r5		is the first 4 patches of this series
stackreduce-v2r5	is the first 10 patches of this series
nodirect-v2r5		is all patches in the series

The results on each test is broken up into three parts. The first part
compares the results of the test itself. The second part is a report based
on the ftrace postprocessing script in patch 4 and reports on direct reclaim
and kswapd activity. The third part reports what percentage of time was
spent in direct reclaim and kswapd being awake.

To work out the percentage of time spent in direct reclaim, I used
/usr/bin/time to get the User + Sys CPU time. The stalled time was taken
from the post-processing script.  The total time is (User + Sys + Stall)
and obviously the percentage is of stalled over total time.

kernbench
=========

                traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
Elapsed min       98.16 ( 0.00%)    97.95 ( 0.21%)    98.25 (-0.09%)
Elapsed mean      98.29 ( 0.00%)    98.26 ( 0.03%)    98.40 (-0.11%)
Elapsed stddev     0.08 ( 0.00%)     0.20 (-165.90%)     0.12 (-59.87%)
Elapsed max       98.34 ( 0.00%)    98.51 (-0.17%)    98.58 (-0.24%)
User    min      311.03 ( 0.00%)   311.74 (-0.23%)   311.13 (-0.03%)
User    mean     311.28 ( 0.00%)   312.45 (-0.38%)   311.42 (-0.05%)
User    stddev     0.24 ( 0.00%)     0.51 (-114.08%)     0.38 (-59.06%)
User    max      311.58 ( 0.00%)   312.94 (-0.44%)   312.06 (-0.15%)
System  min       40.54 ( 0.00%)    39.65 ( 2.20%)    40.34 ( 0.49%)
System  mean      40.80 ( 0.00%)    40.01 ( 1.93%)    40.81 (-0.03%)
System  stddev     0.23 ( 0.00%)     0.34 (-47.57%)     0.29 (-25.47%)
System  max       41.04 ( 0.00%)    40.51 ( 1.29%)    41.11 (-0.17%)
CPU     min      357.00 ( 0.00%)   357.00 ( 0.00%)   357.00 ( 0.00%)
CPU     mean     357.75 ( 0.00%)   358.00 (-0.07%)   357.75 ( 0.00%)
CPU     stddev     0.43 ( 0.00%)     0.71 (-63.30%)     0.43 ( 0.00%)
CPU     max      358.00 ( 0.00%)   359.00 (-0.28%)   358.00 ( 0.00%)

FTrace Reclaim Statistics
                                     traceonly-v2r5  stackreduce-v2r5  nodirect-v2r5
Direct reclaims                                  0          0          0 
Direct reclaim pages scanned                     0          0          0 
Direct reclaim write async I/O                   0          0          0 
Direct reclaim write sync I/O                    0          0          0 
Wake kswapd requests                             0          0          0 
Kswapd wakeups                                   0          0          0 
Kswapd pages scanned                             0          0          0 
Kswapd reclaim write async I/O                   0          0          0 
Kswapd reclaim write sync I/O                    0          0          0 
Time stalled direct reclaim (ms)              0.00       0.00       0.00 
Time kswapd awake (ms)                        0.00       0.00       0.00 

User/Sys Time Running Test (seconds)       2144.58   2146.22    2144.8
Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.00%
Total Elapsed Time (seconds)                788.42    794.85    793.66
Percentage Time kswapd Awake                 0.00%     0.00%     0.00%

kernbench is a straight-forward kernel compile. Kernel is built 5 times and and an
average taken. There was no interesting difference in terms of performance. As the
workload fit easily in memory, there was no page reclaim activity.

IOZone
======
                       traceonly-v2r5       stackreduce-v2r5     nodirect-v2r5
write-64               395452 ( 0.00%)       397208 ( 0.44%)       397796 ( 0.59%)
write-128              463696 ( 0.00%)       460514 (-0.69%)       458940 (-1.04%)
write-256              504861 ( 0.00%)       506050 ( 0.23%)       502969 (-0.38%)
write-512              490875 ( 0.00%)       485767 (-1.05%)       494264 ( 0.69%)
write-1024             497574 ( 0.00%)       489689 (-1.61%)       505956 ( 1.66%)
write-2048             500993 ( 0.00%)       503076 ( 0.41%)       510097 ( 1.78%)
write-4096             504491 ( 0.00%)       502073 (-0.48%)       506993 ( 0.49%)
write-8192             488398 ( 0.00%)       228857 (-113.41%)       313871 (-55.60%)
write-16384            409006 ( 0.00%)       433783 ( 5.71%)       365696 (-11.84%)
write-32768            473136 ( 0.00%)       481153 ( 1.67%)       486373 ( 2.72%)
write-65536            474833 ( 0.00%)       477970 ( 0.66%)       481192 ( 1.32%)
write-131072           429557 ( 0.00%)       452604 ( 5.09%)       459840 ( 6.59%)
write-262144           397934 ( 0.00%)       401955 ( 1.00%)       397479 (-0.11%)
write-524288           222849 ( 0.00%)       230297 ( 3.23%)       209999 (-6.12%)
rewrite-64            1452528 ( 0.00%)      1492919 ( 2.71%)      1452528 ( 0.00%)
rewrite-128           1622919 ( 0.00%)      1618028 (-0.30%)      1663139 ( 2.42%)
rewrite-256           1694118 ( 0.00%)      1704877 ( 0.63%)      1639786 (-3.31%)
rewrite-512           1753325 ( 0.00%)      1740536 (-0.73%)      1730717 (-1.31%)
rewrite-1024          1741104 ( 0.00%)      1787480 ( 2.59%)      1759651 ( 1.05%)
rewrite-2048          1710867 ( 0.00%)      1747411 ( 2.09%)      1747411 ( 2.09%)
rewrite-4096          1583280 ( 0.00%)      1621536 ( 2.36%)      1599942 ( 1.04%)
rewrite-8192          1308005 ( 0.00%)      1338579 ( 2.28%)      1307358 (-0.05%)
rewrite-16384         1293742 ( 0.00%)      1314178 ( 1.56%)      1291602 (-0.17%)
rewrite-32768         1298360 ( 0.00%)      1314503 ( 1.23%)      1276758 (-1.69%)
rewrite-65536         1289212 ( 0.00%)      1316088 ( 2.04%)      1281351 (-0.61%)
rewrite-131072        1286117 ( 0.00%)      1309070 ( 1.75%)      1283007 (-0.24%)
rewrite-262144        1285902 ( 0.00%)      1305816 ( 1.53%)      1274121 (-0.92%)
rewrite-524288         220417 ( 0.00%)       223971 ( 1.59%)       226133 ( 2.53%)
read-64               3203069 ( 0.00%)      2467108 (-29.83%)      3541098 ( 9.55%)
read-128              3759450 ( 0.00%)      4267461 (11.90%)      4233807 (11.20%)
read-256              4264168 ( 0.00%)      4350555 ( 1.99%)      3935921 (-8.34%)
read-512              3437042 ( 0.00%)      3366987 (-2.08%)      3437042 ( 0.00%)
read-1024             3738636 ( 0.00%)      3821805 ( 2.18%)      3735385 (-0.09%)
read-2048             3938881 ( 0.00%)      3984558 ( 1.15%)      3967993 ( 0.73%)
read-4096             3631489 ( 0.00%)      3828122 ( 5.14%)      3781775 ( 3.97%)
read-8192             3175046 ( 0.00%)      3230268 ( 1.71%)      3247058 ( 2.22%)
read-16384            2923635 ( 0.00%)      2869911 (-1.87%)      2954684 ( 1.05%)
read-32768            2819040 ( 0.00%)      2839776 ( 0.73%)      2852152 ( 1.16%)
read-65536            2659324 ( 0.00%)      2827502 ( 5.95%)      2816464 ( 5.58%)
read-131072           2707652 ( 0.00%)      2727534 ( 0.73%)      2746406 ( 1.41%)
read-262144           2765929 ( 0.00%)      2782166 ( 0.58%)      2776125 ( 0.37%)
read-524288           2810803 ( 0.00%)      2822894 ( 0.43%)      2822394 ( 0.41%)
reread-64             5389653 ( 0.00%)      5860307 ( 8.03%)      5735102 ( 6.02%)
reread-128            5122535 ( 0.00%)      5325799 ( 3.82%)      5325799 ( 3.82%)
reread-256            3245838 ( 0.00%)      3285566 ( 1.21%)      3236056 (-0.30%)
reread-512            4340054 ( 0.00%)      4571003 ( 5.05%)      4742616 ( 8.49%)
reread-1024           4265934 ( 0.00%)      4356809 ( 2.09%)      4374559 ( 2.48%)
reread-2048           3915540 ( 0.00%)      4301837 ( 8.98%)      4338776 ( 9.75%)
reread-4096           3846119 ( 0.00%)      3984379 ( 3.47%)      3979764 ( 3.36%)
reread-8192           3257215 ( 0.00%)      3304518 ( 1.43%)      3325949 ( 2.07%)
reread-16384          2959519 ( 0.00%)      2892622 (-2.31%)      2995773 ( 1.21%)
reread-32768          2570835 ( 0.00%)      2607266 ( 1.40%)      2610783 ( 1.53%)
reread-65536          2731466 ( 0.00%)      2683809 (-1.78%)      2691957 (-1.47%)
reread-131072         2738144 ( 0.00%)      2763886 ( 0.93%)      2776056 ( 1.37%)
reread-262144         2781012 ( 0.00%)      2781786 ( 0.03%)      2784322 ( 0.12%)
reread-524288         2787049 ( 0.00%)      2779851 (-0.26%)      2787681 ( 0.02%)
randread-64           1204796 ( 0.00%)      1204796 ( 0.00%)      1143223 (-5.39%)
randread-128          4135958 ( 0.00%)      4012317 (-3.08%)      4135958 ( 0.00%)
randread-256          3454704 ( 0.00%)      3511189 ( 1.61%)      3511189 ( 1.61%)
randread-512          3437042 ( 0.00%)      3366987 (-2.08%)      3437042 ( 0.00%)
randread-1024         3301774 ( 0.00%)      3401130 ( 2.92%)      3403826 ( 3.00%)
randread-2048         3549844 ( 0.00%)      3391470 (-4.67%)      3477979 (-2.07%)
randread-4096         3214912 ( 0.00%)      3261295 ( 1.42%)      3258820 ( 1.35%)
randread-8192         2818958 ( 0.00%)      2836645 ( 0.62%)      2861450 ( 1.48%)
randread-16384        2571662 ( 0.00%)      2515924 (-2.22%)      2564465 (-0.28%)
randread-32768        2319848 ( 0.00%)      2331892 ( 0.52%)      2333594 ( 0.59%)
randread-65536        2288193 ( 0.00%)      2297103 ( 0.39%)      2301123 ( 0.56%)
randread-131072       2270669 ( 0.00%)      2275707 ( 0.22%)      2279150 ( 0.37%)
randread-262144       2258949 ( 0.00%)      2264700 ( 0.25%)      2259975 ( 0.05%)
randread-524288       2250529 ( 0.00%)      2240365 (-0.45%)      2242837 (-0.34%)
randwrite-64           942521 ( 0.00%)       939223 (-0.35%)       939223 (-0.35%)
randwrite-128          962469 ( 0.00%)       971174 ( 0.90%)       969421 ( 0.72%)
randwrite-256          980760 ( 0.00%)       980760 ( 0.00%)       966633 (-1.46%)
randwrite-512         1190529 ( 0.00%)      1138158 (-4.60%)      1040545 (-14.41%)
randwrite-1024        1361836 ( 0.00%)      1361836 ( 0.00%)      1367037 ( 0.38%)
randwrite-2048        1325646 ( 0.00%)      1364390 ( 2.84%)      1361794 ( 2.65%)
randwrite-4096        1360371 ( 0.00%)      1372653 ( 0.89%)      1363935 ( 0.26%)
randwrite-8192        1291680 ( 0.00%)      1305272 ( 1.04%)      1285206 (-0.50%)
randwrite-16384       1253666 ( 0.00%)      1255865 ( 0.18%)      1231889 (-1.77%)
randwrite-32768       1239139 ( 0.00%)      1250641 ( 0.92%)      1224239 (-1.22%)
randwrite-65536       1223186 ( 0.00%)      1228115 ( 0.40%)      1203094 (-1.67%)
randwrite-131072      1207002 ( 0.00%)      1215733 ( 0.72%)      1198229 (-0.73%)
randwrite-262144      1184954 ( 0.00%)      1201542 ( 1.38%)      1179145 (-0.49%)
randwrite-524288        96156 ( 0.00%)        96502 ( 0.36%)        95942 (-0.22%)
bkwdread-64           2923952 ( 0.00%)      3022727 ( 3.27%)      2772930 (-5.45%)
bkwdread-128          3785961 ( 0.00%)      3657016 (-3.53%)      3657016 (-3.53%)
bkwdread-256          3017775 ( 0.00%)      3052087 ( 1.12%)      3159869 ( 4.50%)
bkwdread-512          2875558 ( 0.00%)      2845081 (-1.07%)      2841317 (-1.21%)
bkwdread-1024         3083680 ( 0.00%)      3181915 ( 3.09%)      3140041 ( 1.79%)
bkwdread-2048         3266376 ( 0.00%)      3282603 ( 0.49%)      3281349 ( 0.46%)
bkwdread-4096         3207709 ( 0.00%)      3287506 ( 2.43%)      3248345 ( 1.25%)
bkwdread-8192         2777710 ( 0.00%)      2792156 ( 0.52%)      2777036 (-0.02%)
bkwdread-16384        2565614 ( 0.00%)      2570412 ( 0.19%)      2541795 (-0.94%)
bkwdread-32768        2472332 ( 0.00%)      2495631 ( 0.93%)      2284260 (-8.23%)
bkwdread-65536        2435202 ( 0.00%)      2391036 (-1.85%)      2361477 (-3.12%)
bkwdread-131072       2417850 ( 0.00%)      2453436 ( 1.45%)      2417903 ( 0.00%)
bkwdread-262144       2468467 ( 0.00%)      2491433 ( 0.92%)      2446649 (-0.89%)
bkwdread-524288       2513411 ( 0.00%)      2534789 ( 0.84%)      2486486 (-1.08%)

FTrace Reclaim Statistics
                                  traceonly-v2r5     stackreduce-v2r5  nodirect-v2r5
Direct reclaims                                  0          0          0 
Direct reclaim pages scanned                     0          0          0 
Direct reclaim write async I/O                   0          0          0 
Direct reclaim write sync I/O                    0          0          0 
Wake kswapd requests                             0          0          0 
Kswapd wakeups                                   0          0          0 
Kswapd pages scanned                             0          0          0 
Kswapd reclaim write async I/O                   0          0          0 
Kswapd reclaim write sync I/O                    0          0          0 
Time stalled direct reclaim (ms)              0.00       0.00       0.00 
Time kswapd awake (ms)                        0.00       0.00       0.00 

User/Sys Time Running Test (seconds)         14.54     14.43     14.51
Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.00%
Total Elapsed Time (seconds)                106.39    104.49    107.15
Percentage Time kswapd Awake                 0.00%     0.00%     0.00%

No big surprises in terms of performance. I know there are gains and losses
but I've always had trouble getting very stable figures out of IOZone so
I find it hard to draw conclusions from them. I should revisit what I'm
doing there to see what's wrong.

In terms of reclaim, nothing interesting happened.

SysBench
========
                traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
           1 11025.01 ( 0.00%) 10249.52 (-7.57%) 10430.57 (-5.70%)
           2  3844.63 ( 0.00%)  4988.95 (22.94%)  4038.95 ( 4.81%)
           3  3210.23 ( 0.00%)  2918.52 (-9.99%)  3113.38 (-3.11%)
           4  1958.91 ( 0.00%)  1987.69 ( 1.45%)  1808.37 (-8.32%)
           5  2864.92 ( 0.00%)  3126.13 ( 8.36%)  2355.70 (-21.62%)
           6  4831.63 ( 0.00%)  3815.67 (-26.63%)  4164.09 (-16.03%)
           7  3788.37 ( 0.00%)  3140.39 (-20.63%)  3471.36 (-9.13%)
           8  2293.61 ( 0.00%)  1636.87 (-40.12%)  1754.25 (-30.75%)
FTrace Reclaim Statistics
                                     traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
Direct reclaims                               9843      13398      51651 
Direct reclaim pages scanned                871367    1008709    3080593 
Direct reclaim write async I/O               24883      30699          0 
Direct reclaim write sync I/O                    0          0          0 
Wake kswapd requests                       7070819    6961672   11268341 
Kswapd wakeups                                1578       1500        943 
Kswapd pages scanned                      22016558   21779455   17393431 
Kswapd reclaim write async I/O             1161346    1101641    1717759 
Kswapd reclaim write sync I/O                    0          0          0 
Time stalled direct reclaim (ms)             26.11      45.04       2.97 
Time kswapd awake (ms)                     5105.06    5135.93    6086.32 

User/Sys Time Running Test (seconds)        734.52    712.39     703.9
Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.00%
Total Elapsed Time (seconds)               9710.02   9589.20   9334.45
Percentage Time kswapd Awake                 0.06%     0.00%     0.00%

Unlike other sysbench results I post, this is the result of a read/write
test. As the machine is under-provisioned for the type of tests, figures
are very unstable. For example, for each of the thread counts from 1-8, the
test is run a minimum of 5 times. If the estimated mean is not within 1%,
it's run up to a maximum of 10 times trying to get a stable average. None
of these averages are stable with variances up to 15%. Part of the problem
is that larger thread counts push the test into swap as the memory is
insufficient. I could tune for this, but it was reclaim that was important.

To illustrate though, here is a graph of total io in comparison to swap io
as reported by vmstat. The update frequency was 2 seconds so the IO shown in
the graph is about the maximum capacity of the disk for the entire duration
of the test with swap kicking in every so often so this was heavily IO bound.

http://www.csn.ul.ie/~mel/postings/nodirect-20100614/totalio-swapio-comparison.ps

The writing back of dirty pages was a factor. It did happen, but it was
a negligible portion of the overall IO. For example, with just tracing a
total of 97MB or 2% of the pages scanned by direct reclaim was written back
and it was all async IO. The time stalled in direct reclaim was negligible
although as you'd expect, reduced by not writing back at all.

What is interesting is that kswapd wake requests were raised by direc reclaim
not writing back pages. My theory is that it's because the processes are
making forward progress meaning they need more memory faster and are not
calling congestion_wait as they would have before. kswapd is awake longer
as a result of direct reclaim not writing back pages.

Between 5-10% of the pages scanned by kswapd need to be written back based
on these three kernels. As the disk was maxed out all of the time, I'm having
trouble deciding whether this is "too much IO" or not but I'm leaning towards
"no". I'd expect that the flusher was also having time getting IO bandwidth.

Simple Writeback Test
=====================
                traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
Direct reclaims                               1923       2394       2683 
Direct reclaim pages scanned                246400     252256     282896 
Direct reclaim write async I/O                   0          0          0 
Direct reclaim write sync I/O                    0          0          0 
Wake kswapd requests                       1496401    1648245    1709870 
Kswapd wakeups                                1140       1118       1113 
Kswapd pages scanned                      10999585   10982748   10851473 
Kswapd reclaim write async I/O                   0          0       1398 
Kswapd reclaim write sync I/O                    0          0          0 
Time stalled direct reclaim (ms)              0.01       0.01       0.01 
Time kswapd awake (ms)                      293.54     293.68     285.51 

User/Sys Time Running Test (seconds)        105.17    102.81    104.34
Percentage Time Spent Direct Reclaim         0.00%     0.00%     0.00%
Total Elapsed Time (seconds)                638.75    640.63    639.42
Percentage Time kswapd Awake                 0.04%     0.00%     0.00%

This test starting with 4 threads, doubling the number of threads on each
iteration up to 64. Each iteration writes 4*RAM amount of files to disk
using dd to dirty memory and conv=fsync to have some sort of stability in
the results.

Direc reclaim writeback was not a problem for this test even though a number
of pages were scanned so there is no reason not to disable it. kswapd
encountered some pages in the "nodirect" kernel but it's likely a timing
issue.

Stress HighAlloc
================
              stress-highalloc  stress-highalloc  stress-highalloc
                traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
Pass 1          76.00 ( 0.00%)    77.00 ( 1.00%)    70.00 (-6.00%)
Pass 2          78.00 ( 0.00%)    78.00 ( 0.00%)    73.00 (-5.00%)
At Rest         80.00 ( 0.00%)    79.00 (-1.00%)    78.00 (-2.00%)

FTrace Reclaim Statistics
              stress-highalloc  stress-highalloc  stress-highalloc
                traceonly-v2r5  stackreduce-v2r5     nodirect-v2r5
Direct reclaims                               1245       1247       1369 
Direct reclaim pages scanned                180262     177032     164337 
Direct reclaim write async I/O               35211      30075          0 
Direct reclaim write sync I/O                17994      13127          0 
Wake kswapd requests                          4211       4868       4386 
Kswapd wakeups                                 842        808        739 
Kswapd pages scanned                      41757111   33360435    9946823 
Kswapd reclaim write async I/O             4872154    3154195     791840 
Kswapd reclaim write sync I/O                    0          0          0 
Time stalled direct reclaim (ms)           9064.33    7249.29    2868.22 
Time kswapd awake (ms)                     6250.77    4612.99    1937.64 

User/Sys Time Running Test (seconds)       2822.01   2812.45    2629.6
Percentage Time Spent Direct Reclaim         0.10%     0.00%     0.00%
Total Elapsed Time (seconds)              11365.05   9682.00   5210.19
Percentage Time kswapd Awake                 0.02%     0.00%     0.00%

This test builds a large number of kernels simultaneously so that the total
workload is 1.5 times the size of RAM. It then attempts to allocate all of
RAM as huge pages. The metric is the percentage of memory allocated using
load (Pass 1), a second attempt under load (Pass 2) and when the kernel
compiles are finishes and the system is quiet (At Rest).

The success figures were comparaible with or without direct reclaim. I know
PPC64's success rates are hit a lot worse than this but I think it could be
improved in other means than what we have today so I'm less worried about it.

Unlike the other tests, synchronous direct writeback is a factor in this
test because of lumpy reclaim. This increases the stall time of a lumpy
reclaimer by quite a margin. Compare the "Time stalled direct reclaim"
between the vanilla and nodirect kernel - the nodirect kernel is stalled
less than a third of the time.  Interestingly, the time kswapd is stalled
is significantly reduced as well and overall, the test completes a lot faster.

Whether this is because of improved IO patterns or just because lumpy
reclaim stalling on synchronous IO is a bad idea, I'm not sure but either
way, the patch looks like a good idea from the perspective of this test.

Based on this series of tests at least, there appears to be good reasons
for preventing direct reclaim writing back pages and it does not appear
we are currently spending a lot of our time in writeback. It remains to
be seen if it's still true with dirty ratio is higher (e.g. 40) or the
amount of available memory differs (e.g. 256MB) but the trace points and
post-processing script can be used to help figure it out.

Comments?

KOSAKI Motohiro (2):
  vmscan: kill prev_priority completely
  vmscan: simplify shrink_inactive_list()

Mel Gorman (11):
  tracing, vmscan: Add trace events for kswapd wakeup, sleeping and
    direct reclaim
  tracing, vmscan: Add trace events for LRU page isolation
  tracing, vmscan: Add trace event when a page is written
  tracing, vmscan: Add a postprocessing script for reclaim-related
    ftrace events
  vmscan: Remove unnecessary temporary vars in do_try_to_free_pages
  vmscan: Setup pagevec as late as possible in shrink_inactive_list()
  vmscan: Setup pagevec as late as possible in shrink_page_list()
  vmscan: Update isolated page counters outside of main path in
    shrink_inactive_list()
  vmscan: Write out dirty pages in batch
  vmscan: Do not writeback pages in direct reclaim
  fix: script formatting

 .../trace/postprocess/trace-vmscan-postprocess.pl  |  623 ++++++++++++++++++++
 include/linux/mmzone.h                             |   15 -
 include/trace/events/gfpflags.h                    |   37 ++
 include/trace/events/kmem.h                        |   38 +--
 include/trace/events/vmscan.h                      |  184 ++++++
 mm/page_alloc.c                                    |    2 -
 mm/vmscan.c                                        |  622 ++++++++++++--------
 mm/vmstat.c                                        |    2 -
 8 files changed, 1223 insertions(+), 300 deletions(-)
 create mode 100644 Documentation/trace/postprocess/trace-vmscan-postprocess.pl
 create mode 100644 include/trace/events/gfpflags.h
 create mode 100644 include/trace/events/vmscan.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
