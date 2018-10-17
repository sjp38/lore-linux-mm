Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 011EB6B0003
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 02:33:38 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b95-v6so20250140plb.10
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 23:33:37 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f2-v6si16427856pgf.423.2018.10.16.23.33.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 23:33:35 -0700 (PDT)
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC v4 PATCH 0/5] Eliminate zone->lock contention for will-it-scale/page_fault1 and parallel free
Date: Wed, 17 Oct 2018 14:33:25 +0800
Message-Id: <20181017063330.15384-1-aaron.lu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

This series is meant to improve zone->lock scalability for order 0 pages.
With will-it-scale/page_fault1 workload, on a 2 sockets Intel Skylake
server with 112 CPUs, CPU spend 80% of its time spinning on zone->lock.
Perf profile shows the most time consuming part under zone->lock is the
cache miss on "struct page", so here I'm trying to avoid those cache
misses.

Patch 1/5 adds some wrapper functions for page to be added/removed
into/from buddy and doesn't have functionality changes.

Patch 2/5 skip doing merge for order 0 pages to avoid cache misses on
buddy's "struct page". On a 2 sockets Intel Skylake, this has very good
effect on free path for will-it-scale/page_fault1 full load in that it
reduced zone->lock contention on free path from 35% to 1.1%. Also, it
shows good result on parallel free(*) workload by reducing zone->lock
contention from 90% to almost zero(lru lock increased from almost 0 to
90% though).

Patch 3/5 deals with allocation path zone->lock contention by not
touching pages on free_list one by one inside zone->lock. Together with
patch 2/4, zone->lock contention is entirely eliminated for
will-it-scale/page_fault1 full load, though this patch adds some
overhead to manage cluster on free path and it has some bad effects on
parallel free workload in that it increased zone->lock contention from
almost 0 to 25%.

Patch 4/5 is an optimization in free path due to cluster operation. It
decreased the number of times add_to_cluster() has to be called and
restored performance for parallel free workload by reducing zone->lock's
contention to almost 0% again.

Patch 5/5 relax the condition for no_merge and cluster_alloc to happen.

The good thing about this patchset is, it eliminated zone->lock
contention for will-it-scale/page_fault1 and parallel free on big
servers(contention shifted to lru_lock).

Tariq Toukan has kindly given this patchset a go using netperf and here
is the numbers. Quoting him:

"
I ran TCP multistream tests before and after your changes to mm.
In order to stress the zone lock, I made sure there are always PCPs that 
continuously strive to allocate pages (CPUs where driver allocates 
memory), and PCPs that continuously free pages back to buddy 
(application/stack release the socket buffer).

This was done by configuring less queues than CPUs, and running more TCP 
streams than queues.

In addition, to make the test more page consuming, I modified the driver 
as follows:
- disabled the rx page cache mechanism.
- disabled the page-reuse optimization, so that every page serves a 
single packet, instead of two (each is of default MTU size: 1500B).

NIC: ConnectX-5 (100Gbps)
lscpu:
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                48
On-line CPU(s) list:   0-47
Thread(s) per core:    2
Core(s) per socket:    12
Socket(s):             2
NUMA node(s):          2
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 63
Model name:            Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
Stepping:              2
CPU MHz:               3306.118
BogoMIPS:              4999.28
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              30720K
NUMA node0 CPU(s): 
0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46
NUMA node1 CPU(s): 
1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47

Test:
run multiple netperf instances (TCP_STREAM) for 10 secs, repeat 3 times.
Number of streams: 48, 96, 192, 240, 360, and 480.
Collect stats for:
- BW (in Mbps)
- CPU usage (sum of percentages for all 48 cores).
- perf profile

24 queues:

