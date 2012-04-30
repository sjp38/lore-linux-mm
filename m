Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 3F2546B0044
	for <linux-mm@kvack.org>; Mon, 30 Apr 2012 05:16:22 -0400 (EDT)
Date: Mon, 30 Apr 2012 10:16:17 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v3] mm: compaction: handle incorrect Unmovable type
 pageblocks
Message-ID: <20120430091617.GM9226@suse.de>
References: <201204261015.54449.b.zolnierkie@samsung.com>
 <20120426143620.GF15299@suse.de>
 <4F996F8B.1020207@redhat.com>
 <20120426164713.GG15299@suse.de>
 <4F99EF22.8070600@kernel.org>
 <20120427095608.GI15299@suse.de>
 <4F9DFC9F.8090304@kernel.org>
 <20120430083152.GK9226@suse.de>
 <4F9E536D.8070508@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F9E536D.8070508@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

On Mon, Apr 30, 2012 at 05:55:09PM +0900, Minchan Kim wrote:
> > <SNIP>
> > 
> > Help maybe, but you are proposing the caller of fork() does not do the work
> > necessary to allocate the order-2 page (using ASYNC_PARTIAL, ASYNC_FULL
> > and SYNC) and instead depends on kswapd to do it.
> 
> 
> Hmm, there was misunderstanding.
> I agreed your page allocator suggestion after you suggest AYNC_PARTIAL, ASYNC_FULL and sync.
> The concern was only kswapd. :)
> 

Understood :)

> >> <SNIP>
> >> Why do you think compaction and reclaim by separate?
> >> If kswapd starts compaction, it means someone in direct reclaim path request
> >> to kswapd to get a big order page.
> > 
> > It's not all about high order pages. If kswapd is running compaction and a
> > caller needs an order-0 page it may enter direct reclaim instead which is
> > worse from a latency perspective. The possibility for this situation should
> > be limited as much as possible without a very strong compelling reason.I
> > do not think there is a compelling reason right now to take the risk.
> 
> Hmm, I understand your point.
> Suggestion:
> Couldn't we can coded to give up kswapd's compaction 
> immediately if another task requests order-0 in direct reclaim path?
> 

That would be desirable and it's possible you can do it by altering
slightly how pgdat->classzone_idx so that it's default value is MAX_ZONE
or something similar. If that value changes from its default and kswapd
is in compaction, it can decide whether to stop compaction or not. It
might decide to continue compaction if it has been woken for a
high-order allocation for example.

> >> So I think compaction is a part of reclaim.
> >> In this case, compaction should be necessary.
> >>
> >>>
> >>>> So I think using COMPACT_ASYNC_FULL in kswapd makes sense.
> >>>>
> >>>
> >>> I'm not convinced but am not willing to push on it either. I do think
> >>> that the caller of the page allocator does have to use
> >>> COMPACT_ASYNC_FULL though and cannot be depending on kswapd to do the
> >>> work.
> >>
> >> I agree your second stage reclaiming in direct reclaim.
> >> 1. ASYNC-MOVABLE only
> >> 2. ASYNC-UNMOVABLE only
> >> 3. SYNC
> >>
> > 
> > Ok, then can we at least start with that? Specifically that the
> > page allocator continue to pass in sync to try_to_compact_pages() and
> > try_to_compact_pages() doing compaction first as ASYNC_PARTIAL and then
> > deciding whether it should do a second pass as ASYNC_FULL?
> 
> Yeb. We can proceed second pass once we found many unmovalbe page blocks
> during first ASYNC_PARTIAL compaction.
> 

Exactly.

> >> Another reason we should check unmovable page block in kswapd is that we should consider
> >> atomic allocation where is only place kswapd helps us.
> >> I hope that reason would convince you.
> >>
> > 
> > It doesn't really. High-order atomic allocations are something that should
> > be avoided as much as possible and the longer kswapd runs compaction the
> > greater the risk that processes stall in direct reclaim unnecessarily.
> > I know the current logic of kswapd using compaction.c is meant to help high
> > order atomics but that does not mean I think kswapd should spend even more
> > time in compaction.c without a compelling use case.
> > 
> 
> My suggestion may mitigate the problem.
> 

Yes, it may.

> > At the very least, make kswapd using ASYNC_FULL a separate patch. I will
> > not ACK it without compelling data backing it up but patch 1 would be
> > there to handle Bartlomiej's adverse workload.
> 
> If I have a time, I will try it but now I don't have a time to make such data.
> So let's keep remember this discussion for trial later if we look the problem.
> 

Will do. Minimally add a link to this thread to the changelog.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
