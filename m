Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E4520600034
	for <linux-mm@kvack.org>; Thu,  1 Oct 2009 06:05:33 -0400 (EDT)
Date: Thu, 1 Oct 2009 11:40:46 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/4] slqb: Record what node is local to a kmem_cache_cpu
Message-ID: <20091001104046.GA21906@csn.ul.ie>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie> <1253624054-10882-3-git-send-email-mel@csn.ul.ie> <84144f020909220638l79329905sf9a35286130e88d0@mail.gmail.com> <20090922135453.GF25965@csn.ul.ie> <84144f020909221154x820b287r2996480225692fad@mail.gmail.com> <20090922185608.GH25965@csn.ul.ie> <20090930144117.GA17906@csn.ul.ie> <alpine.DEB.1.10.0909301053550.9450@gentwo.org> <20090930220541.GA31530@csn.ul.ie> <alpine.DEB.1.10.0909301941570.11850@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0909301941570.11850@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 30, 2009 at 07:45:22PM -0400, Christoph Lameter wrote:
> On Wed, 30 Sep 2009, Mel Gorman wrote:
> 
> > > SLUB avoids that issue by having a "current" page for a processor. It
> > > allocates from the current page until its exhausted. It can use fast path
> > > logic both for allocations and frees regardless of the pages origin. The
> > > node fallback is handled by the page allocator and that one is only
> > > involved when a new slab page is needed.
> > >
> >
> > This is essentially the "unqueued" nature of SLUB. It's objective "I have this
> > page here which I'm going to use until I can't use it no more and will depend
> > on the page allocator to sort my stuff out". I have to read up on SLUB up
> > more to see if it's compatible with SLQB or not though. In particular, how
> > does SLUB deal with frees from pages that are not the "current" page? SLQB
> > does not care what page the object belongs to as long as it's node-local
> > as the object is just shoved onto a LIFO for maximum hotness.
> 
> Frees are done directly to the target slab page if they are not to the
> current active slab page. No centralized locks. Concurrent frees from
> processors on the same node to multiple other nodes (or different pages
> on the same node) can occur.
> 

So as a total aside, SLQB has an advantage in that it always uses object
in LIFO order and is more likely to be cache hot. SLUB has an advantage
when one CPU allocates and another one frees because it potentially
avoids a cache line bounce. Might be something worth bearing in mind
when/if a comparison happens later.

> > > SLAB deals with it in fallback_alloc(). It scans the nodes in zonelist
> > > order for free objects of the kmem_cache and then picks up from the
> > > nearest node. Ugly but it works. SLQB would have to do something similar
> > > since it also has the per node object bins that SLAB has.
> > >
> >
> > In a real sense, this is what the patch ends up doing. When it fails to
> > get something locally but sees that the local node is memoryless, it
> > will check the remote node lists in zonelist order. I think that's
> > reasonable behaviour but I'm biased because I just want the damn machine
> > to boot again. What do you think? Pekka, Nick?
> 
> Look at fallback_alloc() in slab. You can likely copy much of it. It
> considers memory policies and cpuset constraints.
> 

True, it looks like some of the logic should be taken from there all right. Can
the treatment of memory policies be dealt with as a separate thread though? I'd
prefer to get memoryless nodes sorted out before considering the next two
problems (per-cpu instability on ppc64 and memory policy handling in SLQB).

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