Before:
STREAMS: 48  BW: 72890.68 CPU: 4457 (44.57)
STREAMS: 48  BW: 70518.78 CPU: 4577 (45.77)
STREAMS: 48  BW: 73354.36 CPU: 4160 (41.60)
STREAMS: 96  BW: 71048.86 CPU: 4809 (48.09)
STREAMS: 96  BW: 70849.41 CPU: 4801 (48.01)
STREAMS: 96  BW: 71156.13 CPU: 4804 (48.04)
STREAMS: 192 BW: 69967.00 CPU: 4803 (48.03)
STREAMS: 192 BW: 67814.98 CPU: 4805 (48.05)
STREAMS: 192 BW: 67767.61 CPU: 4803 (48.03)
STREAMS: 240 BW: 68131.36 CPU: 4805 (48.05)
STREAMS: 240 BW: 67128.16 CPU: 4804 (48.04)
STREAMS: 240 BW: 71137.51 CPU: 4804 (48.04)
STREAMS: 360 BW: 71613.75 CPU: 4804 (48.04)
STREAMS: 360 BW: 72516.28 CPU: 4803 (48.03)
STREAMS: 360 BW: 69121.28 CPU: 4803 (48.03)
STREAMS: 480 BW: 73367.51 CPU: 4805 (48.05)
STREAMS: 480 BW: 74699.93 CPU: 4804 (48.04)
STREAMS: 480 BW: 71192.96 CPU: 4809 (48.09)

zone lock bottleneck (queued_spin_lock_slowpath)

perf top (~similar for all num of streams):
   72.36%  [kernel]             [k] queued_spin_lock_slowpath
   10.23%  [kernel]             [k] copy_user_enhanced_fast_string
    2.10%  [kernel]             [k] copy_page_to_iter
    1.36%  [kernel]             [k] __list_del_entry_valid

After:
STREAMS: 48  BW: 94049.28 CPU: 1651 (16.51)
STREAMS: 48  BW: 94279.97 CPU: 1939 (19.39)
STREAMS: 48  BW: 94247.40 CPU: 1653 (16.53)
STREAMS: 96  BW: 94292.01 CPU: 1905 (19.05)
STREAMS: 96  BW: 94296.22 CPU: 1908 (19.08)
STREAMS: 96  BW: 94301.79 CPU: 1850 (18.50)
STREAMS: 192 BW: 93225.68 CPU: 2034 (20.34)
STREAMS: 192 BW: 93408.97 CPU: 1919 (19.19)
STREAMS: 192 BW: 94486.73 CPU: 2051 (20.51)
STREAMS: 240 BW: 92829.74 CPU: 2055 (20.55)
STREAMS: 240 BW: 94280.25 CPU: 2120 (21.20)
STREAMS: 240 BW: 94504.60 CPU: 2052 (20.52)
STREAMS: 360 BW: 94715.63 CPU: 2087 (20.87)
STREAMS: 360 BW: 94536.92 CPU: 2361 (23.61)
STREAMS: 360 BW: 96327.03 CPU: 2254 (22.54)
STREAMS: 480 BW: 95101.56 CPU: 2404 (24.04)
STREAMS: 480 BW: 95250.94 CPU: 2372 (23.72)
STREAMS: 480 BW: 99479.32 CPU: 2630 (26.30)
bottleneck is released, linerate is reached, significantly lower cpu.

perf top (~similar for all num of streams):  
   25.52%  [kernel]                    [k] copy_user_enhanced_fast_string
    5.93%  [kernel]                    [k] queued_spin_lock_slowpath
    3.72%  [kernel]                    [k] copy_page_to_iter
    3.58%  [kernel]                    [k] intel_idle
    3.24%  [kernel]                    [k] mlx5e_skb_from_cqe_mpwrq_linear
    2.23%  [kernel]                    [k] get_page_from_freelist
    1.94%  [kernel]                    [k] build_skb
    1.84%  [kernel]                    [k] tcp_gro_receive
    1.81%  [kernel]                    [k] poll_idle
    1.40%  [kernel]                    [k] __list_del_entry_valid
    1.07%  [kernel]                    [k] dev_gro_receive


12 queues:

