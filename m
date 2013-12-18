Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id EE4B66B0035
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 14:42:06 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id r15so43387ead.24
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 11:42:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s42si1426909eew.140.2013.12.18.11.42.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 11:42:05 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/6] Configurable fair allocation zone policy v4
Date: Wed, 18 Dec 2013 19:41:57 +0000
Message-Id: <1387395723-25391-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This is still a work in progress. I know Johannes is maintaining his own
patch which takes a different approach and has different priorities. Michal
Hocko has raised concerns potentially affecting both. I'm releasing this so
there is a basis of comparison with Johannes' patch. It's not necessarily
the final shape of what we want to merge but the test results highlight
the current behaviour has regressed performance for basic workloads.

A big concern is the semantics and tradeoffs of the tunable are quite
involved.  Basically no matter what workload you get right, there will be
a workload that will be wrong. This might indicate that this really needs
to be controlled via memory policies or some means of detecting online
which policy should be used on a per-process basis.

By default, this series does *not* interleave pagecache across nodes but
it will interleave between local zones.

Changelog since V3
o Add documentation
o Bring tunable in line with Johannes
o Common code when deciding to update the batch count and skip zones

Changelog since v2
o Drop an accounting patch, behaviour is deliberate
o Special case tmpfs and shmem pages for discussion

Changelog since v1
o Fix lot of brain damage in the configurable policy patch
o Yoink a page cache annotation patch
o Only account batch pages against allocations eligible for the fair policy
o Add patch that default distributes file pages on remote nodes

Commit 81c0a2bb ("mm: page_alloc: fair zone allocator policy") solved a
bug whereby new pages could be reclaimed before old pages because of how
the page allocator and kswapd interacted on the per-zone LRU lists.

Unfortunately a side-effect missed during review was that it's now very
easy to allocate remote memory on NUMA machines. The problem is that
it is not a simple case of just restoring local allocation policies as
there are genuine reasons why global page aging may be prefereable. It's
still a major change to default behaviour so this patch makes the policy
configurable and sets what I think is a sensible default.

The patches are on top of some NUMA balancing patches currently in -mm.

3.13-rc3	 vanilla
instrument-v4	 NUMA balancing patches currently in mmotm
configuratble-v4 This series

Benchmarks are just on some basic workloads, the simple stuff we normally
expect to get right.

kernbench
                          3.13.0-rc3            3.13.0-rc3            3.13.0-rc3
                             vanilla       instrument-v4r1    configurable-v4r13
User    min        1417.32 (  0.00%)     1410.24 (  0.50%)     1410.78 (  0.46%)
User    mean       1419.10 (  0.00%)     1416.85 (  0.16%)     1412.68 (  0.45%)
User    stddev        2.25 (  0.00%)        4.51 (-100.53%)        1.03 ( 54.04%)
User    max        1422.92 (  0.00%)     1420.94 (  0.14%)     1413.68 (  0.65%)
User    range         5.60 (  0.00%)       10.70 (-91.07%)        2.90 ( 48.21%)
System  min         114.83 (  0.00%)      114.40 (  0.37%)      111.02 (  3.32%)
System  mean        115.89 (  0.00%)      116.25 ( -0.31%)      111.97 (  3.38%)
System  stddev        0.63 (  0.00%)        0.95 (-49.62%)        0.72 (-13.87%)
System  max         116.81 (  0.00%)      116.90 ( -0.08%)      113.15 (  3.13%)
System  range         1.98 (  0.00%)        2.50 (-26.26%)        2.13 ( -7.58%)
Elapsed min          42.90 (  0.00%)       43.23 ( -0.77%)       43.07 ( -0.40%)
Elapsed mean         43.58 (  0.00%)       44.09 ( -1.17%)       43.85 ( -0.62%)
Elapsed stddev        0.74 (  0.00%)        0.53 ( 28.21%)        0.41 ( 44.30%)
Elapsed max          44.52 (  0.00%)       44.67 ( -0.34%)       44.25 (  0.61%)
Elapsed range         1.62 (  0.00%)        1.44 ( 11.11%)        1.18 ( 27.16%)
CPU     min        3451.00 (  0.00%)     3434.00 (  0.49%)     3440.00 (  0.32%)
CPU     mean       3522.40 (  0.00%)     3477.20 (  1.28%)     3476.40 (  1.31%)
CPU     stddev       54.34 (  0.00%)       50.01 (  7.98%)       35.54 ( 34.59%)
CPU     max        3570.00 (  0.00%)     3556.00 (  0.39%)     3542.00 (  0.78%)
CPU     range       119.00 (  0.00%)      122.00 ( -2.52%)      102.00 ( 14.29%)

          3.13.0-rc3  3.13.0-rc3  3.13.0-rc3
             vanillainstrument-v4r1configurable-v4r13
User         8540.49     8519.33     8500.40
System        706.31      708.21      682.39
Elapsed       307.58      312.84      308.71

Elapsed time is roughly flat but there is a big reduction in system CPU time. Page
allocation is a smallish component of this workload but the cost of zeroing remote
pages still hurts. 


                            3.13.0-rc3  3.13.0-rc3  3.13.0-rc3
                               vanillainstrument-v4r1configurable-v4r13
