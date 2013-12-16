Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 180DD6B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:39:49 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so2112601eak.25
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:39:49 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si12907878eew.180.2013.12.16.02.39.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 02:39:48 -0800 (PST)
Date: Mon, 16 Dec 2013 10:39:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/4] Fix ebizzy performance regression due to X86 TLB
 range flush v2
Message-ID: <20131216103944.GO11295@suse.de>
References: <1386964870-6690-1-git-send-email-mgorman@suse.de>
 <CA+55aFyNAigQqBk07xLpf0nkhZ_x-QkBYG8otRzsqg_8A2eg-Q@mail.gmail.com>
 <52AB8C68.1040305@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52AB8C68.1040305@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 13, 2013 at 02:38:32PM -0800, H. Peter Anvin wrote:
> On 12/13/2013 01:16 PM, Linus Torvalds wrote:
> > On Fri, Dec 13, 2013 at 12:01 PM, Mel Gorman <mgorman@suse.de> wrote:
> >>
> >> ebizzy
> >>                       3.13.0-rc3                3.4.69            3.13.0-rc3            3.13.0-rc3
> >>       thread             vanilla               vanilla       altershift-v2r1           nowalk-v2r7
> >> Mean     1     7377.91 (  0.00%)     6812.38 ( -7.67%)     7784.45 (  5.51%)     7804.08 (  5.78%)
> >> Mean     2     8262.07 (  0.00%)     8276.75 (  0.18%)     9437.49 ( 14.23%)     9450.88 ( 14.39%)
> >> Mean     3     7895.00 (  0.00%)     8002.84 (  1.37%)     8875.38 ( 12.42%)     8914.60 ( 12.91%)
> >> Mean     4     7658.74 (  0.00%)     7824.83 (  2.17%)     8509.10 ( 11.10%)     8399.43 (  9.67%)
> >> Mean     5     7275.37 (  0.00%)     7678.74 (  5.54%)     8208.94 ( 12.83%)     8197.86 ( 12.68%)
> >> Mean     6     6875.50 (  0.00%)     7597.18 ( 10.50%)     7755.66 ( 12.80%)     7807.51 ( 13.56%)
> >> Mean     7     6722.48 (  0.00%)     7584.75 ( 12.83%)     7456.93 ( 10.93%)     7480.74 ( 11.28%)
> >> Mean     8     6559.55 (  0.00%)     7591.51 ( 15.73%)     6879.01 (  4.87%)     6881.86 (  4.91%)
> > 
> > Hmm. Do you have any idea why 3.4.69 still seems to do better at
> > higher thread counts?
> > 
> > No complaints about this patch-series, just wondering..
> > 
> 
> It would be really great to get some performance numbers on something
> other than ebizzy, though...
> 

What do you suggest? I'd be interested in hearing what sort of tests
originally motivated the series. I picked a few different tests to see
what fell out. All of this was driven from mmtests so I can do a release
and point to the config files used if anyone wants to try reproducing it.

First was Alex's microbenchmark from https://lkml.org/lkml/2012/5/17/59
and ran it for a range of thread numbers, 320 iterations per thread with
random number of entires to flush. Results are from two machines

4 core:  Intel(R) Core(TM) i3-3240 CPU @ 3.40GHz
8 core:  Intel(R) Core(TM) i7-3770 CPU @ 3.40GHz

Single socket in both cases, both ivybridge. Neither are high end but my
budget does not cover having high-end machines in my local test grid which
is bad but unavoidable.

On a 4 core machine

tlbflush
                        3.13.0-rc3            3.13.0-rc3                3.4.69
                           vanilla           nowalk-v2r7               vanilla
Mean       1       11.17 (  0.00%)       10.52 (  5.82%)        5.15 ( 53.93%)
Mean       2       11.70 (  0.00%)       10.77 (  7.99%)       10.30 ( 11.94%)
Mean       3       24.07 (  0.00%)       22.42 (  6.87%)       10.89 ( 54.74%)
Mean       4       40.48 (  0.00%)       39.72 (  1.88%)       19.51 ( 51.81%)
Range      1        7.00 (  0.00%)        7.00 (  0.00%)        5.00 ( 28.57%)
Range      2       44.00 (  0.00%)       20.00 ( 54.55%)       23.00 ( 47.73%)
Range      3       13.00 (  0.00%)       16.00 (-23.08%)        8.00 ( 38.46%)
Range      4       26.00 (  0.00%)       32.00 (-23.08%)       11.00 ( 57.69%)
Stddev     1        1.49 (  0.00%)        1.45 ( -2.83%)        0.52 (-65.22%)
Stddev     2        3.51 (  0.00%)        2.20 (-37.20%)        7.46 (112.74%)
Stddev     3        1.84 (  0.00%)        2.43 ( 32.46%)        1.34 (-26.96%)
Stddev     4        3.44 (  0.00%)        4.61 ( 34.14%)        1.51 (-56.13%)

          3.13.0-rc3  3.13.0-rc3      3.4.69
             vanilla nowalk-v2r7     vanilla
