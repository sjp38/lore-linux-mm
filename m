Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DA5E36B0096
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 07:12:17 -0500 (EST)
Date: Fri, 3 Dec 2010 12:11:53 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] vmscan: make kswapd use a correct order
Message-ID: <20101203121153.GB13268@csn.ul.ie>
References: <1291305649-2405-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1291305649-2405-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 03, 2010 at 01:00:49AM +0900, Minchan Kim wrote:
> If we wake up prematurely, it means we should keep going on
> reclaiming not new order page but at old order page.
> Sometime new order can be smaller than old order by below
> race so it could make failure of old order page reclaiming.
> 
> T0: Task 1 wakes up kswapd with order-3
> T1: So, kswapd starts to reclaim pages using balance_pgdat
> T2: Task 2 wakes up kswapd with order-2 because pages reclaimed
> 	by T1 are consumed quickly.
> T3: kswapd exits balance_pgdat and will do following:
> T4-1: In beginning of kswapd's loop, pgdat->kswapd_max_order will
> 	be reset with zero.
> T4-2: 'order' will be set to pgdat->kswapd_max_order(0), since it
>         enters the false branch of 'if (order (3) < new_order (2))'
> T4-3: If previous balance_pgdat can't meet requirement of order-2
> 	free pages by high watermark, it will start reclaiming again.
>         So balance_pgdat will use order-0 to do reclaim while it
> 	really should use order-2 at the moment.
> T4-4: At last, Task 1 can't get the any page if it wanted with
> 	GFP_ATOMIC.
> 
> Reported-by: Shaohua Li <shaohua.li@intel.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Shaohua Li <shaohua.li@intel.com>
> Cc: Mel Gorman <mel@csn.ul.ie>

Acked-by: Mel Gorman <mel@csn.ul.ie>

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
