Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 1F7706B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 02:22:22 -0400 (EDT)
Date: Fri, 2 Aug 2013 02:22:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/3] mm: page_alloc: fair zone allocator policy
Message-ID: <20130802062208.GP715@cmpxchg.org>
References: <1374267325-22865-1-git-send-email-hannes@cmpxchg.org>
 <1374267325-22865-4-git-send-email-hannes@cmpxchg.org>
 <20130801025636.GC19540@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130801025636.GC19540@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 01, 2013 at 11:56:36AM +0900, Minchan Kim wrote:
> Hi Hannes,
> 
> On Fri, Jul 19, 2013 at 04:55:25PM -0400, Johannes Weiner wrote:
> > Each zone that holds userspace pages of one workload must be aged at a
> > speed proportional to the zone size.  Otherwise, the time an
> > individual page gets to stay in memory depends on the zone it happened
> > to be allocated in.  Asymmetry in the zone aging creates rather
> > unpredictable aging behavior and results in the wrong pages being
> > reclaimed, activated etc.
> > 
> > But exactly this happens right now because of the way the page
> > allocator and kswapd interact.  The page allocator uses per-node lists
> > of all zones in the system, ordered by preference, when allocating a
> > new page.  When the first iteration does not yield any results, kswapd
> > is woken up and the allocator retries.  Due to the way kswapd reclaims
> > zones below the high watermark while a zone can be allocated from when
> > it is above the low watermark, the allocator may keep kswapd running
> > while kswapd reclaim ensures that the page allocator can keep
> > allocating from the first zone in the zonelist for extended periods of
> > time.  Meanwhile the other zones rarely see new allocations and thus
> > get aged much slower in comparison.
> > 
> > The result is that the occasional page placed in lower zones gets
> > relatively more time in memory, even get promoted to the active list
> > after its peers have long been evicted.  Meanwhile, the bulk of the
> > working set may be thrashing on the preferred zone even though there
> > may be significant amounts of memory available in the lower zones.
> > 
> > Even the most basic test -- repeatedly reading a file slightly bigger
> > than memory -- shows how broken the zone aging is.  In this scenario,
> > no single page should be able stay in memory long enough to get
> > referenced twice and activated, but activation happens in spades:
> > 
> >   $ grep active_file /proc/zoneinfo
> >       nr_inactive_file 0
> >       nr_active_file 0
> >       nr_inactive_file 0
> >       nr_active_file 8
> >       nr_inactive_file 1582
> >       nr_active_file 11994
> >   $ cat data data data data >/dev/null
> >   $ grep active_file /proc/zoneinfo
> >       nr_inactive_file 0
> >       nr_active_file 70
> >       nr_inactive_file 258753
> >       nr_active_file 443214
> >       nr_inactive_file 149793
> >       nr_active_file 12021
> > 
> > Fix this with a very simple round robin allocator.  Each zone is
> > allowed a batch of allocations that is proportional to the zone's
> > size, after which it is treated as full.  The batch counters are reset
> > when all zones have been tried and the allocator enters the slowpath
> > and kicks off kswapd reclaim:
> > 
> >   $ grep active_file /proc/zoneinfo
> >       nr_inactive_file 0
> >       nr_active_file 0
> >       nr_inactive_file 174
> >       nr_active_file 4865
> >       nr_inactive_file 53
> >       nr_active_file 860
> >   $ cat data data data data >/dev/null
> >   $ grep active_file /proc/zoneinfo
> >       nr_inactive_file 0
> >       nr_active_file 0
> >       nr_inactive_file 666622
> >       nr_active_file 4988
> >       nr_inactive_file 190969
> >       nr_active_file 937
> 
> First of all, I should appreciate your great work!
> It's amazing and I saw Zlatko proved it enhances real works.
> Thanks Zlatko, too!
> 
> So, I don't want to prevent merging but I think at least, we should
> discuss some issues.
> 
> The concern I have is that it could accelerate low memory pinning
> problems like mlock. Actually, I don't have such workload that makes
> pin lots of pages but that's why we introduced lowmem_reserve_ratio,
> as you know well so we should cover this issue, at least.

We are not actually using the lower zones more in terms of number of
pages at any given time, we are just using them more in terms of
allocation and reclaim rate.

Consider how the page allocator works: it will first fill up the
preferred zone, then the next best zone, etc. and then when all of
them are full, it will wake up kswapd, which will only reclaim them
back to the high watermark + balance gap.

After my change, all zones will be at the high watermarks + balance
gap during idle and between the low and high marks under load.  The
change is marginal.

The lowmem reserve makes sure, before and after, that a sizable
portion of low memory is reserved for non-user allocations.

> Other thing of my concerns is to add overhead in fast path.
> Sometime, we are really reluctant to add simple even "if" condition
> in fastpath but you are adding atomic op whenever page is allocated and
> enter slowpath whenever all of given zones's batchcount is zero.
> Yes, it's not really slow path because it could return to normal status
> without calling significant slow functions by reset batchcount of
> prepare_slowpath.

Yes, no direct reclaim should occur.  I know that it comes of a cost,
but the alternative is broken page reclaim, page cache thrashing etc.
I don't see a way around it...

Thanks for your input, Minchan!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
