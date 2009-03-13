Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5326B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 01:27:05 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2D5Qxnt025037
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:56:59 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D5R7YG1626362
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:57:07 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2D5QwGf010712
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 16:26:58 +1100
Date: Fri, 13 Mar 2009 10:56:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v5)
Message-ID: <20090313052653.GG16897@balbir.in.ibm.com>
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

Sorry, forgot to answer this question earlier.

I assume that by order-1 you mean 2 pages (2^1).

Are you suggesting that if soft limit reclaim fails, we retry? Not
sure if I understand your suggestion completely.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
