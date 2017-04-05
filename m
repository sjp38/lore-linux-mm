Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED166B03AB
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 16:40:40 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a130so6330560qkb.21
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 13:40:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s26si10254901qks.59.2017.04.05.13.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 13:40:38 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 00/16] HMM (Heterogeneous Memory Management) v19
Date: Wed,  5 Apr 2017 16:40:10 -0400
Message-Id: <20170405204026.3940-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Patchset is on top of mmotm mmotm-2017-04-04-15-00 it would conflict
with Michal memory hotplug patchset (first patch in this serie would
be the conflicting one). There is also build issue against 4.11-rc*
where some definitions are now in include/linux/sched/mm.h to fix
this patchset this new header file need to be included in migrate.c
and hmm.c but patchset have been otherwise build tested on different
arch and there wasn't any issues. It was also tested with real hardware
on x86-64.


Changes since v18:
- Use an enum for memory type instead of set of flag, this make a
  more clear separation between different type of ZONE_DEVICE memory
  (ie persistent or HMM unaddressable memory)
-Dona??t preserve soft-dirtyness as check and restore can not be use
 with an active device driver. This could be revisited if we are ever
 able to save device states
-Drop the extra flag to migratepage callback of address_space and use
 a new migrate mode instead of adding a new parameters.
-Improves comments in various code path
-Use rw_sem to protect mirrors list
-Improved Kconfig help description
-Drop over cautious BUG_ON()
-Added a documentation file
-Build fixes
-Typo fixes


Heterogeneous Memory Management (HMM) (description and justification)

Today device driver expose dedicated memory allocation API through their
device file, often relying on a combination of IOCTL and mmap calls. The
device can only access and use memory allocated through this API. This
effectively split the program address space into object allocated for the
device and useable by the device and other regular memory (malloc, mmap
of a file, share memory, a?|) only accessible by CPU (or in a very limited
way by a device by pinning memory).

Allowing different isolated component of a program to use a device thus
require duplication of the input data structure using device memory
allocator. This is reasonable for simple data structure (array, grid,
image, a?|) but this get extremely complex with advance data structure
(list, tree, graph, a?|) that rely on a web of memory pointers. This is
becoming a serious limitation on the kind of work load that can be
offloaded to device like GPU.

New industry standard like C++, OpenCL or CUDA are pushing to remove this
barrier. This require a shared address space between GPU device and CPU so
that GPU can access any memory of a process (while still obeying memory
protection like read only). This kind of feature is also appearing in
various other operating systems.

HMM is a set of helpers to facilitate several aspects of address space
sharing and device memory management. Unlike existing sharing mechanism
that rely on pining pages use by a device, HMM relies on mmu_notifier to
propagate CPU page table update to device page table.

Duplicating CPU page table is only one aspect necessary for efficiently
using device like GPU. GPU local memory have bandwidth in the TeraBytes/
second range but they are connected to main memory through a system bus
like PCIE that is limited to 32GigaBytes/second (PCIE 4.0 16x). Thus it
is necessary to allow migration of process memory from main system memory
to device memory. Issue is that on platform that only have PCIE the device
memory is not accessible by the CPU with the same properties as main
memory (cache coherency, atomic operations, a?|).

To allow migration from main memory to device memory HMM provides a set
of helper to hotplug device memory as a new type of ZONE_DEVICE memory
which is un-addressable by CPU but still has struct page representing it.
This allow most of the core kernel logic that deals with a process memory
to stay oblivious of the peculiarity of device memory.

When page backing an address of a process is migrated to device memory
the CPU page table entry is set to a new specific swap entry. CPU access
to such address triggers a migration back to system memory, just like if
the page was swap on disk. HMM also blocks any one from pinning a
ZONE_DEVICE page so that it can always be migrated back to system memory
if CPU access it. Conversely HMM does not migrate to device memory any
page that is pin in system memory.

To allow efficient migration between device memory and main memory a new
migrate_vma() helpers is added with this patchset. It allows to leverage
device DMA engine to perform the copy operation.

