Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D87E78E00CD
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 03:53:41 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p24so10072786qtl.2
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 00:53:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h1si4961742qtj.131.2019.01.25.00.53.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 00:53:40 -0800 (PST)
Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
References: <20190122103708.11043-1-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Message-ID: <d9dbefb8-052e-7cb5-3de4-245d05270ff9@redhat.com>
Date: Fri, 25 Jan 2019 09:53:35 +0100
MIME-Version: 1.0
In-Reply-To: <20190122103708.11043-1-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com

On 22.01.19 11:37, Oscar Salvador wrote:
> Hi,
> 
> this is the v2 of the first RFC I sent back then in October [1].
> In this new version I tried to reduce the complexity as much as possible,
> plus some clean ups.
> 
> [Testing]
> 
> I have tested it on "x86_64" (small/big memblocks) and on "powerpc".
> On both architectures hot-add/hot-remove online/offline operations
> worked as expected using vmemmap pages, I have not seen any issues so far.
> I wanted to try it out on Hyper-V/Xen, but I did not manage to.
> I plan to do so along this week (if time allows).
> I would also like to test it on arm64, but I am not sure I can grab
> an arm64 box anytime soon.
> 
> [Coverletter]:
> 
> This is another step to make the memory hotplug more usable. The primary
> goal of this patchset is to reduce memory overhead of the hot added
> memory (at least for SPARSE_VMEMMAP memory model). The current way we use
> to populate memmap (struct page array) has two main drawbacks:
> 
> a) it consumes an additional memory until the hotadded memory itself is
>    onlined and
> b) memmap might end up on a different numa node which is especially true
>    for movable_node configuration.
> 
> a) is problem especially for memory hotplug based memory "ballooning"
>    solutions when the delay between physical memory hotplug and the
>    onlining can lead to OOM and that led to introduction of hacks like auto
>    onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
>    policy for the newly added memory")).
> 
> b) can have performance drawbacks.
> 
> I have also seen hot-add operations failing on powerpc due to the fact
> that we try to use order-8 pages when populating the memmap array.
> Given 64KB base pagesize, that is 16MB.
> If we run out of those, we just fail the operation and we cannot add
> more memory.
> We could fallback to base pages as x86_64 does, but we can do better.
> 
> One way to mitigate all these issues is to simply allocate memmap array
> (which is the largest memory footprint of the physical memory hotplug)
> from the hotadded memory itself. VMEMMAP memory model allows us to map
> any pfn range so the memory doesn't need to be online to be usable
> for the array. See patch 3 for more details. In short I am reusing an
> existing vmem_altmap which wants to achieve the same thing for nvdim
> device memory.
> 

I only had a quick glimpse. I would prefer if the caller of add_memory()
can specify whether it would be ok to allocate vmmap from the range.
This e.g. allows ACPI dimm code to allocate from the range, however
other machanisms (XEN, hyper-v, virtio-mem) can allow it once they
actually support it.

Also, while s390x standby memory cannot support allocating from the
range, virtio-mem could easily support it on s390x.

Not sure how such an interface could look like, but I would really like
to have control over that on the add_memory() interface, not per arch.

-- 

Thanks,

David / dhildenb
