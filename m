Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A90236B01E7
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:42:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58Bg0sM012374
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:42:00 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 247C845DE55
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:42:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E4BCF45DE51
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:59 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C640A1DB803A
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:59 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B6C31DB803C
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:41:59 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 07/18] oom: filter tasks not sharing the same cpuset
In-Reply-To: <alpine.DEB.2.00.1006061524310.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061524310.32225@chino.kir.corp.google.com>
Message-Id: <20100608203342.7663.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:41:58 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Tasks that do not share the same set of allowed nodes with the task that
> triggered the oom should not be considered as candidates for oom kill.
> 
> Tasks in other cpusets with a disjoint set of mems would be unfairly
> penalized otherwise because of oom conditions elsewhere; an extreme
> example could unfairly kill all other applications on the system if a
> single task in a user's cpuset sets itself to OOM_DISABLE and then uses
> more memory than allowed.
> 
> Killing tasks outside of current's cpuset rarely would free memory for
> current anyway.  To use a sane heuristic, we must ensure that killing a
> task would likely free memory for current and avoid needlessly killing
> others at all costs just because their potential memory freeing is
> unknown.  It is better to kill current than another task needlessly.
> 
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: Nick Piggin <npiggin@suse.de>
> Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |   10 ++--------
>  1 files changed, 2 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -184,14 +184,6 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  		points /= 4;
>  
>  	/*
> -	 * If p's nodes don't overlap ours, it may still help to kill p
> -	 * because p may have allocated or otherwise mapped memory on
> -	 * this node before. However it will be less likely.
> -	 */
> -	if (!has_intersects_mems_allowed(p))
> -		points /= 8;
> -
> -	/*
>  	 * Adjust the score by oom_adj.
>  	 */
>  	if (oom_adj) {
> @@ -277,6 +269,8 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  			continue;
>  		if (mem && !task_in_mem_cgroup(p, mem))
>  			continue;
> +		if (!has_intersects_mems_allowed(p))
> +			continue;
>  
>  		/*
>  		 * This task already has access to memory reserves and is

pulled. but I'll merge my fix. and append historical remark.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
