Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2A19C6B0047
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 05:52:57 -0400 (EDT)
Date: Mon, 20 Sep 2010 10:52:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 8/8] writeback: Do not sleep on the congestion queue if
	there are no congested BDIs or if significant congestion is not
	being encountered in the current zone
Message-ID: <20100920095239.GE1998@csn.ul.ie>
References: <1284553671-31574-1-git-send-email-mel@csn.ul.ie> <1284553671-31574-9-git-send-email-mel@csn.ul.ie> <20100916152810.cb074e9f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100916152810.cb074e9f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 16, 2010 at 03:28:10PM -0700, Andrew Morton wrote:
> On Wed, 15 Sep 2010 13:27:51 +0100
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > If wait_iff_congested() is called with no BDI congested, the function simply
> > calls cond_resched(). In the event there is significant writeback happening
> > in the zone that is being reclaimed, this can be a poor decision as reclaim
> > would succeed once writeback was completed. Without any backoff logic,
> > younger clean pages can be reclaimed resulting in more reclaim overall and
> > poor performance.
> 
> This is because cond_resched() is a no-op,

Can be a no-op surely. There is an expectation that it will sometimes schedule.

> and we skip around the
> under-writeback pages and go off and look further along the LRU for
> younger clean pages, yes?
> 

Yes.

> > This patch tracks how many pages backed by a congested BDI were found during
> > scanning. If all the dirty pages encountered on a list isolated from the
> > LRU belong to a congested BDI, the zone is marked congested until the zone
> > reaches the high watermark.
> 
> High watermark, or low watermark?
> 

High watermark. The check is made by kswapd.

> The terms are rather ambiguous so let's avoid them.  Maybe "full"
> watermark and "empty"?
> 

Unfortunately they are ambiguous to me. I know what the high watermark
is but not what the full or empty watermarks are.

> >
> > ...
> >
> > @@ -706,6 +726,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  			goto keep;
> >  
> >  		VM_BUG_ON(PageActive(page));
> > +		VM_BUG_ON(page_zone(page) != zone);
> 
> ?
> 

It should not be the case that pages from multiple zones exist on the list
passed to shrink_page_list(). Lets say someone broke that assumption in the
future, which one should be marked congested? No way to know, so lets catch
the bug if the assumptions is ever broken.

> >  		sc->nr_scanned++;
> >  
> >
> > ...
> >
> > @@ -903,6 +928,15 @@ keep_lumpy:
> >  		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
> >  	}
> >  
> > +	/*
> > +	 * Tag a zone as congested if all the dirty pages encountered were
> > +	 * backed by a congested BDI. In this case, reclaimers should just
> > +	 * back off and wait for congestion to clear because further reclaim
> > +	 * will encounter the same problem
> > +	 */
> > +	if (nr_dirty == nr_congested)
> > +		zone_set_flag(zone, ZONE_CONGESTED);
> 
> The implicit "100%" there is a magic number.  hrm.
> 

It is but any other value for that number would be very specific to a
workload or a machine. A sysctl would have to be maintained and I
couldn't convince myself that anyone could do something sensible with
the value.

Rather than introducing a new tunable for this, I was toying with the idea over
the weekend on tracking the scanned/reclaimed ratio within the scan control -
possibly on a per-zone basis but more likely globally. When this ratio drops
below a given threshold, start increasing the time it backs off for up to a
maximum of HZ/10. There are a lot of details to iron out but it's possibly a
better long-term direction than adding a tunable for this implicit magic number
because it would be adaptive to what is happening for the current workload.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