User          197.37      181.76       99.69
System        161.92      161.54      126.49
Elapsed      2741.19     2793.41     2749.12

Showing small gains on that machine but the variations are high enough
that we cannot be certain it's a real gain. The random number of entries
selection is what makes this noisy but picking a single number would
bias the test for the characteristics of a single machine.

Note that 3.4 is still just a lot better.

This was an 8-core machine

tlbflush
                        3.13.0-rc3            3.13.0-rc3                3.4.69
                           vanilla           nowalk-v2r7               vanilla
Mean       1        7.98 (  0.00%)        8.54 ( -7.01%)        5.16 ( 35.36%)
Mean       2        7.82 (  0.00%)        8.35 ( -6.84%)        5.81 ( 25.71%)
Mean       3        6.59 (  0.00%)        7.80 (-18.36%)        5.58 ( 15.37%)
Mean       5       13.28 (  0.00%)       12.85 (  3.20%)        8.88 ( 33.15%)
Mean       8       32.50 (  0.00%)       32.52 ( -0.04%)       19.92 ( 38.71%)
Range      1        7.00 (  0.00%)        6.00 ( 14.29%)        3.00 ( 57.14%)
Range      2        8.00 (  0.00%)        7.00 ( 12.50%)       18.00 (-125.00%)
Range      3        6.00 (  0.00%)        7.00 (-16.67%)        7.00 (-16.67%)
Range      5       11.00 (  0.00%)       20.00 (-81.82%)        9.00 ( 18.18%)
Range      8       35.00 (  0.00%)       33.00 (  5.71%)        8.00 ( 77.14%)
Stddev     1        1.31 (  0.00%)        1.52 ( 15.75%)        0.48 (-63.66%)
Stddev     2        1.55 (  0.00%)        1.52 ( -1.54%)        3.06 ( 98.14%)
Stddev     3        1.27 (  0.00%)        1.61 ( 26.07%)        1.53 ( 20.16%)
Stddev     5        2.99 (  0.00%)        2.63 (-11.97%)        2.56 (-14.38%)
Stddev     8        8.29 (  0.00%)        6.51 (-21.46%)        1.23 (-85.15%)

          3.13.0-rc3  3.13.0-rc3      3.4.69
             vanilla nowalk-v2r7     vanilla
User          316.01      341.55      205.00
System        249.25      273.16      203.79
Elapsed      3382.56     4398.20     3682.31

This is showing a mix of gains and losses with higher CPU usage to boot.
The figures are again within variations so difficult to be conclusive
about it. The system CPU usage is higher

The following is netperf running UDP_STREAM and TCP_STREAM on loopback on
the 4-core machine

netperf-udp
                      3.13.0-rc3            3.13.0-rc3                3.4.69
                         vanilla           nowalk-v2r7               vanilla
Tput 64         179.14 (  0.00%)      177.82 ( -0.74%)      207.16 ( 15.64%)
Tput 128        354.67 (  0.00%)      350.04 ( -1.31%)      416.47 ( 17.42%)
Tput 256        712.01 (  0.00%)      697.31 ( -2.06%)      828.11 ( 16.31%)
Tput 1024      2770.59 (  0.00%)     2717.55 ( -1.91%)     3229.38 ( 16.56%)
Tput 2048      5328.83 (  0.00%)     5255.81 ( -1.37%)     6183.69 ( 16.04%)
Tput 3312      8249.24 (  0.00%)     8170.62 ( -0.95%)     9491.63 ( 15.06%)
Tput 4096      9865.98 (  0.00%)     9760.41 ( -1.07%)    11348.02 ( 15.02%)
Tput 8192     17263.69 (  0.00%)    17261.15 ( -0.01%)    19917.01 ( 15.37%)
Tput 16384    27274.61 (  0.00%)    27283.01 (  0.03%)    30785.56 ( 12.87%)

