Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id DF67F6B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 18:36:40 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3020786pad.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 15:36:40 -0700 (PDT)
Date: Sat, 3 Nov 2012 07:36:31 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: zram OOM behavior
Message-ID: <20121102223630.GA2070@barrios>
References: <20121102063958.GC3326@bbox>
 <20121102083057.GG8218@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121102083057.GG8218@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: David Rientjes <rientjes@google.com>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Fri, Nov 02, 2012 at 08:30:57AM +0000, Mel Gorman wrote:
> On Fri, Nov 02, 2012 at 03:39:58PM +0900, Minchan Kim wrote:
> > Hi Mel,
> > 
> > On Thu, Nov 01, 2012 at 08:28:14AM +0000, Mel Gorman wrote:
> > > On Wed, Oct 31, 2012 at 09:48:57PM -0700, David Rientjes wrote:
> > > > On Thu, 1 Nov 2012, Minchan Kim wrote:
> > > > 
> > > > > It's not true any more.
> > > > > 3.6 includes following code in try_to_free_pages
> > > > > 
> > > > >         /*   
> > > > >          * Do not enter reclaim if fatal signal is pending. 1 is returned so
> > > > >          * that the page allocator does not consider triggering OOM
> > > > >          */
> > > > >         if (fatal_signal_pending(current))
> > > > >                 return 1;
> > > > > 
> > > > > So the hunged task never go to the OOM path and could be looping forever.
> > > > > 
> > > > 
> > > > Ah, interesting.  This is from commit 5515061d22f0 ("mm: throttle direct 
> > > > reclaimers if PF_MEMALLOC reserves are low and swap is backed by network 
> > > > storage").  Thanks for adding Mel to the cc.
> > > > 
> > > 
> > > Indeed, thanks.
> > > 
> > > > The oom killer specifically has logic for this condition: when calling 
> > > > out_of_memory() the first thing it does is
> > > > 
> > > > 	if (fatal_signal_pending(current))
> > > > 		set_thread_flag(TIF_MEMDIE);
> > > > 
> > > > to allow it access to memory reserves so that it may exit if it's having 
> > > > trouble.  But that ends up never happening because of the above code that 
> > > > Minchan has identified.
> > > > 
> > > > So we either need to do set_thread_flag(TIF_MEMDIE) in try_to_free_pages() 
> > > > as well or revert that early return entirely; there's no justification 
> > > > given for it in the comment nor in the commit log. 
> > > 
> > > The check for fatal signal is in the wrong place. The reason it was added
> > > is because a throttled process sleeps in an interruptible sleep.  If a user
> > > user forcibly kills a throttled process, it should not result in an OOM kill.
> > > 
> > > > I'd rather remove it 
> > > > and allow the oom killer to trigger and grant access to memory reserves 
> > > > itself if necessary.
> > > > 
> > > > Mel, how does commit 5515061d22f0 deal with threads looping forever if 
> > > > they need memory in the exit path since the oom killer never gets called?
> > > > 
> > > 
> > > It doesn't. How about this?
> > > 
> > > ---8<---
> > > mm: vmscan: Check for fatal signals iff the process was throttled
> > > 
> > > commit 5515061d22f0 ("mm: throttle direct reclaimers if PF_MEMALLOC reserves
> > > are low and swap is backed by network storage") introduced a check for
> > > fatal signals after a process gets throttled for network storage. The
> > > intention was that if a process was throttled and got killed that it
> > > should not trigger the OOM killer. As pointed out by Minchan Kim and
> > > David Rientjes, this check is in the wrong place and too broad. If a
> > > system is in am OOM situation and a process is exiting, it can loop in
> > > __alloc_pages_slowpath() and calling direct reclaim in a loop. As the
> > > fatal signal is pending it returns 1 as if it is making forward progress
> > > and can effectively deadlock.
> > > 
> > > This patch moves the fatal_signal_pending() check after throttling to
> > > throttle_direct_reclaim() where it belongs.
> > 
> > I'm not sure how below patch achieve your goal which is to prevent
> > unnecessary OOM kill if throttled process is killed by user during
> > throttling. If I misunderstood your goal, please correct me and
> > write down it in description for making it more clear.
> > 
> > If user kills throttled process, throttle_direct_reclaim returns true by
> > this patch so try_to_free_pages returns 1. It means it doesn't call OOM
> > in first path of reclaim but shortly it will try to reclaim again
> > by should_alloc_retry.
> 
> Yes and it returned without calling direct reclaim.
> 
> > And since this second path, throttle_direct_reclaim
> > will continue to return false so that it could end up calling OOM kill.
> > 
> 
> Yes except the second time it has not been throttled and it entered direct
> reclaim. If it fails to make any progress it will return 0 but if this
> happens, it potentially really is an OOM situation. If it manages to
> reclaim, it'll be returning a positive number, is making forward
> progress and should successfully exit without triggering OOM.
> 
> Note that throttle_direct_reclaim also now checks fatal_signal_pending
> before deciding to throttle at all.
> 
> > Is it a your intention? If so, what's different with old version?
> > This patch just delay OOM kill so what's benefit does it has?
> > 
> 
> In the first version it would never try to enter direct reclaim if a
> fatal signal was pending but always claim that forward progress was
> being made.

Surely we need fix for preventing deadlock with OOM kill and that's why
I have Cced you and this patch fixes it but my question is why we need 
such fatal signal checking trick.

How about this?

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 10090c8..881619e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2306,13 +2306,6 @@ unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 
        throttle_direct_reclaim(gfp_mask, zonelist, nodemask);
 
-       /*
-        * Do not enter reclaim if fatal signal is pending. 1 is returned so
-        * that the page allocator does not consider triggering OOM
-        */
-       if (fatal_signal_pending(current))
-               return 1;
-
        trace_mm_vmscan_direct_reclaim_begin(order,
                                sc.may_writepage,
                                gfp_mask);
 
In this case, after throttling, current will try to do direct reclaim and
if he makes forward progress, he will get a memory and exit if he receive KILL signal.
If he can't make forward progress with direct reclaim, he can ends up OOM path but
out_of_memory checks signal check of current and allow to access reserved memory pool
for quick exit and return without killing other victim selection.
Is it a problem for your case?

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
