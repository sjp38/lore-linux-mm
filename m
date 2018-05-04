Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B562B6B000C
	for <linux-mm@kvack.org>; Fri,  4 May 2018 03:32:02 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id x7-v6so11545464wrn.13
        for <linux-mm@kvack.org>; Fri, 04 May 2018 00:32:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y7sor315300wmb.79.2018.05.04.00.32.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 04 May 2018 00:32:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <8b06973c-ef82-17d2-a83d-454368de75e6@suse.cz>
References: <1525408246-14768-1-git-send-email-iamjoonsoo.kim@lge.com> <8b06973c-ef82-17d2-a83d-454368de75e6@suse.cz>
From: Joonsoo Kim <js1304@gmail.com>
Date: Fri, 4 May 2018 16:31:59 +0900
Message-ID: <CAAmzW4OXLgc3ghqnvBHP7QRnjt93a3ZwREn7qH=rQFPeoC5r=w@mail.gmail.com>
Subject: Re: [PATCH] mm/page_alloc: use ac->high_zoneidx for classzone_idx
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Ye Xiaolong <xiaolong.ye@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2018-05-04 16:03 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 05/04/2018 06:30 AM, js1304@gmail.com wrote:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> Currently, we use the zone index of preferred_zone which represents
>> the best matching zone for allocation, as classzone_idx. It has a problem
>> on NUMA system with ZONE_MOVABLE.
>>
>> In NUMA system, it can be possible that each node has different populated
>> zones. For example, node 0 could have DMA/DMA32/NORMAL/MOVABLE zone and
>> node 1 could have only NORMAL zone. In this setup, allocation request
>> initiated on node 0 and the one on node 1 would have different
>> classzone_idx, 3 and 2, respectively, since their preferred_zones are
>> different. If they are handled by only their own node, there is no problem.
>> However, if they are somtimes handled by the remote node, the problem
>> would happen.
>>
>> In the following setup, allocation initiated on node 1 will have some
>> precedence than allocation initiated on node 0 when former allocation is
>> processed on node 0 due to not enough memory on node 1. They will have
>> different lowmem reserve due to their different classzone_idx thus
>> an watermark bars are also different.
>>
> ...
>
>>
>> min watermark for NORMAL zone on node 0
>> allocation initiated on node 0: 750 + 4096 = 4846
>> allocation initiated on node 1: 750 + 0 = 750
>>
>> This watermark difference could cause too many numa_miss allocation
>> in some situation and then performance could be downgraded.
>>
>> Recently, there was a regression report about this problem on CMA patches
>> since CMA memory are placed in ZONE_MOVABLE by those patches. I checked
>> that problem is disappeared with this fix that uses high_zoneidx
>> for classzone_idx.
>>
>> http://lkml.kernel.org/r/20180102063528.GG30397@yexl-desktop
>>
>> Using high_zoneidx for classzone_idx is more consistent way than previous
>> approach because system's memory layout doesn't affect anything to it.
>
> So to summarize;
> - ac->high_zoneidx is computed via the arcane gfp_zone(gfp_mask) and
> represents the highest zone the allocation can use
> - classzone_idx was supposed to be the highest zone that the allocation
> can use, that is actually available in the system. Somehow that became
> the highest zone that is available on the preferred node (in the default
> node-order zonelist), which causes the watermark inconsistencies you
> mention.

Yes! Thanks for summarize!

> I don't see a problem with your change. I would be worried about
> inflated reserves when e.g. ZONE_MOVABLE doesn't exist, but that doesn't
> seem to be the case. My laptop has empty ZONE_MOVABLE and the
> ZONE_NORMAL protection for movable is 0.

Yes! Protection number is calculated by using the number of managed page
in upper zone. If there is no memory on the upper zone, protection will be 0.

> But there had to be some reason for classzone_idx to be like this and
> not simple high_zoneidx. Maybe Mel remembers? Maybe it was important
> then, but is not anymore? Sigh, it seems to be pre-git.

Based on my code inspection, this patch changing classzone_idx implementation
would not cause the problem. I also have tried to find the reason
for classzone_idx implementation by searching git history but I can't.
As you said,
it seems to be pre-git. It would be really helpful that someone who remembers
the reason for current classzone_idx implementation teaches me the reason.

Thanks.
