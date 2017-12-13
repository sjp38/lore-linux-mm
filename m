Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE686B0069
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 07:10:44 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id v63so931142oif.7
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 04:10:44 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k206sor492619oib.316.2017.12.13.04.10.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 04:10:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170817000548.32038-1-jglisse@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Wed, 13 Dec 2017 20:10:42 +0800
Message-ID: <CAF7GXvqSZzNHdefQWhEb2SDYWX5hDWqQX7cayuVEQ8YyTULPog@mail.gmail.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Content-Type: multipart/alternative; boundary="001a113d68c80fd105056037a8fd"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

--001a113d68c80fd105056037a8fd
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

it mention that HMM provided two functions:

1. one is mirror the page table between CPU and a device(like GPU, FPGA),
so i am confused that:  duplicating the CPU page table into a device page
table means

that copy the CPU page table entry into device page table? so the device
can access the CPU's virtual address? and that device can access the the CP=
U

allocated physical memory which map into this VMA, right?


for example:  VMA -> PA (CPU physical address)

mirror: fill the the PTE entry of this VMA into GPU's  page table

so:

For CPU's view: it can access the PA

For GPU's view: it can access the CPU's VMA and PA

right?


2. other function is migrate CPU memory to device memory, what is the
application scenario ?

some input data created by GPU and migrate back to CPU memory? use for CPU
to access GPU's data?

3. function one is help the GPU to access CPU's VMA and  CPU's physical
memory, if CPU want to access GPU's memory, still need to

specification device driver API like IOCTL+mmap+DMA?

4. is it any example? i remember it has a dummy driver in older patchset
version. i canot find in this version.

2017-08-17 8:05 GMT+08:00 J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>:

