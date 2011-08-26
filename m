Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C892D6B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 05:21:50 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p7Q9LmI8019575
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 02:21:48 -0700
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by hpaq7.eem.corp.google.com with ESMTP id p7Q9LjRC001235
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 02:21:46 -0700
Received: by pzk6 with SMTP id 6so4714259pzk.22
        for <linux-mm@kvack.org>; Fri, 26 Aug 2011 02:21:45 -0700 (PDT)
Date: Fri, 26 Aug 2011 02:21:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: skip frozen tasks
In-Reply-To: <20110826085610.GA9083@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1108260218050.14732@chino.kir.corp.google.com>
References: <20110823073101.6426.77745.stgit@zurg> <alpine.DEB.2.00.1108231313520.21637@chino.kir.corp.google.com> <20110824101927.GB3505@tiehlicka.suse.cz> <alpine.DEB.2.00.1108241226550.31357@chino.kir.corp.google.com> <20110825091920.GA22564@tiehlicka.suse.cz>
 <20110825151818.GA4003@redhat.com> <20110825164758.GB22564@tiehlicka.suse.cz> <alpine.DEB.2.00.1108251404130.18747@chino.kir.corp.google.com> <20110826070946.GA7280@tiehlicka.suse.cz> <20110826085610.GA9083@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, 26 Aug 2011, Michal Hocko wrote:

> Let's give all frozen tasks a bonus (OOM_SCORE_ADJ_MAX/2) so that we do
> not consider them unless really necessary and if we really pick up one
> then thaw its threads before we try to kill it.
> 

I don't like arbitrary heuristics like this because they polluted the old 
oom killer before it was rewritten and made it much more unpredictable.  
The only heuristic it includes right now is a bonus for root tasks so that 
when two processes have nearly the same amount of memory usage (within 3% 
of available memory), the non-root task is chosen instead.

This bonus is actually saying that a single frozen task can use up to 50% 
more of the machine's capacity in a system-wide oom condition than the 
task that will now be killed instead.  That seems excessive.

I do like the idea of automatically thawing the task though and if that's 
possible then I don't think we need to manipulate the badness heuristic at 
all.  I know that wouldn't be feasible when we've frozen _all_ threads and 
that's why we have oom_killer_disable(), but we'll have to check with 
Rafael to see if something like this could work.  Rafael?

> TODO
> - given bonus might be too big?
> - aren't we racing with try_to_freeze_tasks?
> ---
>  mm/oom_kill.c |   13 +++++++++++++
>  1 files changed, 13 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 626303b..fd194bc 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -32,6 +32,7 @@
>  #include <linux/mempolicy.h>
>  #include <linux/security.h>
>  #include <linux/ptrace.h>
> +#include <linux/freezer.h>
>  
>  int sysctl_panic_on_oom;
>  int sysctl_oom_kill_allocating_task;
> @@ -214,6 +215,14 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  	points += p->signal->oom_score_adj;
>  
>  	/*
> +	 * Do not try to kill frozen tasks unless there is nothing else to kill.
> +	 * We do not want to give it 1 point because we still want to select a good
> +	 * candidate among all frozen tasks. Let's give it a reasonable bonus.
> +	 */
> +	if (frozen(p))
> +		points -= OOM_SCORE_ADJ_MAX/2;
> +
> +	/*
>  	 * Never return 0 for an eligible task that may be killed since it's
>  	 * possible that no single user task uses more than 0.1% of memory and
>  	 * no single admin tasks uses more than 3.0%.
> @@ -450,6 +459,10 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
>  			pr_err("Kill process %d (%s) sharing same memory\n",
>  				task_pid_nr(q), q->comm);
>  			task_unlock(q);
> +
> +			if (frozen(q))
> +				thaw_process(q);
> +
>  			force_sig(SIGKILL, q);
>  		}
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
