Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 847A36B0002
	for <linux-mm@kvack.org>; Fri, 29 Mar 2013 10:45:40 -0400 (EDT)
Date: Fri, 29 Mar 2013 15:45:37 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch] mm, memcg: give exiting processes access to memory
 reserves
Message-ID: <20130329144537.GG21227@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1303271821120.5005@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1303271821120.5005@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 27-03-13 18:22:10, David Rientjes wrote:
> A memcg may livelock when oom if the process that grabs the hierarchy's
> oom lock is never the first process with PF_EXITING set in the memcg's
> task iteration.
> 
> The oom killer, both global and memcg, will defer if it finds an eligible
> process that is in the process of exiting and it is not being ptraced.
> The idea is to allow it to exit without using memory reserves before
> needlessly killing another process.
> 
> This normally works fine except in the memcg case with a large number of
> threads attached to the oom memcg.  In this case, the memcg oom killer
> only gets called for the process that grabs the hierarchy's oom lock; all
> others end up blocked on the memcg's oom waitqueue.  Thus, if the process
> that grabs the hierarchy's oom lock is never the first PF_EXITING process
> in the memcg's task iteration, the oom killer is constantly deferred
> without anything making progress.
> 
> The fix is to give PF_EXITING processes access to memory reserves so that
> we've marked them as oom killed without any iteration.  This allows
> __mem_cgroup_try_charge() to succeed so that the process may exit.  This
> makes the memcg oom killer exemption for TIF_MEMDIE tasks, now
> immediately granted for processes with pending SIGKILLs and those in the
> exit path, to be equivalent to what is done for the global oom killer.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

AFAIU this has been introduced by 9ff4868e (mm, oom: allow exiting
threads to have access to memory reserves) so maybe we want to mark it
for stable (3.8).

Thanks

> ---
>  mm/memcontrol.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1686,11 +1686,11 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	struct task_struct *chosen = NULL;
>  
>  	/*
> -	 * If current has a pending SIGKILL, then automatically select it.  The
> -	 * goal is to allow it to allocate so that it may quickly exit and free
> -	 * its memory.
> +	 * If current has a pending SIGKILL or is exiting, then automatically
> +	 * select it.  The goal is to allow it to allocate so that it may
> +	 * quickly exit and free its memory.
>  	 */
> -	if (fatal_signal_pending(current)) {
> +	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
>  		set_thread_flag(TIF_MEMDIE);
>  		return;
>  	}

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