netperf-tcp
                      3.13.0-rc3            3.13.0-rc3                3.4.69
                         vanilla           nowalk-v2r7               vanilla
Tput 64        1612.82 (  0.00%)     1622.31 (  0.59%)     1584.68 ( -1.74%)
Tput 128       3043.06 (  0.00%)     3024.19 ( -0.62%)     2926.80 ( -3.82%)
Tput 256       5755.06 (  0.00%)     5747.26 ( -0.14%)     5328.57 ( -7.41%)
Tput 1024     17662.03 (  0.00%)    17778.94 (  0.66%)    11963.09 (-32.27%)
Tput 2048     25382.69 (  0.00%)    25464.23 (  0.32%)    15043.90 (-40.73%)
Tput 3312     29990.79 (  0.00%)    30135.56 (  0.48%)    15731.78 (-47.54%)
Tput 4096     31612.33 (  0.00%)    31775.74 (  0.52%)    17626.10 (-44.24%)
Tput 8192     35366.99 (  0.00%)    35425.15 (  0.16%)    21060.61 (-40.45%)
Tput 16384    38547.25 (  0.00%)    38441.09 ( -0.28%)    27925.43 (-27.56%)

Very marginal there. Something nuts happened with UDP and TCP processing
between 3.4 and 3.13 but this particular series' impact is marginal

8 core machine

netperf-udp
                      3.13.0-rc3            3.13.0-rc3                3.4.69
                         vanilla           nowalk-v2r7               vanilla
Tput 64         328.25 (  0.00%)      331.05 (  0.85%)      383.97 ( 16.97%)
Tput 128        664.31 (  0.00%)      659.58 ( -0.71%)      762.59 ( 14.79%)
Tput 256       1305.82 (  0.00%)     1309.65 (  0.29%)     1508.27 ( 15.50%)
Tput 1024      5110.17 (  0.00%)     5081.82 ( -0.55%)     5775.96 ( 13.03%)
Tput 2048      9839.14 (  0.00%)    10074.00 (  2.39%)    11010.10 ( 11.90%)
Tput 3312     14787.70 (  0.00%)    14850.59 (  0.43%)    16821.29 ( 13.75%)
Tput 4096     17583.14 (  0.00%)    17936.17 (  2.01%)    20246.74 ( 15.15%)
Tput 8192     30165.48 (  0.00%)    30386.78 (  0.73%)    31904.81 (  5.77%)
Tput 16384    48345.93 (  0.00%)    48127.68 ( -0.45%)    48850.30 (  1.04%)

netperf-tcp
                      3.13.0-rc3            3.13.0-rc3                3.4.69
                         vanilla           nowalk-v2r7               vanilla
Tput 64        3064.32 (  0.00%)     3149.22 (  2.77%)     2701.19 (-11.85%)
Tput 128       5777.71 (  0.00%)     5899.85 (  2.11%)     4931.78 (-14.64%)
Tput 256      10330.00 (  0.00%)    10567.97 (  2.30%)     8388.28 (-18.80%)
Tput 1024     30744.90 (  0.00%)    31084.37 (  1.10%)    17496.95 (-43.09%)
Tput 2048     43064.86 (  0.00%)    42916.90 ( -0.34%)    22227.42 (-48.39%)
Tput 3312     50473.85 (  0.00%)    50388.37 ( -0.17%)    25154.14 (-50.16%)
Tput 4096     53909.70 (  0.00%)    53965.40 (  0.10%)    27328.49 (-49.31%)
Tput 8192     63303.83 (  0.00%)    63152.88 ( -0.24%)    32078.71 (-49.33%)
Tput 16384    68632.11 (  0.00%)    68063.05 ( -0.83%)    39758.01 (-42.07%)

Looks a bit more solid. I didn't post the figures but the elapsed times
are also lower implying that netperf is using fewer iterations to
measure results it is confident of

Next is a kernel build benchmark. I'd be very surprised if it was hitting
the relevant paths but I think people expect to see this benchmark so....

4 core machine
kernbench
                          3.13.0-rc3            3.13.0-rc3                3.4.69
                             vanilla           nowalk-v2r7               vanilla
