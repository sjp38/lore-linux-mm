Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3758C6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 10:14:00 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so73561471wid.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 07:13:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eu8si21699928wib.94.2015.08.24.07.13.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 07:13:59 -0700 (PDT)
Subject: Re: [PATCH V2] mm:memory hot-add: memory can not been added to
 movable zone
References: <1440055685-6083-1-git-send-email-liuchangsheng@inspur.com>
 <55D584C7.7060101@suse.cz> <55D68632.1030004@inspur.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DB26A4.9060302@suse.cz>
Date: Mon, 24 Aug 2015 16:13:56 +0200
MIME-Version: 1.0
In-Reply-To: <55D68632.1030004@inspur.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

On 08/21/2015 04:00 AM, Changsheng Liu wrote:
>
> On 08/20/201515:41, Vlastimil Babka wrote:
>> On 08/20/2015 09:28 AM, Changsheng Liu wrote:
>>> From: Changsheng Liu <liuchangcheng@inspur.com>
>>>
>>> When memory is hot added, should_add_memory_movable() always returns 0
>>> because the movable zone is empty, so the memory that was hot added will
>>> add to the normal zone even if we want to remove the memory.
>>
>> I'm not expert on memory hot-plug, but since you CC'd me, I wonder...
>> the function has this comment: " * If movable zone has already been
>> setup, newly added memory should be check."
>>
>> So I read it like "if you want movable memory *at all*, you should do
>> some setup first" (but don't ask me what setup). After your patch,
>> every hot-added memory would be automatically movable? Isn't that
>> silently changing behavior against user expectations? What about those
>> that don't want to hot-remove and don't want movable zones (which
>> limit what kind of allocations are possible), is there a way to
>> prevent memory being movable after your patch?
>       After the system startup, we hot added one cpu with memory, The
> function arch_add_memory() will add the memory to
>       normal zone defaultly but now all zones including normal zone and
> movable zone are empty.So If we want to add the memory
>       to movable zone we need change should_add_memory_movable().

I have poked a bit at the code and documentation, and I may still not 
have the complete picture.

Are you using movable_node kernel option to expect all hotpluggable 
memory to be movable? Then it's probably a bug. But then your patch 
should probably use movable_node_is_enabled() instead of checking just 
the config. Otherwise it would be making zone movable also for those who 
enabled the config, but don't pass the kernel option, and that would be 
wrong?

Or are you onlining memory by "echo online_movable > 
/sys/devices/system/memory/memoryXXX/state" without node_movable kernel 
option?

>>
>>> So we change should_add_memory_movable(): if the user config
>>> CONFIG_MOVABLE_NODE it will return 1 when the movable zone is empty.
>>>
>>> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
>>> Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
>>> Tested-by: Dongdong Fan <fandd@inspur.com>
>>> ---
>>>    mm/memory_hotplug.c |    3 +--
>>>    1 files changed, 1 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index 26fbba7..ff658f2 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -1199,8 +1199,7 @@ static int should_add_memory_movable(int nid,
>>> u64 start, u64 size)
>>>        struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>>>
>>>        if (zone_is_empty(movable_zone))
>>> -        return 0;
>>> -
>>> +        return IS_ENABLED(CONFIG_MOVABLE_NODE);
>>>        if (movable_zone->zone_start_pfn <= start_pfn)
>>>            return 1;
>>>
>>>
>>
>> .
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
