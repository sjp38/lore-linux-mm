Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 67C416B02A4
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 07:59:34 -0400 (EDT)
Date: Fri, 23 Jul 2010 19:59:13 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 7/8] writeback: sync old inodes first in background
 writeback
Message-ID: <20100723115913.GB5125@localhost>
References: <1279545090-19169-1-git-send-email-mel@csn.ul.ie>
 <1279545090-19169-8-git-send-email-mel@csn.ul.ie>
 <20100719142145.GD12510@infradead.org>
 <20100719144046.GR13117@csn.ul.ie>
 <20100722085210.GA26714@localhost>
 <20100722092155.GA28425@localhost>
 <20100722153440.GA1898@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722153440.GA1898@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Christoph Hellwig <hch@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Minchan,

On Thu, Jul 22, 2010 at 11:34:40PM +0800, Minchan Kim wrote:
> Hi, Wu. 
> Thanks for Cced me. 
> 
> AFAIR, we discussed this by private mail and didn't conclude yet. 
> Let's start from beginning. 

OK.

> On Thu, Jul 22, 2010 at 05:21:55PM +0800, Wu Fengguang wrote:
> > > I guess this new patch is more problem oriented and acceptable:
> > > 
> > > --- linux-next.orig/mm/vmscan.c	2010-07-22 16:36:58.000000000 +0800
> > > +++ linux-next/mm/vmscan.c	2010-07-22 16:39:57.000000000 +0800
> > > @@ -1217,7 +1217,8 @@ static unsigned long shrink_inactive_lis
> > >  			count_vm_events(PGDEACTIVATE, nr_active);
> > >  
> > >  			nr_freed += shrink_page_list(&page_list, sc,
> > > -							PAGEOUT_IO_SYNC);
> > > +					priority < DEF_PRIORITY / 3 ?
> > > +					PAGEOUT_IO_SYNC : PAGEOUT_IO_ASYNC);
> > >  		}
> > >  
> > >  		nr_reclaimed += nr_freed;
> > 
> > This one looks better:
> > ---
> > vmscan: raise the bar to PAGEOUT_IO_SYNC stalls
> > 
> > Fix "system goes totally unresponsive with many dirty/writeback pages"
> > problem:
> > 
> > 	http://lkml.org/lkml/2010/4/4/86
> > 
> > The root cause is, wait_on_page_writeback() is called too early in the
> > direct reclaim path, which blocks many random/unrelated processes when
> > some slow (USB stick) writeback is on the way.
> > 
> > A simple dd can easily create a big range of dirty pages in the LRU
> > list. Therefore priority can easily go below (DEF_PRIORITY - 2) in a
> > typical desktop, which triggers the lumpy reclaim mode and hence
> > wait_on_page_writeback().
> 
> I see oom message. order is zero. 

OOM after applying this patch?  It's not an obvious consequence.

> How is lumpy reclaim work?
> For working lumpy reclaim, we have to meet priority < 10 and sc->order > 0.
>
> Please, clarify the problem.
 
This patch tries to respect the lumpy reclaim logic, and only raises
the bar for sync writeback and IO wait. With Mel's change, it's only
doing so for (order <= PAGE_ALLOC_COSTLY_ORDER) allocations. Hopefully
this will limit unexpected side effects.

> > 
> > In Andreas' case, 512MB/1024 = 512KB, this is way too low comparing to
> > the 22MB writeback and 190MB dirty pages. There can easily be a
> 
> What's 22MB and 190M?

The numbers are adapted from the OOM dmesg in
http://lkml.org/lkml/2010/4/4/86 . The OOM is order 0 and GFP_KERNEL.

> It would be better to explain more detail. 
> I think the description has to be clear as summary of the problem 
> without the above link. 

Good suggestion. I'll try.

> Thanks for taking out this problem, again. :)

Heh, I'm actually feeling guilty for the long delay!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
