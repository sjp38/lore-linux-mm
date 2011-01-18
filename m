Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 391736B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 15:24:39 -0500 (EST)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p0IKOXxm010467
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:24:33 -0800
Received: from pvg7 (pvg7.prod.google.com [10.241.210.135])
	by kpbe16.cbf.corp.google.com with ESMTP id p0IKOUHh014672
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:24:31 -0800
Received: by pvg7 with SMTP id 7so9433pvg.11
        for <linux-mm@kvack.org>; Tue, 18 Jan 2011 12:24:30 -0800 (PST)
Date: Tue, 18 Jan 2011 12:24:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone
 is not allowed
In-Reply-To: <20110118101547.GF27152@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1101181211100.18781@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com> <20110118101547.GF27152@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011, Mel Gorman wrote:

> > wait_iff_congested(), though, uses preferred_zone to determine if the
> > congestion wait should be deferred because its dirty pages are backed by
> > a congested bdi.  This incorrectly defers the timeout and busy loops in
> > the page allocator with various cond_resched() calls if preferred_zone is
> > not allowed in the current context, usually consuming 100% of a cpu.
> > 
> 
> The current context being cpuset context or do you have other situations
> in mind?
> 

Only cpuset context will restrict certain nodes from being allocated from, 
mempolicies pass the allowed mask into the page allocator already.

> > This patch resets preferred_zone to an allowed zone in the slowpath if
> > the allocation context is constrained by current's cpuset. 
> 
> Well, preferred_zone has meaning. If it's not possible to allocate from
> that zone in the current cpuset context, it's not really preferred. Why
> not set it in the fast path so there isn't a useless call to
> get_page_from_freelist()?
> 

It may be the preferred zone even if it isn't allowed by current's cpuset 
such as if the allocation is __GFP_WAIT or the task has been oom killed 
and has the TIF_MEMDIE bit set, so the preferred zone in the fastpath is 
accurate in these cases.  In the slowpath, the former is protected by 
checking for ALLOC_CPUSET and the latter is usually only set after the 
page allocator has looped at least once and triggered the oom killer to be 
killed.

I didn't want to add a branch to test for these possibilities in the 
fastpath, however, since preferred_zone isn't of critical importance until 
it's used in the slowpath (ignoring the statistical usage).

> > It also
> > ensures preferred_zone is from the set of allowed nodes when called from
> > within direct reclaim; allocations are always constrainted by cpusets
> > since the context is always blockable.
> > 
> 
> preferred_zone should already be obeying nodemask and the set of allowed
> nodes. Are you aware of an instance where this is not the case or are
> you talking about the nodes allowed by the cpuset?
> 

In the direct reclaim path, the fix is to make sure preferred_zone is 
allowed by cpuset_current_mems_allowed since we don't need to test for 
__GFP_WAIT: it's useless to check the congestion of a zone that cannot be 
allocated from.

> > Both of these uses of cpuset_current_mems_allowed are protected by
> > get_mems_allowed().
> > ---
> >  mm/page_alloc.c |   12 ++++++++++++
> >  mm/vmscan.c     |    3 ++-
> >  2 files changed, 14 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2034,6 +2034,18 @@ restart:
> >  	 */
> >  	alloc_flags = gfp_to_alloc_flags(gfp_mask);
> >  
> > +	/*
> > +	 * If preferred_zone cannot be allocated from in this context, find the
> > +	 * first allowable zone instead.
> > +	 */
> > +	if ((alloc_flags & ALLOC_CPUSET) &&
> > +	    !cpuset_zone_allowed_softwall(preferred_zone, gfp_mask)) {
> > +		first_zones_zonelist(zonelist, high_zoneidx,
> > +				&cpuset_current_mems_allowed, &preferred_zone);
> > +		if (unlikely(!preferred_zone))
> > +			goto nopage;
> > +	}
> > +
> 
> This looks as if it would work but is there any reason why
> cpuset_current_mems_allowed is not used as the nodemask for ALLOC_CPUSET? It's
> used by ZLC with CONFIG_NUMA machines for example so it seems a little
> inconsistent. If a nodemask was supplied by the caller, it could be AND'd
> with cpuset_current_mems_allowed.
> 

ALLOC_CPUSET is checked in get_page_from_freelist() because there are 
exceptions allowed both by cpuset_zone_allowed_softwall() based on the 
state of the task and by not setting ALLOC_CPUSET in the page allocator 
based on !__GFP_WAIT.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
