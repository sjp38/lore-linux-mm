Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id F01C5900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 18:35:48 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p3FMZipn003645
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 15:35:44 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by kpbe13.cbf.corp.google.com with ESMTP id p3FMZBsc010594
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 15:35:43 -0700
Received: by pzk9 with SMTP id 9so1717531pzk.33
        for <linux-mm@kvack.org>; Fri, 15 Apr 2011 15:35:38 -0700 (PDT)
Date: Fri, 15 Apr 2011 15:35:39 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [patch v3] oom: replace PF_OOM_ORIGIN with toggling
 oom_score_adj
In-Reply-To: <alpine.DEB.2.00.1104141316450.20747@chino.kir.corp.google.com>
Message-ID: <alpine.LSU.2.00.1104151528050.4774@sister.anvils>
References: <alpine.DEB.2.00.1104131132240.5563@chino.kir.corp.google.com> <20110414090310.07FF.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1104131740280.16515@chino.kir.corp.google.com> <alpine.DEB.2.00.1104141316450.20747@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matt Fleming <matt@console-pimps.org>, linux-mm@kvack.org

On Thu, 14 Apr 2011, David Rientjes wrote:

> There's a kernel-wide shortage of per-process flags, so it's always 
> helpful to trim one when possible without incurring a significant 
> penalty.  It's even more important when you're planning on adding a per-
> process flag yourself, which I plan to do shortly for transparent 
> hugepages.
> 
> PF_OOM_ORIGIN is used by ksm and swapoff to prefer current since it has a 
> tendency to allocate large amounts of memory and should be preferred for 
> killing over other tasks.  We'd rather immediately kill the task making 
> the errant syscall rather than penalizing an innocent task.
> 
> This patch removes PF_OOM_ORIGIN since its behavior is equivalent to 
> setting the process's oom_score_adj to OOM_SCORE_ADJ_MAX.
> 
> The process's old oom_score_adj is stored and then set to 
> OOM_SCORE_ADJ_MAX during the time it used to have PF_OOM_ORIGIN.  The old 
> value is then reinstated when the process should no longer be considered 
> a high priority for oom killing.
> 
> Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Sorry, I'm trailing along way behind as usual.

This makes good sense (now you're using MAX instead of MIN!),
but may I helatedly ask you to change the name test_set_oom_score_adj()
to replace_oom_score_adj()?  test_set means a bitflag operation to me.

Otherwise,
Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  v3: add comment for test_set_oom_score_adj()
>      disable irqs when taking siglock, thanks to Matt Fleming
> 
>  include/linux/oom.h   |    2 ++
>  include/linux/sched.h |    1 -
>  mm/ksm.c              |    7 +++++--
>  mm/oom_kill.c         |   36 +++++++++++++++++++++++++++---------
>  mm/swapfile.c         |    6 ++++--
>  5 files changed, 38 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -40,6 +40,8 @@ enum oom_constraint {
>  	CONSTRAINT_MEMCG,
>  };
>  
> +extern int test_set_oom_score_adj(int new_val);
> +
>  extern unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  			const nodemask_t *nodemask, unsigned long totalpages);
>  extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1738,7 +1738,6 @@ extern void thread_group_times(struct task_struct *p, cputime_t *ut, cputime_t *
>  #define PF_FROZEN	0x00010000	/* frozen for system suspend */
>  #define PF_FSTRANS	0x00020000	/* inside a filesystem transaction */
>  #define PF_KSWAPD	0x00040000	/* I am kswapd */
> -#define PF_OOM_ORIGIN	0x00080000	/* Allocating much memory to others */
>  #define PF_LESS_THROTTLE 0x00100000	/* Throttle me less: I clean memory */
>  #define PF_KTHREAD	0x00200000	/* I am a kernel thread */
>  #define PF_RANDOMIZE	0x00400000	/* randomize virtual address space */
> diff --git a/mm/ksm.c b/mm/ksm.c
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -35,6 +35,7 @@
>  #include <linux/ksm.h>
>  #include <linux/hash.h>
>  #include <linux/freezer.h>
> +#include <linux/oom.h>
>  
>  #include <asm/tlbflush.h>
>  #include "internal.h"
> @@ -1894,9 +1895,11 @@ static ssize_t run_store(struct kobject *kobj, struct kobj_attribute *attr,
>  	if (ksm_run != flags) {
>  		ksm_run = flags;
>  		if (flags & KSM_RUN_UNMERGE) {
> -			current->flags |= PF_OOM_ORIGIN;
> +			int oom_score_adj;
> +
> +			oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
>  			err = unmerge_and_remove_all_rmap_items();
> -			current->flags &= ~PF_OOM_ORIGIN;
> +			test_set_oom_score_adj(oom_score_adj);
>  			if (err) {
>  				ksm_run = KSM_RUN_STOP;
>  				count = err;
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -38,6 +38,33 @@ int sysctl_oom_kill_allocating_task;
>  int sysctl_oom_dump_tasks = 1;
>  static DEFINE_SPINLOCK(zone_scan_lock);
>  
> +/**
> + * test_set_oom_score_adj() - set current's oom_score_adj and return old value
> + * @new_val: new oom_score_adj value
> + *
> + * Sets the oom_score_adj value for current to @new_val with proper
> + * synchronization and returns the old value.  Usually used to temporarily
> + * set a value, save the old value in the caller, and then reinstate it later.
> + */
> +int test_set_oom_score_adj(int new_val)
> +{
> +	struct sighand_struct *sighand = current->sighand;
> +	int old_val;
> +
> +	spin_lock_irq(&sighand->siglock);
> +	old_val = current->signal->oom_score_adj;
> +	if (new_val != old_val) {
> +		if (new_val == OOM_SCORE_ADJ_MIN)
> +			atomic_inc(&current->mm->oom_disable_count);
> +		else if (old_val == OOM_SCORE_ADJ_MIN)
> +			atomic_dec(&current->mm->oom_disable_count);
> +		current->signal->oom_score_adj = new_val;
> +	}
> +	spin_unlock_irq(&sighand->siglock);
> +
> +	return old_val;
> +}
> +
>  #ifdef CONFIG_NUMA
>  /**
>   * has_intersects_mems_allowed() - check task eligiblity for kill
> @@ -173,15 +200,6 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  	}
>  
>  	/*
> -	 * When the PF_OOM_ORIGIN bit is set, it indicates the task should have
> -	 * priority for oom killing.
> -	 */
> -	if (p->flags & PF_OOM_ORIGIN) {
> -		task_unlock(p);
> -		return 1000;
> -	}
> -
> -	/*
>  	 * The memory controller may have a limit of 0 bytes, so avoid a divide
>  	 * by zero, if necessary.
>  	 */
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -31,6 +31,7 @@
>  #include <linux/syscalls.h>
>  #include <linux/memcontrol.h>
>  #include <linux/poll.h>
> +#include <linux/oom.h>
>  
>  #include <asm/pgtable.h>
>  #include <asm/tlbflush.h>
> @@ -1555,6 +1556,7 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	struct address_space *mapping;
>  	struct inode *inode;
>  	char *pathname;
> +	int oom_score_adj;
>  	int i, type, prev;
>  	int err;
>  
> @@ -1613,9 +1615,9 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  	p->flags &= ~SWP_WRITEOK;
>  	spin_unlock(&swap_lock);
>  
> -	current->flags |= PF_OOM_ORIGIN;
> +	oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
>  	err = try_to_unuse(type);
> -	current->flags &= ~PF_OOM_ORIGIN;
> +	test_set_oom_score_adj(oom_score_adj);
>  
>  	if (err) {
>  		/*
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