NUMA alloc hit                73783951    73924585    93533721
NUMA alloc miss               20013534    19894773           0
NUMA interleave hit                  0           0           0
NUMA alloc local              73783935    73924577    93533714
NUMA page range updates        5933989     5922672     5903323
NUMA huge PMD updates               89         117         184
NUMA PTE updates               5888510     5862885     5809299
NUMA hint faults               2436205     2420282     2384045
NUMA hint local faults         1877025     1814204     2182988
NUMA hint local percent             77          74          91
NUMA pages migrated             457186      480840      198041
AutoNUMA cost                    12231       12152       11965

Note that NUMA alloc misses are reduced to 0. This is consistent throughout for all
benchmarks so I will not mention it again.

It is interesting to note the NUMA hinting faults that were local. It's increased
quite a lot by just allocating the memory local.

While the original intent of the patch was to improve caching when the
workload consumes all of memory, it's worth remembering that some workloads
can be kept cache hot on local nodes.

vmr-stream
                          3.13.0-rc3           3.13.0-rc3           3.13.0-rc3
                            vanilla        instrument-v4r1     configurable-v4r13
Add      5M        3809.80 (  0.00%)     3803.54 ( -0.16%)     3985.49 (  4.61%)
Copy     5M        3360.75 (  0.00%)     3367.38 (  0.20%)     3473.86 (  3.37%)
Scale    5M        3160.39 (  0.00%)     3160.14 ( -0.01%)     3392.39 (  7.34%)
Triad    5M        3533.04 (  0.00%)     3529.78 ( -0.09%)     3851.26 (  9.01%)
Add      7M        3789.82 (  0.00%)     3796.19 (  0.17%)     4004.91 (  5.68%)
Copy     7M        3345.85 (  0.00%)     3368.66 (  0.68%)     3478.26 (  3.96%)
Scale    7M        3176.00 (  0.00%)     3173.44 ( -0.08%)     3393.89 (  6.86%)
Triad    7M        3528.85 (  0.00%)     3531.91 (  0.09%)     3856.74 (  9.29%)
Add      8M        3801.60 (  0.00%)     3774.43 ( -0.71%)     3995.96 (  5.11%)
Copy     8M        3364.64 (  0.00%)     3345.99 ( -0.55%)     3478.86 (  3.39%)
Scale    8M        3169.34 (  0.00%)     3146.35 ( -0.73%)     3396.65 (  7.17%)
Triad    8M        3531.38 (  0.00%)     3509.46 ( -0.62%)     3857.63 (  9.24%)
Add      10M       3807.95 (  0.00%)     3808.50 (  0.01%)     3970.14 (  4.26%)
Copy     10M       3365.64 (  0.00%)     3377.66 (  0.36%)     3473.70 (  3.21%)
Scale    10M       3172.71 (  0.00%)     3166.78 ( -0.19%)     3396.09 (  7.04%)
Triad    10M       3536.15 (  0.00%)     3534.14 ( -0.06%)     3857.11 (  9.08%)
Add      14M       3787.56 (  0.00%)     3805.37 (  0.47%)     4002.47 (  5.67%)
Copy     14M       3345.19 (  0.00%)     3359.46 (  0.43%)     3484.76 (  4.17%)
Scale    14M       3154.55 (  0.00%)     3166.89 (  0.39%)     3400.32 (  7.79%)
Triad    14M       3522.09 (  0.00%)     3534.64 (  0.36%)     3864.75 (  9.73%)
Add      17M       3806.34 (  0.00%)     3796.89 ( -0.25%)     3956.47 (  3.94%)
Copy     17M       3368.39 (  0.00%)     3357.90 ( -0.31%)     3469.40 (  3.00%)
Scale    17M       3169.18 (  0.00%)     3168.00 ( -0.04%)     3390.47 (  6.98%)
Triad    17M       3535.05 (  0.00%)     3529.55 ( -0.16%)     3849.59 (  8.90%)
Add      21M       3795.31 (  0.00%)     3788.25 ( -0.19%)     4042.81 (  6.52%)
Copy     21M       3353.43 (  0.00%)     3360.22 (  0.20%)     3486.10 (  3.96%)
Scale    21M       3160.96 (  0.00%)     3164.97 (  0.13%)     3399.16 (  7.54%)
Triad    21M       3530.45 (  0.00%)     3519.72 ( -0.30%)     3860.71 (  9.35%)
Add      28M       3803.11 (  0.00%)     3788.38 ( -0.39%)     3996.59 (  5.09%)
Copy     28M       3361.16 (  0.00%)     3357.71 ( -0.10%)     3477.19 (  3.45%)
Scale    28M       3160.43 (  0.00%)     3155.64 ( -0.15%)     3396.09 (  7.46%)
Triad    28M       3533.66 (  0.00%)     3522.53 ( -0.32%)     3856.54 (  9.14%)
Add      35M       3792.86 (  0.00%)     3803.38 (  0.28%)     3990.04 (  5.20%)
Copy     35M       3344.24 (  0.00%)     3370.46 (  0.78%)     3476.15 (  3.94%)
Scale    35M       3160.14 (  0.00%)     3174.84 (  0.47%)     3397.43 (  7.51%)
Triad    35M       3531.94 (  0.00%)     3534.84 (  0.08%)     3857.45 (  9.22%)
Add      42M       3803.39 (  0.00%)     3790.25 ( -0.35%)     4017.97 (  5.64%)
Copy     42M       3360.64 (  0.00%)     3354.22 ( -0.19%)     3481.62 (  3.60%)
Scale    42M       3158.64 (  0.00%)     3157.63 ( -0.03%)     3397.54 (  7.56%)
Triad    42M       3529.99 (  0.00%)     3523.89 ( -0.17%)     3860.30 (  9.36%)
Add      56M       3778.07 (  0.00%)     3808.17 (  0.80%)     3964.91 (  4.95%)
Copy     56M       3348.68 (  0.00%)     3367.71 (  0.57%)     3470.75 (  3.65%)
Scale    56M       3169.25 (  0.00%)     3168.97 ( -0.01%)     3390.06 (  6.97%)
Triad    56M       3517.62 (  0.00%)     3537.10 (  0.55%)     3849.49 (  9.43%)
Add      71M       3811.71 (  0.00%)     3814.51 (  0.07%)     4002.20 (  5.00%)
Copy     71M       3370.59 (  0.00%)     3369.28 ( -0.04%)     3482.09 (  3.31%)
Scale    71M       3168.70 (  0.00%)     3174.30 (  0.18%)     3401.24 (  7.34%)
Triad    71M       3536.14 (  0.00%)     3538.14 (  0.06%)     3866.68 (  9.35%)
Add      85M       3805.94 (  0.00%)     3794.21 ( -0.31%)     4017.41 (  5.56%)
Copy     85M       3354.76 (  0.00%)     3352.10 ( -0.08%)     3481.19 (  3.77%)
Scale    85M       3162.20 (  0.00%)     3156.13 ( -0.19%)     3397.90 (  7.45%)
Triad    85M       3538.76 (  0.00%)     3529.06 ( -0.27%)     3859.79 (  9.07%)
Add      113M      3803.66 (  0.00%)     3797.09 ( -0.17%)     4024.26 (  5.80%)
Copy     113M      3348.32 (  0.00%)     3361.90 (  0.41%)     3482.30 (  4.00%)
Scale    113M      3177.09 (  0.00%)     3161.76 ( -0.48%)     3396.35 (  6.90%)
Triad    113M      3536.06 (  0.00%)     3527.87 ( -0.23%)     3858.76 (  9.13%)
Add      142M      3814.65 (  0.00%)     3800.76 ( -0.36%)     3971.52 (  4.11%)
Copy     142M      3353.31 (  0.00%)     3355.70 (  0.07%)     3476.61 (  3.68%)
Scale    142M      3186.05 (  0.00%)     3179.90 ( -0.19%)     3393.11 (  6.50%)
Triad    142M      3545.41 (  0.00%)     3537.84 ( -0.21%)     3855.31 (  8.74%)
Add      170M      3787.71 (  0.00%)     3793.38 (  0.15%)     3996.19 (  5.50%)
Copy     170M      3351.50 (  0.00%)     3355.90 (  0.13%)     3479.89 (  3.83%)
Scale    170M      3158.38 (  0.00%)     3162.04 (  0.12%)     3395.01 (  7.49%)
Triad    170M      3521.84 (  0.00%)     3524.25 (  0.07%)     3856.88 (  9.51%)
Add      227M      3794.46 (  0.00%)     3727.56 ( -1.76%)     3985.47 (  5.03%)
Copy     227M      3368.15 (  0.00%)     3277.24 ( -2.70%)     3471.96 (  3.08%)
Scale    227M      3160.18 (  0.00%)     3091.04 ( -2.19%)     3391.20 (  7.31%)
Triad    227M      3525.39 (  0.00%)     3494.23 ( -0.88%)     3850.97 (  9.24%)
Add      284M      3804.29 (  0.00%)     3810.34 (  0.16%)     3945.32 (  3.71%)
Copy     284M      3366.21 (  0.00%)     3349.90 ( -0.48%)     3464.13 (  2.91%)
Scale    284M      3174.61 (  0.00%)     3164.87 ( -0.31%)     3388.84 (  6.75%)
Triad    284M      3538.50 (  0.00%)     3541.71 (  0.09%)     3846.27 (  8.70%)
Add      341M      3805.26 (  0.00%)     3803.54 ( -0.05%)     4043.00 (  6.25%)
Copy     341M      3366.98 (  0.00%)     3357.66 ( -0.28%)     3485.41 (  3.52%)
Scale    341M      3159.11 (  0.00%)     3171.15 (  0.38%)     3401.61 (  7.68%)
Triad    341M      3530.80 (  0.00%)     3536.21 (  0.15%)     3863.89 (  9.43%)
Add      455M      3791.15 (  0.00%)     3781.78 ( -0.25%)     4002.92 (  5.59%)
Copy     455M      3353.30 (  0.00%)     3341.88 ( -0.34%)     3477.74 (  3.71%)
Scale    455M      3161.21 (  0.00%)     3157.15 ( -0.13%)     3395.44 (  7.41%)
Triad    455M      3527.90 (  0.00%)     3522.57 ( -0.15%)     3855.85 (  9.30%)
Add      568M      3779.79 (  0.00%)     3794.61 (  0.39%)     4001.91 (  5.88%)
Copy     568M      3349.93 (  0.00%)     3353.04 (  0.09%)     3483.56 (  3.99%)
Scale    568M      3163.69 (  0.00%)     3156.21 ( -0.24%)     3399.73 (  7.46%)
Triad    568M      3518.65 (  0.00%)     3524.57 (  0.17%)     3863.36 (  9.80%)
Add      682M      3801.06 (  0.00%)     3786.21 ( -0.39%)     3988.66 (  4.94%)
Copy     682M      3363.64 (  0.00%)     3354.10 ( -0.28%)     3478.52 (  3.42%)
Scale    682M      3151.89 (  0.00%)     3161.41 (  0.30%)     3396.46 (  7.76%)
Triad    682M      3528.97 (  0.00%)     3526.30 ( -0.08%)     3858.57 (  9.34%)
Add      910M      3778.97 (  0.00%)     3783.73 (  0.13%)     4015.78 (  6.27%)
Copy     910M      3345.09 (  0.00%)     3354.44 (  0.28%)     3481.58 (  4.08%)
Scale    910M      3164.46 (  0.00%)     3160.67 ( -0.12%)     3398.66 (  7.40%)
Triad    910M      3516.19 (  0.00%)     3525.40 (  0.26%)     3861.40 (  9.82%)
Add      1137M     3812.17 (  0.00%)     3781.70 ( -0.80%)     3992.81 (  4.74%)
Copy     1137M     3367.52 (  0.00%)     3343.53 ( -0.71%)     3477.47 (  3.27%)
Scale    1137M     3158.62 (  0.00%)     3160.31 (  0.05%)     3395.51 (  7.50%)
Triad    1137M     3536.97 (  0.00%)     3517.86 ( -0.54%)     3815.71 (  7.88%)
Add      1365M     3806.51 (  0.00%)     3807.60 (  0.03%)     3983.99 (  4.66%)
Copy     1365M     3360.43 (  0.00%)     3365.77 (  0.16%)     3470.61 (  3.28%)
Scale    1365M     3155.95 (  0.00%)     3160.24 (  0.14%)     3393.61 (  7.53%)
Triad    1365M     3534.18 (  0.00%)     3533.07 ( -0.03%)     3853.01 (  9.02%)
Add      1820M     3797.86 (  0.00%)     3804.61 (  0.18%)     4000.76 (  5.34%)
Copy     1820M     3362.09 (  0.00%)     3356.15 ( -0.18%)     3483.01 (  3.60%)
Scale    1820M     3170.20 (  0.00%)     3169.60 ( -0.02%)     3403.05 (  7.34%)
Triad    1820M     3531.00 (  0.00%)     3538.39 (  0.21%)     3864.64 (  9.45%)
Add      2275M     3810.31 (  0.00%)     3789.25 ( -0.55%)     3995.44 (  4.86%)
Copy     2275M     3373.60 (  0.00%)     3359.38 ( -0.42%)     3478.62 (  3.11%)
Scale    2275M     3174.64 (  0.00%)     3170.69 ( -0.12%)     3395.45 (  6.96%)
Triad    2275M     3537.57 (  0.00%)     3525.99 ( -0.33%)     3855.61 (  8.99%)
Add      2730M     3801.09 (  0.00%)     3792.84 ( -0.22%)     3961.20 (  4.21%)
Copy     2730M     3357.18 (  0.00%)     3346.35 ( -0.32%)     3457.14 (  2.98%)
Scale    2730M     3177.66 (  0.00%)     3172.64 ( -0.16%)     3371.72 (  6.11%)
Triad    2730M     3539.59 (  0.00%)     3527.66 ( -0.34%)     3824.14 (  8.04%)
Add      3640M     3816.88 (  0.00%)     3789.31 ( -0.72%)     4004.54 (  4.92%)
Copy     3640M     3375.91 (  0.00%)     3356.54 ( -0.57%)     3477.94 (  3.02%)
Scale    3640M     3167.22 (  0.00%)     3150.31 ( -0.53%)     3394.38 (  7.17%)
Triad    3640M     3546.45 (  0.00%)     3524.38 ( -0.62%)     3854.74 (  8.69%)
Add      4551M     3799.05 (  0.00%)     3784.66 ( -0.38%)     3974.45 (  4.62%)
Copy     4551M     3355.66 (  0.00%)     3351.35 ( -0.13%)     3471.85 (  3.46%)
Scale    4551M     3171.91 (  0.00%)     3160.79 ( -0.35%)     3393.06 (  6.97%)
Triad    4551M     3531.61 (  0.00%)     3518.76 ( -0.36%)     3855.49 (  9.17%)
Add      5461M     3801.60 (  0.00%)     3797.07 ( -0.12%)     3996.19 (  5.12%)
Copy     5461M     3360.29 (  0.00%)     3352.70 ( -0.23%)     3479.24 (  3.54%)
Scale    5461M     3161.18 (  0.00%)     3162.49 (  0.04%)     3396.26 (  7.44%)
Triad    5461M     3532.35 (  0.00%)     3529.30 ( -0.09%)     3853.59 (  9.09%)
Add      7281M     3800.80 (  0.00%)     3790.72 ( -0.27%)     3995.88 (  5.13%)
Copy     7281M     3359.99 (  0.00%)     3345.74 ( -0.42%)     3478.84 (  3.54%)
Scale    7281M     3168.68 (  0.00%)     3146.70 ( -0.69%)     3395.73 (  7.17%)
Triad    7281M     3533.59 (  0.00%)     3520.89 ( -0.36%)     3856.70 (  9.14%)
Add      9102M     3790.67 (  0.00%)     3797.54 (  0.18%)     4002.46 (  5.59%)
Copy     9102M     3345.80 (  0.00%)     3348.46 (  0.08%)     3481.31 (  4.05%)
Scale    9102M     3174.65 (  0.00%)     3161.95 ( -0.40%)     3401.10 (  7.13%)
Triad    9102M     3529.51 (  0.00%)     3529.58 (  0.00%)     3864.64 (  9.49%)
Add      10922M     3807.96 (  0.00%)     3796.07 ( -0.31%)     3947.40 (  3.66%)
Copy     10922M     3350.99 (  0.00%)     3357.85 (  0.20%)     3434.74 (  2.50%)
Scale    10922M     3164.74 (  0.00%)     3157.76 ( -0.22%)     3351.72 (  5.91%)
Triad    10922M     3536.69 (  0.00%)     3535.49 ( -0.03%)     3797.59 (  7.38%)
Add      14563M     3786.28 (  0.00%)     3809.36 (  0.61%)     4003.59 (  5.74%)
Copy     14563M     3352.51 (  0.00%)     3371.05 (  0.55%)     3477.73 (  3.73%)
Scale    14563M     3171.95 (  0.00%)     3175.20 (  0.10%)     3394.29 (  7.01%)
Triad    14563M     3522.50 (  0.00%)     3542.29 (  0.56%)     3854.10 (  9.41%)
Add      18204M     3809.56 (  0.00%)     3798.86 ( -0.28%)     3966.36 (  4.12%)
Copy     18204M     3365.06 (  0.00%)     3351.54 ( -0.40%)     3467.60 (  3.05%)
Scale    18204M     3171.25 (  0.00%)     3162.93 ( -0.26%)     3388.46 (  6.85%)
Triad    18204M     3539.90 (  0.00%)     3531.01 ( -0.25%)     3848.78 (  8.73%)
Add      21845M     3798.46 (  0.00%)     3796.16 ( -0.06%)     4024.09 (  5.94%)
Copy     21845M     3362.14 (  0.00%)     3365.10 (  0.09%)     3481.89 (  3.56%)
Scale    21845M     3170.99 (  0.00%)     3152.22 ( -0.59%)     3396.85 (  7.12%)
Triad    21845M     3534.49 (  0.00%)     3528.31 ( -0.17%)     3859.74 (  9.20%)
Add      29127M     3819.69 (  0.00%)     3794.61 ( -0.66%)     3958.76 (  3.64%)
Copy     29127M     3384.67 (  0.00%)     3364.16 ( -0.61%)     3461.19 (  2.26%)
Scale    29127M     3158.68 (  0.00%)     3155.56 ( -0.10%)     3377.98 (  6.94%)
Triad    29127M     3538.17 (  0.00%)     3525.06 ( -0.37%)     3833.34 (  8.34%)
Add      36408M     3806.95 (  0.00%)     3793.50 ( -0.35%)     3980.34 (  4.55%)
Copy     36408M     3361.11 (  0.00%)     3359.84 ( -0.04%)     3477.96 (  3.48%)
Scale    36408M     3165.87 (  0.00%)     3161.61 ( -0.13%)     3398.84 (  7.36%)
Triad    36408M     3536.86 (  0.00%)     3530.39 ( -0.18%)     3862.01 (  9.19%)
Add      43690M     3799.39 (  0.00%)     3799.45 (  0.00%)     4021.62 (  5.85%)
Copy     43690M     3359.26 (  0.00%)     3355.00 ( -0.13%)     3481.97 (  3.65%)
Scale    43690M     3175.35 (  0.00%)     3167.00 ( -0.26%)     3398.43 (  7.03%)
Triad    43690M     3535.26 (  0.00%)     3533.82 ( -0.04%)     3858.45 (  9.14%)
Add      58254M     3799.66 (  0.00%)     3788.90 ( -0.28%)     3986.25 (  4.91%)
Copy     58254M     3355.12 (  0.00%)     3348.89 ( -0.19%)     3473.90 (  3.54%)
Scale    58254M     3170.94 (  0.00%)     3148.96 ( -0.69%)     3392.93 (  7.00%)
Triad    58254M     3537.26 (  0.00%)     3519.99 ( -0.49%)     3853.76 (  8.95%)
Add      72817M     3815.26 (  0.00%)     3801.86 ( -0.35%)     4011.21 (  5.14%)
Copy     72817M     3362.18 (  0.00%)     3363.51 (  0.04%)     3478.56 (  3.46%)
Scale    72817M     3175.73 (  0.00%)     3162.25 ( -0.42%)     3392.44 (  6.82%)
Triad    72817M     3546.44 (  0.00%)     3534.43 ( -0.34%)     3851.14 (  8.59%)
Add      87381M     3519.93 (  0.00%)     3515.94 ( -0.11%)     3838.55 (  9.05%)
Copy     87381M     3175.29 (  0.00%)     3182.78 (  0.24%)     3262.29 (  2.74%)
Scale    87381M     2848.76 (  0.00%)     2836.37 ( -0.43%)     3172.85 ( 11.38%)
Triad    87381M     3465.19 (  0.00%)     3463.32 ( -0.05%)     3773.55 (  8.90%)

          3.13.0-rc3  3.13.0-rc3  3.13.0-rc3
             vanillainstrument-v4r1configurable-v4r13
