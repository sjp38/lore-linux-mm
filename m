Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 673726B004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 17:44:46 -0400 (EDT)
Date: Wed, 30 Sep 2009 23:05:42 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/4] slqb: Record what node is local to a kmem_cache_cpu
Message-ID: <20090930220541.GA31530@csn.ul.ie>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie> <1253624054-10882-3-git-send-email-mel@csn.ul.ie> <84144f020909220638l79329905sf9a35286130e88d0@mail.gmail.com> <20090922135453.GF25965@csn.ul.ie> <84144f020909221154x820b287r2996480225692fad@mail.gmail.com> <20090922185608.GH25965@csn.ul.ie> <20090930144117.GA17906@csn.ul.ie> <alpine.DEB.1.10.0909301053550.9450@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909301053550.9450@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 30, 2009 at 11:06:04AM -0400, Christoph Lameter wrote:
> On Wed, 30 Sep 2009, Mel Gorman wrote:
> 
> > Ok, so I spent today looking at this again. The problem is not with faulty
> > drain logic as such. As frees always place an object on a remote list
> > and the allocation side is often (but not always) allocating a new page,
> > a significant number of objects in the free list are the only object
> > in a page. SLQB drains based on the number of objects on the free list,
> > not the number of pages. With many of the pages having only one object,
> > the freelists are pinning a lot more memory than expected.  For example,
> > a watermark to drain of 512 could be pinning 2MB of pages.
> 
> No good. So we are allocating new pages from somewhere allocating a
> single object and putting them on the freelist where we do not find them
> again.

Yes

> This is bad caching behavior as well.
> 

Yes, I suppose it would be as it's not using the hottest object. The
fact it OOM storms is a bit more important than poor caching behaviour
but hey :/

> > The drain logic could be extended to track not only the number of objects on
> > the free list but also the number of pages but I really don't think that is
> > desirable behaviour. I'm somewhat running out of sensible ideas for dealing
> > with this but here is another go anyway that might be more palatable than
> > tracking what a "local" node is within the slab.
> 
> SLUB avoids that issue by having a "current" page for a processor. It
> allocates from the current page until its exhausted. It can use fast path
> logic both for allocations and frees regardless of the pages origin. The
> node fallback is handled by the page allocator and that one is only
> involved when a new slab page is needed.
> 

This is essentially the "unqueued" nature of SLUB. It's objective "I have this
page here which I'm going to use until I can't use it no more and will depend
on the page allocator to sort my stuff out". I have to read up on SLUB up
more to see if it's compatible with SLQB or not though. In particular, how
does SLUB deal with frees from pages that are not the "current" page? SLQB
does not care what page the object belongs to as long as it's node-local
as the object is just shoved onto a LIFO for maximum hotness.

> SLAB deals with it in fallback_alloc(). It scans the nodes in zonelist
> order for free objects of the kmem_cache and then picks up from the
> nearest node. Ugly but it works. SLQB would have to do something similar
> since it also has the per node object bins that SLAB has.
> 

In a real sense, this is what the patch ends up doing. When it fails to
get something locally but sees that the local node is memoryless, it
will check the remote node lists in zonelist order. I think that's
reasonable behaviour but I'm biased because I just want the damn machine
to boot again. What do you think? Pekka, Nick?

> The local node for a memoryless node may not exist at all since there may
> be multiple nodes at the same distance to the memoryless node. So at
> mininum you would have to manage a set of local nodes. If you have the set
> then you also would need to consider memory policies. During bootup you
> would have to simulate the interleave mode in effect. After bootup you
> would have to use the tasks policy.
> 

I think SLQBs treatment of memory policies needs to be handled as a separate
problem. It's less than perfect at the moment, more of that below.

> This all points to major NUMA issues in SLQB. This is not arch specific.
> SLQB cannot handle memoryless nodes at this point.
> 
> > This patch alters the allocation path. If the allocation from local
> > lists fails and the local node is memoryless, an attempt will be made to
> > allocate from the remote lists before going to the page allocator.
> 
> Are the allocation attempts from the remote lists governed by memory
> policies?

It does to some extent. When selecting a node zonelist, it takes the
current memory policy into account but at a glance, it does not appear
to obey a policy that restricts the available nodes.

> Otherwise you may create imbalances on neighboring nodes.
> 

I haven't thought about this aspect of things a whole lot to be honest.
It's not the problem at hand.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
