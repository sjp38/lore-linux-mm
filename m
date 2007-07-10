Date: Tue, 10 Jul 2007 17:23:55 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070710152355.GI8779@wotan.suse.de>
References: <20070710102043.GA20303@skynet.ie> <200707100929.46153.dave.mccracken@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <200707100929.46153.dave.mccracken@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dave.mccracken@oracle.com>
Cc: Mel Gorman <mel@skynet.ie>, Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 10, 2007 at 09:29:45AM -0500, Dave McCracken wrote:
> On Tuesday 10 July 2007, Mel Gorman wrote:
> > >  Mel's page allocator work.  Might merge this, but I'm still not hearing
> > >  sufficiently convincing noises from a sufficient number of people over
> > > this.
> >
> > This is a long on-going story. It bounces between people who say it's not a
> > complete solution and everything should have the 100% ability to defragment
> > and the people on the other side that say it goes a long way to solving
> > their problem. I've cc'd some of the parties that have expressed any
> > interest in the last year.
> 
> I find myself wondering what "sufficiently convincing noises" are.  I think we 
> can all agree that in the current kernel order>0 allocations are a disaster.  

Are they? For what the kernel currently uses them for, I don't think
the lower order ones are so bad. Now and again we used to get reports
of atomic order 3 allocation failures with e1000 for example, but a
lot of those were before kswapd would properly asynchronously start
reclaim for atomic and higher order allocations. The odd failure
sometimes catches my eye, but nothing I would call a disaster.

Something like the birthday paradox I guess says that you don't actually
need a large proportion of pages free in order to get higher order
pages free. I think it is something like O(log or sqrt total pages), ie.
similar to what we use for our pages_min sizing, isn't it?


> They simply aren't useable once the system fragments.  I think we can also 
> all agree that 100% defragmentation is impossible without rewriting the 
> kernel to avoid the hard-coded virtual->physical relationship we have now.
> 
> With that said, the only remaining question I see is whether we need order>0 
> allocations.  If we do, then Mel's patches are clearly the right thing to do.  
> They have received a lot of testing (if just by virtue of being in -mm for so 
> long), and have shown to greatly increase the availability of order>0 pages.
> 
> The sheer list of patches lined up behind this set is strong evidence that 
> there are useful features which depend on a working order>0.  When you add in 
> the existing code that has to struggle with allocation failures or resort to 
> special pools (ie hugetlbfs), I see a clear vote for the need for this patch.

Really the only patches so far that I think have convincing reasons are
memory unplug and hugepage, and both of those can get a long way by using
a reserve zone (note it isn't entirely reserved, but still available for
things like pagecache). Beyond that, is there a big demand, and do we
want to make this fundamental change in direction in the kernel to
satisfy that demand?
 

> Some object because order>0 will still be able to fail.  I point out that 
> order==0 can also fail, though we go to great lengths to prevent it.  Mel's 
> patches raise the success rate of order>0 to within a few percent of 
> order==0.  All this means is callers will need to decide how to handle the 
> infrequent failure.  This should be true no matter what the order.

So small ones like order-1 and 2 seem reasonably good right now AFAIKS.
If you perhaps want to say start using order-4  pages for slab or
some other kernel memory allocations, then you can run into the situation
where memory gets fragmented such that you have one sixteenth of your
memory actualy used but you can't allocate from any of your slabs because
there are no order-4 pages left. I guess this is a big difference between
order-low failures and order-high.


> 
> I strongly vote for merging these patches.  Let's get them in mainline where 
> they can do some good.
> 
> Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
