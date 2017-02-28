Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 836956B038B
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 00:17:28 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id b2so3196107pgc.6
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 21:17:28 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id s9si691223pgo.309.2017.02.27.21.17.26
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 21:17:27 -0800 (PST)
Date: Tue, 28 Feb 2017 14:17:23 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
Message-ID: <20170228051723.GD2702@bbox>
References: <c4ddfc91-7c84-19ed-b69a-18403e7590f9@wiesinger.com>
 <b3d7a0f3-caa4-91f9-4148-b62cf5e23886@wiesinger.com>
 <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161223025505.GA30876@bbox>
 <c2fe9c45-e25f-d3d6-7fe7-f91e353bc579@wiesinger.com>
 <20170104091120.GD25453@dhcp22.suse.cz>
 <82bce413-1bd7-7f66-1c3d-0d890bbaf6f1@wiesinger.com>
 <20170227090236.GA2789@bbox>
 <20170227094448.GF14029@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227094448.GF14029@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Gerhard Wiesinger <lists@wiesinger.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Feb 27, 2017 at 10:44:49AM +0100, Michal Hocko wrote:
> On Mon 27-02-17 18:02:36, Minchan Kim wrote:
> [...]
> > >From 9779a1c5d32e2edb64da5cdfcd6f9737b94a247a Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Mon, 27 Feb 2017 17:39:06 +0900
> > Subject: [PATCH] mm: use up highatomic before OOM kill
> > 
> > Not-Yet-Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/page_alloc.c | 14 ++++----------
> >  1 file changed, 4 insertions(+), 10 deletions(-)
> > 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 614cd0397ce3..e073cca4969e 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3549,16 +3549,6 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
> >  		*no_progress_loops = 0;
> >  	else
> >  		(*no_progress_loops)++;
> > -
> > -	/*
> > -	 * Make sure we converge to OOM if we cannot make any progress
> > -	 * several times in the row.
> > -	 */
> > -	if (*no_progress_loops > MAX_RECLAIM_RETRIES) {
> > -		/* Before OOM, exhaust highatomic_reserve */
> > -		return unreserve_highatomic_pageblock(ac, true);
> > -	}
> > -
> >  	/*
> >  	 * Keep reclaiming pages while there is a chance this will lead
> >  	 * somewhere.  If none of the target zones can satisfy our allocation
> > @@ -3821,6 +3811,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	if (read_mems_allowed_retry(cpuset_mems_cookie))
> >  		goto retry_cpuset;
> >  
> > +	/* Before OOM, exhaust highatomic_reserve */
> > +	if (unreserve_highatomic_pageblock(ac, true))
> > +		goto retry;
> > +
> 
> OK, this can help for higher order requests when we do not exhaust all
> the retries and fail on compaction but I fail to see how can this help
> for order-0 requets which was what happened in this case. I am not
> saying this is wrong, though.

The should_reclaim_retry can return false although no_progress_loop is less
than MAX_RECLAIM_RETRIES unless eligible zones has enough reclaimable pages
by the progress_loop. In that case, unreserve_highatomic_pageblock cannot
be called so that VM can keep a pageblock(e.g., 2M) for highatomic reserve.
Then, zone_watermark_ok subtracts nr_reserved_highatomic pages for the
pass/fail decision whichs is very conservative but no choice for the hot
path performance. With that, order-0 allocation can be failed.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
