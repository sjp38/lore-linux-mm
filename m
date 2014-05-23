Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id E98FD6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 22:41:52 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so3404850pbc.40
        for <linux-mm@kvack.org>; Thu, 22 May 2014 19:41:52 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id cf5si1918033pbc.10.2014.05.22.19.41.51
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 19:41:51 -0700 (PDT)
Date: Fri, 23 May 2014 10:43:15 +0800
From: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Subject: Re: [PATCH 0/3] Shrinkers and proportional reclaim
Message-ID: <20140523024315.GF25013@yliu-dev.sh.intel.com>
References: <1400749779-24879-1-git-send-email-mgorman@suse.de>
 <20140522161416.GD25013@yliu-dev.sh.intel.com>
 <20140522163051.GJ23991@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140522163051.GJ23991@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Thu, May 22, 2014 at 05:30:51PM +0100, Mel Gorman wrote:
> On Fri, May 23, 2014 at 12:14:16AM +0800, Yuanhan Liu wrote:
> > On Thu, May 22, 2014 at 10:09:36AM +0100, Mel Gorman wrote:
> > > This series is aimed at regressions noticed during reclaim activity. The
> > > first two patches are shrinker patches that were posted ages ago but never
> > > merged for reasons that are unclear to me. I'm posting them again to see if
> > > there was a reason they were dropped or if they just got lost. Dave?  Time?
> > > The last patch adjusts proportional reclaim. Yuanhan Liu, can you retest
> > > the vm scalability test cases on a larger machine? Hugh, does this work
> > > for you on the memcg test cases?
> > 
> > Sure, and here is the result. I applied these 3 patches on v3.15-rc6,
> > and head commit is 60c10afd. e82e0561 is the old commit that introduced
> > the regression.  The testserver has 512G memory and 120 CPU.
> > 
> > It's a simple result; if you need more data, I can gather them and send
> > it to you tomorrow:
> > 
> > e82e0561        v3.15-rc6       60c10afd
> > ----------------------------------------
> > 18560785        12232122        38868453
> >                 -34%            +109
> > 
> > As you can see, the performance is back, and it is way much better ;)
> > 
> 
> Thanks a lot for that and the quick response. It is much appreciated.

Welcome! And sorry that I made a silly mistake. Those numbers are right
though, I just setup wrong compare base; I should compare them with
e82e0561's parent, which is 75485363ce85526 at below table.

Here is the detailed results to compensate the mistake I made ;)

    Legend:
            ~XX%    - stddev percent  (3 runs for each kernel)
            [+-]XX% - change percent


