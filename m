Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id B84206B0253
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 06:12:33 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id a140so47098637wma.0
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:12:33 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id 11si23033914wmd.115.2016.04.12.03.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 03:12:32 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 920311C2370
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 11:12:31 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 00/24] Optimise page alloc/free fast paths v2
Date: Tue, 12 Apr 2016 11:12:01 +0100
Message-Id: <1460455945-29644-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

Sorry for the quick resend. One patch had a warning still and while I
was there, I added a few patches in the bulk pcp free path.

Changelog since v1
o Fix an unused variable warning
o Throw in a few optimisations in the bulk pcp free path
o Rebase to 4.6-rc3

Another year, another round of page allocator optimisations focusing this
time on the alloc and free fast paths. This should be of help to workloads
that are allocator-intensive from kernel space where the cost of zeroing
is not nceessraily incurred.

The series is motivated by the observation that page alloc microbenchmarks
on multiple machines regressed between 3.12.44 and 4.4. Second, there is
discussions before LSF/MM considering the possibility of adding another
page allocator which is potentially hazardous but a patch series improving
performance is better than whining.

After the series is applied, there are still hazards.  In the free paths,
the debugging checking and page zone/pageblock lookups dominate but
there was not an obvious solution to that. In the alloc path, the major
contributers are dealing with zonelists, new page preperation, the fair
zone allocation and numerous statistic updates. The fair zone allocator
is removed by the per-node LRU series if that gets merged so it's nor a
major concern at the moment.

On normal userspace benchmarks, there is little impact as the zeroing cost
is significant but it's visible

aim9
                               4.6.0-rc2             4.6.0-rc2
                                 vanilla          cpuset-v1r20
Min      page_test   864733.33 (  0.00%)   922986.67 (  6.74%)
Min      brk_test   6212191.87 (  0.00%)  6271866.67 (  0.96%)
Min      exec_test     1294.67 (  0.00%)     1306.00 (  0.88%)
Min      fork_test    12644.90 (  0.00%)    12713.33 (  0.54%)

The overall impact on a page allocator microbenchmark for a range of orders
and number of pages allocated in a batch is

                                           4.6.0-rc3                  4.6.0-rc2
                                             vanilla                   micro-v2