> Patchset is on top of git://git.cmpxchg.org/linux-mmotm.git so i
> test same kernel as kbuild system, git branch:
>
> https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-v25
>
> Change since v24 are:
>   - more comments and more documentations
>   - fix dumb mistake when registering device
>   - fix race when multiple concurrent device fault
>   - merge HMM-CDM patchset with HMM patchset to avoid unecessary code
>     churn
>
> The overall logic is the same. Below is the long description of what HMM
> is about and why. At the end of this email i describe briefly each patch
> and suggest reviewers for each of them.
>
> Please consider this patchset for 4.14
>
>
> Heterogeneous Memory Management (HMM) (description and justification)
>
> Today device driver expose dedicated memory allocation API through their
> device file, often relying on a combination of IOCTL and mmap calls. The
> device can only access and use memory allocated through this API. This
> effectively split the program address space into object allocated for the
> device and useable by the device and other regular memory (malloc, mmap
> of a file, share memory, =C3=A2) only accessible by CPU (or in a very lim=
ited
> way by a device by pinning memory).
>
> Allowing different isolated component of a program to use a device thus
> require duplication of the input data structure using device memory
> allocator. This is reasonable for simple data structure (array, grid,
> image, =C3=A2) but this get extremely complex with advance data structure
> (list, tree, graph, =C3=A2) that rely on a web of memory pointers. This i=
s
> becoming a serious limitation on the kind of work load that can be
> offloaded to device like GPU.
>
> New industry standard like C++, OpenCL or CUDA are pushing to remove this
> barrier. This require a shared address space between GPU device and CPU s=
o
> that GPU can access any memory of a process (while still obeying memory
> protection like read only). This kind of feature is also appearing in
> various other operating systems.
>
> HMM is a set of helpers to facilitate several aspects of address space
> sharing and device memory management. Unlike existing sharing mechanism
> that rely on pining pages use by a device, HMM relies on mmu_notifier to
> propagate CPU page table update to device page table.
>
> Duplicating CPU page table is only one aspect necessary for efficiently
> using device like GPU. GPU local memory have bandwidth in the TeraBytes/
> second range but they are connected to main memory through a system bus
> like PCIE that is limited to 32GigaBytes/second (PCIE 4.0 16x). Thus it
> is necessary to allow migration of process memory from main system memory
> to device memory. Issue is that on platform that only have PCIE the devic=
e
> memory is not accessible by the CPU with the same properties as main
> memory (cache coherency, atomic operations, ...).
>
> To allow migration from main memory to device memory HMM provides a set
> of helper to hotplug device memory as a new type of ZONE_DEVICE memory
> which is un-addressable by CPU but still has struct page representing it.
> This allow most of the core kernel logic that deals with a process memory
> to stay oblivious of the peculiarity of device memory.
>
> When page backing an address of a process is migrated to device memory
> the CPU page table entry is set to a new specific swap entry. CPU access
> to such address triggers a migration back to system memory, just like if
> the page was swap on disk. HMM also blocks any one from pinning a
> ZONE_DEVICE page so that it can always be migrated back to system memory
> if CPU access it. Conversely HMM does not migrate to device memory any
> page that is pin in system memory.
>
> To allow efficient migration between device memory and main memory a new
> migrate_vma() helpers is added with this patchset. It allows to leverage
> device DMA engine to perform the copy operation.
>
> This feature will be use by upstream driver like nouveau mlx5 and probabl=
y
> other in the future (amdgpu is next suspect in line). We are actively
> working on nouveau and mlx5 support. To test this patchset we also worked
> with NVidia close source driver team, they have more resources than us to
> test this kind of infrastructure and also a bigger and better userspace
> eco-system with various real industry workload they can be use to test an=
d
> profile HMM.
>
> The expected workload is a program builds a data set on the CPU (from dis=
k,
> from network, from sensors, =C3=A2). Program uses GPU API (OpenCL, CUDA, =
...)
> to give hint on memory placement for the input data and also for the outp=
ut
> buffer. Program call GPU API to schedule a GPU job, this happens using
> device driver specific ioctl. All this is hidden from programmer point of
> view in case of C++ compiler that transparently offload some part of a
> program to GPU. Program can keep doing other stuff on the CPU while the
> GPU is crunching numbers.
>
> It is expected that CPU will not access the same data set as the GPU whil=
e
> GPU is working on it, but this is not mandatory. In fact we expect some
> small memory object to be actively access by both GPU and CPU concurrentl=
y
> as synchronization channel and/or for monitoring purposes. Such object wi=
ll
> stay in system memory and should not be bottlenecked by system bus
> bandwidth (rare write and read access from both CPU and GPU).
>
> As we are relying on device driver API, HMM does not introduce any new
> syscall nor does it modify any existing ones. It does not change any POSI=
X
> semantics or behaviors. For instance the child after a fork of a process
> that is using HMM will not be impacted in anyway, nor is there any data
> hazard between child COW or parent COW of memory that was migrated to
> device prior to fork.
>
> HMM assume a numbers of hardware features. Device must allow device page
> table to be updated at any time (ie device job must be preemptable). Devi=
ce
> page table must provides memory protection such as read only. Device must
> track write access (dirty bit). Device must have a minimum granularity th=
at
> match PAGE_SIZE (ie 4k).
>
>
> Reviewer (just hint):
> Patch 1  HMM documentation
> Patch 2  introduce core infrastructure and definition of HMM, pretty
>          small patch and easy to review
> Patch 3  introduce the mirror functionality of HMM, it relies on
>          mmu_notifier and thus someone familiar with that part would be
>          in better position to review
> Patch 4  is an helper to snapshot CPU page table while synchronizing with
>          concurrent page table update. Understanding mmu_notifier makes
>          review easier.
> Patch 5  is mostly a wrapper around handle_mm_fault()
> Patch 6  add new add_pages() helper to avoid modifying each arch memory
>          hot plug function
> Patch 7  add a new memory type for ZONE_DEVICE and also add all the logic
>          in various core mm to support this new type. Dan Williams and
>          any core mm contributor are best people to review each half of
>          this patchset
> Patch 8  special case HMM ZONE_DEVICE pages inside put_page() Kirill and
>          Dan Williams are best person to review this
> Patch 9  allow to uncharge a page from memory group without using the lru
>          list field of struct page (best reviewer: Johannes Weiner or
>          Vladimir Davydov or Michal Hocko)
> Patch 10 Add support to uncharge ZONE_DEVICE page from a memory cgroup
> (best
>          reviewer: Johannes Weiner or Vladimir Davydov or Michal Hocko)
> Patch 11 add helper to hotplug un-addressable device memory as new type
>          of ZONE_DEVICE memory (new type introducted in patch 3 of this
>          serie). This is boiler plate code around memory hotplug and it
>          also pick a free range of physical address for the device memory=
.
>          Note that the physical address do not point to anything (at leas=
t
>          as far as the kernel knows).
> Patch 12 introduce a new hmm_device class as an helper for device driver
>          that want to expose multiple device memory under a common fake
>          device driver. This is usefull for multi-gpu configuration.
>          Anyone familiar with device driver infrastructure can review
>          this. Boiler plate code really.
> Patch 13 add a new migrate mode. Any one familiar with page migration is
>          welcome to review.
> Patch 14 introduce a new migration helper (migrate_vma()) that allow to
>          migrate a range of virtual address of a process using device DMA
>          engine to perform the copy. It is not limited to do copy from an=
d
>          to device but can also do copy between any kind of source and
>          destination memory. Again anyone familiar with migration code
>          should be able to verify the logic.
> Patch 15 optimize the new migrate_vma() by unmapping pages while we are
>          collecting them. This can be review by any mm folks.
> Patch 16 add unaddressable memory migration to helper introduced in patch
>          7, this can be review by anyone familiar with migration code
> Patch 17 add a feature that allow device to allocate non-present page on
>          the GPU when migrating a range of address to device memory. This
>          is an helper for device driver to avoid having to first allocate
>          system memory before migration to device memory
> Patch 18 add a new kind of ZONE_DEVICE memory for cache coherent device
>          memory (CDM)
> Patch 19 add an helper to hotplug CDM memory
>
>
> Previous patchset posting :
> v1 http://lwn.net/Articles/597289/
> v2 https://lkml.org/lkml/2014/6/12/559
> v3 https://lkml.org/lkml/2014/6/13/633
> v4 https://lkml.org/lkml/2014/8/29/423
> v5 https://lkml.org/lkml/2014/11/3/759
> v6 http://lwn.net/Articles/619737/
> v7 http://lwn.net/Articles/627316/
> v8 https://lwn.net/Articles/645515/
> v9 https://lwn.net/Articles/651553/
> v10 https://lwn.net/Articles/654430/
> v11 http://www.gossamer-threads.com/lists/linux/kernel/2286424
> v12 http://www.kernelhub.org/?msg=3D972982&p=3D2
> v13 https://lwn.net/Articles/706856/
> v14 https://lkml.org/lkml/2016/12/8/344
> v15 http://www.mail-archive.com/linux-kernel@xxxxxxxxxxxxxxx/
> msg1304107.html
> v16 http://www.spinics.net/lists/linux-mm/msg119814.html
> v17 https://lkml.org/lkml/2017/1/27/847
> v18 https://lkml.org/lkml/2017/3/16/596
> v19 https://lkml.org/lkml/2017/4/5/831
> v20 https://lwn.net/Articles/720715/
> v21 https://lkml.org/lkml/2017/4/24/747
> v22 http://lkml.iu.edu/hypermail/linux/kernel/1705.2/05176.html
> v23 https://www.mail-archive.com/linux-kernel@vger.kernel.org/
> msg1404788.html
> v24 https://lwn.net/Articles/726691/
>
> J=C3=A9r=C3=B4me Glisse (18):
>   hmm: heterogeneous memory management documentation v3
>   mm/hmm: heterogeneous memory management (HMM for short) v5
>   mm/hmm/mirror: mirror process address space on device with HMM helpers
>     v3
>   mm/hmm/mirror: helper to snapshot CPU page table v4
>   mm/hmm/mirror: device page fault handler
>   mm/ZONE_DEVICE: new type of ZONE_DEVICE for unaddressable memory v5
>   mm/ZONE_DEVICE: special case put_page() for device private pages v4
>   mm/memcontrol: allow to uncharge page without using page->lru field
>   mm/memcontrol: support MEMORY_DEVICE_PRIVATE v4
>   mm/hmm/devmem: device memory hotplug using ZONE_DEVICE v7
>   mm/hmm/devmem: dummy HMM device for ZONE_DEVICE memory v3
>   mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY
>   mm/migrate: new memory migration helper for use with device memory v5
>   mm/migrate: migrate_vma() unmap page from vma while collecting pages
>   mm/migrate: support un-addressable ZONE_DEVICE page in migration v3
>   mm/migrate: allow migrate_vma() to alloc new page on empty entry v4
>   mm/device-public-memory: device memory cache coherent with CPU v5
>   mm/hmm: add new helper to hotplug CDM memory region v3
>
> Michal Hocko (1):
>   mm/memory_hotplug: introduce add_pages
>
>  Documentation/vm/hmm.txt       |  384 ++++++++++++
>  MAINTAINERS                    |    7 +
>  arch/x86/Kconfig               |    4 +
>  arch/x86/mm/init_64.c          |   22 +-
>  fs/aio.c                       |    8 +
>  fs/f2fs/data.c                 |    5 +-
>  fs/hugetlbfs/inode.c           |    5 +-
>  fs/proc/task_mmu.c             |    9 +-
>  fs/ubifs/file.c                |    5 +-
>  include/linux/hmm.h            |  518 ++++++++++++++++
>  include/linux/ioport.h         |    2 +
>  include/linux/memory_hotplug.h |   11 +
>  include/linux/memremap.h       |  107 ++++
>  include/linux/migrate.h        |  124 ++++
>  include/linux/migrate_mode.h   |    5 +
>  include/linux/mm.h             |   33 +-
>  include/linux/mm_types.h       |    6 +
>  include/linux/swap.h           |   24 +-
>  include/linux/swapops.h        |   68 +++
>  kernel/fork.c                  |    3 +
>  kernel/memremap.c              |   60 +-
>  mm/Kconfig                     |   47 +-
>  mm/Makefile                    |    2 +-
>  mm/balloon_compaction.c        |    8 +
>  mm/gup.c                       |    7 +
>  mm/hmm.c                       | 1273 ++++++++++++++++++++++++++++++
> ++++++++++
>  mm/madvise.c                   |    2 +-
>  mm/memcontrol.c                |  222 ++++---
>  mm/memory.c                    |  107 +++-
>  mm/memory_hotplug.c            |   10 +-
>  mm/migrate.c                   |  928 ++++++++++++++++++++++++++++-
>  mm/mprotect.c                  |   14 +
>  mm/page_vma_mapped.c           |   10 +
>  mm/rmap.c                      |   25 +
>  mm/swap.c                      |   11 +
>  mm/zsmalloc.c                  |    8 +
>  36 files changed, 3964 insertions(+), 120 deletions(-)
>  create mode 100644 Documentation/vm/hmm.txt
>  create mode 100644 include/linux/hmm.h
>  create mode 100644 mm/hmm.c
>
> --
> 2.13.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--001a113d68c80fd105056037a8fd
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>it mention that HMM provided two functions:</div><div=
><br></div><div>1. one is mirror the page table between CPU and a device(li=
ke GPU, FPGA), so i am confused that: =C2=A0duplicating the CPU page table =
into a device page table means</div><div><br></div><div>that copy the CPU p=
age table entry into device page table? so the device can access the CPU&#3=
9;s virtual address? and that device can access the the CPU</div><div><br><=
/div><div>allocated physical memory which map into this VMA, right?</div><d=
iv><br></div><div><br></div><div>for example: =C2=A0VMA -&gt; PA (CPU physi=
cal address)</div><div><br></div><div>mirror: fill the the PTE entry of thi=
s VMA into GPU&#39;s =C2=A0page table</div><div><br></div><div>so:</div><di=
v><br></div><div>For CPU&#39;s view: it can access the PA</div><div><br></d=
iv><div>For GPU&#39;s view: it can access the CPU&#39;s VMA and PA</div><di=
v><br></div><div>right?</div><div><br></div><div><br></div><div>2. other fu=
nction is migrate CPU memory to device memory, what is the application scen=
ario ?</div><div><br></div><div>some input data created by GPU and migrate =
back to CPU memory? use for CPU to access GPU&#39;s data?</div><div><br></d=
iv><div>3. function one is help the GPU to access CPU&#39;s VMA and =C2=A0C=
PU&#39;s physical memory, if CPU want to access GPU&#39;s memory, still nee=
d to</div><div><br></div><div>specification device driver API like IOCTL+mm=
ap+DMA?</div><div><br></div><div>4. is it any example? i remember it has a =
dummy driver in older patchset version. i canot find in this version.=C2=A0=
</div></div><div class=3D"gmail_extra"><br><div class=3D"gmail_quote">2017-=
08-17 8:05 GMT+08:00 J=C3=A9r=C3=B4me Glisse <span dir=3D"ltr">&lt;<a href=
=3D"mailto:jglisse@redhat.com" target=3D"_blank">jglisse@redhat.com</a>&gt;=
</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;bo=
rder-left:1px #ccc solid;padding-left:1ex">Patchset is on top of git://<a h=
ref=3D"http://git.cmpxchg.org/linux-mmotm.git" rel=3D"noreferrer" target=3D=
"_blank">git.cmpxchg.org/linux-<wbr>mmotm.git</a> so i<br>
test same kernel as kbuild system, git branch:<br>
<br>
<a href=3D"https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-v25" rel=
=3D"noreferrer" target=3D"_blank">https://cgit.freedesktop.org/~<wbr>glisse=
/linux/log/?h=3Dhmm-v25</a><br>
<br>
Change since v24 are:<br>
=C2=A0 - more comments and more documentations<br>
=C2=A0 - fix dumb mistake when registering device<br>
=C2=A0 - fix race when multiple concurrent device fault<br>
=C2=A0 - merge HMM-CDM patchset with HMM patchset to avoid unecessary code<=
br>
=C2=A0 =C2=A0 churn<br>
<br>
The overall logic is the same. Below is the long description of what HMM<br=
>
is about and why. At the end of this email i describe briefly each patch<br=
>
and suggest reviewers for each of them.<br>
<br>
Please consider this patchset for 4.14<br>
<br>
<br>
Heterogeneous Memory Management (HMM) (description and justification)<br>
<br>
Today device driver expose dedicated memory allocation API through their<br=
>
device file, often relying on a combination of IOCTL and mmap calls. The<br=
>
device can only access and use memory allocated through this API. This<br>
effectively split the program address space into object allocated for the<b=
r>
device and useable by the device and other regular memory (malloc, mmap<br>
of a file, share memory, =C3=A2) only accessible by CPU (or in a very limit=
ed<br>
way by a device by pinning memory).<br>
<br>
Allowing different isolated component of a program to use a device thus<br>
require duplication of the input data structure using device memory<br>
allocator. This is reasonable for simple data structure (array, grid,<br>
image, =C3=A2) but this get extremely complex with advance data structure<b=
r>
(list, tree, graph, =C3=A2) that rely on a web of memory pointers. This is<=
br>
becoming a serious limitation on the kind of work load that can be<br>
offloaded to device like GPU.<br>
<br>
New industry standard like C++, OpenCL or CUDA are pushing to remove this<b=
r>
barrier. This require a shared address space between GPU device and CPU so<=
br>
that GPU can access any memory of a process (while still obeying memory<br>
protection like read only). This kind of feature is also appearing in<br>
various other operating systems.<br>
<br>
HMM is a set of helpers to facilitate several aspects of address space<br>
sharing and device memory management. Unlike existing sharing mechanism<br>
that rely on pining pages use by a device, HMM relies on mmu_notifier to<br=
>
propagate CPU page table update to device page table.<br>
<br>
Duplicating CPU page table is only one aspect necessary for efficiently<br>
using device like GPU. GPU local memory have bandwidth in the TeraBytes/<br=
>
second range but they are connected to main memory through a system bus<br>
like PCIE that is limited to 32GigaBytes/second (PCIE 4.0 16x). Thus it<br>
is necessary to allow migration of process memory from main system memory<b=
r>
to device memory. Issue is that on platform that only have PCIE the device<=
br>
memory is not accessible by the CPU with the same properties as main<br>
memory (cache coherency, atomic operations, ...).<br>
<br>
To allow migration from main memory to device memory HMM provides a set<br>
of helper to hotplug device memory as a new type of ZONE_DEVICE memory<br>
which is un-addressable by CPU but still has struct page representing it.<b=
r>
This allow most of the core kernel logic that deals with a process memory<b=
r>
to stay oblivious of the peculiarity of device memory.<br>
<br>
When page backing an address of a process is migrated to device memory<br>
the CPU page table entry is set to a new specific swap entry. CPU access<br=
>
to such address triggers a migration back to system memory, just like if<br=
>
the page was swap on disk. HMM also blocks any one from pinning a<br>
ZONE_DEVICE page so that it can always be migrated back to system memory<br=
>
if CPU access it. Conversely HMM does not migrate to device memory any<br>
page that is pin in system memory.<br>
<br>
To allow efficient migration between device memory and main memory a new<br=
>
migrate_vma() helpers is added with this patchset. It allows to leverage<br=
>
device DMA engine to perform the copy operation.<br>
<br>
This feature will be use by upstream driver like nouveau mlx5 and probably<=
br>
other in the future (amdgpu is next suspect in line). We are actively<br>
working on nouveau and mlx5 support. To test this patchset we also worked<b=
r>
with NVidia close source driver team, they have more resources than us to<b=
r>
test this kind of infrastructure and also a bigger and better userspace<br>
eco-system with various real industry workload they can be use to test and<=
br>
profile HMM.<br>
<br>
The expected workload is a program builds a data set on the CPU (from disk,=
<br>
from network, from sensors, =C3=A2). Program uses GPU API (OpenCL, CUDA, ..=
.)<br>
to give hint on memory placement for the input data and also for the output=
<br>
buffer. Program call GPU API to schedule a GPU job, this happens using<br>
device driver specific ioctl. All this is hidden from programmer point of<b=
r>
view in case of C++ compiler that transparently offload some part of a<br>
program to GPU. Program can keep doing other stuff on the CPU while the<br>
GPU is crunching numbers.<br>
<br>
It is expected that CPU will not access the same data set as the GPU while<=
br>
GPU is working on it, but this is not mandatory. In fact we expect some<br>
small memory object to be actively access by both GPU and CPU concurrently<=
br>
as synchronization channel and/or for monitoring purposes. Such object will=
<br>
stay in system memory and should not be bottlenecked by system bus<br>
bandwidth (rare write and read access from both CPU and GPU).<br>
<br>
As we are relying on device driver API, HMM does not introduce any new<br>
syscall nor does it modify any existing ones. It does not change any POSIX<=
br>
semantics or behaviors. For instance the child after a fork of a process<br=
>
that is using HMM will not be impacted in anyway, nor is there any data<br>
hazard between child COW or parent COW of memory that was migrated to<br>
device prior to fork.<br>
<br>
HMM assume a numbers of hardware features. Device must allow device page<br=
>
table to be updated at any time (ie device job must be preemptable). Device=
<br>
page table must provides memory protection such as read only. Device must<b=
r>
track write access (dirty bit). Device must have a minimum granularity that=
<br>
match PAGE_SIZE (ie 4k).<br>
<br>
<br>
Reviewer (just hint):<br>
Patch 1=C2=A0 HMM documentation<br>
Patch 2=C2=A0 introduce core infrastructure and definition of HMM, pretty<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0small patch and easy to review<br>
Patch 3=C2=A0 introduce the mirror functionality of HMM, it relies on<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mmu_notifier and thus someone familiar wi=
th that part would be<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0in better position to review<br>
Patch 4=C2=A0 is an helper to snapshot CPU page table while synchronizing w=
ith<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0concurrent page table update. Understandi=
ng mmu_notifier makes<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0review easier.<br>
Patch 5=C2=A0 is mostly a wrapper around handle_mm_fault()<br>
Patch 6=C2=A0 add new add_pages() helper to avoid modifying each arch memor=
y<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hot plug function<br>
Patch 7=C2=A0 add a new memory type for ZONE_DEVICE and also add all the lo=
gic<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0in various core mm to support this new ty=
pe. Dan Williams and<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0any core mm contributor are best people t=
o review each half of<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0this patchset<br>
Patch 8=C2=A0 special case HMM ZONE_DEVICE pages inside put_page() Kirill a=
nd<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Dan Williams are best person to review th=
is<br>
Patch 9=C2=A0 allow to uncharge a page from memory group without using the =
lru<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0list field of struct page (best reviewer:=
 Johannes Weiner or<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Vladimir Davydov or Michal Hocko)<br>
