Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 220076B003D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 09:43:56 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2MERxdt021468
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:57:59 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2MES7ki1056888
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:58:07 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2MERwUF008600
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:57:58 +0530
Date: Sun, 22 Mar 2009 19:57:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 5/5] Memory controller soft limit reclaim on contention
	(v7)
Message-ID: <20090322142748.GC24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090319165752.27274.36030.sendpatchset@localhost.localdomain> <20090320130630.8b9ac3c7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090320130630.8b9ac3c7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-20 13:06:30]:

> On Thu, 19 Mar 2009 22:27:52 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Feature: Implement reclaim from groups over their soft limit
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Changelog v7...v6
> > 1. Refactored out reclaim_options patch into a separate patch
> > 2. Added additional checks for all swap off condition in
> >    mem_cgroup_hierarchical_reclaim()
> 
> > -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> > +	/*
> > +	 * Try to free up some pages from the memory controllers soft
> > +	 * limit queue.
> > +	 */
> > +	did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);
> > +	if (order || !did_some_progress)
> > +		did_some_progress += try_to_free_pages(zonelist, order,
> > +							gfp_mask);
> >  
> 
> Anyway, my biggest concern is here, always.
> 
>         By this.
>           if (order > 1), try_to_free_pages() is called twice.

try_to_free_mem_cgroup_pages and try_to_free_pages() are called

>         Hmm...how about


> 
>         if (!pages_reclaimed && !(gfp_mask & __GFP_NORETRY)) { # this is the first loop or noretry
>                did_some_progress = mem_cgroup_soft_limit_reclaim(zonelist, gfp_mask);

OK, I see what you mean.. but the cost of the
mem_cgroup_soft_limit_reclaim() is really a low overhead call, which
will bail out very quickly if nothing is over their soft limit.
Even if we retry, we do a simple check for soft-limit-reclaim, if
there is really something to be reclaimed, we reclaim from there
first.

>                if (!did_some_progress)
>                     did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
>         }else
>                     did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
> 
> 
>         maybe a bit more concervative.
> 
> 
>         And I wonder "nodemask" should be checked or not..
>         softlimit reclaim doesn't seem to work well with nodemask...

Doesn't the zonelist take care of nodemask?


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
