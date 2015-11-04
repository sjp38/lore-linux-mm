Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 6B24082F64
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 21:45:49 -0500 (EST)
Received: by padhx2 with SMTP id hx2so29314792pad.1
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 18:45:49 -0800 (PST)
Received: from unicom145.biz-email.net (unicom145.biz-email.net. [210.51.26.145])
        by mx.google.com with ESMTPS id pz7si46895625pab.1.2015.11.03.18.45.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 03 Nov 2015 18:45:48 -0800 (PST)
Subject: Re: [PATCH V5] mm: memory hot-add: memory can not be added to movable
 zone defaultly
References: <9e3e1a14aae1a1d86cbe0ac245fa7356@s.corp-email.com>
 <1442303398-45536-1-git-send-email-liuchangsheng@inspur.com>
 <5638dd45.4aed8c0a.b4962.ffffe94a@mx.google.com>
From: Changsheng Liu <liuchangsheng@inspur.com>
Message-ID: <5639710F.7040103@inspur.com>
Date: Wed, 4 Nov 2015 10:44:31 +0800
MIME-Version: 1.0
In-Reply-To: <5638dd45.4aed8c0a.b4962.ffffe94a@mx.google.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wunan@inspur.com, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>



On 11/4 2015 0:13, Yasuaki Ishimatsu wrote:
> Hi Changsheng,
>
> According to the following thread, Tang has no objection to change kernel
> behavior since udev cannot online memory as movable.
>
> https://lkml.org/lkml/2015/10/21/159
>
> So how about reposting the v5 patch?
> I have a comment about the patch. Please see below.
      Thanksi 1/4 ?I will update the patch and repost it
> On Tue, 15 Sep 2015 03:49:58 -0400
> Changsheng Liu <liuchangsheng@inspur.com> wrote:
>
>> From: Changsheng Liu <liuchangcheng@inspur.com>
>>
>> After the user config CONFIG_MOVABLE_NODE and movable_node kernel option,
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
>> Signed-off-by: Xiaofeng Yan <yanxiaofeng@inspur.com>
>> Signed-off-by: Changsheng Liu <liuchangcheng@inspur.com>
>> Tested-by: Dongdong Fan <fandd@inspur.com>
>> ---
>>   mm/memory_hotplug.c |    8 ++++++++
>>   1 files changed, 8 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 26fbba7..d39dbb0 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1190,6 +1190,9 @@ static int check_hotplug_memory_range(u64 start, u64 size)
>>   /*
>>    * If movable zone has already been setup, newly added memory should be check.
>>    * If its address is higher than movable zone, it should be added as movable.
>> + * And if system boots up with movable_node and config CONFIG_MOVABLE_NOD and
>> + * added memory does not overlap the zone before MOVABLE_ZONE,
>> + * the memory is added as movable
>>    * Without this check, movable zone may overlap with other zone.
>>    */
>>   static int should_add_memory_movable(int nid, u64 start, u64 size)
>> @@ -1197,6 +1200,11 @@ static int should_add_memory_movable(int nid, u64 start, u64 size)
>>   	unsigned long start_pfn = start >> PAGE_SHIFT;
>>   	pg_data_t *pgdat = NODE_DATA(nid);
>>   	struct zone *movable_zone = pgdat->node_zones + ZONE_MOVABLE;
>> +	struct zone *pre_zone = pgdat->node_zones + (ZONE_MOVABLE - 1);
>> +
>> +	if (movable_node_is_enabled()
>> +	&& zone_end_pfn(pre_zone) <= start_pfn)
>> +		return 1;
> 	if (movable_node_is_enabled() && (zone_end_pfn(pre_zone) <= start_pfn))
>
> Thanks,
> Yasuaki Ishimatsu
>
>>   
>>   	if (zone_is_empty(movable_zone))
>>   		return 0;
>> -- 
>> 1.7.1
>>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