Patch 10 Add support to uncharge ZONE_DEVICE page from a memory cgroup (bes=
t<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0reviewer: Johannes Weiner or Vladimir Dav=
ydov or Michal Hocko)<br>
Patch 11 add helper to hotplug un-addressable device memory as new type<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0of ZONE_DEVICE memory (new type introduct=
ed in patch 3 of this<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0serie). This is boiler plate code around =
memory hotplug and it<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0also pick a free range of physical addres=
s for the device memory.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Note that the physical address do not poi=
nt to anything (at least<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0as far as the kernel knows).<br>
Patch 12 introduce a new hmm_device class as an helper for device driver<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0that want to expose multiple device memor=
y under a common fake<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0device driver. This is usefull for multi-=
gpu configuration.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Anyone familiar with device driver infras=
tructure can review<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0this. Boiler plate code really.<br>
Patch 13 add a new migrate mode. Any one familiar with page migration is<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0welcome to review.<br>
Patch 14 introduce a new migration helper (migrate_vma()) that allow to<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0migrate a range of virtual address of a p=
rocess using device DMA<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0engine to perform the copy. It is not lim=
ited to do copy from and<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0to device but can also do copy between an=
y kind of source and<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0destination memory. Again anyone familiar=
 with migration code<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0should be able to verify the logic.<br>
