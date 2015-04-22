Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 575E0900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 20:43:03 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so76529420qgf.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:43:03 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id y137si3570980qky.77.2015.04.21.17.43.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 17:43:02 -0700 (PDT)
Message-ID: <1429663372.27410.75.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 22 Apr 2015 10:42:52 +1000
In-Reply-To: <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, 2015-04-21 at 18:49 -0500, Christoph Lameter wrote:
> On Tue, 21 Apr 2015, Paul E. McKenney wrote:
> 
> > Thoughts?
> 
> Use DAX for memory instead of the other approaches? That way it is
> explicitly clear what information is put on the CAPI device.

Care to elaborate on what DAX is ?

> > 	Although such a device will provide CPU's with cache-coherent
> 
> Maybe call this coprocessor like IBM does? It is like a processor after
> all in terms of its participation in cache coherent?

It is, yes, in a way, though the actual implementation could be anything
from a NIC to a GPU or a crypto accelerator or whatever you can think
of.

The device memory is fully cachable from the CPU standpoint and the
device *completely* shares the MMU with the CPU (operates within a
normal linux mm context).

> > 	access to on-device memory, the resulting memory latency is
> > 	expected to be slower than the normal memory that is tightly
> > 	coupled to the CPUs.  Nevertheless, data that is only occasionally
> > 	accessed by CPUs should be stored in the device's memory.
> > 	On the other hand, data that is accessed rarely by the device but
> > 	frequently by the CPUs should be stored in normal system memory.
> 
> I would expect many devices to not have *normal memory* at all (those
> that simply process some data or otherwise interface with external
> hardware like f.e. a NIC). Other devices like GPUs have local memory but
> what is in GPU memory is very specific and general OS structures should
> not be allocated there.

That isn't entirely true. Take the GPU as an example, they can have
*large* amounts of local memory and you want to migrate the working set
(not just control structures) over.

So you can basically malloc() something on the host, hand it over to the
coprocessor which churns on it, the bus interface/MMU on the device
"detects" that a given page or set of pages is heavily pounded on by the
GPU and sends an interrupt to the host via a sideband channel to request
its migration to the device.

Since the device memory is fully cachable and coherent, it can simply be
represented with struct pages like normal system memory and we can use
the existing migration mechanism.

> What I mostly would like to see is that these devices will have the
> ability to participate in the cpu cache coherency scheme. I.e. they
> will have l1/l2/l3 caches that will allow fast data exchange between the
> coprocessor and the regular processors in the system.

Yes they can in theory.

> >
> > 		a.	It should be possible to migrate all data away
> > 			from the device's memory at any time.
> 
> That would be device specific and only a special device driver for that
> device could save the state of the device (if that is necessary. It would
> not be for something like a NIC).

Yes and no. If the memory is fully given to the system as struct pages,
we can have random kernel allocations on it which means we can't evict
it.

The ideas here are to try to mitigate that, ie, keep the benefit of
struct page and limit the problem of unrelated allocs hitting the
device.

> > 		b.	Normal memory allocation should avoid using the
> > 			device's memory, as this would interfere
> > 			with the needed migration.  It may nevertheless
> > 			be desirable to use the device's memory
> > 			if system memory is exhausted, however, in some
> > 			cases, even this "emergency" use is best avoided.
> > 			In fact, a good solution will provide some means
> > 			for avoiding this for those cases where it is
> > 			necessary to evacuate memory when offlining the
> > 			device.
> 
> Ok that seems to mean that none of the approaches suggested later would
> be useful.

Why ? A far away numa node covered with a CMA would probably do the
trick, a ZONE would definitely do the trick...

> > 	3.	The device's memory is treated like normal system
> > 		memory by the Linux kernel, for example, each page has a
> > 		"struct page" associate with it.  (In contrast, the
> > 		traditional approach has used special-purpose OS mechanisms
> > 		to manage the device's memory, and this memory was treated
> > 		as MMIO space by the kernel.)
> 
> Why do we need a struct page? If so then maybe equip DAX with a struct
> page so that the contents of the device memory can be controlled via a
> filesystem? (may be custom to the needs of the device).

What is DAX ?

struct page means we can transparently migrate anonymous memory accross
among others.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
