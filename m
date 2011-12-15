Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 410EB6B004D
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 10:59:30 -0500 (EST)
Date: Thu, 15 Dec 2011 16:59:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v2] oom, memcg: fix exclusion of memcg threads after they
 have detached their mm
Message-ID: <20111215155926.GA22819@tiehlicka.suse.cz>
References: <alpine.DEB.2.00.1112131659100.32369@chino.kir.corp.google.com>
 <20111214102942.GA11786@tiehlicka.suse.cz>
 <alpine.DEB.2.00.1112141838470.27595@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1112141838470.27595@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed 14-12-11 18:39:40, David Rientjes wrote:
> oom, memcg: fix exclusion of memcg threads after they have detached their mm
> 
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
> memcg or its hierarchy that is currently oom.  This will allow the oom
> killer to appropriately defer rather than kill unnecessarily or, in the
> worst case, panic the machine if nothing else is available to kill.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/memcontrol.c |   17 +++++++++++++----
>  1 files changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1109,10 +1109,19 @@ int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg)
>  	struct task_struct *p;
>  
>  	p = find_lock_task_mm(task);
> -	if (!p)
> -		return 0;
> -	curr = try_get_mem_cgroup_from_mm(p->mm);
> -	task_unlock(p);
> +	if (p) {
> +		curr = try_get_mem_cgroup_from_mm(p->mm);
> +		task_unlock(p);
> +	} else {
> +		/*
> +		 * All threads may have already detached their mm's, but the oom
> +		 * killer still needs to detect if they have already been oom
> +		 * killed to prevent needlessly killing additional tasks.
> +		 */
> +		curr = mem_cgroup_from_task(task);
> +		if (curr)
> +			css_get(&curr->css);

Sorry, but I forgot to mention that we need task_lock(task) around
css_get.

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
