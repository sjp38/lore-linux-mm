Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 32D086B01B7
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 11:03:16 -0400 (EDT)
Received: by pzk6 with SMTP id 6so1154146pzk.1
        for <linux-mm@kvack.org>; Wed, 02 Jun 2010 08:03:13 -0700 (PDT)
Date: Thu, 3 Jun 2010 00:03:04 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 5/5] oom: dump_tasks() use find_lock_task_mm() too
Message-ID: <20100602150304.GA5326@barrios-desktop>
References: <20100601144238.243A.A69D9226@jp.fujitsu.com>
 <20100601145033.2446.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100601145033.2446.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi, Kosaki. 

On Tue, Jun 01, 2010 at 02:51:49PM +0900, KOSAKI Motohiro wrote:
> dump_task() should have the same process iteration logic as
> select_bad_process().
> 
> It is needed for protecting from task exiting race.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/oom_kill.c |   31 +++++++++++++------------------
>  1 files changed, 13 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index cbad4d4..a8af9e8 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -344,35 +344,30 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
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
> +
> +	for_each_process(p) {
>  		struct mm_struct *mm;
>  
> -		if (mem && !task_in_mem_cgroup(p, mem))
> +		if (is_global_init(p) || (p->flags & PF_KTHREAD))

select_bad_process needs is_global_init check to not select init as victim.
But in this case, it is just for dumping information of tasks. 

>  			continue;
> -		if (!thread_group_leader(p))
> +		if (mem && !task_in_mem_cgroup(p, mem))
>  			continue;
>  
> -		task_lock(p);
> -		mm = p->mm;
> -		if (!mm) {
> -			/*
> -			 * total_vm and rss sizes do not exist for tasks with no
> -			 * mm so there's no need to report them; they can't be
> -			 * oom killed anyway.
> -			 */

Please, do not remove the comment for mm newbies unless you think it's useless.

> -			task_unlock(p);
> +		task = find_lock_task_mm(p);
> +		if (!task)
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
