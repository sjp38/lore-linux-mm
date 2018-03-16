Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2A7816B0007
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:14:21 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id g7so2850301qti.14
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 12:14:21 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id l17si3512926qkk.482.2018.03.16.12.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 12:14:19 -0700 (PDT)
From: jglisse@redhat.com
Subject: [PATCH 01/14] mm/hmm: documentation editorial update to HMM documentation
Date: Fri, 16 Mar 2018 15:14:06 -0400
Message-Id: <20180316191414.3223-2-jglisse@redhat.com>
In-Reply-To: <20180316191414.3223-1-jglisse@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Stephen Bates <sbates@raithlin.com>, Jason Gunthorpe <jgg@mellanox.com>, Logan Gunthorpe <logang@deltatee.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>

From: Ralph Campbell <rcampbell@nvidia.com>

This patch updates the documentation for HMM to fix minor typos and
phrasing to be a bit more readable.

Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: Stephen  Bates <sbates@raithlin.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 Documentation/vm/hmm.txt | 360 ++++++++++++++++++++++++-----------------------
 MAINTAINERS              |   1 +
 2 files changed, 187 insertions(+), 174 deletions(-)

diff --git a/Documentation/vm/hmm.txt b/Documentation/vm/hmm.txt
index 4d3aac9f4a5d..c7418c56a0ac 100644
--- a/Documentation/vm/hmm.txt
+++ b/Documentation/vm/hmm.txt
@@ -1,151 +1,159 @@
 Heterogeneous Memory Management (HMM)
 
-Transparently allow any component of a program to use any memory region of said
-program with a device without using device specific memory allocator. This is
-becoming a requirement to simplify the use of advance heterogeneous computing
-where GPU, DSP or FPGA are use to perform various computations.
-
-This document is divided as follow, in the first section i expose the problems
-related to the use of a device specific allocator. The second section i expose
-the hardware limitations that are inherent to many platforms. The third section
-gives an overview of HMM designs. The fourth section explains how CPU page-
-table mirroring works and what is HMM purpose in this context. Fifth section
-deals with how device memory is represented inside the kernel. Finaly the last
-section present the new migration helper that allow to leverage the device DMA
-engine.
-
-
-1) Problems of using device specific memory allocator:
-2) System bus, device memory characteristics
-3) Share address space and migration
+Provide infrastructure and helpers to integrate non conventional memory (device
+memory like GPU on board memory) into regular kernel code path. Corner stone of
+this being specialize struct page for such memory (see sections 5 to 7 of this
+document).
+
+HMM also provide optional helpers for SVM (Share Virtual Memory) ie allowing a
+device to transparently access program address coherently with the CPU meaning
+that any valid pointer on the CPU is also a valid pointer for the device. This
+is becoming a mandatory to simplify the use of advance heterogeneous computing
+where GPU, DSP, or FPGA are used to perform various computations on behalf of
+a process.
+
+This document is divided as follows: in the first section I expose the problems
+related to using device specific memory allocators. In the second section, I
+expose the hardware limitations that are inherent to many platforms. The third
+section gives an overview of the HMM design. The fourth section explains how
+CPU page-table mirroring works and what is HMM's purpose in this context. The
+fifth section deals with how device memory is represented inside the kernel.
+Finally, the last section presents a new migration helper that allows lever-
+aging the device DMA engine.
+
+
+1) Problems of using a device specific memory allocator:
+2) I/O bus, device memory characteristics
+3) Shared address space and migration
 4) Address space mirroring implementation and API
 5) Represent and manage device memory from core kernel point of view
-6) Migrate to and from device memory
+6) Migration to and from device memory
 7) Memory cgroup (memcg) and rss accounting
 
 
 -------------------------------------------------------------------------------
 
-1) Problems of using device specific memory allocator:
+1) Problems of using a device specific memory allocator:
 
