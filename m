Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8ADBD6B0071
	for <linux-mm@kvack.org>; Mon,  7 Jun 2010 09:15:40 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o57DDtHs003190
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 07:13:55 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o57DFPRX100076
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 07:15:26 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o57DFKxF025667
	for <linux-mm@kvack.org>; Mon, 7 Jun 2010 07:15:21 -0600
Date: Mon, 7 Jun 2010 18:28:28 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch 02/18] oom: introduce find_lock_task_mm() to fix !mm
 false positives
Message-ID: <20100607125828.GW4603@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1006061521310.32225@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1006061521310.32225@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2010-06-06 15:34:03]:

> From: Oleg Nesterov <oleg@redhat.com>
> 
> Almost all ->mm == NUL checks in oom_kill.c are wrong.

typo should be NULL

> 
> The current code assumes that the task without ->mm has already
> released its memory and ignores the process. However this is not
> necessarily true when this process is multithreaded, other live
> sub-threads can use this ->mm.
> 
> - Remove the "if (!p->mm)" check in select_bad_process(), it is
>   just wrong.
> 
> - Add the new helper, find_lock_task_mm(), which finds the live
>   thread which uses the memory and takes task_lock() to pin ->mm
> 
> - change oom_badness() to use this helper instead of just checking
>   ->mm != NULL.
> 
> - As David pointed out, select_bad_process() must never choose the
>   task without ->mm, but no matter what oom_badness() returns the
>   task can be chosen if nothing else has been found yet.
> 
>   Change oom_badness() to return int, change it to return -1 if
>   find_lock_task_mm() fails, and change select_bad_process() to
>   check points >= 0.
> 
> Note! This patch is not enough, we need more changes.
> 
> 	- oom_badness() was fixed, but oom_kill_task() still ignores
> 	  the task without ->mm
> 
> 	- oom_forkbomb_penalty() should use find_lock_task_mm() too,
> 	  and it also needs other changes to actually find the first
> 	  first-descendant children
> 
> This will be addressed later.
> 
> [kosaki.motohiro@jp.fujitsu.com: use in badness(), __oom_kill_task()]
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |   74 +++++++++++++++++++++++++++++++++------------------------
>  1 files changed, 43 insertions(+), 31 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -52,6 +52,20 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
>  	return 0;
>  }
> 
> +static struct task_struct *find_lock_task_mm(struct task_struct *p)
> +{
> +	struct task_struct *t = p;
> +
> +	do {
> +		task_lock(t);
> +		if (likely(t->mm))
> +			return t;
> +		task_unlock(t);
> +	} while_each_thread(p, t);
> +
> +	return NULL;
> +}
> +

Even if we miss this mm via p->mm, won't for_each_process actually
catch it? Are you suggesting that the main thread could have detached
the mm and a thread might still have it mapped? 


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
