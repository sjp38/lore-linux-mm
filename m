Date: Mon, 1 Dec 2008 01:18:09 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [patch 1/2] mm: pagecache allocation gfp fixes
In-Reply-To: <20081128120440.GA13786@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0812010053510.14288@blonde.site>
References: <20081127093401.GE28285@wotan.suse.de>
 <84144f020811270152i5d5c50a8i9dbd78aa4a7da646@mail.gmail.com>
 <20081127101837.GJ28285@wotan.suse.de> <Pine.LNX.4.64.0811271749100.17307@blonde.site>
 <20081128120440.GA13786@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Nov 2008, Nick Piggin wrote:
> On Thu, Nov 27, 2008 at 06:14:18PM +0000, Hugh Dickins wrote:
> > On Thu, 27 Nov 2008, Nick Piggin wrote:
> > > On Thu, Nov 27, 2008 at 11:52:40AM +0200, Pekka Enberg wrote:
> > > > > -               err = add_to_page_cache_lru(page, mapping, index, gfp_mask);
> > > > > +               err = add_to_page_cache_lru(page, mapping, index,
> > > > > +                       (gfp_mask & (__GFP_FS|__GFP_IO|__GFP_WAIT|__GFP_HIGH)));
> > > > 
> > > > Can we use GFP_RECLAIM_MASK here? I mean, surely we need to pass
> > > > __GFP_NOFAIL, for example, down to radix_tree_preload() et al?
> > 
> > I certainly agree with Pekka's suggestion to use GFP_RECLAIM_MASK.
> > 
> > > 
> > > Updated patch.
> > 
> > I'm not sure about it.  I came here before 2.6.25, not yet got around
> > to submitting, I went in the opposite direction.  What drove me was an
> > irritation at the growing number of & ~__GFP_HIGHMEMs (after adding a
> > couple myself in shmem.c).  At the least, I think we ought to change
> > those to & GFP_RECLAIM_MASKs (it seems we don't have one, but can
> > imagine a block driver that wants GFP_DMA or GFP_DMA32 for pagecache:
> > there's no reason to alloc its kernel-internal data structures for DMA).
> > 
> > My patch went the opposite direction to yours, in that I was pushing
> > down the GFP_RECLAIM_MASKing into lib/radix-tree.c and mm/memcontrol.c
> > (but that now doesn't kmalloc for itself, so no longer needs the mask).
> > 
> > I'm not sure which way is the right way: you can say I'm inconsistent
> > not to push it down into slab/sleb/slib/slob/slub itself, but I've a
> > notion that someone might object to any extra intrns in their hotpaths.
> > 
> > My design principle, I think, was to minimize the line length of
> > the maximum number of source lines: you may believe in other
> > design principles of higher value.
> 
> I think logically it doesn't belong in those files. The problem comes
> purely from the pagecache layer because we're using gfp masks to ask
> for two different (and not quite compatible things).
> 
> We're using it to specify the pagecache page's memory type, and also
> the allocation context for both the pagecache page, and any other
> supporting allocations required.
> 
> I think it's much more logical to go into the pagecache layer.

Fair enough, I can go along with that, and stomach the longer lines.

I do think that we ought to change those &~__GFP_HIGHMEMs to
&GFP_RECLAIM_MASKs, but that doesn't have to be part of your patch.

And it does make me think that Kamezawa-san's patch in mmotm
memcg-fix-gfp_mask-of-callers-of-charge.patch
which is changing the gfp arg to assorted mem_cgroup interfaces
from GFP_KERNEL to GFP_HIGHUSER_MOVABLE, is probably misguided:
that gfp arg is not telling them what zones of memory to use,
it's telling them the constraints if it reclaims memory.

I'd skip the churn and leave them as GFP_KERNEL - you could argue
that we should define another another name for that set of reclaim
constraints, but I think it would end up too much hair-splitting.

> > Updating it quickly to 2.6.28-rc6, built but untested, here's mine.
> > I'm not saying it's the right approach and yours wrong, just please
> > consider it before deciding on which way to go.
> > 
> > I've left in the hunk from fs/buffer.c in case you can decipher it,
> > I think that's what held me up from submitting: I've never worked
> > out since whether that change is a profound insight into reality
> > here, or just a blind attempt to reduce the line length.
> 
> I don't see why you drop the mapping_gfp_mask from there... if we ever
> change the buffer layer to support HIGHMEM pages, we'd want to set the
> inode's mapping_gfp_mask to GFP_HIGHUSER rather than GFP_USER, wouldn't
> we?

It was just a mysterious fragment, if it makes no sense to you either,
let's just forget it - thanks for looking.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