-Device with large amount of on board memory (several giga bytes) like GPU have
-historically manage their memory through dedicated driver specific API. This
-creates a disconnect between memory allocated and managed by device driver and
-regular application memory (private anonymous, share memory or regular file
-back memory). From here on i will refer to this aspect as split address space.
-I use share address space to refer to the opposite situation ie one in which
-any memory region can be use by device transparently.
+Devices with a large amount of on board memory (several giga bytes) like GPUs
+have historically managed their memory through dedicated driver specific APIs.
+This creates a disconnect between memory allocated and managed by a device
+driver and regular application memory (private anonymous, shared memory, or
+regular file backed memory). From here on I will refer to this aspect as split
+address space. I use shared address space to refer to the opposite situation:
+i.e., one in which any application memory region can be used by a device
+transparently.
 
 Split address space because device can only access memory allocated through the
-device specific API. This imply that all memory object in a program are not
-equal from device point of view which complicate large program that rely on a
-wide set of libraries.
+device specific API. This implies that all memory objects in a program are not
+equal from the device point of view which complicates large programs that rely
+on a wide set of libraries.
 
-Concretly this means that code that wants to leverage device like GPU need to
+Concretly this means that code that wants to leverage devices like GPUs need to
 copy object between genericly allocated memory (malloc, mmap private/share/)
 and memory allocated through the device driver API (this still end up with an
 mmap but of the device file).
 
-For flat dataset (array, grid, image, ...) this isn't too hard to achieve but
-complex data-set (list, tree, ...) are hard to get right. Duplicating a complex
-data-set need to re-map all the pointer relations between each of its elements.
-This is error prone and program gets harder to debug because of the duplicate
-data-set.
+For flat data-sets (array, grid, image, ...) this isn't too hard to achieve but
+complex data-sets (list, tree, ...) are hard to get right. Duplicating a
+complex data-set needs to re-map all the pointer relations between each of its
+elements. This is error prone and program gets harder to debug because of the
+duplicate data-set and addresses.
 
-Split address space also means that library can not transparently use data they
-are getting from core program or other library and thus each library might have
-to duplicate its input data-set using specific memory allocator. Large project
-suffer from this and waste resources because of the various memory copy.
+Split address space also means that libraries can not transparently use data
+they are getting from the core program or another library and thus each library
+might have to duplicate its input data-set using the device specific memory
+allocator. Large projects suffer from this and waste resources because of the
+various memory copies.
 
 Duplicating each library API to accept as input or output memory allocted by
 each device specific allocator is not a viable option. It would lead to a
-combinatorial explosions in the library entry points.
+combinatorial explosion in the library entry points.
 
-Finaly with the advance of high level language constructs (in C++ but in other
-language too) it is now possible for compiler to leverage GPU or other devices
-without even the programmer knowledge. Some of compiler identified patterns are
-only do-able with a share address. It is as well more reasonable to use a share
-address space for all the other patterns.
+Finally, with the advance of high level language constructs (in C++ but in
+other languages too) it is now possible for the compiler to leverage GPUs and
+other devices without programmer knowledge. Some compiler identified patterns
+are only do-able with a shared address space. It is also more reasonable to use
+a shared address space for all other patterns.
 
 
 -------------------------------------------------------------------------------
 
-2) System bus, device memory characteristics
+2) I/O bus, device memory characteristics
 
-System bus cripple share address due to few limitations. Most system bus only
+I/O buses cripple shared address due to few limitations. Most I/O buses only
 allow basic memory access from device to main memory, even cache coherency is
-often optional. Access to device memory from CPU is even more limited, most
-often than not it is not cache coherent.
+often optional. Access to device memory from CPU is even more limited. More
+often than not, it is not cache coherent.
 
-If we only consider the PCIE bus than device can access main memory (often
-through an IOMMU) and be cache coherent with the CPUs. However it only allows
-a limited set of atomic operation from device on main memory. This is worse
-in the other direction the CPUs can only access a limited range of the device
+If we only consider the PCIE bus, then a device can access main memory (often
+through an IOMMU) and be cache coherent with the CPUs. However, it only allows
+a limited set of atomic operations from device on main memory. This is worse
+in the other direction, the CPU can only access a limited range of the device
 memory and can not perform atomic operations on it. Thus device memory can not
