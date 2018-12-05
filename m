Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC1CE6B7343
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 03:03:28 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k66so19511675qkf.1
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 00:03:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r11si141800qvk.194.2018.12.05.00.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 00:03:28 -0800 (PST)
Subject: Re: [PATCH 1/2] admin-guide/memory-hotplug.rst: remove locking
 internal part from admin-guide
References: <20181205023426.24029-1-richard.weiyang@gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <c4f2a712-391b-60b9-64fa-bc8b6bde9994@redhat.com>
Date: Wed, 5 Dec 2018 09:03:24 +0100
MIME-Version: 1.0
In-Reply-To: <20181205023426.24029-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com, osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.vnet.ibm.com>

On 05.12.18 03:34, Wei Yang wrote:
> Locking Internal section exists in core-api documentation, which is more
> suitable for this.
> 
> This patch removes the duplication part here.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> ---
>  Documentation/admin-guide/mm/memory-hotplug.rst | 40 -------------------------
>  1 file changed, 40 deletions(-)
> 
> diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
> index 5c4432c96c4b..241f4ce1e387 100644
> --- a/Documentation/admin-guide/mm/memory-hotplug.rst
> +++ b/Documentation/admin-guide/mm/memory-hotplug.rst
> @@ -392,46 +392,6 @@ Need more implementation yet....
>   - Notification completion of remove works by OS to firmware.
>   - Guard from remove if not yet.
>  
> -
> -Locking Internals
> -=================
> -
> -When adding/removing memory that uses memory block devices (i.e. ordinary RAM),
> -the device_hotplug_lock should be held to:
> -
> -- synchronize against online/offline requests (e.g. via sysfs). This way, memory
> -  block devices can only be accessed (.online/.state attributes) by user
> -  space once memory has been fully added. And when removing memory, we
> -  know nobody is in critical sections.
> -- synchronize against CPU hotplug and similar (e.g. relevant for ACPI and PPC)
> -
> -Especially, there is a possible lock inversion that is avoided using
> -device_hotplug_lock when adding memory and user space tries to online that
> -memory faster than expected:
> -
> -- device_online() will first take the device_lock(), followed by
> -  mem_hotplug_lock
> -- add_memory_resource() will first take the mem_hotplug_lock, followed by
> -  the device_lock() (while creating the devices, during bus_add_device()).
> -
> -As the device is visible to user space before taking the device_lock(), this
> -can result in a lock inversion.
> -
> -onlining/offlining of memory should be done via device_online()/
> -device_offline() - to make sure it is properly synchronized to actions
> -via sysfs. Holding device_hotplug_lock is advised (to e.g. protect online_type)
> -
> -When adding/removing/onlining/offlining memory or adding/removing
> -heterogeneous/device memory, we should always hold the mem_hotplug_lock in
> -write mode to serialise memory hotplug (e.g. access to global/zone
> -variables).
> -
> -In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
> -mode allows for a quite efficient get_online_mems/put_online_mems
> -implementation, so code accessing memory can protect from that memory
> -vanishing.
> -
> -
>  Future Work
>  ===========
>  
> 

I reported this yesterday to Jonathan and Mike

https://lkml.org/lkml/2018/12/3/340


Anyhow

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
