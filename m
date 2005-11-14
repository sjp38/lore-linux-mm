Date: Mon, 14 Nov 2005 10:05:30 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] Make the slab allocator observe NUMA policies
In-Reply-To: <200511131222.48690.ak@suse.de>
Message-ID: <Pine.LNX.4.62.0511141002050.353@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511101401390.16481@schroedinger.engr.sgi.com>
 <200511110406.24838.ak@suse.de> <Pine.LNX.4.62.0511110934110.20360@schroedinger.engr.sgi.com>
 <200511131222.48690.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: steiner@sgi.com, linux-mm@kvack.org, alokk@calsoftinc.com
List-ID: <linux-mm.kvack.org>

On Sun, 13 Nov 2005, Andi Kleen wrote:

> On Friday 11 November 2005 18:40, Christoph Lameter wrote:
> 
> > Hmm. Thats not easy to do since the slab allocator is managing the pages 
> > in terms of the nodes where they are located. The whole thing is geared to 
> > first inspect the lists for one node and then expand if no page is 
> > available.
> 
> Yes, that's fine - as long as it doesn't allocate too many 
> pages at one go (which it doesn't) then the interleaving should
> even the allocations out at page level.

The slab allocator may allocate pages higher orders which need to 
be physically continuous. 

Any idea how to push this to the page allocation within the slab without 
rearchitecting the thing?

> > The cacheline already in use by the page allocator, the page allocator 
> > will continually reference current->mempolicy. See alloc_page_vma and 
> > alloc_pages_current. So its likely that the cacheline is already active 
> > and the impact on the hot code patch is likely negligible.
> 
> I don't think that's likely - frequent users of kmem_cache_alloc don't
> call alloc_pages. That is why we have slow and fast paths for this ...
> But if we keep adding all the features of slow paths to fast paths
> then the fast paths will be eventually not be fast anymore.

IMHO, the application allocating memory is highly likely to call other 
memory allocation function at the same time. small cache operations are 
typically related to page sized allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