Before:
STREAMS: 48  BW: 61766.86 CPU: 4158 (41.58)
STREAMS: 48  BW: 64199.99 CPU: 3661 (36.61)
STREAMS: 48  BW: 63818.20 CPU: 3929 (39.29)
STREAMS: 96  BW: 56918.94 CPU: 4779 (47.79)
STREAMS: 96  BW: 58083.64 CPU: 4733 (47.33)
STREAMS: 96  BW: 57821.44 CPU: 4711 (47.11)
STREAMS: 192 BW: 58394.17 CPU: 4795 (47.95)
STREAMS: 192 BW: 56975.54 CPU: 4800 (48.00)
STREAMS: 192 BW: 57661.05 CPU: 4798 (47.98)
STREAMS: 240 BW: 56555.59 CPU: 4801 (48.01)
STREAMS: 240 BW: 58227.32 CPU: 4799 (47.99)
STREAMS: 240 BW: 57478.13 CPU: 4805 (48.05)
STREAMS: 360 BW: 59316.66 CPU: 4804 (48.04)
STREAMS: 360 BW: 62893.67 CPU: 4803 (48.03)
STREAMS: 360 BW: 59385.07 CPU: 4804 (48.04)
STREAMS: 480 BW: 66586.20 CPU: 4805 (48.05)
STREAMS: 480 BW: 59929.05 CPU: 4803 (48.03)
STREAMS: 480 BW: 61451.14 CPU: 4804 (48.04)
STREAMS: 960 BW: 73923.86 CPU: 4805 (48.05)
STREAMS: 960 BW: 61479.10 CPU: 4804 (48.04)
STREAMS: 960 BW: 73230.86 CPU: 4804 (48.04)
bottleneck is more severe.

perf top:
   78.58%  [kernel]             [k] queued_spin_lock_slowpath
    6.56%  [kernel]             [k] copy_user_enhanced_fast_string
    1.49%  [kernel]             [k] __list_del_entry_valid
    1.10%  [kernel]             [k] copy_page_to_iter
    1.05%  [kernel]             [k] free_pcppages_bulk


After:
STREAMS: 48  BW: 94114.63 CPU: 1961 (19.61)
STREAMS: 48  BW: 94865.69 CPU: 1838 (18.38)
STREAMS: 48  BW: 94222.46 CPU: 2164 (21.64)
STREAMS: 96  BW: 94307.39 CPU: 2184 (21.84)
STREAMS: 96  BW: 93282.46 CPU: 2765 (27.65)
STREAMS: 96  BW: 93642.15 CPU: 2743 (27.43)
STREAMS: 192 BW: 92575.63 CPU: 3093 (30.93)
STREAMS: 192 BW: 92868.66 CPU: 3028 (30.28)
STREAMS: 192 BW: 92749.76 CPU: 3069 (30.69)
STREAMS: 240 BW: 92793.80 CPU: 3131 (31.31)
STREAMS: 240 BW: 93138.46 CPU: 3022 (30.22)
STREAMS: 240 BW: 92520.57 CPU: 3215 (32.15)
STREAMS: 360 BW: 93200.99 CPU: 3328 (33.28)
STREAMS: 360 BW: 92822.61 CPU: 3254 (32.54)
STREAMS: 360 BW: 93138.66 CPU: 3229 (32.29)
STREAMS: 480 BW: 93484.17 CPU: 3184 (31.84)
STREAMS: 480 BW: 92930.23 CPU: 3372 (33.72)
bottleneck released.

   28.09%  [kernel]                 [k] copy_user_enhanced_fast_string
    3.46%  [kernel]                 [k] copy_page_to_iter
    2.71%  [kernel]                 [k] intel_idle
    2.44%  [kernel]                 [k] queued_spin_lock_slowpath
    2.30%  [kernel]                 [k] mlx5e_skb_from_cqe_mpwrq_linear
    1.85%  [kernel]                 [k] mlx5e_sq_xmit
    1.69%  [kernel]                 [k] get_page_from_freelist
    1.59%  [kernel]                 [k] __list_del_entry_valid
    1.51%  [kernel]                 [k] __slab_free
    1.43%  [kernel]                 [k] __tcp_transmit_skb
    1.37%  [kernel]                 [k] tcp_rcv_established
    1.19%  [kernel]                 [k] _raw_spin_lock
    1.16%  [kernel]                 [k] tcp_recvmsg
    1.05%  [kernel]                 [k] _raw_spin_lock_bh


