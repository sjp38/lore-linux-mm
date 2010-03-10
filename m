Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A8DAE6B00B4
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 21:38:19 -0500 (EST)
Date: Wed, 10 Mar 2010 13:38:13 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [PATCH 1/3] page-allocator: Under memory pressure, wait on
 pressure to relieve instead of congestion
Message-ID: <20100310023813.GZ8653@laptop>
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie>
 <1268048904-19397-2-git-send-email-mel@csn.ul.ie>
 <20100309133513.GL8653@laptop>
 <20100309141713.GF4883@csn.ul.ie>
 <20100309150332.GP8653@laptop>
 <4B966C7A.5040706@linux.vnet.ibm.com>
 <20100309182228.GJ4883@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100309182228.GJ4883@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 09, 2010 at 06:22:28PM +0000, Mel Gorman wrote:
> On Tue, Mar 09, 2010 at 04:42:50PM +0100, Christian Ehrhardt wrote:
> >
> >
> > Nick Piggin wrote:
> >> On Tue, Mar 09, 2010 at 02:17:13PM +0000, Mel Gorman wrote:
> >>> On Wed, Mar 10, 2010 at 12:35:13AM +1100, Nick Piggin wrote:
> >>>> On Mon, Mar 08, 2010 at 11:48:21AM +0000, Mel Gorman wrote:
> >>>>> Under heavy memory pressure, the page allocator may call congestion_wait()
> >>>>> to wait for IO congestion to clear or a timeout. This is not as sensible
> >>>>> a choice as it first appears. There is no guarantee that BLK_RW_ASYNC is
> >>>>> even congested as the pressure could have been due to a large number of
> >>>>> SYNC reads and the allocator waits for the entire timeout, possibly uselessly.
> >>>>>
> >>>>> At the point of congestion_wait(), the allocator is struggling to get the
> >>>>> pages it needs and it should back off. This patch puts the allocator to sleep
> >>>>> on a zone->pressure_wq for either a timeout or until a direct reclaimer or
> >>>>> kswapd brings the zone over the low watermark, whichever happens first.
> >>>>>
> >>>>> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> >>>>> ---
> >>>>>  include/linux/mmzone.h |    3 ++
> >>>>>  mm/internal.h          |    4 +++
> >>>>>  mm/mmzone.c            |   47 +++++++++++++++++++++++++++++++++++++++++++++
> >>>>>  mm/page_alloc.c        |   50 +++++++++++++++++++++++++++++++++++++++++++----
> >>>>>  mm/vmscan.c            |    2 +
> >>>>>  5 files changed, 101 insertions(+), 5 deletions(-)
> >>>>>
> >>>>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> >>>>> index 30fe668..72465c1 100644
> >>>>> --- a/include/linux/mmzone.h
> >>>>> +++ b/include/linux/mmzone.h
> > [...]
> >>>>> +{
> >>>>> +	/* If no process is waiting, nothing to do */
> >>>>> +	if (!waitqueue_active(zone->pressure_wq))
> >>>>> +		return;
> >>>>> +
> >>>>> +	/* Check if the high watermark is ok for order 0 */
> >>>>> +	if (zone_watermark_ok(zone, 0, low_wmark_pages(zone), 0, 0))
> >>>>> +		wake_up_interruptible(zone->pressure_wq);
> >>>>> +}
> >>>> If you were to do this under the zone lock (in your subsequent patch),
> >>>> then it could avoid races. I would suggest doing it all as a single
> >>>> patch and not doing the pressure checks in reclaim at all.
> >>>>
> >>> That is reasonable. I've already dropped the checks in reclaim because as you
> >>> say, if the free path check is cheap enough, it's also sufficient. Checking
> >>> in the reclaim paths as well is redundant.
> >>>
> >>> I'll move the call to check_zone_pressure() within the zone lock to avoid
> >>> races.
> >>>
> >
> > Mel, we talked about a thundering herd issue that might come up here in  
> > very constraint cases.
> > So wherever you end up putting that wake_up call, how about being extra  
> > paranoid about a thundering herd flagging them WQ_FLAG_EXCLUSIVE and  
> > waking them with something like that:
> >
> > wake_up_interruptible_nr(zone->pressure_wq, #nrofpagesabovewatermark#);
> >
> > That should be an easy to calculate sane max of waiters to wake up.
> > On the other hand it might be over-engineered and it implies the need to  
> > reconsider when it would be best to wake up the rest.
> >
> 
> It seems over-engineering considering that they wake up after a timeout
> unconditionally. I think it's best for the moment to let them wake up in
> a herd and recheck their zonelists as they'll go back to sleep if
> necessary.

I think it isn't a bad idea and I was thinking about that myself, except
that we might do several wakeups before previously woken processes get
the chance to run and take pages from the watermark.

Also, if we have a large number of processes waiting here, the system
isn't in great shape, so a little CPU activity probably isn't going to
be noticable.

So I agree with Mel it probably isn't needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
