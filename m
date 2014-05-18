Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2746B0036
	for <linux-mm@kvack.org>; Sun, 18 May 2014 13:36:47 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so4689408pab.22
        for <linux-mm@kvack.org>; Sun, 18 May 2014 10:36:47 -0700 (PDT)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id ym9si16461455pab.72.2014.05.18.10.36.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 18 May 2014 10:36:46 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 18 May 2014 23:06:43 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 751363940048
	for <linux-mm@kvack.org>; Sun, 18 May 2014 23:06:10 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4IHaVov54067408
	for <linux-mm@kvack.org>; Sun, 18 May 2014 23:06:31 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4IHa9Mg015280
	for <linux-mm@kvack.org>; Sun, 18 May 2014 23:06:09 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 2/3] CMA: aggressively allocate the pages on cma reserved memory when not used
In-Reply-To: <20140515015842.GB10116@js1304-P5Q-DELUXE>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com> <8761l8ah04.fsf@linux.vnet.ibm.com> <20140515015842.GB10116@js1304-P5Q-DELUXE>
Date: Sun, 18 May 2014 23:06:08 +0530
Message-ID: <87lhtzng53.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> On Wed, May 14, 2014 at 02:12:19PM +0530, Aneesh Kumar K.V wrote:
>> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
>> 
>> 
>> 
>> Another issue i am facing with the current code is the atomic allocation
>> failing even with large number of CMA pages around. In my case we never
>> reclaimed because large part of the memory is consumed by the page cache and
>> for that, free memory check doesn't include at free_cma. I will test
>> with this patchset and update here once i have the results.
>> 
>
> Hello,
>
> Could you elaborate more on your issue?
> I can't completely understand your problem.
> So your atomic allocation is movable? And although there are many free
> cma pages, that request is fail?
>

non movable atomic allocations are failing because we don't have
anything other than CMA pages left and kswapd is yet to catchup ?


  swapper/0: page allocation failure: order:0, mode:0x20
  CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.10.23-1500.pkvm2_1.5.ppc64 #1
  Call Trace:
 [c000000ffffcb610] [c000000000017330] .show_stack+0x130/0x200 (unreliable)
 [c000000ffffcb6e0] [c00000000087a8c8] .dump_stack+0x28/0x3c
 [c000000ffffcb750] [c0000000001e06f0] .warn_alloc_failed+0x110/0x160
 [c000000ffffcb800] [c0000000001e5984] .__alloc_pages_nodemask+0x9d4/0xbf0
 [c000000ffffcb9e0] [c00000000023775c] .alloc_pages_current+0xcc/0x1b0
 [c000000ffffcba80] [c0000000007098d4] .__netdev_alloc_frag+0x1a4/0x1d0
 [c000000ffffcbb20] [c00000000070d750] .__netdev_alloc_skb+0xc0/0x130
 [c000000ffffcbbb0] [d000000009639b40] .tg3_poll_work+0x900/0x1110 [tg3]
 [c000000ffffcbd10] [d00000000963a3a4] .tg3_poll_msix+0x54/0x200 [tg3]
 [c000000ffffcbdb0] [c00000000071fcec] .net_rx_action+0x1dc/0x310
 [c000000ffffcbe90] [c0000000000c1b08] .__do_softirq+0x158/0x330
 [c000000ffffcbf90] [c000000000025744] .call_do_softirq+0x14/0x24
 [c000000ffffc7e00] [c000000000011684] .do_softirq+0xf4/0x130
 [c000000ffffc7e90] [c0000000000c1f18] .irq_exit+0xc8/0x110
 [c000000ffffc7f10] [c000000000011258] .__do_irq+0xc8/0x1f0
 [c000000ffffc7f90] [c000000000025768] .call_do_irq+0x14/0x24
 [c00000000137b750] [c00000000001142c] .do_IRQ+0xac/0x130
 [c00000000137b800] [c000000000002a64]
 hardware_interrupt_common+0x164/0x180

....


 Node 0 DMA: 408*64kB (C) 408*128kB (C) 408*256kB (C) 408*512kB (C) 408*1024kB (C) 406*2048kB (C) 199*4096kB (C) 97*8192kB (C) 6*16384kB (C) =
 3348992kB
 Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=16384kB
 Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=16777216kB

meminfo details:

 MemTotal:       65875584 kB
 MemFree:         8001856 kB
 Buffers:        49330368 kB
 Cached:           178752 kB
 SwapCached:            0 kB
 Active:         28550464 kB
 Inactive:       25476416 kB
 Active(anon):    3771008 kB
 Inactive(anon):   767360 kB
 Active(file):   24779456 kB
 Inactive(file): 24709056 kB
 Unevictable:       15104 kB
 Mlocked:           15104 kB
 SwapTotal:       8384448 kB
 SwapFree:        8384448 kB
 Dirty:                 0 kB

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
