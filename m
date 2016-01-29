Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D2E536B025B
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 14:23:28 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id uo6so46652762pac.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:23:28 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id 84si25229244pfr.114.2016.01.29.11.23.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 11:23:27 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id n128so4155809pfn.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 11:23:27 -0800 (PST)
Date: Sat, 30 Jan 2016 03:23:23 +0800
From: ChengYi He <chengyihetaipei@gmail.com>
Subject: [RFC PATCH 0/2] avoid external fragmentation related to migration
 fallback
Message-ID: <cover.1454094692.git.chengyihetaipei@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Yaowei Bai <bywxiaobai@163.com>, Xishi Qiu <qiuxishi@huawei.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, chengyihetaipei@gmail.com

The patchset tries to avoid external fragmentation related to migration
fallback. The symptom of this external fragmentation is that there are
lots of allocation failures of order-2 and order-3 pages and many
threads enter allocation slowpath to compact and direct reclaim pages.
This will degrade system performance and make it less responsive to
users. This symptom could be observed in devices which have only one
memory zone, such as some arm64 android devices. Below are two examples
in which processes fail to allocate order-2 and order-3 pages and enter
direct reclaim.

1) In arm64, THREAD_SIZE_ORDER is 2. The thread enters direct reclaim
while allocating an order-2 page as kernel stack.
[<ffffffc0002077dc>] dump_backtrace+0x0/0x134
[<ffffffc000207920>] show_stack+0x10/0x1c
[<ffffffc000cedc64>] dump_stack+0x1c/0x28
[<ffffffc0002cb6bc>] try_to_free_pages+0x5d8/0x704
[<ffffffc0002c219c>] __alloc_pages_nodemask+0x544/0x834
[<ffffffc00021a1e4>] copy_process.part.58+0xf4/0xdfc
[<ffffffc00021b000>] do_fork+0xe0/0x358
[<ffffffc00021b310>] SyS_clone+0x10/0x1c

2) The thread enters direct reclaim while allocating an order-3 page.
[<ffffffc0002077dc>] dump_backtrace+0x0/0x134
[<ffffffc000207920>] show_stack+0x10/0x1c
[<ffffffc000cedc64>] dump_stack+0x1c/0x28
[<ffffffc0002cb6bc>] try_to_free_pages+0x5d8/0x704
[<ffffffc0002c219c>] __alloc_pages_nodemask+0x544/0x834
[<ffffffc0002f0c68>] new_slab+0x80/0x23c
[<ffffffc0002f2780>] __slab_alloc.isra.50.constprop.55+0x26c/0x300
[<ffffffc0002f2abc>] kmem_cache_alloc+0x94/0x1d4
[<ffffffc0003e3a1c>] fuse_alloc_inode+0x20/0xb8
[<ffffffc00030f468>] alloc_inode+0x1c/0x90
[<ffffffc000310134>] iget5_locked+0xa0/0x1c0
[<ffffffc0003e3d00>] fuse_iget+0x60/0x1bc
[<ffffffc0003de13c>] fuse_lookup_name+0x140/0x194
[<ffffffc0003de1c4>] fuse_lookup+0x34/0x110
[<ffffffc00030236c>] lookup_real+0x30/0x54
[<ffffffc000302efc>] __lookup_hash+0x30/0x48
[<ffffffc00030377c>] lookup_slow+0x44/0xbc
[<ffffffc000304dd8>] path_lookupat+0x104/0x710
[<ffffffc00030540c>] filename_lookup.isra.32+0x28/0x74
[<ffffffc0003072cc>] user_path_at_empty+0x58/0x88
[<ffffffc000307308>] user_path_at+0xc/0x18
[<ffffffc0002f8764>] SyS_faccessat+0xc0/0x1bc

Below is the root cause of this external fragmentation which could be
observed in devices which have only one memory zone, such as some arm64
android devices:

