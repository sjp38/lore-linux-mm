Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 17BFA6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 02:11:09 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so165143250pab.1
        for <linux-mm@kvack.org>; Mon, 31 Aug 2015 23:11:08 -0700 (PDT)
Received: from unicom154.biz-email.net (bgp252.corp-email.cn. [112.65.243.252])
        by mx.google.com with ESMTPS id ys2si27960303pbc.207.2015.08.31.23.11.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Aug 2015 23:11:08 -0700 (PDT)
Received: from unicom145.biz-email.net ([192.168.0.69])
        by unicom154.biz-email.net ((Trust)) with ESMTP (SSL) id OFI00054
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 14:07:54 +0800
Subject: Re: [PATCH V4] mm: memory hot-add: memory can not be added to movable
 zone defaultly
References: <1441000720-28506-1-git-send-email-liuchangsheng@inspur.com>
 <55E451E8.1080005@suse.cz>
From: Changsheng Liu <liuchangsheng@inspur.com>
Message-ID: <55E54035.9000206@inspur.com>
Date: Tue, 1 Sep 2015 14:05:41 +0800
MIME-Version: 1.0
In-Reply-To: <55E451E8.1080005@suse.cz>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, yasu.isimatu@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>



On 8/31/2015 21:08, Vlastimil Babka wrote:
> On 08/31/2015 07:58 AM, Changsheng Liu wrote:
>> From: Changsheng Liu <liuchangcheng@inspur.com>
>>
>> After the user config CONFIG_MOVABLE_NODE and movable_node kernel 
>> option,
>> When the memory is hot added, should_add_memory_movable() return 0
>> because all zones including movable zone are empty,
>> so the memory that was hot added will be added  to the normal zone
>> and the normal zone will be created firstly.
>> But we want the whole node to be added to movable zone defaultly.
>>
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
>> But if the memory is added to normal zone defaultly,
>> the user will not offline the memory used by kernel.
>>
>> Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
>> Reviewed-by: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
>> Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
>> Reviewed-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
>
> Thanks for the credit for commenting on the previous versions of the 
> patch. However, "Reviewed-by" currently means that the reviewer 
> believes the patch is OK, so you can add it only if the reviewer 
> offers it explicitly. See Documentation/SubmittingPatches section 13. 
> There was a discussion on ksummit-discuss about adding a new tag for 
> this case, but nothing was decided yet AFAIK.
    I'm sorry about it and thanks for your review,I will update the patch.
>
>> Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
>> Tested-by: Dongdong Fan <fandd@inspur.com>
>> ---
>>   mm/memory_hotplug.c |    5 +++++
>>   1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 26fbba7..d1149ff 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1197,6 +1197,11 @@ static int should_add_memory_movable(int nid, 
>> u64 start, u64 size)
>>       unsigned long start_pfn = start >> PAGE_SHIFT;
>>       pg_data_t *pgdat = NODE_DATA(nid);
>>       struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>> +    struct zone *normal_zone = pgdat->node_zones + ZONE_NORMAL;
>> +
>> +    if (movable_node_is_enabled()
>> +    && (zone_end_pfn(normal_zone) <= start_pfn))
>> +        return 1;
>
> I wonder if the condition is true and ZONE_NORMAL exists (but it's 
> empty?) if you intend to only add movable memory to a node, so you can 
> still hot-remove it all with this patch?
     Yes
>
>
>>
>>       if (zone_is_empty(movable_zone))
>>           return 0;
>>
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
