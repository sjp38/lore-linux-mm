Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4D76B04B0
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 16:30:01 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q77so5191635qke.4
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 13:30:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z67si2870395qkc.529.2017.09.08.13.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 13:29:59 -0700 (PDT)
Date: Fri, 8 Sep 2017 16:29:54 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-v25 19/19] mm/hmm: add new helper to hotplug CDM memory
 region v3
Message-ID: <20170908202954.GE3512@redhat.com>
References: <20170817000548.32038-20-jglisse@redhat.com>
 <a42b13a4-9f58-dcbb-e9de-c573fbafbc2f@huawei.com>
 <20170904155123.GA3161@redhat.com>
 <7026dfda-9fd0-2661-5efc-66063dfdf6bc@huawei.com>
 <20170905023826.GA4836@redhat.com>
 <c7997016-7932-649d-cf27-17caa33cd856@huawei.com>
 <20170905135017.GA19397@redhat.com>
 <20170905190013.GC24073@linux.intel.com>
 <20170905192050.GC19397@redhat.com>
 <20170908194344.GA1956@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170908194344.GA1956@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Bob Liu <liubo95@huawei.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, David Nellans <dnellans@nvidia.com>, Balbir Singh <bsingharora@gmail.com>, majiuyue <majiuyue@huawei.com>, "xieyisheng (A)" <xieyisheng1@huawei.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Sep 08, 2017 at 01:43:44PM -0600, Ross Zwisler wrote:
> On Tue, Sep 05, 2017 at 03:20:50PM -0400, Jerome Glisse wrote:
> <>
> > Does HMAT support device hotplug ? I am unfamiliar with the whole inner working
> > of ACPI versus PCIE. Anyway i don't see any issue with device memory also showing
> > through HMAT but like i said device driver for the device will want to be in total
> > control of that memory.
> 
> Yep, the HMAT will support device hotplug via the _HMA method (section 6.2.18
> of ACPI 6.2).  This basically supplies an entirely new HMAT that the system
> will use to replace the current one.
> 
> I don't yet have support for _HMA in my enabling, but I do intend to add
> support for it once we settle on a sysfs API for the regular boot-time case.
> 
> > Like i said issue here is that core kernel is unaware of the device activity ie
> > on what part of memory the device is actively working. So core mm can not make
> > inform decision on what should be migrated to device memory. Also we do not want
> > regular memory allocation to end in device memory unless explicitly ask for.
> > Few reasons for that. First this memory might not only be use for compute task
> > but also for graphic and in that case they are hard constraint on physically
> > contiguous memory allocation that require the GPU to move thing around to make
> > room for graphic object (can't allow GUP).
> > 
> > Second reasons, the device memory is inherently unreliable. If there is a bug
> > in the device driver or the user manage to trigger a faulty condition on GPU
> > the device might need a hard reset (ie cut PCIE power to device) which leads
> > to loss of memory content. While GPU are becoming more and more resilient they
> > are still prone to lockup.
> > 
> > Finaly for GPU there is a common pattern of memory over-commit. You pretend to
> > each application as if they were the only one and allow each of them to allocate
> > all of the device memory or more than could with strict sharing. As GPU have
> > long timeslice between switching to different context/application they can
> > easily move out and in large chunk of the process memory at context/application
> > switching. This is have proven to be a key aspect to allow maximum performances
> > accross several concurrent application/context.
> > 
> > To implement this easiest solution is for the device to lie about how much memory
> > it has and use the system memory as an overflow.
> 
> I don't think any of this precludes the HMAT being involved.  This is all very
> similar to what I think we need to do for high bandwidth memory, for example.
> We don't want the OS to use it for anything, and we want all of it to be
> available for applications to allocate and use for their specific workload.
> We don't want to make any assumptions about how it can or should be used.
> 
> The HMAT is just there to give us a few things:
> 
> 1) It provides us with an explicit way of telling the OS not to use the
> memory, in the form of the "Reservation hint" flag in the Memory Subsystem
> Address Range Structure (ACPI 6.2 section 5.2.27.3).  I expect that this will
> be set for persistent memory and HBM, and it sounds like you'd expect it to be
> set for your device memory as well.
> 
> 2) It provides us with a way of telling userspace "hey, I know about some
> memory, and I can tell you its performance characteristics".  All control of
> how this memory is allocated and used is still left to userspace.
> 
> > I am not saying that NUMA is not the way forward, i am saying that as it is today
> > it is not suited for this. It is lacking metric, it is lacking logic, it is lacking
> > features. We could add all this but it is a lot of work and i don't feel that we
> > have enough real world experience to do so now. I would rather have each devices
> > grow proper infrastructure in their driver through device specific API.
> 
> To be clear, I'm not proposing that we teach the NUMA code how to
> automatically allocate for a given numa node, balance, etc. memory described
> by the HMAT.  All I want is an API that says "here is some memory, I'll tell
> you all I can about it and let you do with it what you will", and perhaps a
> way to manually allocate what you want.
> 
> And yes, this is very hand-wavy at this point. :)  After I get the sysfs
> portion sussed out the next step is to work on enabling something like
> libnuma to allow the memory to be manually allocated.
> 
> I think this works for both my use case and yours, correct?

