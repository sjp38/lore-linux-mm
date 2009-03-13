Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0ADBD6B004D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 00:31:47 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D4Vhpu011563
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Mar 2009 13:31:45 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 64A9C45DE57
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:31:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BC0945DD79
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:31:43 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 07DD7E18001
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:31:43 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A8AC51DB803B
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:31:42 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention (v5)
In-Reply-To: <20090313041341.GA16897@balbir.in.ibm.com>
References: <20090313094735.43D9.A69D9226@jp.fujitsu.com> <20090313041341.GA16897@balbir.in.ibm.com>
Message-Id: <20090313132426.AF4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Mar 2009 13:31:41 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> > > -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > > +	/*
> > > +	 * Try to free up some pages from the memory controllers soft
> > > +	 * limit queue.
> > > +	 */
> > > +	did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
> > > +	if (!order || !did_some_progress)
> > > +		did_some_progress += try_to_free_pages(zonelist, order,
> > > +							gfp_mask);
> > 
> > I have two objection to this.
> > 
> > - "if (!order || !did_some_progress)" mean no call try_to_free_pages()
> >   in order>0 and did_some_progress>0 case.
> >   but mem_cgroup_soft_limit_reclaim() don't have lumpy reclaim.
> >   then, it break high order reclaim.
> 
> I am sending a fix for this right away. Thanks, the check should be
> if (order || !did_some_progress)

No.

it isn't enough.
after is does, order-1 allocation case twrice reclaim (soft limit shrinking
and normal try_to_free_pages()).
then, order-1 reclaim makes slower about 2 times.

unfortunately, order-1 allocation is very frequent. it is used for
kernel stack.


> > - in global reclaim view, foreground reclaim and background reclaim's
> >   reclaim rate is about 1:9 typically.
> >   then, kswapd reclaim the pages by global lru order before proceccing
> >   this logic.
> >   IOW, this soft limit is not SOFT.
> 
> It depends on what you mean by soft. I call them soft since they are
> imposed only when there is contention. If you mean kswapd runs more
> often than direct reclaim, that is true, but it does not impact this
> code extensively since the high water mark is a very small compared to
> the pages present on the system.

No.

My point is, contention case kswapd wakeup. and kswapd reclaim by
global lru order before soft limit shrinking.
Therefore, In typical usage, mem_cgroup_soft_limit_reclaim() almost
don't call properly.

soft limit shrinking should run before processing global reclaim.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
