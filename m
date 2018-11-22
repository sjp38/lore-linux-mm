Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 303FA6B2D83
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 16:53:35 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id z6so7129167qtj.21
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 13:53:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q67si959575qkh.206.2018.11.22.13.53.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 13:53:34 -0800 (PST)
Subject: Re: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181122101241.7965-1-richard.weiyang@gmail.com>
 <18088694-22c8-b09b-f500-4932b6199004@redhat.com>
 <20181122212822.ypedpcbhrxpa3tyv@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <8a130cbe-8f1a-420f-9a82-f0905f4fc46d@redhat.com>
Date: Thu, 22 Nov 2018 22:53:31 +0100
MIME-Version: 1.0
In-Reply-To: <20181122212822.ypedpcbhrxpa3tyv@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On 22.11.18 22:28, Wei Yang wrote:
> On Thu, Nov 22, 2018 at 04:26:40PM +0100, David Hildenbrand wrote:
>> On 22.11.18 11:12, Wei Yang wrote:
>>> During online_pages phase, pgdat->nr_zones will be updated in case this
>>> zone is empty.
>>>
>>> Currently the online_pages phase is protected by the global lock
>>> mem_hotplug_begin(), which ensures there is no contention during the
>>> update of nr_zones. But this global lock introduces scalability issues.
>>>
>>> This patch is a preparation for removing the global lock during
>>> online_pages phase. Also this patch changes the documentation of
>>> node_size_lock to include the protectioin of nr_zones.
>>
>> I looked into locking recently, and there is more to it.
>>
>> Please read:
>>
>> commit dee6da22efac451d361f5224a60be2796d847b51
>> Author: David Hildenbrand <david@redhat.com>
>> Date:   Tue Oct 30 15:10:44 2018 -0700
>>
>>    memory-hotplug.rst: add some details about locking internals
>>    
>>    Let's document the magic a bit, especially why device_hotplug_lock is
>>    required when adding/removing memory and how it all play together with
>>    requests to online/offline memory from user space.
>>
>> Short summary: Onlining/offlining of memory requires the device_hotplug_lock
>> as of now.
>>
>> mem_hotplug_begin() is just an internal optimization. (we don't want
>> everybody to take the device lock)
>>
> 
> Hi, David
> 
> Thanks for your comment.

My last sentence should have been "we don't want everybody to take the
device hotplug lock" :) That caused confusion.

> 
> Hmm... I didn't catch your point.
> 
> Related to memory hot-plug, there are (at least) three locks,
> 
>   * device_hotplug_lock    (global)
>   * device lock            (device scope)
>   * mem_hotplug_lock       (global)
> 
> But with two different hold sequence in two cases:
> 
>   * device_online()
> 
>     device_hotplug_lock
>     device_lock
>     mem_hotplug_lock
> 
>   * add_memory_resource()
> 
>     device_hotplug_lock
>     mem_hotplug_lock
>     device_lock
>        ^
>        |
>        I don't find where this is hold in add_memory_resource(). 
>        Would you mind giving me a hint?
> 
> If my understanding is correct, what is your point?
> 

The point I was trying to make:

Right now all onlining/offlining/adding/removing is protected by the
device_hotplug_lock (and that's a good thing, things are fragile enough
already).

mem_hotplug_lock() is used in addition for get_online_mems().

"This patch is a preparation for removing the global lock during
online_pages phase." - is more like "one global lock".

> I guess your point is : just remove mem_hotplug_lock is not enough to
> resolve the scalability issue?

Depends on which scalability issue :)

Getting rid of / removing the impact of mem_hotplug_lock is certainly a
very good idea. And improves scalability of all callers of
get_online_mems(). If that is the intention, very good :)

If the intention is to make onlining/offlining more scalable (e.g. in
parallel or such), then scalability is limited by device_hotplug_lock.


> 
> Please correct me, if I am not. :-)
> 

Guess I was just wondering which scalability issue we are trying to solve :)

-- 

Thanks,

David / dhildenb