Depend what you mean. Using NUMA as it is today no. Growing new API on the
side of libnuma maybe. It is hard to say. Right now the GPU do have a very
reach API see OpenCL or CUDA API. Anything less expressive than what they
offer would not work.

Existing libnuma API is illsuited. It is too static. GPU workload are more
dynamic as a result the virtual address space and the type of memory that
is backing a range of virtual address is manage in isolation. You move range
of virtual address to different memory following application programmer
advice and overall resource usage.

libnuma is much more alloc some memory on some node and that's where that
memory should stay. At least this is my feeling from the API (here i am not
talking about mbind syscall but about userspace libnuma).


But it can grow to something more in the line of OpenCL/CUDA.


> > Then identify common pattern and from there try to build a sane API (if any such
> > thing exist :)) rather than trying today to build the whole house from the ground
> > up with just a foggy idea of how it should looks in the end.
> 
> Yea, I do see your point.  My worry is that if I define an API, and you define
> an API, we'll end up in two different places with people using our different
> APIs, then:
> 
> https://xkcd.com/927/
> 
> :)

I am well aware of that :) The thing is, that API already exist and there is large
chunk of what we could call legacy application that rely on those (again OpenCL and
CUDA API). The easiest way is to evolve from this existing API and factor out what
is constant accross devices.

Note that while the userspace API of the OpenCL/CUDA API is standardize and well
define. The actual kernel API that the OpenCL/CUDA runtime use to talk with the
kernel vary from one device to the others. That is why i say there is no consensus
on what that API would look like. From high level (OpenCL/CUDA) sure but how this
could translate into device agnostic kernel API is more fuzzy at this point.

Easiest thing would be to create kernel API with all the information that those
high API offer but this would mean moving large chunk of device specific user
space code into the kernel. Given that GPU device driver are already bigger on
their own that all the rest of the kernel taken together, i am not sure this
would be welcome (also some of this code rely on floating point operation
though that can be work around).

> 
> The HMAT enabling I'm trying to do is very passive - it doesn't actively do
> *anything* with the memory, it's entire purpose is to give userspace more
> information about the memory so userspace can make informed decisions.
> 
> Would you be willing to look at the sysfs API I have defined, and see if it
> would work for you?
> 
> https://lkml.org/lkml/2017/7/6/749

For now the same kind of information about GPU memory is reported through API
like OpenCL/CUDA but having one place to report all might appeal to developer.
Issue becomes how to match that sysfs information with an OpenCL/CUDA device
as those API are operating system agnostic.

Nonetheless i will go over the sysfs see how it could fit.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
