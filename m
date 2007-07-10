Date: Tue, 10 Jul 2007 14:55:54 +0100
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070710135554.GC9426@skynet.ie>
References: <20070710102043.GA20303@skynet.ie> <20070710130356.GG8779@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070710130356.GG8779@wotan.suse.de>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (10/07/07 15:03), Nick Piggin didst pronounce:
> On Tue, Jul 10, 2007 at 11:20:43AM +0100, Mel Gorman wrote:
> > > 
> > >  Mel's page allocator work.  Might merge this, but I'm still not hearing
> > >  sufficiently convincing noises from a sufficient number of people over this.
> > > 
> > 
> > This is a long on-going story. It bounces between people who say it's not a
> > complete solution and everything should have the 100% ability to defragment
> > and the people on the other side that say it goes a long way to solving their
> > problem. I've cc'd some of the parties that have expressed any interest in
> > the last year.
> 
> And I guess some other people who want to see what prolbems there are
> and what can't be solved between order-0 allocations and reserve zones.
> 

This is true. The ZONE_MOVABLE stuff is a stab at seeing how far a reserve
zone can get and work to improve order-0 usage is not mutually exclusive to
grouping pages by mobility.

> > On a slightly more left of centre tact, these patches *may* help fsblock with
> > large blocks although I would like to hear Nick's confirming/denying this.
> > Currently if fsblock wants to work with large blocks, it uses a vmap to map
> > discontiguous pages so they are virtually contiguous for the filesystem. The
> > use of VMAP is never cheap, though how much of an overhead in this case is
> > unknown.  If these patches were in place, fsblock could optimisically allocate
> > the higher-order page and use it without vmap if it succeeded. If it fails,
> > it would use vmap as a lower-performance-but-still-works fallback. This
> > may tie in better with what Christoph is doing with large blocks as well
> > as it may be a compromise solution between their proposals - I'm not 100%
> > sure so he's cc'd as well for comment.
> 
> Yeah higher order allocations could definitely be helpful for this although
> I couldn't guess at the sort of impovements at this stage.

Admittedly, neither can I.

> And I mean if
> there was a simple choice between better (but still not perfect) support
> for higher order allocations or not, then of course you would take them.
> I am sure there are other places as well where they might makes life a bit
> easier or performance a bit better.
> 
> But given the code involved, it is not just a simple choice, but a
> tradeoff. Perhaps I haven't seen or don't realise it, but I'm still not
> sure that this tradeoff is a good one. (just my opinion).
> 

Regrettably, the code cannot be made any simplier without making it more
ineffective at the same time.

In principal, the idea is fairly simple. Identify allocations into a number of
"migrate types" and mark them with GFP flags. Instead of one set of free lists
have one set per migrate type and always try an satisfy an allocation from a
preferred list. When that cannot be done, rmqueue_fallback() is responsible
for selecting an alternative list in such a way to minimise future mixing
of blocks.

I cannot see a way this code could be made similar or devise an
alternative mechanism that would achieve the same result and be easier
to understand at the same time. I do not believe any serious alternative
has been proposed or implemented.

> > The patches have been reviewed heavily recently by Christoph and Andy has
> > looked through them as well. They've been tested for a long time in -mm so
> > I would expect they not regress functionality. I've maintained that having
> > the 100% ability to defragment will cost too much in terms of performance
> > and would be blocked by the fact that the device driver model would have to
> > be updated to never use physical addresses - a massive undertaking. I think
> > this approach is more pragmatic and working on making more types of memory
> > (like page tables) migratable is at least piecemeal as opposed to turning
> > everything on it's head.
> 
> My comments about defragmentation of the kernel were not exactly what
> I believe is the right direction to go (it may be, but I'm rally not
> in a position to know without having seen or tried to implement it).

I've taken a look at it a few times. I might be blinded by tunnel vision
but it's always looked like a really serious undertaking. Breaking the 1:1
phys:virt mapping was bad enough and looked like it would have some serious
performance reprocussions. Worse though was the requirement to rework drivers
to never use physical addresses and always be prepared to release all memory -
that just seemed like the type of upheaval that would never succeed.

> But
> I do think that's what would really be needed in order to really support
> higher order allocations the same as order-0.
> 

If they had to work 100% of the time at all times, I might agree with
you but the cost of having that sort of 100% guarantee is likely to be
so high as to outweigh any benefits of using high-order pages in the
first place.

> I realise in your pragmatic approach, you are encouraging users to
> put fallbacks in place in case a higher order page cannot be allocated,
> but I don't think either higher order pagecache or higher order slubs
> have such fallbacks (fsblock or a combination of fsblock and higher
> order pagecache could have, but...).
>  

SLUB doesn't have such a fallback right now. Minimally, one alternative
proposal was to force slabs that are involved with IO to use order-0
until it could be addressed fully. This conversation was never fully
resolved because similar to other points, without grouping pages by
mobility or something similar it's pointless.

fsblock in combination with higher order pagecache would have such a
fallback. While that is vapour at the moment, that does not mean that
something like that could not be implemented if grouping pages by mobility
was used. Again, without grouping pages by mobility or some solution that
has similar effects, higher-order pagecache in any guise becomes unworkable.

> > >  These are slub changes which are dependent on Mel's stuff, and I have a note
> > >  here that there were reports of page allocation failures with these.  What's
> > >  up with that?
> > > 
> > 
> > These is where the
> > have-kswapd-keep-a-minimum-order-free-other-than-order-0.patch and
> > only-check-absolute-watermarks-for-alloc_high-and-alloc_harder-allocations.patch
> > patches should be. There were page allocation failure reports without these
> > patches but Nick felt they were not the correct solution and I tend to agree
> > with him on this matter. I haven't put a massive amount of thought into it
> > yet because without grouping pages by mobility, the question is pointless.
> 
> Yeah I think that was a hack.
> 

Somewhat agreed. This is one where I want to take the time to consider
alternatives that are reliable and not subject to deadlocking. I do not
believe there is any attempt to push these patches anywhere right now.

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
