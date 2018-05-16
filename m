Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D1516B030D
	for <linux-mm@kvack.org>; Wed, 16 May 2018 05:35:59 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 54-v6so84793wrw.1
        for <linux-mm@kvack.org>; Wed, 16 May 2018 02:35:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6-v6si1671821eda.257.2018.05.16.02.35.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 May 2018 02:35:57 -0700 (PDT)
Subject: Re: [PATCH] mm/page_alloc: use ac->high_zoneidx for classzone_idx
References: <1525408246-14768-1-git-send-email-iamjoonsoo.kim@lge.com>
 <8b06973c-ef82-17d2-a83d-454368de75e6@suse.cz>
 <20180504103322.2nbadmnehwdxxaso@suse.de>
 <CAAmzW4PKZFbAS6UEYKP2BBAqgk0=yTMuJRMTz--_0YTj-SjKvw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <aa3452e1-db01-42ae-29eb-b23572e88969@suse.cz>
Date: Wed, 16 May 2018 11:35:55 +0200
MIME-Version: 1.0
In-Reply-To: <CAAmzW4PKZFbAS6UEYKP2BBAqgk0=yTMuJRMTz--_0YTj-SjKvw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Ye Xiaolong <xiaolong.ye@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 05/08/2018 03:00 AM, Joonsoo Kim wrote:
>> classzone predates my involvement with Linux but I would be less concerneed
>> about what the original intent was and instead ensure that classzone index
>> is consistent, sane and potentially renamed while preserving the intent of
>> "reserve pages in lower zones when an allocation request can use higher
>> zones". While historically the critical intent was to preserve Normal and
>> to a lesser extent DMA on 32-bit systems, there still should be some care
>> of DMA32 so we should not lose that.
> 
> Agreed!
> 
>> With the patch, the allocator looks like it would be fine as just
>> reservations change. I think it's unlikely that CMA usage will result
>> in lowmem starvation.  Compaction becomes a bit weird as classzone index
>> has no special meaning versis highmem and I think it'll be very easy to
>> forget.

I don't understand this point, what do you mean about highmem here? I've
checked and compaction seems to use classzone_idx 1) to pass it to
watermark checks as part of compaction suitability checks, i.e. the
usual lowmem protection, and 2) to limit compaction of higher zones in
kcompactd if the direct compactor can't use them anyway - seems this
part has currently the same zone imbalance problem as reclaim.

>> Similarly, vmscan can reclaim pages from remote nodes and zones
>> that are higher than the original request. That is not likely to be a
>> problem but it's a change in behaviour and easy to miss.
>>
>> Fundamentally, I find it extremely weird we now have two variables that are
>> essentially the same thing. They should be collapsed into one variable,
>> renamed and documented on what the index means for page allocator,
>> compaction, vmscan and the special casing around CMA.
> 
> Agreed!
> I will update this patch to reflect your comment. If someone have an idea
> on renaming this variable, please let me know.

Pehaps max_zone_idx? Seems a bit more clear than "high_zoneidx". And I
have no idea what was actually meant by "class".

> Thanks.
> 