User    min         714.10 (  0.00%)      714.51 ( -0.06%)      706.83 (  1.02%)
User    mean        715.04 (  0.00%)      714.75 (  0.04%)      707.64 (  1.04%)
User    stddev        0.67 (  0.00%)        0.25 ( 62.98%)        0.69 ( -3.40%)
User    max         716.12 (  0.00%)      715.22 (  0.13%)      708.56 (  1.06%)
User    range         2.02 (  0.00%)        0.71 ( 64.85%)        1.73 ( 14.36%)
System  min          32.89 (  0.00%)       32.50 (  1.19%)       39.17 (-19.09%)
System  mean         33.25 (  0.00%)       32.75 (  1.53%)       39.51 (-18.82%)
System  stddev        0.25 (  0.00%)        0.22 ( 14.73%)        0.28 (-11.29%)
System  max          33.60 (  0.00%)       33.12 (  1.43%)       39.83 (-18.54%)
System  range         0.71 (  0.00%)        0.62 ( 12.68%)        0.66 (  7.04%)
Elapsed min         195.70 (  0.00%)      195.88 ( -0.09%)      195.84 ( -0.07%)
Elapsed mean        196.09 (  0.00%)      195.97 (  0.06%)      196.14 ( -0.03%)
Elapsed stddev        0.25 (  0.00%)        0.06 ( 74.74%)        0.16 ( 33.94%)
Elapsed max         196.41 (  0.00%)      196.07 (  0.17%)      196.33 (  0.04%)
Elapsed range         0.71 (  0.00%)        0.19 ( 73.24%)        0.49 ( 30.99%)
CPU     min         381.00 (  0.00%)      381.00 (  0.00%)      380.00 (  0.26%)
CPU     mean        381.00 (  0.00%)      381.00 (  0.00%)      380.40 (  0.16%)
CPU     stddev        0.00 (  0.00%)        0.00 (  0.00%)        0.49 (-99.00%)
CPU     max         381.00 (  0.00%)      381.00 (  0.00%)      381.00 (  0.00%)
CPU     range         0.00 (  0.00%)        0.00 (  0.00%)        1.00 (-99.00%)

8 core machine
kernbench
                          3.13.0-rc3            3.13.0-rc3                3.4.69
                             vanilla           nowalk-v2r7               vanilla
User    min         632.94 (  0.00%)      632.71 (  0.04%)      681.00 ( -7.59%)
User    mean        633.25 (  0.00%)      633.41 ( -0.02%)      681.34 ( -7.59%)
User    stddev        0.24 (  0.00%)        0.55 (-124.00%)        0.34 (-39.88%)
User    max         633.55 (  0.00%)      634.14 ( -0.09%)      681.99 ( -7.65%)
User    range         0.61 (  0.00%)        1.43 (-134.43%)        0.99 (-62.30%)
System  min          29.74 (  0.00%)       29.76 ( -0.07%)       38.24 (-28.58%)
System  mean         30.12 (  0.00%)       30.22 ( -0.32%)       38.55 (-27.99%)
System  stddev        0.22 (  0.00%)        0.24 (-11.04%)        0.25 (-14.10%)
System  max          30.39 (  0.00%)       30.48 ( -0.30%)       38.87 (-27.90%)
System  range         0.65 (  0.00%)        0.72 (-10.77%)        0.63 (  3.08%)
Elapsed min          88.40 (  0.00%)       88.47 ( -0.08%)       95.81 ( -8.38%)
Elapsed mean         88.55 (  0.00%)       88.72 ( -0.20%)       96.01 ( -8.43%)
Elapsed stddev        0.10 (  0.00%)        0.15 (-46.20%)        0.23 (-125.69%)
Elapsed max          88.72 (  0.00%)       88.88 ( -0.18%)       96.30 ( -8.54%)
Elapsed range         0.32 (  0.00%)        0.41 (-28.13%)        0.49 (-53.13%)
CPU     min         747.00 (  0.00%)      746.00 (  0.13%)      747.00 (  0.00%)
CPU     mean        748.80 (  0.00%)      747.60 (  0.16%)      749.20 ( -0.05%)
CPU     stddev        0.98 (  0.00%)        1.36 (-38.44%)        1.47 (-50.00%)
CPU     max         750.00 (  0.00%)      750.00 (  0.00%)      751.00 ( -0.13%)
CPU     range         3.00 (  0.00%)        4.00 (-33.33%)        4.00 (-33.33%)

