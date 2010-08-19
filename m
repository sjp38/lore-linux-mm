Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0923E6B01F1
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 06:38:55 -0400 (EDT)
Date: Thu, 19 Aug 2010 11:38:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
	NR_FREE_PAGES when memory is low and kswapd is awake
Message-ID: <20100819103839.GZ19797@csn.ul.ie>
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100816094350.GH19797@csn.ul.ie> <20100816160623.GB15103@cmpxchg.org> <20100817101655.GN19797@csn.ul.ie> <20100817142040.GA3884@barrios-desktop> <20100818085123.GU19797@csn.ul.ie> <20100818145725.GA5744@barrios-desktop> <20100819080624.GX19797@csn.ul.ie> <AANLkTi=Mtc_7b5WG4nmwbFYg8yijyMSG1AUTzy+QTwoy@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTi=Mtc_7b5WG4nmwbFYg8yijyMSG1AUTzy+QTwoy@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 19, 2010 at 07:33:57PM +0900, Minchan Kim wrote:
> On Thu, Aug 19, 2010 at 5:06 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Wed, Aug 18, 2010 at 11:57:26PM +0900, Minchan Kim wrote:
> >> On Wed, Aug 18, 2010 at 09:51:23AM +0100, Mel Gorman wrote:
> >> > > What's a window low and min wmark? Maybe I can miss your point.
> >> > >
> >> >
> >> > The window is due to the fact kswapd is not awake yet. The window is because
> >> > kswapd might not be awake as NR_FREE_PAGES is higher than it should be. The
> >> > system is really somewhere between the low and min watermark but we are not
> >> > taking the accurate measure until kswapd gets woken up. The first allocation
> >> > to notice we are below the low watermark (be it due to vmstat refreshing or
> >> > that NR_FREE_PAGES happens to report we are below the watermark regardless of
> >> > any drift) wakes kswapd and other callers then take an accurate count hence
> >> > "we could breach the watermark but I'm expecting it can only happen for at
> >> > worst one allocation".
> >>
> >> Right. I misunderstood your word.
> >> One more question.
> >>
> >> Could you explain live lock scenario?
> >>
> >
> > Lets say
> >
> > NR_FREE_PAGES     = 256
> > Actual free pages = 8
> >
> > The PCP lists get refilled in patch taking all 8 pages. Now there are
> > zero free pages. Reclaim kicks in but to reclaim any pages it needs to
> > clean something but all the pages are on a network-backed filesystem. To
> > clean them, it must transmit on the network so it tries to allocate some
> > buffers.
> >
> > The livelock is that to free some memory, an allocation must succeed but
> > for an allocation to succeed, some memory must be freed. The system
> 
> Yes. I understood this as livelock but at last VM will kill victim
> process then it can allocate free pages.

And if the exit path for the OOM kill needs to allocate a page what
should it do?

> So I think it's not a livelock.
> 
> > might still remain alive if a process exits and does not need to
> > allocate memory while exiting but by and large, the system is in a
> > dangerous state.
> 
> Do you mean dangerous state of the system is livelock?
> Maybe not.
> I can't understand livelock in this context.
> Anyway, I am okay with this patch except livelock pharse. :)
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
