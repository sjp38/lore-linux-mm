Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6666B038A
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 02:19:45 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 1so82653711pgz.5
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 23:19:45 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id c9si6708277pge.126.2017.03.01.23.19.43
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 23:19:44 -0800 (PST)
Date: Thu, 2 Mar 2017 16:17:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Still OOM problems with 4.9er/4.10er kernels
Message-ID: <20170302071721.GA32632@bbox>
References: <20161209134025.GB4342@dhcp22.suse.cz>
 <a0bf765f-d5dd-7a51-1a6b-39cbda56bd58@wiesinger.com>
 <20161223025505.GA30876@bbox>
 <c2fe9c45-e25f-d3d6-7fe7-f91e353bc579@wiesinger.com>
 <20170104091120.GD25453@dhcp22.suse.cz>
 <82bce413-1bd7-7f66-1c3d-0d890bbaf6f1@wiesinger.com>
 <20170227090236.GA2789@bbox>
 <20170227094448.GF14029@dhcp22.suse.cz>
 <20170228051723.GD2702@bbox>
 <20170228081223.GA26792@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20170228081223.GA26792@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Gerhard Wiesinger <lists@wiesinger.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>

Hi Michal,

On Tue, Feb 28, 2017 at 09:12:24AM +0100, Michal Hocko wrote:
> On Tue 28-02-17 14:17:23, Minchan Kim wrote:
> > On Mon, Feb 27, 2017 at 10:44:49AM +0100, Michal Hocko wrote:
> > > On Mon 27-02-17 18:02:36, Minchan Kim wrote:
> > > [...]
> > > > >From 9779a1c5d32e2edb64da5cdfcd6f9737b94a247a Mon Sep 17 00:00:00 2001
> > > > From: Minchan Kim <minchan@kernel.org>
> > > > Date: Mon, 27 Feb 2017 17:39:06 +0900
> > > > Subject: [PATCH] mm: use up highatomic before OOM kill
> > > > 
> > > > Not-Yet-Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > ---
> > > >  mm/page_alloc.c | 14 ++++----------
> > > >  1 file changed, 4 insertions(+), 10 deletions(-)
> > > > 
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 614cd0397ce3..e073cca4969e 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -3549,16 +3549,6 @@ should_reclaim_retry(gfp_t gfp_mask, unsigned order,
> > > >  		*no_progress_loops = 0;
> > > >  	else
> > > >  		(*no_progress_loops)++;
> > > > -
> > > > -	/*
> > > > -	 * Make sure we converge to OOM if we cannot make any progress
> > > > -	 * several times in the row.
> > > > -	 */
> > > > -	if (*no_progress_loops > MAX_RECLAIM_RETRIES) {
> > > > -		/* Before OOM, exhaust highatomic_reserve */
> > > > -		return unreserve_highatomic_pageblock(ac, true);
> > > > -	}
> > > > -
> > > >  	/*
> > > >  	 * Keep reclaiming pages while there is a chance this will lead
> > > >  	 * somewhere.  If none of the target zones can satisfy our allocation
> > > > @@ -3821,6 +3811,10 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> > > >  	if (read_mems_allowed_retry(cpuset_mems_cookie))
> > > >  		goto retry_cpuset;
> > > >  
> > > > +	/* Before OOM, exhaust highatomic_reserve */
> > > > +	if (unreserve_highatomic_pageblock(ac, true))
> > > > +		goto retry;
> > > > +
> > > 
> > > OK, this can help for higher order requests when we do not exhaust all
> > > the retries and fail on compaction but I fail to see how can this help
> > > for order-0 requets which was what happened in this case. I am not
> > > saying this is wrong, though.
> > 
> > The should_reclaim_retry can return false although no_progress_loop is less
> > than MAX_RECLAIM_RETRIES unless eligible zones has enough reclaimable pages
> > by the progress_loop.
> 
> Yes, sorry I should have been more clear. I was talking about this
> particular case where we had a lot of reclaimable pages (a lot of
> anonymous with the swap available).

This reports shows two problems. Why we see OOM 1) enough *free* pages and
2) enough *freeable* pages.

I just pointed out 1) and sent the patch to solve it.

About 2), one of my imaginary scenario is inactive anon list is full of
pinned pages so VM can unmap them successfully in shrink_page_list but fail
to free due to increased page refcount. In that case, the page will be added
to inactive anonymous LRU list again without activating so inactive_list_is_low
on anonymous LRU is always false. IOW, there is no deactivation from active list.

It's just my picture without no clue. ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
