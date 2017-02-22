Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id BDEF86B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 04:50:46 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id q124so2188693wmg.2
        for <linux-mm@kvack.org>; Wed, 22 Feb 2017 01:50:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 17si1941882wmv.65.2017.02.22.01.50.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Feb 2017 01:50:45 -0800 (PST)
Date: Wed, 22 Feb 2017 10:50:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V3 0/4] Define coherent device memory node
Message-ID: <20170222095043.GG5753@dhcp22.suse.cz>
References: <20170215120726.9011-1-khandual@linux.vnet.ibm.com>
 <20170215182010.reoahjuei5eaxr5s@suse.de>
 <dfd5fd02-aa93-8a7b-b01f-52570f4c87ac@linux.vnet.ibm.com>
 <20170221111107.GJ15595@dhcp22.suse.cz>
 <890fb824-d1f0-3711-4fe6-d6ddf29a0d80@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <890fb824-d1f0-3711-4fe6-d6ddf29a0d80@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

On Tue 21-02-17 19:09:18, Anshuman Khandual wrote:
> On 02/21/2017 04:41 PM, Michal Hocko wrote:
> > On Fri 17-02-17 17:11:57, Anshuman Khandual wrote:
> > [...]
> >> * User space using mbind() to get CDM memory is an additional benefit
> >>   we get by making the CDM plug in as a node and be part of the buddy
> >>   allocator. But the over all idea from the user space point of view
> >>   is that the application can allocate any generic buffer and try to
> >>   use the buffer either from the CPU side or from the device without
> >>   knowing about where the buffer is really mapped physically. That
> >>   gives a seamless and transparent view to the user space where CPU
> >>   compute and possible device based compute can work together. This
> >>   is not possible through a driver allocated buffer.
> > 
> > But how are you going to define any policy around that. Who is allowed
> 
> The user space VMA can define the policy with a mbind(MPOL_BIND) call
> with CDM/CDMs in the nodemask.
>
> > to allocate and how much of this "special memory". Is it possible that
> 
> Any user space application with mbind(MPOL_BIND) call with CDM/CDMs in
> the nodemask can allocate from the CDM memory. "How much" gets controlled
> by how we fault from CPU and the default behavior of the buddy allocator.

In other words the policy is implemented by the kernel. Why is this a
good thing?

> > we will eventually need some access control mechanism? If yes then mbind
> 
> No access control mechanism is needed. If an application wants to use
> CDM memory by specifying in the mbind() it can. Nothing prevents it
> from using the CDM memory.

What if we find out that an access control _is_ really needed? I can
easily imagine that some devices will come up with really fast and expensive
memory. You do not want some random user to steal it from you when you
want to use it for your workload.

> > is really not suitable interface to (ab)use. Also what should happen if
> > the mbind mentions only CDM memory and that is depleted?
> 
> IIUC *only CDM* cannot be requested from user space as there are no user
> visible interface which can translate to __GFP_THISNODE.

I do not understand what __GFP_THISNODE has to do with this. This is an
internal flag.

> MPOL_BIND with
> CDM in the nodemask will eventually pick a FALLBACK zonelist which will
> have zones of the system including CDM ones. If the resultant CDM zones
> run out of memory, we fail the allocation request as usual.

OK, so let's say you mbind to a single node which is CDM. You seem to be
saying that we will simply break the NUMA affinity in this special case?
Currently we invoke the OOM killer if nodes which the application binds
to are depleted and cannot be reclaimed.
 
> > Could you also explain why the transparent view is really better than
> > using a device specific mmap (aka CDM awareness)?
> 
> Okay with a transparent view, we can achieve a control flow of application
> like the following.
> 
> (1) Allocate a buffer:		alloc_buffer(buf, size)
> (2) CPU compute on buffer:	cpu_compute(buf, size)
> (3) Device compute on buffer:	device_compute(buf, size)
> (4) CPU compute on buffer:	cpu_compute(buf, size)
> (5) Release the buffer:		release_buffer(buf, size)
> 
> With assistance from a device specific driver, the actual page mapping of
> the buffer can change between system RAM and device memory depending on
> which side is accessing at a given point. This will be achieved through
> driver initiated migrations.

But then you do not need any NUMA affinity, right? The driver can do
all this automagically. How does the numa policy comes into the game in
your above example. Sorry for being dense, I might be really missing
something important here, but I really fail to see why the NUMA is the
proper interface here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