Yup, nothing there worth getting excited about although slightly amusing
to note that we've improved kernel build times since 3.4.69 if nothing
else. We're all over the performance of that!

This is a modified ebizzy benchmark to give a breakdown of per-thread
performance.

4 core machine
ebizzy total throughput (higher the better)
                    3.13.0-rc3            3.13.0-rc3                3.4.69
                       vanilla           nowalk-v2r7               vanilla
Mean   1     6366.88 (  0.00%)     6741.00 (  5.88%)     6658.32 (  4.58%)
Mean   2     6917.56 (  0.00%)     7952.29 ( 14.96%)     8120.79 ( 17.39%)
Mean   3     6231.78 (  0.00%)     6846.08 (  9.86%)     7174.98 ( 15.14%)
Mean   4     5887.91 (  0.00%)     6503.12 ( 10.45%)     6903.05 ( 17.24%)
Mean   5     5680.77 (  0.00%)     6185.83 (  8.89%)     6549.15 ( 15.29%)
Mean   6     5692.87 (  0.00%)     6249.48 (  9.78%)     6442.21 ( 13.16%)
Mean   7     5846.76 (  0.00%)     6344.94 (  8.52%)     6279.13 (  7.40%)
Mean   8     5974.57 (  0.00%)     6406.28 (  7.23%)     6265.29 (  4.87%)
Range  1      174.00 (  0.00%)      202.00 (-16.09%)      806.00 (-363.22%)
Range  2      286.00 (  0.00%)      979.00 (-242.31%)     1255.00 (-338.81%)
Range  3      530.00 (  0.00%)      583.00 (-10.00%)      626.00 (-18.11%)
Range  4      592.00 (  0.00%)      691.00 (-16.72%)      630.00 ( -6.42%)
Range  5      567.00 (  0.00%)      417.00 ( 26.46%)      584.00 ( -3.00%)
Range  6      588.00 (  0.00%)      353.00 ( 39.97%)      439.00 ( 25.34%)
Range  7      477.00 (  0.00%)      284.00 ( 40.46%)      343.00 ( 28.09%)
Range  8      408.00 (  0.00%)      182.00 ( 55.39%)      237.00 ( 41.91%)
Stddev 1       31.59 (  0.00%)       32.94 ( -4.27%)      154.26 (-388.34%)
Stddev 2       56.95 (  0.00%)      136.79 (-140.19%)      194.45 (-241.43%)
Stddev 3      132.28 (  0.00%)      101.02 ( 23.63%)      106.60 ( 19.41%)
Stddev 4      140.93 (  0.00%)      136.11 (  3.42%)      138.26 (  1.90%)
Stddev 5      118.58 (  0.00%)       86.74 ( 26.85%)      111.73 (  5.77%)
Stddev 6      109.64 (  0.00%)       77.49 ( 29.32%)       95.52 ( 12.87%)
Stddev 7      103.91 (  0.00%)       51.44 ( 50.50%)       54.43 ( 47.62%)
Stddev 8       67.79 (  0.00%)       31.34 ( 53.76%)       53.08 ( 21.69%)

4 core machine
ebizzy Thread spread (closer to 0, the more fair it is)
                    3.13.0-rc3            3.13.0-rc3                3.4.69
                       vanilla           nowalk-v2r7               vanilla
