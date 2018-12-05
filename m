Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42D546B7392
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 04:20:12 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id e29so9692246ede.19
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 01:20:12 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor10274281edq.15.2018.12.05.01.20.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Dec 2018 01:20:10 -0800 (PST)
Date: Wed, 5 Dec 2018 09:20:09 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/2] admin-guide/memory-hotplug.rst: remove locking
 internal part from admin-guide
Message-ID: <20181205092009.n5vb67bd6nuxwkcd@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181205023426.24029-1-richard.weiyang@gmail.com>
 <c4f2a712-391b-60b9-64fa-bc8b6bde9994@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c4f2a712-391b-60b9-64fa-bc8b6bde9994@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, osalvador@suse.de, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.vnet.ibm.com>

On Wed, Dec 05, 2018 at 09:03:24AM +0100, David Hildenbrand wrote:
>On 05.12.18 03:34, Wei Yang wrote:
>> Locking Internal section exists in core-api documentation, which is more
>> suitable for this.
>> 
>> This patch removes the duplication part here.
>> 
>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> ---
>>  Documentation/admin-guide/mm/memory-hotplug.rst | 40 -------------------------
>>  1 file changed, 40 deletions(-)
>> 
>> diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
>> index 5c4432c96c4b..241f4ce1e387 100644
>> --- a/Documentation/admin-guide/mm/memory-hotplug.rst
>> +++ b/Documentation/admin-guide/mm/memory-hotplug.rst
>> @@ -392,46 +392,6 @@ Need more implementation yet....
>>   - Notification completion of remove works by OS to firmware.
>>   - Guard from remove if not yet.
>>  
>> -
>> -Locking Internals
>> -=================
>> -
>> -When adding/removing memory that uses memory block devices (i.e. ordinary RAM),
>> -the device_hotplug_lock should be held to:
>> -
>> -- synchronize against online/offline requests (e.g. via sysfs). This way, memory
>> -  block devices can only be accessed (.online/.state attributes) by user
>> -  space once memory has been fully added. And when removing memory, we
>> -  know nobody is in critical sections.
>> -- synchronize against CPU hotplug and similar (e.g. relevant for ACPI and PPC)
>> -
>> -Especially, there is a possible lock inversion that is avoided using
>> -device_hotplug_lock when adding memory and user space tries to online that
>> -memory faster than expected:
>> -
>> -- device_online() will first take the device_lock(), followed by
>> -  mem_hotplug_lock
>> -- add_memory_resource() will first take the mem_hotplug_lock, followed by
>> -  the device_lock() (while creating the devices, during bus_add_device()).
>> -
>> -As the device is visible to user space before taking the device_lock(), this
>> -can result in a lock inversion.
>> -
>> -onlining/offlining of memory should be done via device_online()/
>> -device_offline() - to make sure it is properly synchronized to actions
>> -via sysfs. Holding device_hotplug_lock is advised (to e.g. protect online_type)
>> -
>> -When adding/removing/onlining/offlining memory or adding/removing
>> -heterogeneous/device memory, we should always hold the mem_hotplug_lock in
>> -write mode to serialise memory hotplug (e.g. access to global/zone
>> -variables).
>> -
>> -In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
>> -mode allows for a quite efficient get_online_mems/put_online_mems
>> -implementation, so code accessing memory can protect from that memory
>> -vanishing.
>> -
>> -
>>  Future Work
>>  ===========
>>  
>> 
>
>I reported this yesterday to Jonathan and Mike
>
>https://lkml.org/lkml/2018/12/3/340
>

Ah, Thanks :-)

>
>Anyhow
>
>Reviewed-by: David Hildenbrand <david@redhat.com>
>
>-- 
>
>Thanks,
>
>David / dhildenb

-- 
Wei Yang
Help you, Help me
