Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 525116B03A6
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 21:25:19 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p80so49943292iop.16
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 18:25:19 -0700 (PDT)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id c131si5105455ioe.115.2017.04.19.18.25.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Apr 2017 18:25:18 -0700 (PDT)
Received: by mail-io0-x22e.google.com with SMTP id k87so46898946ioi.0
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 18:25:18 -0700 (PDT)
Message-ID: <1492651508.1015.2.camel@gmail.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Balbir Singh <bsingharora@gmail.com>
Date: Thu, 20 Apr 2017 11:25:08 +1000
In-Reply-To: <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Wed, 2017-04-19 at 14:02 -0500, Christoph Lameter wrote:
> On Wed, 19 Apr 2017, Balbir Singh wrote:
> 
> > The first patch defines N_COHERENT_MEMORY and supports onlining of
> > N_COHERENT_MEMORY.  The second one enables marking of coherent
> 
> The name is confusing. All other NUMA nodes are coherent. Can we name this
> in some way that describes what is special about these nodes?
> 
> And we already have support for memory only nodes. Why is that not sufficient?
> If you can answer that question then we may get to the term to be used to
> name these nodes. We also have support for hotplug memory. How does the
> memory here differ from hotplug?
> 
>  > memory nodes in architecture specific code, the third patch
> > enables mempolicy MPOL_BIND and MPOL_PREFERRED changes to
> > explicitly specify a node for allocation. The fourth patch adds
> 
> Huh? MPOL_PREFERRED already allows specifying a node.
> MPOL_BIND requires a set of nodes. ??

Wording issues, I meant to support specification of the coherent
memory node for specification.

> 
> > 1. Nodes with N_COHERENT_MEMORY don't have CPUs on them, so
> > effectively they are CPUless memory nodes
> > 2. Nodes with N_COHERENT_MEMORY are marked as movable_nodes.
> > Slub allocations from these nodes will fail otherwise.
> 
> Isnt that what hotpluggable nodes do already?

Yes, we need that coherent device memory as well.

> 
> > 1. MPOL_BIND with the coherent node (Node 3 in the above example) will
> > not filter out N_COHERENT_MEMORY if any of the nodes in the nodemask
> > is in N_COHERENT_MEMORY
> > 2. MPOL_PREFERRED will use the FALLBACK list of the coherent node (Node 3)
> > if a policy that specifies a preference to it is used.
> 
> So this means that "Coherent" nodes means that you need a different
> fallback mechanism? Something like a ISOLATED_NODE or something?

Couple of things are needed

1. Isolation of allocation
2. Isolation of certain algorithms like kswapd/auto-numa balancing

There are some notes of (2) in hte limitations seciton as well.

> 
> The approach sounds pretty invasive to me.

Could you please elaborate, you mean the user space programming bits?


 Can we first clarify what
> features you need and develop terminology that describes things in terms
> of a view from the Linux MM perspective?

Ideally we need the following:

1. Transparency about being able to allocate memory anywhere and the ability
to migrate memory between coherent device memory and normal system memory
2. The ability to explictly allocate memory from coherent device memory
3. Isolation of normal allocations from coherent device memory unless
explictly stated, same as (2) above
4. The ability to hotplug in and out the memory at run-time
5. Exchange pointers between coherent device memory and normal memory
for the compute on the coherent device memory to use

I could list further things, but largely coherent device memory is like
system memory except that we believe that things like auto-numa balancing
and kswapd will not work well due to lack of information about references
and faults.

Some of the mm-summit notes are at https://lwn.net/Articles/717601/
The goals align with HMM, except that the device memory is coherent. HMM
has a CDM variation as well.

 Coherent memory is nothing
> special from there. It is special from the perspective of offload devices
> that have heretofore not offered that. So its mainly a marketing term. We
> need something descriptive here.
> 

We've been using the term coherent device memory (CDM). I could rephrase the
text and documentation for consistency. Would you prefer a different term?

Thanks for the review!
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
