Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D03586B01B6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 02:53:20 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o516rGnF024093
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Jun 2010 15:53:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B39DE45DE81
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 15:53:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8197A45DE7E
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 15:53:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 490F71DB8037
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 15:53:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id DD4E01DB803B
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 15:53:15 +0900 (JST)
Date: Tue, 1 Jun 2010 15:48:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: Fix do_try_to_free_pages() return value when
 priority==0 reclaim failure
Message-Id: <20100601154824.1d87e5a4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100601122140.2436.A69D9226@jp.fujitsu.com>
References: <20100430224316.056084208@cmpxchg.org>
	<xr93sk57yl9o.fsf@ninji.mtv.corp.google.com>
	<20100601122140.2436.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue,  1 Jun 2010 12:29:41 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

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
> Reported-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you very much!!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
