Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31A026B02E1
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 20:52:57 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m132so78528824ith.12
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 17:52:57 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id b7si1277650ith.95.2017.04.24.17.52.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 17:52:56 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id v1so327277pgv.3
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 17:52:56 -0700 (PDT)
Message-ID: <1493081565.21623.5.camel@gmail.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 25 Apr 2017 10:52:45 +1000
In-Reply-To: <alpine.DEB.2.20.1704240858410.15223@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org>
	 <1492651508.1015.2.camel@gmail.com>
	 <alpine.DEB.2.20.1704201025360.26403@east.gentwo.org>
	 <1492993241.2418.2.camel@gmail.com>
	 <alpine.DEB.2.20.1704240858410.15223@east.gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Mon, 2017-04-24 at 09:00 -0500, Christoph Lameter wrote:
> On Mon, 24 Apr 2017, Balbir Singh wrote:
> 
> > > cgroups, memory policy and cpuset provide that
> > > 
> > 
> > Yes and we are building on top of mempolicies. The problem becomes a little
> > worse when the coherent device memory node is seen as CPUless node. I
> > was trying to solve 1 and 2 with the same approach.
> 
> Well I think having the ability to restrict autonuma/ksm per node may also
> be useful for other things. Like running regular processes on node 0 and
> running low latency stuff on  node 1 that should not be interrupted. Right
> now you cannot do that.
> 

I presume it also means differential allocation (applications allocating
on this node will be different) and isolation of allocation. Would you like
to restrict allocations from nodes? The one difference we have is that
coherent device memory has

a. Probably a compute on them which is not visible directly to the system
b. Shows up as a CPUless node

>From a solutioning perspective, today all these daemons work off of
N_MEMORY, without going to deep and speculating, one approach could
be to create N_ISOLATED_MEMORY with tunables for each set of algorithms

I did a quick grep and got the following list of N_MEMORY dependent
code paths

1. kcompactd
2. bootmem huge pages
3. memcg reclaim (soft limit)
4. mempolicy
5. migrate
6. kswapd

Which reminds that I should fix 5 in my patchset :). For KSM I found
merge_across_nodes, I presume some of the isolation across nodes can be
achieved using it and then by applications not using madvise MADV_MERGEABLE?

Would N_COHERENT_MEMORY meet your needs? May be we could call it
N_ISOLATED_MEMORY and then add tunables per-algorithm?



> > > > 2. Isolation of certain algorithms like kswapd/auto-numa balancing
> > > 
> > > Ok that may mean adding some generic functionality to limit those
> > 
> > As in per-algorithm tunables? I think it would be definitely good to have
> > that. I do not know how well that would scale?
> 
> From what I can see it should not be too difficult to implement a node
> mask constraining those activities.
> 
> > Some of these requirements come from whether we use NUMA or HMM-CDM.
> > We prefer NUMA and it meets the above requirements quite well.
> 
> Great.
>

Thanks

Balbir Singh. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
