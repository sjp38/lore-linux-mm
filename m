Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D73D6B02E1
	for <linux-mm@kvack.org>; Wed, 17 May 2017 05:04:00 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id h16so1547743vkd.5
        for <linux-mm@kvack.org>; Wed, 17 May 2017 02:04:00 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id z23si761670uaa.92.2017.05.17.02.03.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 May 2017 02:03:59 -0700 (PDT)
Message-ID: <1495011826.3092.18.camel@kernel.crashing.org>
Subject: Re: [RFC summary] Enable Coherent Device Memory
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 17 May 2017 19:03:46 +1000
In-Reply-To: <20170517082836.whe3hggeew23nwvz@techsingularity.net>
References: <1494569882.21563.8.camel@gmail.com>
	 <20170512102652.ltvzzwejkfat7sdq@techsingularity.net>
	 <CAKTCnz=VkswmWxoniD-TRYWWxr7wrWwCgRcsTXfNkgHZKXDEwA@mail.gmail.com>
	 <20170516084303.ag2lzvdohvh6weov@techsingularity.net>
	 <1494973607.21847.50.camel@kernel.crashing.org>
	 <20170517082836.whe3hggeew23nwvz@techsingularity.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Aneesh Kumar KV <aneesh.kumar@linux.vnet.ibm.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, 2017-05-17 at 09:28 +0100, Mel Gorman wrote:
> On Wed, May 17, 2017 at 08:26:47AM +1000, Benjamin Herrenschmidt wrote:
> > On Tue, 2017-05-16 at 09:43 +0100, Mel Gorman wrote:
> > > I'm not sure what you're asking here. migration is only partially
> > > transparent but a move_pages call will be necessary to force pages onto
> > > CDM if binding policies are not used so the cost of migration will be
> > > invisible. Even if you made it "transparent", the migration cost would
> > > be incurred at fault time. If anything, using move_pages would be more
> > > predictable as you control when the cost is incurred.
> > 
> > One of the main point of this whole exercise is for applications to not
> > have to bother with any of this and now you are bringing all back into
> > their lap.
> > 
> > The base idea behind the counters we have on the link is for the HW to
> > know when memory is accessed "remotely", so that the device driver can
> > make decision about migrating pages into or away from the device,
> > especially so that applications don't have to concern themselves with
> > memory placement.
> > 
> 
> There is only so much magic that can be applied and if the manual case
> cannot be handled then the automatic case is problematic. You say that you
> want kswapd disabled, but have nothing to handle overcommit sanely.

I am not certain we want kswapd disabled, that is definitely more of a
userspace policy, I agree. It could be in this case that it should
prioritize different pages but still be able to push out. We *do* have
age counting etc... just less efficient / higher cost. 

>  You
> want to disable automatic NUMA balancing yet also be able to automatically
> detect when data should move from CDM (automatic NUMA balancing by design
> couldn't move data to CDM without driver support tracking GPU accesses).

We can, via a driver specific hook, since we have specific counters on
the link, so we don't want the autonuma based approach which makes PTEs
inaccessible.

> To handle it transparently, either the driver needs to do the work in which
> case no special core-kernel support is needed beyond what already exists or
> there is a userspace daemon like numad running in userspace that decides
> when to trigger migrations on a separate process that is using CDM which
> would need to gather information from the driver.

The driver can handle it, we just need autonuma off the CDM memory (it
can continue operating normally on system memory).

> In either case, the existing isolation mechanisms are still sufficient as
> long as the driver hot-adds the CDM memory from a userspace trigger that
> it then responsible for setting up the isolation.

Yes, I think the NUMA node based approach works fine using a lot of
existing stuff. There are a couple of gaps, which we need to look at
fixing one way or another such as the above, but overall I don't see
the need of some major overhaul, not do I see the need of going down
the path of ZONE_DEVICE.

> All that aside, this series has nothing to do with the type of magic
> you describe and the feedback as iven was "at this point, what you are
> looking for does not require special kernel support or heavy wiring into
> the core vm".
> 
> > Thus we want to reply on the GPU driver moving the pages around where
> > most appropriate (where they are being accessed, either core memory or
> > GPU memory) based on inputs from the HW counters monitoring the link.
> > 
> 
> And if the driver is polling all the accesses, there are still no changes
> required to the core vm as long as the driver does the hotplug and allows
> userspace to isolate if that is what the applications desire.

With one main exception ... 

We also do want normal allocations to avoid going to the GPU memory.

IE, things should go to the GPU memory if and only if they are either
explicitly put there by the application/driver (the case where
applications do care about manual placement), or the migration case.A 

The latter is triggered by the driver, so it's also a case of the
driver allocating the GPU pages and doing a migration to them.

This is the key thing. Now creating a CMA or using ZONE_MOVABLE can
handle at least keeping kernel allocations off the GPU. However we
would also like to keep random unrelated user memory & page cache off
as well.

There are various reasons for that, some related to the fact that the
performance characteristics of that memory (ie latency) could cause
nasty surprises for normal applications, some related to the fact that
this memory is rather unreliable compared to system memory...

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
