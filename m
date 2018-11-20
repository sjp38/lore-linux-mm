Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F19566B1DE8
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 22:22:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b7so558025eda.10
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 19:22:45 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l37sor18090746edb.2.2018.11.19.19.22.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 19:22:44 -0800 (PST)
Date: Tue, 20 Nov 2018 03:22:42 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, page_alloc: fix calculation of pgdat->nr_zones
Message-ID: <20181120032242.joduflm2tndr6imq@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181117022022.9956-1-richard.weiyang@gmail.com>
 <fc661a9c-3cde-8e43-a05d-f26817ba6e8e@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fc661a9c-3cde-8e43-a05d-f26817ba6e8e@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, dave.hansen@intel.com, linux-mm@kvack.org

On Mon, Nov 19, 2018 at 12:08:54PM +0530, Anshuman Khandual wrote:
>
>
>On 11/17/2018 07:50 AM, Wei Yang wrote:
>> Function init_currently_empty_zone() will adjust pgdat->nr_zones and set
>> it to 'zone_idx(zone) + 1' unconditionally. This is correct in the
>> normal case, while not exact in hot-plug situation.
>> 
>> This function is used in two places:
>> 
>>   * free_area_init_core()
>>   * move_pfn_range_to_zone()
>> 
>> In the first case, we are sure zone index increase monotonically. While
>> in the second one, this is under users control.
>
>So pgdat->nr_zones over counts the number of zones than what node has
>really got ? Does it affect all online options (online/online_kernel

Yes, nr_zones is not the literal meaning.

>/online_movable) if there are other higher index zones present on the
>node. 
>

The sequence matters, while usually we online page to ZONE_NORMAL, if I
am correct.

I may not get your question clearly.

>> 
>> One way to reproduce this is:
>> ----------------------------
>> 
>> 1. create a virtual machine with empty node1
>> 
>>    -m 4G,slots=32,maxmem=32G \
>>    -smp 4,maxcpus=8          \
>>    -numa node,nodeid=0,mem=4G,cpus=0-3 \
>>    -numa node,nodeid=1,mem=0G,cpus=4-7
>> 
>> 2. hot-add cpu 3-7
>> 
>>    cpu-add [3-7]
>> 
>> 2. hot-add memory to nod1
>> 
>>    object_add memory-backend-ram,id=ram0,size=1G
>>    device_add pc-dimm,id=dimm0,memdev=ram0,node=1
>> 
>> 3. online memory with following order
>> 
>>    echo online_movable > memory47/state
>>    echo online > memory40/state
>> 
>> After this, node1 will have its nr_zones equals to (ZONE_NORMAL + 1)
>> instead of (ZONE_MOVABLE + 1).
>
>Which prevents an over count I guess. Just wondering if you noticed this
>causing any real problem or some other side effects.
>

Not from my side.

I think Michal's rely may answer your question.

>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  mm/page_alloc.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>> 
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 5b7cd20dbaef..2d3c54201255 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5823,8 +5823,10 @@ void __meminit init_currently_empty_zone(struct zone *zone,
>>  					unsigned long size)
>>  {
>>  	struct pglist_data *pgdat = zone->zone_pgdat;
>> +	int zone_idx = zone_idx(zone) + 1;
>>  
>> -	pgdat->nr_zones = zone_idx(zone) + 1;
>> +	if (zone_idx > pgdat->nr_zones)
>> +		pgdat->nr_zones = zone_idx;
>
>This seems to be correct if we try to init a zone (due to memory hotplug)
>in between index 0 and pgdat->nr_zones on an already populated node.

Yes, you are right.

-- 
Wei Yang
Help you, Help me
