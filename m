Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 176836B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 10:12:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w12so29586833wmf.3
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 07:12:14 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b3si10491364wjb.92.2016.09.06.07.12.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 07:12:12 -0700 (PDT)
Subject: Re: [PATCH] mem-hotplug: Don't clear the only node in new_node_page()
References: <1473044391.4250.19.camel@TP420>
 <d7393a3e-73a7-7923-bc32-d4dcbc6523f9@suse.cz>
 <B1E0D42A-2F9D-4511-927B-962BC2FD13B3@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3a661375-95d9-d1ff-c799-a0c5d9cec5e3@suse.cz>
Date: Tue, 6 Sep 2016 16:12:02 +0200
MIME-Version: 1.0
In-Reply-To: <B1E0D42A-2F9D-4511-927B-962BC2FD13B3@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, John Allen <jallen@linux.vnet.ibm.com>, qiuxishi@huawei.com, iamjoonsoo.kim@lge.com, n-horiguchi@ah.jp.nec.com, rientjes@google.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 09/06/2016 10:13 AM, Li Zhong wrote:
>
>> On Sep 5, 2016, at 22:18, Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>> On 09/05/2016 04:59 AM, Li Zhong wrote:
>>> Commit 394e31d2c introduced new_node_page() for memory hotplug.
>>>
>>> In new_node_page(), the nid is cleared before calling __alloc_pages_nodemask().
>>> But if it is the only node of the system,
>>
>> So the use case is that we are partially offlining the only online node?
>
> Yes.
>>
>>> and the first round allocation fails,
>>> it will not be able to get memory from an empty nodemask, and trigger oom.
>>
>> Hmm triggering OOM due to empty nodemask sounds like a wrong thing to do. CCing some OOM experts for insight. Also OOM is skipped for __GFP_THISNODE allocations, so we might also consider the same for nodemask-constrained allocations?
>>
>>> The patch checks whether it is the last node on the system, and if it is, then
>>> don't clear the nid in the nodemask.
>>
>> I'd rather see the allocation not OOM, and rely on the fallback in new_node_page() that doesn't have nodemask. But I suspect it might also make sense to treat empty nodemask as something unexpected and put some WARN_ON (instead of OOM) in the allocator.
>
> I think it would be much easier to understand these kind of empty nodemask allocation failure with this WARN_ON(), how about something like this?
>
> ===
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a2214c6..57edf18 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3629,6 +3629,11 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
>                 .migratetype = gfpflags_to_migratetype(gfp_mask),
>         };
>
> +       if (nodemask && nodes_empty(*nodemask)) {
> +               WARN_ON(1);
> +               return NULL;
> +       }
> +
>         if (cpusets_enabled()) {
>                 alloc_mask |= __GFP_HARDWALL;
>                 alloc_flags |= ALLOC_CPUSET;
> ===
>
> If thata??s ok, maybe I can send a separate patch for this?

Something like that, but please not in the hotpath. I think the earliest 
suitable place is in __alloc_pages_slowpath() after the 
get_page_from_freelist() fails. And probably the best way would be to do 
something like pr_warn("nodemask is empty") and then clear __GFP_NOWARN 
from gfp_mask and goto nopage.

Thanks, Vlastimil

> Thanks, Zhong
>
>>
>>> Reported-by: John Allen <jallen@linux.vnet.ibm.com>
>>> Signed-off-by: Li Zhong <zhong@linux.vnet.ibm.com>
>>
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>> Fixes: 394e31d2ceb4 ("mem-hotplug: alloc new page from a nearest neighbor node when mem-offline")
>>
>>> ---
>>> mm/memory_hotplug.c | 4 +++-
>>> 1 file changed, 3 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index 41266dc..b58906b 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -1567,7 +1567,9 @@ static struct page *new_node_page(struct page *page, unsigned long private,
>>> 		return alloc_huge_page_node(page_hstate(compound_head(page)),
>>> 					next_node_in(nid, nmask));
>>>
>>> -	node_clear(nid, nmask);
>>> +	if (nid != next_node_in(nid, nmask))
>>> +		node_clear(nid, nmask);
>>> +
>>> 	if (PageHighMem(page)
>>> 	    || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
>>> 		gfp_mask |= __GFP_HIGHMEM;
>>>
>>>
>>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
