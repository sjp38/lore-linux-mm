Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6E36C6B02E1
	for <linux-mm@kvack.org>; Wed, 10 May 2017 19:04:31 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u187so8669539pgb.0
        for <linux-mm@kvack.org>; Wed, 10 May 2017 16:04:31 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id x71si338179pgd.249.2017.05.10.16.04.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 16:04:30 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id 64so1138700pgb.3
        for <linux-mm@kvack.org>; Wed, 10 May 2017 16:04:30 -0700 (PDT)
Message-ID: <1494457458.940.2.camel@gmail.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 11 May 2017 09:04:18 +1000
In-Reply-To: <20170509113638.GJ6481@dhcp22.suse.cz>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <20170502143608.GM14593@dhcp22.suse.cz> <1493875615.7934.1.camel@gmail.com>
	 <20170504125250.GH31540@dhcp22.suse.cz>
	 <1493912961.25766.379.camel@kernel.crashing.org>
	 <20170505145238.GE31461@dhcp22.suse.cz>
	 <1493999822.25766.397.camel@kernel.crashing.org>
	 <20170509113638.GJ6481@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Tue, 2017-05-09 at 13:36 +0200, Michal Hocko wrote:
> On Fri 05-05-17 17:57:02, Benjamin Herrenschmidt wrote:
> > On Fri, 2017-05-05 at 16:52 +0200, Michal Hocko wrote:
> > > 
> > > This sounds pretty much like a HW specific details which is not the
> > > right criterion to design general CDM around.
> > 
> > Which is why I don't see what's the problem with simply making this
> > a hot-plugged NUMA node, since it's basically what it is with a
> > "different" kind of CPU, possibly covered with a CMA, which provides
> > both some isolation and the ability to do large physical allocations
> > for applications who chose to use the legacy programming interfaces and
> > manually control the memory.
> > 
> > Then, the "issues" with things like reclaim, autonuma can be handled
> > with policy tunables. Possibly node attributes.
> > 
> > It seems to me that such a model fits well in the picture where we are
> > heading not just with GPUs, but with OpenCAPI based memory, CCIX or
> > other similar technologies that can provide memory possibly with co-
> > located acceleration devices.
> > 
> > It also mostly already just work.
> 
> But this is not what the CDM as proposed here is about AFAIU.

The main reason for the patches was to address "issues" with things like
reclaim, autonuma isolation, etc and the constraint of not willing to
make allocator changes.

Do we see node attributes as something we need generically? Is there
consensus that we need this or do we see all new algorithms working
across all of N_MEMORY all the time?

> It is
> argued this is not a _normal_ cpuless node and it neads tweak here and
> there. And that is my main objection about. I do not mind if the memory
> is presented as a hotplugable cpuless memory node. I just do not want it
> to be any more special than cpuless nodes are already.

The downsides being code complexity/run time overhead? Like Ben stated
there are several devices that will also have coherent memory, do you see all of
them abstracted as HMM-CDM?

> 
> > > So let me repeat the fundamental question. Is the only difference from
> > > cpuless nodes the fact that the node should be invisible to processes
> > > unless they specify an explicit node mask?
> > 
> > It would be *preferable* that it is.
> > 
> > It's not necessarily an absolute requirement as long as what lands
> > there can be kicked out. However the system would potentially be
> > performing poorly if too much unrelated stuff lands on the GPU memory
> > as it has a much higher latency.
> 
> This is a general concern for many cpuless NUMA node systems. You have
> to pay for the suboptimal performance when accessing that memory. And
> you have means to cope with that.
> 

How do we evolve the NUMA subsystem to deal with additional requirements?
Do we not enhance NUMA and move to ZONE_DEVICE?

> > Due to the nature of GPUs (and possibly other such accelerators but not
> > necessarily all of them), that memory is also more likely to fail. GPUs
> > crash often. However that isn't necessarily true of OpenCAPI devices or
> > CCIX.
> > 
> > This is the kind of attributes of the memory (quality ?) that can be
> > provided by the driver that is putting it online. We can then
> > orthogonally decide how we chose (or not) to take those into account,
> > either in the default mm algorithms or from explicit policy mechanisms
> > set from userspace, but the latter is often awkward and never done
> > right.
> 
> The first adds maintain costs all over the place and just looking at
> what become of memory policies and cpusets makes me cry. I definitely do
> not want more special casing on top (and just to make it clear a special
> N_MEMORY_$FOO falls into the same category).
> 

And I thought it was cleaner design, yes we have been special casing some
of the N_COHERENT_MEMORY bits in mm/mempolicy.c. 

> [...]
> > > Moreover cpusets already support exclusive numa nodes AFAIR.
> > 
> > Which implies that the user would have to do epxlciit cpuset
> > manipulations for the system to work right ? Most user wouldn't and the
> > rsult is that most user would have badly working systems. That's almost
> > always what happens when we chose to bounce *all* policy decision to
> > the user without the kernel attempting to have some kind of semi-sane
> > default.
> 
> I would argue that this is the case for cpuless numa nodes already.
> Users should better know what they are doing when using such a
> specialized HW. And that includes a specialized configuration.
>

Like Ben said intimate knowledge of using specialized hardware
is an unfair assumption. It sounds like the decision then is that
we do HMM-CDM or live with cpuless nodes without enhancements?

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
