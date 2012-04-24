Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id AE32E6B0092
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 19:09:16 -0400 (EDT)
Received: by iajr24 with SMTP id r24so2309352iaj.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 16:09:16 -0700 (PDT)
Date: Tue, 24 Apr 2012 16:09:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: avoid checking set of allowed nodes twice when
 selecting a victim
In-Reply-To: <20120412140137.GA32729@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1204241605570.17792@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1204031633460.8112@chino.kir.corp.google.com> <20120412140137.GA32729@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, 12 Apr 2012, Michal Hocko wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 46bf2ed5..a9df008 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -171,23 +171,10 @@ static bool oom_unkillable_task(struct task_struct *p,
>  	return false;
>  }
>  
> -/**
> - * oom_badness - heuristic function to determine which candidate task to kill
> - * @p: task struct of which task we should calculate
> - * @totalpages: total present RAM allowed for page allocation
> - *
> - * The heuristic for determining which task to kill is made to be as simple and
> - * predictable as possible.  The goal is to return the highest value for the
> - * task consuming the most memory to avoid subsequent oom failures.
> - */
> -unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> +/* can be used only for tasks which are killable as per oom_unkillable_task */
> +static unsigned int __oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  		      const nodemask_t *nodemask, unsigned long totalpages)
>  {
> -	long points;
> -
> -	if (oom_unkillable_task(p, memcg, nodemask))
> -		return 0;
> -
>  	p = find_lock_task_mm(p);
>  	if (!p)
>  		return 0;
> @@ -239,6 +226,26 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	return (points < 1000) ? points : 1000;
>  }
>  
> +/**
> + * oom_badness - heuristic function to determine which candidate task to kill
> + * @p: task struct of which task we should calculate
> + * @totalpages: total present RAM allowed for page allocation
> + *
> + * The heuristic for determining which task to kill is made to be as simple and
> + * predictable as possible.  The goal is to return the highest value for the
> + * task consuming the most memory to avoid subsequent oom failures.
> + */
> +unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
> +		      const nodemask_t *nodemask, unsigned long totalpages)
> +{
> +	long points;
> +
> +	if (oom_unkillable_task(p, memcg, nodemask))
> +		return 0;
> +
> +	return __oom_badness(p, memcg, nodemask, totalpages);
> +}
> +
>  /*
>   * Determine the type of allocation constraint.
>   */
> @@ -366,7 +373,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  			}
>  		}
>  
> -		points = oom_badness(p, memcg, nodemask, totalpages);
> +		points = __oom_badness(p, memcg, nodemask, totalpages);
>  		if (points > *ppoints) {
>  			chosen = p;
>  			*ppoints = points;

No, the way I had it written is correct: the above unnecessarily checks 
for membership in a memcg or intersection with a set of allowable nodes 
for child threads in oom_kill_process().  With a lot of children and with 
a CONFIG_NODES_SHIFT significantly large (the prerequisite for this patch 
to make any difference), that's too costly to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
