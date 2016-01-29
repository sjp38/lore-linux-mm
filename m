Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 61E226B0255
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 16:04:11 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id 128so68669559wmz.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:04:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a65si13200190wmh.50.2016.01.29.13.04.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 29 Jan 2016 13:04:10 -0800 (PST)
Subject: Re: [RFC PATCH 0/2] avoid external fragmentation related to migration
 fallback
References: <cover.1454094692.git.chengyihetaipei@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56ABD3B8.3080306@suse.cz>
Date: Fri, 29 Jan 2016 22:03:52 +0100
MIME-Version: 1.0
In-Reply-To: <cover.1454094692.git.chengyihetaipei@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ChengYi He <chengyihetaipei@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>, Yaowei Bai <bywxiaobai@163.com>, Xishi Qiu <qiuxishi@huawei.com>, Alexander Duyck <alexander.h.duyck@redhat.com>, "'Kirill A . Shutemov'" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/29/2016 08:23 PM, ChengYi He wrote:

[...]

> Below is the root cause of this external fragmentation which could be
> observed in devices which have only one memory zone, such as some arm64
> android devices:
> 
> 1) In arm64, the first 4GB physical address space is of DMA zone. If the
> size of physical memory is less than 4GB and the whole memory is in the
> first 4GB address space, then the system will have only one DMA zone.
> 2) By default, all pageblocks are Movable.
> 3) Allocators such as slab, ion, graphics preferably allocate pages of
> Unmvoable migration type. It might fallback to allocate Movable pages
> and changes Movable pageblocks into Unmovable ones.
> 4) Movable pagesblocks will become less and less due to above reason.
> However, in android system, AnonPages request is always high. The
> Movable pages will be easily exhausted.
> 5) While Movable pages are exhausted, the Movable allocations will
> frequently fallback to allocate the largest feasiable pages of the other
> migration types. The order-2 and order-3 Unmovable pages will be split
> into smaller ones easily.
> 
> This symptom doesn't appear in arm32 android which usually has two
> memory zones including Highmem and Normal. The slab, ion, and graphics
> allocators allocate pages with flag GFP_KERNEL. Only Movable pageblocks
> in Normal zone become less, and the Movable pages in Highmem zone are
> still a lot. Thus, the Movable pages will not be easily exhausted, and
> there will not be frequent fallbacks.

Hm, this 1 zone vs 2 zones shouldn't make that much difference, unless
a) you use zone reclaim mode, or b) you have an old kernel without fair
zone allocation policy?

> Since the root cause is that fallbacks might frequently split order-2
> and order-3 pages of the other migration types. This patch tweaks
> fallback mechanism to avoid splitting order-2 and order-3 pages. while
> fallbacks happen, if the largest feasible pages are less than or queal to
> COSTLY_ORDER, i.e. 3, then try to select the smallest feasible pages. The
> reason why fallbacks prefer the largest feasiable pages is to increase
> fallback efficiency since fallbacks are likely to happen again. By
> stealing the largest feasible pages, it could reduce the oppourtunities
> of antoher fallback. Besides, it could make consecutive allocations more
> approximate to each other and make system less fragment. However, if the
> largest feasible pages are less than or equal to order-3, fallbacks might
> split it and make the upcoming order-3 page allocations fail.

In theory I don't see immediately why preferring smaller pages for
fallback should be a clear win. If it's Unmovable allocations stealing
from Movable pageblocks, the allocations will spread over larger areas
instead of being grouped together. Maybe, for Movable allocations
stealing from Unmovable allocations, preferring smallest might make
sense and be safe, as any extra fragmentation is fixable bycompaction.
Maybe it was already tried (by Joonsoo?) at some point, I'm not sure
right now.

> My test is against arm64 android devices with kernel 3.10.49. I set the
> same account and install the same applications in both deivces and use
> them synchronously.

3.10 is wayyyyyy old. There were numerous patches to compaction and
anti-fragmentation since then. IIRC the fallback decisions were quite
suboptimal at that point. I'm not even sure how you could apply your
patches to both recent kernel for posting them, and 3.10 for testing?
Is it possible to test on 4.4?

