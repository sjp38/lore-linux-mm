Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 70E176B0037
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 08:39:33 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/2] Reduce system disruption due to kswapd more followup
Date: Wed, 26 Jun 2013 13:39:22 +0100
Message-Id: <1372250364-20640-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Michal Hocko <mhocko@suse.cz>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Further testing revealed that swapping was still higher than expected for
the parallel IO tests. There was also a performance regression reported
building kernels but there appears to be multiple sources of that problem.
This follow-up series primarily addresses the first swapping issue.

The tests were based on three kernels

vanilla:        kernel 3.10-rc4 as that is what the current mmotm uses as a baseline
mmotm-20130606  is mmotm as of that date.
lessdisrupt-v1 is this follow-up series on top of the mmotm kernel

The first test used memcached+memcachetest while some background IO
was in progress as implemented by the parallel IO tests implement in
MM Tests. memcachetest benchmarks how many operations/second memcached
can service. It starts with no background IO on a freshly created ext4
filesystem and then re-runs the test with larger amounts of IO in the
background to roughly simulate a large copy in progress. The expectation
is that the IO should have little or no impact on memcachetest which is
running entirely in memory.

parallelio
                                        3.10.0-rc4                  3.10.0-rc4                  3.10.0-rc4
                                           vanilla          mm1-mmotm-20130606        mm1-lessdisrupt-v1
Ops memcachetest-0M             23018.00 (  0.00%)          22412.00 ( -2.63%)          22556.00 ( -2.01%)
Ops memcachetest-715M           23383.00 (  0.00%)          22810.00 ( -2.45%)          22431.00 ( -4.07%)
Ops memcachetest-2385M          10989.00 (  0.00%)          23564.00 (114.43%)          23054.00 (109.79%)
Ops memcachetest-4055M           3798.00 (  0.00%)          24004.00 (532.02%)          24050.00 (533.23%)
Ops io-duration-0M                  0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops io-duration-715M               12.00 (  0.00%)              7.00 ( 41.67%)              7.00 ( 41.67%)
Ops io-duration-2385M             133.00 (  0.00%)             21.00 ( 84.21%)             22.00 ( 83.46%)
Ops io-duration-4055M             159.00 (  0.00%)             36.00 ( 77.36%)             36.00 ( 77.36%)
Ops swaptotal-0M                    0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swaptotal-715M             139693.00 (  0.00%)             19.00 ( 99.99%)              0.00 (  0.00%)
Ops swaptotal-2385M            268541.00 (  0.00%)              0.00 (  0.00%)             19.00 ( 99.99%)
Ops swaptotal-4055M            414269.00 (  0.00%)          22059.00 ( 94.68%)              2.00 (100.00%)
Ops swapin-0M                       0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-715M                     0.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-2385M                73189.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops swapin-4055M               126292.00 (  0.00%)              0.00 (  0.00%)              0.00 (  0.00%)
Ops minorfaults-0M            1536018.00 (  0.00%)        1533536.00 (  0.16%)        1607381.00 ( -4.65%)
Ops minorfaults-715M          1789978.00 (  0.00%)        1616152.00 (  9.71%)        1533462.00 ( 14.33%)
Ops minorfaults-2385M         1910448.00 (  0.00%)        1614060.00 ( 15.51%)        1661727.00 ( 13.02%)
Ops minorfaults-4055M         1760518.00 (  0.00%)        1613980.00 (  8.32%)        1615116.00 (  8.26%)
Ops majorfaults-0M                  0.00 (  0.00%)              0.00 (  0.00%)              5.00 (-99.00%)
Ops majorfaults-715M              169.00 (  0.00%)            234.00 (-38.46%)             48.00 ( 71.60%)
Ops majorfaults-2385M           14899.00 (  0.00%)            100.00 ( 99.33%)            222.00 ( 98.51%)
Ops majorfaults-4055M           21853.00 (  0.00%)            150.00 ( 99.31%)            128.00 ( 99.41%)

memcachetest is the transactions/second reported by memcachetest. In
        the vanilla kernel note that performance drops from around
        23K/sec to just over 4K/second when there is 2385M of IO going
        on in the background. With current mmotm and the follow-on
	series performance is good.

swaptotal is the total amount of swap traffic. With mmotm the total amount
	of swapping is much reduced. Note that with 4G of background IO that
	this follow-up series almost completely eliminated swap IO.


                            3.10.0-rc4  3.10.0-rc4  3.10.0-rc4
                               vanillamm1-mmotm-20130606mm1-lessdisrupt-v1
