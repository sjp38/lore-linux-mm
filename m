Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 835B48D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 05:30:09 -0500 (EST)
Date: Tue, 18 Jan 2011 10:29:41 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone
	is not allowed
Message-ID: <20110118102941.GG27152@csn.ul.ie>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com> <20110118142339.6705.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110118142339.6705.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 18, 2011 at 03:04:21PM +0900, KOSAKI Motohiro wrote:
> Hi,
> 
> > Before 0e093d99763e (writeback: do not sleep on the congestion queue if
> > there are no congested BDIs or if significant congestion is not being
> > encountered in the current zone), preferred_zone was only used for
> > statistics and to determine the zoneidx from which to allocate from given
> > the type requested.
> 
> True. So, following comment is now bogus. ;)
> 
> __alloc_pages_nodemask()
> {
> (snip)
>         get_mems_allowed();
>         /* The preferred zone is used for statistics later */
>         first_zones_zonelist(zonelist, high_zoneidx, nodemask, &preferred_zone);
>         if (!preferred_zone) {
>                 put_mems_allowed();
>                 return NULL;
>         }
> 

At best, it's misleading. It is used for staistics later but it's not
all it's used for.

> 
> Now, we have three preferred_zone usage.
>  1. for zone stat
>  2. wait_iff_congested
>  3. for calculate compaction duration
> 

For 3, it is used to determine if compaction should be deferred. I'm not
sure what it has to do with the duration of compaction.

> So, I have two question.  
> 

three questions :)

> 1. Why do we need different vm stat policy mempolicy and cpuset? 
> That said, if we are using mempolicy, the above nodemask variable is 
> not NULL, then preferrd_zone doesn't point nearest zone. But it point 
> always nearest zone when cpuset are used. 
> 

I think this is historical. cpuset and mempolicy were introduced at
different times and never merged together as they should have been. I
think an attempt was made a very long time ago but there was significant
resistance from SGI developers who didn't want to see regressions
introduced in a feature they depended heavily on.

> 2. Why wait_iff_congested in page_alloc only wait preferred zone? 
> That said, theorically, any no congested zones in allocatable zones can
> avoid waiting. Just code simplify?
> 

The ideal for page allocation is that the preferred zone is always used.
If it is congested, it's probable that significant pressure also exists on
the other zones in the zonelist (because an allocation attempt failed)
but if the preferred zone is uncongested, we should try reclaiming from
it rather than going to sleep.

> 3. I'm not sure why zone->compact_defer is not noted per zone, instead
> noted only preferred zone. Do you know the intention?
> 

If we are deferring compaction, we have failed to compact the preferred
zone and all other zones in the zonelist. Updating the preferred zone is
sufficient for future allocations of the same type. We could update all
zones in the zonelist but it's unnecessary overhead and gains very little.

> I mean my first feeling tell me that we have a chance to make code simplify
> more.
> 
> Mel, Can you please tell us your opinion?
> 

Right now, I'm thinking that cpuset_current_mems_allowed should be used
as a nodemask earlier so that preferred_zone gets initialised as a
sensible value early on.

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