1) In arm64, the first 4GB physical address space is of DMA zone. If the
size of physical memory is less than 4GB and the whole memory is in the
first 4GB address space, then the system will have only one DMA zone.
2) By default, all pageblocks are Movable.
3) Allocators such as slab, ion, graphics preferably allocate pages of
Unmvoable migration type. It might fallback to allocate Movable pages
and changes Movable pageblocks into Unmovable ones.
4) Movable pagesblocks will become less and less due to above reason.
However, in android system, AnonPages request is always high. The
Movable pages will be easily exhausted.
5) While Movable pages are exhausted, the Movable allocations will
frequently fallback to allocate the largest feasiable pages of the other
migration types. The order-2 and order-3 Unmovable pages will be split
into smaller ones easily.

This symptom doesn't appear in arm32 android which usually has two
memory zones including Highmem and Normal. The slab, ion, and graphics
allocators allocate pages with flag GFP_KERNEL. Only Movable pageblocks
in Normal zone become less, and the Movable pages in Highmem zone are
still a lot. Thus, the Movable pages will not be easily exhausted, and
there will not be frequent fallbacks.

Since the root cause is that fallbacks might frequently split order-2
and order-3 pages of the other migration types. This patch tweaks
fallback mechanism to avoid splitting order-2 and order-3 pages. while
fallbacks happen, if the largest feasible pages are less than or queal to
COSTLY_ORDER, i.e. 3, then try to select the smallest feasible pages. The
reason why fallbacks prefer the largest feasiable pages is to increase
fallback efficiency since fallbacks are likely to happen again. By
stealing the largest feasible pages, it could reduce the oppourtunities
of antoher fallback. Besides, it could make consecutive allocations more
approximate to each other and make system less fragment. However, if the
largest feasible pages are less than or equal to order-3, fallbacks might
split it and make the upcoming order-3 page allocations fail.

My test is against arm64 android devices with kernel 3.10.49. I set the
same account and install the same applications in both deivces and use
them synchronously.

Test result:
1) Test without this patch:
Most free pages are order-0 Unmovable ones. allocstall and compact_stall
in /proc/vmstat are relatively high. And most occurances of allocstall
are due to order-2 and order-3 allocations.
2) Test with this patch:
There are more order-2 and order-3 free pages. allocstall and
compact_stall in /proc/vmstat are relatively low. And most occurances of
allocstall are due to order-0 allocations.

Log:
1) Test without this patch:
------ TIME (date) ------
Fri Jul  3 16:52:55 CST 2015
------ UPTIME (uptime) ------
up time: 2 days, 12:06:52, idle time: 8 days, 14:48:55, sleep time: 16:43:56
------ MEMORY INFO (/proc/meminfo) ------
MemTotal:        2792568 kB
MemFree:          194524 kB
Buffers:            3788 kB
Cached:           380872 kB
------ PAGETYPEINFO (/proc/pagetypeinfo) ------
Free pages count per migrate type at order      0     1     2    3    4
Node    0, zone      DMA, type    Unmovable 43852   701     0    0    0
Node    0, zone      DMA, type  Reclaimable  3357     0     0    0    0
Node    0, zone      DMA, type      Movable     0     5     0    0    0
Node    0, zone      DMA, type      Reserve     0     1     5    0    0
Node    0, zone      DMA, type          CMA     2     0     0    0    0
Node    0, zone      DMA, type      Isolate     0     0     0    0    0
Number of blocks type Unmovable Reclaimable Movable Reserve CMA Isolate
Node 0, zone      DMA       362          80     170       2 113       0
------ VIRTUAL MEMORY STATS (/proc/vmstat) ------
pgsteal_kswapd_dma 31755040
pgsteal_direct_dma 34597394
pgscan_kswapd_dma 36427664
pgscan_direct_dma 39490711
kswapd_low_wmark_hit_quickly 201929
kswapd_high_wmark_hit_quickly 4858
allocstall 664269
allocstall_order_0 9738
allocstall_order_1 1787
allocstall_order_2 637608
allocstall_order_3 15136
pgmigrate_success 2941956
pgmigrate_fail 1033
compact_migrate_scanned 142985157
compact_free_scanned 4734040109
compact_isolated 7720362
compact_stall 65978
compact_fail 46084
compact_success 11717

