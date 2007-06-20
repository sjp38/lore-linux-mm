Date: Wed, 20 Jun 2007 09:51:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Some thoughts on memory policies
In-Reply-To: <p73lkeerep2.fsf@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0706200940550.22446@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706181257010.13154@schroedinger.engr.sgi.com>
 <p73lkeerep2.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, wli@holomorphy.com, lee.schermerhorn@hp.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jun 2007, Andi Kleen wrote:

> > - Device drivers may need to control memory allocations in
> >   devices either because their DMA engines can only reach a
> >   subsection of the system
> 
> On what system does this happen? Not sure you can call that
> a "coherent system"

This is an issue for example on DSM systems where memory is virtualized by 
transferring pages of memory on request. We are also getting into embedded 
systems using NUMA for a variety of reason. Devices that can only reach
a subset of memory may come about there.

> > or because memory transfer
> >   performance is superior in certain nodes of the system.
> 
> Most architectures already give a sensible default for the coherent DMA
> mappings (node the device is attached to) For the others it is
> really not under driver control.

Yes I did some of that work. But that is still from the perspective of the 
system as a whole. A device may have unique locality requirements. F.e. it 
may be able to interweave memory transfers from multiple nodes for optimal 
performance.

> Also controlling from the device where the submitted
> data is difficult unless you bind processes. If you do 
> it just works, but if you don't want to (for most cases
> explicit binding is bad) it is hard.

It wont be difficult if the device has

1. A node number
2. An allocation policy

Then the allocation must be done as if we would be on that node.

> I would be definitely opposed to anything that exposes
> addresses as user interface.

Well its more the device driver telling the system where the stuff ought 
to be best located.

> > 2. Memory policies need to support additional constraints
> > 
> > - Restriction to a set of nodes. That is what we have today.
> > 
> > - Restriction to a container or cpuset. Maybe restriction
> >   to a set of containers?
> 
> Why?

Because the sysadmin can set the containers up in a flexible way. Maybe we 
want to segment a node into a couple of 100MB chunks and give various apps
access to it?

> > - Strict vs no strict allocations. A strict allocation needs
> >   to fail if the constraints cannot be met. A non strict
> >   allocation can fall back.
> 
> That's already there -- that's the difference between PREFERED
> and BIND.

But its not available for interleave f.e.

> Regarding your page cache proposal: I think it's a bad
> idea, larger soft page sizes would be better.

I am not sure what you are talking about.

> > The esoteric
> > nature of memory policy semantics makes them difficult to comprehend.
> 
> Exactly.  It doesn't make sense to implement if you can't
> give it a good interface.

Right we need a clean interface and something that works in such a way 
that people can understand it. The challenge is to boil down something 
complex to a few simple mechanisms.
 
> > 7. Allocators must change
> > 
> > Right now the policy is set by the process context which is bad because
> > one cannot specify a memory policy for an allocation. It must be possible
> > to pass a memory policy to the allocators and then get the memory 
> > requested.
> 
> We already can allocate on a node. If there is really demand
> we could also expose interleaved allocations, but again
> we would need a good user.

We have these bad hacks for shmem and for hugetlb where we have to set 
policies in the context by creating a fake vma in order to get policy 
applied.

If we want to allocate for a device then the device is the context and not 
the process, same thing for shmem and hugetlb.
 
> Not sure it is useful for sl[aou]b.

If we do this then it needs to be consistently supported by the 
allocators. Meaning the slab allocators would have to support a call where 
you can pass a policy in and then objects need to be served in conformity 
with that policy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
