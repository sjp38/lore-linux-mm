Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2463144088B
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 19:50:48 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i6so2489161pgr.14
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 16:50:48 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id w7si3632642pfk.52.2017.08.24.16.50.46
        for <linux-mm@kvack.org>;
        Thu, 24 Aug 2017 16:50:46 -0700 (PDT)
Date: Fri, 25 Aug 2017 08:51:11 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 0/6] proactive kcompactd
Message-ID: <20170824235111.GA29701@js1304-P5Q-DELUXE>
References: <20170727160701.9245-1-vbabka@suse.cz>
 <alpine.DEB.2.10.1708091353500.1218@chino.kir.corp.google.com>
 <20170821141014.GC1371@cmpxchg.org>
 <20170823053612.GA19689@js1304-P5Q-DELUXE>
 <502d438b-7167-5b78-c66c-0e1b47ba2434@suse.cz>
 <20170824062457.GA24656@js1304-P5Q-DELUXE>
 <07967c37-d0e5-4743-7021-109dfeb9027a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07967c37-d0e5-4743-7021-109dfeb9027a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On Thu, Aug 24, 2017 at 01:30:24PM +0200, Vlastimil Babka wrote:
> On 08/24/2017 08:24 AM, Joonsoo Kim wrote:
> >>
> >>> If someone doesn't agree with above solution, your approach looks the
> >>> second best to me. Though, there is something to optimize.
> >>>
> >>> I think that we don't need to be precise to track the pageblock's
> >>> freepage state. Compaction is a far rare event compared to page
> >>> allocation so compaction could be tolerate with false positive.
> >>>
> >>> So, my suggestion is:
> >>>
> >>> 1) Use 1 bit for the pageblock. Reusing PB_migrate_skip looks the best
> >>> to me.
> >>
> >> Wouldn't the reusing cripple the original use for the migration scanner?
> > 
> > I think that there is no serious problem. Problem happens if we set
> > PB_migrate_skip wrongly. Consider following two cases that set
> > PB_migrate_skip.
> > 
> > 1) migration scanner find that whole pages in the pageblock is pinned.
> > -> set skip -> it is cleared after one of the page is freed. No
> > problem.
> > 
> > There is a possibility that temporary pinned page is unpinned and we
> > miss this pageblock but it would be minor case.
> > 
> > 2) migration scanner find that whole pages in the pageblock are free.
> > -> set skip -> we can miss the pageblock for a long time.
> 
> On second thought, this is probably not an issue. If whole pageblock is
> free, then there's most likely no reason for compaction to be running.
> It's also not likely that migrate scanner would see a pageblock that the
> free scanner has processed previously, which is why we already use
> single bit for both scanners.

Think about the case that migration scanner see the pageblock where
all pages are free and set skip bit. Sometime after, those pages would
be used and not be freed for a long time. Compaction cannot notice
that that pageblock has migratable page and skip it for a long time.
It would be also minor case but I think that considering this case is
more safer way.

> But I realized your code seems wrong. You want to set skip bit when a
> page is freed, although for the free scanner that means a page has
> become available so we would actually want to *clear* the bit in that
> case. That could be indeed much more accurate for kcompactd (which runs
> after kswapd reclaim) than its ignore_skip_hint usage

Oops... I also realized my code is wrong. My intention is clear skip
bit when freeing the page. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
