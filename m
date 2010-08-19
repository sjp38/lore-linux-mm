Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A98006B02B1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 11:46:47 -0400 (EDT)
Received: by pwi3 with SMTP id 3so992137pwi.14
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 08:46:46 -0700 (PDT)
Date: Fri, 20 Aug 2010 00:46:38 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100819154638.GF6805@barrios-desktop>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
 <1281951733-29466-3-git-send-email-mel@csn.ul.ie>
 <20100816094350.GH19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100816094350.GH19797@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 16, 2010 at 10:43:50AM +0100, Mel Gorman wrote:
> On Mon, Aug 16, 2010 at 10:42:12AM +0100, Mel Gorman wrote:
> > Ordinarily watermark checks are made based on the vmstat NR_FREE_PAGES as
> > it is cheaper than scanning a number of lists. To avoid synchronization
> > overhead, counter deltas are maintained on a per-cpu basis and drained both
> > periodically and when the delta is above a threshold. On large CPU systems,
> > the difference between the estimated and real value of NR_FREE_PAGES can be
> > very high. If the system is under both load and low memory, it's possible
> > for watermarks to be breached. In extreme cases, the number of free pages
> > can drop to 0 leading to the possibility of system livelock.
> > 
> > This patch introduces zone_nr_free_pages() to take a slightly more accurate
> > estimate of NR_FREE_PAGES while kswapd is awake.  The estimate is not perfect
> > and may result in cache line bounces but is expected to be lighter than the
> > IPI calls necessary to continually drain the per-cpu counters while kswapd
> > is awake.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> And the second I sent this, I realised I had sent a slightly old version
> that missed a compile-fix :(
> 
> ==== CUT HERE ====
> mm: page allocator: Calculate a better estimate of NR_FREE_PAGES when memory is low and kswapd is awake
> 
> Ordinarily watermark checks are made based on the vmstat NR_FREE_PAGES as
> it is cheaper than scanning a number of lists. To avoid synchronization
> overhead, counter deltas are maintained on a per-cpu basis and drained both
> periodically and when the delta is above a threshold. On large CPU systems,
> the difference between the estimated and real value of NR_FREE_PAGES can be
> very high. If the system is under both load and low memory, it's possible
> for watermarks to be breached. In extreme cases, the number of free pages
> can drop to 0 leading to the possibility of system livelock.

Mel. Could you consider normal(or small) system but has two core at least?
I means we apply you rule according to the number of CPU and RAM size. (ie,
threshold value). 
Now mobile system begin to have two core in system and above 1G RAM. 
Such case, it has threshold 8.

It is unlikey to happen livelock.
Is it worth to have such overhead in such system? 
What do you think?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
