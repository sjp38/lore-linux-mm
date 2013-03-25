Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id A30B36B0002
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 23:17:46 -0400 (EDT)
Message-ID: <514FC279.5050403@cn.fujitsu.com>
Date: Mon, 25 Mar 2013 11:20:25 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hotplug: only free wait_table if it's allocated by
 vmalloc
References: <514C2A43.3020008@huawei.com> <514C2C36.3060709@cn.fujitsu.com> <514FA535.4050503@huawei.com>
In-Reply-To: <514FA535.4050503@huawei.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@huawei.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, qiuxishi <qiuxishi@huawei.com>, linux-mm@kvack.org

On 03/25/2013 09:15 AM, Jiang Liu wrote:
> I have done a work to associate a tag with each memblock,
> may be that could be reused.

Hi Liu,

Yes, the CONFIG_HAVE_MEMBLOCK_TAG patch, I saw that before. :)

And it may have the following difference,
1) It is a flag, not a tag, which means a range may have several
    different attributes.
2) Mark node-lify-cycle data, and put it on local node, and free
    it when hot-removing.
3) Mark and reserve movable memory, as you did. :)

I'll try to find as much code that can be reused as I can. :)

Thanks for reminding me this. :)

Thanks. :)

>
> On 2013-3-22 18:02, Tang Chen wrote:
>> On 03/22/2013 05:54 PM, Jianguo Wu wrote:
>>> zone->wait_table may be allocated from bootmem, it can not be freed.
>>>
>>> Cc: Andrew Morton<akpm@linux-foundation.org>
>>> Cc: Wen Congyang<wency@cn.fujitsu.com>
>>> Cc: Tang Chen<tangchen@cn.fujitsu.com>
>>> Cc: Jiang Liu<jiang.liu@huawei.com>
>>> Cc: linux-mm@kvack.org
>>> Signed-off-by: Jianguo Wu<wujianguo@huawei.com>
>>> ---
>>>    mm/memory_hotplug.c |    6 +++++-
>>>    1 files changed, 5 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index 07b6263..91ed7cd 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -1779,7 +1779,11 @@ void try_offline_node(int nid)
>>>        for (i = 0; i<   MAX_NR_ZONES; i++) {
>>>            struct zone *zone = pgdat->node_zones + i;
>>>
>>> -        if (zone->wait_table)
>>> +        /*
>>> +         * wait_table may be allocated from boot memory,
>>> +         * here only free if it's allocated by vmalloc.
>>> +         */
>>> +        if (is_vmalloc_addr(zone->wait_table))
>>>                vfree(zone->wait_table);
>>
>> Reviewed-by: Tang Chen<tangchen@cn.fujitsu.com>
>>
>> FYI, I'm trying add a flag member into memblock to mark memory whose
>> life cycle is the same as a node. I think maybe this flag could be used
>> to free this kind of memory from bootmem.
>>
>> Thanks. :)
>>
>>
>>>        }
>>>
>>
>>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
