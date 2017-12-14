Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id F091E6B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 10:28:40 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id u193so2666168oie.4
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:28:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x136si1321580oif.551.2017.12.14.07.28.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 07:28:39 -0800 (PST)
Date: Thu, 14 Dec 2017 10:28:35 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 00/19] HMM (Heterogeneous Memory Management) v25
Message-ID: <20171214152834.GA25092@redhat.com>
References: <20170817000548.32038-1-jglisse@redhat.com>
 <CAF7GXvqSZzNHdefQWhEb2SDYWX5hDWqQX7cayuVEQ8YyTULPog@mail.gmail.com>
 <20171213161247.GA2927@redhat.com>
 <CAF7GXvrxo2xj==wA_=fXr+9nF0k0Ed123kZXeKWKBHS6TKYNdA@mail.gmail.com>
 <20171214031607.GA17710@redhat.com>
 <CAF7GXvqoYXDJNYcrzJo5bGvfBG9iFq8PbeA7RO7y+9DuM7N0og@mail.gmail.com>
 <20171214041650.GB17710@redhat.com>
 <CAF7GXvpuvrfRHBBrQ4ADz+ma_=z6T0+9j3As-GBTtS+gNqfZXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAF7GXvpuvrfRHBBrQ4ADz+ma_=z6T0+9j3As-GBTtS+gNqfZXA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>

On Thu, Dec 14, 2017 at 03:05:39PM +0800, Figo.zhang wrote:
> 2017-12-14 12:16 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:
> > On Thu, Dec 14, 2017 at 11:53:40AM +0800, Figo.zhang wrote:
> > > 2017-12-14 11:16 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:
> > > > On Thu, Dec 14, 2017 at 10:48:36AM +0800, Figo.zhang wrote:
> > > > > 2017-12-14 0:12 GMT+08:00 Jerome Glisse <jglisse@redhat.com>:
> > > > > > On Wed, Dec 13, 2017 at 08:10:42PM +0800, Figo.zhang wrote:

[...]

> > This slide is for the case where you use device memory on PCIE platform.
> > When that happen only the device can access the virtual address back by
> > device memory. If CPU try to access such address a page fault is trigger
> > and it migrate the data back to regular memory where both GPU and CPU can
> > access it concurently.
> >
> > And again this behavior only happen if you use HMM non cache coherent
> > device memory model. If you use the device cache coherent model with HMM
> > then CPU can access the device memory directly too and above scenario
> > never happen.
> >
> > Note that memory copy when data move from device to system or from system
> > to device memory are inevitable. This is exactly as with autoNUMA. Also
> > note that in some case thing can get allocated directly on GPU and never
> > copied back to regular memory (only use by GPU and freed once GPU is done
> > with them) the zero copy case. But i want to stress that the zero copy
> > case is unlikely to happen for input buffer. Usualy you do not get your
> > input data set directly on the GPU but from network or disk and you might
> > do pre-processing on CPU (uncompress input, or do something that is better
> > done on the CPU). Then you feed your data to the GPU and you do computation
> > there.
> >
> 
> Greati 1/4 ?very detail about the HMM explanation, Thanks a lot.
> so would you like see my conclusion is correct?
> * if support CCIX/CAPI, CPU can access GPU memory directly, and GPU also
> can access CPU memory directly,
> so it no need copy on kernel space in HMM solutions.

Yes but migration do imply copy. The physical address backing a virtual address
can change over the lifetime of a virtual address (between mmap and munmap). As
a result of various activity (auto NUMA, compaction, swap out then swap back in,
...) and in the case that interest us as the result of a device driver migrating
thing to its device memory.


> * if no support CCIX/CAPI, CPU cannot access GPU memory in cache
> coherency method, also GPU cannot access CPU memory at
> cache coherency. it need some copies like John Hobburt's slides.
>    *when GPU page fault, need copy data from CPU page to GPU page, and
> HMM unmap the CPU page...
>    * when CPU page fault, need copy data from GPU page to CPU page
> and ummap GPU page and map the CPU page...

No, GPU can access main memory just fine (snoop PCIE transaction and in a
full cache coherent way with CPU). Only the CPU can not access the device
memory. So there is a special case only when migrating some virtual address
to use device memory.

What is described inside John's slides is what happen when you migrate some
virtual addresses to device memory where the CPU can not access it. This
migration is not necessary for the GPU to access memory. It only happens as
an optimization when the device driver suspect it will make frequent access
to that memory and that CPU will not try to access it.

[...]

> > No. Here we are always talking about virtual address that are the outcome
> > of an mmap syscall either as private anonymous memory or as mmap of regular
> > file (ie not a device file but a regular file on a filesystem).
> >
> > Device driver can migrate any virtual address to use device memory for
> > performance reasons (how, why and when such migration happens is totaly
> > opaque to HMM it is under the control of the device driver).
> >
> > So if you do:
> >    BUFA = malloc(size);
> > Then do something with BUFA on the CPU (like reading input or network, ...)
> > the memory is likely to be allocated with regular main memory (like DDR).
> >
> > Now if you start some job on your GPU that access BUFA the device driver
> > might call migrate_vma() helper to migrate the memory to device memory. At
> > that point the virtual address of BUFA point to physical device memory here
> > CAPI or CCIX. If it is not CAPI/CCIX than the GPU page table point to
> > device
> > memory while the CPU page table point to invalid special entry. The GPU can
> > work on BUFA that now reside inside the device memory. Finaly, in the non
> > CAPI/CCIX case, if CPU try to access that memory then a migration back to
> > regular memory happen.
> >
> 
> in this scenario:
> *if CAPI/CCIX supporti 1/4 ? the CPU's page table and GPU's also point to the
> device physical page?
> in this case, it still need the ZONE_DEVICE infrastructure for
> CPU page tablei 1/4 ?

Correct, in CAPI/CCIX case there is only one page table and thus after migration
they both point to same physical address for the virtual addresses of BUFA.

> *if no CAPI/CCIX support, the CPU's page table filled a invalid special pte.

Correct. This is the case described by John's slides.


The physical memory backing a virtual address can change at anytime for many
different reasons (autonuma, compaction, swap out follow by swap in, ...) and
migration (from one physical memory type to another) for accelerator purposes
is just a new reasons in that list.

Cheers,
JA(C)rA'me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
