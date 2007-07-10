From: Dave McCracken <dave.mccracken@oracle.com>
Subject: Re: -mm merge plans -- anti-fragmentation
Date: Tue, 10 Jul 2007 12:11:45 -0500
References: <20070710102043.GA20303@skynet.ie> <200707100929.46153.dave.mccracken@oracle.com> <20070710152355.GI8779@wotan.suse.de>
In-Reply-To: <20070710152355.GI8779@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200707101211.46003.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tuesday 10 July 2007, Nick Piggin wrote:
> On Tue, Jul 10, 2007 at 09:29:45AM -0500, Dave McCracken wrote:
> > I find myself wondering what "sufficiently convincing noises" are.  I
> > think we can all agree that in the current kernel order>0 allocations are
> > a disaster.
>
> Are they? For what the kernel currently uses them for, I don't think
> the lower order ones are so bad. Now and again we used to get reports
> of atomic order 3 allocation failures with e1000 for example, but a
> lot of those were before kswapd would properly asynchronously start
> reclaim for atomic and higher order allocations. The odd failure
> sometimes catches my eye, but nothing I would call a disaster.

Ok, maybe disaster is too strong a word.  But any kind of order>0 allocation 
still has to be approached with fear and caution, with a well tested fallback 
in the case of the inevitable failures.  How many driver writers would have 
benefited from using order>0 pages, but turned aside to other less optimal 
solutions due to their unreliability?  We don't know, and probably never 
will.  Those people have moved on and won't revisit that design decision.

> > The sheer list of patches lined up behind this set is strong evidence
> > that there are useful features which depend on a working order>0.  When
> > you add in the existing code that has to struggle with allocation
> > failures or resort to special pools (ie hugetlbfs), I see a clear vote
> > for the need for this patch.
>
> Really the only patches so far that I think have convincing reasons are
> memory unplug and hugepage, and both of those can get a long way by using
> a reserve zone (note it isn't entirely reserved, but still available for
> things like pagecache). Beyond that, is there a big demand, and do we
> want to make this fundamental change in direction in the kernel to
> satisfy that demand?

Yes, these projects have workarounds, because they have to.  But the 
workarounds are painful and often require that the user specify in advance 
what memory they intend to use for this purpose, something users often have 
to learn by trial and error.  Mel's patches would eliminate this barrier to 
use of the features.

I don't see Mel's patches as "a fundamental change in direction".  I think 
you're overstating the case.  I see it as fixing a deficiency in the design 
of the page allocator, and a long overdue fix.

> > Some object because order>0 will still be able to fail.  I point out that
> > order==0 can also fail, though we go to great lengths to prevent it.
> >  Mel's patches raise the success rate of order>0 to within a few percent
> > of order==0.  All this means is callers will need to decide how to handle
> > the infrequent failure.  This should be true no matter what the order.
>
> So small ones like order-1 and 2 seem reasonably good right now AFAIKS.
> If you perhaps want to say start using order-4  pages for slab or
> some other kernel memory allocations, then you can run into the situation
> where memory gets fragmented such that you have one sixteenth of your
> memory actualy used but you can't allocate from any of your slabs because
> there are no order-4 pages left. I guess this is a big difference between
> order-low failures and order-high.

In summary, I think I can rephrase your arguments against the patches as 
order>0 allocation pretty much works now for small orders, and people are 
living with it".  Is that fairly accurate?  My counter argument is that we 
can easily make it work much better and vastly simplify the code that is 
having to work around the lack of it by applying Mel's patches.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
