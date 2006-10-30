Date: Mon, 30 Oct 2006 08:41:24 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <4544914F.3000502@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0610300825020.20524@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610161744140.10698@schroedinger.engr.sgi.com>
 <20061017102737.14524481.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0610161824440.10835@schroedinger.engr.sgi.com>
 <45347288.6040808@yahoo.com.au> <Pine.LNX.4.64.0610171053090.13792@schroedinger.engr.sgi.com>
 <45360CD7.6060202@yahoo.com.au> <20061018123840.a67e6a44.akpm@osdl.org>
 <Pine.LNX.4.64.0610231606570.960@schroedinger.engr.sgi.com>
 <20061026150938.bdf9d812.akpm@osdl.org> <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <20061027190452.6ff86cae.akpm@osdl.org> <Pine.LNX.4.64.0610271907400.10615@schroedinger.engr.sgi.com>
 <20061027192429.42bb4be4.akpm@osdl.org> <Pine.LNX.4.64.0610271926370.10742@schroedinger.engr.sgi.com>
 <20061027214324.4f80e992.akpm@osdl.org> <Pine.LNX.4.64.0610281743260.14058@schroedinger.engr.sgi.com>
 <20061028180402.7c3e6ad8.akpm@osdl.org> <Pine.LNX.4.64.0610281805280.14100@schroedinger.engr.sgi.com>
 <4544914F.3000502@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 29 Oct 2006, Nick Piggin wrote:

> > 1. Duplicate the caches (pageset structures). This reduces cache hit
> > rates. Duplicates lots of information in the page allocator.
> 
> You would have to do the same thing to get an O(1) per-CPU allocation
> for a specific zone/reclaim type/etc regardless whether or not you use
> zones.

Duplicate caches reduce the hitrate of the cache and if there are 
fluctuating usage scenarios then the cache may run cold,

> > 2. Necessity of additional load balancing across multiple zones.
> 
> a. we have to do this anyway for eg. dma32 and NUMA, and b. it is much
> better than the highmem problem was because all the memory is kernel
> addressable.

Yes we have that but this is going to be more complex in the future if we 
add additional zones. We dont need it with a single zone.

> If you use another scheme (eg. lists within zones within nodes, rather
> than just more zones within nodes), then you still fundamentally have
> to balance somehow.

The single zone scheme does not need this.

> > 3. The NUMA layer can only support memory policies for a single zone.
> 
> That's broken. The VM had zones long before it had nodes or memory
> policies

NUMA nodes mostly only have one zone (ZONE_NORMAL on 64 bit and 
ZONE_HIGHMEM on 32 bit). The only exception are low nodes (node 0 or 1?) 
that may have additional DMA zones in some configurations.

> > 4. You may have to duplicate the slab allocator caches for that
> >    purpose.
> 
> If you want specific allocations from a given zone, yes. So you may
> have to do the same if you want a specific slab allcoation from a
> list within a zone.

I am still not sure what the lists within a zone are for? The proposal
was to reduce zones and not create additional lists.

> node->zone->many lists vs node->many zones? I guess the zones approach is
> faster?

No. Node->many_zone->freelist vs. node->one_zone-?_one_freelist in the regular case.

For Mel's defrag scheme one would need to add new lists but 
then this will introduce more fragmentation in order to fix the 
fragmentation issue. Still having lists within a zone would avoid the boot 
up sizing of zones and avoid additional page flags.

> Not that I am any more convinced that defragmentation is a good idea than
> I was a year ago, but I think it is naive to think we can instantly be rid
> of all the problems associated with zones by degenerating that layer of the
> VM and introducing a new one that does basically the same things.

I am also having the same concerns. Going from multiple zones to one zone 
is a performance benefit in many cases. In the NUMA case (if you have more 
than a few nodes) most nodes only have one zone anyways.

> It is true that zones may not be a perfect fit for what some people want to
> do, but until they have shown a) what they want to do is a good idea, and
> b) zones can't easily be adapted, then using the infrastructure we already
> have throughout the entire mm seems like a good idea.

I have never said that people cannot add zones. But this is usually not 
necessary. The intend here is to optimize for the case that we only have 
one zone. Single zone configurations will have a smaller VM with less 
cache footprint and run faster.
 
> IMO, Andrew's idea to have 1..N zones in a node seems sane and it would be
> a good generalisation of even the present code.

We already have multiple zones, and it is fairly easy to add a zone. If 
someone has an idea how to generalize this then please do so. I do not see 
how that could be done given the different usage scenarios for the various 
zones.

But why is not okay to optimize the kernel for the one zone situation?
I prefer a simple, small and fast VM and this only optimizing the VM by 
not compiling code that is only needed for configurations that require 
multiple zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