In addition, I tested single/small number of streams (no serious 
contention on zone lock), and observed 'similar or better' results for 
all cases.
"

The bad things are:
 - it added some overhead in compaction path where it will do merging
   for those merge-skipped order 0 pages;
 - it is unfriendly to high order page allocation since we do not do
   merging for order 0 pages now.

To see how much effect it has on compaction success rate,
mmtests/stress-highalloc is used on a Desktop machine with 8 CPUs and
4G memory. (mmtests/stress-highalloc: make N copies of kernel tree and
start building them to consume almost all memory with reclaimable file
page cache. These file page cache will not be returned to buddy so
effectively makes it a worst case for high order page workload. Then
after 5 minutes, start allocating X order-9 pages to see how well
compaction works).

With a delay of 100ms between allocations:
kernel   success_rate  average_time_of_alloc_one_hugepage
base           58%       3.95927e+06 ns
patch2/5       58%       5.45935e+06 ns
patch4/5       57%       6.59174e+06 ns

With a delay of 1ms between allocations:
kernel   success_rate  average_time_of_alloc_one_hugepage
base           53%       3.17362e+06 ns
patch2/5       44%       2.31637e+06 ns
patch4/5       59%       2.73029e+06 ns

If we compare patch4/5's result with base, it performed OK I think.
This is probably due to compaction is a heavy job so the added overhead
doesn't affect much.

Please note that for workloads that use only order0 pages, this patchset
will be a win; for workloads that use only huge pages, this patchset
will not have much impact since fragementation will only happen when a
lot of order0 pages get allocated and freed; The only workloads that will
get hurt are those that use both order0 and hugepage at the same time.

To see how much effect it has on those workloads that use both order0
and hugepage, I did the following test on a 2 sockets Intel Skylake with
112 CPUs/64G memory:
1 Break all high order pages by starting a program that consumes almost
  all memory with anonymous pages and then exit. This is used to create
  an extreme bad case for this patchset compared to vanilla that always
  does merging;
2 Start 56 processes of will-it-scale/page_fault1 that use hugepages
  through calling madvise(MADV_HUGEPAGE). To make things worse for this
  patchset, start another 56 processes of will-it-scale/page_fault1 that
  uses order 0 pages to continually cause trouble for the 56 THP users.
  Let them run for 5 minutes.

Score result(higher is better):

kernel      order0           THP
base        1522246        10540254
patch2/5    5266247 +246%   3309816 -69%
patch4/5    2234073 +47%    9610295 -8.8%

Real workloads will differ of course.

(*) Parallel free is a workload that I used to see how well parallel
freeing a large VMA can be. I tested this on a 4 sockets Intel Skylake
machine with 768G memory. The test program starts by doing a 512G anon
memory allocation with mmap() and then exit to see how fast it can exit.
The parallel is implemented inside kernel and has been posted before:
http://lkml.kernel.org/r/1489568404-7817-1-git-send-email-aaron.lu@intel.com

A branch is maintained here in case someone wants to give it a try:
https://github.com/aaronlu/linux no_merge_cluster_alloc_4.19-rc5

v4:
 - rebased to v4.19-rc5;
 - add numbers from netperf(courtesy of Tariq Toukan)

Aaron Lu (5):
  mm/page_alloc: use helper functions to add/remove a page to/from buddy
  mm/__free_one_page: skip merge for order-0 page unless compaction
    failed
  mm/rmqueue_bulk: alloc without touching individual page structure
  mm/free_pcppages_bulk: reduce overhead of cluster operation on free
    path
  mm/can_skip_merge(): make it more aggressive to attempt cluster
    alloc/free

 include/linux/mm_types.h |  10 +-
 include/linux/mmzone.h   |  35 +++
 mm/compaction.c          |  17 +-
 mm/internal.h            |  57 +++++
 mm/page_alloc.c          | 490 +++++++++++++++++++++++++++++++++++----
 5 files changed, 556 insertions(+), 53 deletions(-)

-- 
2.17.2
