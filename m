Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5FF6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 01:07:49 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2D4sPwx031800
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:54:25 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D584Ur958654
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:08:04 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2D57jKM001398
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:07:46 +1100
Date: Fri, 13 Mar 2009 10:37:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v5)
Message-ID: <20090313050740.GF16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090313041341.GA16897@balbir.in.ibm.com> <20090313132426.AF4D.A69D9226@jp.fujitsu.com> <20090313134548.AF50.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090313134548.AF50.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-13 13:50:26]:

> > > > I have two objection to this.
> > > > 
> > > > - "if (!order || !did_some_progress)" mean no call try_to_free_pages()
> > > >   in order>0 and did_some_progress>0 case.
> > > >   but mem_cgroup_soft_limit_reclaim() don't have lumpy reclaim.
> > > >   then, it break high order reclaim.
> > > 
> > > I am sending a fix for this right away. Thanks, the check should be
> > > if (order || !did_some_progress)
> > 
> > No.
> > 
> > it isn't enough.
> > after is does, order-1 allocation case twrice reclaim (soft limit shrinking
> > and normal try_to_free_pages()).
> > then, order-1 reclaim makes slower about 2 times.
> > 
> > unfortunately, order-1 allocation is very frequent. it is used for
> > kernel stack.
> 
> in normal order-1 reclaim is:
> 
> 1. try_to_free_pages()
> 2. get_page_from_freelist()
> 3. retry if order-1 page don't exist
> 
> Coundn't you use the same logic?
> 
> > > > - in global reclaim view, foreground reclaim and background reclaim's
> > > >   reclaim rate is about 1:9 typically.
> > > >   then, kswapd reclaim the pages by global lru order before proceccing
> > > >   this logic.
> > > >   IOW, this soft limit is not SOFT.
> > > 
> > > It depends on what you mean by soft. I call them soft since they are
> > > imposed only when there is contention. If you mean kswapd runs more
> > > often than direct reclaim, that is true, but it does not impact this
> > > code extensively since the high water mark is a very small compared to
> > > the pages present on the system.
> > 
> > No.
> > 
> > My point is, contention case kswapd wakeup. and kswapd reclaim by
> > global lru order before soft limit shrinking.
> > Therefore, In typical usage, mem_cgroup_soft_limit_reclaim() almost
> > don't call properly.
> > 
> > soft limit shrinking should run before processing global reclaim.
> 
> Do you have the reason of disliking call from kswapd ?
>

Yes, I sent that reason out as comments to Kame's patches. kswapd or
balance_pgdat controls the zones, priority and in effect how many
pages we scan while doing reclaim. I did lots of experiments and found
that if soft limit reclaim occurred from kswapd, soft_limit_reclaim
would almost always fail and shrink_zone() would succeed, since it
looks at the whole zone and is always able to find some pages at all
priority levels. It also does not allow for targetted reclaim based on
how much we exceed the soft limit by. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
