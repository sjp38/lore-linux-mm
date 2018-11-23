Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5066B2FD0
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 07:11:35 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b26so8663424qtq.14
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 04:11:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c4si5077502qtj.64.2018.11.23.04.11.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Nov 2018 04:11:33 -0800 (PST)
Subject: Re: [RFC PATCH 0/4] mm, memory_hotplug: allocate memmap from hotadded
 memory
References: <20181116101222.16581-1-osalvador@suse.com>
 <2571308d-0460-e8b9-ad40-75d6b13b2d09@redhat.com>
 <20181123115519.2dnzscmmgv63fdub@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Message-ID: <729f2126-c4ba-e764-3c71-7bd711e44187@redhat.com>
Date: Fri, 23 Nov 2018 13:11:29 +0100
MIME-Version: 1.0
In-Reply-To: <20181123115519.2dnzscmmgv63fdub@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.com>
Cc: linux-mm@kvack.org, mhocko@suse.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org

On 23.11.18 12:55, Oscar Salvador wrote:
> On Thu, Nov 22, 2018 at 10:21:24AM +0100, David Hildenbrand wrote:
>> 1. How are we going to present such memory to the system statistics?
>>
>> In my opinion, this vmemmap memory should
>> a) still account to total memory
>> b) show up as allocated
>>
>> So just like before.
> 
> No, it does not show up under total memory and neither as allocated memory.
> This memory is not for use for anything but for creating the pagetables
> for the memmap array for the section/s.
> 
> It is not memory that the system can use.
> 
> I also guess that if there is a strong opinion on this, we could create
> a counter, something like NR_VMEMMAP_PAGES, and show it under /proc/meminfo.

It's a change if we "hide" such memory. E.g. in a cloud environment you
request to add XGB to your system. You will not see XGB, that can be
"problematic" with some costumers :) - "But I am paying for additional
XGB". (Showing XGB but YMB as allocated is easier to argue with - "your
OS is using it").

> 
>> 2. Is this optional, in other words, can a device driver decide to not
>> to it like that?
> 
> Right now, is a per arch setup.
> For example, x86_64/powerpc/arm64 will do it inconditionally.

That could indeed break Hyper-V/XEN (if the granularity in which you can
add memory can be smaller than 2MB). Or you have bigger memory blocks.

> 
> If we want to restrict this a per device-driver thing, I guess that we could
> allow to pass a flag to add_memory()->add_memory_resource(), and there
> unset MHP_MEMMAP_FROM_RANGE in case that flag is enabled.
> 
>> You mention ballooning. Now, both XEN and Hyper-V (the only balloon
>> drivers that add new memory as of now), usually add e.g. a 128MB segment
>> to only actually some part of it (e.g. 64MB, but could vary). Now, going
>> ahead and assuming that all memory of a section can be read/written is
>> wrong. A device driver will indicate which pages may actually be used
>> via set_online_page_callback() when new memory is added. But at that
>> point you already happily accessed some memory for vmmap - which might
>> lead to crashes.
>>
>> For now the rule was: Memory that was not onlined will not be
>> read/written, that's why it works for XEN and Hyper-V.
> 
> We do not write all memory of the hot-added section, we just write the
> first 2MB (first 512 pages), the other 126MB are left untouched.

Then that has to be made a rule and we have to make sure that all users
(Hyper-V/XEN) can cope with that.

But it is more problematic because we could have 2GB memory blocks. Then
the 2MB rule does no longer strike. Other archs have other sizes (e.g.
s390x 256MB).

> 
> Assuming that you add a memory-chunk section aligned (128MB), but you only present
> the first 64MB or 32MB to the guest as onlined, we still need to allocate the memmap
> for the whole section.

Yes, that's the right thing to do. (the section will be online but some
parts "fake offline")

> 
> I do not really know the tricks behind Hyper-V/Xen, could you expand on that?

Let's say you want to add 64MB on Hyper-V. What Linux will do is add a
new section (128MB) but only actually online, say the first 64MB (I have
no idea if it has to be the first 64MB actually!).

It will keep the other pages "fake-offline" and online them later on
when e.g. adding another 64MB.

See drivers/hv/hv_balloon.c:
- set_online_page_callback(&hv_online_page);
- hv_bring_pgs_online() -> hv_page_online_one() -> has_pfn_is_backed()

The other 64MB must not be written (otherwise GP!) but eventually be
read for e.g. dumping (although that is also shaky and I am fixing that
right now to make it more reliable).

Long story short: It is better to allow device drivers to make use of
the old behavior until they eventually can make sure that the "altmap?"
can be read/written when adding memory.

It presents a major change in the add_memory() interface.

> 
> So far I only tested this with qemu simulating large machines, but I plan
> to try the balloning thing on Xen.
> 
> At this moment I am working on a second version of this patchset
> to address Dave's feedback.

Cool, keep me tuned :)

> 
> ----
> Oscar Salvador
> SUSE L3 
> 


-- 

Thanks,

David / dhildenb
