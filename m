Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id E5A4E6B0036
	for <linux-mm@kvack.org>; Sun, 18 May 2014 22:26:55 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so5133058pbb.36
        for <linux-mm@kvack.org>; Sun, 18 May 2014 19:26:55 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id xq7si697530pab.27.2014.05.18.19.26.53
        for <linux-mm@kvack.org>;
        Sun, 18 May 2014 19:26:55 -0700 (PDT)
Date: Mon, 19 May 2014 11:29:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Message-ID: <20140519022922.GC19615@js1304-P5Q-DELUXE>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com>
 <8761l8ah04.fsf@linux.vnet.ibm.com>
 <20140515015842.GB10116@js1304-P5Q-DELUXE>
 <87lhtzng53.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lhtzng53.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, May 18, 2014 at 11:06:08PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > On Wed, May 14, 2014 at 02:12:19PM +0530, Aneesh Kumar K.V wrote:
> >> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> >> 
> >> 
> >> 
> >> Another issue i am facing with the current code is the atomic allocation
> >> failing even with large number of CMA pages around. In my case we never
> >> reclaimed because large part of the memory is consumed by the page cache and
> >> for that, free memory check doesn't include at free_cma. I will test
> >> with this patchset and update here once i have the results.
> >> 
> >
> > Hello,
> >
> > Could you elaborate more on your issue?
> > I can't completely understand your problem.
> > So your atomic allocation is movable? And although there are many free
> > cma pages, that request is fail?
> >
> 
> non movable atomic allocations are failing because we don't have
> anything other than CMA pages left and kswapd is yet to catchup ?
> 
> 
>   swapper/0: page allocation failure: order:0, mode:0x20
>   CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.23-1500.pkvm2_1.5.ppc64 #1
>   Call Trace:
>  [c000000ffffcb610] [c000000000017330] .show_stack+0x130/0x200 (unreliable)
>  [c000000ffffcb6e0] [c00000000087a8c8] .dump_stack+0x28/0x3c
>  [c000000ffffcb750] [c0000000001e06f0] .warn_alloc_failed+0x110/0x160
>  [c000000ffffcb800] [c0000000001e5984] .__alloc_pages_nodemask+0x9d4/0xbf0
>  [c000000ffffcb9e0] [c00000000023775c] .alloc_pages_current+0xcc/0x1b0
>  [c000000ffffcba80] [c0000000007098d4] .__netdev_alloc_frag+0x1a4/0x1d0
>  [c000000ffffcbb20] [c00000000070d750] .__netdev_alloc_skb+0xc0/0x130
>  [c000000ffffcbbb0] [d000000009639b40] .tg3_poll_work+0x900/0x1110 [tg3]
>  [c000000ffffcbd10] [d00000000963a3a4] .tg3_poll_msix+0x54/0x200 [tg3]
>  [c000000ffffcbdb0] [c00000000071fcec] .net_rx_action+0x1dc/0x310
>  [c000000ffffcbe90] [c0000000000c1b08] .__do_softirq+0x158/0x330
>  [c000000ffffcbf90] [c000000000025744] .call_do_softirq+0x14/0x24
>  [c000000ffffc7e00] [c000000000011684] .do_softirq+0xf4/0x130
>  [c000000ffffc7e90] [c0000000000c1f18] .irq_exit+0xc8/0x110
>  [c000000ffffc7f10] [c000000000011258] .__do_irq+0xc8/0x1f0
>  [c000000ffffc7f90] [c000000000025768] .call_do_irq+0x14/0x24
>  [c00000000137b750] [c00000000001142c] .do_IRQ+0xac/0x130
>  [c00000000137b800] [c000000000002a64]
>  hardware_interrupt_common+0x164/0x180
> 
> ....
> 
> 
>  Node 0 DMA: 408*64kB (C) 408*128kB (C) 408*256kB (C) 408*512kB (C) 408*1024kB (C) 406*2048kB (C) 199*4096kB (C) 97*8192kB (C) 6*16384kB (C) =
>  3348992kB
>  Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=16384kB
>  Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=16777216kB
> 
> meminfo details:
> 
>  MemTotal:       65875584 kB
>  MemFree:         8001856 kB
>  Buffers:        49330368 kB
>  Cached:           178752 kB
>  SwapCached:            0 kB
>  Active:         28550464 kB
>  Inactive:       25476416 kB
>  Active(anon):    3771008 kB
>  Inactive(anon):   767360 kB
>  Active(file):   24779456 kB
>  Inactive(file): 24709056 kB
>  Unevictable:       15104 kB
>  Mlocked:           15104 kB
>  SwapTotal:       8384448 kB
>  SwapFree:        8384448 kB
>  Dirty:                 0 kB
> 
> -aneesh
> 

Hello,

I think that third patch in this patchset would solve this problem.
Your problem may occur in following scenario.

1. Unmovable, reclaimable page are nearly empty.
2. There are some movable pages, so watermark checking is ok.
3. A lot of movable allocations are requested.
4. Most of movable pages are allocated.
5. But, watermark checking is still ok, because we have a lot of
   free cma pages and this allocation is for movable type.
   No waking up kswapd.
6. non-movable atomic allocation request => fail

So, the problem is in step #5. Althoght we have enough pages for
movable type, we should prepare allocation request for the others.
With my third patch, kswapd could be woken by movable allocation, so
your problem would disappreared.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
