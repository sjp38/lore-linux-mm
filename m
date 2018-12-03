Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EFBEF6B6AF7
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 15:37:20 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id m19so7165022edc.6
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 12:37:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor8057314ede.19.2018.12.03.12.37.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 12:37:19 -0800 (PST)
Date: Mon, 3 Dec 2018 20:37:18 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
Message-ID: <20181203203718.x5fhxg7amjldvoxr@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181122101241.7965-1-richard.weiyang@gmail.com>
 <20181130065847.13714-1-richard.weiyang@gmail.com>
 <dd8f1834-769e-d341-58dc-50a81fe0c0ec@redhat.com>
 <20181201002709.ggybtqza6c7hyqrn@master>
 <9134dde5-8f8c-b985-b38b-b7697b50bf89@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9134dde5-8f8c-b985-b38b-b7697b50bf89@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon, Dec 03, 2018 at 11:09:52AM +0100, David Hildenbrand wrote:
>On 01.12.18 01:27, Wei Yang wrote:
>> On Fri, Nov 30, 2018 at 10:30:22AM +0100, David Hildenbrand wrote:
>>> On 30.11.18 07:58, Wei Yang wrote:
>>>> During online_pages phase, pgdat->nr_zones will be updated in case this
>>>> zone is empty.
>>>>
>>>> Currently the online_pages phase is protected by the global lock
>>>> mem_hotplug_begin(), which ensures there is no contention during the
>>>> update of nr_zones. But this global lock introduces scalability issues.
>>>>
>>>> The patch moves init_currently_empty_zone under both zone_span_writelock
>>>> and pgdat_resize_lock because both the pgdat state is changed (nr_zones)
>>>> and the zone's start_pfn. Also this patch changes the documentation
>>>> of node_size_lock to include the protectioin of nr_zones.
>>>
>>> s/protectioin/protection/
>>>
>>>>
>>>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>>>> Acked-by: Michal Hocko <mhocko@suse.com>
>>>> Reviewed-by: Oscar Salvador <osalvador@suse.de>
>>>> CC: David Hildenbrand <david@redhat.com>
>>>>
>>>> ---
>>>> David, I may not catch you exact comment on the code or changelog. If I
>>>> missed, just let me know.
>>>
>>> I guess I would have rewritten it to something like the following
>>>
>>> "
>>> Currently the online_pages phase is protected by two global locks
>>> (device_device_hotplug_lock and mem_hotplug_lock). Especial the latter
>>> can result in scalability issues, as it will slow down code relying on
>>> get_online_mems(). Let's prepare code for not having to rely on
>>> get_online_mems() but instead some more fine grained locks.
>> 
>> I am not sure why we specify get_online_mems() here. mem_hotplug_lock is
>> grabed in many places besides this one. In my mind, each place introduce
>> scalability issue, not only this one.
>
>mem_hotplug_lock is grabbed in write only when
>adding/removing/onlining/offlining memory and when adding/removing
>device memory. The read locker are the critical part for now.
>
>> 
>> Or you want to say, the mem_hotplug_lock will introduce scalability
>> issue in two place:
>> 
>>   * hotplug process itself
>>   * slab allocation process
>> 
>> The second one is more critical. And this is what we try to address?
>
>Indeed, especially as the first usually (except device memory) also uses
>the device_hotplug_lock, I only consider the second one critical.
>
>Feel free to change this description to whatever you like.
>As I already stated scalability of adding/removing/onlining/offlining is
>not really an issue as of now (prove me wrong :) ). So I would not care
>about including such information in this patch.
>

Thanks for your information.

Let me try to reword the changelog.

>-- 
>
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me
