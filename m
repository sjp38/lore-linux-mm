Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0BC86B68D1
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 06:25:24 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 92so12817058qkx.19
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 03:25:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x5si1124758qvf.112.2018.12.03.03.25.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 03:25:23 -0800 (PST)
Subject: Re: [PATCH v3 1/2] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
 <20181129155316.8174-1-richard.weiyang@gmail.com>
 <d67e3edd-5a93-c133-3b3c-d3833ed27fd5@redhat.com>
 <20181130042815.t44nroyqcqa3tpgv@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <e44018ff-b3d1-a1e2-3496-9554ff148fc4@redhat.com>
Date: Mon, 3 Dec 2018 12:25:20 +0100
MIME-Version: 1.0
In-Reply-To: <20181130042815.t44nroyqcqa3tpgv@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, dave.hansen@intel.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

On 30.11.18 05:28, Wei Yang wrote:
> On Thu, Nov 29, 2018 at 05:06:15PM +0100, David Hildenbrand wrote:
>> On 29.11.18 16:53, Wei Yang wrote:
>>> pgdat_resize_lock is used to protect pgdat's memory region information
>>> like: node_start_pfn, node_present_pages, etc. While in function
>>> sparse_add/remove_one_section(), pgdat_resize_lock is used to protect
>>> initialization/release of one mem_section. This looks not proper.
>>>
>>> Based on current implementation, even remove this lock, mem_section
>>> is still away from contention, because it is protected by global
>>> mem_hotpulg_lock.
>>
>> s/mem_hotpulg_lock/mem_hotplug_lock/
>>
>>>
>>> Following is the current call trace of sparse_add/remove_one_section()
>>>
>>>     mem_hotplug_begin()
>>>     arch_add_memory()
>>>        add_pages()
>>>            __add_pages()
>>>                __add_section()
>>>                    sparse_add_one_section()
>>>     mem_hotplug_done()
>>>
>>>     mem_hotplug_begin()
>>>     arch_remove_memory()
>>>         __remove_pages()
>>>             __remove_section()
>>>                 sparse_remove_one_section()
>>>     mem_hotplug_done()
>>>
>>> The comment above the pgdat_resize_lock also mentions "Holding this will
>>> also guarantee that any pfn_valid() stays that way.", which is true with
>>> the current implementation and false after this patch. But current
>>> implementation doesn't meet this comment. There isn't any pfn walkers
>>> to take the lock so this looks like a relict from the past. This patch
>>> also removes this comment.
>>
>> Should we start to document which lock is expected to protect what?
>>
>> I suggest adding what you just found out to
>> Documentation/admin-guide/mm/memory-hotplug.rst "Locking Internals".
>> Maybe a new subsection for mem_hotplug_lock. And eventually also
>> pgdat_resize_lock.
> 
> Well, I am not good at document writting. Below is my first trial.  Look
> forward your comments.
> 
> BTW, in case I would send a new version with this, would I put this into
> a separate one or merge this into current one?
> 
> diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
> index 5c4432c96c4b..1548820a0762 100644
> --- a/Documentation/admin-guide/mm/memory-hotplug.rst
> +++ b/Documentation/admin-guide/mm/memory-hotplug.rst

BTW, it really should go into

Documentation/core-api/memory-hotplug.rst

Something got wrong while merging this in linux-next, so now we have
duplicate documentation and the one in
Documentation/admin-guide/mm/memory-hotplug.rst about locking internals
has to go.


> @@ -396,6 +396,20 @@ Need more implementation yet....
>  Locking Internals
>  =================
>  
> +There are three locks involved in memory-hotplug, two global lock and one local
> +lock:
> +
> +- device_hotplug_lock
> +- mem_hotplug_lock
> +- device_lock
> +
> +Currently, they are twisted together for all kinds of reasons. The following
> +part is divded into device_hotplug_lock and mem_hotplug_lock parts
> +respectively to describe those tricky situations.
> +
> +device_hotplug_lock
> +---------------------
> +
>  When adding/removing memory that uses memory block devices (i.e. ordinary RAM),
>  the device_hotplug_lock should be held to:
>  
> @@ -417,14 +431,21 @@ memory faster than expected:
>  As the device is visible to user space before taking the device_lock(), this
>  can result in a lock inversion.
>  
> +mem_hotplug_lock
> +---------------------
> +
>  onlining/offlining of memory should be done via device_online()/
> -device_offline() - to make sure it is properly synchronized to actions
> -via sysfs. Holding device_hotplug_lock is advised (to e.g. protect online_type)
> +device_offline() - to make sure it is properly synchronized to actions via
> +sysfs. Even mem_hotplug_lock is used to protect the process, because of the
> +lock inversion described above, holding device_hotplug_lock is still advised
> +(to e.g. protect online_type)
>  
>  When adding/removing/onlining/offlining memory or adding/removing
>  heterogeneous/device memory, we should always hold the mem_hotplug_lock in
>  write mode to serialise memory hotplug (e.g. access to global/zone
> -variables).
> +variables). Currently, we take advantage of this to serialise sparsemem's
> +mem_section handling in sparse_add_one_section() and
> +sparse_remove_one_section().
>  
>  In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
>  mode allows for a quite efficient get_online_mems/put_online_mems
> 
>>
>>
>> Thanks,
>>
>> David / dhildenb
> 


-- 

Thanks,

David / dhildenb