-be consider like regular memory from kernel point of view.
+be considered the same as regular memory from the kernel point of view.
 
 Another crippling factor is the limited bandwidth (~32GBytes/s with PCIE 4.0
-and 16 lanes). This is 33 times less that fastest GPU memory (1 TBytes/s).
-The final limitation is latency, access to main memory from the device has an
-order of magnitude higher latency than when the device access its own memory.
+and 16 lanes). This is 33 times less than the fastest GPU memory (1 TBytes/s).
+The final limitation is latency. Access to main memory from the device has an
+order of magnitude higher latency than when the device accesses its own memory.
 
-Some platform are developing new system bus or additions/modifications to PCIE
-to address some of those limitations (OpenCAPI, CCIX). They mainly allow two
+Some platforms are developing new I/O buses or additions/modifications to PCIE
+to address some of these limitations (OpenCAPI, CCIX). They mainly allow two
 way cache coherency between CPU and device and allow all atomic operations the
-architecture supports. Saddly not all platform are following this trends and
-some major architecture are left without hardware solutions to those problems.
+architecture supports. Saddly, not all platforms are following this trend and
+some major architectures are left without hardware solutions to these problems.
 
-So for share address space to make sense not only we must allow device to
+So for shared address space to make sense, not only must we allow device to
 access any memory memory but we must also permit any memory to be migrated to
 device memory while device is using it (blocking CPU access while it happens).
 
 
 -------------------------------------------------------------------------------
 
-3) Share address space and migration
+3) Shared address space and migration
 
 HMM intends to provide two main features. First one is to share the address
-space by duplication the CPU page table into the device page table so same
-address point to same memory and this for any valid main memory address in
+space by duplicating the CPU page table in the device page table so the same
+address points to the same physical memory for any valid main memory address in
 the process address space.
 
-To achieve this, HMM offer a set of helpers to populate the device page table
+To achieve this, HMM offers a set of helpers to populate the device page table
 while keeping track of CPU page table updates. Device page table updates are
-not as easy as CPU page table updates. To update the device page table you must
-allow a buffer (or use a pool of pre-allocated buffer) and write GPU specifics
-commands in it to perform the update (unmap, cache invalidations and flush,
-...). This can not be done through common code for all device. Hence why HMM
-provides helpers to factor out everything that can be while leaving the gory
-details to the device driver.
-
-The second mechanism HMM provide is a new kind of ZONE_DEVICE memory that does
-allow to allocate a struct page for each page of the device memory. Those page
-are special because the CPU can not map them. They however allow to migrate
-main memory to device memory using exhisting migration mechanism and everything
-looks like if page was swap out to disk from CPU point of view. Using a struct
-page gives the easiest and cleanest integration with existing mm mechanisms.
-Again here HMM only provide helpers, first to hotplug new ZONE_DEVICE memory
-for the device memory and second to perform migration. Policy decision of what
-and when to migrate things is left to the device driver.
-
-Note that any CPU access to a device page trigger a page fault and a migration
-back to main memory ie when a page backing an given address A is migrated from
-a main memory page to a device page then any CPU access to address A trigger a
-page fault and initiate a migration back to main memory.
-
-
-With this two features, HMM not only allow a device to mirror a process address
-space and keeps both CPU and device page table synchronize, but also allow to
-leverage device memory by migrating part of data-set that is actively use by a
-device.
+not as easy as CPU page table updates. To update the device page table, you must
+allocate a buffer (or use a pool of pre-allocated buffers) and write GPU
+specific commands in it to perform the update (unmap, cache invalidations, and
+flush, ...). This can not be done through common code for all devices. Hence
+why HMM provides helpers to factor out everything that can be while leaving the
+hardware specific details to the device driver.
+
+The second mechanism HMM provides, is a new kind of ZONE_DEVICE memory that
+allows allocating a struct page for each page of the device memory. Those pages
+are special because the CPU can not map them. However, they allow migrating
+main memory to device memory using existing migration mechanisms and everything
+looks like a page is swapped out to disk from the CPU point of view. Using a
+struct page gives the easiest and cleanest integration with existing mm mech-
+anisms. Here again, HMM only provides helpers, first to hotplug new ZONE_DEVICE
+memory for the device memory and second to perform migration. Policy decisions
+of what and when to migrate things is left to the device driver.
+
+Note that any CPU access to a device page triggers a page fault and a migration
+back to main memory. For example, when a page backing a given CPU address A is
+migrated from a main memory page to a device page, then any CPU access to
+address A triggers a page fault and initiates a migration back to main memory.
+
+With these two features, HMM not only allows a device to mirror process address
+space and keeping both CPU and device page table synchronized, but also lever-
+ages device memory by migrating the part of the data-set that is actively being
+used by the device.
 
 
 -------------------------------------------------------------------------------
 
 4) Address space mirroring implementation and API
 
