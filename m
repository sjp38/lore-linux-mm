Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 132056B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 11:28:09 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o18-v6so13500082qtm.11
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 08:28:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id d21-v6si1637813qtb.244.2018.08.07.08.28.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 08:28:08 -0700 (PDT)
Subject: Re: [RFC PATCH 2/3] mm/memory_hotplug: Create __shrink_pages and move
 it to offline_pages
References: <20180807133757.18352-1-osalvador@techadventures.net>
 <20180807133757.18352-3-osalvador@techadventures.net>
 <20180807135221.GA3301@redhat.com>
 <a6e4e654-fc95-497f-16f3-8c1550cf03d6@redhat.com>
 <20180807151957.GC3301@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <fd9dbd35-3bc9-ca92-0b69-b68415e27ffb@redhat.com>
Date: Tue, 7 Aug 2018 17:28:04 +0200
MIME-Version: 1.0
In-Reply-To: <20180807151957.GC3301@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: osalvador@techadventures.net, akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@oracle.com, yasu.isimatu@gmail.com, logang@deltatee.com, dave.jiang@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On 07.08.2018 17:19, Jerome Glisse wrote:
> On Tue, Aug 07, 2018 at 04:54:57PM +0200, David Hildenbrand wrote:
>> On 07.08.2018 15:52, Jerome Glisse wrote:
>>> On Tue, Aug 07, 2018 at 03:37:56PM +0200, osalvador@techadventures.net wrote:
>>>> From: Oscar Salvador <osalvador@suse.de>
>>>
>>> [...]
>>>
>>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>>> index 9bd629944c91..e33555651e46 100644
>>>> --- a/mm/memory_hotplug.c
>>>> +++ b/mm/memory_hotplug.c
>>>
>>> [...]
>>>
>>>>  /**
>>>>   * __remove_pages() - remove sections of pages from a zone
>>>> - * @zone: zone from which pages need to be removed
>>>> + * @nid: node which pages belong to
>>>>   * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
>>>>   * @nr_pages: number of pages to remove (must be multiple of section size)
>>>>   * @altmap: alternative device page map or %NULL if default memmap is used
>>>> @@ -548,7 +557,7 @@ static int __remove_section(struct zone *zone, struct mem_section *ms,
>>>>   * sure that pages are marked reserved and zones are adjust properly by
>>>>   * calling offline_pages().
>>>>   */
>>>> -int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>>>> +int __remove_pages(int nid, unsigned long phys_start_pfn,
>>>>  		 unsigned long nr_pages, struct vmem_altmap *altmap)
>>>>  {
>>>>  	unsigned long i;
>>>> @@ -556,10 +565,9 @@ int __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
>>>>  	int sections_to_remove, ret = 0;
>>>>  
>>>>  	/* In the ZONE_DEVICE case device driver owns the memory region */
>>>> -	if (is_dev_zone(zone)) {
>>>> -		if (altmap)
>>>> -			map_offset = vmem_altmap_offset(altmap);
>>>> -	} else {
>>>> +	if (altmap)
>>>> +		map_offset = vmem_altmap_offset(altmap);
>>>> +	else {
>>>
>>> This will break ZONE_DEVICE at least for HMM. While i think that
>>> altmap -> ZONE_DEVICE (ie altmap imply ZONE_DEVICE) the reverse
>>> is not true ie ZONE_DEVICE does not necessarily imply altmap. So
>>> with the above changes you change the expected behavior. You do
>>> need the zone to know if it is a ZONE_DEVICE. You could also lookup
>>> one of the struct page but my understanding is that this is what
>>> you want to avoid in the first place.
>>
>> I wonder if we could instead forward from the callers whether we are
>> dealing with ZONE_DEVICE memory (is_device ...), at least that seems
>> feasible in hmm code. Not having looked at details yet.
>>
> 
> Yes i believe this is doable, this add one more argument, to me it
> looked like passing down the zone was good idea, i think with the
> struct zone you can even remove the altmap argument.
> 
> Is there a reason why you do not want to pass down the struct zone ?

If struct pages are not initialized (for ordinary memory, because memory
was never onlined), the zone might be random, and e.g. ZONE_DEVICE
although it really isn't (or worse, a not existent zone).

The zone of ordinary memory will be decided once memory is onlined. So
the zone really should not belong into memory removal code (online in
offlining code, we would have to lie about it in case !ZONE_DEVICE here).

> 
> Cheers,
> JA(C)rA'me
> 


-- 

Thanks,

David / dhildenb
