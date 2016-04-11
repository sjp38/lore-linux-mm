Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id F07756B025E
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:13:52 -0400 (EDT)
Received: by mail-wm0-f48.google.com with SMTP id u206so93139008wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:13:52 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id z141si17069786wmc.59.2016.04.11.01.13.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 01:13:51 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id E07D11C1714
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:13:50 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 00/21] Optimise page alloc/free fast paths
Date: Mon, 11 Apr 2016 09:13:23 +0100
Message-Id: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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

                                           4.6.0-rc2                  4.6.0-rc2
                                             vanilla               cpuset-v1r20
Min      alloc-odr0-1               425.00 (  0.00%)           348.00 ( 18.12%)
Min      alloc-odr0-2               313.00 (  0.00%)           254.00 ( 18.85%)
Min      alloc-odr0-4               258.00 (  0.00%)           213.00 ( 17.44%)
Min      alloc-odr0-8               224.00 (  0.00%)           183.00 ( 18.30%)
Min      alloc-odr0-16              207.00 (  0.00%)           171.00 ( 17.39%)
Min      alloc-odr0-32              199.00 (  0.00%)           163.00 ( 18.09%)
Min      alloc-odr0-64              194.00 (  0.00%)           159.00 ( 18.04%)
Min      alloc-odr0-128             192.00 (  0.00%)           157.00 ( 18.23%)
Min      alloc-odr0-256             201.00 (  0.00%)           166.00 ( 17.41%)
Min      alloc-odr0-512             212.00 (  0.00%)           179.00 ( 15.57%)
Min      alloc-odr0-1024            219.00 (  0.00%)           187.00 ( 14.61%)
Min      alloc-odr0-2048            225.00 (  0.00%)           193.00 ( 14.22%)
Min      alloc-odr0-4096            231.00 (  0.00%)           199.00 ( 13.85%)
Min      alloc-odr0-8192            235.00 (  0.00%)           201.00 ( 14.47%)
Min      alloc-odr0-16384           235.00 (  0.00%)           201.00 ( 14.47%)
Min      alloc-odr1-1               539.00 (  0.00%)           449.00 ( 16.70%)
Min      alloc-odr1-2               399.00 (  0.00%)           338.00 ( 15.29%)
Min      alloc-odr1-4               317.00 (  0.00%)           271.00 ( 14.51%)
Min      alloc-odr1-8               276.00 (  0.00%)           236.00 ( 14.49%)
Min      alloc-odr1-16              256.00 (  0.00%)           217.00 ( 15.23%)
Min      alloc-odr1-32              247.00 (  0.00%)           209.00 ( 15.38%)
Min      alloc-odr1-64              242.00 (  0.00%)           205.00 ( 15.29%)
Min      alloc-odr1-128             240.00 (  0.00%)           204.00 ( 15.00%)
Min      alloc-odr1-256             242.00 (  0.00%)           206.00 ( 14.88%)
Min      alloc-odr1-512             243.00 (  0.00%)           207.00 ( 14.81%)
Min      alloc-odr1-1024            248.00 (  0.00%)           212.00 ( 14.52%)
Min      alloc-odr1-2048            253.00 (  0.00%)           221.00 ( 12.65%)
Min      alloc-odr1-4096            258.00 (  0.00%)           224.00 ( 13.18%)
Min      alloc-odr1-8192            262.00 (  0.00%)           224.00 ( 14.50%)
Min      alloc-odr2-1               577.00 (  0.00%)           469.00 ( 18.72%)
Min      alloc-odr2-2               435.00 (  0.00%)           350.00 ( 19.54%)
Min      alloc-odr2-4               346.00 (  0.00%)           282.00 ( 18.50%)
Min      alloc-odr2-8               299.00 (  0.00%)           247.00 ( 17.39%)
Min      alloc-odr2-16              282.00 (  0.00%)           229.00 ( 18.79%)
Min      alloc-odr2-32              269.00 (  0.00%)           221.00 ( 17.84%)
Min      alloc-odr2-64              264.00 (  0.00%)           217.00 ( 17.80%)
Min      alloc-odr2-128             263.00 (  0.00%)           216.00 ( 17.87%)
Min      alloc-odr2-256             264.00 (  0.00%)           217.00 ( 17.80%)
Min      alloc-odr2-512             268.00 (  0.00%)           222.00 ( 17.16%)
Min      alloc-odr2-1024            279.00 (  0.00%)           233.00 ( 16.49%)
Min      alloc-odr2-2048            285.00 (  0.00%)           236.00 ( 17.19%)
Min      alloc-odr2-4096            288.00 (  0.00%)           237.00 ( 17.71%)
Min      alloc-odr3-1               651.00 (  0.00%)           511.00 ( 21.51%)
Min      alloc-odr3-2               487.00 (  0.00%)           380.00 ( 21.97%)
Min      alloc-odr3-4               393.00 (  0.00%)           305.00 ( 22.39%)
Min      alloc-odr3-8               343.00 (  0.00%)           271.00 ( 20.99%)
Min      alloc-odr3-16              322.00 (  0.00%)           252.00 ( 21.74%)
Min      alloc-odr3-32              312.00 (  0.00%)           246.00 ( 21.15%)
Min      alloc-odr3-64              310.00 (  0.00%)           245.00 ( 20.97%)
Min      alloc-odr3-128             312.00 (  0.00%)           246.00 ( 21.15%)
Min      alloc-odr3-256             320.00 (  0.00%)           252.00 ( 21.25%)
Min      alloc-odr3-512             330.00 (  0.00%)           260.00 ( 21.21%)
Min      alloc-odr3-1024            334.00 (  0.00%)           263.00 ( 21.26%)
Min      alloc-odr3-2048            337.00 (  0.00%)           268.00 ( 20.47%)
Min      alloc-odr4-1               804.00 (  0.00%)           585.00 ( 27.24%)
Min      alloc-odr4-2               603.00 (  0.00%)           438.00 ( 27.36%)
Min      alloc-odr4-4               487.00 (  0.00%)           360.00 ( 26.08%)
Min      alloc-odr4-8               433.00 (  0.00%)           322.00 ( 25.64%)
Min      alloc-odr4-16              406.00 (  0.00%)           299.00 ( 26.35%)
Min      alloc-odr4-32              402.00 (  0.00%)           297.00 ( 26.12%)
Min      alloc-odr4-64              401.00 (  0.00%)           297.00 ( 25.94%)
Min      alloc-odr4-128             412.00 (  0.00%)           307.00 ( 25.49%)
Min      alloc-odr4-256             424.00 (  0.00%)           322.00 ( 24.06%)
Min      alloc-odr4-512             431.00 (  0.00%)           330.00 ( 23.43%)
Min      alloc-odr4-1024            435.00 (  0.00%)           330.00 ( 24.14%)
Min      free-odr0-1                214.00 (  0.00%)           189.00 ( 11.68%)
Min      free-odr0-2                152.00 (  0.00%)           136.00 ( 10.53%)
Min      free-odr0-4                120.00 (  0.00%)           107.00 ( 10.83%)
Min      free-odr0-8                105.00 (  0.00%)            96.00 (  8.57%)
Min      free-odr0-16                96.00 (  0.00%)            87.00 (  9.38%)
Min      free-odr0-32                91.00 (  0.00%)            83.00 (  8.79%)
Min      free-odr0-64                89.00 (  0.00%)            81.00 (  8.99%)
Min      free-odr0-128               88.00 (  0.00%)            80.00 (  9.09%)
Min      free-odr0-256              101.00 (  0.00%)            95.00 (  5.94%)
Min      free-odr0-512              117.00 (  0.00%)           112.00 (  4.27%)
Min      free-odr0-1024             125.00 (  0.00%)           118.00 (  5.60%)
Min      free-odr0-2048             131.00 (  0.00%)           124.00 (  5.34%)
Min      free-odr0-4096             136.00 (  0.00%)           129.00 (  5.15%)
Min      free-odr0-8192             137.00 (  0.00%)           129.00 (  5.84%)
Min      free-odr0-16384            137.00 (  0.00%)           129.00 (  5.84%)
Min      free-odr1-1                317.00 (  0.00%)           290.00 (  8.52%)
Min      free-odr1-2                229.00 (  0.00%)           209.00 (  8.73%)
Min      free-odr1-4                185.00 (  0.00%)           166.00 ( 10.27%)
Min      free-odr1-8                165.00 (  0.00%)           149.00 (  9.70%)
Min      free-odr1-16               152.00 (  0.00%)           138.00 (  9.21%)
Min      free-odr1-32               146.00 (  0.00%)           132.00 (  9.59%)
Min      free-odr1-64               146.00 (  0.00%)           131.00 ( 10.27%)
Min      free-odr1-128              147.00 (  0.00%)           137.00 (  6.80%)
Min      free-odr1-256              150.00 (  0.00%)           140.00 (  6.67%)
Min      free-odr1-512              151.00 (  0.00%)           142.00 (  5.96%)
Min      free-odr1-1024             157.00 (  0.00%)           147.00 (  6.37%)
Min      free-odr1-2048             161.00 (  0.00%)           150.00 (  6.83%)
Min      free-odr1-4096             160.00 (  0.00%)           147.00 (  8.12%)
Min      free-odr1-8192             157.00 (  0.00%)           145.00 (  7.64%)
Min      free-odr2-1                357.00 (  0.00%)           311.00 ( 12.89%)
Min      free-odr2-2                257.00 (  0.00%)           222.00 ( 13.62%)
Min      free-odr2-4                211.00 (  0.00%)           185.00 ( 12.32%)
Min      free-odr2-8                189.00 (  0.00%)           161.00 ( 14.81%)
Min      free-odr2-16               176.00 (  0.00%)           150.00 ( 14.77%)
Min      free-odr2-32               171.00 (  0.00%)           145.00 ( 15.20%)
Min      free-odr2-64               170.00 (  0.00%)           149.00 ( 12.35%)
Min      free-odr2-128              170.00 (  0.00%)           152.00 ( 10.59%)
Min      free-odr2-256              172.00 (  0.00%)           155.00 (  9.88%)
Min      free-odr2-512              183.00 (  0.00%)           162.00 ( 11.48%)
Min      free-odr2-1024             188.00 (  0.00%)           168.00 ( 10.64%)
Min      free-odr2-2048             187.00 (  0.00%)           165.00 ( 11.76%)
Min      free-odr2-4096             185.00 (  0.00%)           162.00 ( 12.43%)
Min      free-odr3-1                442.00 (  0.00%)           360.00 ( 18.55%)
Min      free-odr3-2                319.00 (  0.00%)           255.00 ( 20.06%)
Min      free-odr3-4                262.00 (  0.00%)           206.00 ( 21.37%)
Min      free-odr3-8                235.00 (  0.00%)           186.00 ( 20.85%)
Min      free-odr3-16               221.00 (  0.00%)           174.00 ( 21.27%)
Min      free-odr3-32               217.00 (  0.00%)           178.00 ( 17.97%)
Min      free-odr3-64               218.00 (  0.00%)           184.00 ( 15.60%)
Min      free-odr3-128              219.00 (  0.00%)           188.00 ( 14.16%)
Min      free-odr3-256              229.00 (  0.00%)           195.00 ( 14.85%)
Min      free-odr3-512              235.00 (  0.00%)           199.00 ( 15.32%)
Min      free-odr3-1024             234.00 (  0.00%)           199.00 ( 14.96%)
Min      free-odr3-2048             234.00 (  0.00%)           199.00 ( 14.96%)
Min      free-odr4-1                595.00 (  0.00%)           447.00 ( 24.87%)
Min      free-odr4-2                436.00 (  0.00%)           319.00 ( 26.83%)
Min      free-odr4-4                366.00 (  0.00%)           268.00 ( 26.78%)
Min      free-odr4-8                330.00 (  0.00%)           239.00 ( 27.58%)
Min      free-odr4-16               312.00 (  0.00%)           231.00 ( 25.96%)
Min      free-odr4-32               309.00 (  0.00%)           235.00 ( 23.95%)
Min      free-odr4-64               305.00 (  0.00%)           243.00 ( 20.33%)
Min      free-odr4-128              315.00 (  0.00%)           256.00 ( 18.73%)
Min      free-odr4-256              324.00 (  0.00%)           272.00 ( 16.05%)
Min      free-odr4-512              328.00 (  0.00%)           276.00 ( 15.85%)
Min      free-odr4-1024             331.00 (  0.00%)           275.00 ( 16.92%)
Min      total-odr0-1               639.00 (  0.00%)           537.00 ( 15.96%)
Min      total-odr0-2               465.00 (  0.00%)           390.00 ( 16.13%)
Min      total-odr0-4               378.00 (  0.00%)           320.00 ( 15.34%)
Min      total-odr0-8               329.00 (  0.00%)           279.00 ( 15.20%)
Min      total-odr0-16              303.00 (  0.00%)           258.00 ( 14.85%)
Min      total-odr0-32              290.00 (  0.00%)           246.00 ( 15.17%)
Min      total-odr0-64              283.00 (  0.00%)           240.00 ( 15.19%)
Min      total-odr0-128             280.00 (  0.00%)           237.00 ( 15.36%)
Min      total-odr0-256             302.00 (  0.00%)           261.00 ( 13.58%)
Min      total-odr0-512             329.00 (  0.00%)           291.00 ( 11.55%)
Min      total-odr0-1024            344.00 (  0.00%)           305.00 ( 11.34%)
Min      total-odr0-2048            356.00 (  0.00%)           317.00 ( 10.96%)
Min      total-odr0-4096            367.00 (  0.00%)           328.00 ( 10.63%)
Min      total-odr0-8192            372.00 (  0.00%)           330.00 ( 11.29%)
Min      total-odr0-16384           372.00 (  0.00%)           330.00 ( 11.29%)
Min      total-odr1-1               858.00 (  0.00%)           739.00 ( 13.87%)
Min      total-odr1-2               629.00 (  0.00%)           547.00 ( 13.04%)
Min      total-odr1-4               502.00 (  0.00%)           437.00 ( 12.95%)
Min      total-odr1-8               441.00 (  0.00%)           385.00 ( 12.70%)
Min      total-odr1-16              409.00 (  0.00%)           355.00 ( 13.20%)
Min      total-odr1-32              393.00 (  0.00%)           342.00 ( 12.98%)
Min      total-odr1-64              388.00 (  0.00%)           336.00 ( 13.40%)
Min      total-odr1-128             387.00 (  0.00%)           341.00 ( 11.89%)
Min      total-odr1-256             392.00 (  0.00%)           346.00 ( 11.73%)
Min      total-odr1-512             394.00 (  0.00%)           349.00 ( 11.42%)
Min      total-odr1-1024            405.00 (  0.00%)           359.00 ( 11.36%)
Min      total-odr1-2048            414.00 (  0.00%)           371.00 ( 10.39%)
Min      total-odr1-4096            418.00 (  0.00%)           371.00 ( 11.24%)
Min      total-odr1-8192            419.00 (  0.00%)           369.00 ( 11.93%)
Min      total-odr2-1               935.00 (  0.00%)           781.00 ( 16.47%)
Min      total-odr2-2               693.00 (  0.00%)           572.00 ( 17.46%)
Min      total-odr2-4               557.00 (  0.00%)           467.00 ( 16.16%)
Min      total-odr2-8               488.00 (  0.00%)           408.00 ( 16.39%)
Min      total-odr2-16              458.00 (  0.00%)           379.00 ( 17.25%)
Min      total-odr2-32              440.00 (  0.00%)           366.00 ( 16.82%)
Min      total-odr2-64              434.00 (  0.00%)           366.00 ( 15.67%)
Min      total-odr2-128             433.00 (  0.00%)           368.00 ( 15.01%)
Min      total-odr2-256             436.00 (  0.00%)           372.00 ( 14.68%)
Min      total-odr2-512             451.00 (  0.00%)           384.00 ( 14.86%)
Min      total-odr2-1024            467.00 (  0.00%)           401.00 ( 14.13%)
Min      total-odr2-2048            472.00 (  0.00%)           401.00 ( 15.04%)
Min      total-odr2-4096            473.00 (  0.00%)           399.00 ( 15.64%)
Min      total-odr3-1              1093.00 (  0.00%)           871.00 ( 20.31%)
Min      total-odr3-2               807.00 (  0.00%)           635.00 ( 21.31%)
Min      total-odr3-4               655.00 (  0.00%)           511.00 ( 21.98%)
Min      total-odr3-8               578.00 (  0.00%)           457.00 ( 20.93%)
Min      total-odr3-16              543.00 (  0.00%)           426.00 ( 21.55%)
Min      total-odr3-32              529.00 (  0.00%)           424.00 ( 19.85%)
Min      total-odr3-64              528.00 (  0.00%)           429.00 ( 18.75%)
Min      total-odr3-128             531.00 (  0.00%)           434.00 ( 18.27%)
Min      total-odr3-256             549.00 (  0.00%)           448.00 ( 18.40%)
Min      total-odr3-512             566.00 (  0.00%)           459.00 ( 18.90%)
Min      total-odr3-1024            568.00 (  0.00%)           462.00 ( 18.66%)
Min      total-odr3-2048            571.00 (  0.00%)           467.00 ( 18.21%)
Min      total-odr4-1              1399.00 (  0.00%)          1032.00 ( 26.23%)
Min      total-odr4-2              1040.00 (  0.00%)           757.00 ( 27.21%)
Min      total-odr4-4               853.00 (  0.00%)           628.00 ( 26.38%)
Min      total-odr4-8               764.00 (  0.00%)           561.00 ( 26.57%)
Min      total-odr4-16              718.00 (  0.00%)           530.00 ( 26.18%)
Min      total-odr4-32              711.00 (  0.00%)           532.00 ( 25.18%)
Min      total-odr4-64              706.00 (  0.00%)           541.00 ( 23.37%)
Min      total-odr4-128             727.00 (  0.00%)           563.00 ( 22.56%)
Min      total-odr4-256             748.00 (  0.00%)           594.00 ( 20.59%)
Min      total-odr4-512             759.00 (  0.00%)           606.00 ( 20.16%)
Min      total-odr4-1024            766.00 (  0.00%)           605.00 ( 21.02%)

 arch/powerpc/mm/mmu_context_hash64.c         |   2 +-
 arch/powerpc/mm/pgtable_64.c                 |   6 +-
 arch/sparc/mm/init_64.c                      |   2 +-
 arch/tile/mm/homecache.c                     |   2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_cs.c       |   6 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_gem.c      |   2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c      |   2 +-
 drivers/gpu/drm/etnaviv/etnaviv_gem.c        |   6 +-
 drivers/gpu/drm/i915/i915_gem_userptr.c      |   4 +-
 drivers/gpu/drm/radeon/radeon_ttm.c          |   2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |   6 +-
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   2 +-
 drivers/net/ethernet/sfc/rx.c                |   2 +-
 drivers/net/ethernet/ti/netcp_core.c         |   2 +-
 drivers/net/virtio_net.c                     |   1 -
 fs/9p/cache.c                                |   2 +-
 fs/afs/cache.c                               |   2 +-
 fs/btrfs/extent_io.c                         |   4 +-
 fs/buffer.c                                  |  10 +-
 fs/cachefiles/rdwr.c                         |   6 +-
 fs/ceph/addr.c                               |   4 +-
 fs/ceph/cache.c                              |   2 +-
 fs/cifs/cache.c                              |   2 +-
 fs/dax.c                                     |   2 +-
 fs/ext4/file.c                               |   2 +-
 fs/ext4/inode.c                              |   6 +-
 fs/f2fs/checkpoint.c                         |   2 +-
 fs/f2fs/data.c                               |   2 +-
 fs/f2fs/file.c                               |   2 +-
 fs/f2fs/node.c                               |   4 +-
 fs/fscache/page.c                            |   2 +-
 fs/fuse/dev.c                                |   2 +-
 fs/gfs2/aops.c                               |   2 +-
 fs/hugetlbfs/inode.c                         |   2 +-
 fs/nfs/fscache-index.c                       |   2 +-
 fs/nilfs2/btree.c                            |   2 +-
 fs/nilfs2/page.c                             |   8 +-
 fs/nilfs2/segment.c                          |   4 +-
 fs/ubifs/file.c                              |   2 +-
 fs/xfs/xfs_file.c                            |   2 +-
 include/linux/compaction.h                   |   6 +-
 include/linux/cpuset.h                       |  42 ++--
 include/linux/gfp.h                          |   9 +-
 include/linux/mm.h                           |   5 +-
 include/linux/mmzone.h                       |  34 ++-
 include/linux/page-flags.h                   |   7 +-
 include/linux/pagemap.h                      |   6 +-
 include/linux/pagevec.h                      |   8 +-
 include/linux/skbuff.h                       |   2 +-
 include/linux/slab.h                         |   3 -
 include/linux/swap.h                         |   2 +-
 include/linux/vmstat.h                       |   2 -
 include/trace/events/kmem.h                  |  11 +-
 include/trace/events/mmflags.h               |   1 -
 kernel/cpuset.c                              |  14 +-
 kernel/power/snapshot.c                      |   4 +-
 mm/compaction.c                              |  12 +-
 mm/filemap.c                                 |   6 +-
 mm/internal.h                                |   4 +-
 mm/mempolicy.c                               |  19 +-
 mm/mlock.c                                   |   4 +-
 mm/mmzone.c                                  |   2 +-
 mm/page-writeback.c                          |   2 +-
 mm/page_alloc.c                              | 327 ++++++++++++++++-----------
 mm/percpu-vm.c                               |   2 +-
 mm/rmap.c                                    |   2 +-
 mm/shmem.c                                   |   6 +-
 mm/swap.c                                    |  11 +-
 mm/swap_state.c                              |   2 +-
 mm/truncate.c                                |   6 +-
 mm/vmscan.c                                  |   6 +-
 mm/vmstat.c                                  |  25 --
 net/core/skbuff.c                            |   4 +-
 tools/perf/builtin-kmem.c                    |   1 -
 75 files changed, 388 insertions(+), 338 deletions(-)

-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
