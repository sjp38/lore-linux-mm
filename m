Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id B0C316B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 09:51:41 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id g10so6913523pdj.31
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 06:51:41 -0800 (PST)
Received: from psmtp.com ([74.125.245.161])
        by mx.google.com with SMTP id ai2si17184087pad.88.2013.11.21.06.51.38
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 06:51:39 -0800 (PST)
Date: Thu, 21 Nov 2013 09:51:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm, vmscan: abort futile reclaim if we've been oom killed
Message-ID: <20131121145128.GJ3556@cmpxchg.org>
References: <alpine.DEB.2.02.1311121801200.18803@chino.kir.corp.google.com>
 <20131113152412.GH707@cmpxchg.org>
 <alpine.DEB.2.02.1311131400300.23211@chino.kir.corp.google.com>
 <20131114000043.GK707@cmpxchg.org>
 <alpine.DEB.2.02.1311131639010.6735@chino.kir.corp.google.com>
 <20131118164107.GC3556@cmpxchg.org>
 <alpine.DEB.2.02.1311181712080.4292@chino.kir.corp.google.com>
 <20131120160712.GF3556@cmpxchg.org>
 <alpine.DEB.2.02.1311201803000.30862@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311201803000.30862@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 20, 2013 at 07:08:50PM -0800, David Rientjes wrote:
> On Wed, 20 Nov 2013, Johannes Weiner wrote:
> 
> > > "All other tasks" would be defined as though sharing the same mempolicy 
> > > context as the oom kill victim or the same set of cpuset mems, I'm not 
> > > sure what type of method for determining reclaim eligiblity you're 
> > > proposing to avoid pointlessly spinning without making progress.  Until an 
> > > alternative exists, my patch avoids the needless spinning and expedites 
> > > the exit, so I'll ask that it be merged.
> > 
> > I laid this out in the second half of my email, which you apparently
> > did not read:
> > 
> 
> I read it, but your proposal is incomplete, see below.
> 
> > "If we have multi-second stalls in direct reclaim then it should be
> >  fixed for all direct reclaimers.  The problem is not only OOM kill
> >  victims getting stuck, it's every direct reclaimer being stuck trying
> >  to do way too much work before retrying the allocation.
> > 
> 
> I'm addressing oom conditions here, including system, mempolicy, and 
> cpuset ooms.
> 
> I'm not addressing a large number of processes that are doing direct 
> reclaim in parallel over the same set of zones.  That would be a more 
> invasive change and could potentially cause regressions because reclaim 
> would be stopped prematurely before reclaiming the given threshold.  I do 
> not have a bug report in front of me that suggests this is an issue 
> outside of oom conditions and the current behavior is actually intuitive: 
> if there are a large number of processes attempting reclaim, the demand 
> for memory from those zones is higher and it is intuitive to have reclaim 
> done in parallel up to a threshold.
> 
> >  Kswapd checks the system state after every priority cycle.  Direct
> >  reclaim should probably do the same and retry the allocation after
> >  every priority cycle or every X pages scanned, where X is something
> >  reasonable and not "up to every LRU page in the system"."
> > 
> > NAK to this incomplete drive-by fix.
> > 
> 
> This is a fix for a real-world situation that current exists in reclaim: 
> specifically, preventing unnecessary stalls in reclaim in oom conditions 
> that is known to be futile.  There is no possibility that reclaim itself 
> will be successful because of the oom condition, and that condition is the 
> only condition where reclaim is guaranteed to not be successful.  I'm sure 
> we both agree that there is no use in an oom killed process continually 
> looping in reclaim and yielding the cpu back to another process which just 
> prolongs the duration before the oom killed process can free its memory.

Yes, but you are actively avoiding the only question I have asked from
the beginning:

If there is an OOM kill, direct reclaim for a given memory context has
failed and every continuation of direct reclaim in this context is
just pointless burning of cpu cycles.  You said you have 700 processes
in direct reclaim.  Your patch allows ONE of them to exit prematurely.
What about the other 699?  There is still nothing to reclaim for them.

My proposal was: if they would all check back with the allocator more
frequently, this would properly resolve this problem.  You added an
OOM victim check after every priority cycle to solve this problem for
one task, but if we checked the watermarks as well each priority
cycle, all 700 tasks could quit useless burning of CPU cycles once
direct reclaim has failed.

> You're advocating that the allocation is retried after every priority 
> cycle as an alternative and that seems potentially racy and incomplete: if 
> 32 processes enter reclaim all doing order-0 allocations and one process 
> reclaims a page, they would all terminate reclaim and retry the 
> allocation.  31 processes would then loop the page allocator again, and 
> reenter reclaim again at the starting priority.  Much better, in my 
> opinion, would be to reclaim up to a threshold for each and then return to 
> the page allocator since all 32 processes have demand for memory; that 
> threshold is debatable, but SWAP_CLUSTER_MAX is reasonable.

They would re-enter at the next priority of course, not the same one
again.  All I suggested is retrying the allocation in between reclaim
priority cycles, I'm not sure where you are getting the rest from.

> So I would be nervous to carry the classzone_idx into direct reclaim, do 
> an alloc_flags |= ALLOC_NO_WATERMARKS iff TIF_MEMDIE, iterate the 
> zonelist, and do a __zone_watermark_ok_safe() for some watermark that's 
> greater than the low watermark to avoid finding ourselves oom again upon 
> returning to the page allocator without causing regressions in reclaim.
> 
> The page allocator already tries to allocate memory between direct reclaim 
> and calling the oom killer specifically for cases where reclaim was 
> unsuccessful for a single process because memory was freed externally.

Lol, but you complain that the direct reclaim part of this cycle is
too long!  I propose shortening it.  Why are we still having this
argument?!

> The situation I'm addressing occurs when reclaim will never be successful 
> and nothing external to it will reclaim anything that the oom kill victim 
> can use.  The non-victim processes will continue to loop through the oom 
> killer and get put to sleep since they aren't victims themselves, but in 
> the case described there are 700 processes competing for cpu all doing 
> memory allocations so that doesn't help as it normally would.  Older 
> kernels used to increase the timeslice that oom kill victims have so they 
> exit as quickly as possible, but that was removed since 341aea2bc48b 
> ("oom-kill: remove boost_dying_task_prio()").

Yes, the OOM victim should exit direct reclaim.  But so should ALL
OTHER 699 TASKS, given that there is nothing to reclaim from this
context!

I just don't get why you are so focussed on this one victim task.  The
OOM situation is not property of this one task, it's a context-wide
state.  If a context goes OOM, direct reclaim has failed and should be
stopped as soon as possible.  It does not make sense for the victim to
continue, it does not make sense for anybody else to continue.

12 priority cycles is just too long of a stretch before checking back
with the overall state of affairs, that's the real problem in my view.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