Mean   1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Mean   2        0.34 (  0.00%)        0.30 ( 11.76%)        0.07 ( 79.41%)
Mean   3        1.29 (  0.00%)        0.92 ( 28.68%)        0.29 ( 77.52%)
Mean   4        7.08 (  0.00%)       42.38 (-498.59%)        0.22 ( 96.89%)
Mean   5      193.54 (  0.00%)      483.41 (-149.77%)        0.41 ( 99.79%)
Mean   6      151.12 (  0.00%)      198.22 (-31.17%)        0.42 ( 99.72%)
Mean   7      115.38 (  0.00%)      160.29 (-38.92%)        0.58 ( 99.50%)
Mean   8      108.65 (  0.00%)      138.96 (-27.90%)        0.44 ( 99.60%)
Range  1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Range  2        5.00 (  0.00%)        6.00 (-20.00%)        2.00 ( 60.00%)
Range  3       10.00 (  0.00%)       17.00 (-70.00%)        9.00 ( 10.00%)
Range  4      256.00 (  0.00%)     1001.00 (-291.02%)        5.00 ( 98.05%)
Range  5      456.00 (  0.00%)     1226.00 (-168.86%)        6.00 ( 98.68%)
Range  6      298.00 (  0.00%)      294.00 (  1.34%)        8.00 ( 97.32%)
Range  7      192.00 (  0.00%)      220.00 (-14.58%)        7.00 ( 96.35%)
Range  8      171.00 (  0.00%)      163.00 (  4.68%)        8.00 ( 95.32%)
Stddev 1        0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Stddev 2        0.72 (  0.00%)        0.85 ( 17.99%)        0.29 (-59.72%)
Stddev 3        1.42 (  0.00%)        1.90 ( 34.22%)        1.12 (-21.19%)
Stddev 4       33.83 (  0.00%)      127.26 (276.15%)        0.79 (-97.65%)
Stddev 5       92.08 (  0.00%)      225.01 (144.35%)        1.06 (-98.85%)
Stddev 6       64.82 (  0.00%)       69.43 (  7.11%)        1.28 (-98.02%)
Stddev 7       36.66 (  0.00%)       49.19 ( 34.20%)        1.18 (-96.79%)
Stddev 8       30.79 (  0.00%)       36.23 ( 17.64%)        1.06 (-96.55%)

Three things to note here. The spread goes to hell when there are more
workload threads than cores. Second, the patch is actually making the
spread and thread fairness worse. Third, the fact that there is spread at
all is bad because 3.4.69 experienced no such problem

8 core machine
ebizzy
                     3.13.0-rc3            3.13.0-rc3                3.4.69
                        vanilla           nowalk-v2r7               vanilla
Mean   1      7295.77 (  0.00%)     7835.63 (  7.40%)     6713.32 ( -7.98%)
Mean   2      8252.58 (  0.00%)     9554.63 ( 15.78%)     8334.43 (  0.99%)
Mean   3      8179.74 (  0.00%)     9032.46 ( 10.42%)     8134.42 ( -0.55%)
Mean   4      7862.45 (  0.00%)     8688.01 ( 10.50%)     7966.27 (  1.32%)
Mean   5      7170.24 (  0.00%)     8216.15 ( 14.59%)     7820.63 (  9.07%)
Mean   6      6835.10 (  0.00%)     7866.95 ( 15.10%)     7773.30 ( 13.73%)
Mean   7      6740.99 (  0.00%)     7586.36 ( 12.54%)     7712.45 ( 14.41%)
Mean   8      6494.01 (  0.00%)     6849.82 (  5.48%)     7705.62 ( 18.66%)
Mean   12     6567.37 (  0.00%)     6973.66 (  6.19%)     7554.82 ( 15.04%)
Mean   16     6630.26 (  0.00%)     7042.52 (  6.22%)     7331.04 ( 10.57%)
Range  1       767.00 (  0.00%)      194.00 ( 74.71%)      661.00 ( 13.82%)
Range  2       178.00 (  0.00%)      185.00 ( -3.93%)      592.00 (-232.58%)
Range  3       175.00 (  0.00%)      213.00 (-21.71%)      431.00 (-146.29%)
Range  4       806.00 (  0.00%)      924.00 (-14.64%)      542.00 ( 32.75%)
Range  5       544.00 (  0.00%)      438.00 ( 19.49%)      444.00 ( 18.38%)
Range  6       399.00 (  0.00%)     1111.00 (-178.45%)      528.00 (-32.33%)
Range  7       629.00 (  0.00%)      895.00 (-42.29%)      467.00 ( 25.76%)
Range  8       400.00 (  0.00%)      255.00 ( 36.25%)      435.00 ( -8.75%)
Range  12      233.00 (  0.00%)      108.00 ( 53.65%)      330.00 (-41.63%)
Range  16      141.00 (  0.00%)      134.00 (  4.96%)      496.00 (-251.77%)
Stddev 1        73.94 (  0.00%)       52.33 ( 29.23%)      177.17 (-139.59%)
Stddev 2        23.47 (  0.00%)       42.08 (-79.24%)       88.91 (-278.74%)
Stddev 3        36.48 (  0.00%)       29.02 ( 20.45%)      101.07 (-177.05%)
Stddev 4       158.37 (  0.00%)      133.99 ( 15.40%)      130.52 ( 17.59%)
Stddev 5       116.74 (  0.00%)       76.76 ( 34.25%)       78.31 ( 32.92%)
Stddev 6        66.34 (  0.00%)      273.87 (-312.83%)       87.79 (-32.33%)
Stddev 7       145.62 (  0.00%)      174.99 (-20.16%)       90.52 ( 37.84%)
Stddev 8        68.51 (  0.00%)       47.58 ( 30.54%)       81.11 (-18.39%)
Stddev 12       32.15 (  0.00%)       20.18 ( 37.22%)       65.74 (-104.50%)
Stddev 16       21.59 (  0.00%)       20.29 (  6.01%)       86.42 (-300.25%)