75485363ce85526  e82e0561dae9f3ae5a21fc2d3                  v3.15-rc6  60c10afd233f3344479d229dc  
---------------  -------------------------  -------------------------  -------------------------  
  35979244 ~ 0%     -48.4%   18560785 ~ 0%     -66.0%   12235090 ~ 0%      +8.0%   38868453 ~ 0%   vm-scalability.throughput

     28138 ~ 0%   +7448.2%    2123943 ~ 0%   +2724.5%     794777 ~ 0%      +1.6%      28598 ~ 0%   proc-vmstat.allocstall

       544 ~ 6%     -95.2%         26 ~ 0%     -96.5%         19 ~21%      -6.9%        506 ~ 6%   numa-vmstat.node2.nr_isolated_file
  12009832 ~11%    +368.1%   56215319 ~ 0%    +312.9%   49589361 ~ 1%      +0.7%   12091235 ~ 5%   numa-numastat.node3.numa_foreign
       560 ~ 5%     -95.7%         24 ~12%     -96.9%         17 ~10%      -8.7%        511 ~ 2%   numa-vmstat.node1.nr_isolated_file
   8740137 ~12%    +574.0%   58910256 ~ 0%    +321.0%   36798827 ~ 0%     +21.0%   10578905 ~13%   numa-vmstat.node0.numa_other
   8734988 ~12%    +574.4%   58904944 ~ 0%    +321.2%   36794158 ~ 0%     +21.0%   10572718 ~13%   numa-vmstat.node0.numa_miss
      1308 ~12%    -100.0%          0 ~ 0%    -100.0%          0          +23.3%       1612 ~18%   proc-vmstat.pgscan_direct_throttle
  12294788 ~11%    +401.2%   61622745 ~ 0%    +332.6%   53190547 ~ 0%     -13.2%   10667387 ~ 5%   numa-numastat.node1.numa_foreign
       576 ~ 6%     -91.2%         50 ~22%     -94.3%         33 ~20%     -18.1%        472 ~ 1%   numa-vmstat.node0.nr_isolated_file
        12 ~24%   +2400.0%        316 ~ 4%  +13543.7%       1728 ~ 5%    +155.3%         32 ~29%   proc-vmstat.compact_stall
       572 ~ 2%     -96.4%         20 ~18%     -97.6%         13 ~11%     -17.5%        472 ~ 2%   numa-vmstat.node3.nr_isolated_file
      3012 ~12%   +2388.4%      74959 ~ 0%    +254.7%      10685 ~ 1%     -45.4%       1646 ~ 1%   proc-vmstat.pageoutrun
      2312 ~ 3%     -94.2%        133 ~ 4%     -95.8%         97 ~ 8%     -12.6%       2021 ~ 2%   proc-vmstat.nr_isolated_file
   2575163 ~ 0%   +2779.1%   74141888 ~ 0%    +958.0%   27244229 ~ 0%      -1.3%    2542941 ~ 0%   proc-vmstat.pgscan_direct_dma32
  21916603 ~13%   +2519.8%  5.742e+08 ~ 0%   +2868.9%  6.507e+08 ~ 0%     -16.1%   18397644 ~ 5%   proc-vmstat.pgscan_kswapd_normal
     53306 ~24%   +1077.9%     627895 ~ 0%   +2066.2%    1154741 ~ 0%     +23.5%      65815 ~24%   proc-vmstat.pgscan_kswapd_dma32
   2575163 ~ 0%   +2778.6%   74129497 ~ 0%    +957.8%   27239606 ~ 0%      -1.3%    2542353 ~ 0%   proc-vmstat.pgsteal_direct_dma32
  21907744 ~14%   +2520.8%  5.742e+08 ~ 0%   +2870.0%  6.507e+08 ~ 0%     -16.1%   18386641 ~ 5%   proc-vmstat.pgsteal_kswapd_normal
     53306 ~24%   +1077.7%     627796 ~ 0%   +2065.7%    1154436 ~ 0%     +23.3%      65731 ~24%   proc-vmstat.pgsteal_kswapd_dma32
   2967449 ~ 0%   +2432.7%   75156011 ~ 0%    +869.9%   28781337 ~ 0%      -0.7%    2945933 ~ 0%   proc-vmstat.pgalloc_dma32
  13081172 ~11%    +599.4%   91495653 ~ 0%    +337.1%   57180622 ~ 0%     +12.1%   14668141 ~13%   numa-numastat.node0.other_node
  13073426 ~11%    +599.8%   91489575 ~ 0%    +337.4%   57177129 ~ 0%     +12.1%   14660341 ~13%   numa-numastat.node0.numa_miss
       281 ~23%   +1969.4%       5822 ~ 1%   +3321.4%       9625 ~ 2%     -26.9%        205 ~17%   proc-vmstat.kswapd_low_wmark_hit_quickly
   8112109 ~10%    +389.4%   39704684 ~ 0%    +316.9%   33819005 ~ 0%      -7.3%    7523408 ~ 6%   numa-vmstat.node1.numa_foreign
  46881452 ~ 6%    +377.0%  2.236e+08 ~ 0%    +355.8%  2.137e+08 ~ 0%      -4.0%   44983257 ~ 3%   proc-vmstat.numa_miss
  46881949 ~ 6%    +376.9%  2.236e+08 ~ 0%    +355.8%  2.137e+08 ~ 0%      -4.0%   44983257 ~ 3%   proc-vmstat.numa_foreign
  46904868 ~ 6%    +376.8%  2.236e+08 ~ 0%    +355.6%  2.137e+08 ~ 0%      -4.0%   45006469 ~ 3%   proc-vmstat.numa_other
   7800796 ~12%    +363.7%   36173419 ~ 0%    +303.7%   31494068 ~ 1%      +9.4%    8535720 ~ 3%   numa-vmstat.node3.numa_foreign
  11737423 ~ 3%    +393.4%   57911736 ~ 0%    +326.5%   50058077 ~ 1%      +1.7%   11936784 ~ 9%   numa-numastat.node2.numa_foreign
    346095 ~15%    +401.6%    1736002 ~11%    -100.0%          0         -100.0%          0        cpuidle.C1E-IVB.time
   7880367 ~ 7%    +375.2%   37445539 ~ 0%    +304.3%   31862655 ~ 1%      +8.6%    8561430 ~ 8%   numa-vmstat.node2.numa_foreign
   6757778 ~ 7%    +356.3%   30834351 ~ 0%    +466.4%   38274496 ~ 1%      +0.2%    6769705 ~ 2%   numa-vmstat.node0.numa_foreign
  11503752 ~18%    +292.5%   45154508 ~ 0%    +350.3%   51802278 ~ 1%     -16.1%    9652380 ~ 6%   numa-numastat.node2.other_node
  11501132 ~18%    +292.5%   45147677 ~ 0%    +350.4%   51796449 ~ 1%     -16.1%    9647223 ~ 6%   numa-numastat.node2.numa_miss
   7262807 ~16%    +299.9%   29046424 ~ 0%    +348.7%   32588398 ~ 1%     -11.1%    6457478 ~ 6%   numa-vmstat.node2.numa_miss
   7377133 ~16%    +295.3%   29164332 ~ 0%    +343.4%   32710857 ~ 1%     -10.8%    6578224 ~ 5%   numa-vmstat.node2.numa_other
   6820241 ~ 6%    +307.8%   27811586 ~ 0%    +420.7%   35515296 ~ 1%      +7.9%    7355910 ~ 6%   numa-vmstat.node1.numa_miss
  10839905 ~ 7%    +341.4%   47852614 ~ 0%    +461.2%   60832325 ~ 0%      -5.1%   10287850 ~ 4%   numa-numastat.node0.numa_foreign
   6935590 ~ 6%    +302.6%   27924868 ~ 0%    +413.8%   35633492 ~ 1%      +7.8%    7476577 ~ 6%   numa-vmstat.node1.numa_other
  10813993 ~ 5%    +299.5%   43204929 ~ 0%    +420.1%   56246521 ~ 1%      -0.6%   10749818 ~ 4%   numa-numastat.node1.numa_miss
  10819213 ~ 5%    +299.3%   43206092 ~ 0%    +419.9%   56248990 ~ 1%      -0.6%   10757658 ~ 4%   numa-numastat.node1.other_node
   1140660 ~ 4%    +286.4%    4407490 ~ 0%     -70.1%     340604 ~ 7%     -73.9%     297174 ~10%   softirqs.RCU
  11492901 ~ 5%    +280.8%   43760234 ~ 1%    +321.6%   48449737 ~ 0%     -13.6%    9925875 ~11%   numa-numastat.node3.numa_miss
  11500730 ~ 5%    +280.5%   43764966 ~ 1%    +321.3%   48452382 ~ 0%     -13.7%    9928289 ~11%   numa-numastat.node3.other_node
   7731093 ~ 9%    +267.2%   28390454 ~ 1%    +295.2%   30551873 ~ 1%      -9.4%    7001974 ~11%   numa-vmstat.node3.numa_miss
   7848292 ~ 9%    +263.2%   28506779 ~ 1%    +290.8%   30671898 ~ 1%      -9.3%    7121295 ~11%   numa-vmstat.node3.numa_other
  9.19e+08 ~ 0%     -67.9%  2.947e+08 ~ 0%     -88.0%  1.099e+08 ~ 0%      +0.5%   9.24e+08 ~ 0%   proc-vmstat.pgsteal_direct_normal
 9.192e+08 ~ 0%     -67.9%  2.949e+08 ~ 0%     -88.0%  1.101e+08 ~ 0%      +0.5%  9.242e+08 ~ 0%   proc-vmstat.pgscan_direct_normal
       583 ~48%    +119.9%       1283 ~ 4%    -100.0%          0         -100.0%          0        cpuidle.C3-IVB.usage
      1941 ~15%     +94.3%       3772 ~ 2%    -100.0%          0         -100.0%          0        cpuidle.C1E-IVB.usage
    104150 ~ 8%    +122.7%     231910 ~ 1%    -100.0%          0         -100.0%          0        cpuidle.C6-IVB.usage
      4549 ~20%     -44.1%       2544 ~ 3%     -14.1%       3907 ~ 2%     +27.0%       5777 ~27%   numa-meminfo.node2.Mapped
       131 ~ 3%     +57.2%        207 ~26%      +6.2%        139 ~15%      -2.5%        128 ~ 0%   numa-vmstat.node2.nr_mlock
      1154 ~23%     -44.4%        641 ~ 3%     -14.5%        987 ~ 2%     +12.6%       1300 ~13%   numa-vmstat.node2.nr_mapped
       247 ~ 0%     -44.6%        137 ~ 4%     -23.5%        189 ~27%     -13.1%        215 ~14%   numa-vmstat.node3.nr_mlock
   7893867 ~ 0%     +73.1%   13662239 ~ 0%    +131.7%   18293241 ~ 1%      -7.2%    7322135 ~ 2%   softirqs.TIMER
       254 ~ 1%     +52.0%        386 ~ 0%    +112.9%        541 ~ 0%     +33.5%        339 ~ 0%   uptime.boot
    372323 ~ 0%     +52.3%     567042 ~ 0%     +31.1%     488079 ~21%     -15.6%     314286 ~31%   softirqs.SCHED
       936 ~ 8%     +37.4%       1286 ~ 3%    -100.0%          0         -100.0%          0        cpuidle.C1-IVB.usage
  31479723 ~ 4%     -27.5%   22834553 ~ 2%     -34.7%   20560389 ~ 2%      +6.6%   33549465 ~ 3%   numa-meminfo.node2.MemFree
   2323695 ~ 2%     +40.4%    3262008 ~ 1%     -26.5%    1706990 ~ 2%     -48.1%    1205381 ~ 0%   proc-vmstat.pgfault
  32342772 ~ 8%     -26.3%   23833261 ~ 4%     -32.9%   21705887 ~ 0%      +9.4%   35376761 ~ 4%   numa-meminfo.node0.MemFree
   8031011 ~ 8%     -25.6%    5975081 ~ 4%     -32.1%    5453418 ~ 0%      +9.9%    8825066 ~ 4%   numa-vmstat.node0.nr_free_pages
   7827043 ~ 5%     -26.9%    5725077 ~ 2%     -34.0%    5166251 ~ 2%      +7.0%    8371916 ~ 3%   numa-vmstat.node2.nr_free_pages
    397512 ~17%     +51.9%     603759 ~ 0%    +142.6%     964486 ~ 3%     +61.6%     642503 ~ 0%   meminfo.Active(file)
     99417 ~17%     +51.8%     150939 ~ 0%    +142.5%     241038 ~ 3%     +61.7%     160751 ~ 0%   proc-vmstat.nr_active_file
  31323464 ~ 2%     -23.4%   23989124 ~ 4%     -31.8%   21369103 ~ 3%      +9.2%   34212722 ~ 1%   numa-meminfo.node3.MemFree
    438263 ~15%     +47.4%     645991 ~ 0%    +130.4%    1009642 ~ 3%     +55.8%     682854 ~ 0%   meminfo.Active
 1.218e+08 ~ 3%     -27.1%   88812446 ~ 0%     -35.9%   78043140 ~ 1%      +8.8%  1.326e+08 ~ 1%   vmstat.memory.free
   7783606 ~ 2%     -22.7%    6013340 ~ 4%     -31.0%    5368886 ~ 3%      +9.5%    8525297 ~ 1%   numa-vmstat.node3.nr_free_pages
 9.863e+09 ~ 5%     +28.0%  1.263e+10 ~ 0%    -100.0%          0         -100.0%          0        cpuidle.C6-IVB.time
  30685778 ~ 3%     -25.6%   22816822 ~ 0%     -33.9%   20284824 ~ 1%      +9.6%   33629815 ~ 0%   proc-vmstat.nr_free_pages
 1.226e+08 ~ 3%     -25.6%   91184833 ~ 0%     -33.8%   81175485 ~ 0%      +9.1%  1.338e+08 ~ 1%   meminfo.MemFree
     38.36 ~ 1%     -22.9%      29.57 ~ 0%     -32.2%      26.01 ~ 1%     +16.8%      44.81 ~ 0%   turbostat.%c6
    258220 ~ 2%     +27.1%     328306 ~ 0%    +312.9%    1066156 ~ 1%    +327.3%    1103267 ~ 0%   numa-meminfo.node0.SReclaimable
   7391310 ~ 8%     -23.6%    5644229 ~ 3%     -30.8%    5113603 ~ 1%     +10.9%    8193379 ~ 3%   numa-vmstat.node1.nr_free_pages
     64655 ~ 2%     +26.9%      82040 ~ 0%    +312.1%     266434 ~ 1%    +328.1%     276777 ~ 0%   numa-vmstat.node0.nr_slab_reclaimable
  29746194 ~ 9%     -24.3%   22509136 ~ 3%     -31.6%   20349995 ~ 1%     +10.5%   32855085 ~ 3%   numa-meminfo.node1.MemFree
     26.27 ~ 3%     -19.8%      21.08 ~ 2%     -38.5%      16.17 ~ 5%      +7.5%      28.25 ~ 4%   turbostat.%pc2
 1.834e+08 ~ 2%     -19.1%  1.483e+08 ~ 0%     -30.6%  1.273e+08 ~ 0%      +7.1%  1.963e+08 ~ 0%   numa-vmstat.node2.numa_local
 1.835e+08 ~ 2%     -19.1%  1.484e+08 ~ 0%     -30.5%  1.274e+08 ~ 0%      +7.1%  1.965e+08 ~ 0%   numa-vmstat.node2.numa_hit
    253483 ~ 0%     +24.4%     315364 ~ 0%    +356.1%    1156183 ~ 3%    +332.1%    1095207 ~ 1%   numa-meminfo.node2.SReclaimable
     63485 ~ 0%     +24.2%      78832 ~ 0%    +355.1%     288938 ~ 3%    +332.8%     274790 ~ 2%   numa-vmstat.node2.nr_slab_reclaimable
 1.834e+08 ~ 1%     -19.1%  1.484e+08 ~ 0%     -32.2%  1.244e+08 ~ 0%      +6.4%  1.952e+08 ~ 0%   numa-vmstat.node1.numa_local
 1.835e+08 ~ 1%     -19.1%  1.485e+08 ~ 0%     -32.2%  1.245e+08 ~ 0%      +6.4%  1.953e+08 ~ 0%   numa-vmstat.node1.numa_hit
     31121 ~ 0%     +24.2%      38660 ~ 0%    +337.9%     136272 ~ 0%    +346.2%     138852 ~ 0%   slabinfo.radix_tree_node.active_slabs
     31121 ~ 0%     +24.2%      38660 ~ 0%    +337.9%     136272 ~ 0%    +346.2%     138852 ~ 0%   slabinfo.radix_tree_node.num_slabs
   1773967 ~ 0%     +24.2%    2203652 ~ 0%    +330.2%    7631290 ~ 0%    +338.3%    7775736 ~ 0%   slabinfo.radix_tree_node.num_objs
 1.812e+08 ~ 1%     -18.0%  1.486e+08 ~ 0%     -36.8%  1.145e+08 ~ 0%      +6.1%  1.923e+08 ~ 0%   numa-vmstat.node0.numa_local
 1.812e+08 ~ 1%     -18.0%  1.486e+08 ~ 0%     -36.8%  1.145e+08 ~ 0%      +6.1%  1.923e+08 ~ 0%   numa-vmstat.node0.numa_hit
     66070 ~ 3%     +21.3%      80115 ~ 0%    +321.2%     278266 ~ 2%    +326.5%     281780 ~ 0%   numa-vmstat.node3.nr_slab_reclaimable
    300550 ~ 1%     +24.0%     372562 ~ 0%    +270.4%    1113328 ~ 1%    +282.0%    1148228 ~ 0%   numa-meminfo.node0.Slab
    263893 ~ 3%     +21.5%     320550 ~ 0%    +322.0%    1113565 ~ 2%    +325.5%    1122866 ~ 0%   numa-meminfo.node3.SReclaimable
 1.829e+08 ~ 1%     -18.5%  1.491e+08 ~ 0%     -29.1%  1.297e+08 ~ 0%      +7.2%  1.961e+08 ~ 0%   numa-vmstat.node3.numa_local
  1.83e+08 ~ 1%     -18.5%  1.492e+08 ~ 0%     -29.1%  1.298e+08 ~ 0%      +7.2%  1.962e+08 ~ 0%   numa-vmstat.node3.numa_hit
    259346 ~ 0%     +23.4%     320065 ~ 0%    +322.7%    1096319 ~ 0%    +326.9%    1107135 ~ 0%   proc-vmstat.nr_slab_reclaimable
   1037386 ~ 0%     +23.4%    1280292 ~ 0%    +323.0%    4387782 ~ 0%    +328.0%    4439951 ~ 0%   meminfo.SReclaimable
      8287 ~11%     +18.5%       9817 ~11%     +15.1%       9539 ~15%     +12.5%       9319 ~14%   numa-meminfo.node0.AnonPages
 2.577e+08 ~ 0%     -17.7%  2.121e+08 ~ 0%     -29.5%  1.817e+08 ~ 0%      +0.5%  2.589e+08 ~ 0%   numa-numastat.node2.local_node
 2.577e+08 ~ 0%     -17.7%  2.121e+08 ~ 0%     -29.5%  1.817e+08 ~ 0%      +0.5%  2.589e+08 ~ 0%   numa-numastat.node2.numa_hit
    286724 ~ 0%     +22.0%     349778 ~ 0%    +316.0%    1192776 ~ 2%    +293.8%    1129211 ~ 1%   numa-meminfo.node2.Slab


