Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18F096B0038
	for <linux-mm@kvack.org>; Sun, 23 Apr 2017 20:20:53 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 194so204262758iof.21
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 17:20:53 -0700 (PDT)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id o80si9336974ito.126.2017.04.23.17.20.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Apr 2017 17:20:52 -0700 (PDT)
Received: by mail-it0-x241.google.com with SMTP id e132so12344756ite.2
        for <linux-mm@kvack.org>; Sun, 23 Apr 2017 17:20:51 -0700 (PDT)
Message-ID: <1492993241.2418.2.camel@gmail.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 24 Apr 2017 10:20:41 +1000
In-Reply-To: <alpine.DEB.2.20.1704201025360.26403@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org>
	 <1492651508.1015.2.camel@gmail.com>
	 <alpine.DEB.2.20.1704201025360.26403@east.gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Thu, 2017-04-20 at 10:29 -0500, Christoph Lameter wrote:
> On Thu, 20 Apr 2017, Balbir Singh wrote:
> > Couple of things are needed
> > 
> > 1. Isolation of allocation
> 
> cgroups, memory policy and cpuset provide that
> 

Yes and we are building on top of mempolicies. The problem becomes a little
worse when the coherent device memory node is seen as CPUless node. I
was trying to solve 1 and 2 with the same approach.

> > 2. Isolation of certain algorithms like kswapd/auto-numa balancing
> 
> Ok that may mean adding some generic functionality to limit those

As in per-algorithm tunables? I think it would be definitely good to have
that. I do not know how well that would scale?

> 
> > > The approach sounds pretty invasive to me.
> > 
> > Could you please elaborate, you mean the user space programming bits?
> 
> No I mean the modification of the memory policies in particular. We are
> adding more exceptions to an already complex and fragile system.
> 
> Can we do this in a generic way just using hotplug nodes and some of the
> existing isolation mechanisms?
>

Yes, that was the first approach we tried and we are reusing whatever
we can -- HMM for driver driven migration, mempolicies for allocation
control and N_COHERENT_MEMORY for isolation because of 1 and 2 above
combined.
 
> 
> > Ideally we need the following:
> > 
> > 1. Transparency about being able to allocate memory anywhere and the ability
> > to migrate memory between coherent device memory and normal system memory
> 
> If it is a memory node then you have that already.
> 
> > 2. The ability to explictly allocate memory from coherent device memory
> 
> Ditto
> 
> > 3. Isolation of normal allocations from coherent device memory unless
> > explictly stated, same as (2) above
> 
> memory policies etc do that.
> 
> > 4. The ability to hotplug in and out the memory at run-time
> 
> hotplug code does that.
> 
> 
> > 5. Exchange pointers between coherent device memory and normal memory
> > for the compute on the coherent device memory to use

> 
> I dont see anything preventing that from occurring right now. Thats a
> device issue with doing proper virtual to physical mapping right?
> 

Some of these requirements come from whether we use NUMA or HMM-CDM.
We prefer NUMA and it meets the above requirements quite well.

> > I could list further things, but largely coherent device memory is like
> > system memory except that we believe that things like auto-numa balancing
> > and kswapd will not work well due to lack of information about references
> > and faults.
> 
> Ok so far I do not see that we need coherent nodes at all.
>

I presume you are suggesting this based on the fact that we add additional
infrastructure for auto-numa/kswapd/etc isolation?
 
> > Some of the mm-summit notes are at https://lwn.net/Articles/717601/
> > The goals align with HMM, except that the device memory is coherent. HMM
> > has a CDM variation as well.
> 
> I was at the presentation but at that point you were interested in a
> different approach it seems.

I do remember you were present, I don't think things have changed since then.

> 
> > We've been using the term coherent device memory (CDM). I could rephrase the
> > text and documentation for consistency. Would you prefer a different term?
> 
> Hotplug memory node?
> 

Normal memory is hotpluggable too.. but I'd be fine as long as everyone agrees

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
