Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 732836B02BD
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 12:45:31 -0400 (EDT)
Received: by pwi3 with SMTP id 3so1028289pwi.14
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 09:45:44 -0700 (PDT)
Date: Fri, 20 Aug 2010 01:45:34 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100819164534.GB1345@barrios-desktop>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
 <1281951733-29466-3-git-send-email-mel@csn.ul.ie>
 <20100816094350.GH19797@csn.ul.ie>
 <20100819154638.GF6805@barrios-desktop>
 <20100819160612.GF19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100819160612.GF19797@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 05:06:12PM +0100, Mel Gorman wrote:
> On Fri, Aug 20, 2010 at 12:46:38AM +0900, Minchan Kim wrote:
 > Mel. Could you consider normal(or small) system but has two core at least?
> 
> I did consider it but I was not keen on the idea of small systems behaving
> very differently to large systems in this regard. I thought there was a
> danger that a problem problem would be hidden by such a move.
> 
> > I means we apply you rule according to the number of CPU and RAM size. (ie,
> > threshold value). 
> > Now mobile system begin to have two core in system and above 1G RAM. 
> > Such case, it has threshold 8.
> > 
> > It is unlikey to happen livelock.
> > Is it worth to have such overhead in such system? 
> > What do you think?
> > 
> 
> Such overhead could be avoided if we made a check like the following in
> refresh_zone_stat_thresholds()
> 
>                 /*
>                  * Only set percpu_drift_mark if there is a danger that
>                  * NR_FREE_PAGES reports the low watermark is ok when in fact
>                  * the min watermark could be breached by an allocation
>                  */
>                 tolerate_drift = low_wmark_pages(zone) - min_wmark_pages(zone);
>                 max_drift = num_online_cpus() * threshold;
>                 if (max_drift > tolerate_drift)
>                         zone->percpu_drift_mark = high_wmark_pages(zone)
> 					+ max_drift;
> 
> Would this be preferable?

Yes. It looks good to me. 

> 
> -- 
> Mel Gorman
> Part-time Phd Student                          Linux Technology Center
> University of Limerick                         IBM Dublin Software Lab

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
