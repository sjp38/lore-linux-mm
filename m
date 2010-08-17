Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 88F346B01F2
	for <linux-mm@kvack.org>; Tue, 17 Aug 2010 10:20:49 -0400 (EDT)
Received: by pzk33 with SMTP id 33so2710114pzk.14
        for <linux-mm@kvack.org>; Tue, 17 Aug 2010 07:20:48 -0700 (PDT)
Date: Tue, 17 Aug 2010 23:20:40 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100817142040.GA3884@barrios-desktop>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie>
 <1281951733-29466-3-git-send-email-mel@csn.ul.ie>
 <20100816094350.GH19797@csn.ul.ie>
 <20100816160623.GB15103@cmpxchg.org>
 <20100817101655.GN19797@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100817101655.GN19797@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 2010 at 11:16:55AM +0100, Mel Gorman wrote:
> Well, the drift can be either direction because drift can be due to pages
> being either freed or allocated. e.g. it could be something like
> 
> NR_FREE_PAGES		CPU 0			CPU 1		Actual Free
> 128			-32			 +64		   160
> 
> Because CPU 0 was allocating pages while CPU 1 was freeing them but that
> is not what is important here. At any given time, the NR_FREE_PAGES can be
> wrong by as much as
> 
> num_online_cpus * (threshold - 1)

That's the answer I expected.
As I mentioned previous mail, we need to consider allocation path.
But you already have been considered it by partially in here. 
Yes. It looks good to me. :)

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

> 
> As kswapd goes back to sleep when the high watermark is reached, it's important
> that it has actually reached the watermark before sleeping.  Similarly,
> if an allocator is checking the low watermark, it needs an accurate count.
> Hence a more careful accounting for NR_FREE_PAGES should happen when the
> number of free pages is within
> 
> high_watermark + (num_online_cpus * (threshold - 1))
> 
> Only checking when kswapd is awake still leaves a window between the low
> and min watermark when we could breach the watermark but I'm expecting it
> can only happen for at worst one allocation. After that, kswapd wakes
> and the count becomes accurate again.

I can't understand the point. 
Now kswapd starts from below low wmark and stops until high wmark.
So if VM has pages of below low wmark, it could always check by zone_nr_free_pages 
regardless of min. 

What's a window low and min wmark? Maybe I can miss your point. 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
