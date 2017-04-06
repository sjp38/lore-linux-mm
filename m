Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2743D6B03E1
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 00:59:57 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n80so8995364qke.6
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 21:59:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w124si443207qka.67.2017.04.05.21.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Apr 2017 21:59:55 -0700 (PDT)
Date: Thu, 6 Apr 2017 00:59:50 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 00/16] HMM (Heterogeneous Memory Management) v19
Message-ID: <20170406045950.GA12362@redhat.com>
References: <20170405204026.3940-1-jglisse@redhat.com>
 <CAF7GXvptCfV89rAi=j1cy1df12039GDpq_DHOyx+_xk0FjBDPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAF7GXvptCfV89rAi=j1cy1df12039GDpq_DHOyx+_xk0FjBDPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>

On Thu, Apr 06, 2017 at 11:22:12AM +0800, Figo.zhang wrote:

[...]

> > Heterogeneous Memory Management (HMM) (description and justification)
> >
> > Today device driver expose dedicated memory allocation API through their
> > device file, often relying on a combination of IOCTL and mmap calls. The
> > device can only access and use memory allocated through this API. This
> > effectively split the program address space into object allocated for the
> > device and useable by the device and other regular memory (malloc, mmap
> > of a file, share memory, a?|) only accessible by CPU (or in a very limited
> > way by a device by pinning memory).
> >
> > Allowing different isolated component of a program to use a device thus
> > require duplication of the input data structure using device memory
> > allocator. This is reasonable for simple data structure (array, grid,
> > image, a?|) but this get extremely complex with advance data structure
> > (list, tree, graph, a?|) that rely on a web of memory pointers. This is
> > becoming a serious limitation on the kind of work load that can be
> > offloaded to device like GPU.
> >
> 
> how handle it by current  GPU software stack? maintain a complex middle
> firmwork/HAL?

Yes you still need a framework like OpenCL or CUDA. They are work under
way to leverage GPU directly from language like C++, so i expect that
the HAL will be hidden more and more for a larger group of programmer.
Note i still expect some programmer will want to program closer to the
hardware to extract every bit of performances they can.

For OpenCL you need HMM to implement what is described as fine-grained
system SVM memory model (see OpenCL 2.0 or latter specification).

> > New industry standard like C++, OpenCL or CUDA are pushing to remove this
> > barrier. This require a shared address space between GPU device and CPU so
> > that GPU can access any memory of a process (while still obeying memory
> > protection like read only).
> 
> GPU can access the whole process VMAs or any VMAs which backing system
> memory has migrate to GPU page table?

Whole process VMAs, it does not need to be migrated to device memory. The
migration is an optional features that is necessary for performances but
GPU can access system memory just fine.

[...]

> > When page backing an address of a process is migrated to device memory
> > the CPU page table entry is set to a new specific swap entry. CPU access
> > to such address triggers a migration back to system memory, just like if
> > the page was swap on disk. HMM also blocks any one from pinning a
> > ZONE_DEVICE page so that it can always be migrated back to system memory
> > if CPU access it. Conversely HMM does not migrate to device memory any
> > page that is pin in system memory.
> >
> 
> the purpose of  migrate the system pages to device is that device can read
> the system memory?
> if the CPU/programs want read the device data, it need pin/mapping the
> device memory to the process address space?
> if multiple applications want to read the same device memory region
> concurrently, how to do it?

Purpose of migrating to device memory is to leverage device memory bandwidth.
PCIE bandwidth 32GB/s, device memory bandwidth between 256GB/s to 1TB/s also
device bandwidth has smaller latency.

CPU can not access device memory. It can but in limited way on PCIE and it
would violate memory model programmer get for regular system memory hence
for all intents and purposes it is better to say that CPU can not access
any of the device memory.

Share VMA will just work, so if a VMA is share between 2 process than both
process can access the same memory. All the semantics that are valid on the
CPU are also valid on the GPU. Nothing change there.


> it is better a graph to show how CPU and GPU share the address space.

I am not good at making ASCII graph, nor would i know how to graph this.
Any valid address on the CPU is valid on the GPU, that's it really. The
migration to device memory is orthogonal to the share address space.

Cheers,
JA(C)rA'me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