This feature will be use by upstream driver like nouveau mlx5 and probably
other in the future (amdgpu is next suspect  in line). We are actively
working on nouveau and mlx5 support. To test this patchset we also worked
with NVidia close source driver team, they have more resources than us to
test this kind of infrastructure and also a bigger and better userspace
eco-system with various real industry workload they can be use to test and
profile HMM.

The expected workload is a program builds a data set on the CPU (from disk,
from network, from sensors, a?|). Program uses GPU API (OpenCL, CUDA, ...)
to give hint on memory placement for the input data and also for the output
buffer. Program call GPU API to schedule a GPU job, this happens using
device driver specific ioctl. All this is hidden from programmer point of
view in case of C++ compiler that transparently offload some part of a
program to GPU. Program can keep doing other stuff on the CPU while the
GPU is crunching numbers.

It is expected that CPU will not access the same data set as the GPU while
GPU is working on it, but this is not mandatory. In fact we expect some
small memory object to be actively access by both GPU and CPU concurrently
as synchronization channel and/or for monitoring purposes. Such object will
stay in system memory and should not be bottlenecked by system bus
bandwidth (rare write and read access from both CPU and GPU).

As we are relying on device driver API, HMM does not introduce any new
syscall nor does it modify any existing ones. It does not change any POSIX
semantics or behaviors. For instance the child after a fork of a process
that is using HMM will not be impacted in anyway, nor is there any data
hazard between child COW or parent COW of memory that was migrated to
device prior to fork.

HMM assume a numbers of hardware features. Device must allow device page
table to be updated at any time (ie device job must be preemptable). Device
page table must provides memory protection such as read only. Device must
track write access (dirty bit). Device must have a minimum granularity that
match PAGE_SIZE (ie 4k).


Reviewer (just hint):
Patch 1    add the concept of memory type and pass this down to to arch
           memory hotplug (adding new arg) Dan Williams is the best person
           to review this change
Patch 2    move the page reference decrement from put_page() to
           put_zone_device_page() Dan Williams is the best person to review
           this change
Patch 3    add a new memory type for ZONE_DEVICE and also add all the logic
           in various core mm to support this new type. Dan Williams and
           any core mm contributor are best people to review each half of
           this patchset
Patch 4    add support for new un-addressable type added in patch 3 to
           x86-64. This can be review by x86 contributor but there is
           nothing x86 specific about it. So i think any one with mm
           experience is fine
Patch 5    add a new migrate mode. Any one familiar with page migration is
           welcome to review.
Patch 6    introduce a new migration helper (migrate_vma()) that allow to
           migrate a range of virtual address of a process using device DMA
           engine to perform the copy. It is not limited to do copy from and
           to device but can also do copy between any kind of source and
           destination memory. Again anyone familiar with migration code
           should be able to verify the logic.
Patch 7    optimize the new migrate_vma() by unmapping pages while we are
           collecting them. This can be review by any mm folks.
Patch 8    introduce core infrastructure and definition of HMM, pretty
           small patch and easy to review
Patch 9    introduce the mirror functionality of HMM, it relies on
           mmu_notifier and thus someone familiar with that part would be
           in better position to review
Patch 10   is an helper to snapshot CPU page table while synchronizing with
           concurrent page table update. Understanding mmu_notifier makes
           review easier.
Patch 11   is mostly a wrapper around handle_mm_fault()
Patch 12   add unaddressable memory migration to helper introduced in patch
           6, this can be review by anyone familiar with migration code
Patch 13   add a feature that allow device to allocate non-present page on
           the GPU when migrating a range of address to device memory. This
           is an helper for device driver to avoid having to first allocate
           system memory before migration to device memory
Patch 14   add helper to hotplug un-addressable device memory as new type
           of ZONE_DEVICE memory (new type introducted in patch 3 of this
           serie). This is boiler plate code around memory hotplug and it
           also pick a free range of physical address for the device memory.
           Note that the physical address do not point to anything (at least
           as far as the kernel knows).
Patch 15   introduce a new hmm_device class as an helper for device driver
           that want to expose multiple device memory under a common fake
           device driver. This is usefull for multi-gpu configuration.
           Anyone familiar with device driver infrastructure can review
           this. Boiler plate code really.
Patch 16   is the documentation for everything


