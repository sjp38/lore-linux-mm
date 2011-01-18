Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B3D828D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 01:04:26 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7B4733EE0BD
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 15:04:22 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 603A845DE62
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 15:04:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 36AE345DE5E
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 15:04:22 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F579E08005
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 15:04:22 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB903E78006
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 15:04:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone is not allowed
In-Reply-To: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com>
Message-Id: <20110118142339.6705.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 18 Jan 2011 15:04:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> Before 0e093d99763e (writeback: do not sleep on the congestion queue if
> there are no congested BDIs or if significant congestion is not being
> encountered in the current zone), preferred_zone was only used for
> statistics and to determine the zoneidx from which to allocate from given
> the type requested.

True. So, following comment is now bogus. ;)

__alloc_pages_nodemask()
{
(snip)
        get_mems_allowed();
        /* The preferred zone is used for statistics later */
        first_zones_zonelist(zonelist, high_zoneidx, nodemask, &preferred_zone);
        if (!preferred_zone) {
                put_mems_allowed();
                return NULL;
        }


Now, we have three preferred_zone usage.
 1. for zone stat
 2. wait_iff_congested
 3. for calculate compaction duration

So, I have two question.  

1. Why do we need different vm stat policy mempolicy and cpuset? 
That said, if we are using mempolicy, the above nodemask variable is 
not NULL, then preferrd_zone doesn't point nearest zone. But it point 
always nearest zone when cpuset are used. 

2. Why wait_iff_congested in page_alloc only wait preferred zone? 
That said, theorically, any no congested zones in allocatable zones can
avoid waiting. Just code simplify?

3. I'm not sure why zone->compact_defer is not noted per zone, instead
noted only preferred zone. Do you know the intention?

I mean my first feeling tell me that we have a chance to make code simplify
more.

Mel, Can you please tell us your opinion?



> wait_iff_congested(), though, uses preferred_zone to determine if the
> congestion wait should be deferred because its dirty pages are backed by
> a congested bdi.  This incorrectly defers the timeout and busy loops in
> the page allocator with various cond_resched() calls if preferred_zone is
> not allowed in the current context, usually consuming 100% of a cpu.
> 
> This patch resets preferred_zone to an allowed zone in the slowpath if
> the allocation context is constrained by current's cpuset.  It also
> ensures preferred_zone is from the set of allowed nodes when called from
> within direct reclaim; allocations are always constrainted by cpusets
> since the context is always blockable.
> 
> Both of these uses of cpuset_current_mems_allowed are protected by
> get_mems_allowed().


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
