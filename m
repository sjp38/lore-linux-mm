Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5376B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 07:13:08 -0400 (EDT)
Received: by oigm66 with SMTP id m66so3722800oig.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 04:13:08 -0700 (PDT)
Received: from unicom146.biz-email.net (unicom146.biz-email.net. [210.51.26.146])
        by mx.google.com with SMTP id gj3si1351453obb.6.2015.08.27.04.13.06
        for <linux-mm@kvack.org>;
        Thu, 27 Aug 2015 04:13:07 -0700 (PDT)
Subject: Re: [PATCH V3] mm: memory hot-add: memory can not be added to movable
 zone defaultly
References: <1440665641-3839-1-git-send-email-liuchangsheng@inspur.com>
 <55DED890.4020200@suse.cz>
From: Changsheng Liu <liuchangsheng@inspur.com>
Message-ID: <55DEEF68.4090403@inspur.com>
Date: Thu, 27 Aug 2015 19:07:20 +0800
MIME-Version: 1.0
In-Reply-To: <55DED890.4020200@suse.cz>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>



a?? 2015/8/27 17:29, Vlastimil Babka a??e??:
> On 08/27/2015 10:54 AM, Changsheng Liu wrote:
>> From: Changsheng Liu <liuchangcheng@inspur.com>
>>
>> After the user config CONFIG_MOVABLE_NODE and movable_node kernel 
>> option,
>> When the memory is hot added, should_add_memory_movable() return 0
>> because all zones including movable zone are empty,
>> so the memory that was hot added will be added  to the normal zone
>> and the normal zone will be created firstly.
>> But we want the whole node to be added to movable zone defaultly.
>
> OK it seems current behavior indeed goes against the expectations of 
> setting movable_node.
>
>> So we change should_add_memory_movable(): if the user config
>> CONFIG_MOVABLE_NODE and movable_node kernel option
>> it will always return 1 and all zones is empty at the same time,
>> so that the movable zone will be created firstly
>> and then the whole node will be added to movable zone defaultly.
>> If we want the node to be added to normal zone,
>> we can do it as follows:
>> "echo online_kernel > /sys/devices/system/memory/memoryXXX/state"
>>
>> If the memory is added to movable zone defaultly,
>> the user can offline it and add it to other zone again.
>
> Was this tested to really work as well? Per Yasuaki's explanation in 
> v2, you shouldn't create ZONE_MOVABLE before ZONE_NORMAL.
     We will test it more fully.
     There is on limit written in Documentation/memory-hotplug.txt when 
move the memory from movable zone to normal zone:
     echo online_kernel > /sys/devices/system/memory/memoryXXX/state
     (NOTE: current limit: this memory block must be adjacent to 
ZONE_NORMAL)

     The zone will be created as follows:
     First,all zones have been initialized,but all zones are empty, then 
the should_add_memory_movable() return 1 so the movable is created and 
add the whole node to movable zone.
             empty                 whole node's memory
     |-------------------|-------------------------------|---
      ZONE_NORMAL     ZONE_MOVABLE

    when we  move the memory to normal zone
empty whole node's memory
|--------------------|----------------------------------------------------:-------------------------------------------|
                                   one memory block ajacent to 
ZONE_NORMAL  :
      ZONE_NORMAL   ZONE_MOVABLE            :
                                       :
                                  one memory block 
                                             :    whole node  - one 
memory block
|-------------------------------------------------------------------------|-------------------------------------------|
      ZONE_NORMAL                           ZONE_MOVABLE
>
>> But if the memory is added to normal zone defaultly,
>> the user will not offline the memory used by kernel.
>>
>> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
>
> Interesting...
>
>> Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>i
>> Tested-by: Dongdong Fan <fandd@inspur.com>
>> ---
>>   mm/memory_hotplug.c |    3 +++
>>   1 files changed, 3 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 26fbba7..b5f14fa 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1198,6 +1198,9 @@ static int should_add_memory_movable(int nid, 
>> u64 start, u64 size)
>>       pg_data_t *pgdat = NODE_DATA(nid);
>>       struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>>
>> +    if (movable_node_is_enabled())
>> +        return 1;
>> +
>>       if (zone_is_empty(movable_zone))
>>           return 0;
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
