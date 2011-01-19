Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B97C16B0092
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 07:48:30 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BA4473EE0C0
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:48:26 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 91ED045DE53
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:48:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D0FF45DE51
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:48:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F254EF8009
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:48:26 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1898CEF8003
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 21:48:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone is not allowed
In-Reply-To: <20110118102941.GG27152@csn.ul.ie>
References: <20110118142339.6705.A69D9226@jp.fujitsu.com> <20110118102941.GG27152@csn.ul.ie>
Message-Id: <20110119134014.2819.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 19 Jan 2011 21:48:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > Now, we have three preferred_zone usage.
> >  1. for zone stat
> >  2. wait_iff_congested
> >  3. for calculate compaction duration
> > 
> 
> For 3, it is used to determine if compaction should be deferred. I'm not
> sure what it has to do with the duration of compaction.
> 
> > So, I have two question.  
> > 
> 
> three questions :)

Hehe, Maybe the yellow monkey can't count number rather than two. I bet. ;-p

> > 1. Why do we need different vm stat policy mempolicy and cpuset? 
> > That said, if we are using mempolicy, the above nodemask variable is 
> > not NULL, then preferrd_zone doesn't point nearest zone. But it point 
> > always nearest zone when cpuset are used. 
> 
> I think this is historical. cpuset and mempolicy were introduced at
> different times and never merged together as they should have been. I
> think an attempt was made a very long time ago but there was significant
> resistance from SGI developers who didn't want to see regressions
> introduced in a feature they depended heavily on.

Yup, I think so too.
And as David said, NUMA stat is not so important stastics. Probably we can concentrate
usage (2).


> 
> > 2. Why wait_iff_congested in page_alloc only wait preferred zone? 
> > That said, theorically, any no congested zones in allocatable zones can
> > avoid waiting. Just code simplify?
> > 
> 
> The ideal for page allocation is that the preferred zone is always used.

Yup, really.

However, now we are discussing reclaim and allocationo retry path. It's slightly different
allocation fast path.

> If it is congested, it's probable that significant pressure also exists on
> the other zones in the zonelist (because an allocation attempt failed)

Hmm..
Why do we need to guess it? It is in allocation retrying path, IOW it's after try_to_free_pages(),
scanning zonelist is not so heavy impact operation.


> but if the preferred zone is uncongested, we should try reclaiming from
> it rather than going to sleep.

But if it's congested, the task will be stucked in vmscan anyway.
Can you please show your worried scenario?

> > 3. I'm not sure why zone->compact_defer is not noted per zone, instead
> > noted only preferred zone. Do you know the intention?
> 
> If we are deferring compaction, we have failed to compact the preferred
> zone and all other zones in the zonelist. Updating the preferred zone is
> sufficient for future allocations of the same type. We could update all
> zones in the zonelist but it's unnecessary overhead and gains very little.

Ok, the requirement is to note one of zones, not list head zone of zonelist.


> > I mean my first feeling tell me that we have a chance to make code simplify
> > more.
> > 
> > Mel, Can you please tell us your opinion?
> > 
> 
> Right now, I'm thinking that cpuset_current_mems_allowed should be used
> as a nodemask earlier so that preferred_zone gets initialised as a
> sensible value early on.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
