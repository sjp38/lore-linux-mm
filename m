Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B81566B0093
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 23:25:04 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N4MC9U027408
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 13:22:13 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 31EB345DE4F
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 13:22:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F016945DD72
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 13:22:11 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C185E1DB8044
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 13:22:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6888C1DB803A
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 13:22:11 +0900 (JST)
Date: Mon, 23 Mar 2009 13:20:45 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] Memory controller soft limit reclaim on contention
 (v7)
Message-Id: <20090323132045.092127da.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323041253.GH24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165752.27274.36030.sendpatchset@localhost.localdomain>
	<20090320130630.8b9ac3c7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090322142748.GC24227@balbir.in.ibm.com>
	<20090323090205.49fc95d0.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323041253.GH24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 09:42:53 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > Even if order > 0, mem_cgroup_try_to_free_pages() may be able to recover
> > the situation. Maybe it's better to allow lumpty-reclaim even when
> > !scanning_global_lru().
> > 
> 
> if order > 0, we let the global reclaim handler reclaim (scan global
> LRU). I think the chance of success is higher through that path,
> having said that I have not experimented with trying to allow
> lumpy-reclaim from memory cgroup LRU's. I think that should be a
> separate effort from this one.
> 

But ignoring that will make the cost twice....

> > 
> > > Even if we retry, we do a simple check for soft-limit-reclaim, if
> > > there is really something to be reclaimed, we reclaim from there
> > > first.
> > > 
> > That means you reclaim memory twice ;) 
> > AFAIK,
> >   - fork() -> task_struct/stack
> >     page table in x86 PAE mode
> > requires order-1 pages very frequently and this "call twice" approach will kill
> > the application peformance very effectively.
> 
> Yes, it would if this was the only way to allocate pages. But look at
> reality, with kswapd running in the background, how frequently do you
> expect to hit the reclaim path. Could you clarify what you mean by
> order-1 (2^1), if so soft limit reclaim is not invoked and it should
> not hurt performance. What am I missing?
> 
Hmm, maybe running hackbench under memory pressure will tell the answer.
Anyway, plz get Ack from people for memory management.
Rik or Mel or Christoph or Nick or someone.


> > 
> > > >                if (!did_some_progress)
> > > >                     did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > > >         }else
> > > >                     did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > > > 
> > > > 
> > > >         maybe a bit more concervative.
> > > > 
> > > > 
> > > >         And I wonder "nodemask" should be checked or not..
> > > >         softlimit reclaim doesn't seem to work well with nodemask...
> > > 
> > > Doesn't the zonelist take care of nodemask?
> > > 
> > 
> > Not sure, but I think, no check. hmm BUG in vmscan.c ?
> > 
> 
> The zonelist is built using policy_zonelist, that handles nodemask as
> well. That should keep the zonelist and nodemask in sync.. no?
> 

I already sent a patch.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
