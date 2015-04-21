Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id 301C3900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 19:49:34 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so29157562ied.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 16:49:33 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [2001:558:fe21:29:69:252:207:41])
        by mx.google.com with ESMTPS id an2si4265710igc.22.2015.04.21.16.49.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 16:49:33 -0700 (PDT)
Date: Tue, 21 Apr 2015 18:49:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150421214445.GA29093@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, 21 Apr 2015, Paul E. McKenney wrote:

> Thoughts?

Use DAX for memory instead of the other approaches? That way it is
explicitly clear what information is put on the CAPI device.

> 	Although such a device will provide CPU's with cache-coherent

Maybe call this coprocessor like IBM does? It is like a processor after
all in terms of its participation in cache coherent?

> 	access to on-device memory, the resulting memory latency is
> 	expected to be slower than the normal memory that is tightly
> 	coupled to the CPUs.  Nevertheless, data that is only occasionally
> 	accessed by CPUs should be stored in the device's memory.
> 	On the other hand, data that is accessed rarely by the device but
> 	frequently by the CPUs should be stored in normal system memory.

I would expect many devices to not have *normal memory* at all (those
that simply process some data or otherwise interface with external
hardware like f.e. a NIC). Other devices like GPUs have local memory but
what is in GPU memory is very specific and general OS structures should
not be allocated there.

What I mostly would like to see is that these devices will have the
ability to participate in the cpu cache coherency scheme. I.e. they
will have l1/l2/l3 caches that will allow fast data exchange between the
coprocessor and the regular processors in the system.

>
> 		a.	It should be possible to migrate all data away
> 			from the device's memory at any time.

That would be device specific and only a special device driver for that
device could save the state of the device (if that is necessary. It would
not be for something like a NIC).

> 		b.	Normal memory allocation should avoid using the
> 			device's memory, as this would interfere
> 			with the needed migration.  It may nevertheless
> 			be desirable to use the device's memory
> 			if system memory is exhausted, however, in some
> 			cases, even this "emergency" use is best avoided.
> 			In fact, a good solution will provide some means
> 			for avoiding this for those cases where it is
> 			necessary to evacuate memory when offlining the
> 			device.

Ok that seems to mean that none of the approaches suggested later would
be useful.

> 	3.	The device's memory is treated like normal system
> 		memory by the Linux kernel, for example, each page has a
> 		"struct page" associate with it.  (In contrast, the
> 		traditional approach has used special-purpose OS mechanisms
> 		to manage the device's memory, and this memory was treated
> 		as MMIO space by the kernel.)

Why do we need a struct page? If so then maybe equip DAX with a struct
page so that the contents of the device memory can be controlled via a
filesystem? (may be custom to the needs of the device).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
