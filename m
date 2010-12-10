Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D65EE6B0095
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 06:37:36 -0500 (EST)
Date: Fri, 10 Dec 2010 11:37:17 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-ID: <20101210113717.GS20133@csn.ul.ie>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org> <20101209003621.GB3796@hostway.ca> <20101208172324.d45911f4.akpm@linux-foundation.org> <AANLkTik1sqUqk061KMu8ZEn5Ai4AyTfKR3JA1ceR5qFW@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTik1sqUqk061KMu8ZEn5Ai4AyTfKR3JA1ceR5qFW@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Kirby <sim@hostway.ca>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2010 at 10:39:46AM -0800, Ying Han wrote:
> On Wed, Dec 8, 2010 at 5:23 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > On Wed, 8 Dec 2010 16:36:21 -0800 Simon Kirby <sim@hostway.ca> wrote:
> >
> >> On Wed, Dec 08, 2010 at 04:16:59PM +0100, Johannes Weiner wrote:
> >>
> >> > Kswapd tries to rebalance zones persistently until their high
> >> > watermarks are restored.
> >> >
> >> > If the amount of unreclaimable pages in a zone makes this impossible
> >> > for reclaim, though, kswapd will end up in a busy loop without a
> >> > chance of reaching its goal.
> >> >
> >> > This behaviour was observed on a virtual machine with a tiny
> >> > Normal-zone that filled up with unreclaimable slab objects.
> >> >
> >> > This patch makes kswapd skip rebalancing on such 'hopeless' zones and
> >> > leaves them to direct reclaim.
> >>
> >> Hi!
> >>
> >> We are experiencing a similar issue, though with a 757 MB Normal zone,
> >> where kswapd tries to rebalance Normal after an order-3 allocation while
> >> page cache allocations (order-0) keep splitting it back up again.  It can
> >> run the whole day like this (SSD storage) without sleeping.
> >
> > People at google have told me they've seen the same thing.  A fork is
> > taking 15 minutes when someone else is doing a dd, because the fork
> > enters direct-reclaim trying for an order-one page.  It successfully
> > frees some order-one pages but before it gets back to allocate one, dd
> > has gone and stolen them, or split them apart.
> 
> So we are running into this problem in a container environment. While
> running dd in a container with
> bunch of system daemons like sshd, we've seen sshd being OOM killed.
> 

It's possible that containers are *particularly* vunerable to this
problem because they don't have kswapd. As direct reclaimers go to
sleep, the race between an order-1 page being freed and another request
breaking up the order-1 page might be far more severe.

> One of the theory which we haven't fully proven is dd keep sallocating
> and stealing pages which just being
> reclaimed from ttfp of sshd. We've talked with Andrew and wondering if
> there is a way to prevent that
> happening. And we learned that we might have something for order 0
> pages since they got freed to per-cpu
> list and the process triggered ttfp more likely to get it unless being
> rescheduled. But nothing for order 1 which
> is fork() in this case.
> 
> --Ying
> 
> >
> > This problem would have got worse when slub came along doing its stupid
> > unnecessary high-order allocations.
> >
> > Billions of years ago a direct-reclaimer had a one-deep cache in the
> > task_struct into which it freed the page to prevent it from getting
> > stolen.
> >
> > Later, we took that out because pages were being freed into the
> > per-cpu-pages magazine, which is effectively task-local anyway.  But
> > per-cpu-pages are only for order-0 pages.  See slub stupidity, above.
> >
> > I expect that this is happening so repeatably because the
> > direct-reclaimer is dong a sleep somewhere after freeing the pages it
> > needs - if it wasn't doing that then surely the window wouldn't be wide
> > enough for it to happen so often.  But I didn't look.
> >
> > Suitable fixes might be
> >
> > a) don't go to sleep after the successful direct-reclaim.
> >
> > b) reinstate the one-deep task-local free page cache.
> >
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> 

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
