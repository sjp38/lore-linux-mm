Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id C27D96B0032
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 01:43:11 -0400 (EDT)
Date: Thu, 1 Aug 2013 14:43:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Possible deadloop in direct reclaim?
Message-ID: <20130801054338.GD19540@bbox>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello,

On Mon, Jul 22, 2013 at 09:58:17PM -0700, Lisa Du wrote:
> Dear Sir:
> Currently I met a possible deadloop in direct reclaim. After run plenty of the application, system run into a status that system memory is very fragmentized. Like only order-0 and order-1 memory left.
> Then one process required a order-2 buffer but it enter an endless direct reclaim. From my trace log, I can see this loop already over 200,000 times. Kswapd was first wake up and then go back to sleep as it cannot rebalance this order's memory. But zone->all_unreclaimable remains 1.
> Though direct_reclaim every time returns no pages, but as zone->all_unreclaimable = 1, so it loop again and again. Even when zone->pages_scanned also becomes very large. It will block the process for long time, until some watchdog thread detect this and kill this process. Though it's in __alloc_pages_slowpath, but it's too slow right? Maybe cost over 50 seconds or even more.
> I think it's not as expected right?  Can we also add below check in the function all_unreclaimable() to terminate this loop?
> 
> @@ -2355,6 +2355,8 @@ static bool all_unreclaimable(struct zonelist *zonelist,
>                         continue;
>                 if (!zone->all_unreclaimable)
>                         return false;
> +               if (sc->nr_reclaimed == 0 && !zone_reclaimable(zone))
> +                       return true;
>         }
>          BTW: I'm using kernel3.4, I also try to search in the kernel3.9, didn't see a possible fix for such issue. Or is anyone also met such issue before? Any comment will be welcomed, looking forward to your reply!
> 
> Thanks!

I'd like to ask somethigs.

1. Do you have enabled swap?
2. Do you enable CONFIG_COMPACTION?
3. Could we get your zoneinfo via cat /proc/zoneinfo?
4. If you disabled watchdog thread, you could see OOM sometime
   although it takes very long time?


> 
> Best Regards
> Lisa Du
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
