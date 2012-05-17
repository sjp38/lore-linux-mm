Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 173D16B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 17:50:24 -0400 (EDT)
Date: Thu, 17 May 2012 14:50:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, oom: normalize oom scores to oom_score_adj scale
 only for userspace
Message-Id: <20120517145022.a99f41e8.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1205171432250.6951@chino.kir.corp.google.com>
References: <20120426193551.GA24968@redhat.com>
	<alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1205031513400.1631@chino.kir.corp.google.com>
	<20120503222949.GA13762@redhat.com>
	<alpine.DEB.2.00.1205171432250.6951@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 17 May 2012 14:33:27 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> The oom_score_adj scale ranges from -1000 to 1000 and represents the
> proportion of memory available to the process at allocation time.  This
> means an oom_score_adj value of 300, for example, will bias a process as
> though it was using an extra 30.0% of available memory and a value of
> -350 will discount 35.0% of available memory from its usage.
> 
> The oom killer badness heuristic also uses this scale to report the oom
> score for each eligible process in determining the "best" process to
> kill.  Thus, it can only differentiate each process's memory usage by
> 0.1% of system RAM.
> 
> On large systems, this can end up being a large amount of memory: 256MB
> on 256GB systems, for example.
> 
> This can be fixed by having the badness heuristic to use the actual
> memory usage in scoring threads and then normalizing it to the
> oom_score_adj scale for userspace.  This results in better comparison
> between eligible threads for kill and no change from the userspace
> perspective.
> 
> ...
>
> @@ -198,45 +198,33 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	}
>  
>  	/*
> -	 * The memory controller may have a limit of 0 bytes, so avoid a divide
> -	 * by zero, if necessary.
> -	 */
> -	if (!totalpages)
> -		totalpages = 1;
> -
> -	/*
>  	 * The baseline for the badness score is the proportion of RAM that each
>  	 * task's rss, pagetable and swap space use.
>  	 */
> -	points = get_mm_rss(p->mm) + p->mm->nr_ptes;
> -	points += get_mm_counter(p->mm, MM_SWAPENTS);
> -
> -	points *= 1000;
> -	points /= totalpages;
> +	points = get_mm_rss(p->mm) + p->mm->nr_ptes +
> +		 get_mm_counter(p->mm, MM_SWAPENTS);
>  	task_unlock(p);
>  
>  	/*
>  	 * Root processes get 3% bonus, just like the __vm_enough_memory()
>  	 * implementation used by LSMs.
>  	 */
> -	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> -		points -= 30;
> +	if (has_capability_noaudit(p, CAP_SYS_ADMIN) && totalpages)

There doesn't seem much point in testing totalpages here - it's a
micro-optimisation which adds a branch, on a slow path.

> +		points -= 30 * totalpages / 1000;
>  
>  	/*
>  	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
>  	 * either completely disable oom killing or always prefer a certain
>  	 * task.
>  	 */
> -	points += p->signal->oom_score_adj;
> +	points += p->signal->oom_score_adj * totalpages / 1000;

And if we *do* want to add that micro-optimisation, we may as well
extend it to cover this expression also:

	if (totalpages) {	/* reason goes here */
		if (has_capability_noaudit(...))
			points -= 30 * totalpages / 1000;
		p->signal->oom_score_adj * totalpages / 1000;
	}

>  	/*
>  	 * Never return 0 for an eligible task that may be killed since it's
>  	 * possible that no single user task uses more than 0.1% of memory and
>  	 * no single admin tasks uses more than 3.0%.
>  	 */
> -	if (points <= 0)
> -		return 1;
> -	return (points < 1000) ? points : 1000;
> +	return points <= 0 ? 1 : points;

`points' is unsigned - testing it for negative looks odd.

>  }
>  
>  /*
> @@ -314,7 +302,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  {
>  	struct task_struct *g, *p;
>  	struct task_struct *chosen = NULL;
> -	*ppoints = 0;
> +	unsigned long chosen_points = 0;
>  
>  	do_each_thread(g, p) {
>  		unsigned int points;
> @@ -354,7 +342,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  			 */
>  			if (p == current) {
>  				chosen = p;
> -				*ppoints = 1000;
> +				chosen_points = ULONG_MAX;
>  			} else if (!force_kill) {
>  				/*
>  				 * If this task is not being ptraced on exit,
> @@ -367,12 +355,13 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		}
>  
>  		points = oom_badness(p, memcg, nodemask, totalpages);
> -		if (points > *ppoints) {
> +		if (points > chosen_points) {
>  			chosen = p;
> -			*ppoints = points;
> +			chosen_points = points;
>  		}
>  	} while_each_thread(g, p);
>  
> +	*ppoints = chosen_points * 1000 / totalpages;

So it's up to the select_bad_process() callers to prevent the
divide-by-zero.  It is unobvious that they actually do this, and this
important and unobvious caller requirement is undocumented.

>  	return chosen;
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
