Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f177.google.com (mail-ea0-f177.google.com [209.85.215.177])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6ED6B0037
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 08:29:09 -0500 (EST)
Received: by mail-ea0-f177.google.com with SMTP id n15so478500ead.22
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 05:29:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h45si4315032eeo.193.2013.12.19.05.29.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 05:29:08 -0800 (PST)
Date: Thu, 19 Dec 2013 13:29:05 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 0/6] Configurable fair allocation zone policy v4
Message-ID: <20131219132905.GL11295@suse.de>
References: <1387395723-25391-1-git-send-email-mgorman@suse.de>
 <20131218210617.GC20038@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131218210617.GC20038@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 18, 2013 at 04:06:17PM -0500, Johannes Weiner wrote:
> On Wed, Dec 18, 2013 at 07:41:57PM +0000, Mel Gorman wrote:
> > This is still a work in progress. I know Johannes is maintaining his own
> > patch which takes a different approach and has different priorities. Michal
> > Hocko has raised concerns potentially affecting both. I'm releasing this so
> > there is a basis of comparison with Johannes' patch. It's not necessarily
> > the final shape of what we want to merge but the test results highlight
> > the current behaviour has regressed performance for basic workloads.
> > 
> > A big concern is the semantics and tradeoffs of the tunable are quite
> > involved.  Basically no matter what workload you get right, there will be
> > a workload that will be wrong. This might indicate that this really needs
> > to be controlled via memory policies or some means of detecting online
> > which policy should be used on a per-process basis.
> 
> I'm more and more agreeing with this.  As I stated in my answer to
> Michal, I may have seen this too black and white and the flipside of
> the coin as not important enough.
> 
> But it really does point to a mempolicy.  As long as we can agree on a
> default that makes most sense for users, there is no harm in offering
> a choice.  E.g. aging artifacts are simply irrelevant without reclaim
> going on, so a workload that mostly avoids it can benefit from a
> placement policy that strives for locality without any downsides.
> 

Agreed.

In a land of free ponies we could try detecting online if a process should
be using MPOL_LOCAL or MPOL_INTERLEAVE_FILE (or whatever the policy gets
called) automatically if the process is using teh system default memory
policy. Possible detection methods

1. Recent excessive fallback to remote nodes clean local node
2. If kswapd awake for long periods of time receiving excessive wakeups
   then switch the processes waking it to MPOL_INTERLEAVE_FILE. kswapd
   could track who is keeping it awake on a list. Processes switch back
   to MPOL_LOCAL after some period of time.
3. Crystal ball instruction

> > By default, this series does *not* interleave pagecache across nodes but
> > it will interleave between local zones.
> > 
> > Changelog since V3
> > o Add documentation
> > o Bring tunable in line with Johannes
> > o Common code when deciding to update the batch count and skip zones
> > 
> > Changelog since v2
> > o Drop an accounting patch, behaviour is deliberate
> > o Special case tmpfs and shmem pages for discussion
> > 
> > Changelog since v1
> > o Fix lot of brain damage in the configurable policy patch
> > o Yoink a page cache annotation patch
> > o Only account batch pages against allocations eligible for the fair policy
> > o Add patch that default distributes file pages on remote nodes
> > 
> > Commit 81c0a2bb ("mm: page_alloc: fair zone allocator policy") solved a
> > bug whereby new pages could be reclaimed before old pages because of how
> > the page allocator and kswapd interacted on the per-zone LRU lists.
> > 
> > Unfortunately a side-effect missed during review was that it's now very
> > easy to allocate remote memory on NUMA machines. The problem is that
> > it is not a simple case of just restoring local allocation policies as
> > there are genuine reasons why global page aging may be prefereable. It's
> > still a major change to default behaviour so this patch makes the policy
> > configurable and sets what I think is a sensible default.
> 
> I wrote this to Michal, too: as 3.12 was only recently released and
> its NUMA placement quite broken, I doubt that people running NUMA
> machines already rely on this aspect of global page cache placement.
> 

Doubtful. I bet some people are already depending on the local zone
interleaving though. It's nice, we want that thing.

> We should be able to restrict placement fairness to node-local zones
> exclusively for 3.12-stable and possibly for 3.13, depending on how
> fast we can agree on the interface.
> 
> I would prefer fixing the worst first so that we don't have to rush a
> user interface in order to keep global cache aging, which nobody knows
> exists yet.  But that part is simply not ready, so let's revert it.
> And then place any subsequent attempts of implementing this for NUMA
> on top of it, without depending on them for 3.12-stable and 3.13.
> 
> The following fix should produce the same outcomes on your tests:
> 
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] mm: page_alloc: revert NUMA aspect of fair allocation
>  policy
> 

Yes, it should.

I see no harm in including the change to zone_local to avoid calling
node_distance as well. I would be very surprised if there are machines
that are multiple nodes that are at LOCAL_DISTANCE. Whether you include
that or not;

Acked-by: Mel Gorman <mgorman@suse.de>

Thanks.


-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
