Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 06B9F6B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 17:09:17 -0400 (EDT)
Date: Wed, 11 May 2011 22:09:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110511210907.GA17898@suse.de>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
 <1305127773-10570-4-git-send-email-mgorman@suse.de>
 <alpine.DEB.2.00.1105111314310.9346@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1105111314310.9346@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, James Bottomley <James.Bottomley@hansenpartnership.com>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, May 11, 2011 at 01:38:47PM -0700, David Rientjes wrote:
> On Wed, 11 May 2011, Mel Gorman wrote:
> 
> > To avoid locking and per-cpu overhead, SLUB optimisically uses
> > high-order allocations up to order-3 by default and falls back to
> > lower allocations if they fail. While care is taken that the caller
> > and kswapd take no unusual steps in response to this, there are
> > further consequences like shrinkers who have to free more objects to
> > release any memory. There is anecdotal evidence that significant time
> > is being spent looping in shrinkers with insufficient progress being
> > made (https://lkml.org/lkml/2011/4/28/361) and keeping kswapd awake.
> > 
> > SLUB is now the default allocator and some bug reports have been
> > pinned down to SLUB using high orders during operations like
> > copying large amounts of data. SLUBs use of high-orders benefits
> > applications that are sized to memory appropriately but this does not
> > necessarily apply to large file servers or desktops.  This patch
> > causes SLUB to use order-0 pages like SLAB does by default.
> > There is further evidence that this keeps kswapd's usage lower
> > (https://lkml.org/lkml/2011/5/10/383).
> > 
> 
> This is going to severely impact slub's performance for applications on 
> machines with plenty of memory available where fragmentation isn't a 
> concern when allocating from caches with large object sizes (even 
> changing the min order of kamlloc-256 from 1 to 0!) by default for users 
> who don't use slub_max_order=3 on the command line.  SLUB relies heavily 
> on allocating from the cpu slab and freeing to the cpu slab to avoid the 
> slowpaths, so higher order slabs are important for its performance.
> 

I agree with you that there are situations where plenty of memory
means that that it'll perform much better. However, indications are
that it breaks down with high CPU usage when memory is low.  Worse,
once fragmentation becomes a problem, large amounts of UNMOVABLE and
RECLAIMABLE will make it progressively more expensive to find the
necessary pages. Perhaps with patches 1 and 2, this is not as much
of a problem but figures in the leader indicated that for a simple
workload with large amounts of files and data exceeding physical
memory that it was better off not to use high orders at all which
is a situation I'd expect to be encountered by more users than
performance-sensitive applications.

In other words, we're taking one hit or the other.

> I can get numbers for a simple netperf TCP_RR benchmark with this change 
> applied to show the degradation on a server with >32GB of RAM with this 
> patch applied.
> 

Agreed, I'd expect netperf TCP_RR or TCP_STREAM to take a hit,
particularly on a local machine where the recycling of pages will
impact it heavily.

> It would be ideal if this default could be adjusted based on the amount of 
> memory available in the smallest node to determine whether we're concerned 
> about making higher order allocations. 

It's not a function of memory size, working set size is what
is important or at least how many new pages have been allocated
recently. Fit your workload in physical memory - high orders are
great. Go larger than that and you hit problems. James' testing
indicated that kswapd CPU usage dropped to far lower levels with this
patch applied his test of untarring a large file for example.

> (Using the smallest node as a 
> metric so that mempolicies and cpusets don't get unfairly biased against.)  
> With the previous changes in this patchset, specifically avoiding waking 
> kswapd and doing compaction for the higher order allocs before falling 
> back to the min order, it shouldn't be devastating to try an order-3 alloc 
> that will fail quickly.
> 

Which is more reasonable? That an ordinary user gets a default that
is fairly safe even if benchmarks that demand the highest performance
from SLUB take a hit or that administrators running such workloads
set slub_max_order=3?

> > Signed-off-by: Mel Gorman <mgorman@suse.de>
> > ---
> >  Documentation/vm/slub.txt |    2 +-
> >  mm/slub.c                 |    2 +-
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
> > index 07375e7..778e9fa 100644
> > --- a/Documentation/vm/slub.txt
> > +++ b/Documentation/vm/slub.txt
> > @@ -117,7 +117,7 @@ can be influenced by kernel parameters:
> >  
> >  slub_min_objects=x		(default 4)
> >  slub_min_order=x		(default 0)
> > -slub_max_order=x		(default 1)
> > +slub_max_order=x		(default 0)
> 
> Hmm, that was wrong to begin with, it should have been 3.
> 

True, but I didn't see the point fixing it in a separate patch. If this
patch gets rejected, I'll submit a documentation fix.

> >  
> >  slub_min_objects allows to specify how many objects must at least fit
> >  into one slab in order for the allocation order to be acceptable.
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 1071723..23a4789 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2198,7 +2198,7 @@ EXPORT_SYMBOL(kmem_cache_free);
> >   * take the list_lock.
> >   */
> >  static int slub_min_order;
> > -static int slub_max_order = PAGE_ALLOC_COSTLY_ORDER;
> > +static int slub_max_order;
> >  static int slub_min_objects;
> >  
> >  /*

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