Here I also compared those 3 patches with its base: v3.15-rc6, so that
you can see the changes between them clearly:

      v3.15-rc6  60c10afd233f3344479d229dc  
---------------  -------------------------  
  12235090 ~ 0%    +217.7%   38868453 ~ 0%   vm-scalability.throughput

    794777 ~ 0%     -96.4%      28598 ~ 0%   proc-vmstat.allocstall

     28.86 ~ 0%    -100.0%       0.00 ~ 0%   perf-profile.cpu-cycles._raw_spin_lock.grab_super_passive.super_cache_count.shrink_slab_node.shrink_slab
      0.04 ~30%  +75293.9%      33.17 ~ 2%   perf-profile.cpu-cycles._raw_spin_lock.free_pcppages_bulk.free_hot_cold_page.free_hot_cold_page_list.shrink_page_list
      0.00           +Inf%      19.20 ~ 4%   perf-profile.cpu-cycles._raw_spin_lock.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_current.__page_cache_alloc

     10685 ~ 1%     -84.6%       1646 ~ 1%   proc-vmstat.pageoutrun
  38274496 ~ 1%     -82.3%    6769705 ~ 2%   numa-vmstat.node0.numa_foreign
  27239606 ~ 0%     -90.7%    2542353 ~ 0%   proc-vmstat.pgsteal_direct_dma32
 1.099e+08 ~ 0%    +740.6%   9.24e+08 ~ 0%   proc-vmstat.pgsteal_direct_normal
 6.507e+08 ~ 0%     -97.2%   18386641 ~ 5%   proc-vmstat.pgsteal_kswapd_normal
        13 ~11%   +3322.7%        472 ~ 2%   numa-vmstat.node3.nr_isolated_file
  28781337 ~ 0%     -89.8%    2945933 ~ 0%   proc-vmstat.pgalloc_dma32
        97 ~ 8%   +1974.9%       2021 ~ 2%   proc-vmstat.nr_isolated_file
      1570 ~ 5%     -98.0%         30 ~25%   proc-vmstat.compact_success
     28.91 ~ 0%    -100.0%       0.00 ~ 0%   perf-profile.cpu-cycles._raw_spin_lock.put_super.super_cache_count.shrink_slab_node.shrink_slab
      1728 ~ 5%     -98.1%         32 ~29%   proc-vmstat.compact_stall
  51802278 ~ 1%     -81.4%    9652380 ~ 6%   numa-numastat.node2.other_node
      9625 ~ 2%     -97.9%        205 ~17%   proc-vmstat.kswapd_low_wmark_hit_quickly
        33 ~20%   +1330.3%        472 ~ 1%   numa-vmstat.node0.nr_isolated_file
 1.101e+08 ~ 0%    +739.2%  9.242e+08 ~ 0%   proc-vmstat.pgscan_direct_normal
      6344 ~12%     -91.9%        513 ~22%   cpuidle.C3-IVT-4S.usage
  51796449 ~ 1%     -81.4%    9647223 ~ 6%   numa-numastat.node2.numa_miss
  27244229 ~ 0%     -90.7%    2542941 ~ 0%   proc-vmstat.pgscan_direct_dma32
   1154436 ~ 0%     -94.3%      65731 ~24%   proc-vmstat.pgsteal_kswapd_dma32
 6.507e+08 ~ 0%     -97.2%   18397644 ~ 5%   proc-vmstat.pgscan_kswapd_normal
   1154741 ~ 0%     -94.3%      65815 ~24%   proc-vmstat.pgscan_kswapd_dma32
  56246521 ~ 1%     -80.9%   10749818 ~ 4%   numa-numastat.node1.numa_miss
        19 ~21%   +2538.9%        506 ~ 6%   numa-vmstat.node2.nr_isolated_file
 1.318e+10 ~31%    -100.0%       1346 ~ 3%   numa-vmstat.node2.nr_alloc_batch
  56248990 ~ 1%     -80.9%   10757658 ~ 4%   numa-numastat.node1.other_node
  60832325 ~ 0%     -83.1%   10287850 ~ 4%   numa-numastat.node0.numa_foreign
        17 ~10%   +2807.2%        511 ~ 2%   numa-vmstat.node1.nr_isolated_file
      1.03 ~ 9%    +342.3%       4.57 ~10%   perf-profile.cpu-cycles._raw_spin_lock_irq.__remove_mapping.shrink_page_list.shrink_inactive_list.shrink_lruvec
 2.137e+08 ~ 0%     -78.9%   44983257 ~ 3%   proc-vmstat.numa_foreign
 2.137e+08 ~ 0%     -78.9%   44983257 ~ 3%   proc-vmstat.numa_miss
 2.137e+08 ~ 0%     -78.9%   45006469 ~ 3%   proc-vmstat.numa_other
  53190547 ~ 0%     -79.9%   10667387 ~ 5%   numa-numastat.node1.numa_foreign
  32588398 ~ 1%     -80.2%    6457478 ~ 6%   numa-vmstat.node2.numa_miss
  32710857 ~ 1%     -79.9%    6578224 ~ 5%   numa-vmstat.node2.numa_other
  35515296 ~ 1%     -79.3%    7355910 ~ 6%   numa-vmstat.node1.numa_miss
  35633492 ~ 1%     -79.0%    7476577 ~ 6%   numa-vmstat.node1.numa_other
  48449737 ~ 0%     -79.5%    9925875 ~11%   numa-numastat.node3.numa_miss
  48452382 ~ 0%     -79.5%    9928289 ~11%   numa-numastat.node3.other_node
  33819005 ~ 0%     -77.8%    7523408 ~ 6%   numa-vmstat.node1.numa_foreign
  50058077 ~ 1%     -76.2%   11936784 ~ 9%   numa-numastat.node2.numa_foreign
  57177129 ~ 0%     -74.4%   14660341 ~13%   numa-numastat.node0.numa_miss
  57180622 ~ 0%     -74.3%   14668141 ~13%   numa-numastat.node0.other_node
  30551873 ~ 1%     -77.1%    7001974 ~11%   numa-vmstat.node3.numa_miss
    171383 ~ 3%    +315.8%     712676 ~ 0%   numa-vmstat.node0.workingset_nodereclaim
  30671898 ~ 1%     -76.8%    7121295 ~11%   numa-vmstat.node3.numa_other
  49589361 ~ 1%     -75.6%   12091235 ~ 5%   numa-numastat.node3.numa_foreign
      3.20 ~ 3%     -73.8%       0.84 ~ 7%   perf-profile.cpu-cycles.get_page_from_freelist.__alloc_pages_nodemask.alloc_pages_current.__page_cache_alloc.__do_page_cache_readahead
  36794158 ~ 0%     -71.3%   10572718 ~13%   numa-vmstat.node0.numa_miss
  36798827 ~ 0%     -71.3%   10578905 ~13%   numa-vmstat.node0.numa_other
  31862655 ~ 1%     -73.1%    8561430 ~ 8%   numa-vmstat.node2.numa_foreign
      5.49 ~ 3%     -72.6%       1.51 ~ 2%   perf-profile.cpu-cycles.read_hpet.ktime_get.sched_clock_tick.scheduler_tick.update_process_times
  31494068 ~ 1%     -72.9%    8535720 ~ 3%   numa-vmstat.node3.numa_foreign
    193959 ~32%    +270.9%     719458 ~ 0%   numa-vmstat.node1.workingset_nodereclaim
      5.54 ~24%     -62.4%       2.08 ~ 2%   perf-profile.cpu-cycles.read_hpet.ktime_get.tick_sched_timer.__run_hrtimer.hrtimer_interrupt
    942413 ~ 1%    +202.8%    2853944 ~ 0%   proc-vmstat.workingset_nodereclaim
      2.56 ~ 1%    +183.7%       7.26 ~ 1%   perf-profile.cpu-cycles.memset.mpage_readpages.xfs_vm_readpages.__do_page_cache_readahead.ondemand_readahead
      0.66 ~ 3%    +158.0%       1.71 ~ 1%   perf-profile.cpu-cycles.do_mpage_readpage.mpage_readpages.xfs_vm_readpages.__do_page_cache_readahead.ondemand_readahead
    278876 ~ 8%    +160.9%     727574 ~ 1%   numa-vmstat.node3.workingset_nodereclaim
      0.99 ~ 2%    +153.7%       2.51 ~ 1%   perf-profile.cpu-cycles.copy_user_enhanced_fast_string.generic_file_aio_read.xfs_file_aio_read.do_sync_read.vfs_read
      1.06 ~ 4%    +152.4%       2.68 ~ 7%   perf-profile.cpu-cycles._raw_spin_lock_irq.shrink_inactive_list.shrink_lruvec.shrink_zone.shrink_zones
  18293241 ~ 1%     -60.0%    7322135 ~ 2%   softirqs.TIMER
   2751027 ~ 1%    +143.4%    6694741 ~ 0%   proc-vmstat.slabs_scanned
    323697 ~13%    +122.6%     720522 ~ 0%   numa-vmstat.node2.workingset_nodereclaim
      2.97 ~20%     -48.9%       1.52 ~ 2%   perf-profile.cpu-cycles.read_hpet.ktime_get_update_offsets.hrtimer_interrupt.local_apic_timer_interrupt.smp_apic_timer_interrupt
    267614 ~ 0%     -54.0%     123176 ~ 1%   cpuidle.C6-IVT-4S.usage
   3854181 ~17%     -53.9%    1775595 ~17%   cpuidle.C1E-IVT-4S.time
       557 ~15%     -55.1%        250 ~ 8%   cpuidle.C1E-IVT-4S.usage
     13518 ~ 7%     -42.6%       7760 ~15%   proc-vmstat.numa_pte_updates
     16.17 ~ 5%     +74.7%      28.25 ~ 4%   turbostat.%pc2
      1076 ~21%     +59.1%       1712 ~17%   numa-vmstat.node3.nr_mapped
     11908 ~13%     -42.3%       6872 ~11%   proc-vmstat.numa_hint_faults
     26.01 ~ 1%     +72.2%      44.81 ~ 0%   turbostat.%c6
  78043140 ~ 1%     +69.8%  1.326e+08 ~ 1%   vmstat.memory.free
      4293 ~22%     +55.3%       6668 ~15%   numa-meminfo.node3.Mapped
 1.145e+08 ~ 0%     +67.9%  1.923e+08 ~ 0%   numa-vmstat.node0.numa_local
 1.145e+08 ~ 0%     +67.9%  1.923e+08 ~ 0%   numa-vmstat.node0.numa_hit
      9263 ~ 6%     -38.4%       5708 ~ 8%   proc-vmstat.numa_hint_faults_local
  20284824 ~ 1%     +65.8%   33629815 ~ 0%   proc-vmstat.nr_free_pages
  81175485 ~ 0%     +64.8%  1.338e+08 ~ 1%   meminfo.MemFree
  20560389 ~ 2%     +63.2%   33549465 ~ 3%   numa-meminfo.node2.MemFree
  20349995 ~ 1%     +61.5%   32855085 ~ 3%   numa-meminfo.node1.MemFree
  21705887 ~ 0%     +63.0%   35376761 ~ 4%   numa-meminfo.node0.MemFree
   5166251 ~ 2%     +62.1%    8371916 ~ 3%   numa-vmstat.node2.nr_free_pages
   5453418 ~ 0%     +61.8%    8825066 ~ 4%   numa-vmstat.node0.nr_free_pages
   5113603 ~ 1%     +60.2%    8193379 ~ 3%   numa-vmstat.node1.nr_free_pages
       541 ~ 0%     -37.3%        339 ~ 0%   uptime.boot
  21369103 ~ 3%     +60.1%   34212722 ~ 1%   numa-meminfo.node3.MemFree
   5368886 ~ 3%     +58.8%    8525297 ~ 1%   numa-vmstat.node3.nr_free_pages
 1.617e+08 ~ 0%     +57.4%  2.545e+08 ~ 0%   numa-numastat.node0.numa_hit
 1.617e+08 ~ 0%     +57.4%  2.545e+08 ~ 0%   numa-numastat.node0.local_node
 1.244e+08 ~ 0%     +57.0%  1.952e+08 ~ 0%   numa-vmstat.node1.numa_local
 1.245e+08 ~ 0%     +56.9%  1.953e+08 ~ 0%   numa-vmstat.node1.numa_hit
 1.273e+08 ~ 0%     +54.2%  1.963e+08 ~ 0%   numa-vmstat.node2.numa_local
 1.274e+08 ~ 0%     +54.1%  1.965e+08 ~ 0%   numa-vmstat.node2.numa_hit
    241038 ~ 3%     -33.3%     160751 ~ 0%   proc-vmstat.nr_active_file
    964486 ~ 3%     -33.4%     642503 ~ 0%   meminfo.Active(file)
      3.16 ~ 5%     -28.2%       2.27 ~18%   perf-profile.cpu-cycles._raw_spin_lock_irqsave.pagevec_lru_move_fn.__lru_cache_add.lru_cache_add.add_to_page_cache_lru
   1009642 ~ 3%     -32.4%     682854 ~ 0%   meminfo.Active
 1.297e+08 ~ 0%     +51.2%  1.961e+08 ~ 0%   numa-vmstat.node3.numa_local
 1.298e+08 ~ 0%     +51.2%  1.962e+08 ~ 0%   numa-vmstat.node3.numa_hit
 7.056e+08 ~ 0%     +46.0%   1.03e+09 ~ 0%   proc-vmstat.numa_hit
 7.056e+08 ~ 0%     +46.0%   1.03e+09 ~ 0%   proc-vmstat.numa_local
 1.768e+08 ~ 0%     +45.7%  2.576e+08 ~ 0%   numa-numastat.node1.local_node
 1.768e+08 ~ 0%     +45.7%  2.576e+08 ~ 0%   numa-numastat.node1.numa_hit
   1706990 ~ 2%     -29.4%    1205381 ~ 0%   proc-vmstat.pgfault
 1.817e+08 ~ 0%     +42.5%  2.589e+08 ~ 0%   numa-numastat.node2.local_node
 1.817e+08 ~ 0%     +42.5%  2.589e+08 ~ 0%   numa-numastat.node2.numa_hit
        91 ~ 0%     -30.0%         64 ~ 0%   vmstat.procs.r
 1.854e+08 ~ 0%     +39.7%   2.59e+08 ~ 0%   numa-numastat.node3.local_node
 1.854e+08 ~ 0%     +39.7%   2.59e+08 ~ 0%   numa-numastat.node3.numa_hit
      2402 ~ 6%     -23.8%       1830 ~ 9%   numa-meminfo.node2.PageTables
    189013 ~ 5%     -26.2%     139474 ~ 1%   proc-vmstat.pgactivate
       599 ~ 5%     -23.3%        460 ~ 9%   numa-vmstat.node2.nr_page_table_pages
       567 ~ 1%     -23.8%        432 ~ 3%   slabinfo.kmalloc-8192.active_objs
       567 ~ 1%     -23.8%        432 ~ 3%   slabinfo.kmalloc-8192.num_objs
      2403 ~ 8%     -24.8%       1807 ~ 1%   numa-meminfo.node0.PageTables
      3439 ~ 7%     -25.1%       2574 ~21%   numa-vmstat.node2.nr_active_anon
     13778 ~ 7%     -25.4%      10275 ~21%   numa-meminfo.node2.Active(anon)
     13823 ~ 7%     -25.6%      10288 ~21%   numa-meminfo.node2.AnonPages
      3449 ~ 7%     -25.3%       2577 ~21%   numa-vmstat.node2.nr_anon_pages
       599 ~ 9%     -23.7%        457 ~ 1%   numa-vmstat.node0.nr_page_table_pages
      5832 ~ 1%     -19.6%       4692 ~ 2%   cpuidle.C1-IVT-4S.usage
      2323 ~ 0%     -17.9%       1907 ~ 1%   proc-vmstat.nr_page_table_pages
      9308 ~ 0%     -17.9%       7642 ~ 1%   meminfo.PageTables
     17256 ~ 4%     +27.1%      21940 ~ 8%   meminfo.Mapped
 8.922e+08 ~ 0%     +20.3%  1.074e+09 ~ 0%   proc-vmstat.pgalloc_normal
      3907 ~ 2%     +47.8%       5777 ~27%   numa-meminfo.node2.Mapped
       987 ~ 2%     +31.7%       1300 ~13%   numa-vmstat.node2.nr_mapped
 9.207e+08 ~ 0%     +16.9%  1.076e+09 ~ 0%   proc-vmstat.pgfree
 1.356e+10 ~ 1%     -14.2%  1.163e+10 ~ 0%   cpuidle.C6-IVT-4S.time
      2246 ~ 3%     -12.6%       1963 ~ 5%   numa-meminfo.node1.PageTables
 1.083e+08 ~ 0%     -12.7%   94534696 ~ 1%   numa-meminfo.node0.FilePages
 1.079e+08 ~ 0%     -12.6%   94270824 ~ 1%   numa-meminfo.node0.Inactive(file)
 1.079e+08 ~ 0%     -12.6%   94270854 ~ 1%   numa-meminfo.node0.Inactive
       559 ~ 3%     -11.6%        494 ~ 4%   numa-vmstat.node1.nr_page_table_pages
      1774 ~ 2%     +12.1%       1989 ~ 4%   slabinfo.sock_inode_cache.num_objs
      1774 ~ 2%     +12.1%       1989 ~ 4%   slabinfo.sock_inode_cache.active_objs
 1.102e+08 ~ 0%     -12.4%   96552102 ~ 1%   numa-meminfo.node0.MemUsed
 4.424e+08 ~ 0%     -12.4%  3.877e+08 ~ 0%   vmstat.memory.cache
  26940036 ~ 0%     -12.5%   23585745 ~ 1%   numa-vmstat.node0.nr_inactive_file
  27043809 ~ 0%     -12.5%   23651628 ~ 1%   numa-vmstat.node0.nr_file_pages
 1.098e+08 ~ 0%     -12.2%   96437485 ~ 0%   proc-vmstat.nr_file_pages
 1.093e+08 ~ 0%     -12.2%   96005869 ~ 0%   proc-vmstat.nr_inactive_file
      4528 ~ 5%     +18.2%       5353 ~10%   proc-vmstat.nr_mapped
 4.392e+08 ~ 0%     -12.0%  3.865e+08 ~ 0%   meminfo.Cached
 1.096e+08 ~ 0%     -11.8%   96632158 ~ 1%   numa-meminfo.node2.FilePages
 4.372e+08 ~ 0%     -12.0%  3.848e+08 ~ 0%   meminfo.Inactive(file)
 1.093e+08 ~ 0%     -11.9%   96232093 ~ 1%   numa-meminfo.node2.Inactive
 1.093e+08 ~ 0%     -11.9%   96232069 ~ 1%   numa-meminfo.node2.Inactive(file)
 4.374e+08 ~ 0%     -12.0%   3.85e+08 ~ 0%   meminfo.Inactive
 1.116e+08 ~ 0%     -11.6%   98566609 ~ 1%   numa-meminfo.node2.MemUsed
  27073175 ~ 0%     -11.8%   23870731 ~ 0%   numa-vmstat.node3.nr_inactive_file
 1.084e+08 ~ 0%     -12.0%   95375555 ~ 0%   numa-meminfo.node3.Inactive(file)
 1.084e+08 ~ 0%     -12.0%   95375696 ~ 0%   numa-meminfo.node3.Inactive
 1.098e+08 ~ 0%     -11.5%   97177949 ~ 1%   numa-meminfo.node1.FilePages
  27368670 ~ 0%     -11.7%   24172297 ~ 1%   numa-vmstat.node2.nr_file_pages
  27292874 ~ 0%     -11.8%   24072388 ~ 1%   numa-vmstat.node2.nr_inactive_file
 1.088e+08 ~ 0%     -11.8%   95932998 ~ 0%   numa-meminfo.node3.FilePages
  27177317 ~ 0%     -11.7%   24010011 ~ 0%   numa-vmstat.node3.nr_file_pages
 1.118e+08 ~ 0%     -11.2%   99260989 ~ 1%   numa-meminfo.node1.MemUsed
 1.107e+08 ~ 0%     -11.6%   97902893 ~ 0%   numa-meminfo.node3.MemUsed
  27415800 ~ 0%     -11.3%   24313716 ~ 1%   numa-vmstat.node1.nr_file_pages
 1.088e+08 ~ 0%     -11.2%   96669488 ~ 1%   numa-meminfo.node1.Inactive(file)
 1.091e+08 ~ 0%     -11.1%   96922630 ~ 1%   numa-meminfo.node1.Inactive
     10839 ~ 0%     -11.0%       9643 ~ 0%   proc-vmstat.nr_anon_pages
  27179244 ~ 0%     -11.0%   24186654 ~ 1%   numa-vmstat.node1.nr_inactive_file
     43359 ~ 0%     -10.9%      38620 ~ 0%   meminfo.AnonPages
     11286 ~ 0%     -10.7%      10078 ~ 0%   proc-vmstat.nr_active_anon
     45155 ~ 0%     -10.6%      40350 ~ 0%   meminfo.Active(anon)
    401298 ~ 7%     +11.8%     448799 ~ 7%   meminfo.Committed_AS
     33611 ~ 0%     -60.9%      13155 ~ 0%   time.system_time
       409 ~ 0%     -49.3%        207 ~ 0%   time.elapsed_time
      2135 ~ 1%     +70.1%       3631 ~ 8%   time.voluntary_context_switches
      2179 ~ 1%     +47.5%       3214 ~ 0%   vmstat.system.cs
     72.36 ~ 0%     -26.3%      53.33 ~ 0%   turbostat.%c0
      8222 ~ 0%     -22.5%       6375 ~ 0%   time.percent_of_cpu_this_job_got
     70.17 ~ 0%     +28.9%      90.42 ~ 0%   time.user_time
    234540 ~ 0%     -19.8%     188128 ~ 0%   time.involuntary_context_switches
       325 ~ 0%     -15.9%        273 ~ 0%   turbostat.Cor_W
       396 ~ 0%     -12.8%        345 ~ 0%   turbostat.Pkg_W
     85.30 ~ 0%     +12.2%      95.67 ~ 0%   turbostat.RAM_W
    118580 ~ 0%      -6.9%     110376 ~ 0%   vmstat.system.in
    121252 ~ 0%      -3.6%     116834 ~ 0%   time.minor_page_faults


	--yliu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