Minor Faults                  11230171    10689656    10650607
Major Faults                     37255         786         705
Swap Ins                        199724           0           0
Swap Outs                       623022       22078          21
Direct pages scanned                 0        5378       51660
Kswapd pages scanned          15892718     1610408     1653629
Kswapd pages reclaimed         1097093     1083339     1107652
Direct pages reclaimed               0        5024       47241
Kswapd efficiency                   6%         67%         66%
Kswapd velocity              13633.275    1385.369    1420.058
Direct efficiency                 100%         93%         91%
Direct velocity                  0.000       4.626      44.363
Percentage direct scans             0%          0%          3%
Zone normal velocity         13474.405     671.123     697.927
Zone dma32 velocity            158.870     718.872     766.494
Zone dma velocity                0.000       0.000       0.000
Page writes by reclaim     3065275.000   27259.000    6316.000
Page writes file               2442253        5181        6295
Page writes anon                623022       22078          21
Page reclaim immediate            8019         429         318
Sector Reads                    963320       99096      151864
Sector Writes                 13057396    10887480    10878500
Page rescued immediate               0           0           0
Slabs scanned                    64896       23168       34176
Direct inode steals                  0           0           0
Kswapd inode steals               8668           0           0
Kswapd skipped wait                  0           0           0

Few observations

1. Swap outs were almost completely eliminated and there were no swap-ins.

2. Direct reclaim is active due to reduced activity from kswapd and the fact
   that it is no longer reclaiming at priority 0

3. Zone scanning is still relatively balanced.

4. Page writes from reclaim context is still reasonable low.

                  3.10.0-rc4  3.10.0-rc4  3.10.0-rc4
                     vanillamm1-mmotm-20130606mm1-lessdisrupt-v1
Mean sda-avgqz        168.05       34.64       35.60
Mean sda-await        831.76      216.31      207.05
Mean sda-r_await        7.88        9.68        7.25
Mean sda-w_await     3088.32      223.90      218.28
Max  sda-avgqz       1162.17      766.85      795.69
Max  sda-await       6788.75     4130.01     3728.43
Max  sda-r_await      106.93      242.00       65.97
Max  sda-w_await    30565.93     4145.75     3959.87

Wait times are marginally reduced by the follow-up and still a massive
improve against the mainline kernel.

I tested parallel kernel builds when booted with 1G of RAM. 12 kernels
were built with 2 being compiled at any given time.

multibuild
                          3.10.0-rc4            3.10.0-rc4            3.10.0-rc4
                             vanilla    mm1-mmotm-20130606  mm1-lessdisrupt-v1
User    min         584.99 (  0.00%)      553.31 (  5.42%)      569.08 (  2.72%)
User    mean        598.35 (  0.00%)      574.48 (  3.99%)      581.65 (  2.79%)
User    stddev       10.01 (  0.00%)       17.90 (-78.78%)       10.03 ( -0.14%)
User    max         614.64 (  0.00%)      598.94 (  2.55%)      597.97 (  2.71%)
User    range        29.65 (  0.00%)       45.63 (-53.90%)       28.89 (  2.56%)
System  min          35.78 (  0.00%)       35.05 (  2.04%)       35.54 (  0.67%)
System  mean         36.12 (  0.00%)       35.69 (  1.20%)       35.88 (  0.69%)
System  stddev        0.26 (  0.00%)        0.55 (-113.69%)        0.21 ( 17.51%)
System  max          36.53 (  0.00%)       36.44 (  0.25%)       36.13 (  1.09%)
System  range         0.75 (  0.00%)        1.39 (-85.33%)        0.59 ( 21.33%)
Elapsed min         190.54 (  0.00%)      190.56 ( -0.01%)      192.99 ( -1.29%)
Elapsed mean        197.58 (  0.00%)      203.30 ( -2.89%)      200.53 ( -1.49%)
Elapsed stddev        4.65 (  0.00%)        5.26 (-13.16%)        5.66 (-21.79%)
Elapsed max         203.72 (  0.00%)      210.23 ( -3.20%)      210.46 ( -3.31%)
Elapsed range        13.18 (  0.00%)       19.67 (-49.24%)       17.47 (-32.55%)
CPU     min         308.00 (  0.00%)      282.00 (  8.44%)      294.00 (  4.55%)
CPU     mean        320.80 (  0.00%)      299.78 (  6.55%)      307.67 (  4.09%)
CPU     stddev       10.44 (  0.00%)       13.83 (-32.50%)        9.71 (  7.01%)
CPU     max         340.00 (  0.00%)      333.00 (  2.06%)      328.00 (  3.53%)
CPU     range        32.00 (  0.00%)       51.00 (-59.38%)       34.00 ( -6.25%)

Average kernel build times are still impacted but the follow-up series
helps marginally (it's too noisy to be sure). A preliminary bisection
indicated that there were multiple sources of the regression. The two
other points are the patches that cause mark_page_accessed to be obeyed
and the slab shrinker series. As there a number of patches in flight to
mmotm at the moment in different areas it would be best to confirm this
after this follow-up is merged.

 mm/vmscan.c | 26 ++++++++++----------------
 1 file changed, 10 insertions(+), 16 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
