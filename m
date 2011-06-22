Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4D413900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 19:16:29 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p5MNGNvE005184
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:16:24 -0700
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by kpbe12.cbf.corp.google.com with ESMTP id p5MNGMT5016820
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:16:22 -0700
Received: by pvg3 with SMTP id 3so843995pvg.4
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 16:16:22 -0700 (PDT)
Date: Wed, 22 Jun 2011 16:16:19 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/6] oom: oom-killer don't use proportion of system-ram
 internally
In-Reply-To: <4E01C86D.30006@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1106221604230.11759@chino.kir.corp.google.com>
References: <4E01C7D5.3060603@jp.fujitsu.com> <4E01C86D.30006@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, caiqian@redhat.com, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Oleg Nesterov <oleg@redhat.com>

On Wed, 22 Jun 2011, KOSAKI Motohiro wrote:

> CAI Qian reported his kernel did hang-up if he ran fork intensive
> workload and then invoke oom-killer.
> 
> The problem is, current oom calculation uses 0-1000 normalized value
> (The unit is a permillage of system-ram). Its low precision make
> a lot of same oom score. IOW, in his case, all processes have smaller
> oom score than 1 and internal calculation round it to 1.
> 
> Thus oom-killer kill ineligible process. This regression is caused by
> commit a63d83f427 (oom: badness heuristic rewrite).
> 
> The solution is, the internal calculation just use number of pages
> instead of permillage of system-ram. And convert it to permillage
> value at displaying time.
> 

Ok, I agree this is better and I like that you've kept the userspace 
interfaces compatible.

> This patch doesn't change any ABI (included  /proc/<pid>/oom_score_adj)
> even though current logic has a lot of my dislike thing.
> 
> Reported-by: CAI Qian <caiqian@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  fs/proc/base.c      |   13 ++++++----
>  include/linux/oom.h |    2 +-
>  mm/oom_kill.c       |   60 ++++++++++++++++++++++++++++++--------------------
>  3 files changed, 45 insertions(+), 30 deletions(-)
> 
> diff --git a/fs/proc/base.c b/fs/proc/base.c
> index 14def99..4a10763 100644
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -479,14 +479,17 @@ static const struct file_operations proc_lstats_operations = {
> 
>  static int proc_oom_score(struct task_struct *task, char *buffer)
>  {
> -	unsigned long points = 0;
> +	unsigned long points;
> +	unsigned long ratio = 0;
> +	unsigned long totalpages = totalram_pages + total_swap_pages + 1;
> 
>  	read_lock(&tasklist_lock);
> -	if (pid_alive(task))
> -		points = oom_badness(task, NULL, NULL,
> -					totalram_pages + total_swap_pages);
> +	if (pid_alive(task)) {
> +		points = oom_badness(task, NULL, NULL, totalpages);
> +		ratio = points * 1000 / totalpages;
> +	}
>  	read_unlock(&tasklist_lock);
> -	return sprintf(buffer, "%lu\n", points);
> +	return sprintf(buffer, "%lu\n", ratio);
>  }
> 
>  struct limit_names {
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index 4952fb8..75b104c 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -42,7 +42,7 @@ enum oom_constraint {
> 
>  extern int test_set_oom_score_adj(int new_val);
> 
> -extern unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
> +extern unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  			const nodemask_t *nodemask, unsigned long totalpages);
>  extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
>  extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 797308b..cff8000 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -159,10 +159,11 @@ static bool oom_unkillable_task(struct task_struct *p,
>   * predictable as possible.  The goal is to return the highest value for the
>   * task consuming the most memory to avoid subsequent oom failures.
>   */
> -unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
> +unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  		      const nodemask_t *nodemask, unsigned long totalpages)
>  {
> -	int points;
> +	unsigned long points;
> +	unsigned long score_adj = 0;

Does this need to be initialized to 0?

> 
>  	if (oom_unkillable_task(p, mem, nodemask))
>  		return 0;

I was going to suggest changing the comment for oom_badness(), but then 
realized that it never stated that it returns a proportion in the first 
place!  I suggest, however, that you modify the comment to specify what 
the return value is: a value up to the point of totalpages that represents 
the amount of rss, swap, and ptes that the process is using.

> @@ -194,33 +195,44 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  	 */
>  	points = get_mm_rss(p->mm) + p->mm->nr_ptes;
>  	points += get_mm_counter(p->mm, MM_SWAPENTS);
> -
> -	points *= 1000;
> -	points /= totalpages;
>  	task_unlock(p);
> 
> -	/*
> -	 * Root processes get 3% bonus, just like the __vm_enough_memory()
> -	 * implementation used by LSMs.
> -	 */
> -	if (task_euid(p) == 0)
> -		points -= 30;
> +	/* Root processes get 3% bonus. */
> +	if (task_euid(p) == 0) {
> +		if (points >= totalpages / 32)
> +			points -= totalpages / 32;
> +		else
> +			points = 0;
> +	}
> 
>  	/*
>  	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
>  	 * either completely disable oom killing or always prefer a certain
>  	 * task.
>  	 */
> -	points += p->signal->oom_score_adj;
> +	if (p->signal->oom_score_adj >= 0) {
> +		score_adj = p->signal->oom_score_adj * (totalpages / 1000);
> +		if (ULONG_MAX - points >= score_adj)
> +			points += score_adj;
> +		else
> +			points = ULONG_MAX;

Does points = max(points + score_adj, ULONG_MAX) work here?

> +	} else {
> +		score_adj = -p->signal->oom_score_adj * (totalpages / 1000);
> +		if (points >= score_adj)
> +			points -= score_adj;
> +		else
> +			points = 0;
> +	}
> 

points = min(points - score_adj, 0)?

>  	/*
>  	 * Never return 0 for an eligible task that may be killed since it's
>  	 * possible that no single user task uses more than 0.1% of memory and
>  	 * no single admin tasks uses more than 3.0%.
>  	 */
> -	if (points <= 0)
> -		return 1;
> -	return (points < 1000) ? points : 1000;
> +	if (!points)
> +		points = 1;
> +

Comment needs to be updated to say that an eligible task gets at least a 
charge of 1 page instead of 0.1% of memory.

Everything else looks good, thanks for looking at this KOSAKI!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
