Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 520FB6B005C
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 03:33:04 -0400 (EDT)
Date: Thu, 1 Aug 2013 16:33:30 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Possible deadloop in direct reclaim?
Message-ID: <20130801073330.GG19540@bbox>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
 <20130801054338.GD19540@bbox>
 <89813612683626448B837EE5A0B6A7CB3B630BE04E@SC-VEXCH4.marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B630BE04E@SC-VEXCH4.marvell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Wed, Jul 31, 2013 at 11:13:07PM -0700, Lisa Du wrote:
> >On Mon, Jul 22, 2013 at 09:58:17PM -0700, Lisa Du wrote:
> >> Dear Sir:
> >> Currently I met a possible deadloop in direct reclaim. After run plenty of
> >the application, system run into a status that system memory is very
> >fragmentized. Like only order-0 and order-1 memory left.
> >> Then one process required a order-2 buffer but it enter an endless direct
> >reclaim. From my trace log, I can see this loop already over 200,000 times.
> >Kswapd was first wake up and then go back to sleep as it cannot rebalance
> >this order's memory. But zone->all_unreclaimable remains 1.
> >> Though direct_reclaim every time returns no pages, but as
> >zone->all_unreclaimable = 1, so it loop again and again. Even when
> >zone->pages_scanned also becomes very large. It will block the process for
> >long time, until some watchdog thread detect this and kill this process.
> >Though it's in __alloc_pages_slowpath, but it's too slow right? Maybe cost
> >over 50 seconds or even more.
> >> I think it's not as expected right?  Can we also add below check in the
> >function all_unreclaimable() to terminate this loop?
> >>
> >> @@ -2355,6 +2355,8 @@ static bool all_unreclaimable(struct zonelist
> >*zonelist,
> >>                         continue;
> >>                 if (!zone->all_unreclaimable)
> >>                         return false;
> >> +               if (sc->nr_reclaimed == 0 && !zone_reclaimable(zone))
> >> +                       return true;
> >>         }
> >>          BTW: I'm using kernel3.4, I also try to search in the kernel3.9,
> >didn't see a possible fix for such issue. Or is anyone also met such issue
> >before? Any comment will be welcomed, looking forward to your reply!
> >>
> >> Thanks!
> >
> >I'd like to ask somethigs.
> >
> >1. Do you have enabled swap?
> I set CONFIG_SWAP=y, but I didn't really have a swap partition, that means my swap buffer size is 0;
> >2. Do you enable CONFIG_COMPACTION?
> No, I didn't enable;
> >3. Could we get your zoneinfo via cat /proc/zoneinfo?
> I dump some info from ramdump, please review:

Thanks for the information.
You said order-2 allocation was failed so I will assume preferred zone
is normal zone, not high zone because high order allocation in kernel side
isn't from high zone.

> crash> kmem -z
> NODE: 0  ZONE: 0  ADDR: c08460c0  NAME: "Normal"
>   SIZE: 192512  PRESENT: 182304  MIN/LOW/HIGH: 853/1066/1279

712M normal memory.

>   VM_STAT:
>           NR_FREE_PAGES: 16092

There are plenty of free pages over high watermark but there are heavy
fragmentation as I see below information.

So, kswapd doesn't scan this zone loop iteration is done with order-2.
I mean kswapd will scan this zone with order-0 if first iteration is
done by this

        order = sc.order = 0;
        
        goto loop_again;

But this time, zone_watermark_ok_safe with testorder = 0 on normal zone
is always true so that scanning of zone will be skipped. It means kswapd
never set zone->unreclaimable to 1.

>        NR_INACTIVE_ANON: 17
>          NR_ACTIVE_ANON: 55091
>        NR_INACTIVE_FILE: 17
>          NR_ACTIVE_FILE: 17
>          NR_UNEVICTABLE: 0
>                NR_MLOCK: 0
>           NR_ANON_PAGES: 55077

There are about 200M anon pages and few file pages.
You don't have swap so that reclaimer couldn't go far.

>          NR_FILE_MAPPED: 42
>           NR_FILE_PAGES: 69
>           NR_FILE_DIRTY: 0
>            NR_WRITEBACK: 0
>     NR_SLAB_RECLAIMABLE: 1226
>   NR_SLAB_UNRECLAIMABLE: 9373
>            NR_PAGETABLE: 2776
>         NR_KERNEL_STACK: 798
>         NR_UNSTABLE_NFS: 0
>               NR_BOUNCE: 0
>         NR_VMSCAN_WRITE: 91
>     NR_VMSCAN_IMMEDIATE: 115381
>       NR_WRITEBACK_TEMP: 0
>        NR_ISOLATED_ANON: 0
>        NR_ISOLATED_FILE: 0
>                NR_SHMEM: 31
>              NR_DIRTIED: 15256
>              NR_WRITTEN: 11981
> NR_ANON_TRANSPARENT_HUGEPAGES: 0
> 
> NODE: 0  ZONE: 1  ADDR: c08464c0  NAME: "HighMem"
>   SIZE: 69632  PRESENT: 69088  MIN/LOW/HIGH: 67/147/228
>   VM_STAT:
>           NR_FREE_PAGES: 161