Patch 15 optimize the new migrate_vma() by unmapping pages while we are<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0collecting them. This can be review by an=
y mm folks.<br>
Patch 16 add unaddressable memory migration to helper introduced in patch<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A07, this can be review by anyone familiar =
with migration code<br>
Patch 17 add a feature that allow device to allocate non-present page on<br=
>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0the GPU when migrating a range of address=
 to device memory. This<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0is an helper for device driver to avoid h=
aving to first allocate<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0system memory before migration to device =
memory<br>
Patch 18 add a new kind of ZONE_DEVICE memory for cache coherent device<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0memory (CDM)<br>
Patch 19 add an helper to hotplug CDM memory<br>
<br>
<br>
Previous patchset posting :<br>
v1 <a href=3D"http://lwn.net/Articles/597289/" rel=3D"noreferrer" target=3D=
"_blank">http://lwn.net/Articles/<wbr>597289/</a><br>
v2 <a href=3D"https://lkml.org/lkml/2014/6/12/559" rel=3D"noreferrer" targe=
t=3D"_blank">https://lkml.org/lkml/2014/6/<wbr>12/559</a><br>
v3 <a href=3D"https://lkml.org/lkml/2014/6/13/633" rel=3D"noreferrer" targe=
t=3D"_blank">https://lkml.org/lkml/2014/6/<wbr>13/633</a><br>
v4 <a href=3D"https://lkml.org/lkml/2014/8/29/423" rel=3D"noreferrer" targe=
t=3D"_blank">https://lkml.org/lkml/2014/8/<wbr>29/423</a><br>
v5 <a href=3D"https://lkml.org/lkml/2014/11/3/759" rel=3D"noreferrer" targe=
t=3D"_blank">https://lkml.org/lkml/2014/11/<wbr>3/759</a><br>
v6 <a href=3D"http://lwn.net/Articles/619737/" rel=3D"noreferrer" target=3D=
"_blank">http://lwn.net/Articles/<wbr>619737/</a><br>
v7 <a href=3D"http://lwn.net/Articles/627316/" rel=3D"noreferrer" target=3D=
"_blank">http://lwn.net/Articles/<wbr>627316/</a><br>
v8 <a href=3D"https://lwn.net/Articles/645515/" rel=3D"noreferrer" target=
=3D"_blank">https://lwn.net/Articles/<wbr>645515/</a><br>
v9 <a href=3D"https://lwn.net/Articles/651553/" rel=3D"noreferrer" target=
=3D"_blank">https://lwn.net/Articles/<wbr>651553/</a><br>
v10 <a href=3D"https://lwn.net/Articles/654430/" rel=3D"noreferrer" target=
=3D"_blank">https://lwn.net/Articles/<wbr>654430/</a><br>
v11 <a href=3D"http://www.gossamer-threads.com/lists/linux/kernel/2286424" =
rel=3D"noreferrer" target=3D"_blank">http://www.gossamer-threads.<wbr>com/l=
ists/linux/kernel/2286424</a><br>
v12 <a href=3D"http://www.kernelhub.org/?msg=3D972982&amp;p=3D2" rel=3D"nor=
eferrer" target=3D"_blank">http://www.kernelhub.org/?msg=3D<wbr>972982&amp;=
p=3D2</a><br>
v13 <a href=3D"https://lwn.net/Articles/706856/" rel=3D"noreferrer" target=
=3D"_blank">https://lwn.net/Articles/<wbr>706856/</a><br>
v14 <a href=3D"https://lkml.org/lkml/2016/12/8/344" rel=3D"noreferrer" targ=
et=3D"_blank">https://lkml.org/lkml/2016/12/<wbr>8/344</a><br>
v15 <a href=3D"http://www.mail-archive.com/linux-kernel@xxxxxxxxxxxxxxx/msg=
1304107.html" rel=3D"noreferrer" target=3D"_blank">http://www.mail-archive.=
com/<wbr>linux-kernel@xxxxxxxxxxxxxxx/<wbr>msg1304107.html</a><br>
v16 <a href=3D"http://www.spinics.net/lists/linux-mm/msg119814.html" rel=3D=
"noreferrer" target=3D"_blank">http://www.spinics.net/lists/<wbr>linux-mm/m=
sg119814.html</a><br>
v17 <a href=3D"https://lkml.org/lkml/2017/1/27/847
v18" rel=3D"noreferrer" target=3D"_blank">https://lkml.org/lkml/2017/1/<wbr=
>27/847<br>
v18</a> <a href=3D"https://lkml.org/lkml/2017/3/16/596" rel=3D"noreferrer" =
target=3D"_blank">https://lkml.org/lkml/2017/3/<wbr>16/596</a><br>
v19 <a href=3D"https://lkml.org/lkml/2017/4/5/831" rel=3D"noreferrer" targe=
t=3D"_blank">https://lkml.org/lkml/2017/4/<wbr>5/831</a><br>
v20 <a href=3D"https://lwn.net/Articles/720715/" rel=3D"noreferrer" target=
=3D"_blank">https://lwn.net/Articles/<wbr>720715/</a><br>
v21 <a href=3D"https://lkml.org/lkml/2017/4/24/747" rel=3D"noreferrer" targ=
et=3D"_blank">https://lkml.org/lkml/2017/4/<wbr>24/747</a><br>
v22 <a href=3D"http://lkml.iu.edu/hypermail/linux/kernel/1705.2/05176.html"=
 rel=3D"noreferrer" target=3D"_blank">http://lkml.iu.edu/hypermail/<wbr>lin=
