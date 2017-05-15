Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B2CC76B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 08:55:37 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b74so69433791pfd.2
        for <linux-mm@kvack.org>; Mon, 15 May 2017 05:55:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p71si10713920pfj.351.2017.05.15.05.55.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 May 2017 05:55:36 -0700 (PDT)
Date: Mon, 15 May 2017 14:55:31 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
Message-ID: <20170515125530.GH6056@dhcp22.suse.cz>
References: <20170419075242.29929-1-bsingharora@gmail.com>
 <20170502143608.GM14593@dhcp22.suse.cz>
 <1493875615.7934.1.camel@gmail.com>
 <20170504125250.GH31540@dhcp22.suse.cz>
 <1493912961.25766.379.camel@kernel.crashing.org>
 <20170505145238.GE31461@dhcp22.suse.cz>
 <1493999822.25766.397.camel@kernel.crashing.org>
 <20170509113638.GJ6481@dhcp22.suse.cz>
 <1494337392.25766.446.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494337392.25766.446.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

[Ups, for some reason this got stuck in my draft folder and didn't get
send out]

On Tue 09-05-17 15:43:12, Benjamin Herrenschmidt wrote:
> On Tue, 2017-05-09 at 13:36 +0200, Michal Hocko wrote:
> > But this is not what the CDM as proposed here is about AFAIU. It is
> > argued this is not a _normal_ cpuless node and it neads tweak here and
> > there. And that is my main objection about. I do not mind if the memory
> > is presented as a hotplugable cpuless memory node. I just do not want it
> > to be any more special than cpuless nodes are already.
> 
> But if you look at where things are going with the new kind of memory
> technologies appearing etc... I think the concept of "normal" for
> memory is rather fragile.
> 
> So I think it makes sense to grow the idea that nodes have "attributes"
> that affect the memory policies.

I am not really sure our current API fits into such a world and a change
would require much deeper consideration.

[...]
> > This is a general concern for many cpuless NUMA node systems. You have
> > to pay for the suboptimal performance when accessing that memory. And
> > you have means to cope with that.
> 
> Yup. However in this case, GPU memory is really bad, so that's one
> reason why we want to push the idea of effectively not allowing non-
> explicit allocations from it.

I would argue that a cpuless node with a NUMA distance larger than a
certain threshold falls pretty much into the same category.

> Thus, memory would be allocated from that node only if either the
> application (or driver) use explicit APIs to grab some of it, or if the
> driver migrates pages to it. (Or possibly, if we can make that work,
> the memory is provisioned as the result of a page fault by the GPU
> itself).

That sounds like HMM to me.
 
[...]
> > I would argue that this is the case for cpuless numa nodes already.
> > Users should better know what they are doing when using such a
> > specialized HW. And that includes a specialized configuration.
> 
> So what you are saying is that users who want to use GPUs or FPGAs or
> accelerated devices will need to have intimate knowledge of Linux CPU
> and memory policy management at a low level.

No, I am not saying that. I am saying that if you want to use GPU/FPGAs
and what-not effectivelly you will most likely have to do additional
steps anyway.

> That's where I disagree.
> 
> People want to throw these things at all sort of problems out there,
> hide them behind libraries, and have things "just work".
> 
> The user will just use applications normally. Those will be use
> more/less standard libraries to perform various computations, these
> libraries will know how to take advantage of accelerators, nothing in
> that chains knows about memory policies & placement, cpusets etc... and
> nothing *should*.

With the proposed solution, they would need to set up mempolicy/cpuset
so I must be missing something here...

> Of course, the special case of the HPC user trying to milk the last
> cycle out of the system is probably going to do what you suggest. But
> most users won't.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
