Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 954C06B007B
	for <linux-mm@kvack.org>; Sun, 14 Feb 2010 21:56:40 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1F2uak1012942
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Feb 2010 11:56:36 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 398EB45DE51
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 11:56:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 12AE145DE4E
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 11:56:36 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E8E8FE08009
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 11:56:35 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 72B42E08002
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 11:56:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 1/7 -mm] oom: filter tasks not sharing the same cpuset
In-Reply-To: <alpine.DEB.2.00.1002100227590.8001@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1002100224210.8001@chino.kir.corp.google.com> <alpine.DEB.2.00.1002100227590.8001@chino.kir.corp.google.com>
Message-Id: <20100215115154.727B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Feb 2010 11:56:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
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
> current anyway.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

This patch does right thing and looks promissing. but unfortunately
I have to NAK this patch temporary.

This patch is nearly just revert of the commit 7887a3da75. We have to
dig archaeology mail log and find why this reverting don't cause
the old pain again.

However, I personally think we end up to merge this. It is the reason
I've used "temporary".


> ---
>  mm/oom_kill.c |   12 +++---------
>  1 files changed, 3 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -35,7 +35,7 @@ static DEFINE_SPINLOCK(zone_scan_lock);
>  /* #define DEBUG */
>  
>  /*
> - * Is all threads of the target process nodes overlap ours?
> + * Do all threads of the target process overlap our allowed nodes?
>   */
>  static int has_intersects_mems_allowed(struct task_struct *tsk)
>  {
> @@ -167,14 +167,6 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
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
> @@ -266,6 +258,8 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  			continue;
>  		if (mem && !task_in_mem_cgroup(p, mem))
>  			continue;
> +		if (!has_intersects_mems_allowed(p))
> +			continue;
>  
>  		/*
>  		 * This task already has access to memory reserves and is
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
