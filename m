Date: Mon, 14 Nov 2005 11:08:37 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] Make the slab allocator observe NUMA policies
In-Reply-To: <200511141944.33478.ak@suse.de>
Message-ID: <Pine.LNX.4.62.0511141055560.1222@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com>
 <200511131222.48690.ak@suse.de> <Pine.LNX.4.62.0511141002050.353@schroedinger.engr.sgi.com>
 <200511141944.33478.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Mon, 14 Nov 2005, Andi Kleen wrote:

> > Any idea how to push this to the page allocation within the slab without 
> > rearchitecting the thing?
> 
> I believe that's only a small fraction of the allocations, for where
> the slabs are big enough to be an significant part of the page.
> 
> Proof: VM breaks down with higher orders. If slab would use them
> all the time it would break down too. It doesn't. Q.E.D ;-)

Yes the higher order pages are rare. However, regular sized pages are 
frequent and the allocations for these pages always consult 
task->mempolicy.

> Another way (as a backup option) would be to RR them as higher order pages, 
> but that would need new special code.

The proposed patch RRs higher order pages as configured by the memory 
policy.

The other fundamental problem that I mentioned remains: 

The slab allocator is designed in such a way that it needs to know the 
node for the allocation before it does its work. This is because the 
nodelists are per node since 2.6.14. You wanted to do the policy 
application on the back end so after all the work is done (presumably 
for the current node) and after the node specific lists have been 
examined. Policy application at that point may find that another
node than the current node was desired and the whole thing has to be 
redone for the other node. This will significantly negatively impact
the performance of the slab allocator in particular if the current node
is is unlikely to be chosen for the memory policy.

I have thought about various ways to modify kmem_getpages() but these do 
not fit into the basic current concept of the slab allocator. The 
proposed method is the cleanest approach that I can think of. I'd be glad 
if you could come up with something different but AFAIK simply moving the 
policy application down in the slab allocator does not work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
