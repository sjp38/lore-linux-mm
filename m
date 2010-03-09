Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 48A776B00C3
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 06:29:55 -0500 (EST)
Date: Tue, 9 Mar 2010 11:29:35 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] page-allocator: Check zone pressure when batch of
	pages are freed
Message-ID: <20100309112934.GE4883@csn.ul.ie>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <1268048904-19397-3-git-send-email-mel@csn.ul.ie> <20100309095342.GD8653@laptop> <20100309100835.GA4883@csn.ul.ie> <20100309102345.GG8653@laptop> <20100309103608.GD4883@csn.ul.ie> <20100309111117.GI8653@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100309111117.GI8653@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 09, 2010 at 10:11:18PM +1100, Nick Piggin wrote:
> On Tue, Mar 09, 2010 at 10:36:08AM +0000, Mel Gorman wrote:
> > On Tue, Mar 09, 2010 at 09:23:45PM +1100, Nick Piggin wrote:
> > > On Tue, Mar 09, 2010 at 10:08:35AM +0000, Mel Gorman wrote:
> > > > On Tue, Mar 09, 2010 at 08:53:42PM +1100, Nick Piggin wrote:
> > > > > Cool, you found this doesn't hurt performance too much?
> > > > > 
> > > > 
> > > > Nothing outside the noise was measured. I didn't profile it to be
> > > > absolutly sure but I expect it's ok.
> > > 
> > > OK. Moving the waitqueue cacheline out of the fastpath footprint
> > > and doing the flag thing might be a good idea?
> > > 
> > 
> > Probably, I'll do it as a separate micro-optimisation patch so it's
> > clear what I'm doing.
> 
> Fair enough.
> 
> > > > > Can't you remove the check from the reclaim code now? (The check
> > > > > here should give a more timely wait anyway)
> > > > > 
> > > > 
> > > > I'll try and see what the timing and total IO figures look like.
> > > 
> > > Well reclaim goes through free_pages_bulk anyway, doesn't it? So
> > > I don't see why you would have to run any test.
> > >  
> > 
> > It should be fine but no harm in double checking. The tests I'm doing
> > are not great anyway. I'm somewhat depending on people familar with
> > IO-related performance testing to give this a whirl or tell me how they
> > typically benchmark low-memory situations.
> 
> I don't really like that logic. It makes things harder to understand
> down the road if you have double checks.

There *should* be no difference and that is my expectation. If there is,
it means I'm missing something important. Hence, the double check.

> > > > > This is good because it should eliminate most all cases of extra
> > > > > waiting. I wonder if you've also thought of doing the check in the
> > > > > allocation path too as we were discussing? (this would give a better
> > > > > FIFO behaviour under memory pressure but I could easily agree it is not
> > > > > worth the cost)
> > > > > 
> > > > 
> > > > I *could* make the check but as I noted in the leader, there isn't
> > > > really a good test case that determines if these changes are "good" or
> > > > "bad". Removing congestion_wait() seems like an obvious win but other
> > > > modifications that alter how and when processes wait are less obvious.
> > > 
> > > Fair enough. But we could be sure it increases fairness, which is a
> > > good thing. So then we'd just have to check it against performance.
> > > 
> > 
> > Ordinarily, I'd agree but we've seen bug reports before from applications
> > that depended on unfairness for good performance. dbench figures depended
> > at one point in unfair behaviour (specifically being allowed to dirty the
> > whole system). volanomark was one that suffered when the scheduler became
> > more fair (think sched_yield was also a biggie). The new behaviour was
> > better and arguably the applications were doing the wrong thing but I'd
> > still like to treat "increase fairness in the page allocator" as a
> > separate patch as a result.
> 
> Yeah sure it would be done as another patch. I don't think there is much
> question that making things fairer is better. Especially if the
> alternative is a theoretical starvation.
> 

Agreed.

> That's not to say that batching shouldn't then be used to help improve
> performance of fairly scheduled resources. But it should be done in a
> carefully designed and controlled way, so that neither the fairness /
> starvation, nor the good performance from batching, depend on timing
> and behaviours of the hardware interconnect etc.
> 

Indeed. Batching is less clear-cut in this context. We are already
batching on a per-CPU basis but not on a per-process basis. My feeling
is that the problem to watch out for with queueing in the allocation
path is 2+ processes waiting on the queue and then allocating too much
on the per-cpu lists. Easy enough to handle that one but there are
probably a few more gotchas in there somewhere. Will revisit for sure
though.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
