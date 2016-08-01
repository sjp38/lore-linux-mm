Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 08FC26B0253
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 19:45:45 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id pp5so270285671pac.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 16:45:45 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f66si37471787pfc.168.2016.08.01.16.45.43
        for <linux-mm@kvack.org>;
        Mon, 01 Aug 2016 16:45:43 -0700 (PDT)
Date: Tue, 2 Aug 2016 08:46:39 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: bail out in shrin_inactive_list
Message-ID: <20160801234639.GA6770@bbox>
References: <1469433119-1543-1-git-send-email-minchan@kernel.org>
 <20160729141130.GC2034@cmpxchg.org>
MIME-Version: 1.0
In-Reply-To: <20160729141130.GC2034@cmpxchg.org>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 29, 2016 at 10:11:30AM -0400, Johannes Weiner wrote:
> On Mon, Jul 25, 2016 at 04:51:59PM +0900, Minchan Kim wrote:
> > With node-lru, if there are enough reclaimable pages in highmem
> > but nothing in lowmem, VM can try to shrink inactive list although
> > the requested zone is lowmem.
> > 
> > The problem is direct reclaimer scans inactive list is fulled with
> > highmem pages to find a victim page at a reqested zone or lower zones
> > but the result is that VM should skip all of pages. It just burns out
> > CPU. Even, many direct reclaimers are stalled by too_many_isolated
> > if lots of parallel reclaimer are going on although there are no
> > reclaimable memory in inactive list.
> > 
> > I tried the experiment 4 times in 32bit 2G 8 CPU KVM machine
> > to get elapsed time.
> > 
> > 	hackbench 500 process 2
> > 
> > = Old =
> > 
> > 1st: 289s 2nd: 310s 3rd: 112s 4th: 272s
> > 
> > = Now =
> > 
> > 1st: 31s  2nd: 132s 3rd: 162s 4th: 50s.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> > I believe proper fix is to modify get_scan_count. IOW, I think
> > we should introduce lruvec_reclaimable_lru_size with proper
> > classzone_idx but I don't know how we can fix it with memcg
> > which doesn't have zone stat now. should introduce zone stat
> > back to memcg? Or, it's okay to ignore memcg?
> 
> You can fully ignore memcg and kmemcg. They only care about the
> balance sheet - page in, page out - never mind the type of page.
> 
> If you are allocating a slab object and there is no physical memory,
> you'll wake kswapd or enter direct reclaim with the restricted zone
> index. If you then try to charge the freshly allocated page or object
> but hit the limit, kmem or otherwise, you'll enter memcg reclaim that
> is not restricted and only cares about getting usage + pages < limit.

Thanks. I got understood.

> 
> I agree that it might be better to put this logic in get_scan_count()
> and set both nr[lru] as well as *lru_pages according to the pages that
> are eligible for the given reclaim index.
> 
> if (global_reclaim(sc))
>   add zone stats from 0 to sc->reclaim_idx
> else
>   use lruvec_lru_size()

Yeb, I already sent it.
http://lkml.kernel.org/r/1469604588-6051-2-git-send-email-minchan@kernel.org

Thanks for the review, Johannes!

> 
> It's a bit unfortunate that abstractions like the lruvec fall apart
> when we have to reconstruct zones ad-hoc now, but I don't see any
> obvious way around it...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
