Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 867F56B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 07:37:39 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c13so197053eek.16
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 04:37:38 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id s8si23442986eeh.248.2013.12.12.04.37.37
        for <linux-mm@kvack.org>;
        Thu, 12 Dec 2013 04:37:38 -0800 (PST)
Date: Thu, 12 Dec 2013 13:37:36 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131212123736.GE2630@dhcp22.suse.cz>
References: <20131204111318.GE8410@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com>
 <20131209124840.GC3597@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com>
 <20131210103827.GB20242@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com>
 <20131211095549.GA18741@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312111434200.7354@chino.kir.corp.google.com>
 <20131212103159.GB2630@dhcp22.suse.cz>
 <20131212121140.GD2630@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131212121140.GD2630@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Thu 12-12-13 13:11:40, Michal Hocko wrote:
> On Thu 12-12-13 11:31:59, Michal Hocko wrote:
> [...]
> > The semantic would be as simple as "notification is sent only when
> > an action is due". It will be still racy as nothing prevents a task
> > which is not under OOM to exit and release some memory but there is no
> > sensible way to address that. On the other hand such a semantic would be
> > sensible for oom_control listeners because they will know that an action
> > has to be or will be taken (the line was drawn).
> > 
> > Can we agree on this, Johannes? Or you see the line drawn when
> > mem_cgroup_oom_synchronize has been reached already no matter whether
> > the action is to be done or not?
> 
> Something like the following:

I forgot to mention that this patch assumes "memcg: Do not hang on OOM
when killed by userspace OOM"

> From 5d9c01e2814a7ade49db7945ad3890f4f138855e Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 12 Dec 2013 11:50:17 +0100
> Subject: [PATCH] memcg: notify userspace about OOM when and action is due
> 
> Userspace is currently notified about OOM condition after fails
> to reclaim any memory after MEM_CGROUP_RECLAIM_RETRIES rounds.
> This usually means that the memcg is really in troubles and an
> OOM action (either done by userspace or kernel) has to be taken.
> The kernel OOM killer however bails out and doesn't kill anything
> if it sees an already dying/exiting task in a good hope a memory
> will be released and OOM situation will be resolved.
> 
> Therefore it makes sense to notify userspace only after really all
> measures have been taken and an userspace action is required or
> the kernel kills a task.
> 
> This patch also removes fatal_signal_pending and PF_EXITING check from
> mem_cgroup_oom_synchronize because __mem_cgroup_try_charge already
> checks for both and bypasses charge so we cannot end up in the oom path.

Hmm, I have just noticed that oom_scan_process_thread aborts scanning
only if it sees PF_EXITING or TIF_MEMDIE. Why the same is not done for 
fatal_signal_pending tasks as well? Following the same logic as for the
current we should do that no?

The different sets of checks is so confusing :/

> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> ---
>  mm/memcontrol.c | 17 ++++-------------
>  mm/oom_kill.c   |  5 +++++
>  2 files changed, 9 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 98900c070045..af7148c77bac 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2235,16 +2235,6 @@ bool mem_cgroup_oom_synchronize(bool handle)
>  	if (!handle)
>  		goto cleanup;
>  
> -	/*
> -	 * If current has a pending SIGKILL or is exiting, then automatically
> -	 * select it.  The goal is to allow it to allocate so that it may
> -	 * quickly exit and free its memory.
> -	 */
> -	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
> -		set_thread_flag(TIF_MEMDIE);
> -		goto cleanup;
> -	}
> -
>  	owait.memcg = memcg;
>  	owait.wait.flags = 0;
>  	owait.wait.func = memcg_oom_wake_function;
> @@ -2256,15 +2246,16 @@ bool mem_cgroup_oom_synchronize(bool handle)
>  
>  	locked = mem_cgroup_oom_trylock(memcg);
>  
> -	if (locked)
> -		mem_cgroup_oom_notify(memcg);
> -
>  	if (locked && !memcg->oom_kill_disable) {
>  		mem_cgroup_unmark_under_oom(memcg);
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
> +		/* calls mem_cgroup_oom_notify if there is a task to kill */
>  		mem_cgroup_out_of_memory(memcg, current->memcg_oom.gfp_mask,
>  					 current->memcg_oom.order);
>  	} else {
> +		if (locked && memcg->oom_kill_disable)
> +			mem_cgroup_oom_notify(memcg);
> +
>  		schedule();
>  		mem_cgroup_unmark_under_oom(memcg);
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1e4a600a6163..47c9de8da36d 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -394,6 +394,8 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>  		dump_tasks(memcg, nodemask);
>  }
>  
> +extern void mem_cgroup_oom_notify(struct mem_cgroup *memcg);
> +
>  #define K(x) ((x) << (PAGE_SHIFT-10))
>  /*
>   * Must be called while holding a reference to p, which will be released upon
> @@ -470,6 +472,9 @@ void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  		victim = p;
>  	}
>  
> +	if (memcg)
> +		mem_cgroup_oom_notify(memcg);
> +
>  	/* mm cannot safely be dereferenced after task_unlock(victim) */
>  	mm = victim->mm;
>  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> -- 
> 1.8.4.4
> 
> -- 
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
