Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id A16C96B004D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 09:46:19 -0500 (EST)
Date: Mon, 5 Nov 2012 14:46:14 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: zram OOM behavior
Message-ID: <20121105144614.GJ8218@suse.de>
References: <20121102063958.GC3326@bbox>
 <20121102083057.GG8218@suse.de>
 <20121102223630.GA2070@barrios>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20121102223630.GA2070@barrios>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Sat, Nov 03, 2012 at 07:36:31AM +0900, Minchan Kim wrote:
> > <SNIP>
> > In the first version it would never try to enter direct reclaim if a
> > fatal signal was pending but always claim that forward progress was
> > being made.
> 
> Surely we need fix for preventing deadlock with OOM kill and that's why
> I have Cced you and this patch fixes it but my question is why we need 
> such fatal signal checking trick.
> 
> How about this?
> 

Both will work as expected but....

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 10090c8..881619e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2306,13 +2306,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
>  
>         throttle_direct_reclaim(gfp_mask, zonelist, nodemask);
>  
> -       /*
> -        * Do not enter reclaim if fatal signal is pending. 1 is returned so
> -        * that the page allocator does not consider triggering OOM
> -        */
> -       if (fatal_signal_pending(current))
> -               return 1;
> -
>         trace_mm_vmscan_direct_reclaim_begin(order,
>                                 sc.may_writepage,
>                                 gfp_mask);
>  
> In this case, after throttling, current will try to do direct reclaim and
> if he makes forward progress, he will get a memory and exit if he receive KILL signal.

It may be completely unnecessary to reclaim memory if the process that was
throttled and killed just exits quickly. As the fatal signal is pending
it will be able to use the pfmemalloc reserves.

> If he can't make forward progress with direct reclaim, he can ends up OOM path but
> out_of_memory checks signal check of current and allow to access reserved memory pool
> for quick exit and return without killing other victim selection.

While this is true, what advantage is there to having a killed process
potentially reclaiming memory it does not need to?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
