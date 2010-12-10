Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 591866B0092
	for <linux-mm@kvack.org>; Fri, 10 Dec 2010 06:36:57 -0500 (EST)
Date: Fri, 10 Dec 2010 11:34:54 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-ID: <20101210113454.GR20133@csn.ul.ie>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org> <20101209003621.GB3796@hostway.ca> <20101208172324.d45911f4.akpm@linux-foundation.org> <20101209144412.GE20133@csn.ul.ie> <AANLkTimHrL5HnSf-rAMGdg-_ZKZ5RgJ_sEWo+BH5Q9sL@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTimHrL5HnSf-rAMGdg-_ZKZ5RgJ_sEWo+BH5Q9sL@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Kirby <sim@hostway.ca>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2010 at 10:48:37AM -0800, Ying Han wrote:
> On Thu, Dec 9, 2010 at 6:44 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Wed, Dec 08, 2010 at 05:23:24PM -0800, Andrew Morton wrote:
> >> On Wed, 8 Dec 2010 16:36:21 -0800 Simon Kirby <sim@hostway.ca> wrote:
> >>
> >> > On Wed, Dec 08, 2010 at 04:16:59PM +0100, Johannes Weiner wrote:
> >> >
> >> > > Kswapd tries to rebalance zones persistently until their high
> >> > > watermarks are restored.
> >> > >
> >> > > If the amount of unreclaimable pages in a zone makes this impossible
> >> > > for reclaim, though, kswapd will end up in a busy loop without a
> >> > > chance of reaching its goal.
> >> > >
> >> > > This behaviour was observed on a virtual machine with a tiny
> >> > > Normal-zone that filled up with unreclaimable slab objects.
> >> > >
> >> > > This patch makes kswapd skip rebalancing on such 'hopeless' zones and
> >> > > leaves them to direct reclaim.
> >> >
> >> > Hi!
> >> >
> >> > We are experiencing a similar issue, though with a 757 MB Normal zone,
> >> > where kswapd tries to rebalance Normal after an order-3 allocation while
> >> > page cache allocations (order-0) keep splitting it back up again.  It can
> >> > run the whole day like this (SSD storage) without sleeping.
> >>
> >> People at google have told me they've seen the same thing.  A fork is
> >> taking 15 minutes when someone else is doing a dd, because the fork
> >> enters direct-reclaim trying for an order-one page.  It successfully
> >> frees some order-one pages but before it gets back to allocate one, dd
> >> has gone and stolen them, or split them apart.
> >>
> >
> > Is there a known test case for this or should I look at doing a
> > streaming-IO test with a basic workload constantly forking in the
> > background to measure the fork latency?
> 
> We were seeing some system daemons(sshd) being OOM killed while
> running in the same
> memory container as dd test. I assume we can generate the test case
> while running dd on
> 10G of file in 1G container, at the same time running
> unixbench(fork/exec loop)?
> 

unixbench in a fork/exec loop won't tell us the latency of each
individual operation. If order-1 is really a problem, we should see a
large standard deviation between fork/exec attempts. A custom test of
some sort is probably required.

> >
> >> This problem would have got worse when slub came along doing its stupid
> >> unnecessary high-order allocations.
> >>
> >> Billions of years ago a direct-reclaimer had a one-deep cache in the
> >> task_struct into which it freed the page to prevent it from getting
> >> stolen.
> >>
> >> Later, we took that out because pages were being freed into the
> >> per-cpu-pages magazine, which is effectively task-local anyway.  But
> >> per-cpu-pages are only for order-0 pages.  See slub stupidity, above.
> >>
> >> I expect that this is happening so repeatably because the
> >> direct-reclaimer is dong a sleep somewhere after freeing the pages it
> >> needs - if it wasn't doing that then surely the window wouldn't be wide
> >> enough for it to happen so often.  But I didn't look.
> >>
> >> Suitable fixes might be
> >>
> >> a) don't go to sleep after the successful direct-reclaim.
> >>
> >
> > I submitted a patch for this a long time ago but at the time we didn't
> > have a test case that made a difference to it. Might be worth
> > revisiting. I can't find the related patch any more but it was fairly
> > trivial.
> 
> If you have the patch, maybe we can give a try on our case.
> 

I'll cobble one together early next week.

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
