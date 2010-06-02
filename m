Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3F22C6B01B4
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 11:56:21 -0400 (EDT)
Date: Wed, 2 Jun 2010 17:54:55 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: remove PF_EXITING check completely
Message-ID: <20100602155455.GB9622@redhat.com>
References: <20100601093951.2430.A69D9226@jp.fujitsu.com> <20100601201843.GA20732@redhat.com> <20100602200732.F518.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100602200732.F518.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/02, KOSAKI Motohiro wrote:
>
> Today, I've thought to make some bandaid patches for this issue. but
> yes, I've reached the same conclusion.
>
> If we think multithread and core dump situation, all fixes are just
> bandaid. We can't remove deadlock chance completely.
>
> The deadlock is certenaly worst result, then, minor PF_EXITING optimization
> doesn't have so much worth.

Agreed! I was always wondering if it really helps in practice.


> Subject: [PATCH] oom: remove PF_EXITING check completely
>
> PF_EXITING is wrong check if the task have multiple threads. This patch
> removes it.
>
> Suggested-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Nick Piggin <npiggin@suse.de>
> ---
>  mm/oom_kill.c |   27 ---------------------------
>  1 files changed, 0 insertions(+), 27 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 9e7f0f9..b06f8d1 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -302,24 +302,6 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  		if (test_tsk_thread_flag(p, TIF_MEMDIE))
>  			return ERR_PTR(-1UL);
>
> -		/*
> -		 * This is in the process of releasing memory so wait for it
> -		 * to finish before killing some other task by mistake.
> -		 *
> -		 * However, if p is the current task, we allow the 'kill' to
> -		 * go ahead if it is exiting: this will simply set TIF_MEMDIE,
> -		 * which will allow it to gain access to memory reserves in
> -		 * the process of exiting and releasing its resources.
> -		 * Otherwise we could get an easy OOM deadlock.
> -		 */
> -		if ((p->flags & PF_EXITING) && p->mm) {
> -			if (p != current)
> -				return ERR_PTR(-1UL);
> -
> -			chosen = p;
> -			*ppoints = ULONG_MAX;
> -		}
> -
>  		points = badness(p, uptime.tv_sec);
>  		if (points > *ppoints || !chosen) {
>  			chosen = p;
> @@ -436,15 +418,6 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	if (printk_ratelimit())
>  		dump_header(p, gfp_mask, order, mem);
>
> -	/*
> -	 * If the task is already exiting, don't alarm the sysadmin or kill
> -	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> -	 */
> -	if (p->flags & PF_EXITING) {
> -		__oom_kill_process(p, mem, 0);
> -		return 0;
> -	}
> -
>  	printk(KERN_ERR "%s: kill process %d (%s) score %li or a child\n",
>  					message, task_pid_nr(p), p->comm, points);
>
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
