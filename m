Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id F3C676B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 23:16:57 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id f28so2391771otd.12
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 20:16:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e124si1005543oib.324.2017.12.13.20.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 20:16:56 -0800 (PST)
Date: Wed, 13 Dec 2017 23:16:51 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Message-ID: <20171214041650.GB17710@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <CAF7GXvqSZzNHdefQWhEb2SDYWX5hDWqQX7cayuVEQ8YyTULPog@mail.gmail.com>
 <20171213161247.GA2927@redhat.com>
 <CAF7GXvrxo2xj==wA_=fXr+9nF0k0Ed123kZXeKWKBHS6TKYNdA@mail.gmail.com>
 <20171214031607.GA17710@redhat.com>
 <CAF7GXvqoYXDJNYcrzJo5bGvfBG9iFq8PbeA7RO7y+9DuM7N0og@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAF7GXvqoYXDJNYcrzJo5bGvfBG9iFq8PbeA7RO7y+9DuM7N0og@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

On Thu, Dec 14, 2017 at 11:53:40AM +0800, Figo.zhang wrote:
> 2017-12-14 11:16 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:
> 
> > On Thu, Dec 14, 2017 at 10:48:36AM +0800, Figo.zhang wrote:
> > > 2017-12-14 0:12 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:
> > >
> > > > On Wed, Dec 13, 2017 at 08:10:42PM +0800, Figo.zhang wrote:

[...]

> > This is not what happen. Here is the workflow with HMM mirror (note that
> > physical address do not matter here so i do not even reference them it is
> > all about virtual address):
> >  1 They are 3 buffers a, b and r at given virtual address both CPU and
> >    GPU can access them (concurently or not this does not matter).
> >  2 GPU can fault so if any virtual address do not have a page table
> >    entry inside the GPU page table this trigger a page fault that will
> >    call HMM mirror helper to snapshot CPU page table into the GPU page
> >    table. If there is no physical memory backing the virtual address
> >    (ie CPU page table is also empty for the given virtual address) then
> >    the regular page fault handler of the kernel is invoked.
> >
> 
> so when HMM mirror done, the content of GPU page table entry and
> CPU page table entry
> are same, right? so the GPU and CPU can access the same physical address,
> this physical
> address is allocated by CPU malloc systemcall. is it conflict and race
> condition? CPU and GPU
> write to this physical address concurrently.

Correct and yes it is conflict free. PCIE platform already support
cache coherent access by device to main memory (snoop transaction
in PCIE specification). Access can happen concurently to same byte
and it behave exactly the same as if two CPU core try to access the
same byte.

> 
> i see this slides said:
> http://on-demand.gputechconf.com/gtc/2017/presentation/s7764_john-hubbardgpus-using-hmm-blur-the-lines-between-cpu-and-gpu.pdf
> 
> in page 22~23i 1/4 ?
> When CPU page fault occurs:
> * UM (unified memory driver) copies page data to CPU, umaps from GPU
> *HMM maps page to CPU
> 
> when GPU page fault occurs:
> *HMM has a malloc record buffer, so UM copy page data to GPU
> *HMM unmaps page from CPU
> 
> so in this slides, it said it will has two copies, from CPU to GPU, and
> from GPU to CPU. so in this case (mul_mat_on_gpu()), is it really need two
> copies in kernel space?

This slide is for the case where you use device memory on PCIE platform.
When that happen only the device can access the virtual address back by
device memory. If CPU try to access such address a page fault is trigger
and it migrate the data back to regular memory where both GPU and CPU can
access it concurently.

And again this behavior only happen if you use HMM non cache coherent
device memory model. If you use the device cache coherent model with HMM
then CPU can access the device memory directly too and above scenario
never happen.

Note that memory copy when data move from device to system or from system
to device memory are inevitable. This is exactly as with autoNUMA. Also
note that in some case thing can get allocated directly on GPU and never
copied back to regular memory (only use by GPU and freed once GPU is done
with them) the zero copy case. But i want to stress that the zero copy
case is unlikely to happen for input buffer. Usualy you do not get your
input data set directly on the GPU but from network or disk and you might
do pre-processing on CPU (uncompress input, or do something that is better
done on the CPU). Then you feed your data to the GPU and you do computation
there.


> > Without HMM mirror but ATS/PASI (CCIX or CAPI):
> >  1 They are 3 buffers a, b and r at given virtual address both CPU and
> >    GPU can access them (concurently or not this does not matter).
> >  2 GPU use the exact same page table as the CPU and fault exactly like
> >    CPU on empty page table entry
> >
> > So in the end with HMM mirror or ATS/PASID you get the same behavior.
> > There is no complexity like you seem to assume. This all about virtual
> > address. At any point in time any given valid virtual address of a process
> > point to a given physical memory address and that physical memory address
> > is the same on both the CPU and the GPU at any point in time they are
> > never out of sync (both in HMM mirror and in ATS/PASID case).
> >
> > The exception is for platform that do not have CAPI or CCIX property ie
> > cache coherency for CPU access to device memory. On such platform when
> > you migrate a virtual address to use device physical memory you update
> > the CPU page table with a special entry. If the CPU try to access the
> > virtual address with special entry it trigger fault and HMM will migrate
> > the virtual address back to regular memory. But this does not apply for
> > CAPI or CCIX platform.
> >
> 
> the example of the virtual address using device physical memory is : gpu_r
> = gpu_alloc(m*m*sizeof(float)),
> so CPU want to access gpu_r will trigger migrate back to CPU memory,
> it will allocate CPU page and copy
> to gpu_r's content to CPU pages, right?

No. Here we are always talking about virtual address that are the outcome
of an mmap syscall either as private anonymous memory or as mmap of regular
file (ie not a device file but a regular file on a filesystem).

Device driver can migrate any virtual address to use device memory for
performance reasons (how, why and when such migration happens is totaly
opaque to HMM it is under the control of the device driver).

So if you do:
   BUFA = malloc(size);
Then do something with BUFA on the CPU (like reading input or network, ...)
the memory is likely to be allocated with regular main memory (like DDR).

Now if you start some job on your GPU that access BUFA the device driver
might call migrate_vma() helper to migrate the memory to device memory. At
that point the virtual address of BUFA point to physical device memory here
CAPI or CCIX. If it is not CAPI/CCIX than the GPU page table point to device
memory while the CPU page table point to invalid special entry. The GPU can
work on BUFA that now reside inside the device memory. Finaly, in the non
CAPI/CCIX case, if CPU try to access that memory then a migration back to
regular memory happen.


What you really need is to decouple the virtual address part from what is
the physical memory that is backing a virtual address. HMM provide helpers
for both aspect. First to mirror page table so that every virtual address
point to same physical address. Second side of HMM is to allow to use device
memory transparently inside a process by allowing to migrate any virtual
address to use device memory. Both aspect are orthogonal to each others.

Cheers,
JA(C)rA'me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
