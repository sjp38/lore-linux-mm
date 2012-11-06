Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 318F76B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 05:17:29 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so247979pad.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 02:17:28 -0800 (PST)
Date: Tue, 6 Nov 2012 19:17:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram OOM behavior
Message-ID: <20121106101719.GA2005@barrios>
References: <20121102063958.GC3326@bbox>
 <20121102083057.GG8218@suse.de>
 <20121102223630.GA2070@barrios>
 <20121105144614.GJ8218@suse.de>
 <20121106002550.GA3530@barrios>
 <20121106085822.GN8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121106085822.GN8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Tue, Nov 06, 2012 at 08:58:22AM +0000, Mel Gorman wrote:
> On Tue, Nov 06, 2012 at 09:25:50AM +0900, Minchan Kim wrote:
> > On Mon, Nov 05, 2012 at 02:46:14PM +0000, Mel Gorman wrote:
> > > On Sat, Nov 03, 2012 at 07:36:31AM +0900, Minchan Kim wrote:
> > > > > <SNIP>
> > > > > In the first version it would never try to enter direct reclaim if a
> > > > > fatal signal was pending but always claim that forward progress was
> > > > > being made.
> > > > 
> > > > Surely we need fix for preventing deadlock with OOM kill and that's why
> > > > I have Cced you and this patch fixes it but my question is why we need 
> > > > such fatal signal checking trick.
> > > > 
> > > > How about this?
> > > > 
> > > 
> > > Both will work as expected but....
> > > 
> > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > index 10090c8..881619e 100644
> > > > --- a/mm/vmscan.c
> > > > +++ b/mm/vmscan.c
> > > > @@ -2306,13 +2306,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
> > > >  
> > > >         throttle_direct_reclaim(gfp_mask, zonelist, nodemask);
> > > >  
> > > > -       /*
> > > > -        * Do not enter reclaim if fatal signal is pending. 1 is returned so
> > > > -        * that the page allocator does not consider triggering OOM
> > > > -        */
> > > > -       if (fatal_signal_pending(current))
> > > > -               return 1;
> > > > -
> > > >         trace_mm_vmscan_direct_reclaim_begin(order,
> > > >                                 sc.may_writepage,
> > > >                                 gfp_mask);
> > > >  
> > > > In this case, after throttling, current will try to do direct reclaim and
> > > > if he makes forward progress, he will get a memory and exit if he receive KILL signal.
> > > 
> > > It may be completely unnecessary to reclaim memory if the process that was
> > > throttled and killed just exits quickly. As the fatal signal is pending
> > > it will be able to use the pfmemalloc reserves.
> > > 
> > > > If he can't make forward progress with direct reclaim, he can ends up OOM path but
> > > > out_of_memory checks signal check of current and allow to access reserved memory pool
> > > > for quick exit and return without killing other victim selection.
> > > 
> > > While this is true, what advantage is there to having a killed process
> > > potentially reclaiming memory it does not need to?
> > 
> > Killed process needs a memory for him to be terminated. I think it's not a good idea for him
> > to use reserved memory pool unconditionally although he is throtlled and killed.
> > Because reserved memory pool is very stricted resource for emergency so using reserved memory
> > pool should be last resort after he fail to reclaim.
> > 
> 
> Part of that reclaim can be the process reclaiming its own pages and
> putting them in swap just so it can exit shortly afterwards. If it was
> throttled in this path, it implies that swap-over-NFS is enabled where

Could we make sure it's only the case for swap-over-NFS?
I think it can happen if the system has very slow thumb card.

> such reclaim in fact might require the pfmemalloc reserves to be used to
> allocate network buffers. It's potentially unnecessary work because the

You mean we need pfmemalloc reserve to swap out anon pages by swap-over-NFS?
Yes. In this case, you're right. I would be better to use reserve pool for
just exiting instead of swap out over network. But how can you make sure that
we have only anonymous page when we try to reclaim? 
If there are some file-backed pages, we can avoid swapout at that time.
Maybe we need some check.

> same reserves could have been used to just exit the process.
> 
> I'll go your way if you insist because it's not like getting throttled
> and killed before exit is a common situation and it should work either
> way.

I don't want to insist on. Just want to know what's the problem and find
better solution. :) 

P.S) I'm at situation which is very hard to sit down in front of computer
for a long time due to really really thanksful training course. :(
Shortly, I should go to dance.
Please feel free to send patch without expectation I will send patch soon.

> 
> -- 
> Mel Gorman
> SUSE Labs

-- 
Kind Regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
