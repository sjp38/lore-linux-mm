Date: Sat, 9 Feb 2008 16:19:39 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB tbench regression due to page allocator deficiency
In-Reply-To: <20080209143518.ced71a48.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
 <20080209143518.ced71a48.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Sat, 9 Feb 2008, Andrew Morton wrote:

> On Sat, 9 Feb 2008 13:45:11 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Isnt there a way that we can make the page allocator handle PAGE_SIZEd 
> > allocations in such a way that is competitive with the slab allocators? 
> > The cycle count for an allocation needs to be <100 not just below 1000 as 
> > it is now.
> Well.  Where are the cycles spent?

No idea. This is from some measurements I took with my page allocator 
benchmarks. For the tests see the code at
git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git tests

We do a gazillion of tests before doing anything. Most of that is NUMA 
stuff it seems but even in SMP this is still signficant.

> We are notorious for sucking but I don't think even we suck enough to have
> left a 10x optimisation opportunity in the core page allocator ;)

The regression only occurs if there is intensive allocation and freeing of 
pages. If there is a contiguous stream of allocations then there will be 
no regression since the slab allocators will have to go to the page 
allocator to get new pages. So the suckiness gets pushed under the carpet.

The SLUB fastpath takes around 40-50 cycles if things align right.
SLAB takes around 80-100 cycles.
The page allocator fastpath takes 342 cycles(!) at its best (Note kernel 
compiled for SMP no NUMA!)

It seems that we may increase kernel performance in general if we would 
come up with a better fastpath. That would not only improve slub but the 
kernel in general.

> >  include/linux/slub_def.h |    6 +++---
> >  mm/slub.c                |   25 +++++++++++++++++--------
> 
> I am worrried by a patch which squeezes a few percent out of tbench.  Does
> it improve real things?  Does anything regress?

It uses an order 3 alloc to get a big allocation unit to be able to stuff 
8 4k pages into it. Should improve networking. Howeve an order 3 
alloc is considered to be not good by many.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
