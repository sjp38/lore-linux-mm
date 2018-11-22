Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7F86B2ABB
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 04:21:32 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id j125so8682647qke.12
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 01:21:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q11si1858140qki.187.2018.11.22.01.21.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 01:21:31 -0800 (PST)
Subject: Re: [RFC PATCH 0/4] mm, memory_hotplug: allocate memmap from hotadded
 memory
References: <20181116101222.16581-1-osalvador@suse.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <2571308d-0460-e8b9-ad40-75d6b13b2d09@redhat.com>
Date: Thu, 22 Nov 2018 10:21:24 +0100
MIME-Version: 1.0
In-Reply-To: <20181116101222.16581-1-osalvador@suse.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.com>, linux-mm@kvack.org
Cc: mhocko@suse.com, rppt@linux.vnet.ibm.com, akpm@linux-foundation.org, arunks@codeaurora.org, bhe@redhat.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, Jonathan.Cameron@huawei.com, jglisse@redhat.com, linux-kernel@vger.kernel.org

On 16.11.18 11:12, Oscar Salvador wrote:
> Hi,
> 
> this patchset is based on Michal's patchset [1].
> Patch#1, patch#2 and patch#4 are quite the same.
> They just needed little changes to adapt it to current codestream,
> so it seemed fair to leave them.
> 
> ---------
> Original cover:
> 
> This is another step to make the memory hotplug more usable. The primary
> goal of this patchset is to reduce memory overhead of the hot added
> memory (at least for SPARSE_VMEMMAP memory model). Currently we use
> kmalloc to poppulate memmap (struct page array) which has two main
> drawbacks a) it consumes an additional memory until the hotadded memory
> itslef is onlined and b) memmap might end up on a different numa node
> which is especially true for movable_node configuration.

I haven't looked at the patches but have some questions.

1. How are we going to present such memory to the system statistics?

In my opinion, this vmemmap memory should
a) still account to total memory
b) show up as allocated

So just like before.


2. Is this optional, in other words, can a device driver decide to not
to it like that?

You mention ballooning. Now, both XEN and Hyper-V (the only balloon
drivers that add new memory as of now), usually add e.g. a 128MB segment
to only actually some part of it (e.g. 64MB, but could vary). Now, going
ahead and assuming that all memory of a section can be read/written is
wrong. A device driver will indicate which pages may actually be used
via set_online_page_callback() when new memory is added. But at that
point you already happily accessed some memory for vmmap - which might
lead to crashes.

For now the rule was: Memory that was not onlined will not be
read/written, that's why it works for XEN and Hyper-V.

It *could* work for them if they could know and communicate to
add_memory() which part of a newly added memory block is definitely usable.

So, especially for the case of balloning that you describe, things are
more tricky than a simple "let's just use some memory of the memory
block we're adding" unfortunately. For DIMMs it can work.

> 
> a) is problem especially for memory hotplug based memory "ballooning"
> solutions when the delay between physical memory hotplug and the
> onlining can lead to OOM and that led to introduction of hacks like auto
> onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
> policy for the newly added memory")).
> b) can have performance drawbacks.
> 
> One way to mitigate both issues is to simply allocate memmap array
> (which is the largest memory footprint of the physical memory hotplug)
> from the hotadded memory itself. VMEMMAP memory model allows us to map
> any pfn range so the memory doesn't need to be online to be usable
> for the array. See patch 3 for more details. In short I am reusing an
> existing vmem_altmap which wants to achieve the same thing for nvdim
> device memory.
> 
> There is also one potential drawback, though. If somebody uses memory
> hotplug for 1G (gigantic) hugetlb pages then this scheme will not work
> for them obviously because each memory block will contain reserved
> area. Large x86 machines will use 2G memblocks so at least one 1G page
> will be available but this is still not 2G...

Yes, I think this is a possible use case. So it would have to be
configurable somewehere - opt-in most probably. But related to
ballooning, they will usually add the minimum possible granularity (e.g.
128MB) and that seems to work for these setups. DIMMs are probably
different.

