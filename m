From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] Make the slab allocator observe NUMA policies
Date: Tue, 15 Nov 2005 04:34:14 +0100
References: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com> <200511141944.33478.ak@suse.de> <Pine.LNX.4.62.0511141055560.1222@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0511141055560.1222@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511150434.15094.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Monday 14 November 2005 20:08, Christoph Lameter wrote:

> The slab allocator is designed in such a way that it needs to know the 
> node for the allocation before it does its work. This is because the 
> nodelists are per node since 2.6.14. You wanted to do the policy 
> application on the back end so after all the work is done (presumably 
> for the current node) and after the node specific lists have been 
> examined. Policy application at that point may find that another
> node than the current node was desired and the whole thing has to be 
> redone for the other node. This will significantly negatively impact
> the performance of the slab allocator in particular if the current node
> is is unlikely to be chosen for the memory policy.
> 
> I have thought about various ways to modify kmem_getpages() but these do 
> not fit into the basic current concept of the slab allocator. The 
> proposed method is the cleanest approach that I can think of. I'd be glad 
> if you could come up with something different but AFAIK simply moving the 
> policy application down in the slab allocator does not work.

I haven't checked all the details, but why can't it be done at the cache_grow
layer? (that's already a slow path)

If it's not possible to do it in the slow path I would say the design is 
incompatible with interleaving then. Better not do it then than doing it wrong.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
