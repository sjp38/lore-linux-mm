Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1AA056B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 10:11:18 -0400 (EDT)
Date: Tue, 20 Jul 2010 15:10:49 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 8/8] vmscan: Kick flusher threads to clean pages when
	reclaim is encountering dirty pages
Message-ID: <20100720141049.GV13117@csn.ul.ie>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie> <1279545090-19169-9-git-send-email-mel@csn.ul.ie> <20100719142349.GE12510@infradead.org> <20100719143737.GQ13117@csn.ul.ie> <20100719224838.GC16031@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100719224838.GC16031@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 12:48:39AM +0200, Johannes Weiner wrote:
> On Mon, Jul 19, 2010 at 03:37:37PM +0100, Mel Gorman wrote:
> > On Mon, Jul 19, 2010 at 10:23:49AM -0400, Christoph Hellwig wrote:
> > > On Mon, Jul 19, 2010 at 02:11:30PM +0100, Mel Gorman wrote:
> > > > +	/*
> > > > +	 * If reclaim is encountering dirty pages, it may be because
> > > > +	 * dirty pages are reaching the end of the LRU even though
> > > > +	 * the dirty_ratio may be satisified. In this case, wake
> > > > +	 * flusher threads to pro-actively clean some pages
> > > > +	 */
> > > > +	wakeup_flusher_threads(laptop_mode ? 0 : nr_dirty + nr_dirty / 2);
> > > > +
> > > 
> > > Where is the laptop-mode magic coming from?
> > > 
> > 
> > It comes from other parts of page reclaim where writing pages is avoided
> > by page reclaim where possible. Things like this
> > 
> > 	wakeup_flusher_threads(laptop_mode ? 0 : total_scanned);
> 
> Actually, it's not avoiding writing pages in laptop mode, instead it
> is lumping writeouts aggressively (as I wrote in my other mail,
> .nr_pages=0 means 'write everything') to keep disk spinups rare and
> make maximum use of them.
> 

You're right, 0 does mean flush everything - /me slaps self. It was introduced
in 2.6.6 with the patch "[PATCH] laptop mode". Quoting from it

    Algorithm: the idea is to hold dirty data in memory for a long time,
    but to flush everything which has been accumulated if the disk happens
    to spin up for other reasons.

So, the reason for the magic is half right - avoid excessive disk spin-ups
but my reasoning for it was wrong. I thought it was avoiding a cleaning to
save power.  What it is actually intended to do is "if we are spinning up the
disk anyway, do as much work as possible so it can spin down for longer later".

Where it's wrong is that it should only wakeup flusher threads if dirty
pages were encountered. What it's doing right now is potentially
cleaning everything. It means I need to rerun all the tests and see if
the number of pages encountered by page reclaim is really reduced or was
it because I was calling wakeup_flusher_threads(0) when no dirty pages
were encountered.

> > although the latter can get disabled too. Deleting the magic is an
> > option which would trade IO efficiency for power efficiency but my
> > current thinking is laptop mode preferred reduced power.
> 
> Maybe couple your wakeup with sc->may_writepage?  It is usually false
> for laptop_mode but direct reclaimers enable it at one point in
> do_try_to_free_pages() when it scanned more than 150% of the reclaim
> target, so you could use existing disk spin-up points instead of
> introducing new ones or disabling the heuristics in laptop mode.
> 

How about the following?

        if (nr_dirty && sc->may_writepage)
                wakeup_flusher_threads(laptop_mode ? 0 :
                                                nr_dirty + nr_dirty / 2);


1. Wakup flusher threads if dirty pages are encountered
2. For direct reclaim, only wake them up if may_writepage is set
   indicating that the system is ready to spin up disks and start
   reclaiming
3. In laptop_mode, flush everything to reduce future spin-ups

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