ux/kernel/1705.2/05176.html</a><br>
v23 <a href=3D"https://www.mail-archive.com/linux-kernel@vger.kernel.org/ms=
g1404788.html" rel=3D"noreferrer" target=3D"_blank">https://www.mail-archiv=
e.com/<wbr>linux-kernel@vger.kernel.org/<wbr>msg1404788.html</a><br>
v24 <a href=3D"https://lwn.net/Articles/726691/" rel=3D"noreferrer" target=
=3D"_blank">https://lwn.net/Articles/<wbr>726691/</a><br>
<br>
J=C3=A9r=C3=B4me Glisse (18):<br>
=C2=A0 hmm: heterogeneous memory management documentation v3<br>
=C2=A0 mm/hmm: heterogeneous memory management (HMM for short) v5<br>
=C2=A0 mm/hmm/mirror: mirror process address space on device with HMM helpe=
rs<br>
=C2=A0 =C2=A0 v3<br>
=C2=A0 mm/hmm/mirror: helper to snapshot CPU page table v4<br>
=C2=A0 mm/hmm/mirror: device page fault handler<br>
=C2=A0 mm/ZONE_DEVICE: new type of ZONE_DEVICE for unaddressable memory v5<=
br>
=C2=A0 mm/ZONE_DEVICE: special case put_page() for device private pages v4<=
br>
=C2=A0 mm/memcontrol: allow to uncharge page without using page-&gt;lru fie=
ld<br>
=C2=A0 mm/memcontrol: support MEMORY_DEVICE_PRIVATE v4<br>
=C2=A0 mm/hmm/devmem: device memory hotplug using ZONE_DEVICE v7<br>
=C2=A0 mm/hmm/devmem: dummy HMM device for ZONE_DEVICE memory v3<br>
=C2=A0 mm/migrate: new migrate mode MIGRATE_SYNC_NO_COPY<br>
=C2=A0 mm/migrate: new memory migration helper for use with device memory v=
5<br>
=C2=A0 mm/migrate: migrate_vma() unmap page from vma while collecting pages=
<br>
=C2=A0 mm/migrate: support un-addressable ZONE_DEVICE page in migration v3<=
br>
=C2=A0 mm/migrate: allow migrate_vma() to alloc new page on empty entry v4<=
br>
=C2=A0 mm/device-public-memory: device memory cache coherent with CPU v5<br=
>
=C2=A0 mm/hmm: add new helper to hotplug CDM memory region v3<br>
<br>
Michal Hocko (1):<br>
=C2=A0 mm/memory_hotplug: introduce add_pages<br>
<br>
=C2=A0Documentation/vm/hmm.txt=C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 384 ++++++=
++++++<br>
=C2=A0MAINTAINERS=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A0 7 +<br>
=C2=A0arch/x86/Kconfig=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0|=C2=A0 =C2=A0 4 +<br>
=C2=A0arch/x86/mm/init_64.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=
=A022 +-<br>
=C2=A0fs/aio.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 8 +<br>
=C2=A0fs/f2fs/data.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0|=C2=A0 =C2=A0 5 +-<br>
=C2=A0fs/hugetlbfs/inode.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =
=C2=A0 5 +-<br>
=C2=A0fs/proc/task_mmu.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
=C2=A0 =C2=A0 9 +-<br>
=C2=A0fs/ubifs/file.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 |=C2=A0 =C2=A0 5 +-<br>
=C2=A0include/linux/hmm.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =
518 ++++++++++++++++<br>
=C2=A0include/linux/ioport.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=
=A0 2 +<br>
=C2=A0include/linux/memory_hotplug.h |=C2=A0 =C2=A011 +<br>
=C2=A0include/linux/memremap.h=C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 107 ++++<b=
r>
=C2=A0include/linux/migrate.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 124 ++++<b=
r>
=C2=A0include/linux/migrate_mode.h=C2=A0 =C2=A0|=C2=A0 =C2=A0 5 +<br>
=C2=A0include/linux/mm.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=
=C2=A0 =C2=A033 +-<br>
=C2=A0include/linux/mm_types.h=C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 6 +=
<br>
=C2=A0include/linux/swap.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =
=C2=A024 +-<br>
=C2=A0include/linux/swapops.h=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A068 +=
++<br>
=C2=A0kernel/fork.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 |=C2=A0 =C2=A0 3 +<br>
=C2=A0kernel/memremap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=
=C2=A0 =C2=A060 +-<br>
=C2=A0mm/Kconfig=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A047 +-<br>
=C2=A0mm/Makefile=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 =C2=A0 2 +-<br>
=C2=A0mm/balloon_compaction.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A0 8 +=
<br>
=C2=A0mm/gup.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =C2=A0 7 +<br>
=C2=A0mm/hmm.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0| 1273 ++++++++++++++++++++++++++++++<wbr>+++++++++=
+<br>
=C2=A0mm/madvise.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 =C2=A0 2 +-<br>
=C2=A0mm/memcontrol.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 |=C2=A0 222 ++++---<br>
=C2=A0mm/memory.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 |=C2=A0 107 +++-<br>
=C2=A0mm/memory_hotplug.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 |=C2=A0 =
=C2=A010 +-<br>
=C2=A0mm/migrate.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0|=C2=A0 928 ++++++++++++++++++++++++++++-<br>
=C2=A0mm/mprotect.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 |=C2=A0 =C2=A014 +<br>
=C2=A0mm/page_vma_mapped.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0|=C2=A0 =
=C2=A010 +<br>
=C2=A0mm/rmap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A025 +<br>
=C2=A0mm/swap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 |=C2=A0 =C2=A011 +<br>
=C2=A0mm/zsmalloc.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 |=C2=A0 =C2=A0 8 +<br>
=C2=A036 files changed, 3964 insertions(+), 120 deletions(-)<br>
=C2=A0create mode 100644 Documentation/vm/hmm.txt<br>
=C2=A0create mode 100644 include/linux/hmm.h<br>
=C2=A0create mode 100644 mm/hmm.c<br>
<span class=3D"HOEnZb"><font color=3D"#888888"><br>
--<br>
2.13.4<br>
<br>
--<br>
To unsubscribe, send a message with &#39;unsubscribe linux-mm&#39; in<br>
the body to <a href=3D"mailto:majordomo@kvack.org">majordomo@kvack.org</a>.=
=C2=A0 For more info on Linux MM,<br>
see: <a href=3D"http://www.linux-mm.org/" rel=3D"noreferrer" target=3D"_bla=
nk">http://www.linux-mm.org/</a> .<br>
Don&#39;t email: &lt;a href=3Dmailto:&quot;<a href=3D"mailto:dont@kvack.org=
">dont@kvack.org</a>&quot;&gt; <a href=3D"mailto:email@kvack.org">email@kva=
ck.org</a> &lt;/a&gt;<br>
</font></span></blockquote></div><br></div>

--001a113d68c80fd105056037a8fd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
