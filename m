Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DAC426B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 07:22:31 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBECMSul022002
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 14 Dec 2009 21:22:29 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 887AD45DE51
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:22:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6123E45DD76
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:22:28 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BDB01DB803A
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:22:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CA0811DB803B
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 21:22:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
In-Reply-To: <20091211164651.036f5340@annuminas.surriel.com>
References: <20091211164651.036f5340@annuminas.surriel.com>
Message-Id: <20091214210823.BBAE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 14 Dec 2009 21:22:24 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> Under very heavy multi-process workloads, like AIM7, the VM can
> get into trouble in a variety of ways.  The trouble start when
> there are hundreds, or even thousands of processes active in the
> page reclaim code.
> 
> Not only can the system suffer enormous slowdowns because of
> lock contention (and conditional reschedules) between thousands
> of processes in the page reclaim code, but each process will try
> to free up to SWAP_CLUSTER_MAX pages, even when the system already
> has lots of memory free.
> 
> It should be possible to avoid both of those issues at once, by
> simply limiting how many processes are active in the page reclaim
> code simultaneously.
> 
> If too many processes are active doing page reclaim in one zone,
> simply go to sleep in shrink_zone().
> 
> On wakeup, check whether enough memory has been freed already
> before jumping into the page reclaim code ourselves.  We want
> to use the same threshold here that is used in the page allocator
> for deciding whether or not to call the page reclaim code in the
> first place, otherwise some unlucky processes could end up freeing
> memory for the rest of the system.

This patch seems very similar to my old effort. afaik, there are another
two benefit.

1. Improve resource gurantee
   if thousands tasks start to vmscan at the same time, they eat all memory for
   PF_MEMALLOC. it might cause another dangerous problem. some filesystem
   and io device don't handle allocation failure properly.

2. Improve OOM contidion behavior
   Currently, vmscan don't handle SIGKILL at all. then if the system
   have hevy memory pressure, OOM killer can't kill the target process
   soon. it might cause OOM killer kill next innocent process.
   This patch can fix it.



> @@ -1600,6 +1612,31 @@ static void shrink_zone(int priority, struct zone *zone,
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  	int noswap = 0;
>  
> +	if (!current_is_kswapd() && atomic_read(&zone->concurrent_reclaimers) >
> +				max_zone_concurrent_reclaimers &&
> +				(sc->gfp_mask & (__GFP_IO|__GFP_FS)) ==
> +				(__GFP_IO|__GFP_FS)) {
> +		/*
> +		 * Do not add to the lock contention if this zone has
> +		 * enough processes doing page reclaim already, since
> +		 * we would just make things slower.
> +		 */
> +		sleep_on(&zone->reclaim_wait);

Oops. this is bug. sleep_on() is not SMP safe.


I made few fixing patch today. I'll post it soon.


btw, following is mesurement result by hackbench.
================

unit: sec

parameter			old		new
130 (5200 processes)		5.463		4.442
140 (5600 processes)		479.357		7.792
150 (6000 processes)		729.640		20.529



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
