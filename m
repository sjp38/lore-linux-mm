Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 780786B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 00:50:33 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2D4oSDB019501
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 13 Mar 2009 13:50:30 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1CC6145DD78
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:50:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF59245DD7D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:50:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 70A741DB8047
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:50:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 240FF1DB8042
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 13:50:27 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention (v5)
In-Reply-To: <20090313132426.AF4D.A69D9226@jp.fujitsu.com>
References: <20090313041341.GA16897@balbir.in.ibm.com> <20090313132426.AF4D.A69D9226@jp.fujitsu.com>
Message-Id: <20090313134548.AF50.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Mar 2009 13:50:26 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

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
> 
> unfortunately, order-1 allocation is very frequent. it is used for
> kernel stack.

in normal order-1 reclaim is:

1. try_to_free_pages()
2. get_page_from_freelist()
3. retry if order-1 page don't exist

Coundn't you use the same logic?

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
> Therefore, In typical usage, mem_cgroup_soft_limit_reclaim() almost
> don't call properly.
> 
> soft limit shrinking should run before processing global reclaim.

Do you have the reason of disliking call from kswapd ?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