> 
> Test result:
> 1) Test without this patch:
> Most free pages are order-0 Unmovable ones. allocstall and compact_stall
> in /proc/vmstat are relatively high. And most occurances of allocstall
> are due to order-2 and order-3 allocations.
> 2) Test with this patch:
> There are more order-2 and order-3 free pages. allocstall and
> compact_stall in /proc/vmstat are relatively low. And most occurances of
> allocstall are due to order-0 allocations.
> 
> Log:
> 1) Test without this patch:
> ------ TIME (date) ------
> Fri Jul  3 16:52:55 CST 2015
> ------ UPTIME (uptime) ------
> up time: 2 days, 12:06:52, idle time: 8 days, 14:48:55, sleep time: 16:43:56
> ------ MEMORY INFO (/proc/meminfo) ------
> MemTotal:        2792568 kB
> MemFree:          194524 kB
> Buffers:            3788 kB
> Cached:           380872 kB
> ------ PAGETYPEINFO (/proc/pagetypeinfo) ------
> Free pages count per migrate type at order      0     1     2    3    4
> Node    0, zone      DMA, type    Unmovable 43852   701     0    0    0
> Node    0, zone      DMA, type  Reclaimable  3357     0     0    0    0
> Node    0, zone      DMA, type      Movable     0     5     0    0    0
> Node    0, zone      DMA, type      Reserve     0     1     5    0    0
> Node    0, zone      DMA, type          CMA     2     0     0    0    0
> Node    0, zone      DMA, type      Isolate     0     0     0    0    0
> Number of blocks type Unmovable Reclaimable Movable Reserve CMA Isolate
> Node 0, zone      DMA       362          80     170       2 113       0
> ------ VIRTUAL MEMORY STATS (/proc/vmstat) ------
> pgsteal_kswapd_dma 31755040
> pgsteal_direct_dma 34597394
> pgscan_kswapd_dma 36427664
> pgscan_direct_dma 39490711
> kswapd_low_wmark_hit_quickly 201929
> kswapd_high_wmark_hit_quickly 4858
> allocstall 664269
> allocstall_order_0 9738
> allocstall_order_1 1787
> allocstall_order_2 637608
> allocstall_order_3 15136
> pgmigrate_success 2941956
> pgmigrate_fail 1033
> compact_migrate_scanned 142985157
> compact_free_scanned 4734040109
> compact_isolated 7720362
> compact_stall 65978
> compact_fail 46084
> compact_success 11717
> 
> 2) Test with this patch:
> ------ TIME (date) ------
> Fri Jul  3 16:52:31 CST 2015
> ------ UPTIME (uptime) ------
> up time: 2 days, 12:06:30
> ------ MEMORY INFO (/proc/meminfo) ------
> MemTotal:        2792568 kB
> MemFree:           47612 kB
> Buffers:            3732 kB
> Cached:           387048 kB
> ------ PAGETYPEINFO (/proc/pagetypeinfo) ------
> Free pages count per migrate type at order      0     1     2    3    4
> Node    0, zone      DMA, type    Unmovable   272   243   126    1    0
> Node    0, zone      DMA, type  Reclaimable     0   361   168   46    0
> Node    0, zone      DMA, type      Movable  4103  1782   130    3    0
> Node    0, zone      DMA, type      Reserve     0     0     0    0    0
> Node    0, zone      DMA, type          CMA   563     2     0    0    0
> Node    0, zone      DMA, type      Isolate     0     0     0    0    0
> Number of blocks type Unmovable Reclaimable Movable Reserve CMA Isolate
> Node 0, zone      DMA       183          12     417       2 113       0
> ------ VIRTUAL MEMORY STATS (/proc/vmstat) ------
> pgsteal_kswapd_dma 50710868
> pgsteal_direct_dma 1756780
> pgscan_kswapd_dma 58281837
> pgscan_direct_dma 2022049
> kswapd_low_wmark_hit_quickly 37599
> kswapd_high_wmark_hit_quickly 13564
> allocstall 27510
> allocstall_order_0 26101
> allocstall_order_1 23
> allocstall_order_2 1224
> allocstall_order_3 162
> pgmigrate_success 63751
> pgmigrate_fail 7
> compact_migrate_scanned 278170
> compact_free_scanned 6155410
> compact_isolated 140762
> compact_stall 749
> compact_fail 54
> compact_success 22
> unevictable_pgs_culled 794
> 
> Below is the status of another device with this patch.
> /proc/pagetypeinfo shows that even if there are no Movable pages, there
> are lots of order-2 and order-3 Unmovable pages. For this case, if the
> patch is not applied, then order-2 and order-3 Unmovable pages will be
> split easily. It's likely that system perforamnce will become low due to
> severe external fragmentation.
> 
> ------ UPTIME (uptime) ------
> up time: 33 days, 08:10:58
> ------ MEMORY INFO (/proc/meminfo) ------
> MemTotal:        2792568 kB
> MemFree:           37340 kB
> Buffers:           13412 kB
> Cached:           655456 kB
> ------ PAGETYPEINFO (/proc/pagetypeinfo) ------
> Free pages count per migrate type at order      0     1     2     3    4
> Node    0, zone      DMA, type    Unmovable   718   628  1116   301    0
> Node    0, zone      DMA, type  Reclaimable   198    93     0     0    0
> Node    0, zone      DMA, type      Movable     0     0     0     0    0
> Node    0, zone      DMA, type      Reserve     0     0     0     0    0
> Node    0, zone      DMA, type          CMA    89    11     3     0    0
> Node    0, zone      DMA, type      Isolate     0     0     0     0    0
> Number of blocks type Unmovable Reclaimable Movable Reserve  CMA Isolate
> Node 0, zone      DMA       377         115     120       2  113       0
> ------ VIRTUAL MEMORY STATS (/proc/vmstat) ------
> pgsteal_direct_dma 28575192
> pgsteal_kswapd_dma 378357910
> pgscan_kswapd_dma 422765699
> pgscan_direct_dma 31860747
> kswapd_low_wmark_hit_quickly 947979
> kswapd_high_wmark_hit_quickly 139901
> allocstall 592989
> compact_migrate_scanned 149884903
> compact_free_scanned 6629299888
> compact_isolated 7699012
> compact_stall 52550
> compact_fail 45155
> compact_success 6057
> 
> ChengYi He (2):
>   mm/page_alloc: let migration fallback support pages of requested order
>   mm/page_alloc: avoid splitting pages of order 2 and 3 in migration
>     fallback
> 
>  mm/page_alloc.c | 92 ++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 59 insertions(+), 33 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