Patch series shows the strongest performance gain here. Not surprising
considering this was the machine and test that first motivated the
series. 3.4.69 is still a lot better.

ebizzy Thread spread
                     3.13.0-rc3            3.13.0-rc3                3.4.69
                        vanilla           nowalk-v2r7               vanilla
Mean   1         0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Mean   2         0.40 (  0.00%)        0.35 ( 12.50%)        0.13 ( 67.50%)
Mean   3        23.73 (  0.00%)        0.46 ( 98.06%)        0.26 ( 98.90%)
Mean   4        12.79 (  0.00%)        1.40 ( 89.05%)        0.67 ( 94.76%)
Mean   5        13.08 (  0.00%)        4.06 ( 68.96%)        0.36 ( 97.25%)
Mean   6        23.21 (  0.00%)      136.62 (-488.63%)        1.13 ( 95.13%)
Mean   7        15.85 (  0.00%)      203.46 (-1183.66%)        1.51 ( 90.47%)
Mean   8       109.37 (  0.00%)       47.75 ( 56.34%)        1.05 ( 99.04%)
Mean   12      124.84 (  0.00%)      120.55 (  3.44%)        0.59 ( 99.53%)
Mean   16      113.50 (  0.00%)      109.60 (  3.44%)        0.49 ( 99.57%)
Range  1         0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Range  2         3.00 (  0.00%)       11.00 (-266.67%)        1.00 ( 66.67%)
Range  3        80.00 (  0.00%)        5.00 ( 93.75%)        1.00 ( 98.75%)
Range  4        38.00 (  0.00%)        5.00 ( 86.84%)        2.00 ( 94.74%)
Range  5        37.00 (  0.00%)       21.00 ( 43.24%)        1.00 ( 97.30%)
Range  6        46.00 (  0.00%)      927.00 (-1915.22%)        8.00 ( 82.61%)
Range  7        28.00 (  0.00%)      716.00 (-2457.14%)       36.00 (-28.57%)
Range  8       325.00 (  0.00%)      315.00 (  3.08%)       26.00 ( 92.00%)
Range  12      160.00 (  0.00%)      151.00 (  5.62%)        5.00 ( 96.88%)
Range  16      108.00 (  0.00%)      123.00 (-13.89%)        1.00 ( 99.07%)
Stddev 1         0.00 (  0.00%)        0.00 (  0.00%)        0.00 (  0.00%)
Stddev 2         0.62 (  0.00%)        1.18 ( 91.08%)        0.34 (-45.44%)
Stddev 3        17.40 (  0.00%)        0.81 (-95.37%)        0.44 (-97.48%)
Stddev 4         8.52 (  0.00%)        1.05 (-87.69%)        0.51 (-94.00%)
Stddev 5         7.91 (  0.00%)        3.94 (-50.20%)        0.48 (-93.93%)
Stddev 6         7.11 (  0.00%)      174.18 (2348.91%)        1.48 (-79.18%)
Stddev 7         5.90 (  0.00%)      139.48 (2263.45%)        4.12 (-30.24%)
Stddev 8        80.95 (  0.00%)       58.03 (-28.32%)        2.65 (-96.72%)
Stddev 12       31.48 (  0.00%)       33.78 (  7.30%)        0.66 (-97.89%)
Stddev 16       24.32 (  0.00%)       26.22 (  7.79%)        0.50 (-97.94%)

Again, while overall performance is better, the spread of performance
between threads is worse but the fact that there is spread at all is
bad.

So overall to me it looks like the series still stands. The clearest result
was from ebizzy which is an adverse workload in this specific case because
of the size of the TLBs involved. The performance of individual threads
is a big concern but I can bisect for that separately and see what falls out.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
