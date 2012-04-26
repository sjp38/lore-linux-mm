Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 494326B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 12:47:19 -0400 (EDT)
Date: Thu, 26 Apr 2012 17:47:13 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3] mm: compaction: handle incorrect Unmovable type
 pageblocks
Message-ID: <20120426164713.GG15299@suse.de>
References: <201204261015.54449.b.zolnierkie@samsung.com>
 <20120426143620.GF15299@suse.de>
 <4F996F8B.1020207@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F996F8B.1020207@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Thu, Apr 26, 2012 at 11:53:47AM -0400, Rik van Riel wrote:
> On 04/26/2012 10:36 AM, Mel Gorman wrote:
> 
> >Hmm, at what point does COMPACT_ASYNC_FULL get used? I see it gets
> >used for the proc interface but it's not used via the page allocator at
> >all.
> 
> He is using COMPACT_SYNC for the proc interface, and
> COMPACT_ASYNC_FULL from kswapd.
> 

Ah, yes, of course. My bad.

Even that is not particularly satisfactory though as it's depending on
kswapd to do the work so it's a bit of a race to see if kswapd completes
the job before the page allocator needs it.

> >Minimally I was expecting to see if being used from the page allocator.
> 
> Makes sense, especially if we get the CPU overhead
> saving stuff that we talked about at LSF to work :)
> 

True.

> >A better option might be to track the number of MIGRATE_UNMOVABLE blocks that
> >were skipped over during COMPACT_ASYNC_PARTIAL and if it was a high
> >percentage and it looked like compaction failed then to retry with
> >COMPACT_ASYNC_FULL. If you took this option, try_to_compact_pages()
> >would still only take sync as a parameter and keep the decision within
> >compaction.c
> 
> This I don't get.
> 
> If we have a small number of MIGRATE_UNMOVABLE blocks,
> is it worth skipping over them?
> 

We do not know in advance how many MIGRATE_UNMOVABLE blocks are going to
be encountered. Even if we kept track of the number of MIGRATE_UNMOVABLE
pageblocks in the zone, it would not tell us how many pageblocks the
scanner will see.

> If we have really large number of MIGRATE_UNMOVABLE blocks,
> did we let things get out of hand?  By giving the page
> allocator this many unmovable blocks to choose from, we
> could have ended up with actually non-compactable memory.
> 

If there are a large number of MIGRATE_UNMOVABLE blocks, each with a single
unmovable page at the end of the block then the worst case situation
is that the second pass (COMPACT_ASYNC_PARTIAL being the first pass)
is useless and slow due to the scanning within MIGRATE_UNMOVABLE blocks.

When this situation occurs, I would also expect that the third pass
(COMPACT_SYNC) will also fail and then compaction will get deferred to
limit further damage.

In the average case, I would expect the large number of
MIGRATE_UNMOVABLE blocks to also be partially populated which means that
scans of these blocks will also be partial limiting the amount of
scanning we do. How much this is limited is impossible to estimate as
it's dependant on the workload.

> If we have a medium number of MIGRATE_UNMOVABLE blocks,
> is it worth doing a restart and scanning all the movable
> blocks again?
> 

This goes back to the same problem of we do not know how many
MIGRATE_UNMOVABLE pageblocks are going to be encountered in advance However,
I see your point.

Instead of COMPACT_ASYNC_PARTIAL and COMPACT_ASYNC_FULL should we have
COMPACT_ASYNC_MOVABLE and COMPACT_ASYNC_UNMOVABLE? The first pass from
the page allocator (COMPACT_ASYNC_MOVABLE) would only consider MOVABLE
blocks as migration targets. The second pass (COMPACT_ASYNC_UNMOVABLE)
would examine UNMOVABLE blocks, rescue them and use what blocks it
rescues as migration targets. The third pass (COMPACT_SYNC) would work
as it does currently. kswapd would only ever use COMPACT_ASYNC_MOVABLE.

That would avoid rescanning the movable blocks uselessly on the second
pass but should still work for Bartlomiej's workload.

What do you think?

> In other words, could it be better to always try to
> rescue the unmovable blocks?

I do not think we should always scan within unmovable blocks on the
first pass. I strongly suspect it would lead to excessive amounts of CPU
time spent in mm/compaction.c.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