Previous patchset posting :
    v1 http://lwn.net/Articles/597289/
    v2 https://lkml.org/lkml/2014/6/12/559
    v3 https://lkml.org/lkml/2014/6/13/633
    v4 https://lkml.org/lkml/2014/8/29/423
    v5 https://lkml.org/lkml/2014/11/3/759
    v6 http://lwn.net/Articles/619737/
    v7 http://lwn.net/Articles/627316/
    v8 https://lwn.net/Articles/645515/
    v9 https://lwn.net/Articles/651553/
    v10 https://lwn.net/Articles/654430/
    v11 http://www.gossamer-threads.com/lists/linux/kernel/2286424
    v12 http://www.kernelhub.org/?msg=972982&p=2
    v13 https://lwn.net/Articles/706856/
    v14 https://lkml.org/lkml/2016/12/8/344
    v15 http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1304107.html
    v16 http://www.spinics.net/lists/linux-mm/msg119814.html
    v17 https://lkml.org/lkml/2017/1/27/847
    v18 https://lkml.org/lkml/2017/3/16/596


JA(C)rA'me Glisse (16):
  mm/memory/hotplug: add memory type parameter to arch_add/remove_memory
  mm/put_page: move ZONE_DEVICE page reference decrement v2
  mm/unaddressable-memory: new type of ZONE_DEVICE for unaddressable
    memory
  mm/ZONE_DEVICE/x86: add support for un-addressable device memory
  mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY
  mm/migrate: new memory migration helper for use with device memory v4
  mm/migrate: migrate_vma() unmap page from vma while collecting pages
  mm/hmm: heterogeneous memory management (HMM for short)
  mm/hmm/mirror: mirror process address space on device with HMM helpers
  mm/hmm/mirror: helper to snapshot CPU page table v2
  mm/hmm/mirror: device page fault handler
  mm/migrate: support un-addressable ZONE_DEVICE page in migration
  mm/migrate: allow migrate_vma() to alloc new page on empty entry
  mm/hmm/devmem: device memory hotplug using ZONE_DEVICE
  mm/hmm/devmem: dummy HMM device for ZONE_DEVICE memory v2
  hmm: heterogeneous memory management documentation

 Documentation/vm/hmm.txt       |  362 ++++++++++++
 MAINTAINERS                    |    7 +
 arch/ia64/mm/init.c            |   36 +-
 arch/powerpc/mm/mem.c          |   37 +-
 arch/s390/mm/init.c            |   16 +-
 arch/sh/mm/init.c              |   35 +-
 arch/x86/mm/init_32.c          |   41 +-
 arch/x86/mm/init_64.c          |   57 +-
 fs/aio.c                       |    8 +
 fs/f2fs/data.c                 |    5 +-
 fs/hugetlbfs/inode.c           |    5 +-
 fs/proc/task_mmu.c             |    7 +
 fs/ubifs/file.c                |    5 +-
 include/linux/hmm.h            |  468 ++++++++++++++++
 include/linux/ioport.h         |    1 +
 include/linux/memory_hotplug.h |   34 +-
 include/linux/memremap.h       |   57 ++
 include/linux/migrate.h        |  115 ++++
 include/linux/migrate_mode.h   |    5 +
 include/linux/mm.h             |   14 +-
 include/linux/mm_types.h       |    5 +
 include/linux/swap.h           |   24 +-
 include/linux/swapops.h        |   68 +++
 kernel/fork.c                  |    2 +
 kernel/memremap.c              |   51 +-
 mm/Kconfig                     |   44 ++
 mm/Makefile                    |    1 +
 mm/balloon_compaction.c        |    8 +
 mm/hmm.c                       | 1205 ++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                    |   61 ++
 mm/memory_hotplug.c            |   14 +-
 mm/migrate.c                   |  785 +++++++++++++++++++++++++-
 mm/mprotect.c                  |   14 +
 mm/page_vma_mapped.c           |   10 +
 mm/rmap.c                      |   25 +
 mm/zsmalloc.c                  |    8 +
 36 files changed, 3590 insertions(+), 50 deletions(-)
 create mode 100644 Documentation/vm/hmm.txt
 create mode 100644 include/linux/hmm.h
 create mode 100644 mm/hmm.c

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
