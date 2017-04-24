Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53D246B02EE
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 14:12:54 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j130so43486492qkj.3
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:12:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h33si18871910qta.167.2017.04.24.11.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 11:12:52 -0700 (PDT)
From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
Subject: [HMM 00/15] HMM (Heterogeneous Memory Management) v21
Date: Mon, 24 Apr 2017 14:12:28 -0400
Message-Id: <20170424181243.20320-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

Sorry for repost but changing name impact enough patches that it
make more sense to repost the whole serie.

Patchset is on top of mmotm mmotm-2017-04-18 and Michal patchset
([PATCH -v3 0/13] mm: make movable onlining suck less). Branch:

https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v21

Only change since v20 is changing device unaddressable to device
private as Dan requested. Everything else is the same as v20.


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
Patch 1    add new add_pages() helper to avoid modifying each arch memory
           hot plug function
Patch 2    move the page reference decrement from put_page() to
           put_zone_device_page() Dan Williams is the best person to review
           this change
Patch 3    add a new memory type for ZONE_DEVICE and also add all the logic
           in various core mm to support this new type. Dan Williams and
           any core mm contributor are best people to review each half of
           this patchset
Patch 4    add a new migrate mode. Any one familiar with page migration is
           welcome to review.
Patch 5    introduce a new migration helper (migrate_vma()) that allow to
           migrate a range of virtual address of a process using device DMA
           engine to perform the copy. It is not limited to do copy from and
           to device but can also do copy between any kind of source and
           destination memory. Again anyone familiar with migration code
           should be able to verify the logic.
Patch 6    optimize the new migrate_vma() by unmapping pages while we are
           collecting them. This can be review by any mm folks.
Patch 7    introduce core infrastructure and definition of HMM, pretty
           small patch and easy to review
Patch 8    introduce the mirror functionality of HMM, it relies on
           mmu_notifier and thus someone familiar with that part would be
           in better position to review
Patch 9    is an helper to snapshot CPU page table while synchronizing with
           concurrent page table update. Understanding mmu_notifier makes
           review easier.
Patch 10   is mostly a wrapper around handle_mm_fault()
Patch 11   add unaddressable memory migration to helper introduced in patch
           6, this can be review by anyone familiar with migration code
Patch 12   add a feature that allow device to allocate non-present page on
           the GPU when migrating a range of address to device memory. This
           is an helper for device driver to avoid having to first allocate
           system memory before migration to device memory
Patch 13   add helper to hotplug un-addressable device memory as new type
           of ZONE_DEVICE memory (new type introducted in patch 3 of this
           serie). This is boiler plate code around memory hotplug and it
           also pick a free range of physical address for the device memory.
           Note that the physical address do not point to anything (at least
           as far as the kernel knows).
Patch 14   introduce a new hmm_device class as an helper for device driver
           that want to expose multiple device memory under a common fake
           device driver. This is usefull for multi-gpu configuration.
           Anyone familiar with device driver infrastructure can review
           this. Boiler plate code really.
Patch 15   is the documentation for everything


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
    v19 https://lkml.org/lkml/2017/4/5/831
    v20 https://lwn.net/Articles/720715/

JA(C)rA'me Glisse (14):
  mm/put_page: move ZONE_DEVICE page reference decrement v2
  mm/private-memory: new type of ZONE_DEVICE for unaddressable memory v2
  mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY
  mm/migrate: new memory migration helper for use with device memory v4
  mm/migrate: migrate_vma() unmap page from vma while collecting pages
  mm/hmm: heterogeneous memory management (HMM for short) v3
  mm/hmm/mirror: mirror process address space on device with HMM helpers
    v3
  mm/hmm/mirror: helper to snapshot CPU page table v3
  mm/hmm/mirror: device page fault handler
  mm/migrate: support un-addressable ZONE_DEVICE page in migration v2
  mm/migrate: allow migrate_vma() to alloc new page on empty entry v2
  mm/hmm/devmem: device memory hotplug using ZONE_DEVICE v4
  mm/hmm/devmem: dummy HMM device for ZONE_DEVICE memory v3
  hmm: heterogeneous memory management documentation

Michal Hocko (1):
  mm, memory_hotplug: introduce add_pages

 Documentation/vm/hmm.txt       |  362 ++++++++++++
 MAINTAINERS                    |    7 +
 arch/x86/Kconfig               |    4 +
 arch/x86/mm/init_64.c          |   22 +-
 fs/aio.c                       |    8 +
 fs/f2fs/data.c                 |    5 +-
 fs/hugetlbfs/inode.c           |    5 +-
 fs/proc/task_mmu.c             |    7 +
 fs/ubifs/file.c                |    5 +-
 include/linux/hmm.h            |  468 ++++++++++++++++
 include/linux/ioport.h         |    1 +
 include/linux/memory_hotplug.h |   11 +
 include/linux/memremap.h       |   82 +++
 include/linux/migrate.h        |  115 ++++
 include/linux/migrate_mode.h   |    5 +
 include/linux/mm.h             |   14 +-
 include/linux/mm_types.h       |    5 +
 include/linux/swap.h           |   24 +-
 include/linux/swapops.h        |   68 +++
 kernel/fork.c                  |    2 +
 kernel/memremap.c              |   47 ++
 mm/Kconfig                     |   47 ++
 mm/Makefile                    |    1 +
 mm/balloon_compaction.c        |    8 +
 mm/hmm.c                       | 1203 ++++++++++++++++++++++++++++++++++++++++
 mm/memory.c                    |   61 ++
 mm/memory_hotplug.c            |   10 +-
 mm/migrate.c                   |  789 +++++++++++++++++++++++++-
 mm/mprotect.c                  |   14 +
 mm/page_vma_mapped.c           |   10 +
 mm/rmap.c                      |   25 +
 mm/zsmalloc.c                  |    8 +
 32 files changed, 3412 insertions(+), 31 deletions(-)
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
