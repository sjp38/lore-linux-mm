Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6FE56B6881
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 05:09:55 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id j5so12795749qtk.11
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 02:09:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s127si2667896qkf.24.2018.12.03.02.09.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 02:09:54 -0800 (PST)
Subject: Re: [PATCH v3] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
References: <20181122101241.7965-1-richard.weiyang@gmail.com>
 <20181130065847.13714-1-richard.weiyang@gmail.com>
 <dd8f1834-769e-d341-58dc-50a81fe0c0ec@redhat.com>
 <20181201002709.ggybtqza6c7hyqrn@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <9134dde5-8f8c-b985-b38b-b7697b50bf89@redhat.com>
Date: Mon, 3 Dec 2018 11:09:52 +0100
MIME-Version: 1.0
In-Reply-To: <20181201002709.ggybtqza6c7hyqrn@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On 01.12.18 01:27, Wei Yang wrote:
> On Fri, Nov 30, 2018 at 10:30:22AM +0100, David Hildenbrand wrote:
>> On 30.11.18 07:58, Wei Yang wrote:
>>> During online_pages phase, pgdat->nr_zones will be updated in case this
>>> zone is empty.
>>>
>>> Currently the online_pages phase is protected by the global lock
>>> mem_hotplug_begin(), which ensures there is no contention during the
>>> update of nr_zones. But this global lock introduces scalability issues.
>>>
>>> The patch moves init_currently_empty_zone under both zone_span_writelock
>>> and pgdat_resize_lock because both the pgdat state is changed (nr_zones)
>>> and the zone's start_pfn. Also this patch changes the documentation
>>> of node_size_lock to include the protectioin of nr_zones.
>>
>> s/protectioin/protection/
>>
>>>
>>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>>> Acked-by: Michal Hocko <mhocko@suse.com>
>>> Reviewed-by: Oscar Salvador <osalvador@suse.de>
>>> CC: David Hildenbrand <david@redhat.com>
>>>
>>> ---
>>> David, I may not catch you exact comment on the code or changelog. If I
>>> missed, just let me know.
>>
>> I guess I would have rewritten it to something like the following
>>
>> "
>> Currently the online_pages phase is protected by two global locks
>> (device_device_hotplug_lock and mem_hotplug_lock). Especial the latter
>> can result in scalability issues, as it will slow down code relying on
>> get_online_mems(). Let's prepare code for not having to rely on
>> get_online_mems() but instead some more fine grained locks.
> 
> I am not sure why we specify get_online_mems() here. mem_hotplug_lock is
> grabed in many places besides this one. In my mind, each place introduce
> scalability issue, not only this one.

mem_hotplug_lock is grabbed in write only when
adding/removing/onlining/offlining memory and when adding/removing
device memory. The read locker are the critical part for now.

> 
> Or you want to say, the mem_hotplug_lock will introduce scalability
> issue in two place:
> 
>   * hotplug process itself
>   * slab allocation process
> 
> The second one is more critical. And this is what we try to address?

Indeed, especially as the first usually (except device memory) also uses
the device_hotplug_lock, I only consider the second one critical.

Feel free to change this description to whatever you like.
As I already stated scalability of adding/removing/onlining/offlining is
not really an issue as of now (prove me wrong :) ). So I would not care
about including such information in this patch.

-- 

Thanks,

David / dhildenb