Min      alloc-odr0-1               428.00 (  0.00%)           343.00 ( 19.86%)
Min      alloc-odr0-2               314.00 (  0.00%)           252.00 ( 19.75%)
Min      alloc-odr0-4               256.00 (  0.00%)           209.00 ( 18.36%)
Min      alloc-odr0-8               223.00 (  0.00%)           182.00 ( 18.39%)
Min      alloc-odr0-16              207.00 (  0.00%)           168.00 ( 18.84%)
Min      alloc-odr0-32              197.00 (  0.00%)           162.00 ( 17.77%)
Min      alloc-odr0-64              193.00 (  0.00%)           159.00 ( 17.62%)
Min      alloc-odr0-128             191.00 (  0.00%)           157.00 ( 17.80%)
Min      alloc-odr0-256             200.00 (  0.00%)           167.00 ( 16.50%)
Min      alloc-odr0-512             212.00 (  0.00%)           179.00 ( 15.57%)
Min      alloc-odr0-1024            220.00 (  0.00%)           184.00 ( 16.36%)
Min      alloc-odr0-2048            226.00 (  0.00%)           190.00 ( 15.93%)
Min      alloc-odr0-4096            233.00 (  0.00%)           197.00 ( 15.45%)
Min      alloc-odr0-8192            235.00 (  0.00%)           199.00 ( 15.32%)
Min      alloc-odr0-16384           235.00 (  0.00%)           199.00 ( 15.32%)
Min      alloc-odr1-1               519.00 (  0.00%)           461.00 ( 11.18%)
Min      alloc-odr1-2               391.00 (  0.00%)           344.00 ( 12.02%)
Min      alloc-odr1-4               312.00 (  0.00%)           276.00 ( 11.54%)
Min      alloc-odr1-8               276.00 (  0.00%)           238.00 ( 13.77%)
Min      alloc-odr1-16              256.00 (  0.00%)           220.00 ( 14.06%)
Min      alloc-odr1-32              247.00 (  0.00%)           211.00 ( 14.57%)
Min      alloc-odr1-64              242.00 (  0.00%)           208.00 ( 14.05%)
Min      alloc-odr1-128             245.00 (  0.00%)           206.00 ( 15.92%)
Min      alloc-odr1-256             244.00 (  0.00%)           206.00 ( 15.57%)
Min      alloc-odr1-512             245.00 (  0.00%)           209.00 ( 14.69%)
Min      alloc-odr1-1024            246.00 (  0.00%)           211.00 ( 14.23%)
Min      alloc-odr1-2048            253.00 (  0.00%)           220.00 ( 13.04%)
Min      alloc-odr1-4096            258.00 (  0.00%)           224.00 ( 13.18%)
Min      alloc-odr1-8192            261.00 (  0.00%)           226.00 ( 13.41%)
Min      alloc-odr2-1               560.00 (  0.00%)           480.00 ( 14.29%)
Min      alloc-odr2-2               422.00 (  0.00%)           366.00 ( 13.27%)
Min      alloc-odr2-4               339.00 (  0.00%)           289.00 ( 14.75%)
Min      alloc-odr2-8               297.00 (  0.00%)           250.00 ( 15.82%)
Min      alloc-odr2-16              277.00 (  0.00%)           233.00 ( 15.88%)
Min      alloc-odr2-32              268.00 (  0.00%)           223.00 ( 16.79%)
Min      alloc-odr2-64              266.00 (  0.00%)           219.00 ( 17.67%)
Min      alloc-odr2-128             264.00 (  0.00%)           218.00 ( 17.42%)
Min      alloc-odr2-256             265.00 (  0.00%)           219.00 ( 17.36%)
Min      alloc-odr2-512             270.00 (  0.00%)           224.00 ( 17.04%)
Min      alloc-odr2-1024            279.00 (  0.00%)           234.00 ( 16.13%)
Min      alloc-odr2-2048            284.00 (  0.00%)           239.00 ( 15.85%)
Min      alloc-odr2-4096            285.00 (  0.00%)           239.00 ( 16.14%)
Min      alloc-odr3-1               629.00 (  0.00%)           526.00 ( 16.38%)
Min      alloc-odr3-2               471.00 (  0.00%)           395.00 ( 16.14%)
Min      alloc-odr3-4               382.00 (  0.00%)           315.00 ( 17.54%)
Min      alloc-odr3-8               466.00 (  0.00%)           279.00 ( 40.13%)
Min      alloc-odr3-16              316.00 (  0.00%)           259.00 ( 18.04%)
Min      alloc-odr3-32              307.00 (  0.00%)           251.00 ( 18.24%)
Min      alloc-odr3-64              305.00 (  0.00%)           248.00 ( 18.69%)
Min      alloc-odr3-128             308.00 (  0.00%)           248.00 ( 19.48%)
Min      alloc-odr3-256             317.00 (  0.00%)           256.00 ( 19.24%)
Min      alloc-odr3-512             327.00 (  0.00%)           262.00 ( 19.88%)
Min      alloc-odr3-1024            332.00 (  0.00%)           268.00 ( 19.28%)
Min      alloc-odr3-2048            333.00 (  0.00%)           269.00 ( 19.22%)
Min      alloc-odr4-1               764.00 (  0.00%)           607.00 ( 20.55%)
Min      alloc-odr4-2               577.00 (  0.00%)           459.00 ( 20.45%)
Min      alloc-odr4-4               473.00 (  0.00%)           370.00 ( 21.78%)
Min      alloc-odr4-8               420.00 (  0.00%)           327.00 ( 22.14%)
Min      alloc-odr4-16              397.00 (  0.00%)           309.00 ( 22.17%)
Min      alloc-odr4-32              391.00 (  0.00%)           303.00 ( 22.51%)
Min      alloc-odr4-64              395.00 (  0.00%)           302.00 ( 23.54%)
Min      alloc-odr4-128             408.00 (  0.00%)           311.00 ( 23.77%)
Min      alloc-odr4-256             421.00 (  0.00%)           326.00 ( 22.57%)
Min      alloc-odr4-512             428.00 (  0.00%)           333.00 ( 22.20%)
Min      alloc-odr4-1024            429.00 (  0.00%)           330.00 ( 23.08%)
Min      free-odr0-1                216.00 (  0.00%)           193.00 ( 10.65%)
Min      free-odr0-2                152.00 (  0.00%)           137.00 (  9.87%)
Min      free-odr0-4                119.00 (  0.00%)           107.00 ( 10.08%)
Min      free-odr0-8                106.00 (  0.00%)            95.00 ( 10.38%)
Min      free-odr0-16                97.00 (  0.00%)            87.00 ( 10.31%)
Min      free-odr0-32                92.00 (  0.00%)            82.00 ( 10.87%)
Min      free-odr0-64                89.00 (  0.00%)            80.00 ( 10.11%)
Min      free-odr0-128               89.00 (  0.00%)            79.00 ( 11.24%)
Min      free-odr0-256              102.00 (  0.00%)            94.00 (  7.84%)
Min      free-odr0-512              117.00 (  0.00%)           110.00 (  5.98%)
Min      free-odr0-1024             125.00 (  0.00%)           118.00 (  5.60%)
Min      free-odr0-2048             131.00 (  0.00%)           123.00 (  6.11%)
Min      free-odr0-4096             136.00 (  0.00%)           126.00 (  7.35%)
Min      free-odr0-8192             136.00 (  0.00%)           127.00 (  6.62%)
Min      free-odr0-16384            137.00 (  0.00%)           127.00 (  7.30%)
Min      free-odr1-1                317.00 (  0.00%)           292.00 (  7.89%)
Min      free-odr1-2                228.00 (  0.00%)           210.00 (  7.89%)
Min      free-odr1-4                182.00 (  0.00%)           169.00 (  7.14%)
Min      free-odr1-8                162.00 (  0.00%)           148.00 (  8.64%)
Min      free-odr1-16               152.00 (  0.00%)           138.00 (  9.21%)
Min      free-odr1-32               144.00 (  0.00%)           132.00 (  8.33%)
Min      free-odr1-64               143.00 (  0.00%)           131.00 (  8.39%)
Min      free-odr1-128              148.00 (  0.00%)           136.00 (  8.11%)
Min      free-odr1-256              150.00 (  0.00%)           141.00 (  6.00%)
Min      free-odr1-512              151.00 (  0.00%)           144.00 (  4.64%)
Min      free-odr1-1024             155.00 (  0.00%)           147.00 (  5.16%)
Min      free-odr1-2048             157.00 (  0.00%)           150.00 (  4.46%)
Min      free-odr1-4096             156.00 (  0.00%)           147.00 (  5.77%)
Min      free-odr1-8192             156.00 (  0.00%)           146.00 (  6.41%)
Min      free-odr2-1                363.00 (  0.00%)           315.00 ( 13.22%)
Min      free-odr2-2                256.00 (  0.00%)           229.00 ( 10.55%)
Min      free-odr2-4                209.00 (  0.00%)           189.00 (  9.57%)
Min      free-odr2-8                182.00 (  0.00%)           162.00 ( 10.99%)
Min      free-odr2-16               171.00 (  0.00%)           154.00 (  9.94%)
Min      free-odr2-32               165.00 (  0.00%)           152.00 (  7.88%)
Min      free-odr2-64               166.00 (  0.00%)           153.00 (  7.83%)
Min      free-odr2-128              167.00 (  0.00%)           156.00 (  6.59%)
Min      free-odr2-256              170.00 (  0.00%)           159.00 (  6.47%)
Min      free-odr2-512              177.00 (  0.00%)           165.00 (  6.78%)
Min      free-odr2-1024             184.00 (  0.00%)           168.00 (  8.70%)
Min      free-odr2-2048             182.00 (  0.00%)           165.00 (  9.34%)
Min      free-odr2-4096             181.00 (  0.00%)           163.00 (  9.94%)
Min      free-odr3-1                442.00 (  0.00%)           376.00 ( 14.93%)
Min      free-odr3-2                310.00 (  0.00%)           272.00 ( 12.26%)
Min      free-odr3-4                253.00 (  0.00%)           215.00 ( 15.02%)
Min      free-odr3-8                285.00 (  0.00%)           193.00 ( 32.28%)
Min      free-odr3-16               207.00 (  0.00%)           179.00 ( 13.53%)
Min      free-odr3-32               207.00 (  0.00%)           180.00 ( 13.04%)
Min      free-odr3-64               212.00 (  0.00%)           184.00 ( 13.21%)
Min      free-odr3-128              216.00 (  0.00%)           189.00 ( 12.50%)
Min      free-odr3-256              224.00 (  0.00%)           197.00 ( 12.05%)
Min      free-odr3-512              231.00 (  0.00%)           201.00 ( 12.99%)
Min      free-odr3-1024             230.00 (  0.00%)           202.00 ( 12.17%)
Min      free-odr3-2048             229.00 (  0.00%)           199.00 ( 13.10%)
Min      free-odr4-1                559.00 (  0.00%)           460.00 ( 17.71%)
Min      free-odr4-2                406.00 (  0.00%)           333.00 ( 17.98%)
Min      free-odr4-4                336.00 (  0.00%)           272.00 ( 19.05%)
Min      free-odr4-8                298.00 (  0.00%)           240.00 ( 19.46%)
Min      free-odr4-16               283.00 (  0.00%)           235.00 ( 16.96%)
Min      free-odr4-32               291.00 (  0.00%)           239.00 ( 17.87%)
Min      free-odr4-64               297.00 (  0.00%)           242.00 ( 18.52%)
Min      free-odr4-128              309.00 (  0.00%)           257.00 ( 16.83%)
Min      free-odr4-256              322.00 (  0.00%)           275.00 ( 14.60%)
Min      free-odr4-512              326.00 (  0.00%)           279.00 ( 14.42%)
Min      free-odr4-1024             325.00 (  0.00%)           275.00 ( 15.38%)
Min      total-odr0-1               644.00 (  0.00%)           536.00 ( 16.77%)
Min      total-odr0-2               466.00 (  0.00%)           389.00 ( 16.52%)
Min      total-odr0-4               375.00 (  0.00%)           316.00 ( 15.73%)
Min      total-odr0-8               329.00 (  0.00%)           277.00 ( 15.81%)
Min      total-odr0-16              304.00 (  0.00%)           255.00 ( 16.12%)
Min      total-odr0-32              289.00 (  0.00%)           244.00 ( 15.57%)
Min      total-odr0-64              282.00 (  0.00%)           239.00 ( 15.25%)
Min      total-odr0-128             280.00 (  0.00%)           236.00 ( 15.71%)
Min      total-odr0-256             302.00 (  0.00%)           261.00 ( 13.58%)
Min      total-odr0-512             329.00 (  0.00%)           289.00 ( 12.16%)
Min      total-odr0-1024            345.00 (  0.00%)           302.00 ( 12.46%)
Min      total-odr0-2048            357.00 (  0.00%)           313.00 ( 12.32%)
Min      total-odr0-4096            369.00 (  0.00%)           323.00 ( 12.47%)
Min      total-odr0-8192            371.00 (  0.00%)           326.00 ( 12.13%)
Min      total-odr0-16384           372.00 (  0.00%)           326.00 ( 12.37%)
Min      total-odr1-1               836.00 (  0.00%)           754.00 (  9.81%)
Min      total-odr1-2               619.00 (  0.00%)           554.00 ( 10.50%)
Min      total-odr1-4               495.00 (  0.00%)           445.00 ( 10.10%)
Min      total-odr1-8               438.00 (  0.00%)           386.00 ( 11.87%)
Min      total-odr1-16              408.00 (  0.00%)           358.00 ( 12.25%)
Min      total-odr1-32              391.00 (  0.00%)           343.00 ( 12.28%)
Min      total-odr1-64              385.00 (  0.00%)           339.00 ( 11.95%)
Min      total-odr1-128             393.00 (  0.00%)           342.00 ( 12.98%)
Min      total-odr1-256             394.00 (  0.00%)           347.00 ( 11.93%)
Min      total-odr1-512             396.00 (  0.00%)           353.00 ( 10.86%)
Min      total-odr1-1024            401.00 (  0.00%)           358.00 ( 10.72%)
Min      total-odr1-2048            410.00 (  0.00%)           370.00 (  9.76%)
Min      total-odr1-4096            414.00 (  0.00%)           371.00 ( 10.39%)
Min      total-odr1-8192            417.00 (  0.00%)           372.00 ( 10.79%)
Min      total-odr2-1               923.00 (  0.00%)           795.00 ( 13.87%)
Min      total-odr2-2               678.00 (  0.00%)           595.00 ( 12.24%)
Min      total-odr2-4               548.00 (  0.00%)           478.00 ( 12.77%)
Min      total-odr2-8               480.00 (  0.00%)           412.00 ( 14.17%)
Min      total-odr2-16              448.00 (  0.00%)           387.00 ( 13.62%)
Min      total-odr2-32              433.00 (  0.00%)           375.00 ( 13.39%)
Min      total-odr2-64              432.00 (  0.00%)           372.00 ( 13.89%)
Min      total-odr2-128             431.00 (  0.00%)           374.00 ( 13.23%)
Min      total-odr2-256             436.00 (  0.00%)           378.00 ( 13.30%)
Min      total-odr2-512             447.00 (  0.00%)           389.00 ( 12.98%)
Min      total-odr2-1024            463.00 (  0.00%)           402.00 ( 13.17%)
Min      total-odr2-2048            466.00 (  0.00%)           404.00 ( 13.30%)
Min      total-odr2-4096            466.00 (  0.00%)           402.00 ( 13.73%)
Min      total-odr3-1              1071.00 (  0.00%)           904.00 ( 15.59%)
Min      total-odr3-2               781.00 (  0.00%)           667.00 ( 14.60%)
Min      total-odr3-4               636.00 (  0.00%)           531.00 ( 16.51%)
Min      total-odr3-8               751.00 (  0.00%)           472.00 ( 37.15%)
Min      total-odr3-16              523.00 (  0.00%)           438.00 ( 16.25%)
Min      total-odr3-32              514.00 (  0.00%)           431.00 ( 16.15%)
Min      total-odr3-64              517.00 (  0.00%)           432.00 ( 16.44%)
Min      total-odr3-128             524.00 (  0.00%)           437.00 ( 16.60%)
Min      total-odr3-256             541.00 (  0.00%)           453.00 ( 16.27%)
Min      total-odr3-512             558.00 (  0.00%)           463.00 ( 17.03%)
Min      total-odr3-1024            562.00 (  0.00%)           470.00 ( 16.37%)
Min      total-odr3-2048            562.00 (  0.00%)           468.00 ( 16.73%)
Min      total-odr4-1              1323.00 (  0.00%)          1067.00 ( 19.35%)
Min      total-odr4-2               983.00 (  0.00%)           792.00 ( 19.43%)
Min      total-odr4-4               809.00 (  0.00%)           642.00 ( 20.64%)
Min      total-odr4-8               718.00 (  0.00%)           567.00 ( 21.03%)
Min      total-odr4-16              680.00 (  0.00%)           544.00 ( 20.00%)
Min      total-odr4-32              682.00 (  0.00%)           542.00 ( 20.53%)
Min      total-odr4-64              692.00 (  0.00%)           544.00 ( 21.39%)
Min      total-odr4-128             717.00 (  0.00%)           568.00 ( 20.78%)
Min      total-odr4-256             743.00 (  0.00%)           601.00 ( 19.11%)
Min      total-odr4-512             754.00 (  0.00%)           612.00 ( 18.83%)
Min      total-odr4-1024            754.00 (  0.00%)           605.00 ( 19.76%)

 fs/buffer.c                |  10 +-
 include/linux/compaction.h |   6 +-
 include/linux/cpuset.h     |  42 ++++--
 include/linux/mm.h         |   5 +-
 include/linux/mmzone.h     |  34 +++--
 include/linux/page-flags.h |   7 +-
 include/linux/vmstat.h     |   2 -
 kernel/cpuset.c            |  14 +-
 mm/compaction.c            |  12 +-
 mm/internal.h              |   4 +-
 mm/mempolicy.c             |  19 +--
 mm/mmzone.c                |   2 +-
 mm/page_alloc.c            | 328 +++++++++++++++++++++++++++------------------
 mm/vmstat.c                |  25 ----
 14 files changed, 293 insertions(+), 217 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
