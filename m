Received: from e3.ny.us.ibm.com (s3 [10.0.3.103])
	by admin.ny.us.ibm.com. (8.9.3/8.9.3) with ESMTP id PAA31382
	for <linux-mm@kvack.org>; Wed, 26 Apr 2000 15:14:52 -0400
From: frankeh@us.ibm.com
Message-ID: <852568CD.00695B9D.00@D51MTA07.pok.ibm.com>
Date: Wed, 26 Apr 2000 15:06:09 -0400
Subject: Re: 2.3.x mem balancing
Mime-Version: 1.0
Content-type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Mark_H_Johnson.RTS@raytheon.com, linux-mm@kvack.org, riel@nl.linux.org, Linus Torvalds <torvalds@transmeta.com>, pratap@us.ibm.com
List-ID: <linux-mm.kvack.org>

Kanoj, this is the issue I raised earlier on the board, but didn't get a
reply...

Yes, one NUMA machine here at IBM research consists of a 4-node cluster of
4-way xeon boxes.
When NUMA-d together, each memory controller simply relocates its own node
memory to
a designated 1-GB range and forwards other requests to the appropriate
nodes while maintaining cache coherence.

This ofcourse leads to the situation, that only the first node will have
DMA memory, given the 1GB kernel limitation.

I used to have  a software solution to this namely by rewritting the __pa
and __va macros to do some remapping
which would allow each node to provide some kernel virtual DMA memory.

Now how do you believe the architectures (particular x86 based NUMA
systems) will evolve ?

As with respect to some other messages regarding the zones.

With respect to NUMA allocation, I still like to see happening what was
pointed out for the IRIX and which is for instance
also available on NUMAQ/Dynix as well. Namely resource classes.

A resource class to be a set of basic resources such as (CPUs and memory,
i.e nodes) on which to restrict execution and allocation for user processes

(a) we have a full CPU affinity patch, driven by a system call interface
that restricts execution to a set of specified CPUs     .. any takers ...

(b) kanoj and I made a first attempt (~2.3.48 timeframe) to restrict
allocation to certain nodes, but the swapping behavior never properly
worked and with
     the constant changes under 2.3.99-preX, I put this on ice until the vm
becomes somewhat more stable.
    Again, I want to specify a set of nodes from where to allocate memory .
   Given a node set specification, I would like to treat the zones of the
same class on all those specified nodes (e.g. ZONE_HIGH) as a single target
class. Only if it can not allocate within that combined class  on the
specified set of nodes, should the allocator decent into the next lower
class.

   Open ofcourse in this spec is what will be effected by the memory
specification ??? only user pages, or pages that go to memory mapped files
as well?






kanoj@google.engr.sgi.com (Kanoj Sarcar) on 04/26/2000 01:36:48 PM

To:   andrea@suse.de (Andrea Arcangeli)
cc:   Mark_H_Johnson.RTS@raytheon.com, linux-mm@kvack.org,
      riel@nl.linux.org, torvalds@transmeta.com (Linus Torvalds)
Subject:  Re: 2.3.x mem balancing




>
> On NUMA hardware you have only one zone per node since nobody uses
ISA-DMA
> on such machines and you have PCI64 or you can use the PCI-DMA sg for
> PCI32. So on NUMA hardware you are going to have only one zone per node
> (at least this was the setup of the NUMA machine I was playing with). So
> you don't mind at all about classzone/zone. Classzone and zone are the
> same thing in such a setup, they both are the plain ZONE_DMA zone_t.
> Finished. Said that you don't care anymore about the changes of how the
> overlapped zones are handled since you don't have overlapped zones in
> first place.

Andrea, are you talking about the SGI Origin platform, or are you
using some other NUMA platform? In any case, the SGI platform in fact
does not support ISA-DMA, but unfortunately, I don't think just because
it has PCI mapping registers, you can assume that all memory is DMAable.
For us to be able to consider all memory as dmaable, before each dma
operation starts, we need to have a pci-dma type hook to program the
mapping registers. As far as I know, such a hook is not used on all
drivers (in 2.4 timeframe), so very unfortunately, I think we need
to keep the option open about each node having more than just ZONE_DMA.
Finally, I am not sure how things will work, we are still busy trying
to get the Origin/Linux port going.

FWIW, I think the IBM/Sequent NUMA machines in fact have nodes that
have only nondmaable memory.

>
> If you move the NUMA balancing and node selection into the higher layer
> as I was proposing, instead you can do clever things.
>

For an example and a (old) patch for this, look at

     http://oss.sgi.com/projects/numa/download/numa.gen.42b
     http://oss.sgi.com/projects/numa/download/numa.plat.42b

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
