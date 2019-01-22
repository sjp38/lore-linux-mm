Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD218E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 05:37:17 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f31so9065116edf.17
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 02:37:17 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id j1-v6si1222768ejo.195.2019.01.22.02.37.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 02:37:15 -0800 (PST)
From: Oscar Salvador <osalvador@suse.de>
Subject: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from hotadded memory
Date: Tue, 22 Jan 2019 11:37:04 +0100
Message-Id: <20190122103708.11043-1-osalvador@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, Pavel.Tatashin@microsoft.com, david@redhat.com, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Oscar Salvador <osalvador@suse.de>

Hi,

this is the v2 of the first RFC I sent back then in October [1].
In this new version I tried to reduce the complexity as much as possible,
plus some clean ups.

[Testing]

I have tested it on "x86_64" (small/big memblocks) and on "powerpc".
On both architectures hot-add/hot-remove online/offline operations
worked as expected using vmemmap pages, I have not seen any issues so far.
I wanted to try it out on Hyper-V/Xen, but I did not manage to.
I plan to do so along this week (if time allows).
I would also like to test it on arm64, but I am not sure I can grab
an arm64 box anytime soon.

[Coverletter]:

This is another step to make the memory hotplug more usable. The primary
goal of this patchset is to reduce memory overhead of the hot added
memory (at least for SPARSE_VMEMMAP memory model). The current way we use
to populate memmap (struct page array) has two main drawbacks:

a) it consumes an additional memory until the hotadded memory itself is
   onlined and
b) memmap might end up on a different numa node which is especially true
   for movable_node configuration.

a) is problem especially for memory hotplug based memory "ballooning"
   solutions when the delay between physical memory hotplug and the
   onlining can lead to OOM and that led to introduction of hacks like auto
   onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
   policy for the newly added memory")).

b) can have performance drawbacks.

I have also seen hot-add operations failing on powerpc due to the fact
that we try to use order-8 pages when populating the memmap array.
Given 64KB base pagesize, that is 16MB.
If we run out of those, we just fail the operation and we cannot add
more memory.
We could fallback to base pages as x86_64 does, but we can do better.

One way to mitigate all these issues is to simply allocate memmap array
(which is the largest memory footprint of the physical memory hotplug)
from the hotadded memory itself. VMEMMAP memory model allows us to map
any pfn range so the memory doesn't need to be online to be usable
for the array. See patch 3 for more details. In short I am reusing an
existing vmem_altmap which wants to achieve the same thing for nvdim
device memory.

There is also one potential drawback, though. If somebody uses memory
hotplug for 1G (gigantic) hugetlb pages then this scheme will not work
for them obviously because each memory block will contain reserved
area. Large x86 machines will use 2G memblocks so at least one 1G page
will be available but this is still not 2G...

I am not really sure somebody does that and how reliable that can work
actually. Nevertheless, I _believe_ that onlining more memory into
virtual machines is much more common usecase. Anyway if there ever is a
strong demand for such a usecase we have basically 3 options a) enlarge
memory blocks even more b) enhance altmap allocation strategy and reuse
low memory sections to host memmaps of other sections on the same NUMA
node c) have the memmap allocation strategy configurable to fallback to
the current allocation.
 
[Overall design]:

Let us say we hot-add 2GB of memory on a x86_64 (memblock size = 128M).
That is:

 - 16 sections
 - 524288 pages
 - 8192 vmemmap pages (out of those 524288. We spend 512 pages for each section)

 The range of pages is: 0xffffea0004000000 - 0xffffea0006000000
 The vmemmap range is:  0xffffea0004000000 - 0xffffea0004080000

 0xffffea0004000000 is the head vmemmap page (first page), while all the others
 are "tails".

 We keep the following information in it:

 - Head page:
   - head->_refcount: number of sections
   - head->private :  number of vmemmap pages
 - Tail page:
   - tail->freelist : pointer to the head

This is done because it eases the work in cases where we have to compute the
number of vmemmap pages to know how much do we have to skip etc, and to keep
the right accounting to present_pages.

When we want to hot-remove the range, we need to be careful because the first
pages of that range, are used for the memmap maping, so if we remove those
first, we would blow up while accessing the others later on.
For that reason we keep the number of sections in head->_refcount, to know how
much do we have to defer the free up.

Since in a hot-remove operation, sections are being removed sequentially, the
approach taken here is that every time we hit free_section_memmap(), we decrease
the refcount of the head.
When it reaches 0, we know that we hit the last section, so we call
vmemmap_free() for the whole memory-range in backwards, so we make sure that
the pages used for the mapping will be latest to be freed up.

The accounting is as follows:

 Vmemmap pages are charged to spanned/present_paged, but not to manages_pages.

I yet have to check a couple of things like creating an accounting item
like VMEMMAP_PAGES to show in /proc/meminfo to ease to spot the memory that
went in there, testing Hyper-V/Xen to see how they react to the fact that
we are using the beginning of the memory-range for our own purposes, and to
check the thing about gigantic pages + hotplug.
I also have to check that there is no compilation/runtime errors when
CONFIG_SPARSEMEM but !CONFIG_SPARSEMEM_VMEMMAP.
But before that, I would like to get people's feedback about the overall
design, and ideas/suggestions.


[1] https://patchwork.kernel.org/cover/10685835/

Michal Hocko (3):
  mm, memory_hotplug: cleanup memory offline path
  mm, memory_hotplug: provide a more generic restrictions for memory
    hotplug
  mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap

Oscar Salvador (1):
  mm, memory_hotplug: allocate memmap from the added memory range for
    sparse-vmemmap

 arch/arm64/mm/mmu.c            |  10 ++-
 arch/ia64/mm/init.c            |   5 +-
 arch/powerpc/mm/init_64.c      |   7 ++
 arch/powerpc/mm/mem.c          |   6 +-
 arch/s390/mm/init.c            |  12 ++-
 arch/sh/mm/init.c              |   6 +-
 arch/x86/mm/init_32.c          |   6 +-
 arch/x86/mm/init_64.c          |  20 +++--
 drivers/hv/hv_balloon.c        |   1 +
 drivers/xen/balloon.c          |   1 +
 include/linux/memory_hotplug.h |  42 ++++++++--
 include/linux/memremap.h       |   2 +-
 include/linux/page-flags.h     |  23 +++++
 kernel/memremap.c              |   9 +-
 mm/compaction.c                |   8 ++
 mm/memory_hotplug.c            | 186 +++++++++++++++++++++++++++++------------
 mm/page_alloc.c                |  47 ++++++++++-
 mm/page_isolation.c            |  13 +++
 mm/sparse.c                    | 124 +++++++++++++++++++++++++--
 mm/util.c                      |   2 +
 20 files changed, 431 insertions(+), 99 deletions(-)

-- 
2.13.7
