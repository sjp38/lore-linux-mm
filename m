Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3175D6B0085
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 11:18:40 -0400 (EDT)
Date: Thu, 16 Sep 2010 16:18:28 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 8/8] writeback: Do not sleep on the congestion queue if
	there are no congested BDIs or if significant congestion is not
	being encountered in the current zone
Message-ID: <20100916151827.GA11405@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie> <1284553671-31574-9-git-send-email-mel@csn.ul.ie> <20100916081338.GB16115@barrios-desktop> <20100916091824.GB15709@csn.ul.ie> <20100916141147.GC16115@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100916141147.GC16115@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > > <snip>
> > > 
> > > >  			      struct scan_control *sc)
> > > >  {
> > > > +	enum bdi_queue_status ret = QUEUEWRITE_DENIED;
> > > > +
> > > >  	if (current->flags & PF_SWAPWRITE)
> > > > -		return 1;
> > > > +		return QUEUEWRITE_ALLOWED;
> > > >  	if (!bdi_write_congested(bdi))
> > > > -		return 1;
> > > > +		return QUEUEWRITE_ALLOWED;
> > > > +	else
> > > > +		ret = QUEUEWRITE_CONGESTED;
> > > >  	if (bdi == current->backing_dev_info)
> > > > -		return 1;
> > > > +		return QUEUEWRITE_ALLOWED;
> > > >  
> > > >  	/* lumpy reclaim for hugepage often need a lot of write */
> > > >  	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> > > > -		return 1;
> > > > -	return 0;
> > > > +		return QUEUEWRITE_ALLOWED;
> > > > +	return ret;
> > > >  }
> > > 
> > > The function can't return QUEUEXXX_DENIED.
> > > It can affect disable_lumpy_reclaim. 
> > > 
> > 
> > Yes, but that change was made in "vmscan: Narrow the scenarios lumpy
> > reclaim uses synchrounous reclaim". Maybe I am misunderstanding your
> > objection.
> 
> I means current may_write_to_queue never returns QUEUEWRITE_DENIED.
> What's the role of it?
> 

As of now, little point because QUEUEWRITE_CONGESTED implies denied. I was allowing
the possibility of distinguishing between these cases in the future depending
on what happened with wait_iff_congested(). I will drop it for simplicity
and reintroduce it when or if there is a distinction between
denied and congested.

> In addition, we don't need disable_lumpy_reclaim_mode() in pageout.
> That's because both PAGE_KEEP and PAGE_KEEP_CONGESTED go to keep_locked
> and calls disable_lumpy_reclaim_mode at last. 
> 

True, good spot.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
