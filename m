Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B3EF96B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 00:58:22 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2D4ivBM028436
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:44:57 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D4wZov467252
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:58:35 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2D4wHNj016538
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:58:17 +1100
Date: Fri, 13 Mar 2009 10:28:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v5)
Message-ID: <20090313045811.GB16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090313094735.43D9.A69D9226@jp.fujitsu.com> <20090313041341.GA16897@balbir.in.ibm.com> <20090313132426.AF4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090313132426.AF4D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-13 13:31:41]:

> > > > -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > > > +	/*
> > > > +	 * Try to free up some pages from the memory controllers soft
> > > > +	 * limit queue.
> > > > +	 */
> > > > +	did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
> > > > +	if (!order || !did_some_progress)
> > > > +		did_some_progress += try_to_free_pages(zonelist, order,
> > > > +							gfp_mask);
> > > 
> > > I have two objection to this.
> > > 
> > > - "if (!order || !did_some_progress)" mean no call try_to_free_pages()
> > >   in order>0 and did_some_progress>0 case.
> > >   but mem_cgroup_soft_limit_reclaim() don't have lumpy reclaim.
> > >   then, it break high order reclaim.
> > 
> > I am sending a fix for this right away. Thanks, the check should be
> > if (order || !did_some_progress)
> 
> No.
> 
> it isn't enough.
> after is does, order-1 allocation case twrice reclaim (soft limit shrinking
> and normal try_to_free_pages()).
> then, order-1 reclaim makes slower about 2 times.

My benchmarks don't show any degredation...  this slowdown will occur *iff*
soft limits are enabled and groups are over their soft limit. Even if
soft limit reclaim were to be initiated through kswapd (which is
through my experimentation, a bad place to do it), you'd have delays
incurred since you would have increased contention on zone lru lock.

Anyway, lets boil it down your comment to

The issue you claim occurs when the cgroups are over their soft
limit and there is memory contention.

> 
> unfortunately, order-1 allocation is very frequent. it is used for
> kernel stack.
>
> 
> > > - in global reclaim view, foreground reclaim and background reclaim's
> > >   reclaim rate is about 1:9 typically.
> > >   then, kswapd reclaim the pages by global lru order before proceccing
> > >   this logic.
> > >   IOW, this soft limit is not SOFT.
> > 
> > It depends on what you mean by soft. I call them soft since they are
> > imposed only when there is contention. If you mean kswapd runs more
> > often than direct reclaim, that is true, but it does not impact this
> > code extensively since the high water mark is a very small compared to
> > the pages present on the system.
> 
> No.
> 
> My point is, contention case kswapd wakeup. and kswapd reclaim by
> global lru order before soft limit shrinking.

I've seen the same even if kswapd is used for reclaim, since we have
no control over priority and the length to scan. shrink_zone() does
more work than soft limit reclaim.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
