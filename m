Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 40D702806D7
	for <linux-mm@kvack.org>; Tue,  9 May 2017 09:43:14 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id g12so42061394uab.10
        for <linux-mm@kvack.org>; Tue, 09 May 2017 06:43:14 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id z63si24480vkg.199.2017.05.09.06.43.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 May 2017 06:43:13 -0700 (PDT)
Message-ID: <1494337392.25766.446.camel@kernel.crashing.org>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 09 May 2017 15:43:12 +0200
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
To: Michal Hocko <mhocko@suse.com>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Tue, 2017-05-09 at 13:36 +0200, Michal Hocko wrote:
> But this is not what the CDM as proposed here is about AFAIU. It is
> argued this is not a _normal_ cpuless node and it neads tweak here and
> there. And that is my main objection about. I do not mind if the memory
> is presented as a hotplugable cpuless memory node. I just do not want it
> to be any more special than cpuless nodes are already.

But if you look at where things are going with the new kind of memory
technologies appearing etc... I think the concept of "normal" for
memory is rather fragile.

So I think it makes sense to grow the idea that nodes have "attributes"
that affect the memory policies.

That said, one thing we do need to clarify, especially in the context
of our short term GPU usage model, is of those attributes, what is
inherent to the way the HW works and what is more related to the actual
userspace usage model, the latter possibly being better dealt with with
existing policy mechanisms).

Also maybe understand how much of these things are likely to be shared
with other type of devices such as OpenCAPI or CCIX.

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

Yup. However in this case, GPU memory is really bad, so that's one
reason why we want to push the idea of effectively not allowing non-
explicit allocations from it.

Thus, memory would be allocated from that node only if either the
application (or driver) use explicit APIs to grab some of it, or if the
driver migrates pages to it. (Or possibly, if we can make that work,
the memory is provisioned as the result of a page fault by the GPU
itself).

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

So what you are saying is that users who want to use GPUs or FPGAs or
accelerated devices will need to have intimate knowledge of Linux CPU
and memory policy management at a low level.

That's where I disagree.

People want to throw these things at all sort of problems out there,
hide them behind libraries, and have things "just work".

The user will just use applications normally. Those will be use
more/less standard libraries to perform various computations, these
libraries will know how to take advantage of accelerators, nothing in
that chains knows about memory policies & placement, cpusets etc... and
nothing *should*.

Of course, the special case of the HPC user trying to milk the last
cycle out of the system is probably going to do what you suggest. But
most users won't.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
