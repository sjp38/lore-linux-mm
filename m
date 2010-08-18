Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id CA4AE6B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 04:51:40 -0400 (EDT)
Date: Wed, 18 Aug 2010 09:51:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
	NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100818085123.GU19797@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100816094350.GH19797@csn.ul.ie> <20100816160623.GB15103@cmpxchg.org> <20100817101655.GN19797@csn.ul.ie> <20100817142040.GA3884@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100817142040.GA3884@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 2010 at 11:20:40PM +0900, Minchan Kim wrote:
> On Tue, Aug 17, 2010 at 11:16:55AM +0100, Mel Gorman wrote:
> > Well, the drift can be either direction because drift can be due to pages
> > being either freed or allocated. e.g. it could be something like
> > 
> > NR_FREE_PAGES		CPU 0			CPU 1		Actual Free
> > 128			-32			 +64		   160
> > 
> > Because CPU 0 was allocating pages while CPU 1 was freeing them but that
> > is not what is important here. At any given time, the NR_FREE_PAGES can be
> > wrong by as much as
> > 
> > num_online_cpus * (threshold - 1)
> 
> That's the answer I expected.
> As I mentioned previous mail, we need to consider allocation path.
> But you already have been considered it by partially in here. 
> Yes. It looks good to me. :)
> 
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 

Thanks.

> > 
> > As kswapd goes back to sleep when the high watermark is reached, it's important
> > that it has actually reached the watermark before sleeping.  Similarly,
> > if an allocator is checking the low watermark, it needs an accurate count.
> > Hence a more careful accounting for NR_FREE_PAGES should happen when the
> > number of free pages is within
> > 
> > high_watermark + (num_online_cpus * (threshold - 1))
> > 
> > Only checking when kswapd is awake still leaves a window between the low
> > and min watermark when we could breach the watermark but I'm expecting it
> > can only happen for at worst one allocation. After that, kswapd wakes
> > and the count becomes accurate again.
> 
> I can't understand the point. 
> Now kswapd starts from below low wmark and stops until high wmark.

Correct.

> So if VM has pages of below low wmark, it could always check by zone_nr_free_pages 
> regardless of min. 
> 

The difficulty is that NR_FREE_PAGES is an estimate so for a time the VM may
not know it is below the low watermark. We can get a more accurate view but
it's costly so we want to avoid that cost whenever we can.

> What's a window low and min wmark? Maybe I can miss your point. 
> 

The window is due to the fact kswapd is not awake yet. The window is because
kswapd might not be awake as NR_FREE_PAGES is higher than it should be. The
system is really somewhere between the low and min watermark but we are not
taking the accurate measure until kswapd gets woken up. The first allocation
to notice we are below the low watermark (be it due to vmstat refreshing or
that NR_FREE_PAGES happens to report we are below the watermark regardless of
any drift) wakes kswapd and other callers then take an accurate count hence
"we could breach the watermark but I'm expecting it can only happen for at
worst one allocation".

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
