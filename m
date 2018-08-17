Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25BAC6B075F
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 04:56:42 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id c22-v6so1210002qkb.18
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 01:56:42 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id p39-v6si1206647qtf.187.2018.08.17.01.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 01:56:41 -0700 (PDT)
Subject: Re: [PATCH RFC 1/2] drivers/base: export
 lock_device_hotplug/unlock_device_hotplug
References: <20180817075901.4608-1-david@redhat.com>
 <20180817075901.4608-2-david@redhat.com> <20180817084146.GB14725@kroah.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <5a5d73e9-e4aa-ffed-a2e3-8aef64e61923@redhat.com>
Date: Fri, 17 Aug 2018 10:56:36 +0200
MIME-Version: 1.0
In-Reply-To: <20180817084146.GB14725@kroah.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@suse.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "K . Y . Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, David Rientjes <rientjes@google.com>

On 17.08.2018 10:41, Greg Kroah-Hartman wrote:
> On Fri, Aug 17, 2018 at 09:59:00AM +0200, David Hildenbrand wrote:
>> From: Vitaly Kuznetsov <vkuznets@redhat.com>
>>
>> Well require to call add_memory()/add_memory_resource() with
>> device_hotplug_lock held, to avoid a lock inversion. Allow external modules
>> (e.g. hv_balloon) that make use of add_memory()/add_memory_resource() to
>> lock device hotplug.
>>
>> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
>> [modify patch description]
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>>  drivers/base/core.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/drivers/base/core.c b/drivers/base/core.c
>> index 04bbcd779e11..9010b9e942b5 100644
>> --- a/drivers/base/core.c
>> +++ b/drivers/base/core.c
>> @@ -700,11 +700,13 @@ void lock_device_hotplug(void)
>>  {
>>  	mutex_lock(&device_hotplug_lock);
>>  }
>> +EXPORT_SYMBOL_GPL(lock_device_hotplug);
>>  
>>  void unlock_device_hotplug(void)
>>  {
>>  	mutex_unlock(&device_hotplug_lock);
>>  }
>> +EXPORT_SYMBOL_GPL(unlock_device_hotplug);
> 
> If these are going to be "global" symbols, let's properly name them.
> device_hotplug_lock/unlock would be better.  But I am _really_ nervous
> about letting stuff outside of the driver core mess with this, as people
> better know what they are doing.

The only "problem" is that we have kernel modules (for paravirtualized
devices) that call add_memory(). This is Hyper-V right now, but we might
have other ones in the future. Without them we would not have to export
it. We might also get kernel modules that want to call remove_memory() -
which will require the device_hotplug_lock as of now.

What we could do is

a) add_memory() -> _add_memory() and don't export it
b) add_memory() takes the device_hotplug_lock and calls _add_memory() .
We export that one.
c) Use add_memory() in external modules only

Similar wrapper would be needed e.g. for remove_memory() later on.

> 
> Can't we just "lock" the memory stuff instead?  Why does the entirety of
> the driver core need to be messed with here?

The main problem is that add_memory() will first take the
mem_hotplug_lock, to later on create and attach the memory block devices
(to a bus without any drivers) via bus_probe_device(). Here, we will
take the device_lock() of these devices.

Setting a device online from user space (.online = true) will first take
the device_hotplug_lock, then the device_lock(), and _right now_ not the
mem_hotplug_lock (see cover letter/patch 2).

We have to take mem_hotplug_lock here, but doing it down in e.g.
online_pages() will right now create the possibility for a lock
inversion. So one alternative is to take the mem_hotplug_lock in core.c
before calling device_online()/device_offline(). But this feels very wrong.

Thanks!

> 
> thanks,
> 
> greg k-h
> 


-- 

Thanks,

David / dhildenb
