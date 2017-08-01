Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 389906B053D
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:41:31 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id t78so14930943ita.14
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:31 -0700 (PDT)
Received: from mail-it0-f65.google.com (mail-it0-f65.google.com. [209.85.214.65])
        by mx.google.com with ESMTPS id y16si9526731iod.310.2017.08.01.05.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 05:41:30 -0700 (PDT)
Received: by mail-it0-f65.google.com with SMTP id t78so1527427ita.1
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:41:30 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH v2 0/6] mm, memory_hotplug: allocate memmap from hotadded memory
Date: Tue,  1 Aug 2017 14:41:05 +0200
Message-Id: <20170801124111.28881-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Dan Williams <dan.j.williams@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, x86@kernel.org

Hi,
this is a second version of the RFC previously posted [1]. It is still
an RFC and the main reason for the repost is that I've done some changes
and review should be easier this way. The biggest difference is that
users of the memory hotplug can opt-in for this new feature. This is mainly
because HMM doesn't provide its altmap nor it wants struct pages in the
added range. Archs can then veto the feature if they cannot support it.
The only such example is s390. See [2] for a more detailed explanation why.

Original cover:

This is another step to make the memory hotplug more usable. The primary
goal of this patchset is to reduce memory overhead of the hot added
memory (at least for SPARSE_VMEMMAP memory model). Currently we use
kmalloc to poppulate memmap (struct page array) which has two main
drawbacks a) it consumes an additional memory until the hotadded memory
itslef is onlined and b) memmap might end up on a different numa node
which is especially true for movable_node configuration.

a) is problem especially for memory hotplug based memory "ballooning"
solutions when the delay between physical memory hotplug and the
onlining can lead to OOM and that led to introduction of hacks like auto
onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
policy for the newly added memory")).
b) can have performance drawbacks.

One way to mitigate both issues is to simply allocate memmap array
(which is the largest memory footprint of the physical memory hotplug)
from the hotadded memory itself. VMEMMAP memory model allows us to map
any pfn range so the memory doesn't need to be online to be usable
for the array. See patch 3 for more details. In short I am reusing an
existing vmem_altmap which wants to achieve the same thing for nvdim
device memory.

I am sending this as an RFC because this has seen only a very limited
testing and I am mostly interested about opinions on the chosen
approach. I had to touch some arch code and I have no idea whether my
changes make sense there (especially ppc). Therefore I would highly
appreciate arch maintainers to check patch 3.

Patches 5 and 6 should be straightforward cleanups.

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

Are there any other concerns, ideas, comments?

The patches is based on the current mmotm tree (mmotm-2017-07-31-16-56)

Diffstat says
 arch/arm64/mm/mmu.c            |  9 +++--
 arch/ia64/mm/discontig.c       |  4 ++-
 arch/ia64/mm/init.c            |  5 +--
 arch/powerpc/mm/init_64.c      | 34 +++++++++++++-----
 arch/powerpc/mm/mem.c          |  5 +--
 arch/s390/mm/init.c            | 11 ++++--
 arch/s390/mm/vmem.c            |  9 ++---
 arch/sh/mm/init.c              |  5 +--
 arch/sparc/mm/init_64.c        |  6 ++--
 arch/x86/mm/init_32.c          |  5 +--
 arch/x86/mm/init_64.c          | 18 +++++++---
 include/linux/memory_hotplug.h | 32 ++++++++++++++---
 include/linux/memremap.h       | 39 ++++++++++++++------
 include/linux/mm.h             | 25 +++++++++++--
 include/linux/page-flags.h     | 18 ++++++++++
 kernel/memremap.c              | 12 +++----
 mm/compaction.c                |  3 ++
 mm/memory_hotplug.c            | 80 +++++++++++++++++++++---------------------
 mm/page_alloc.c                | 25 +++++++++++--
 mm/page_isolation.c            | 11 +++++-
 mm/sparse-vmemmap.c            | 13 +++++--
 mm/sparse.c                    | 36 +++++++++++++------
 22 files changed, 290 insertions(+), 115 deletions(-)

Shortlog
Michal Hocko (6):
      mm, memory_hotplug: cleanup memory offline path
      mm, arch: unify vmemmap_populate altmap handling
      mm, memory_hotplug: provide a more generic restrictions for memory hotplug
      mm, memory_hotplug: allocate memmap from the added memory range for sparse-vmemmap
      mm, sparse: complain about implicit altmap usage in vmemmap_populate
      mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap


[1] http://lkml.kernel.org/r/20170726083333.17754-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/20170731195830.0d0ebf2f@thinkpad

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
