Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC5CB6B03E3
	for <linux-mm@kvack.org>; Tue,  9 May 2017 03:51:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l64so52063397pfb.14
        for <linux-mm@kvack.org>; Tue, 09 May 2017 00:51:38 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id l16si12195353pgn.17.2017.05.09.00.51.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 00:51:37 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id i63so14057208pgd.2
        for <linux-mm@kvack.org>; Tue, 09 May 2017 00:51:37 -0700 (PDT)
Message-ID: <1494316289.14525.1.camel@gmail.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 09 May 2017 17:51:29 +1000
In-Reply-To: <20170505145238.GE31461@dhcp22.suse.cz>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <20170502143608.GM14593@dhcp22.suse.cz> <1493875615.7934.1.camel@gmail.com>
	 <20170504125250.GH31540@dhcp22.suse.cz>
	 <1493912961.25766.379.camel@kernel.crashing.org>
	 <20170505145238.GE31461@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz, cl@linux.com

On Fri, 2017-05-05 at 16:52 +0200, Michal Hocko wrote:
> On Thu 04-05-17 17:49:21, Benjamin Herrenschmidt wrote:
> > On Thu, 2017-05-04 at 14:52 +0200, Michal Hocko wrote:
> > > But the direct reclaim would be effective only _after_ all other nodes
> > > are full.
> > > 
> > > I thought that kswapd reclaim is a problem because the HW doesn't
> > > support aging properly but as the direct reclaim works then what is the
> > > actual problem?
> > 
> > Ageing isn't isn't completely broken. The ATS MMU supports
> > dirty/accessed just fine.
> > 
> > However the TLB invalidations are quite expensive with a GPU so too
> > much harvesting is detrimental, and the GPU tends to check pages out
> > using a special "read with intend to write" mode, which means it almost
> > always set the dirty bit if the page is writable to begin with.
> 
> This sounds pretty much like a HW specific details which is not the
> right criterion to design general CDM around.

I think Ben answered several of these questions. NUMA we felt was the best
representation of such memory, but it has limitations in that we'd like
to isolate some default algorithms that run on all nodes marked N_MEMORY.
Do you see that as a concern? Would you like to see a generic policy
like Ben said to handle node attributes like reclaim, autonuma, etc?

> 
> So let me repeat the fundamental question. Is the only difference from
> cpuless nodes the fact that the node should be invisible to processes
> unless they specify an explicit node mask? If yes then we are talking
> about policy in the kernel and that sounds like a big no-no to me.
> Moreover cpusets already support exclusive numa nodes AFAIR.

Why do you see this as a policy, it's a mechanism of isolating nodes,
the nodes themselves are then used using mempolicy.

> 
> I am either missing something important here, and the discussion so far
> hasn't helped to be honest, or this whole CDM effort tries to build a
> generic interface around a _specific_ piece of HW. The matter is worse
> by the fact that the described usecases are so vague that it is hard to
> build a good picture whether this is generic enough that a new/different
> HW will still fit into this picture.

The use case is similar to HMM, except that we've got coherent memory.
We treat is as important and want to isolate normal allocations, unless
the allocation is explicitly specified. CPUsets provide an isolation
mechanism, but we see autonuma for example moving pages away when there
is an access from the system side. With reclaim, it would be better to
use the fallback list first then swap. Again the use case is:

I'm trying to do a FAQ version here

Isolate memory - why?
 - CDM memory is not meant for normal usage, applications can request for it
   explictly. Oflload their compute to the device where the memory is
   (the offload is via a user space API like CUDA/openCL/...)
How do we isolate - NUMA or HMM?
 - Since the memory is coherent, NUMA provides the mechanism to isolate to
   a large extent via mempolicy. With NUMA we also get autonuma/kswapd/etc
   running. Something we would like to avoid. NUMA gives the application
   a transparent view of memory, in the sense that all mm features work,
   like direct page cache allocation in coherent device memory, limiting
   memory via cgroups if required, etc. With CPUSets, its
   possible for us to isolate allocation. One challenge is that the
   admin on the system may use them differently and applications need to
   be aware of running in the right cpuset to allocate memory from the
   CDM node. Putting all applications in the cpuset with the CDM node is
   not the right thing to do, which means the application needs to move itself
   to the right cpuset before requesting for CDM memory. It's not impossible
   to use CPUsets, just hard to configure correctly.
  - With HMM, we would need a HMM variant HMM-CDM, so that we are not marking
   the pages as unavailable, page cache cannot do directly to coherent memory.
   Audit of mm paths is required. Most of the other things should work.
   User access to HMM-CDM memory behind ZONE_DEVICE is via a device driver.
Why do we need migration?
 - Depending on where the memory is being accessed from, we would like to
   migrate pages between system and coherent device memory. HMM provides
   DMA offload capability that is useful in both cases.
What is the larger picture - end to end?
 - Applications can allocate memory on the device or in system memory,
   offload the compute via user space API. Migration can be used for performance
   if required since it helps to keep the memory local to the compute.

Ben/Jerome/John/others did I get the FAQ right?

>From my side, I want to ensure that the decision HMM-CDM or NUMA-CDM is based
on our design and understanding, as opposed to the reason that the
use case is not clear or in sufficient. I'd be happy if we said, we understand
the use case and believe that HMM-CDM is better from the mm's perspective as
its better because... as opposed to isolating NUMA attributes because .... 
or vice-versa.

Thanks for the review,
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
