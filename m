Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B3DA76B01BA
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 12:05:22 -0400 (EDT)
Received: by pxi12 with SMTP id 12so3016997pxi.14
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 09:05:21 -0700 (PDT)
Date: Thu, 3 Jun 2010 01:05:13 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 3/5] oom: introduce find_lock_task_mm() to fix !mm
 false positives
Message-ID: <20100602160513.GC5326@barrios-desktop>
References: <20100531182526.1843.A69D9226@jp.fujitsu.com>
 <20100531183539.1849.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100531183539.1849.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, May 31, 2010 at 06:36:34PM +0900, KOSAKI Motohiro wrote:
> From: Oleg Nesterov <oleg@redhat.com>
> Subject: [PATCH 3/5] oom: introduce find_lock_task_mm() to fix !mm false positives
> 
> Almost all ->mm == NUL checks in oom_kill.c are wrong.
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
>   task without ->mm, but no matter what badness() returns the
>   task can be chosen if nothing else has been found yet.
> 
> Note! This patch is not enough, we need more changes.
> 
> 	- badness() was fixed, but oom_kill_task() still ignores
> 	  the task without ->mm
> 
> This will be addressed later.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> [rebase
> latest -mm and remove some obsoleted description]
Reviewed-by: Minchan Kim <minchan.kim@gmail.com?

Good catch but I have a nitpick. :)

find_lock_task_mm isn't good name of the function, I think. 
As you know, original goal of the function is to find sub-thread of p
which is alive(ie, doesn't release mm). 

task_lock is important for user of the function but minor.

I suggest following as 
/*
 * If we find alive thread of process, it returns task_struct of sub thread.
 * Notice. this function calls task_lock. So caller should call task_unlock.
 */
static struct task_struct *find_alive_subthread(struct task_struct *process)
{
... 
}

I don't forced my suggesion if you suggest much good name.
Regardless of accepting my suggestion, looks good to me.

> ---
>  mm/oom_kill.c |   28 +++++++++++++++++-----------
>  1 files changed, 17 insertions(+), 11 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index c87a6f4..162af2e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -52,6 +52,19 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
>  	return 0;
>  }
>  
> +static struct task_struct *find_lock_task_mm(struct task_struct *p)
> +{
> +	struct task_struct *t = p;
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
>  /**
>   * badness - calculate a numeric value for how bad this task has been
>   * @p: task struct of which task we should calculate
> @@ -74,7 +87,6 @@ static int has_intersects_mems_allowed(struct task_struct *tsk)
>  unsigned long badness(struct task_struct *p, unsigned long uptime)
>  {
>  	unsigned long points, cpu_time, run_time;
> -	struct mm_struct *mm;
>  	struct task_struct *child;
>  	int oom_adj = p->signal->oom_adj;
>  	struct task_cputime task_time;
> @@ -84,17 +96,14 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  	if (oom_adj == OOM_DISABLE)
>  		return 0;
>  
> -	task_lock(p);
> -	mm = p->mm;
> -	if (!mm) {
> -		task_unlock(p);
> +	p = find_lock_task_mm(p);
> +	if (!p)
>  		return 0;
> -	}
>  
>  	/*
>  	 * The memory size of the process is the basis for the badness.
>  	 */
> -	points = mm->total_vm;
> +	points = p->mm->total_vm;
>  
>  	/*
>  	 * After this unlock we can no longer dereference local variable `mm'
> @@ -117,7 +126,7 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>  	 */
>  	list_for_each_entry(child, &p->children, sibling) {
>  		task_lock(child);
> -		if (child->mm != mm && child->mm)
> +		if (child->mm != p->mm && child->mm)
>  			points += child->mm->total_vm/2 + 1;
>  		task_unlock(child);
>  	}
> @@ -256,9 +265,6 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  	for_each_process(p) {
>  		unsigned long points;
>  
> -		/* skip the tasks which have already released their mm. */
> -		if (!p->mm)
> -			continue;
>  		/* skip the init task and kthreads */
>  		if (is_global_init(p) || (p->flags & PF_KTHREAD))
>  			continue;
> -- 
> 1.6.5.2
> 
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