-Address space mirroring main objective is to allow to duplicate range of CPU
-page table into a device page table and HMM helps keeping both synchronize. A
+Address space mirroring's main objective is to allow duplication of a range of
+CPU page table into a device page table; HMM helps keep both synchronized. A
 device driver that want to mirror a process address space must start with the
 registration of an hmm_mirror struct:
 
@@ -155,8 +163,8 @@ device driver that want to mirror a process address space must start with the
                                 struct mm_struct *mm);
 
 The locked variant is to be use when the driver is already holding the mmap_sem
-of the mm in write mode. The mirror struct has a set of callback that are use
-to propagate CPU page table:
+of the mm in write mode. The mirror struct has a set of callbacks that are used
+to propagate CPU page tables:
 
  struct hmm_mirror_ops {
      /* sync_cpu_device_pagetables() - synchronize page tables
@@ -181,13 +189,13 @@ of the mm in write mode. The mirror struct has a set of callback that are use
                      unsigned long end);
  };
 
-Device driver must perform update to the range following action (turn range
-read only, or fully unmap, ...). Once driver callback returns the device must
-be done with the update.
+The device driver must perform the update action to the range (mark range
+read only, or fully unmap, ...). The device must be done with the update before
+the driver callback returns.
 
 
-When device driver wants to populate a range of virtual address it can use
-either:
+When the device driver wants to populate a range of virtual addresses, it can
+use either:
  int hmm_vma_get_pfns(struct vm_area_struct *vma,
                       struct hmm_range *range,
                       unsigned long start,
@@ -201,17 +209,19 @@ When device driver wants to populate a range of virtual address it can use
                    bool write,
                    bool block);
 
-First one (hmm_vma_get_pfns()) will only fetch present CPU page table entry and
-will not trigger a page fault on missing or non present entry. The second one
-do trigger page fault on missing or read only entry if write parameter is true.
-Page fault use the generic mm page fault code path just like a CPU page fault.
+The first one (hmm_vma_get_pfns()) will only fetch present CPU page table
+entries and will not trigger a page fault on missing or non present entries.
+The second one does trigger a page fault on missing or read only entry if the
+write parameter is true. Page faults use the generic mm page fault code path
+just like a CPU page fault.
 
-Both function copy CPU page table into their pfns array argument. Each entry in
-that array correspond to an address in the virtual range. HMM provide a set of
-flags to help driver identify special CPU page table entries.
+Both functions copy CPU page table entries into their pfns array argument. Each
+entry in that array corresponds to an address in the virtual range. HMM
+provides a set of flags to help the driver identify special CPU page table
+entries.
 
 Locking with the update() callback is the most important aspect the driver must
-respect in order to keep things properly synchronize. The usage pattern is :
+respect in order to keep things properly synchronized. The usage pattern is:
 
  int driver_populate_range(...)
  {
@@ -233,43 +243,44 @@ Locking with the update() callback is the most important aspect the driver must
       return 0;
  }
 
-The driver->update lock is the same lock that driver takes inside its update()
-callback. That lock must be call before hmm_vma_range_done() to avoid any race
-with a concurrent CPU page table update.
+The driver->update lock is the same lock that the driver takes inside its
+update() callback. That lock must be held before hmm_vma_range_done() to avoid
+any race with a concurrent CPU page table update.
 
-HMM implements all this on top of the mmu_notifier API because we wanted to a
-simpler API and also to be able to perform optimization latter own like doing
-concurrent device update in multi-devices scenario.
+HMM implements all this on top of the mmu_notifier API because we wanted a
+simpler API and also to be able to perform optimizations latter on like doing
+concurrent device updates in multi-devices scenario.
 
-HMM also serve as an impedence missmatch between how CPU page table update are
-done (by CPU write to the page table and TLB flushes) from how device update
-their own page table. Device update is a multi-step process, first appropriate
-commands are write to a buffer, then this buffer is schedule for execution on
-the device. It is only once the device has executed commands in the buffer that
-the update is done. Creating and scheduling update command buffer can happen
-concurrently for multiple devices. Waiting for each device to report commands
-as executed is serialize (there is no point in doing this concurrently).
+HMM also serves as an impedence missmatch between how CPU page table updates
+are done (by CPU write to the page table and TLB flushes) and how devices
+update their own page table. Device updates are a multi-step process. First,
+appropriate commands are writen to a buffer, then this buffer is scheduled for
+execution on the device. It is only once the device has executed commands in
+the buffer that the update is done. Creating and scheduling the update command
+buffer can happen concurrently for multiple devices. Waiting for each device to
+report commands as executed is serialized (there is no point in doing this
+concurrently).
 
 
 -------------------------------------------------------------------------------
 
 5) Represent and manage device memory from core kernel point of view
 
-Several differents design were try to support device memory. First one use
-device specific data structure to keep information about migrated memory and
-HMM hooked itself in various place of mm code to handle any access to address
-that were back by device memory. It turns out that this ended up replicating
-most of the fields of struct page and also needed many kernel code path to be
-updated to understand this new kind of memory.
+Several different designs were tried to support device memory. First one used
+a device specific data structure to keep information about migrated memory and
+HMM hooked itself in various places of mm code to handle any access to
+addresses that were backed by device memory. It turns out that this ended up
+replicating most of the fields of struct page and also needed many kernel code
+paths to be updated to understand this new kind of memory.
 
-Thing is most kernel code path never try to access the memory behind a page
-but only care about struct page contents. Because of this HMM switchted to
-directly using struct page for device memory which left most kernel code path
-un-aware of the difference. We only need to make sure that no one ever try to
-map those page from the CPU side.
+Most kernel code paths never try to access the memory behind a page
+but only care about struct page contents. Because of this, HMM switched to
+directly using struct page for device memory which left most kernel code paths
+unaware of the difference. We only need to make sure that no one ever tries to
+map those pages from the CPU side.
 
-HMM provide a set of helpers to register and hotplug device memory as a new
-region needing struct page. This is offer through a very simple API:
+HMM provides a set of helpers to register and hotplug device memory as a new
+region needing a struct page. This is offered through a very simple API:
 
  struct hmm_devmem *hmm_devmem_add(const struct hmm_devmem_ops *ops,
                                    struct device *device,
@@ -289,18 +300,19 @@ HMM provide a set of helpers to register and hotplug device memory as a new
  };
 
 The first callback (free()) happens when the last reference on a device page is
-drop. This means the device page is now free and no longer use by anyone. The
-second callback happens whenever CPU try to access a device page which it can
-not do. This second callback must trigger a migration back to system memory.
+dropped. This means the device page is now free and no longer used by anyone.
+The second callback happens whenever the CPU tries to access a device page
+which it can not do. This second callback must trigger a migration back to
+system memory.
 
 
 -------------------------------------------------------------------------------
 
-6) Migrate to and from device memory
+6) Migration to and from device memory
 
-Because CPU can not access device memory, migration must use device DMA engine
-to perform copy from and to device memory. For this we need a new migration
-helper:
+Because the CPU can not access device memory, migration must use the device DMA
+engine to perform copy from and to device memory. For this we need a new
+migration helper:
 
  int migrate_vma(const struct migrate_vma_ops *ops,
                  struct vm_area_struct *vma,
@@ -311,15 +323,15 @@ to perform copy from and to device memory. For this we need a new migration
                  unsigned long *dst,
                  void *private);
 
-Unlike other migration function it works on a range of virtual address, there
-is two reasons for that. First device DMA copy has a high setup overhead cost
+Unlike other migration functions it works on a range of virtual address, there
+are two reasons for that. First, device DMA copy has a high setup overhead cost
 and thus batching multiple pages is needed as otherwise the migration overhead
-make the whole excersie pointless. The second reason is because driver trigger
-such migration base on range of address the device is actively accessing.
+makes the whole exersize pointless. The second reason is because the
+migration might be for a range of addresses the device is actively accessing.
 
-The migrate_vma_ops struct define two callbacks. First one (alloc_and_copy())
-control destination memory allocation and copy operation. Second one is there
-to allow device driver to perform cleanup operation after migration.
+The migrate_vma_ops struct defines two callbacks. First one (alloc_and_copy())
+controls destination memory allocation and copy operation. Second one is there
+to allow the device driver to perform cleanup operations after migration.
 
  struct migrate_vma_ops {
      void (*alloc_and_copy)(struct vm_area_struct *vma,
@@ -336,19 +348,19 @@ to allow device driver to perform cleanup operation after migration.
                               void *private);
  };
 
-It is important to stress that this migration helpers allow for hole in the
+It is important to stress that these migration helpers allow for holes in the
 virtual address range. Some pages in the range might not be migrated for all
-the usual reasons (page is pin, page is lock, ...). This helper does not fail
-but just skip over those pages.
+the usual reasons (page is pinned, page is locked, ...). This helper does not
+fail but just skips over those pages.
 
-The alloc_and_copy() might as well decide to not migrate all pages in the
-range (for reasons under the callback control). For those the callback just
-have to leave the corresponding dst entry empty.
+The alloc_and_copy() might decide to not migrate all pages in the
+range (for reasons under the callback control). For those, the callback just
+has to leave the corresponding dst entry empty.
 
-Finaly the migration of the struct page might fails (for file back page) for
+Finally, the migration of the struct page might fail (for file backed page) for
 various reasons (failure to freeze reference, or update page cache, ...). If
-that happens then the finalize_and_map() can catch any pages that was not
-migrated. Note those page were still copied to new page and thus we wasted
+that happens, then the finalize_and_map() can catch any pages that were not
+migrated. Note those pages were still copied to a new page and thus we wasted
 bandwidth but this is considered as a rare event and a price that we are
 willing to pay to keep all the code simpler.
 
@@ -358,27 +370,27 @@ willing to pay to keep all the code simpler.
 7) Memory cgroup (memcg) and rss accounting
 
 For now device memory is accounted as any regular page in rss counters (either
-anonymous if device page is use for anonymous, file if device page is use for
-file back page or shmem if device page is use for share memory). This is a
-deliberate choice to keep existing application that might start using device
-memory without knowing about it to keep runing unimpacted.
-
-Drawbacks is that OOM killer might kill an application using a lot of device
-memory and not a lot of regular system memory and thus not freeing much system
-memory. We want to gather more real world experience on how application and
-system react under memory pressure in the presence of device memory before
+anonymous if device page is used for anonymous, file if device page is used for
+file backed page or shmem if device page is used for shared memory). This is a
+deliberate choice to keep existing applications, that might start using device
+memory without knowing about it, running unimpacted.
+
+A Drawback is that the OOM killer might kill an application using a lot of
+device memory and not a lot of regular system memory and thus not freeing much
+system memory. We want to gather more real world experience on how applications
+and system react under memory pressure in the presence of device memory before
 deciding to account device memory differently.
 
 
-Same decision was made for memory cgroup. Device memory page are accounted
+Same decision was made for memory cgroup. Device memory pages are accounted
 against same memory cgroup a regular page would be accounted to. This does
 simplify migration to and from device memory. This also means that migration
 back from device memory to regular memory can not fail because it would
 go above memory cgroup limit. We might revisit this choice latter on once we
-get more experience in how device memory is use and its impact on memory
+get more experience in how device memory is used and its impact on memory
 resource control.
 
 
-Note that device memory can never be pin nor by device driver nor through GUP
+Note that device memory can never be pinned by device driver nor through GUP
 and thus such memory is always free upon process exit. Or when last reference
-is drop in case of share memory or file back memory.
+is dropped in case of shared memory or file backed memory.
diff --git a/MAINTAINERS b/MAINTAINERS
index 8be7d1382ce9..4db4d4a820b1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6466,6 +6466,7 @@ L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/hmm*
 F:	include/linux/hmm*
+F:	Documentation/vm/hmm.txt
 
 HOST AP DRIVER
 M:	Jouni Malinen <j@w1.fi>
-- 
2.14.3
