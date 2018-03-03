Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7C43F6B0003
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 12:53:49 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id b23so6454058oib.16
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 09:53:49 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s7sor2234454oia.83.2018.03.03.09.53.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 03 Mar 2018 09:53:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <32e2bbbe-fe71-6607-fdbb-04767bec9bbb@redhat.com>
References: <32e2bbbe-fe71-6607-fdbb-04767bec9bbb@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 3 Mar 2018 09:53:46 -0800
Message-ID: <CAPcyv4hvDg6KD0D+7bEzF2a=-oiSTutJiHfKWBihmSzMz5VvFw@mail.gmail.com>
Subject: Re: Question: Using online_pages/offline_pages() with granularity <
 mem section size
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Reza Arbab <arbab@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 2, 2018 at 7:23 AM, David Hildenbrand <david@redhat.com> wrote:
> Hi,
>
> in the context of virtualization, I am experimenting right now with an
> approach to plug/unplug memory using a paravirtualized interface(not
> ACPI). And I stumbled over certain things, looking at the memory hot/un
> plug code.
>
> The big picture:
>
> A paravirtualized device provides a physical memory region to the guest.
> We could have multiple such devices. Each device is assigned to a NUMA
> node. We want to control how much memory in such a region the guest is
> allowed to use. We can dynamically add/remove memory to NUMA nodes this
> way and make sure a guest cannot make use of more memory than requested.
>
> Especially: We decide in the kernel which memory block to online/offline.
>
>
> The basic mechanism:
>
> The hypervisor provides a physical memory region to the guest. This
> memory region can be used by the guest to plug/unplug memory. The
> hypervisor asks for a certain amount of used memory and the guest should
> try to reach that goal, by plugging/unplugging memory. Whenever the
> guest wants to plug/unplug a block, it has to communicate that to the
> hypervisor.
>
> The hypervisor can grant/deny requests to plug/unplug a block of memory.
> Especially, the guest must not take more memory than requested. Trying
> to read unplugged memory succeeds (e.g. for kdump), writing to that
> memory is prohibited.
>
> Memory blocks can be of any granularity, but 1-4MB looks like a sane
> amount to not fragment memory too much. If the guest can't find free
> memory blocks, no unplug is possible.
>
>
> In the guest, I add_memory() new memory blocks to the NORMAL zone. The
> NORMAL zone makes it harder to remove memory but we don't run into any
> problems (e.g. too little NORMAL memory e.g. for page tables). Now,
> these chunks are fairly big (>= 128MB) and there seems to be no way to
> plug/unplug smaller chunks to Linux using official interfaces ("memory
> segments"). Trying to remove >=128MB of NORMAL memory will usually not
> succeed. So I thought about manually removing parts of a memory section.
>
> Yes, this sounds similar to a balloon, but it is different: I have to
> offline memory in a certain memory range, not just any memory in the
> system. So I cannot simply use kmalloc() - there is no allocator that
> guarantees that.
>
> So instead I want ahead and thought about simply manually
> offlining/onlining parts of a memory segment - especially "page blocks".
> I do my own bookkeeping about which parts of a memory segment are
> online/offline and use that information for finding blocks to
> plug/unplug. The offline_pages() interface made me assume that this
> should work with blocks in the size of pageblock_nr_pages.
>
>
> I stumbled over the following two problems:
>
> 1. __offline_isolated_pages() doesn't care about page blocks, it simply
> calls offline_mem_sections(), which marks the whole section as offline,
> although it has to remain online until all pages in that section were
> offlined. Now this can be handled by moving the offline_mem_sections()
> logic further outside to the caller of offline_pages().
>
> 2. While offlining 2MB blocks (page block size), I discovered that more
> memory was marked as reserved. Especially, a page block contains pages
> with an order 10 (4MB), which implies that two page blocks are "bound
> together". This is also done in __offline_isolated_pages(). Offlining
> 2MB will result in 4MB being marked as reserved.
>
> Now, when I switch to 4MB, my manual online_pages/offline_pages seems so
> far to work fine.
>
> So my questions are:
>
> Can I assume that online_pages/offline_pages() works with "MAX_ORDER -
> 1" sizes reliably? Should the checks in these functions be updated? page
> blocks does not seem to be the real deal.
>
> Any better approach to allocate memory in a specific memory range
> (without fake numa nodes)? So I could avoid using
> online_pages/offline_pages and instead do it similar to a balloon
> driver? (mark the page as reserved myself)

Not sure this answers your questions, but I did play with sub-section
memory hotplug last year in this patch set, but it fell to the bottom
of my queue. At least at the time it seemed possible to remove the
section alignment constraints of memory hotplug.

https://lists.01.org/pipermail/linux-nvdimm/2017-March/009167.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
