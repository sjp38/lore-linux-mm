Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC116B576F
	for <linux-mm@kvack.org>; Fri, 30 Nov 2018 04:19:17 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id z6so4728354qtj.21
        for <linux-mm@kvack.org>; Fri, 30 Nov 2018 01:19:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q8si303801qvr.202.2018.11.30.01.19.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 30 Nov 2018 01:19:16 -0800 (PST)
Subject: Re: [PATCH v3 1/2] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
References: <20181128091243.19249-1-richard.weiyang@gmail.com>
 <20181129155316.8174-1-richard.weiyang@gmail.com>
 <d67e3edd-5a93-c133-3b3c-d3833ed27fd5@redhat.com>
 <20181130042815.t44nroyqcqa3tpgv@master>
From: David Hildenbrand <david@redhat.com>
Message-ID: <c1eab65f-b7b9-9a38-1ac5-8a23dbcb249f@redhat.com>
Date: Fri, 30 Nov 2018 10:19:13 +0100
MIME-Version: 1.0
In-Reply-To: <20181130042815.t44nroyqcqa3tpgv@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: mhocko@suse.com, dave.hansen@intel.com, osalvador@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org

>> I suggest adding what you just found out to
>> Documentation/admin-guide/mm/memory-hotplug.rst "Locking Internals".
>> Maybe a new subsection for mem_hotplug_lock. And eventually also
>> pgdat_resize_lock.
> 
> Well, I am not good at document writting. Below is my first trial.  Look
> forward your comments.

I'll have a look, maybe also Oscar and Michal can have a look. I guess
we don't have to cover all now, we can add more details as we discover them.

> 
> BTW, in case I would send a new version with this, would I put this into
> a separate one or merge this into current one?

I would put this into a separate patch.

> 
> diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
> index 5c4432c96c4b..1548820a0762 100644
> --- a/Documentation/admin-guide/mm/memory-hotplug.rst
> +++ b/Documentation/admin-guide/mm/memory-hotplug.rst
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

s/divded/divided/

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

I would this section start after the following paragraph, as most of
that paragraph belongs to the device_hotplug_lock.


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

Apart from that looks good to me, thanks!


-- 

Thanks,

David / dhildenb