> 
> I am not really sure somebody does that and how reliable that can work
> actually. Nevertheless, I _believe_ that onlining more memory into
> virtual machines is much more common usecase. Anyway if there ever is a
> strong demand for such a usecase we have basically 3 options a) enlarge
> memory blocks even more b) enhance altmap allocation strategy and reuse
> low memory sections to host memmaps of other sections on the same NUMA
> node c) have the memmap allocation strategy configurable to fallback to
> the current allocation.
> 
> ---------
> 
> Old version of this patchset would blow up because we were clearing the
> pmds while we still had to reference pages backed by that memory.
> I picked another approach which does not force us to touch arch specific code
> in that regard.
> 
> Overall design:
> 
> With the preface of:
> 
>     1) Whenever you hot-add a range, this is the same range that will be hot-removed.
>        This is just because you can't remove half of a DIMM, in the same way you can't
>        remove half of a device in qemu.
>        A device/DIMM are added/removed as a whole.
> 
>     2) Every add_memory()->add_memory_resource()->arch_add_memory()->__add_pages()
>        will use a new altmap because it is a different hot-added range.
> 
>     3) When you hot-remove a range, the sections will be removed sequantially
>        starting from the first section of the range and ending with the last one.
> 
>     4) hot-remove operations are protected by hotplug lock, so no parallel operations
>        can take place.
> 
>     The current design is as follows:
> 
>     hot-remove operation)
> 
>     - __kfree_section_memmap will be called for every section to be removed.
>     - We catch the first vmemmap_page and we pin it to a global variable.
>     - Further calls to __kfree_section_memmap will decrease refcount of
>       the vmemmap page without calling vmemmap_free().
>       We defer the call to vmemmap_free() untill all sections are removed
>     - If the refcount drops to 0, we know that we hit the last section.
>     - We clear the global variable.
>     - We call vmemmap_free for [last_section, current_vmemmap_page)
> 
>     In case we are hot-removing a range that used altmap, the call to
>     vmemmap_free must be done backwards, because the beginning of memory
>     is used for the pagetables.
>     Doing it this way, we ensure that by the time we remove the pagetables,
>     those pages will not have to be referenced anymore.
> 
>     An example:
> 
>     (qemu) object_add memory-backend-ram,id=ram0,size=10G
>     (qemu) device_add pc-dimm,id=dimm0,memdev=ram0,node=1
> 
>     - This has added: ffffea0004000000 - ffffea000427ffc0 (refcount: 80)
> 
>     When refcount of ffffea0004000000 drops to 0, vmemmap_free()
>     will be called in this way:
> 
>     vmemmap_free: start/end: ffffea000de00000 - ffffea000e000000
>     vmemmap_free: start/end: ffffea000dc00000 - ffffea000de00000
>     vmemmap_free: start/end: ffffea000da00000 - ffffea000dc00000
>     vmemmap_free: start/end: ffffea000d800000 - ffffea000da00000
>     vmemmap_free: start/end: ffffea000d600000 - ffffea000d800000
>     vmemmap_free: start/end: ffffea000d400000 - ffffea000d600000
>     vmemmap_free: start/end: ffffea000d200000 - ffffea000d400000
>     vmemmap_free: start/end: ffffea000d000000 - ffffea000d200000
>     vmemmap_free: start/end: ffffea000ce00000 - ffffea000d000000
>     vmemmap_free: start/end: ffffea000cc00000 - ffffea000ce00000
>     vmemmap_free: start/end: ffffea000ca00000 - ffffea000cc00000
>     vmemmap_free: start/end: ffffea000c800000 - ffffea000ca00000
>     vmemmap_free: start/end: ffffea000c600000 - ffffea000c800000
>     vmemmap_free: start/end: ffffea000c400000 - ffffea000c600000
>     vmemmap_free: start/end: ffffea000c200000 - ffffea000c400000
>     vmemmap_free: start/end: ffffea000c000000 - ffffea000c200000
>     vmemmap_free: start/end: ffffea000be00000 - ffffea000c000000
>     ...
>     ...
>     vmemmap_free: start/end: ffffea0004000000 - ffffea0004200000
> 
> 
>     [Testing]
> 
>     - Tested ony on x86_64
>     - Several tests were carried out with memblocks of different sizes.
>     - Tests were performed adding different memory-range sizes
>       from 512M to 60GB.
> 
>     [Todo]
>     - Look into hotplug gigantic pages case
> 
> Before investing more effort, I would like to hear some opinions/thoughts/ideas.
> 
> [1] https://lore.kernel.org/lkml/20170801124111.28881-1-mhocko@kernel.org/
> 
> Michal Hocko (3):
>   mm, memory_hotplug: cleanup memory offline path
>   mm, memory_hotplug: provide a more generic restrictions for memory
>     hotplug
>   mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap
> 
> Oscar Salvador (1):
>   mm, memory_hotplug: allocate memmap from the added memory range for
>     sparse-vmemmap
> 
>  arch/arm64/mm/mmu.c            |   5 +-
>  arch/ia64/mm/init.c            |   5 +-
>  arch/powerpc/mm/init_64.c      |   2 +
>  arch/powerpc/mm/mem.c          |   6 +-
>  arch/s390/mm/init.c            |  12 +++-
>  arch/sh/mm/init.c              |   6 +-
>  arch/x86/mm/init_32.c          |   6 +-
>  arch/x86/mm/init_64.c          |  17 ++++--
>  include/linux/memory_hotplug.h |  35 ++++++++---
>  include/linux/memremap.h       |  65 +++++++++++++++++++-
>  include/linux/page-flags.h     |  18 ++++++
>  kernel/memremap.c              |  12 ++--
>  mm/compaction.c                |   3 +
>  mm/hmm.c                       |   6 +-
>  mm/memory_hotplug.c            | 133 ++++++++++++++++++++++++++++-------------
>  mm/page_alloc.c                |  33 ++++++++--
>  mm/page_isolation.c            |  13 +++-
>  mm/sparse.c                    |  62 ++++++++++++++++---
>  18 files changed, 345 insertions(+), 94 deletions(-)
> 


-- 

Thanks,

David / dhildenb
