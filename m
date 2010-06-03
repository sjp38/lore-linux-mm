Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E626F6B0227
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 11:23:09 -0400 (EDT)
Date: Thu, 3 Jun 2010 17:21:43 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 08/12] oom: dump_tasks() use find_lock_task_mm() too
Message-ID: <20100603152143.GA8005@redhat.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com> <20100603152350.725F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100603152350.725F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/03, KOSAKI Motohiro wrote:
>
> dump_task() should use find_lock_task_mm() too. It is necessary for
> protecting task-exiting race.

This patch also replaces the pointless do_each_thread() with
for_each_process(), good.

Reviewed-by: Oleg Nesterov <oleg@redhat.com>

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/oom_kill.c |   37 ++++++++++++++++++++-----------------
>  1 files changed, 20 insertions(+), 17 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 35a2ecc..6360c56 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -345,35 +345,38 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>   */
>  static void dump_tasks(const struct mem_cgroup *mem)
>  {
> -	struct task_struct *g, *p;
> +	struct task_struct *p;
> +	struct task_struct *task;
>  
>  	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
>  	       "name\n");
> -	do_each_thread(g, p) {
> -		struct mm_struct *mm;
>  
> -		if (mem && !task_in_mem_cgroup(p, mem))
> +	for_each_process(p) {
> +		/*
> +		 * We don't have is_global_init() check here, because the old
> +		 * code do that. printing init process is not big matter. But 
> +		 * we don't hope to make unnecessary compatiblity breaking.
> +		 */
> +		if (p->flags & PF_KTHREAD)
>  			continue;
> -		if (!thread_group_leader(p))
> +		if (mem && !task_in_mem_cgroup(p, mem))
>  			continue;
>  
> -		task_lock(p);
> -		mm = p->mm;
> -		if (!mm) {
> +		task = find_lock_task_mm(p);
> +		if (!task)
>  			/*
> -			 * total_vm and rss sizes do not exist for tasks with no
> -			 * mm so there's no need to report them; they can't be
> -			 * oom killed anyway.
> +			 * Probably oom vs task-exiting race was happen and ->mm
> +			 * have been detached. thus there's no need to report them;
> +			 * they can't be oom killed anyway.
>  			 */
> -			task_unlock(p);
>  			continue;
> -		}
> +
>  		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
> -		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
> -		       get_mm_rss(mm), (int)task_cpu(p), p->signal->oom_adj,
> +		       task->pid, __task_cred(task)->uid, task->tgid, task->mm->total_vm,
> +		       get_mm_rss(task->mm), (int)task_cpu(task), task->signal->oom_adj,
>  		       p->comm);
> -		task_unlock(p);
> -	} while_each_thread(g, p);
> +		task_unlock(task);
> +	}
>  }
>  
>  static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
> -- 
> 1.6.5.2
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