User         1144.35     1154.47     1086.52
System         55.28       56.98       49.29
E lapsed      1207.64     1220.98     1145.16

This is a memory streaming benchmark. It benefits heavily from using local memory
so there are fairly sizable gains throughout.

                            3.13.0-rc3  3.13.0-rc3  3.13.0-rc3
                               vanillainstrument-v4r1configurable-v4r13
NUMA alloc hit                 1238820     1341467     2102140
NUMA alloc miss                 691541      787339           0
NUMA interleave hit                  0           0           0
NUMA alloc local               1238815     1341465     2102133
NUMA page range updates       24916702    24981923    24979446
NUMA huge PMD updates            48025       48138       48138
NUMA PTE updates                375927      383405      380928
NUMA hint faults                373397      380787      378304
NUMA hint local faults          142051      133068      368551
NUMA hint local percent             38          34          97
NUMA pages migrated              83407      105492       12060
AutoNUMA cost                     2042        2080        2066

Similarly the NUMA hinting faults were mostly local

pft
                        3.13.0-rc3            3.13.0-rc3            3.13.0-rc3
                           vanilla       instrument-v4r1    configurable-v4r13
User       1       0.6980 (  0.00%)       0.6830 (  2.15%)       0.6830 (  2.15%)
User       2       0.7040 (  0.00%)       0.7220 ( -2.56%)       0.7260 ( -3.12%)
User       3       0.6910 (  0.00%)       0.7200 ( -4.20%)       0.6800 (  1.59%)
User       4       0.7250 (  0.00%)       0.7290 ( -0.55%)       0.7370 ( -1.66%)
User       5       0.7590 (  0.00%)       0.7810 ( -2.90%)       0.7520 (  0.92%)
User       6       0.8130 (  0.00%)       0.8130 (  0.00%)       0.7400 (  8.98%)
User       7       0.8210 (  0.00%)       0.7990 (  2.68%)       0.7960 (  3.05%)
User       8       0.8390 (  0.00%)       0.8110 (  3.34%)       0.8020 (  4.41%)
System     1       9.1230 (  0.00%)       9.1630 ( -0.44%)       8.2640 (  9.42%)
System     2       9.3990 (  0.00%)       9.3730 (  0.28%)       8.4570 ( 10.02%)
System     3       9.1460 (  0.00%)       9.1070 (  0.43%)       8.6270 (  5.67%)
System     4       8.9160 (  0.00%)       8.7960 (  1.35%)       8.7380 (  2.00%)
System     5       9.5900 (  0.00%)       9.5420 (  0.50%)       8.9600 (  6.57%)
System     6       9.8640 (  0.00%)       9.8200 (  0.45%)       9.2530 (  6.19%)
System     7       9.9860 (  0.00%)       9.8140 (  1.72%)       9.3720 (  6.15%)
System     8       9.8570 (  0.00%)       9.8380 (  0.19%)       9.2860 (  5.79%)
Elapsed    1       9.8240 (  0.00%)       9.8500 ( -0.26%)       8.9530 (  8.87%)
Elapsed    2       5.0870 (  0.00%)       5.0670 (  0.39%)       4.6120 (  9.34%)
Elapsed    3       3.3220 (  0.00%)       3.3070 (  0.45%)       3.1320 (  5.72%)
Elapsed    4       2.4440 (  0.00%)       2.4080 (  1.47%)       2.4030 (  1.68%)
Elapsed    5       2.1500 (  0.00%)       2.1550 ( -0.23%)       1.9970 (  7.12%)
Elapsed    6       1.8290 (  0.00%)       1.8230 (  0.33%)       1.7040 (  6.83%)
Elapsed    7       1.5760 (  0.00%)       1.5470 (  1.84%)       1.4910 (  5.39%)
Elapsed    8       1.3660 (  0.00%)       1.3440 (  1.61%)       1.2830 (  6.08%)
Faults/cpu 1  336505.5875 (  0.00%)  335646.1191 ( -0.26%)  369269.9491 (  9.74%)
Faults/cpu 2  327139.2186 (  0.00%)  327337.4309 (  0.06%)  359879.3760 ( 10.01%)
Faults/cpu 3  336004.1324 (  0.00%)  336283.8915 (  0.08%)  355077.6062 (  5.68%)
Faults/cpu 4  342824.1564 (  0.00%)  346956.7616 (  1.21%)  348805.5389 (  1.74%)
Faults/cpu 5  319553.7707 (  0.00%)  320266.6891 (  0.22%)  340232.2510 (  6.47%)
Faults/cpu 6  309614.5554 (  0.00%)  310923.0881 (  0.42%)  330752.5617 (  6.83%)
Faults/cpu 7  306159.2969 (  0.00%)  311474.2294 (  1.74%)  325141.8868 (  6.20%)
Faults/cpu 8  309077.4966 (  0.00%)  310491.4673 (  0.46%)  327802.7845 (  6.06%)
Faults/sec 1  336364.5575 (  0.00%)  335493.4899 ( -0.26%)  369125.5968 (  9.74%)
Faults/sec 2  649713.2290 (  0.00%)  652201.7336 (  0.38%)  716621.5272 ( 10.30%)
Faults/sec 3  994812.3119 (  0.00%)  999330.4234 (  0.45%) 1055728.0701 (  6.12%)
Faults/sec 4 1352137.4832 (  0.00%) 1372667.4485 (  1.52%) 1375014.2113 (  1.69%)
Faults/sec 5 1538115.0421 (  0.00%) 1533647.8496 ( -0.29%) 1654330.8228 (  7.56%)
Faults/sec 6 1807211.7324 (  0.00%) 1814037.7599 (  0.38%) 1940810.7735 (  7.39%)
Faults/sec 7 2101840.1872 (  0.00%) 2132966.7624 (  1.48%) 2220066.9942 (  5.62%)
Faults/sec 8 2421813.7208 (  0.00%) 2458797.5104 (  1.53%) 2580986.1397 (  6.57%)

