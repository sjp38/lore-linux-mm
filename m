Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 888696B0771
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 05:41:31 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id i9-v6so5884643qtj.3
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 02:41:31 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n38-v6si1537142qvc.270.2018.08.17.02.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 02:41:30 -0700 (PDT)
Subject: Re: [PATCH RFC 1/2] drivers/base: export
 lock_device_hotplug/unlock_device_hotplug
References: <20180817075901.4608-1-david@redhat.com>
 <20180817075901.4608-2-david@redhat.com> <20180817084146.GB14725@kroah.com>
 <5a5d73e9-e4aa-ffed-a2e3-8aef64e61923@redhat.com>
 <CAJZ5v0gkYV8o2Eq+EcGT=OP1tQGPGVVe3n9VGD6z7KAVVqhv9w@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <42df9062-f647-3ad6-5a07-be2b99531119@redhat.com>
Date: Fri, 17 Aug 2018 11:41:24 +0200
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0gkYV8o2Eq+EcGT=OP1tQGPGVVe3n9VGD6z7KAVVqhv9w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>, devel@linuxdriverproject.org, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, osalvador@suse.de, Vitaly Kuznetsov <vkuznets@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, David Rientjes <rientjes@google.com>

On 17.08.2018 11:03, Rafael J. Wysocki wrote:
> On Fri, Aug 17, 2018 at 10:56 AM David Hildenbrand <david@redhat.com> wrote:
>>
>> On 17.08.2018 10:41, Greg Kroah-Hartman wrote:
>>> On Fri, Aug 17, 2018 at 09:59:00AM +0200, David Hildenbrand wrote:
>>>> From: Vitaly Kuznetsov <vkuznets@redhat.com>
>>>>
>>>> Well require to call add_memory()/add_memory_resource() with
>>>> device_hotplug_lock held, to avoid a lock inversion. Allow external modules
>>>> (e.g. hv_balloon) that make use of add_memory()/add_memory_resource() to
>>>> lock device hotplug.
>>>>
>>>> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
>>>> [modify patch description]
>>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>>>> ---
>>>>  drivers/base/core.c | 2 ++
>>>>  1 file changed, 2 insertions(+)
>>>>
>>>> diff --git a/drivers/base/core.c b/drivers/base/core.c
>>>> index 04bbcd779e11..9010b9e942b5 100644
>>>> --- a/drivers/base/core.c
>>>> +++ b/drivers/base/core.c
>>>> @@ -700,11 +700,13 @@ void lock_device_hotplug(void)
>>>>  {
>>>>      mutex_lock(&device_hotplug_lock);
>>>>  }
>>>> +EXPORT_SYMBOL_GPL(lock_device_hotplug);
>>>>
>>>>  void unlock_device_hotplug(void)
>>>>  {
>>>>      mutex_unlock(&device_hotplug_lock);
>>>>  }
>>>> +EXPORT_SYMBOL_GPL(unlock_device_hotplug);
>>>
>>> If these are going to be "global" symbols, let's properly name them.
>>> device_hotplug_lock/unlock would be better.  But I am _really_ nervous
>>> about letting stuff outside of the driver core mess with this, as people
>>> better know what they are doing.
>>
>> The only "problem" is that we have kernel modules (for paravirtualized
>> devices) that call add_memory(). This is Hyper-V right now, but we might
>> have other ones in the future. Without them we would not have to export
>> it. We might also get kernel modules that want to call remove_memory() -
>> which will require the device_hotplug_lock as of now.
>>
>> What we could do is
>>
>> a) add_memory() -> _add_memory() and don't export it
>> b) add_memory() takes the device_hotplug_lock and calls _add_memory() .
>> We export that one.
>> c) Use add_memory() in external modules only
>>
>> Similar wrapper would be needed e.g. for remove_memory() later on.
> 
> That would be safer IMO, as it would prevent developers from using
> add_memory() without the lock, say.
> 
> If the lock is always going to be required for add_memory(), make it
> hard (or event impossible) to use the latter without it.
> 

If there are no objections, I'll go into that direction. But I'll wait
for more comments regarding the general concept first.

Thanks!

-- 

Thanks,

David / dhildenb