Reclaimer should reclaim this zone.

>        NR_INACTIVE_ANON: 104
>          NR_ACTIVE_ANON: 46114
>        NR_INACTIVE_FILE: 9722
>          NR_ACTIVE_FILE: 12263

It seems there are lots of room to evict file pages.

>          NR_UNEVICTABLE: 168
>                NR_MLOCK: 0
>           NR_ANON_PAGES: 46102
>          NR_FILE_MAPPED: 12227
>           NR_FILE_PAGES: 22270
>           NR_FILE_DIRTY: 1
>            NR_WRITEBACK: 0
>     NR_SLAB_RECLAIMABLE: 0
>   NR_SLAB_UNRECLAIMABLE: 0
>            NR_PAGETABLE: 0
>         NR_KERNEL_STACK: 0
>         NR_UNSTABLE_NFS: 0
>               NR_BOUNCE: 0
>         NR_VMSCAN_WRITE: 0
>     NR_VMSCAN_IMMEDIATE: 0
>       NR_WRITEBACK_TEMP: 0
>        NR_ISOLATED_ANON: 0
>        NR_ISOLATED_FILE: 0
>                NR_SHMEM: 117
>              NR_DIRTIED: 7364
>              NR_WRITTEN: 6989
> NR_ANON_TRANSPARENT_HUGEPAGES: 0
> 
> ZONE  NAME        SIZE    FREE  MEM_MAP   START_PADDR  START_MAPNR
>   0   Normal    192512   16092  c1200000       0            0     
> AREA    SIZE  FREE_AREA_STRUCT  BLOCKS  PAGES
>   0       4k      c08460f0           3      3
>   0       4k      c08460f8         436    436
>   0       4k      c0846100       15237  15237
>   0       4k      c0846108           0      0
>   0       4k      c0846110           0      0
>   1       8k      c084611c          39     78
>   1       8k      c0846124           0      0
>   1       8k      c084612c         169    338
>   1       8k      c0846134           0      0
>   1       8k      c084613c           0      0
>   2      16k      c0846148           0      0
>   2      16k      c0846150           0      0
>   2      16k      c0846158           0      0
> ---------Normal zone all order > 1 has no free pages
> ZONE  NAME        SIZE    FREE  MEM_MAP   START_PADDR  START_MAPNR
>   1   HighMem    69632     161  c17e0000    2f000000      192512  
> AREA    SIZE  FREE_AREA_STRUCT  BLOCKS  PAGES
>   0       4k      c08464f0          12     12
>   0       4k      c08464f8           0      0
>   0       4k      c0846500          14     14
>   0       4k      c0846508           3      3
>   0       4k      c0846510           0      0
>   1       8k      c084651c           0      0
>   1       8k      c0846524           0      0
>   1       8k      c084652c           0      0
>   2      16k      c0846548           0      0
>   2      16k      c0846550           0      0
>   2      16k      c0846558           0      0
>   2      16k      c0846560           1      4
>   2      16k      c0846568           0      0
>   5     128k      c08465cc           0      0
>   5     128k      c08465d4           0      0
>   5     128k      c08465dc           0      0
>   5     128k      c08465e4           4    128
>   5     128k      c08465ec           0      0
> ------Other's all zero
> 
> Some other zone information I dump from pglist_data
> {
> 	watermark = {853, 1066, 1279}, 
>       percpu_drift_mark = 0, 
>       lowmem_reserve = {0, 2159, 2159}, 
>       dirty_balance_reserve = 3438, 
>       pageset = 0xc07f6144, 
>       lock = {
>         {
>           rlock = {
>             raw_lock = {
>               lock = 0
>             }, 
>             break_lock = 0
>           }
>         }
>       },       
> 	all_unreclaimable = 0,
>       reclaim_stat = {
>         recent_rotated = {903355, 960912}, 
>         recent_scanned = {932404, 2462017}
>       }, 
>       pages_scanned = 84231,

Most of scan happens in direct reclaim path, I guess
but direct reclaim couldn't reclaim any pages due to lack of swap device.

It means we have to set zone->all_unreclaimable in direct reclaim path, too.
Below patch fix your problem?
