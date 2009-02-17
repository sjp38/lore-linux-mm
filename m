Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id DF1296B008A
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 01:44:01 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n1H6hseG016853
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 12:13:54 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1H6fGiW3252350
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 12:11:16 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n1H6hrgq022436
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 17:43:54 +1100
Date: Tue, 17 Feb 2009 12:13:49 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches (v2)
Message-ID: <20090217064349.GC3513@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090216110844.29795.17804.sendpatchset@localhost.localdomain> <20090217090523.975bbec2.kamezawa.hiroyu@jp.fujitsu.com> <20090217030526.GA20958@balbir.in.ibm.com> <20090217130352.4ba7f91c.kamezawa.hiroyu@jp.fujitsu.com> <20090217044110.GD20958@balbir.in.ibm.com> <20090217141039.440e5463.kamezawa.hiroyu@jp.fujitsu.com> <20090217053903.GA3513@balbir.in.ibm.com> <20090217153658.225e1c5c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090217153658.225e1c5c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-17 15:36:58]:

> On Tue, 17 Feb 2009 11:09:03 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-17 14:10:39]:
> > 
> > > On Tue, 17 Feb 2009 10:11:10 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-17 13:03:52]:
> > > > 
> > > > > On Tue, 17 Feb 2009 08:35:26 +0530
> > > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > I don't want to add any new big burden to kernel hackers of memory management,
> > > > > they work hard to improve memory reclaim. This patch will change the behavior.
> > > > > 
> > > > 
> > > > I don't think I agree, this approach suggests that before doing global
> > > > reclaim, there are several groups that are using more than their
> > > > share of memory, so it makes sense to reclaim from them first.
> > > > 
> > > 
> > > > 
> > > > > BTW, in typical bad case, several threads on cpus goes into memory recalim at once and
> > > > > all thread will visit this memcg's soft-limit tree at once and soft-limit will
> > > > > not work as desired anyway.
> > > > > You can't avoid this problem at alloc_page() hot-path.
> > > > 
> > > > Even if all threads go into soft-reclaim at once, the tree will become
> > > > empty after a point and we will just return saying there are no more
> > > > memcg's to reclaim from (we remove the memcg from the tree when
> > > > reclaiming), then those threads will go into regular reclaim if there
> > > > is still memory pressure.
> > > 
> > > Yes. the largest-excess group will be removed. So, it seems that it doesn't work
> > > as designed. rbtree is considered as just a hint ? If so, rbtree seems to be
> > > overkill.
> > > 
> > > just a question:
> > > Assume memcg under hierarchy.
> > >    ../group_A/                 usage=1G, soft_limit=900M  hierarchy=1
> > >               01/              usage=200M, soft_limit=100M
> > >               02/              usage=300M, soft_limit=200M
> > >               03/              usage=500M, soft_limit=300M  <==== 200M over.
> > >                  004/          usage=200M, soft_limit=100M
> > >                  005/          usage=300M, soft_limit=200M
> > > 
> > > At memory shortage, group 03's memory will be reclaimed 
> > >   - reclaim memory from 03, 03/004, 03/005
> > > 
> > > When 100M of group 03' memory is reclaimed, group_A 's memory is reclaimd at the
> > > same time, implicitly. Doesn't this break your rb-tree ?
> > > 
> > > I recommend you that soft-limit can be only applied to the node which is top of
> > > hierarchy.
> > 
> > Yes, that can be done, but the reason for putting both was to target
> > the right memcg early.
> > 
> My point is  that sort by rb-tree is broken in above case.
>

OK, I'll explore, experiment and think about adding just the root 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