This is page fault microbenchmark. Again, heavy gains from having local memory.

          3.13.0-rc3  3.13.0-rc3  3.13.0-rc3
             vanillainstrument-v4r1configurable-v4r13
User           60.57       61.53       60.20
System        868.16      861.36      809.22
Elapsed       336.19      335.31      315.19

And big reduction in system CPU time.

                            3.13.0-rc3  3.13.0-rc3  3.13.0-rc3
                               vanillainstrument-v4r1configurable-v4r13
NUMA alloc hit               187243902   187334720   264999707
NUMA alloc miss               77736695    77665156           0
NUMA interleave hit                  0           0           0
NUMA alloc local             187243902   187334720   264999706
NUMA page range updates      136246380   134086920   124386461
NUMA huge PMD updates                0           0           0
NUMA PTE updates             136246380   134086920   124386461
NUMA hint faults                   512         804         524
NUMA hint local faults             248         339         349
NUMA hint local percent             48          42          66
NUMA pages migrated                169          53         115
AutoNUMA cost                      956         942         873

NUMA hinting faults were not as local as I'd hope but it's a separate issue.

ebizzy
                     3.13.0-rc3            3.13.0-rc3            3.13.0-rc3
                        vanilla       instrument-v4r1    configurable-v4r13
Mean   1      3213.33 (  0.00%)     3170.67 ( -1.33%)     3215.33 (  0.06%)
Mean   2      2291.33 (  0.00%)     2310.00 (  0.81%)     2364.00 (  3.17%)
Mean   3      2234.67 (  0.00%)     2300.33 (  2.94%)     2289.00 (  2.43%)
Mean   4      2224.33 (  0.00%)     2237.00 (  0.57%)     2238.00 (  0.61%)
Mean   5      2256.33 (  0.00%)     2249.00 ( -0.33%)     2319.67 (  2.81%)
Mean   6      2233.00 (  0.00%)     2253.67 (  0.93%)     2228.67 ( -0.19%)
Mean   7      2212.33 (  0.00%)     2258.33 (  2.08%)     2237.00 (  1.11%)
Mean   8      2224.67 (  0.00%)     2232.33 (  0.34%)     2235.33 (  0.48%)
Mean   12     2213.33 (  0.00%)     2223.33 (  0.45%)     2230.00 (  0.75%)
Mean   16     2221.00 (  0.00%)     2247.67 (  1.20%)     2237.00 (  0.72%)
Mean   20     2215.00 (  0.00%)     2247.33 (  1.46%)     2244.33 (  1.32%)
Mean   24     2175.00 (  0.00%)     2181.00 (  0.28%)     2225.00 (  2.30%)
Mean   28     2110.00 (  0.00%)     2156.67 (  2.21%)     2140.33 (  1.44%)
Mean   32     2077.67 (  0.00%)     2081.33 (  0.18%)     2092.33 (  0.71%)
Mean   36     2016.33 (  0.00%)     2042.67 (  1.31%)     2086.33 (  3.47%)
Mean   40     1984.00 (  0.00%)     1988.00 (  0.20%)     2032.67 (  2.45%)
Mean   44     1943.33 (  0.00%)     1960.00 (  0.86%)     1993.33 (  2.57%)
Mean   48     1925.00 (  0.00%)     1935.00 (  0.52%)     1990.67 (  3.41%)
Range  1        62.00 (  0.00%)       74.00 (-19.35%)       59.00 (  4.84%)
Range  2        70.00 (  0.00%)       32.00 ( 54.29%)      146.00 (-108.57%)
Range  3        39.00 (  0.00%)       48.00 (-23.08%)       70.00 (-79.49%)
Range  4       100.00 (  0.00%)      127.00 (-27.00%)       74.00 ( 26.00%)
Range  5        65.00 (  0.00%)       52.00 ( 20.00%)      100.00 (-53.85%)
Range  6        25.00 (  0.00%)       17.00 ( 32.00%)       81.00 (-224.00%)
Range  7        55.00 (  0.00%)       19.00 ( 65.45%)       44.00 ( 20.00%)
Range  8         9.00 (  0.00%)       43.00 (-377.78%)       15.00 (-66.67%)
Range  12       52.00 (  0.00%)       10.00 ( 80.77%)       22.00 ( 57.69%)
Range  16       47.00 (  0.00%)       55.00 (-17.02%)       28.00 ( 40.43%)
Range  20        9.00 (  0.00%)       68.00 (-655.56%)       27.00 (-200.00%)
Range  24       44.00 (  0.00%)       81.00 (-84.09%)       54.00 (-22.73%)
Range  28       28.00 (  0.00%)       46.00 (-64.29%)       80.00 (-185.71%)
Range  32       23.00 (  0.00%)       22.00 (  4.35%)       11.00 ( 52.17%)
Range  36        9.00 (  0.00%)       20.00 (-122.22%)       75.00 (-733.33%)
Range  40       31.00 (  0.00%)        5.00 ( 83.87%)       10.00 ( 67.74%)
Range  44       16.00 (  0.00%)       15.00 (  6.25%)       18.00 (-12.50%)
Range  48        7.00 (  0.00%)       18.00 (-157.14%)       16.00 (-128.57%)
Stddev 1        25.42 (  0.00%)       30.83 (-21.26%)       24.50 (  3.62%)
Stddev 2        29.68 (  0.00%)       13.37 ( 54.96%)       61.26 (-106.40%)
Stddev 3        18.15 (  0.00%)       19.87 ( -9.46%)       28.89 (-59.14%)
Stddev 4        41.28 (  0.00%)       55.76 (-35.06%)       34.65 ( 16.06%)
Stddev 5        27.18 (  0.00%)       21.65 ( 20.36%)       44.03 (-61.99%)
Stddev 6        10.80 (  0.00%)        7.04 ( 34.83%)       37.28 (-245.12%)
Stddev 7        23.10 (  0.00%)        8.73 ( 62.20%)       18.02 ( 21.99%)
Stddev 8         3.68 (  0.00%)       19.60 (-432.39%)        6.13 (-66.45%)
Stddev 12       23.84 (  0.00%)        4.19 ( 82.42%)        9.93 ( 58.33%)
Stddev 16       20.22 (  0.00%)       23.47 (-16.10%)       11.52 ( 43.02%)
Stddev 20        3.74 (  0.00%)       27.86 (-644.61%)       11.15 (-197.88%)
Stddev 24       18.18 (  0.00%)       35.19 (-93.49%)       22.23 (-22.23%)
Stddev 28       11.78 (  0.00%)       20.81 (-76.69%)       32.66 (-177.38%)
Stddev 32        9.74 (  0.00%)        9.74 (  0.00%)        4.64 ( 52.34%)
Stddev 36        3.86 (  0.00%)        8.99 (-133.08%)       33.83 (-776.65%)
Stddev 40       14.17 (  0.00%)        2.16 ( 84.75%)        4.19 ( 70.42%)
Stddev 44        7.54 (  0.00%)        7.07 (  6.25%)        8.26 ( -9.51%)
Stddev 48        2.94 (  0.00%)        7.48 (-154.20%)        6.94 (-135.88%)

