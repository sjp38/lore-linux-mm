Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id C48576B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 05:18:02 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so51245278pdb.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 02:18:02 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id s6si19304230pdp.201.2015.08.24.02.17.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 02:18:01 -0700 (PDT)
Message-ID: <55DAE113.20503@huawei.com>
Date: Mon, 24 Aug 2015 17:17:07 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memory-hotplug: remove reset_node_managed_pages()
 and reset_node_managed_pages() in hotadd_new_pgdat()
References: <55C9A3A9.5090300@huawei.com> <55C9A554.4090509@huawei.com> <55D9A036.7060506@cn.fujitsu.com>
In-Reply-To: <55D9A036.7060506@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, izumi.taku@jp.fujitsu.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>

On 2015/8/23 18:28, Tang Chen wrote:

> Hi Shi,
> 
> Sorry for the late reply. I hope it won't be too late.
> 
> NON-ACK by me, I think.
> 
> I noticed that your first has been merged. But it won't fix the problem
> these code intended to fix.
> 
> After your patch 1, zone's spanned/present won't be set to 0 because:
> 
> free_area_init_node()
>  |--> get_pfn_range_for_nid(&start_pfn, &end_pfn)
>  |--> calculate_node_totalpages(pgdat, start_pfn, end_pfn, ...)
>          | --> zone_spanned_pages_in_node()
>                   | --> if (!node_start_pfn && !node_end_pfn) return 0;    --------    false, won't return 0
>          | --> zone_absent_pages_in_node()
>                   | --> if (!node_start_pfn && !node_end_pfn) return 0;    --------    false, won't return 0
> 

Hi Tang,

Thank you for your reply. When we add a new node, it is not included in the
memblock, I have no idea why zone_spanned_pages_in_node() and zone_absent_pages_in_node()
won't return 0. Do you add some debug code and print it?

> This is caused by a little bug in your patch 1.
> 
> You should put memblock_add_node(start, size, nid) before hotadd_new_pgdat()
> because:
> 

My patch is just add an empty node first, later __add_zone() will update the size.
But it is all right put here, and it can fix the print bug.

> hotadd_new_pgdat()
>  | --> free_area_init_node()
>           | --> get_pfn_range_for_nid()
>                    | --> find memory ranges in memblock.
> 
> | --> memblock_add_node(start, size, nid) -------------------    if you add it here, it doesn't work.
> 
> The result will be like below if we hotadd node 5.
> [ 2007.577000] Initmem setup node 5 [mem 0x0000000000000000-0xffffffffffffffff]

	pr_info("Initmem setup node %d [mem %#018Lx-%#018Lx]\n", nid,
		(u64)start_pfn << PAGE_SHIFT, ((u64)end_pfn << PAGE_SHIFT) - 1);
start_pfn and end_pfn are both 0, and 0-1 -> 0xffffffffffffffff, right?

> [ 2007.584000] On node 5 totalpages: 0
> [ 2007.585000] Built 5 zonelists in Node order, mobility grouping on.  Total pages: 32588823
> [ 2007.594000] Policy zone: Normal
> [ 2007.598000] init_memory_mapping: [mem 0x60000000000-0x607ffffffff]
> 
> 
> And also, if we merge this patch, /sys/devices/system/node/nodeX/meminfo will break.
> 

trigger call trace?

> 
> Since this patch is not merged, I think let's just drop it.
> 
> And about the little bug in your patch 1, since I'm in a hurry, I have already send a patch to fix it.
> 
> 
> Thanks. :)
> 
> 
> On 08/11/2015 03:33 PM, Xishi Qiu wrote:
>> After hotadd_new_pgdat()->free_area_init_node(), the pgdat and zone's spanned/present
>> are both 0, so remove reset_node_managed_pages() and reset_node_managed_pages().
>>
>> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
>> ---
>>   mm/memory_hotplug.c | 25 -------------------------
>>   1 file changed, 25 deletions(-)
>>
>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>> index 11f26cc..997dfad 100644
>> --- a/mm/memory_hotplug.c
>> +++ b/mm/memory_hotplug.c
>> @@ -1065,16 +1065,6 @@ int __ref online_pages(unsigned long pfn, unsigned long nr_pages, int online_typ
>>   }
>>   #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */
>>   -static void reset_node_present_pages(pg_data_t *pgdat)
>> -{
>> -    struct zone *z;
>> -
>> -    for (z = pgdat->node_zones; z < pgdat->node_zones + MAX_NR_ZONES; z++)
>> -        z->present_pages = 0;
>> -
>> -    pgdat->node_present_pages = 0;
>> -}
>> -
>>   /* we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG */
>>   static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>>   {
>> @@ -1109,21 +1099,6 @@ static pg_data_t __ref *hotadd_new_pgdat(int nid, u64 start)
>>       build_all_zonelists(pgdat, NULL);
>>       mutex_unlock(&zonelists_mutex);
>>   -    /*
>> -     * zone->managed_pages is set to an approximate value in
>> -     * free_area_init_core(), which will cause
>> -     * /sys/device/system/node/nodeX/meminfo has wrong data.
>> -     * So reset it to 0 before any memory is onlined.
>> -     */
>> -    reset_node_managed_pages(pgdat);
>> -
>> -    /*
>> -     * When memory is hot-added, all the memory is in offline state. So
>> -     * clear all zones' present_pages because they will be updated in
>> -     * online_pages() and offline_pages().
>> -     */
>> -    reset_node_present_pages(pgdat);
>> -
>>       return pgdat;
>>   }
>>   
> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
