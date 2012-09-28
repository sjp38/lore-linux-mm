Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 30C486B0068
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 04:05:11 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so5347326pbb.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 01:05:10 -0700 (PDT)
Message-ID: <50655A29.1050303@gmail.com>
Date: Fri, 28 Sep 2012 16:04:57 +0800
From: Ni zhan Chen <nizhan.chen@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] memory_hotplug: Don't modify the zone_start_pfn outside
 of zone_span_writelock()
References: <1348728470-5580-1-git-send-email-laijs@cn.fujitsu.com> <1348728470-5580-4-git-send-email-laijs@cn.fujitsu.com> <5064525E.5080901@gmail.com> <506551CF.9090009@cn.fujitsu.com>
In-Reply-To: <506551CF.9090009@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Jiang Liu <jiang.liu@huawei.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On 09/28/2012 03:29 PM, Lai Jiangshan wrote:
> Hi, Chen,
>
> On 09/27/2012 09:19 PM, Ni zhan Chen wrote:
>> On 09/27/2012 02:47 PM, Lai Jiangshan wrote:
>>> The __add_zone() maybe call sleep-able init_currently_empty_zone()
>>> to init wait_table,
>>>
>>> But this function also modifies the zone_start_pfn without any lock.
>>> It is bugy.
>>>
>>> So we move this modification out, and we ensure the modification
>>> of zone_start_pfn is only done with zone_span_writelock() held or in booting.
>>>
>>> Since zone_start_pfn is not modified by init_currently_empty_zone()
>>> grow_zone_span() needs to check zone_start_pfn before update it.
>>>
>>> CC: Mel Gorman <mel@csn.ul.ie>
>>> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
>>> Reported-by: Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>
>>> Tested-by: Wen Congyang <wency@cn.fujitsu.com>
>>> ---
>>>    mm/memory_hotplug.c |    2 +-
>>>    mm/page_alloc.c     |    3 +--
>>>    2 files changed, 2 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index b62d429b..790561f 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -205,7 +205,7 @@ static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
>>>        zone_span_writelock(zone);
>>>          old_zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
>>> -    if (start_pfn < zone->zone_start_pfn)
>>> +    if (!zone->zone_start_pfn || start_pfn < zone->zone_start_pfn)
>>>            zone->zone_start_pfn = start_pfn;
>>>          zone->spanned_pages = max(old_zone_end_pfn, end_pfn) -
>>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>>> index c13ea75..2545013 100644
>>> --- a/mm/page_alloc.c
>>> +++ b/mm/page_alloc.c
>>> @@ -3997,8 +3997,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
>>>            return ret;
>>>        pgdat->nr_zones = zone_idx(zone) + 1;
>>>    -    zone->zone_start_pfn = zone_start_pfn;
>>> -
>> then how can mminit_dprintk print zone->zone_start_pfn ? always print 0 make no sense.
>
> The full code here:
>
> 	mminit_dprintk(MMINIT_TRACE, "memmap_init",
> 			"Initialising map node %d zone %lu pfns %lu -> %lu\n",
> 			pgdat->node_id,
> 			(unsigned long)zone_idx(zone),
> 			zone_start_pfn, (zone_start_pfn + size));
>
>
> It doesn't always print 0, it still behaves as I expected.
> Could you elaborate?

Yeah, you are right. I mean mminit_dprintk is called after 
zone->zone_start_pfn initialized to show initialising state, but after 
this patch applied zone->zone_start_pfn will not be initialized before 
this print point.

>
> Thanks,
> Lai
>
>
>>>        mminit_dprintk(MMINIT_TRACE, "memmap_init",
>>>                "Initialising map node %d zone %lu pfns %lu -> %lu\n",
>>>                pgdat->node_id,
>>> @@ -4465,6 +4463,7 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat,
>>>            ret = init_currently_empty_zone(zone, zone_start_pfn,
>>>                            size, MEMMAP_EARLY);
>>>            BUG_ON(ret);
>>> +        zone->zone_start_pfn = zone_start_pfn;
>>>            memmap_init(size, nid, j, zone_start_pfn);
>>>            zone_start_pfn += size;
>>>        }
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
