Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id EE2D76B0033
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 16:28:47 -0400 (EDT)
Date: Tue, 23 Jul 2013 20:28:46 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: Possible deadloop in direct reclaim?
In-Reply-To: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
Message-ID: <000001400d38469d-a121fb96-4483-483a-9d3e-fc552e413892-000000@email.amazonses.com>
References: <89813612683626448B837EE5A0B6A7CB3B62F8F272@SC-VEXCH4.marvell.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lisa Du <cldu@marvell.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>

On Mon, 22 Jul 2013, Lisa Du wrote:

> Currently I met a possible deadloop in direct reclaim. After run plenty of the application, system run into a status that system memory is very fragmentized. Like only order-0 and order-1 memory left.

Can you verify that by doing a

 cat /proc/buddyinfo

?

> Then one process required a order-2 buffer but it enter an endless
> direct reclaim. From my trace log, I can see this loop already over
> 200,000 times. Kswapd was first wake up and then go back to sleep as it
> cannot rebalance this order's memory. But zone->all_unreclaimable
> remains 1. Though direct_reclaim every time returns no pages, but as
> zone->all_unreclaimable = 1, so it loop again and again. Even when
> zone->pages_scanned also becomes very large. It will block the process
> for long time, until some watchdog thread detect this and kill this
> process. Though it's in __alloc_pages_slowpath, but it's too slow right?
> Maybe cost over 50 seconds or even more.

> I think it's not as expected right?  Can we also add below check in the
> function all_unreclaimable() to terminate this loop?
>
> @@ -2355,6 +2355,8 @@ static bool all_unreclaimable(struct zonelist *zonelist,
>                         continue;
>                 if (!zone->all_unreclaimable)
>                         return false;
> +               if (sc->nr_reclaimed == 0 && !zone_reclaimable(zone))
> +                       return true;
>         }

Mel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
