Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A07056B01DB
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:55:43 -0400 (EDT)
Date: Tue, 8 Jun 2010 12:55:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 03/18] oom: dump_tasks use find_lock_task_mm too
Message-Id: <20100608125533.086a4191.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061523360.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061523360.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:12 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> dump_task() should use find_lock_task_mm() too. It is necessary for
> protecting task-exiting race.

A full description of the race would help people understand the code
and the change.

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |   39 +++++++++++++++++++++------------------
>  1 files changed, 21 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -336,35 +336,38 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>   */
>  static void dump_tasks(const struct mem_cgroup *mem)

The comment over this function needs to be updated to describe the role
of incoming argument `mem'.

>  {
> -	struct task_struct *g, *p;
> +	struct task_struct *p;
> +	struct task_struct *task;
>  
>  	printk(KERN_INFO "[ pid ]   uid  tgid total_vm      rss cpu oom_adj "
>  	       "name\n");
> -	do_each_thread(g, p) {
> -		struct mm_struct *mm;
> -
> -		if (mem && !task_in_mem_cgroup(p, mem))
> +	for_each_process(p) {

The switch from do_each_thread() to for_each_process() is
unchangelogged.  It looks like a little cleanup to me.

> +		/*
> +		 * We don't have is_global_init() check here, because the old
> +		 * code do that. printing init process is not big matter. But
> +		 * we don't hope to make unnecessary compatibility breaking.
> +		 */

When merging others' patches, please do review and if necessary fix or
enhance the comments and the changelog.  I don't think people take
offense.


Also, I don't think it's really valuable to document *changes* within
the code comments.  This comment is referring to what the old code did
versus the new code.  Generally it's best to just document the code as
it presently stands and leave the documentation of the delta to the
changelog.

That's not always true, of course - we should document oddball code
which is left there for userspace-visible back-compatibility reasons.


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
> +		if (!task) {
>  			/*
> -			 * total_vm and rss sizes do not exist for tasks with no
> -			 * mm so there's no need to report them; they can't be
> -			 * oom killed anyway.
> +			 * Probably oom vs task-exiting race was happen and ->mm
> +			 * have been detached. thus there's no need to report
> +			 * them; they can't be oom killed anyway.
>  			 */

OK, that hinted at the race but still didn't really tell readers what it is.

> -			task_unlock(p);
>  			continue;
>  		}
> +
>  		printk(KERN_INFO "[%5d] %5d %5d %8lu %8lu %3d     %3d %s\n",
> -		       p->pid, __task_cred(p)->uid, p->tgid, mm->total_vm,
> -		       get_mm_rss(mm), (int)task_cpu(p), p->signal->oom_adj,
> -		       p->comm);
> -		task_unlock(p);
> -	} while_each_thread(g, p);
> +		       task->pid, __task_cred(task)->uid, task->tgid,
> +		       task->mm->total_vm, get_mm_rss(task->mm),
> +		       (int)task_cpu(task), task->signal->oom_adj, p->comm);

No need to cast the task_cpu() return value - just use %u.

> +		task_unlock(task);
> +	}
>  }
>  
>  static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
