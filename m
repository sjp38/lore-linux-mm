Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58D906B0005
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 10:23:56 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id b84so3971485qkj.14
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 07:23:56 -0800 (PST)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id u55si1711065qtk.439.2018.03.02.07.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Mar 2018 07:23:55 -0800 (PST)
From: David Hildenbrand <david@redhat.com>
Subject: Question: Using online_pages/offline_pages() with granularity < mem
 section size
Message-ID: <32e2bbbe-fe71-6607-fdbb-04767bec9bbb@redhat.com>
Date: Fri, 2 Mar 2018 16:23:52 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

in the context of virtualization, I am experimenting right now with an
approach to plug/unplug memory using a paravirtualized interface(not
ACPI). And I stumbled over certain things, looking at the memory hot/un
plug code.

The big picture:

A paravirtualized device provides a physical memory region to the guest.
We could have multiple such devices. Each device is assigned to a NUMA
node. We want to control how much memory in such a region the guest is
allowed to use. We can dynamically add/remove memory to NUMA nodes this
way and make sure a guest cannot make use of more memory than requested.

Especially: We decide in the kernel which memory block to online/offline.


The basic mechanism:

The hypervisor provides a physical memory region to the guest. This
memory region can be used by the guest to plug/unplug memory. The
hypervisor asks for a certain amount of used memory and the guest should
try to reach that goal, by plugging/unplugging memory. Whenever the
guest wants to plug/unplug a block, it has to communicate that to the
hypervisor.

The hypervisor can grant/deny requests to plug/unplug a block of memory.
Especially, the guest must not take more memory than requested. Trying
to read unplugged memory succeeds (e.g. for kdump), writing to that
memory is prohibited.

Memory blocks can be of any granularity, but 1-4MB looks like a sane
amount to not fragment memory too much. If the guest can't find free
memory blocks, no unplug is possible.


In the guest, I add_memory() new memory blocks to the NORMAL zone. The
NORMAL zone makes it harder to remove memory but we don't run into any
problems (e.g. too little NORMAL memory e.g. for page tables). Now,
these chunks are fairly big (>= 128MB) and there seems to be no way to
plug/unplug smaller chunks to Linux using official interfaces ("memory
segments"). Trying to remove >=128MB of NORMAL memory will usually not
succeed. So I thought about manually removing parts of a memory section.

Yes, this sounds similar to a balloon, but it is different: I have to
offline memory in a certain memory range, not just any memory in the
system. So I cannot simply use kmalloc() - there is no allocator that
guarantees that.

So instead I want ahead and thought about simply manually
offlining/onlining parts of a memory segment - especially "page blocks".
I do my own bookkeeping about which parts of a memory segment are
online/offline and use that information for finding blocks to
plug/unplug. The offline_pages() interface made me assume that this
should work with blocks in the size of pageblock_nr_pages.


I stumbled over the following two problems:

1. __offline_isolated_pages() doesn't care about page blocks, it simply
calls offline_mem_sections(), which marks the whole section as offline,
although it has to remain online until all pages in that section were
offlined. Now this can be handled by moving the offline_mem_sections()
logic further outside to the caller of offline_pages().

2. While offlining 2MB blocks (page block size), I discovered that more
memory was marked as reserved. Especially, a page block contains pages
with an order 10 (4MB), which implies that two page blocks are "bound
together". This is also done in __offline_isolated_pages(). Offlining
2MB will result in 4MB being marked as reserved.

Now, when I switch to 4MB, my manual online_pages/offline_pages seems so
far to work fine.

So my questions are:

Can I assume that online_pages/offline_pages() works with "MAX_ORDER -
1" sizes reliably? Should the checks in these functions be updated? page
blocks does not seem to be the real deal.

Any better approach to allocate memory in a specific memory range
(without fake numa nodes)? So I could avoid using
online_pages/offline_pages and instead do it similar to a balloon
driver? (mark the page as reserved myself)


Thanks a lot!

-- 

Thanks,

David / dhildenb

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