2) Test with this patch:
------ TIME (date) ------
Fri Jul  3 16:52:31 CST 2015
------ UPTIME (uptime) ------
up time: 2 days, 12:06:30
------ MEMORY INFO (/proc/meminfo) ------
MemTotal:        2792568 kB
MemFree:           47612 kB
Buffers:            3732 kB
Cached:           387048 kB
------ PAGETYPEINFO (/proc/pagetypeinfo) ------
Free pages count per migrate type at order      0     1     2    3    4
Node    0, zone      DMA, type    Unmovable   272   243   126    1    0
Node    0, zone      DMA, type  Reclaimable     0   361   168   46    0
Node    0, zone      DMA, type      Movable  4103  1782   130    3    0
Node    0, zone      DMA, type      Reserve     0     0     0    0    0
Node    0, zone      DMA, type          CMA   563     2     0    0    0
Node    0, zone      DMA, type      Isolate     0     0     0    0    0
Number of blocks type Unmovable Reclaimable Movable Reserve CMA Isolate
Node 0, zone      DMA       183          12     417       2 113       0
------ VIRTUAL MEMORY STATS (/proc/vmstat) ------
pgsteal_kswapd_dma 50710868
pgsteal_direct_dma 1756780
pgscan_kswapd_dma 58281837
pgscan_direct_dma 2022049
kswapd_low_wmark_hit_quickly 37599
kswapd_high_wmark_hit_quickly 13564
allocstall 27510
allocstall_order_0 26101
allocstall_order_1 23
allocstall_order_2 1224
allocstall_order_3 162
pgmigrate_success 63751
pgmigrate_fail 7
compact_migrate_scanned 278170
compact_free_scanned 6155410
compact_isolated 140762
compact_stall 749
compact_fail 54
compact_success 22
unevictable_pgs_culled 794

Below is the status of another device with this patch.
/proc/pagetypeinfo shows that even if there are no Movable pages, there
are lots of order-2 and order-3 Unmovable pages. For this case, if the
patch is not applied, then order-2 and order-3 Unmovable pages will be
split easily. It's likely that system perforamnce will become low due to
severe external fragmentation.

------ UPTIME (uptime) ------
up time: 33 days, 08:10:58
------ MEMORY INFO (/proc/meminfo) ------
MemTotal:        2792568 kB
MemFree:           37340 kB
Buffers:           13412 kB
Cached:           655456 kB
------ PAGETYPEINFO (/proc/pagetypeinfo) ------
Free pages count per migrate type at order      0     1     2     3    4
Node    0, zone      DMA, type    Unmovable   718   628  1116   301    0
Node    0, zone      DMA, type  Reclaimable   198    93     0     0    0
Node    0, zone      DMA, type      Movable     0     0     0     0    0
Node    0, zone      DMA, type      Reserve     0     0     0     0    0
Node    0, zone      DMA, type          CMA    89    11     3     0    0
Node    0, zone      DMA, type      Isolate     0     0     0     0    0
Number of blocks type Unmovable Reclaimable Movable Reserve  CMA Isolate
Node 0, zone      DMA       377         115     120       2  113       0
------ VIRTUAL MEMORY STATS (/proc/vmstat) ------
pgsteal_direct_dma 28575192
pgsteal_kswapd_dma 378357910
pgscan_kswapd_dma 422765699
pgscan_direct_dma 31860747
kswapd_low_wmark_hit_quickly 947979
kswapd_high_wmark_hit_quickly 139901
allocstall 592989
compact_migrate_scanned 149884903
compact_free_scanned 6629299888
compact_isolated 7699012
compact_stall 52550
compact_fail 45155
compact_success 6057

ChengYi He (2):
  mm/page_alloc: let migration fallback support pages of requested order
  mm/page_alloc: avoid splitting pages of order 2 and 3 in migration
    fallback

 mm/page_alloc.c | 92 ++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 59 insertions(+), 33 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
