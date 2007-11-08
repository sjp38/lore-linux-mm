Date: Thu, 8 Nov 2007 05:54:04 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] radix-tree: avoid atomic allocations for preloaded insertions
Message-ID: <20071108045404.GJ3227@wotan.suse.de>
References: <20071108004304.GD3227@wotan.suse.de> <20071107170923.6cf3c389.akpm@linux-foundation.org> <20071108013723.GF3227@wotan.suse.de> <20071107190254.4e65812a.akpm@linux-foundation.org> <20071108031645.GI3227@wotan.suse.de> <20071107201242.390aec38.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071107201242.390aec38.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Wed, Nov 07, 2007 at 08:12:42PM -0800, Andrew Morton wrote:
> > On Thu, 8 Nov 2007 04:16:45 +0100 Nick Piggin <npiggin@suse.de> wrote:
> > On Wed, Nov 07, 2007 at 07:02:54PM -0800, Andrew Morton wrote:
> > > 
> > > 	test radix_tree_preloads
> > > 		kmem_cache_alloc()
> > > 		store it in radix_tree_preloads()
> > > 	retrieve it from radix_tree_preloads()
> > > 
> > > it's not a _lot_ of work, but it's there.  Mainly the new dirtying of this
> > > cpu's radix_tree_preload all the time.
> > 
> > Oh that. Yeah I suppose it does, but it is a per-cpu var which already
> > must be read from, so we won't get write misses. I can't see it being
> > any problem at all.
> > 
> 
> The cacheline now needs to be written back: more bus traffic.

Sure, but that's a bandwidth issue rather than a latency one, and the
bandwidth consumed by this single write is in the noise, I can assure
you. We're talking about this event happening at *very most* once per
pagecache page insertion. And considering the pagecache has to be zeroed
out or otherwise initialized, the bandwidth is like 0.1% of the page
clearing bandwidth required.

But if the variable is that hot, it won't get written back to memory
_every_ time it is dirtied in CPU cache anyway.


> > And you can end up consuming _all_ of the
> > !__GFP_WAIT reserves that can be used for more useful things (eg. we can
> > use it in the block layer request allocation to avoid a spin_unlock_irq/
> > spin_lock_irq pair required when we fall back to __GFP_WAIT).
> 
> I don't think we can go more than a single page below the zone watermark
> because the preceding radix_tree_preload(GFP_KERNEL) filled things up
> again.
> 
> In which case, why did David hit that allocation failure at all? 
> Presumably this cpu's radix_tree_preloads slot was already full, or the
> radix_tree_preload() allocation was satisfied from slab cache.

Of course it is already full: as the code stands now it never gets used
up at all until a page allocation failure hits.


> > But with my patch it is never called so long as the radix_tree_insert is
> > called within a successful preload (which it always is, for pagecache
> > AFAIKS).
> 
> ug, that was subtle.  Too subtle to be omitted from changelog, code comments
> and runtime assertions..

I did mention it in the changelog (zone->lock moves from underneath tree_lock).

I don't know what runtime assertions we can have. But it isn't so hard to
see the 2 places that insert pages into the pagecache run under a preload.

 
> It would be good to simply require that the radix_tree_preloads slot be
> full on entry to radix_tree_insert() (ie: all callers correctly use
> radix_tree_preload()).  But some callers don't bother.
> 
> <looks at arch/powerpc/kernel/irq.c>
> 
> It's buggy - doesn't handle GFP_ATOMIC allocation failures.
> 
> <looks at drivers/net/mlx4/cq.c>
> 
> Well at least it tests for failure, but it could reliably avoid failure if
> it used radix_tree_preload().
> 
> <looks at fs/nfs/write.c>
> 
> again: unreliable, remembers to test for failure, would be better to use
> radix_tree_preload().
> 
> 
> So I think what we should be doing here is fixing those three callers to
> use radix_tree_preload() correctly, then remove that kmem_cache_alloc()
> from radix_tree_node_alloc() altogether.  And add a suitable runtime
> assertion to the top of radix_tree_insert() to catch regressers.

Sure, that's another patch again. I'm just patching the problem I want
to see fixed. Everytime I try to do these peripheral cleanups and fixes,
the patch fixing the main issue gets ignored (along with everything
else).


> But I suppose that's a separate work.  For now, please at least comment
> your "AFAIKS"?
> 
> 
> My bottom line: your change
> 
> - is a bit slower

That's so much less significant than the atomic->non-atomic operations
you hate me doing that I never thought you'd care at all about it. If
the new Andrew is going to count cycles going into core code, I couldn't
be happier though ;)

 
> - doesn't solve the problem which it claims to be solving
>   (radix_tree_insert() doesn't deplete atomic reserves as long as the
>   caller uses radix_tree_preload(GFP_KERNEL))

I'm pretty sure it does. I don't follow exactly why you say it doesn't.
 

> - is probably desirable as a simplify-the-locking-hierarchy thing, but a)
>   should be presented as such and

It's primarily to avoid GFP_ATOMIC allocations. Simplify the locking
hierarcy is secondary and I put that in the changelog.


> b) needs code comments explaining why it
>   is correct and needs a big fat TODO explaining how we should get that
>   kmem_cache_alloc() out of there, an how we should do it.
> 
> OK?

I don't really know about getting that kmem_cache_alloc out of there.
For radix trees that are protected by sleeping locks, you don't actually
need to disable preempt and you can do sleeping allocations there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
