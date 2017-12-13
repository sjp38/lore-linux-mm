Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 291EE6B0033
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 11:12:53 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id u126so1223370oia.19
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 08:12:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x7si744916oti.73.2017.12.13.08.12.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 08:12:51 -0800 (PST)
Date: Wed, 13 Dec 2017 11:12:48 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Message-ID: <20171213161247.GA2927@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <CAF7GXvqSZzNHdefQWhEb2SDYWX5hDWqQX7cayuVEQ8YyTULPog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAF7GXvqSZzNHdefQWhEb2SDYWX5hDWqQX7cayuVEQ8YyTULPog@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

On Wed, Dec 13, 2017 at 08:10:42PM +0800, Figo.zhang wrote:
> it mention that HMM provided two functions:
> 
> 1. one is mirror the page table between CPU and a device(like GPU, FPGA),
> so i am confused that:  duplicating the CPU page table into a device page
> table means
> 
> that copy the CPU page table entry into device page table? so the device
> can access the CPU's virtual address? and that device can access the the CPU
> allocated physical memory which map into this VMA, right?
>
> for example:  VMA -> PA (CPU physical address)
> 
> mirror: fill the the PTE entry of this VMA into GPU's  page table
> 
> so:
> 
> For CPU's view: it can access the PA
> 
> For GPU's view: it can access the CPU's VMA and PA
> 
> right?

Correct. This is for platform/device without ATS/PASID. Note that
HMM only provide helpers to snapshot the CPU page table and properly
synchronize with concurrent CPU page table update. Most of the code
is really inside the device driver as each device driver has its own
architecture and its own page table format.


> 2. other function is migrate CPU memory to device memory, what is the
> application scenario ?

Second part of HMM is to allow to register "special" struct page
(they are not on the LRU and are associated with a device). Having
struct page allow most of the kernel memory management to be
oblivous to the underlying memory type (regular DDR memort or device
memory).

The migrate helper introduced with HMM is to allow to migrate to
and from device memory using DMA engine and not CPU memcopy. It
is needed because on some platform CPU can not access the device
memory and moreover DMA engine reach higher bandwidth more easily
than CPU memcopy.

Again this is an helper. The policy on what to migrate, when, ...
is outside HMM for now we assume that the device driver is the
best place to have this logic. Maybe in few year once we have more
device driver using that kind of feature we may grow common code
to expose common API to userspace for migration policy.


> some input data created by GPU and migrate back to CPU memory? use for CPU
> to access GPU's data?

It can be use in any number of way. So yes all the scenario you
list do apply. On platform where CPU can not access device memory
you need to migrate back to regular memory for CPU access.

Note that the physical memory use behind a virtual address pointer
is transparent to the application thus you do not need to modify
it in anyway. That is the whole point of HMM.


> 3. function one is help the GPU to access CPU's VMA and  CPU's physical
> memory, if CPU want to access GPU's memory, still need to
> specification device driver API like IOCTL+mmap+DMA?

No you do not need special memory allocator with an HMM capable
device (and device driver). HMM mirror functionality is to allow
any pointer to point to same memory on both a device and CPU for
a given application. This is the Fine-Grained system SVM as
specified in the OpenCL 2.0 specification.

Basic example is without HMM:
    mul_mat_on_gpu(float *r, float *a, float *b, unsigned m)
    {
        gpu_buffer_t gpu_r, gpu_a, gpu_b;

        gpu_r = gpu_alloc(m*m*sizeof(float));
        gpu_a = gpu_alloc(m*m*sizeof(float));
        gpu_b = gpu_alloc(m*m*sizeof(float));
        gpu_copy_to(gpu_a, a, m*m*sizeof(float));
        gpu_copy_to(gpu_b, b, m*m*sizeof(float));

        gpu_mul_mat(gpu_r, gpu_a, gpu_b, m);

        gpu_copy_from(gpu_r, r, m*m*sizeof(float));
    }

With HMM:
    mul_mat_on_gpu(float *r, float *a, float *b, unsigned m)
    {
        gpu_mul_mat(r, a, b, m);
    }

So it is going from a world with device specific allocation
to a model where any regular process memory (outcome of an
mmap to a regular file or for anonymous private memory). can
be access by both CPU and GPU using same pointer.


Now on platform like PCIE where CPU can not access the device
memory in cache coherent way (also with no garanty regarding
CPU atomic operations) you can not have the CPU access the device
memory without breaking memory model expected by the programmer.

Hence if some range of the virtual address space of a process
has been migrated to device memory it must be migrated back to
regular memory.

On platform like CAPI or CCIX you do not need to migrate back
to regular memory on CPU access. HMM provide helpers to handle
both cases.


> 4. is it any example? i remember it has a dummy driver in older patchset
> version. i canot find in this version.

Dummy driver and userspace:
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-next
https://github.com/glisse/hmm-dummy-test-suite

nouveau prototype:
https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-nouveau

I was waiting on rework of nouveau memory management before
working on final implementation of HMM inside nouveau. That
rework is now mostly ready:

https://github.com/skeggsb/nouveau/tree/devel-fault

I intend to start working on final HMM inside nouveau after
the end of year celebration and i hope to have it in some
working state in couple month. At the same time we are working
on an open source userspace to make use of that (probably
an OpenCL runtime first but we are looking into other thing
such as OpenMP, CUDA, ...).

Plans is to upstream all this next year, all the bits are
slowly cooking.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
