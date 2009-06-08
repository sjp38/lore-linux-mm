Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4F86B004F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 10:04:04 -0400 (EDT)
Date: Mon, 8 Jun 2009 17:21:50 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch][v2] swap: virtual swap readahead
Message-ID: <20090608152150.GA7563@cmpxchg.org>
References: <20090602223738.GA15475@cmpxchg.org> <Pine.LNX.4.64.0906071747440.20105@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0906071747440.20105@sister.anvils>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 07, 2009 at 06:55:15PM +0100, Hugh Dickins wrote:
> On Wed, 3 Jun 2009, Johannes Weiner wrote:
> >
> > The current swap readahead implementation reads a physically
> > contiguous group of swap slots around the faulting page to take
> > advantage of the disk head's position and in the hope that the
> > surrounding pages will be needed soon as well.
> > 
> > This works as long as the physical swap slot order approximates the
> > LRU order decently, otherwise it wastes memory and IO bandwidth to
> > read in pages that are unlikely to be needed soon.
> > 
> > However, the physical swap slot layout diverges from the LRU order
> > with increasing swap activity, i.e. high memory pressure situations,
> > and this is exactly the situation where swapin should not waste any
> > memory or IO bandwidth as both are the most contended resources at
> > this point.
> > 
> > Another approximation for LRU-relation is the VMA order as groups of
> > VMA-related pages are usually used together.
> > 
> > This patch combines both the physical and the virtual hint to get a
> > good approximation of pages that are sensible to read ahead.
> > 
> > When both diverge, we either read unrelated data, seek heavily for
> > related data, or, what this patch does, just decrease the readahead
> > efforts.
> > 
> > To achieve this, we have essentially two readahead windows of the same
> > size: one spans the virtual, the other one the physical neighborhood
> > of the faulting page.  We only read where both areas overlap.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Reviewed-by: Rik van Riel <riel@redhat.com>
> > Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > Cc: Andi Kleen <andi@firstfloor.org>
> 
> I think this a great idea, a very promising approach.  I like it
> so much better than Andrew's and others' proposals to dedicate
> areas of swap space to distinct virtual objects: which, as you
> rightly pointed out, condemn us to unnecessary seeking when
> writing swap (and is even more of an issue if we're writing
> to SSD rather than HDD).
> 
> It would be nice to get results from a wider set of benchmarks
> than just qsbench; but I don't think qsbench is biased in your
> favour, and I don't think you need go to too much trouble on
> that - let's just aim to get your work into mmotm, then we can
> all play around with it for a while.  I suppose what I'd most
> like is to try it with shmem, which you've understandably left
> out for now.

I agree, it would be nice to have this in mm soonish and have it
exposed a bit more until .31 or .32.  And I'll continue to test other
loads.

> You'll be hating me for the way I made shmem_truncate_range() etc.
> nigh incomprehensible when enabling highmem index pages there.
> Christoph Rohland's original was much nicer.  Again and again and
> again I've wanted to throw all that out, and keep swap entries in
> the standard radix tree which keeps the struct page pointers; but
> again and again and again, I've been unable to justify losing the
> highmem index ability - for a while it seemed as if x86_64 was
> going to make highmem a thing of the past, and it's certainly helped
> us to ignore 32GB 32-bit; but I think 4GB 32-bit is here a long while.

Regarding highmem, I have only one 32 bit box with 1G memory and
highmem= seems to be broken right now.  The documentation says it will
fix-set the zone.  It does not on x86, but instead seems to set up
Normal and then complain about the lack of remaining pages to stuff
into HighMem.

With 128M HighMem, testing for highpte mapping overhead is a bit bogus
so I can't do that until I figure something out (either fixing
highmem= or no-opping GFP_HIGHMEM and use GFP_HIGHPTE for the pte
pages).

Or redoing the patch as you suggested below, which is probably what I
will opt for.

> Though I like the way you localized it all into swapin_readahead(),
> I'd prefer to keep ptes out of swap_state.c, and think several issues
> will fall away if you turn your patch around.  You'll avoid the pte code
> in swap_state.c, you'll satisfy Andi's concerns about locking/kmapping
> overhead, and you'll find shmem much much easier, if instead of peering
> back at where you've come from in swapin_readahead(), you make the outer
> levels (do_swap_page and shmem_getpage) pass a vector of swap entries to
> swapin_readahead()?  That vector on stack, and copied from the one page
> table or index page (don't bother to cross page table or index page
> boundaries) while it was mapped.

That is a nice suggestion.

> It's probably irrelevant to you, but I've attached an untested patch
> of mine which stomps somewhat on this area: I was shocked to notice
> shmem_getpage() in a list of deep stack offenders a few months back,
> realized it was those unpleasant NUMA mempolicy pseudo-vmas, and made
> a patch to get rid of them.  I've rebased it to 2.6.30-rc8 and checked
> that the resulting kernel runs, but not really tested it; and I think
> I didn't even try to get the mpol reference counting right (tends to
> be an issue precisely in swapin_readahead, where one mpol ends up used
> repeatedly) - mpol refcounting is an arcane art only Lee understands!
> I've attached the patch because you may want to glance at it and
> decide, either that it's something which is helpful to the direction
> you're going in and you'd like to base upon it, or that it's a
> distraction and you'd prefer me to keep it to myself until your
> changes are in.

I will try to make swapin_readahead() take an array of ptes, then your
patch shouldn't get in my way as I don't need the vma anymore.

> But your patch below is incomplete, isn't it?  The old swapin_readahead()
> is now called swapin_readahead_phys(), and you want shmem_getpage() to be
> using that for now: but no prototype for it and no change to mm/shmem.c.

You probably missed the no-vma or no-vma->vm_mm branch in
swapin_readahead().  shmem either sends in a NULL-vma or the dummy-vma
that has no vm->vm_mm set.  Oops.  That is of course a bug, vma->vm_mm
is uninitialized, not NULL.  But that will go away as well.

Thanks,

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
