Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1E07F6B4164
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 04:24:30 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n68so18500075qkn.8
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 01:24:30 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i10si2619676qvo.173.2018.11.26.01.24.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 01:24:29 -0800 (PST)
Subject: Re: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
 <20181122101241.7965-1-richard.weiyang@gmail.com>
 <18088694-22c8-b09b-f500-4932b6199004@redhat.com>
 <20181123084201.GA8625@dhcp22.suse.cz>
 <ca7d2320-6263-f213-d064-b5dc404bfa07@redhat.com>
 <20181126014451.grrdei2luujiqwrh@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <424dd9eb-7295-5cf4-98b2-7a1bfd53b32e@redhat.com>
Date: Mon, 26 Nov 2018 10:24:26 +0100
MIME-Version: 1.0
In-Reply-To: <20181126014451.grrdei2luujiqwrh@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On 26.11.18 02:44, Wei Yang wrote:
> On Fri, Nov 23, 2018 at 09:46:52AM +0100, David Hildenbrand wrote:
>> On 23.11.18 09:42, Michal Hocko wrote:
>>> On Thu 22-11-18 16:26:40, David Hildenbrand wrote:
>>>> On 22.11.18 11:12, Wei Yang wrote:
>>>>> During online_pages phase, pgdat->nr_zones will be updated in case this
>>>>> zone is empty.
>>>>>
>>>>> Currently the online_pages phase is protected by the global lock
>>>>> mem_hotplug_begin(), which ensures there is no contention during the
>>>>> update of nr_zones. But this global lock introduces scalability issues.
>>>>>
>>>>> This patch is a preparation for removing the global lock during
>>>>> online_pages phase. Also this patch changes the documentation of
>>>>> node_size_lock to include the protectioin of nr_zones.
>>>>
>>>> I looked into locking recently, and there is more to it.
>>>>
>>>> Please read:
>>>>
>>>> commit dee6da22efac451d361f5224a60be2796d847b51
>>>> Author: David Hildenbrand <david@redhat.com>
>>>> Date:   Tue Oct 30 15:10:44 2018 -0700
>>>>
>>>>     memory-hotplug.rst: add some details about locking internals
>>>>     
>>>>     Let's document the magic a bit, especially why device_hotplug_lock is
>>>>     required when adding/removing memory and how it all play together with
>>>>     requests to online/offline memory from user space.
>>>>
>>>> Short summary: Onlining/offlining of memory requires the device_hotplug_lock
>>>> as of now.
>>>
>>> Well, I would tend to disagree here. You might be describing the current
>>> state of art but the device_hotplug_lock doesn't make much sense for the
>>> memory hotplug in principle. There is absolutely nothing in the core MM
>>
>> There are collisions with CPU hotplug that require this lock (when nodes
>> come and go as far as I remember). And there is the problematic lock
>> inversion that can happen when adding/remving memory. This all has to be
>> sorted out, we'll have to see if we really need it for
>> onlining/offlining, though, however ...
>>
> 
> Seems I get a little understanding on this part.
> 
> There are two hotplug:
>    * CPU hotplug 
>    * Memory hotplug.
> 
> There are two phase for Memory hotplug:
>    * physical add/remove 
>    * logical online/offline
> 
> All of them are protected by device_hotplug_lock now, so we need to be
> careful to release this in any case. Is my understanding correct?

Yes, e.g. the acpi driver always held the device_hotplug_lock (due to
possible problems with concurrent cpu/memory hot(un)plug). Onlining
offlining of devices (including cpu/memory) from user space always held
the device_hotplug_lock. So this part was executed sequentially for a
long time.

I recently made sure that any adding/removing/onlining/offlining
correctly grabs the device_hotplug_lock AND the mem_hotplug_lock in any
case (because it was inconsistent and broken), so it is all executed
sequentially.

So when getting rid of mem_hotplug_lock we only have to care about all
users that don't take the device_hotplug_lock.

> 
>>> that would require this lock. The current state just uses a BKL in some
>>> sense and we really want to get rid of that longterm. This patch is a tiny
>>> step in that direction and I suspect many more will need to come on the
>>> way. We really want to end up with a clear scope of each lock being
>>> taken. A project for a brave soul...
>>
>> ... for now I don't consider "optimize for parallel
>> onlining/offlining/adding/removing of memory and cpus" really necessary.
>> What is necessary indeed is to not slowdown the whole system just
>> because some memory is coming/going. Therefore I agree, this patch is a
>> step into the right direction.
>>
> 
> Agree.
> 
> The target is to accelerate the hot-plug without slow down the normal
> process. 

Indeed!


-- 

Thanks,

David / dhildenb
