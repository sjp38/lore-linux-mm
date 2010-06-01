Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D99756B01E5
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 08:24:10 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o51CD36h014269
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 08:13:03 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o51CO1Dn121958
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 08:24:01 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o51CO1Yo030206
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 08:24:01 -0400
Received: from balbir-laptop ([9.77.209.155])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id o51CNxWY030079
	for <linux-mm@kvack.org>; Tue, 1 Jun 2010 08:24:00 -0400
Resent-Message-ID: <20100601122358.GL2804@balbir.in.ibm.com>
Resent-To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Date: Tue, 1 Jun 2010 13:40:59 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] vmscan: Fix do_try_to_free_pages() return value when
 priority==0 reclaim failure
Message-ID: <20100601081059.GA2804@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100430224316.056084208@cmpxchg.org>
 <xr93sk57yl9o.fsf@ninji.mtv.corp.google.com>
 <20100601122140.2436.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100601122140.2436.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [2010-06-01 12:29:41]:

> CC to memcg folks.
> 
> > I agree with the direction of this patch, but I am seeing a hang when
> > testing with mmotm-2010-05-21-16-05.  The following test hangs, unless I
> > remove this patch from mmotm:
> >   mount -t cgroup none /cgroups -o memory
> >   mkdir /cgroups/cg1
> >   echo $$ > /cgroups/cg1/tasks
> >   dd bs=1024 count=1024 if=/dev/null of=/data/foo
> >   echo $$ > /cgroups/tasks
> >   echo 1 > /cgroups/cg1/memory.force_empty
> > 
> > I think the hang is caused by the following portion of
> > mem_cgroup_force_empty():
> > 	while (nr_retries && mem->res.usage > 0) {
> > 		int progress;
> > 
> > 		if (signal_pending(current)) {
> > 			ret = -EINTR;
> > 			goto out;
> > 		}
> > 		progress = try_to_free_mem_cgroup_pages(mem, GFP_KERNEL,
> > 						false, get_swappiness(mem));
> > 		if (!progress) {
> > 			nr_retries--;
> > 			/* maybe some writeback is necessary */
> > 			congestion_wait(BLK_RW_ASYNC, HZ/10);
> > 		}
> > 
> > 	}
> > 
> > With this patch applied, it is possible that when do_try_to_free_pages()
> > calls shrink_zones() for priority 0 that shrink_zones() may return 1
> > indicating progress, even though no pages may have been reclaimed.
> > Because this is a cgroup operation, scanning_global_lru() is false and
> > the following portion of do_try_to_free_pages() fails to set ret=0.
> > > 	if (ret && scanning_global_lru(sc))
> > >  		ret = sc->nr_reclaimed;
> > This leaves ret=1 indicating that do_try_to_free_pages() reclaimed 1
> > page even though it did not reclaim any pages.  Therefore
> > mem_cgroup_force_empty() erroneously believes that
> > try_to_free_mem_cgroup_pages() is making progress (one page at a time),
> > so there is an endless loop.
> 
> Good catch!
> 
> Yeah, your analysis is fine. thank you for both your testing and
> making analysis.
> 
> Unfortunatelly, this logic need more fix. because It have already been
> corrupted by another regression. my point is, if priority==0 reclaim 
> failure occur, "ret = sc->nr_reclaimed" makes no sense at all.
> 
> The fixing patch is here. What do you think?
> 
> 
> 
> From 49a395b21fe1b2f864112e71d027ffcafbdc9fc0 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 1 Jun 2010 11:29:50 +0900
> Subject: [PATCH] vmscan: Fix do_try_to_free_pages() return value when priority==0 reclaim failure
> 
> Greg Thelen reported recent Johannes's stack diet patch makes kernel
> hang. His test is following.
> 
>   mount -t cgroup none /cgroups -o memory
>   mkdir /cgroups/cg1
>   echo $$ > /cgroups/cg1/tasks
>   dd bs=1024 count=1024 if=/dev/null of=/data/foo
>   echo $$ > /cgroups/tasks
>   echo 1 > /cgroups/cg1/memory.force_empty
> 
> Actually, This OOM hard to try logic have been corrupted
> since following two years old patch.
> 
> 	commit a41f24ea9fd6169b147c53c2392e2887cc1d9247
> 	Author: Nishanth Aravamudan <nacc@us.ibm.com>
> 	Date:   Tue Apr 29 00:58:25 2008 -0700
> 
> 	    page allocator: smarter retry of costly-order allocations
> 
> Original intention was "return success if the system have shrinkable
> zones though priority==0 reclaim was failure". But the above patch
> changed to "return nr_reclaimed if .....". Oh, That forgot nr_reclaimed
> may be 0 if priority==0 reclaim failure.
> 
> And Johannes's patch made more corrupt. Originally, priority==0 recliam
> failure on memcg return 0, but this patch changed to return 1. It
> totally confused memcg.
> 
> This patch fixes it completely.
>

The patch seems reasonable to me, although I've not tested it

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
