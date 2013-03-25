Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 035566B0027
	for <linux-mm@kvack.org>; Sun, 24 Mar 2013 21:28:27 -0400 (EDT)
Message-ID: <514FA7D4.8090906@huawei.com>
Date: Mon, 25 Mar 2013 09:26:44 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/hotplug: only free wait_table if it's allocated by
 vmalloc
References: <514C2A43.3020008@huawei.com> <514C2C36.3060709@cn.fujitsu.com>
In-Reply-To: <514C2C36.3060709@cn.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wen Congyang <wency@cn.fujitsu.com>, Liujiang <jiang.liu@huawei.com>, qiuxishi <qiuxishi@huawei.com>, linux-mm@kvack.org

On 2013/3/22 18:02, Tang Chen wrote:

> On 03/22/2013 05:54 PM, Jianguo Wu wrote:
>> zone->wait_table may be allocated from bootmem, it can not be freed.
>>
>> Cc: Andrew Morton<akpm@linux-foundation.org>
>> Cc: Wen Congyang<wency@cn.fujitsu.com>
>> Cc: Tang Chen<tangchen@cn.fujitsu.com>
>> Cc: Jiang Liu<jiang.liu@huawei.com>
>> Cc: linux-mm@kvack.org
>> Signed-off-by: Jianguo Wu<wujianguo@huawei.com>
>> ---
>>   mm/memory_hotplug.c |    6 +++++-
>>   1 files changed, 5 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 07b6263..91ed7cd 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1779,7 +1779,11 @@ void try_offline_node(int nid)
>>       for (i = 0; i<  MAX_NR_ZONES; i++) {
>>           struct zone *zone = pgdat->node_zones + i;
>>
>> -        if (zone->wait_table)
>> +        /*
>> +         * wait_table may be allocated from boot memory,
>> +         * here only free if it's allocated by vmalloc.
>> +         */
>> +        if (is_vmalloc_addr(zone->wait_table))
>>               vfree(zone->wait_table);
> 
> Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
> 
> FYI, I'm trying add a flag member into memblock to mark memory whose
> life cycle is the same as a node. I think maybe this flag could be used
> to free this kind of memory from bootmem.

And only the bootmem is aligned to PAGE_SIZE, I think.

> 
> Thanks. :)
> 
> 
>>       }
>>
> 
> -- 
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
