Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 006326B00B1
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 03:27:48 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2N8QkhQ008021
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 19:26:46 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2N8Sxsl1077424
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 19:29:01 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2N8SfgE015510
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 19:28:41 +1100
Date: Mon, 23 Mar 2009 13:58:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/5] Memory controller soft limit reclaim on contention
	(v7)
Message-ID: <20090323082822.GM24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090319165752.27274.36030.sendpatchset@localhost.localdomain> <20090320130630.8b9ac3c7.kamezawa.hiroyu@jp.fujitsu.com> <20090322142748.GC24227@balbir.in.ibm.com> <20090323090205.49fc95d0.kamezawa.hiroyu@jp.fujitsu.com> <20090323041253.GH24227@balbir.in.ibm.com> <20090323132045.092127da.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090323132045.092127da.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-23 13:20:45]:

> On Mon, 23 Mar 2009 09:42:53 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > > Even if order > 0, mem_cgroup_try_to_free_pages() may be able to recover
> > > the situation. Maybe it's better to allow lumpty-reclaim even when
> > > !scanning_global_lru().
> > > 
> > 
> > if order > 0, we let the global reclaim handler reclaim (scan global
> > LRU). I think the chance of success is higher through that path,
> > having said that I have not experimented with trying to allow
> > lumpy-reclaim from memory cgroup LRU's. I think that should be a
> > separate effort from this one.
> > 
> 
> But ignoring that will make the cost twice....
>

OK, lets fix it, but it as a separate effort and with data that shows
us the same.
 
> > > 
> > > > Even if we retry, we do a simple check for soft-limit-reclaim, if
> > > > there is really something to be reclaimed, we reclaim from there
> > > > first.
> > > > 
> > > That means you reclaim memory twice ;) 
> > > AFAIK,
> > >   - fork() -> task_struct/stack
> > >     page table in x86 PAE mode
> > > requires order-1 pages very frequently and this "call twice" approach will kill
> > > the application peformance very effectively.
> > 
> > Yes, it would if this was the only way to allocate pages. But look at
> > reality, with kswapd running in the background, how frequently do you
> > expect to hit the reclaim path. Could you clarify what you mean by
> > order-1 (2^1), if so soft limit reclaim is not invoked and it should
> > not hurt performance. What am I missing?
> > 
> Hmm, maybe running hackbench under memory pressure will tell the answer.
> Anyway, plz get Ack from people for memory management.
> Rik or Mel or Christoph or Nick or someone.
>

Rik is on the cc and is linux-mm. I hope they'll look at it.
 
> 
> > > 
> > > > >                if (!did_some_progress)
> > > > >                     did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > > > >         }else
> > > > >                     did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > > > > 
> > > > > 
> > > > >         maybe a bit more concervative.
> > > > > 
> > > > > 
> > > > >         And I wonder "nodemask" should be checked or not..
> > > > >         softlimit reclaim doesn't seem to work well with nodemask...
> > > > 
> > > > Doesn't the zonelist take care of nodemask?
> > > > 
> > > 
> > > Not sure, but I think, no check. hmm BUG in vmscan.c ?
> > > 
> > 
> > The zonelist is built using policy_zonelist, that handles nodemask as
> > well. That should keep the zonelist and nodemask in sync.. no?
> > 
> 
> I already sent a patch.

I've seen it, the basic assumption of the patch is that

policy_zonelist() and for_each_zone_zonelist_nodemask() where nodemask
is derived from policy_nodemask() give different results.. correct?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
