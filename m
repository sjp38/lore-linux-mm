Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92C0C6B30F5
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 08:17:36 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id k203so11851158qke.2
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 05:17:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 3si4062490qtb.246.2018.11.23.05.17.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 05:17:35 -0800 (PST)
Subject: Re: [PATCH v1] mm/memory_hotplug: drop "online" parameter from
 add_memory_resource()
References: <20181123123740.27652-1-david@redhat.com>
 <20181123125400.GL8625@dhcp22.suse.cz>
 <a97fcf28-ef71-2b49-c25c-bc96cff8366b@redhat.com>
 <20181123130546.GN8625@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <ad35cab2-ee1a-74a8-d039-9b79048a5580@redhat.com>
Date: Fri, 23 Nov 2018 14:17:30 +0100
MIME-Version: 1.0
In-Reply-To: <20181123130546.GN8625@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Stefano Stabellini <sstabellini@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>, Stephen Rothwell <sfr@canb.auug.org.au>

On 23.11.18 14:05, Michal Hocko wrote:
> On Fri 23-11-18 13:58:16, David Hildenbrand wrote:
>> On 23.11.18 13:54, Michal Hocko wrote:
>>> On Fri 23-11-18 13:37:40, David Hildenbrand wrote:
>>>> User space should always be in charge of how to online memory and
>>>> if memory should be onlined automatically in the kernel. Let's drop the
>>>> parameter to overwrite this - XEN passes memhp_auto_online, just like
>>>> add_memory(), so we can directly use that instead internally.
>>>
>>> Heh, I wanted to get rid of memhp_auto_online so much and now we have it
>>> in the core memory_hotplug. Not a win on my side I would say :/
>>
>> That is actually a good point: Can we remove memhp_auto_online or is it
>> already some sort of kernel ABI?
>>
>> (as it is exported via /sys/devices/system/memory/auto_online_blocks)
> 
> I have tried and there was a pushback [1]. That led to a rework of the
> sysfs semantic of onlining btw. The biggest objection against removing was
> that the userspace might be too slow to online memory and memmaps could
> eat the available memory and trigger OOM. That is why I've started
> working on the self hosted memmpas but failed to finish it. Fortunatelly
> Oscar is brave enough to continue in that work.

Yes I saw that work :) . I wonder if it is really an issue or can we
worked around. At least for paravirtualized devices (a.k.a. balloon
devices) - even without the memmaps rework.

E.g. only add a new memory block in case the old one was onlined. And we
get that information via register_memory_notifier(). So we would always
only have one memory block "pending to be onlined".

That's at least my plan for virtio-mem (add one block at a time). The
problem is if some external entity triggers memory hotplug of actual
devices you cannot simply control. Like adding a bunch of ACPI DIMMs in
one shot without userspace being able to keep up.

But the memmaps thingy still is very valuable when wanting to add memory
in an environment where we are already low on memory.

> 
> [1] http://lkml.kernel.org/r/20170227092817.23571-1-mhocko@kernel.org
> 


-- 

Thanks,

David / dhildenb
