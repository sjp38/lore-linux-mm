Date: Wed, 11 Jul 2007 11:01:31 +0100
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070711100130.GE7568@skynet.ie>
References: <20070710102043.GA20303@skynet.ie> <200707100929.46153.dave.mccracken@oracle.com> <20070710152355.GI8779@wotan.suse.de> <200707101211.46003.dave.mccracken@oracle.com> <20070711025946.GD27475@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070711025946.GD27475@wotan.suse.de>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Dave McCracken <dave.mccracken@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (11/07/07 04:59), Nick Piggin didst pronounce:
> On Tue, Jul 10, 2007 at 12:11:45PM -0500, Dave McCracken wrote:
> > On Tuesday 10 July 2007, Nick Piggin wrote:
> > > On Tue, Jul 10, 2007 at 09:29:45AM -0500, Dave McCracken wrote:
> > > > I find myself wondering what "sufficiently convincing noises" are.  I
> > > > think we can all agree that in the current kernel order>0 allocations are
> > > > a disaster.
> > >
> > > Are they? For what the kernel currently uses them for, I don't think
> > > the lower order ones are so bad. Now and again we used to get reports
> > > of atomic order 3 allocation failures with e1000 for example, but a
> > > lot of those were before kswapd would properly asynchronously start
> > > reclaim for atomic and higher order allocations. The odd failure
> > > sometimes catches my eye, but nothing I would call a disaster.
> > 
> > Ok, maybe disaster is too strong a word.  But any kind of order>0 allocation 
> > still has to be approached with fear and caution, with a well tested fallback 
> > in the case of the inevitable failures.  How many driver writers would have 
> > benefited from using order>0 pages, but turned aside to other less optimal 
> > solutions due to their unreliability?  We don't know, and probably never 
> > will.  Those people have moved on and won't revisit that design decision.
> 
> On the other side of the coin, we can't just merge this in the hope
> that some good uses might turn up (IMO).
> 

That is a catch-22. There is no point putting any work into these "good
uses" if they know they'll depend on grouping pages by mobility. After
watching the patches been kicked around for so long, I'd be suprised if
people put a lot of effort into implementing things that depended on
them.

Despite that, memory unplug has shown up again despite needing these
patches to go through, the SLUB high-order allocation stuff is there
and *potentially* fsblock could avoid using vmap all the time if that
approach was taken.

> 
> > > > The sheer list of patches lined up behind this set is strong evidence
> > > > that there are useful features which depend on a working order>0.  When
> > > > you add in the existing code that has to struggle with allocation
> > > > failures or resort to special pools (ie hugetlbfs), I see a clear vote
> > > > for the need for this patch.
> > >
> > > Really the only patches so far that I think have convincing reasons are
> > > memory unplug and hugepage, and both of those can get a long way by using
> > > a reserve zone (note it isn't entirely reserved, but still available for
> > > things like pagecache). Beyond that, is there a big demand, and do we
> > > want to make this fundamental change in direction in the kernel to
> > > satisfy that demand?
> > 
> > Yes, these projects have workarounds, because they have to.  But the 
> > workarounds are painful and often require that the user specify in advance 
> > what memory they intend to use for this purpose, something users often have 
> > to learn by trial and error.  Mel's patches would eliminate this barrier to 
> > use of the features.
> > 
> > I don't see Mel's patches as "a fundamental change in direction".  I think 
> > you're overstating the case.  I see it as fixing a deficiency in the design 
> > of the page allocator, and a long overdue fix.
> 
> I would still say that with Mel's patches in, you need to have a fallback
> to order-0 because memory can still get fragemnted.

I have not disputed this. I know stressed high-order allocations have
worked well in testing to date but I accept that some corner case is
going to exist that will cause a failure and we have to be prepared to
handle it.

> But no Mel's patches
> are not exactly a fundamental change in direction itself, but introducing
> higher order allocations without fallbacks is a change (OK, order 1 or 2
> is used today, and mostly because of the nature of the allocator they're OK
> too, but if we're talking about like 64K+ of contiguous pages).
> 

Then the changes that depend on high-order allocations succeeded or the world
ends needs to be checked carefully. Grouping pages by mobility shouldn't be
kicked on the grounds of what future patch may or may not do as it is not a
fundamental change in direction on its own.  For now, high-order users must
still be prepared to handle fallbacks and we should track how often those
fallbacks are used as it's an indication of when grouping pages by mobility
is not behaving as advertised.

In the context of high-order pagecache, I believe it can be made work with
fsblock nicely as I've stated elsewhere by using vmap as a fallback instead
of the first option. SLUB using high-order allocations all the time needs to
be revisited so I would not be keen on pushing it right now because I have
the same concerns as you in mind. When failures happen for memory unplug,
it just means unplug does not occur which is not world ending.

> > > > Some object because order>0 will still be able to fail.  I point out that
> > > > order==0 can also fail, though we go to great lengths to prevent it.
> > > >  Mel's patches raise the success rate of order>0 to within a few percent
> > > > of order==0.  All this means is callers will need to decide how to handle
> > > > the infrequent failure.  This should be true no matter what the order.
> > >
> > > So small ones like order-1 and 2 seem reasonably good right now AFAIKS.
> > > If you perhaps want to say start using order-4  pages for slab or
> > > some other kernel memory allocations, then you can run into the situation
> > > where memory gets fragmented such that you have one sixteenth of your
> > > memory actualy used but you can't allocate from any of your slabs because
> > > there are no order-4 pages left. I guess this is a big difference between
> > > order-low failures and order-high.
> > 
> > In summary, I think I can rephrase your arguments against the patches as 
> > order>0 allocation pretty much works now for small orders, and people are 
> > living with it".  Is that fairly accurate?  My counter argument is that we 
> 
> Well it does work for small orders and if by living with it you mean works
> OK, then yes.
> 
> 
> > can easily make it work much better and vastly simplify the code that is 
> > having to work around the lack of it by applying Mel's patches.
> 
> OK we have a lot contained in that statement :)
> 
> Make it work much better -- OK, so it should be easy to get the evidence
> to justify this, then?
> 
> Vastly simplify the code -- so firstly you have to weigh this against the
> increased complexity of Mel's patches, and secondly you are saying that we
> can abandon fallback code? That's where we're talking about a fundamental
> change in direction.
> 

I don't think fallback code should be abandoned. Maybe in a few years
when we know fallback never occur in any circumstances then maybe, but not
now. Someone using high orders needs to be sure there is a good reason for
it to justify dealing with the complexity. Some users like hugepages and
memory unplug are willing to deal with said complexity because they have to.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
