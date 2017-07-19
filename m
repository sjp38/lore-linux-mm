Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 71F8C6B02B4
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 07:53:15 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d77so3578024oig.7
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 04:53:15 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id g140si3962950oic.150.2017.07.19.04.53.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 04:53:14 -0700 (PDT)
Subject: Re: [PATCH 00/15] HMM (Heterogeneous Memory Management) v24
References: <20170628180047.5386-1-jglisse@redhat.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <19d4aa0e-a428-ed6d-c524-9b1cdcf6aa30@huawei.com>
Date: Wed, 19 Jul 2017 19:48:08 +0800
MIME-Version: 1.0
In-Reply-To: <20170628180047.5386-1-jglisse@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>

Hi JA(C)rA'me

On 2017/6/29 2:00, JA(C)rA'me Glisse wrote:
> 
> Patchset is on top of git://git.cmpxchg.org/linux-mmotm.git so i
> test same kernel as kbuild system, git branch:
> 
> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v24
> 
> Change since v23 is code comment fixes, simplify kernel configuration and
> improve allocation of new page on migration do device memory (last patch
> in this patchset).
> 
> Everything else is the same. Below is the long description of what HMM
> is about and why. At the end of this email i describe briefly each patch
> and suggest reviewers for each of them.
> 
> 
> Heterogeneous Memory Management (HMM) (description and justification)
> 
> Today device driver expose dedicated memory allocation API through their
> device file, often relying on a combination of IOCTL and mmap calls. The
> device can only access and use memory allocated through this API. This
> effectively split the program address space into object allocated for the
> device and useable by the device and other regular memory (malloc, mmap
> of a file, share memory, Ac) only accessible by CPU (or in a very limited
> way by a device by pinning memory).
> 
> Allowing different isolated component of a program to use a device thus
> require duplication of the input data structure using device memory
> allocator. This is reasonable for simple data structure (array, grid,
> image, Ac) but this get extremely complex with advance data structure
> (list, tree, graph, Ac) that rely on a web of memory pointers. This is
> becoming a serious limitation on the kind of work load that can be
> offloaded to device like GPU.
> 
> New industry standard like C++, OpenCL or CUDA are pushing to remove this
> barrier. This require a shared address space between GPU device and CPU so
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
> to device memory. Issue is that on platform that only have PCIE the device
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
> the page was swap on disk. 
> [...]
> To allow efficient migration between device memory and main memory a new
> migrate_vma() helpers is added with this patchset. It allows to leverage
> device DMA engine to perform the copy operation.
> 

Is this means that when CPU access an address of a process is migrated to device
memory, it should call migrate_vma() to migrate a range of address back to CPU ?
If it is so, I think it should somewhere call this function in this patchset,
however, I do not find anywhere in this patchset call this function.

Or am I miss anything?

Thanks
Yisheng Xie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
