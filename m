Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 250D86B003D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:10:26 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N03Vk2015096
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 09:03:32 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9605C45DD72
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:03:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 646C145DD74
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:03:31 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 40A12E08004
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:03:31 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D271A1DB8014
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:03:30 +0900 (JST)
Date: Mon, 23 Mar 2009 09:02:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] Memory controller soft limit reclaim on contention
 (v7)
Message-Id: <20090323090205.49fc95d0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090322142748.GC24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165752.27274.36030.sendpatchset@localhost.localdomain>
	<20090320130630.8b9ac3c7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090322142748.GC24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, 22 Mar 2009 19:57:48 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-20 13:06:30]:
> 
> > On Thu, 19 Mar 2009 22:27:52 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > Feature: Implement reclaim from groups over their soft limit
> > > 
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > 
> > > Changelog v7...v6
> > > 1. Refactored out reclaim_options patch into a separate patch
> > > 2. Added additional checks for all swap off condition in
> > >    mem_cgroup_hierarchical_reclaim()
> > 
> > > -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > > +	/*
> > > +	 * Try to free up some pages from the memory controllers soft
> > > +	 * limit queue.
> > > +	 */
> > > +	did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
> > > +	if (order || !did_some_progress)
> > > +		did_some_progress += try_to_free_pages(zonelist, order,
> > > +							gfp_mask);
> > >  
> > 
> > Anyway, my biggest concern is here, always.
> > 
> >         By this.
> >           if (order > 1), try_to_free_pages() is called twice.
> 
> try_to_free_mem_cgroup_pages and try_to_free_pages() are called
> 
> >         Hmm...how about
> 
> 
> > 
> >         if (!pages_reclaimed && !(gfp_mask & __GFP_NORETRY)) { # this is the first loop or noretry
> >                did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
> 
> OK, I see what you mean.. but the cost of the
> mem_cgroup_soft_limit_reclaim() is really a low overhead call, which
> will bail out very quickly if nothing is over their soft limit.

My point is "if something is over soft limit" case. Memory is reclaiemd twice.
My above code tries to avoid call memory-reclaim twice.

Even if order > 0, mem_cgroup_try_to_free_pages() may be able to recover
the situation. Maybe it's better to allow lumpty-reclaim even when
!scanning_global_lru().


> Even if we retry, we do a simple check for soft-limit-reclaim, if
> there is really something to be reclaimed, we reclaim from there
> first.
> 
That means you reclaim memory twice ;) 
AFAIK,
  - fork() -> task_struct/stack
    page table in x86 PAE mode
requires order-1 pages very frequently and this "call twice" approach will kill
the application peformance very effectively.

> >                if (!did_some_progress)
> >                     did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> >         }else
> >                     did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > 
> > 
> >         maybe a bit more concervative.
> > 
> > 
> >         And I wonder "nodemask" should be checked or not..
> >         softlimit reclaim doesn't seem to work well with nodemask...
> 
> Doesn't the zonelist take care of nodemask?
> 

Not sure, but I think, no check. hmm BUG in vmscan.c ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