Performance is only slightly improved here, it's doing a lot of remote copies
anyway as a side-effect of the type of workload it is. There is high spread
on the performance of individual threads but that bug is known and being handled
elsewhere.

          3.13.0-rc3  3.13.0-rc3  3.13.0-rc3
             vanillainstrument-v4r1configurable-v4r13
User          491.24      494.38      500.23
System        874.62      874.43      870.83
Elapsed      1082.00     1082.29     1082.14

                            3.13.0-rc3  3.13.0-rc3  3.13.0-rc3
                               vanillainstrument-v4r1configurable-v4r13
NUMA alloc hit               238904205   238016877   315741530
NUMA alloc miss               71969773    75135651           0
NUMA interleave hit                  0           0           0
NUMA alloc local             238904198   238016873   315741524
NUMA page range updates         157577      171845      163950
NUMA huge PMD updates               33          38          17
NUMA PTE updates                140714      152427      155263
NUMA hint faults                 39395       60301       56019
NUMA hint local faults           17294       30974       33723
NUMA hint local percent             43          51          60
NUMA pages migrated               7183        8818       11221
AutoNUMA cost                      198         302         281

Local hinting is not great again but the workload is doing a lot of remote
references so it's somewhat expected.

 Documentation/sysctl/vm.txt |  51 +++++++++++++
 include/linux/gfp.h         |   4 +-
 include/linux/mmzone.h      |   2 +
 include/linux/pagemap.h     |   2 +-
 include/linux/swap.h        |   1 +
 kernel/sysctl.c             |   8 ++
 mm/filemap.c                |   3 +-
 mm/page_alloc.c             | 182 ++++++++++++++++++++++++++++++++++++++------
 mm/shmem.c                  |  14 ++++
 9 files changed, 239 insertions(+), 28 deletions(-)

-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
