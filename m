Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 417276B02CC
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 05:29:45 -0500 (EST)
Date: Wed, 14 Dec 2011 11:29:42 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] oom, memcg: fix exclusion of memcg threads after they
 have detached their mm
Message-ID: <20111214102942.GA11786@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1112131659100.32369@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1112131659100.32369@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Tue 13-12-11 16:59:32, David Rientjes wrote:
> The oom killer relies on logic that identifies threads that have already
> been oom killed when scanning the tasklist and, if found, deferring until
> such threads have exited.  This is done by checking for any candidate
> threads that have the TIF_MEMDIE bit set.
> 
> For memcg ooms, candidate threads are first found by calling
> task_in_mem_cgroup() since the oom killer should not defer if there's an
> oom killed thread in another memcg.
> 
> Unfortunately, task_in_mem_cgroup() excludes threads if they have
> detached their mm in the process of exiting so TIF_MEMDIE is never
> detected for such conditions.  This is different for global, mempolicy,
> and cpuset oom conditions where a detached mm is only excluded after
> checking for TIF_MEMDIE and deferring, if necessary, in
> select_bad_process().
> 
> The fix is to return true if a task has a detached mm but is still in the
> memcg that is currently oom.  This will allow the oom killer to
> appropriately defer rather than kill unnecessarily or, in the worst case,
> panic the machine if nothing else is available to kill.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1110,7 +1110,7 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
>  
>  	p = find_lock_task_mm(task);
>  	if (!p)
> -		return 0;
> +		return mem_cgroup_from_task(task) == memcg;

We need mem_cgroup_same_or_subtree otherwise you will not catch a task
from hierarchy. What about something like:
	if (p) {
	        curr = try_get_mem_cgroup_from_mm(p->mm);
		task_unlock(p);
	}
	else {
		if ((curr = mem_cgroup_from_task(taska)))
			css_get(&curr->css)
	}

Other than that agreed.

>  	curr = try_get_mem_cgroup_from_mm(p->mm);
>  	task_unlock(p);
>  	if (!curr)
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
