Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 160E16B0069
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 22:16:14 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id t18so2011465oie.5
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:16:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t31si1053403otb.390.2017.12.13.19.16.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 19:16:13 -0800 (PST)
Date: Wed, 13 Dec 2017 22:16:08 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Message-ID: <20171214031607.GA17710@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <CAF7GXvqSZzNHdefQWhEb2SDYWX5hDWqQX7cayuVEQ8YyTULPog@mail.gmail.com>
 <20171213161247.GA2927@redhat.com>
 <CAF7GXvrxo2xj==wA_=fXr+9nF0k0Ed123kZXeKWKBHS6TKYNdA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAF7GXvrxo2xj==wA_=fXr+9nF0k0Ed123kZXeKWKBHS6TKYNdA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

On Thu, Dec 14, 2017 at 10:48:36AM +0800, Figo.zhang wrote:
> 2017-12-14 0:12 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:
> 
> > On Wed, Dec 13, 2017 at 08:10:42PM +0800, Figo.zhang wrote:

[...]

> > Basic example is without HMM:
> >     mul_mat_on_gpu(float *r, float *a, float *b, unsigned m)
> >     {
> >         gpu_buffer_t gpu_r, gpu_a, gpu_b;
> >
> >         gpu_r = gpu_alloc(m*m*sizeof(float));
> >         gpu_a = gpu_alloc(m*m*sizeof(float));
> >         gpu_b = gpu_alloc(m*m*sizeof(float));
> >         gpu_copy_to(gpu_a, a, m*m*sizeof(float));
> >         gpu_copy_to(gpu_b, b, m*m*sizeof(float));
> >
> >         gpu_mul_mat(gpu_r, gpu_a, gpu_b, m);
> >
> >         gpu_copy_from(gpu_r, r, m*m*sizeof(float));
> >     }
> >
> 
> The traditional workflow is:
> 1. the pointer a, b and r are total point to the CPU memory
> 2. create/alloc three GPU buffers: gpu_a, gpu_b, gpu_r
> 3. copy CPU memory a and b to GPU memory gpu_b and gpu_b
> 4. let the GPU to do the calculation
> 5.  copy the result from GPU buffer (gpu_r) to CPU buffer (r)
> 
> is it right?

Right.


> > With HMM:
> >     mul_mat_on_gpu(float *r, float *a, float *b, unsigned m)
> >     {
> >         gpu_mul_mat(r, a, b, m);
> >     }
> >
> 
> with HMM workflow:
> 1. CPU has three buffer: a, b, r, and it is physical addr is : pa, pb, pr
>      and GPU has tree physical buffer: gpu_a, gpu_b, gpu_r
> 2. GPU want to access buffer a and b, cause a GPU page fault
> 3. GPU report a page fault to CPU
> 4. CPU got a GPU page fault:
>                 * unmap the buffer a,b,r (who do it? GPU driver?)
>                 * copy the buffer a ,b's content to GPU physical buffers:
> gpu_a, gpu_b
>                 * fill the GPU page table entry with these pages (gpu_a,
> gpu_b, gpu_r) of the CPU virtual address: a,b,r;
> 
> 5. GPU do the calculation
> 6. CPU want to get result from buffer r and will cause a CPU page fault:
> 7. in CPU page fault:
>              * unmap the GPU page table entry for virtual address a,b,r.
> (who do the unmap? GPU driver?)
>              * copy the GPU's buffer content (gpu_a, gpu_b, gpu_r) to
> CPU buffer (abr)
>              * fill the CPU page table entry: virtual_addr -> buffer
> (pa,pb,pr)
> 8. so the CPU can get the result form buffer r.
> 
> my guess workflow is right?
> it seems need two copy, from CPU to GPU, and then GPU to CPU for result.
> * is it CPU and GPU have the  page table concurrently, so
> no page fault occur?
> * how about the performance? it sounds will create lots of page fault.

This is not what happen. Here is the workflow with HMM mirror (note that
physical address do not matter here so i do not even reference them it is
all about virtual address):
 1 They are 3 buffers a, b and r at given virtual address both CPU and
   GPU can access them (concurently or not this does not matter).
 2 GPU can fault so if any virtual address do not have a page table
   entry inside the GPU page table this trigger a page fault that will
   call HMM mirror helper to snapshot CPU page table into the GPU page
   table. If there is no physical memory backing the virtual address
   (ie CPU page table is also empty for the given virtual address) then 
   the regular page fault handler of the kernel is invoked.

Without HMM mirror but ATS/PASI (CCIX or CAPI):
 1 They are 3 buffers a, b and r at given virtual address both CPU and
   GPU can access them (concurently or not this does not matter).
 2 GPU use the exact same page table as the CPU and fault exactly like
   CPU on empty page table entry

So in the end with HMM mirror or ATS/PASID you get the same behavior.
There is no complexity like you seem to assume. This all about virtual
address. At any point in time any given valid virtual address of a process
point to a given physical memory address and that physical memory address
is the same on both the CPU and the GPU at any point in time they are
never out of sync (both in HMM mirror and in ATS/PASID case).

The exception is for platform that do not have CAPI or CCIX property ie
cache coherency for CPU access to device memory. On such platform when
you migrate a virtual address to use device physical memory you update
the CPU page table with a special entry. If the CPU try to access the
virtual address with special entry it trigger fault and HMM will migrate
the virtual address back to regular memory. But this does not apply for
CAPI or CCIX platform.


Too minimize page fault the device driver is encourage to pre-fault and
prepopulate its page table (the HMM mirror case). Often device driver has
enough context information to guess what range of virtual address is
about to be access by the device and thus pre-fault thing.


Hope this clarify thing for you.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
