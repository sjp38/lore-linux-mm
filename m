Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 35F9A6B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 05:56:13 -0400 (EDT)
Date: Fri, 27 Apr 2012 10:56:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3] mm: compaction: handle incorrect Unmovable type
 pageblocks
Message-ID: <20120427095608.GI15299@suse.de>
References: <201204261015.54449.b.zolnierkie@samsung.com>
 <20120426143620.GF15299@suse.de>
 <4F996F8B.1020207@redhat.com>
 <20120426164713.GG15299@suse.de>
 <4F99EF22.8070600@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F99EF22.8070600@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Fri, Apr 27, 2012 at 09:58:10AM +0900, Minchan Kim wrote:
> On 04/27/2012 01:47 AM, Mel Gorman wrote:
> 
> > On Thu, Apr 26, 2012 at 11:53:47AM -0400, Rik van Riel wrote:
> >> On 04/26/2012 10:36 AM, Mel Gorman wrote:
> >>
> >>> Hmm, at what point does COMPACT_ASYNC_FULL get used? I see it gets
> >>> used for the proc interface but it's not used via the page allocator at
> >>> all.
> >>
> >> He is using COMPACT_SYNC for the proc interface, and
> >> COMPACT_ASYNC_FULL from kswapd.
> >>
> > 
> > Ah, yes, of course. My bad.
> > 
> > Even that is not particularly satisfactory though as it's depending on
> > kswapd to do the work so it's a bit of a race to see if kswapd completes
> > the job before the page allocator needs it.
> 
> 
> It was a direction by my review.

Ah.

> In my point, I don't want to add more latency in direct reclaim async path if we can
> although reclaim is already slow path.
> 

Your statement was

   Direct reclaim latency is critical on latency sensitive applications(of
   course, you can argue it's already very slow once we reach this path,
   but at least, let's not increase more overhead if we can) so I think
   it would be better to use ASYNC_PARTIAL.  If we fail to allocate in
   this phase, we set it with COMPACTION_SYNC in next phase, below code.

If a path is latency sensitive they have already lost if they are in this
path. They have entered compaction and may enter direct reclaim shortly
so latency is bad at this point. If the application is latency sensitive
they probably should disable THP to avoid any spikes due to THP allocation.

So I still maintain that the page allocator should not be depending on
kswapd to do the work for it. If the caller wants high-order pages, it
must be prepared to pay the cost of allocation.

> If async direct reclaim fails to compact memory with COMPACT_ASYNC_PARTIAL,
> it ends up trying to compact memory with COMPACT_SYNC, again so it would
> be no problem to allocate big order page and it's as-it-is approach by
> async and sync mode.
> 

Is a compromise whereby a second pass consider only MIGRATE_UNMOVABLE
pageblocks for rescus and migration targets acceptable? It would be nicer
again if try_to_compact_pages() still accepted a "sync" parameter and would
decide itself if a COMPACT_ASYNC_FULL pass was necessary when sync==false.

> While latency is important in direct reclaim, kswapd isn't.

That does not mean we should tie up kswapd in compaction.c for longer
than is necessary. It should be getting out of compaction ASAP in case
reclaim is necessary.

> So I think using COMPACT_ASYNC_FULL in kswapd makes sense.
> 

I'm not convinced but am not willing to push on it either. I do think
that the caller of the page allocator does have to use
COMPACT_ASYNC_FULL though and cannot be depending on kswapd to do the
work.

> > <SNIP>
> >
> > This goes back to the same problem of we do not know how many
> > MIGRATE_UNMOVABLE pageblocks are going to be encountered in advance However,
> > I see your point.
> > 
> > Instead of COMPACT_ASYNC_PARTIAL and COMPACT_ASYNC_FULL should we have
> > COMPACT_ASYNC_MOVABLE and COMPACT_ASYNC_UNMOVABLE? The first pass from
> > the page allocator (COMPACT_ASYNC_MOVABLE) would only consider MOVABLE
> > blocks as migration targets. The second pass (COMPACT_ASYNC_UNMOVABLE)
> > would examine UNMOVABLE blocks, rescue them and use what blocks it
> > rescues as migration targets. The third pass (COMPACT_SYNC) would work
> 
> 
> It does make sense.
> 
> > as it does currently. kswapd would only ever use COMPACT_ASYNC_MOVABLE.
> 
> I don't get it. Why do kswapd use only COMPACT_ASYNC_MOVALBE?

Because kswapds primary responsibility is reclaim, not compaction.

> As I mentioned, latency isn't important in kswapd so I think kswapd always
> rescur unmovable block would help direct reclaim's first path(COMPACT_ASYNC
> _MOVABLE)'s success rate.
> 

Latency for kswapd can be important if processes are entering direct
reclaim because kswapd was running compaction instead of reclaim. The
cost is indirect and difficult to detect which is why I would prefer
kswapds use of compaction was as fast as possible.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
