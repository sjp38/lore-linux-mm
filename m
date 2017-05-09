Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02AB7280401
	for <linux-mm@kvack.org>; Tue,  9 May 2017 07:36:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p62so18963318wrc.13
        for <linux-mm@kvack.org>; Tue, 09 May 2017 04:36:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a197si12887677wma.151.2017.05.09.04.36.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 04:36:41 -0700 (PDT)
Date: Tue, 9 May 2017 13:36:38 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
Message-ID: <20170509113638.GJ6481@dhcp22.suse.cz>
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <20170502143608.GM14593@dhcp22.suse.cz>
 <1493875615.7934.1.camel@gmail.com>
 <20170504125250.GH31540@dhcp22.suse.cz>
 <1493912961.25766.379.camel@kernel.crashing.org>
 <20170505145238.GE31461@dhcp22.suse.cz>
 <1493999822.25766.397.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1493999822.25766.397.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Fri 05-05-17 17:57:02, Benjamin Herrenschmidt wrote:
> On Fri, 2017-05-05 at 16:52 +0200, Michal Hocko wrote:
> > 
> > This sounds pretty much like a HW specific details which is not the
> > right criterion to design general CDM around.
> 
> Which is why I don't see what's the problem with simply making this
> a hot-plugged NUMA node, since it's basically what it is with a
> "different" kind of CPU, possibly covered with a CMA, which provides
> both some isolation and the ability to do large physical allocations
> for applications who chose to use the legacy programming interfaces and
> manually control the memory.
> 
> Then, the "issues" with things like reclaim, autonuma can be handled
> with policy tunables. Possibly node attributes.
> 
> It seems to me that such a model fits well in the picture where we are
> heading not just with GPUs, but with OpenCAPI based memory, CCIX or
> other similar technologies that can provide memory possibly with co-
> located acceleration devices.
> 
> It also mostly already just work.

But this is not what the CDM as proposed here is about AFAIU. It is
argued this is not a _normal_ cpuless node and it neads tweak here and
there. And that is my main objection about. I do not mind if the memory
is presented as a hotplugable cpuless memory node. I just do not want it
to be any more special than cpuless nodes are already.

> > So let me repeat the fundamental question. Is the only difference from
> > cpuless nodes the fact that the node should be invisible to processes
> > unless they specify an explicit node mask?
> 
> It would be *preferable* that it is.
> 
> It's not necessarily an absolute requirement as long as what lands
> there can be kicked out. However the system would potentially be
> performing poorly if too much unrelated stuff lands on the GPU memory
> as it has a much higher latency.

This is a general concern for many cpuless NUMA node systems. You have
to pay for the suboptimal performance when accessing that memory. And
you have means to cope with that.

> Due to the nature of GPUs (and possibly other such accelerators but not
> necessarily all of them), that memory is also more likely to fail. GPUs
> crash often. However that isn't necessarily true of OpenCAPI devices or
> CCIX.
> 
> This is the kind of attributes of the memory (quality ?) that can be
> provided by the driver that is putting it online. We can then
> orthogonally decide how we chose (or not) to take those into account,
> either in the default mm algorithms or from explicit policy mechanisms
> set from userspace, but the latter is often awkward and never done
> right.

The first adds maintain costs all over the place and just looking at
what become of memory policies and cpusets makes me cry. I definitely do
not want more special casing on top (and just to make it clear a special
N_MEMORY_$FOO falls into the same category).

[...]
> > Moreover cpusets already support exclusive numa nodes AFAIR.
> 
> Which implies that the user would have to do epxlciit cpuset
> manipulations for the system to work right ? Most user wouldn't and the
> rsult is that most user would have badly working systems. That's almost
> always what happens when we chose to bounce *all* policy decision to
> the user without the kernel attempting to have some kind of semi-sane
> default.

I would argue that this is the case for cpuless numa nodes already.
Users should better know what they are doing when using such a
specialized HW. And that includes a specialized configuration.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
