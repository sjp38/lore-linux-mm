Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7966B02C3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:33:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id m80so4904889wmd.4
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:33:50 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id m77si8841824wmc.23.2017.07.26.01.33.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 01:33:49 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id c184so6466894wmd.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:33:48 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [RFC PATCH 0/5] mm, memory_hotplug: allocate memmap from hotadded memory
Date: Wed, 26 Jul 2017 10:33:28 +0200
Message-Id: <20170726083333.17754-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Dan Williams <dan.j.williams@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>

Hi,
this is another step to make the memory hotplug more usable. The primary
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
appreciate arch maintainers to check patch 2.

Patches 4 and 5 should be straightforward cleanups.

There is also one potential drawback, though. If somebody uses memory
hotplug for 1G (gigantic) hugetlb pages then this scheme will not work
for them obviously because each memory section will contain 2MB reserved
area.  I am not really sure somebody does that and how reliable that
can work actually. Nevertheless, I _believe_ that onlining more memory
into virtual machines is much more common usecase. Anyway if there ever
is a strong demand for such a usecase we have basically 3 options a)
enlarge memory sections b) enhance altmap allocation strategy and reuse
low memory sections to host memmaps of other sections on the same NUMA
node c) have the memmap allocation strategy configurable to fallback to
the current allocation.

Are there any other concerns, ideas, comments?

The patches is based on the current mmotm tree (mmotm-2017-07-12-15-11)

Diffstat says
 arch/arm64/mm/mmu.c            |  9 ++++--
 arch/ia64/mm/discontig.c       |  4 ++-
 arch/powerpc/mm/init_64.c      | 34 ++++++++++++++++------
 arch/s390/mm/vmem.c            |  7 +++--
 arch/sparc/mm/init_64.c        |  6 ++--
 arch/x86/mm/init_64.c          | 13 +++++++--
 include/linux/memory_hotplug.h |  7 +++--
 include/linux/memremap.h       | 34 +++++++++++++++-------
 include/linux/mm.h             | 25 ++++++++++++++--
 include/linux/page-flags.h     | 18 ++++++++++++
 kernel/memremap.c              |  6 ----
 mm/compaction.c                |  3 ++
 mm/memory_hotplug.c            | 66 +++++++++++++++++++-----------------------
 mm/page_alloc.c                | 25 ++++++++++++++--
 mm/page_isolation.c            | 11 ++++++-
 mm/sparse-vmemmap.c            | 13 +++++++--
 mm/sparse.c                    | 36 ++++++++++++++++-------
 17 files changed, 223 insertions(+), 94 deletions(-)

Shortlog
Michal Hocko (5):
      mm, memory_hotplug: cleanup memory offline path
      mm, arch: unify vmemmap_populate altmap handling
      mm, memory_hotplug: allocate memmap from the added memory range for sparse-vmemmap
      mm, sparse: complain about implicit altmap usage in vmemmap_populate
      mm, sparse: rename kmalloc_section_memmap, __kfree_section_memmap


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
