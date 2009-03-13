Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4FD586B0047
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 03:03:54 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2D73kMC014619
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 12:33:46 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D70WHr1204286
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 12:30:32 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2D73j6f000507
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:03:45 +1100
Date: Fri, 13 Mar 2009 12:33:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v5)
Message-ID: <20090313070340.GI16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090313134548.AF50.A69D9226@jp.fujitsu.com> <20090313050740.GF16897@balbir.in.ibm.com> <20090313145032.AF4D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090313145032.AF4D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2009-03-13 15:54:03]:

> > > > My point is, contention case kswapd wakeup. and kswapd reclaim by
> > > > global lru order before soft limit shrinking.
> > > > Therefore, In typical usage, mem_cgroup_soft_limit_reclaim() almost
> > > > don't call properly.
> > > > 
> > > > soft limit shrinking should run before processing global reclaim.
> > > 
> > > Do you have the reason of disliking call from kswapd ?
> > >
> > 
> > Yes, I sent that reason out as comments to Kame's patches. kswapd or
> > balance_pgdat controls the zones, priority and in effect how many
> > pages we scan while doing reclaim. I did lots of experiments and found
> > that if soft limit reclaim occurred from kswapd, soft_limit_reclaim
> > would almost always fail and shrink_zone() would succeed, since it
> > looks at the whole zone and is always able to find some pages at all
> > priority levels. It also does not allow for targetted reclaim based on
> > how much we exceed the soft limit by. 
> 
> hm
> I read past discussion. so, I think we discuss many aspect at once.
> So, my current thinking is below, 
> 
> (1) if the group don't have any soft limit shrinking page, 
>     mem_cgroup_soft_limit_reclaim() spent time unnecessary.
>     -> right.

If the soft limit RB tree is empty, we don't spend any time at all.
Are you referring to something else? Am I missing something? The tree
will be empty if no group is over the soft limit.

>       actually, past global reclaim had similar problem.
>       then zone_is_all_unreclaimable() was introduced.
>       maybe we can use similar technique to memcg.
> 
> (2) mem_cgroup_soft_limit_reclaim() should be called from?
>     -> under discussion.
>        we should solve (1) at first for proper constructive
>        discussion.
> 
> (3) What's "fairness" of soft limit?
>     -> perfectly another aspect.
> 
> So, I'd like to discuss (1) at first.
> Although we don't kswapd shrinking, (1) is problem.
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
