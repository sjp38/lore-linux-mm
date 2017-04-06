Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 220946B03DF
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 23:22:14 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l68so2316765oib.19
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 20:22:14 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id p131si132704oif.176.2017.04.05.20.22.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 20:22:13 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id r203so37698846oib.3
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 20:22:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170405204026.3940-1-jglisse@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
From: "Figo.zhang" <figo1802@gmail.com>
Date: Thu, 6 Apr 2017 11:22:12 +0800
Message-ID: <CAF7GXvptCfV89rAi=j1cy1df12039GDpq_DHOyx+_xk0FjBDPg@mail.gmail.com>
Subject: Re: [HMM 00/16] HMM (Heterogeneous Memory Management) v19
Content-Type: multipart/alternative; boundary=001a113d4feed6a7c3054c77038c
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>

--001a113d4feed6a7c3054c77038c
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

>
>
>
>
> Heterogeneous Memory Management (HMM) (description and justification)
>
> Today device driver expose dedicated memory allocation API through their
> device file, often relying on a combination of IOCTL and mmap calls. The
> device can only access and use memory allocated through this API. This
> effectively split the program address space into object allocated for the
> device and useable by the device and other regular memory (malloc, mmap
> of a file, share memory, =E2=80=A6) only accessible by CPU (or in a very =
limited
> way by a device by pinning memory).
>
> Allowing different isolated component of a program to use a device thus
> require duplication of the input data structure using device memory
> allocator. This is reasonable for simple data structure (array, grid,
> image, =E2=80=A6) but this get extremely complex with advance data struct=
ure
> (list, tree, graph, =E2=80=A6) that rely on a web of memory pointers. Thi=
s is
> becoming a serious limitation on the kind of work load that can be
> offloaded to device like GPU.
>

how handle it by current  GPU software stack? maintain a complex middle
firmwork/HAL?


>
> New industry standard like C++, OpenCL or CUDA are pushing to remove this
> barrier. This require a shared address space between GPU device and CPU s=
o
> that GPU can access any memory of a process (while still obeying memory
> protection like read only).


GPU can access the whole process VMAs or any VMAs which backing system
memory has migrate to GPU page table?



> This kind of feature is also appearing in
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
> memory (cache coherency, atomic operations, =E2=80=A6).
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

the purpose of  migrate the system pages to device is that device can read
the system memory?
if the CPU/programs want read the device data, it need pin/mapping the
device memory to the process address space?
if multiple applications want to read the same device memory region
concurrently, how to do it?

it is better a graph to show how CPU and GPU share the address space.


>
> To allow efficient migration between device memory and main memory a new
> migrate_vma() helpers is added with this patchset. It allows to leverage
> device DMA engine to perform the copy operation.
>
> This feature will be use by upstream driver like nouveau mlx5 and probabl=
y
> other in the future (amdgpu is next suspect  in line). We are actively
> working on nouveau and mlx5 support. To test this patchset we also worked
> with NVidia close source driver team, they have more resources than us to
> test this kind of infrastructure and also a bigger and better userspace
> eco-system with various real industry workload they can be use to test an=
d
> profile HMM.
>
> The expected workload is a program builds a data set on the CPU (from dis=
k,
> from network, from sensors, =E2=80=A6). Program uses GPU API (OpenCL, CUD=
A, ...)
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
>
>

--001a113d4feed6a7c3054c77038c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #c=
cc solid;padding-left:1ex"><br><br>
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
of a file, share memory, =E2=80=A6) only accessible by CPU (or in a very li=
mited<br>
way by a device by pinning memory).<br>
<br>
Allowing different isolated component of a program to use a device thus<br>
require duplication of the input data structure using device memory<br>
allocator. This is reasonable for simple data structure (array, grid,<br>
image, =E2=80=A6) but this get extremely complex with advance data structur=
e<br>
(list, tree, graph, =E2=80=A6) that rely on a web of memory pointers. This =
is<br>
becoming a serious limitation on the kind of work load that can be<br>
offloaded to device like GPU.<br></blockquote><div><br></div><div>how handl=
e it by current =C2=A0GPU software stack? maintain a complex middle firmwor=
k/HAL?</div><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"mar=
gin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
<br>
New industry standard like C++, OpenCL or CUDA are pushing to remove this<b=
r>
barrier. This require a shared address space between GPU device and CPU so<=
br>
that GPU can access any memory of a process (while still obeying memory<br>
protection like read only). </blockquote><div><br></div><div>GPU can access=
 the whole process VMAs or any VMAs which backing system memory has migrate=
 to GPU page table?</div><div><br></div><div>=C2=A0</div><blockquote class=
=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padd=
ing-left:1ex">This kind of feature is also appearing in<br>
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
memory (cache coherency, atomic operations, =E2=80=A6).<br>
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
page that is pin in system memory.<br></blockquote><div><br></div><div>the =
purpose of =C2=A0migrate the system pages to device is that device can read=
 the system memory?</div><div>if the CPU/programs=C2=A0want read the device=
 data, it need pin/mapping=C2=A0the device memory to the process address sp=
ace?</div><div>if multiple applications=C2=A0want to read the same device m=
emory region concurrently, how to do it?</div><div><br></div><div>it is bet=
ter a graph to show how CPU and GPU share the address space.</div><div>=C2=
=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;borde=
r-left:1px #ccc solid;padding-left:1ex">
<br>
To allow efficient migration between device memory and main memory a new<br=
>
migrate_vma() helpers is added with this patchset. It allows to leverage<br=
>
device DMA engine to perform the copy operation.<br>
<br>
This feature will be use by upstream driver like nouveau mlx5 and probably<=
br>
other in the future (amdgpu is next suspect=C2=A0 in line). We are actively=
<br>
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
from network, from sensors, =E2=80=A6). Program uses GPU API (OpenCL, CUDA,=
 ...)<br>
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
<br><span class=3D"HOEnZb"><font color=3D"#888888"><br>
</font></span></blockquote></div><br></div></div>

--001a113d4feed6a7c3054c77038c--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
