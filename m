Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB8216B000A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 21:01:02 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f63-v6so120746wmi.4
        for <linux-mm@kvack.org>; Mon, 07 May 2018 18:01:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f7-v6sor10946118wrf.63.2018.05.07.18.01.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 18:01:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180504103322.2nbadmnehwdxxaso@suse.de>
References: <1525408246-14768-1-git-send-email-iamjoonsoo.kim@lge.com>
 <8b06973c-ef82-17d2-a83d-454368de75e6@suse.cz> <20180504103322.2nbadmnehwdxxaso@suse.de>
From: Joonsoo Kim <js1304@gmail.com>
Date: Tue, 8 May 2018 10:00:59 +0900
Message-ID: <CAAmzW4PKZFbAS6UEYKP2BBAqgk0=yTMuJRMTz--_0YTj-SjKvw@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: use ac->high_zoneidx for classzone_idx
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Ye Xiaolong <xiaolong.ye@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello, Mel.

Thanks for precious input!

2018-05-04 19:33 GMT+09:00 Mel Gorman <mgorman@suse.de>:
> On Fri, May 04, 2018 at 09:03:02AM +0200, Vlastimil Babka wrote:
>> > min watermark for NORMAL zone on node 0
>> > allocation initiated on node 0: 750 + 4096 = 4846
>> > allocation initiated on node 1: 750 + 0 = 750
>> >
>> > This watermark difference could cause too many numa_miss allocation
>> > in some situation and then performance could be downgraded.
>> >
>> > Recently, there was a regression report about this problem on CMA patches
>> > since CMA memory are placed in ZONE_MOVABLE by those patches. I checked
>> > that problem is disappeared with this fix that uses high_zoneidx
>> > for classzone_idx.
>> >
>> > http://lkml.kernel.org/r/20180102063528.GG30397@yexl-desktop
>> >
>> > Using high_zoneidx for classzone_idx is more consistent way than previous
>> > approach because system's memory layout doesn't affect anything to it.
>>
>> So to summarize;
>> - ac->high_zoneidx is computed via the arcane gfp_zone(gfp_mask) and
>> represents the highest zone the allocation can use
>
> It's arcane but it was simply a fast-path calculation. A much older
> definition would be easier to understand but it was slower.
>
>> - classzone_idx was supposed to be the highest zone that the allocation
>> can use, that is actually available in the system. Somehow that became
>> the highest zone that is available on the preferred node (in the default
>> node-order zonelist), which causes the watermark inconsistencies you
>> mention.
>>
>
> I think it *always* was the index of the first preferred zone of a
> zonelist. The treatment of classzone has changed a lot over the years and
> I didn't do a historical check but the general intent was always "protect
> some pages in lower zones". This was particularly important for 32-bit
> and highmem albeit that is less of a concern today. When it transferred to
> NUMA, I don't think it ever was seriously considered if it should change
> as the critical node was likely to be node 0 with all the zones and the
> remote nodes all used the highest zone. CMA/MOVABLE changed that slightly
> by allowing the possibility of node0 having a "higher" zone than every

I think that this problem is related to not only protection of the
lowmem (that is
lower than normal) but also node balance.

In fact, problem reported by zeroday-bot is caused by node1 having a
"higher" zone. In this case, node0's lowmem is protected well but
node balance of the allocation is broken since node1's normal memory cannot
be protected from allocation that is initiated on remote node.

> other node. When MOVABLE was introduced, it wasn't much of a problem as
> the purpose of MOVABLE was for systems that dynamically needed to allocate
> hugetlbfs later in the runtime but for CMA, it was a lot more critical
> for ordinary usage so this is primarily a CMA thing.

I'm not sure that it's primarily a CMA thing. There is an another critical setup
for this problem, that is, memory hotplug. If someone plug-in a new memory to
the MOVABLE zone, "higher" zone will be created in a specific node and
this problem happens. I have checked this with QEMU.

>> I don't see a problem with your change. I would be worried about
>> inflated reserves when e.g. ZONE_MOVABLE doesn't exist, but that doesn't
>> seem to be the case. My laptop has empty ZONE_MOVABLE and the
>> ZONE_NORMAL protection for movable is 0.
>>
>> But there had to be some reason for classzone_idx to be like this and
>> not simple high_zoneidx. Maybe Mel remembers? Maybe it was important
>> then, but is not anymore? Sigh, it seems to be pre-git.
>>
>
> classzone predates my involvement with Linux but I would be less concerneed
> about what the original intent was and instead ensure that classzone index
> is consistent, sane and potentially renamed while preserving the intent of
> "reserve pages in lower zones when an allocation request can use higher
> zones". While historically the critical intent was to preserve Normal and
> to a lesser extent DMA on 32-bit systems, there still should be some care
> of DMA32 so we should not lose that.

Agreed!

> With the patch, the allocator looks like it would be fine as just
> reservations change. I think it's unlikely that CMA usage will result
> in lowmem starvation.  Compaction becomes a bit weird as classzone index
> has no special meaning versis highmem and I think it'll be very easy to
> forget. Similarly, vmscan can reclaim pages from remote nodes and zones
> that are higher than the original request. That is not likely to be a
> problem but it's a change in behaviour and easy to miss.
>
> Fundamentally, I find it extremely weird we now have two variables that are
> essentially the same thing. They should be collapsed into one variable,
> renamed and documented on what the index means for page allocator,
> compaction, vmscan and the special casing around CMA.

Agreed!
I will update this patch to reflect your comment. If someone have an idea
on renaming this variable, please let me know.

Thanks.
