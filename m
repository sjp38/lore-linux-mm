Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 999FC6B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 22:01:10 -0400 (EDT)
Received: by qkch123 with SMTP id h123so19387001qkc.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 19:01:10 -0700 (PDT)
Received: from unicom145.biz-email.net (unicom145.biz-email.net. [210.51.26.145])
        by mx.google.com with ESMTPS id 10si10352081qhy.85.2015.08.20.19.01.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 19:01:09 -0700 (PDT)
Subject: Re: [PATCH V2] mm:memory hot-add: memory can not been added to
 movable zone
References: <1440055685-6083-1-git-send-email-liuchangsheng@inspur.com>
 <55D584C7.7060101@suse.cz>
From: Changsheng Liu <liuchangsheng@inspur.com>
Message-ID: <55D68632.1030004@inspur.com>
Date: Fri, 21 Aug 2015 10:00:18 +0800
MIME-Version: 1.0
In-Reply-To: <55D584C7.7060101@suse.cz>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>


On 08/20/201515:41, Vlastimil Babka wrote:
> On 08/20/2015 09:28 AM, Changsheng Liu wrote:
>> From: Changsheng Liu <liuchangcheng@inspur.com>
>>
>> When memory is hot added, should_add_memory_movable() always returns 0
>> because the movable zone is empty, so the memory that was hot added will
>> add to the normal zone even if we want to remove the memory.
>
> I'm not expert on memory hot-plug, but since you CC'd me, I wonder... 
> the function has this comment: " * If movable zone has already been 
> setup, newly added memory should be check."
>
> So I read it like "if you want movable memory *at all*, you should do 
> some setup first" (but don't ask me what setup). After your patch, 
> every hot-added memory would be automatically movable? Isn't that 
> silently changing behavior against user expectations? What about those 
> that don't want to hot-remove and don't want movable zones (which 
> limit what kind of allocations are possible), is there a way to 
> prevent memory being movable after your patch?
     After the system startup, we hot added one cpu with memory, The 
function arch_add_memory() will add the memory to
     normal zone defaultly but now all zones including normal zone and 
movable zone are empty.So If we want to add the memory
     to movable zone we need change should_add_memory_movable().
>
>> So we change should_add_memory_movable(): if the user config
>> CONFIG_MOVABLE_NODE it will return 1 when the movable zone is empty.
>>
>> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
>> Tested-by: Dongdong Fan <fandd@inspur.com>
>> ---
>>   mm/memory_hotplug.c |    3 +--
>>   1 files changed, 1 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 26fbba7..ff658f2 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1199,8 +1199,7 @@ static int should_add_memory_movable(int nid, 
>> u64 start, u64 size)
>>       struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>>
>>       if (zone_is_empty(movable_zone))
>> -        return 0;
>> -
>> +        return IS_ENABLED(CONFIG_MOVABLE_NODE);
>>       if (movable_zone->zone_start_pfn <= start_pfn)
>>           return 1;
>>
>>
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
