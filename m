Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5B226B02C4
	for <linux-mm@kvack.org>; Wed, 17 May 2017 05:57:31 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id x71so1793196vkd.0
        for <linux-mm@kvack.org>; Wed, 17 May 2017 02:57:31 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id j64si584024vkg.207.2017.05.17.02.57.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 02:57:30 -0700 (PDT)
Message-ID: <1495014995.3092.20.camel@kernel.crashing.org>
Subject: Re: [RFC summary] Enable Coherent Device Memory
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 17 May 2017 19:56:35 +1000
In-Reply-To: <20170517091511.gjxx46d2h6gmcqjf@techsingularity.net>
References: <1494569882.21563.8.camel@gmail.com>
	 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
	 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
	 <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
	 <1494973607.21847.50.camel@kernel.crashing.org>
	 <20170517082836.whe3hggeew23nwvz@techsingularity.net>
	 <1495011826.3092.18.camel@kernel.crashing.org>
	 <20170517091511.gjxx46d2h6gmcqjf@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, 2017-05-17 at 10:15 +0100, Mel Gorman wrote:
> > We can, via a driver specific hook, since we have specific counters on
> > the link, so we don't want the autonuma based approach which makes PTEs
> > inaccessible.
> > 
> 
> Then poll the driver from a userspace daemon and make placement
> decisions if automatic NUMA balancings reference-based decisions are
> unsuitable.

Why a userspace daemon ? I don't get this... the driver will get
interrupts from the GPU with page lists, it can trigger migrations
without needing a userspace daemon...

> > > To handle it transparently, either the driver needs to do the work in which
> > > case no special core-kernel support is needed beyond what already exists or
> > > there is a userspace daemon like numad running in userspace that decides
> > > when to trigger migrations on a separate process that is using CDM which
> > > would need to gather information from the driver.
> > 
> > The driver can handle it, we just need autonuma off the CDM memory (it
> > can continue operating normally on system memory).
> > 
> 
> Already suggested that prctl be used to disable automatic numa balancing
> on a per-task basis. Alternatively, settiing a memory policy will be
> enough and as the applications are going to need policies anyway, you
> should be able to get that by default.

I'm not sure we want to disable it for the application vs. disabling it
for pages that reside on that node, however, but it could be tricky so
the application first might be a way to get started.

> > > In either case, the existing isolation mechanisms are still sufficient as
> > > long as the driver hot-adds the CDM memory from a userspace trigger that
> > > it then responsible for setting up the isolation.
> > 
> > Yes, I think the NUMA node based approach works fine using a lot of
> > existing stuff. There are a couple of gaps, which we need to look at
> > fixing one way or another such as the above, but overall I don't see
> > the need of some major overhaul, not do I see the need of going down
> > the path of ZONE_DEVICE.
> > 
> Your choice, but it also doesn't take away from the fact that special
> casing in the core does not appear to be required at this point.

Well, yes and no.

If we use the NUMA based approach, then no special casing up to this
point, the only thing is below, the idea of avoiding "normal"
allocations for that type of memory.

If we use ZONE_DEVICE and the bulk of the HMM infrastructure, then we
get the above, but at the expense of a pile of special casing all over
the place for the "special" kind of struct page created for ZONE_DEVICE
(lacking LRU).

> > > All that aside, this series has nothing to do with the type of magic
> > > you describe and the feedback as iven was "at this point, what you are
> > > looking for does not require special kernel support or heavy wiring into
> > > the core vm".
> > > 
> > > > Thus we want to reply on the GPU driver moving the pages around where
> > > > most appropriate (where they are being accessed, either core memory or
> > > > GPU memory) based on inputs from the HW counters monitoring the link.
> > > > 
> > > 
> > > And if the driver is polling all the accesses, there are still no changes
> > > required to the core vm as long as the driver does the hotplug and allows
> > > userspace to isolate if that is what the applications desire.
> > 
> > With one main exception ... 
> > 
> > We also do want normal allocations to avoid going to the GPU memory.
> > 
> 
> Use policies. If the NUMA distance for CDM is set high then even applications
> that have access to CDM will use every other node before going to CDM.

Yes. That was the original idea. Along with ZONE_MOVABLE to avoid
kernel allocations completely.

I think Balbir and Anshuman wanted to play with a more fully exclusive
approach where those allocations are simply not permitted.

>  As
> you insist on no application awareness, the migration to CDM will have to
> be controlled by a separate daemon.

Or by the driver itself, I don't think we need a daemon, but that's a
detail in the grand scheme of things.

> > IE, things should go to the GPU memory if and only if they are either
> > explicitly put there by the application/driver (the case where
> > applications do care about manual placement), or the migration case.A 
> > 
> > The latter is triggered by the driver, so it's also a case of the
> > driver allocating the GPU pages and doing a migration to them.
> > 
> > This is the key thing. Now creating a CMA or using ZONE_MOVABLE can
> > handle at least keeping kernel allocations off the GPU. However we
> > would also like to keep random unrelated user memory & page cache off
> > as well.
> > 
> 
> Fine -- hot add the memory from the device via a userspace trigger and
> have the userspace trigger then setup the policies to isolate CDM from
> general usage.

This is racy though. The memory is hot added, but things can get
allocated all over it before it has time to adjust the policies. Same
issue we had with creating a CMA I believe.

I think that's what Balbir was trying to do with the changes to the
core, to be able to create that "don't touche me" NUMA node straight
up.

Unless we have a way to create a node without actually making it
available for allocations, so we get a chance to establish policies for
it, then "online" it ?

Doing these from userspace is a bit nasty since it's expected to all be
under the control of the GPU driver, but it could be done via a
combination of GPU driver & udev helpers or a special daemon.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
