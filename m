Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5C42E6B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 07:52:46 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id p10so6403916pdj.26
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 04:52:46 -0800 (PST)
Received: from psmtp.com ([74.125.245.134])
        by mx.google.com with SMTP id yg5si9589322pbc.206.2013.11.18.04.52.43
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 04:52:44 -0800 (PST)
Date: Mon, 18 Nov 2013 13:52:40 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
Message-ID: <20131118125240.GC32623@dhcp22.suse.cz>
References: <alpine.DEB.2.02.1310301838300.13556@chino.kir.corp.google.com>
 <20131031054942.GA26301@cmpxchg.org>
 <alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com>
 <20131113233419.GJ707@cmpxchg.org>
 <alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
 <20131114032508.GL707@cmpxchg.org>
 <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

[Adding Eric to CC]

On Thu 14-11-13 15:26:51, David Rientjes wrote:
> When current has a pending SIGKILL or is already in the exit path, it
> only needs access to memory reserves to fully exit.  In that sense, the
> memcg is not actually oom for current, it simply needs to bypass memory
> charges to exit and free its memory, which is guarantee itself that
> memory will be freed.
> 
> We only want to notify userspace for actionable oom conditions where
> something needs to be done (and all oom handling can already be deferred
> to userspace through this method by disabling the memcg oom killer with
> memory.oom_control), not simply when a memcg has reached its limit, which
> would actually have to happen before memcg reclaim actually frees memory
> for charges.

I believe this also fixes the issue reported by Eric
(https://lkml.org/lkml/2013/7/28/74). I had a patch for this
https://lkml.org/lkml/2013/7/31/94 but the code changed since then and
this should be equivalent.
 
> Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/memcontrol.c | 20 ++++++++++----------
>  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1783,16 +1783,6 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	unsigned int points = 0;
>  	struct task_struct *chosen = NULL;
>  
> -	/*
> -	 * If current has a pending SIGKILL or is exiting, then automatically
> -	 * select it.  The goal is to allow it to allocate so that it may
> -	 * quickly exit and free its memory.
> -	 */
> -	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
> -		set_thread_flag(TIF_MEMDIE);
> -		return;
> -	}
> -
>  	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
>  	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
>  	for_each_mem_cgroup_tree(iter, memcg) {
> @@ -2243,6 +2233,16 @@ bool mem_cgroup_oom_synchronize(bool handle)
>  	if (!handle)
>  		goto cleanup;
>  
> +	/*
> +	 * If current has a pending SIGKILL or is exiting, then automatically
> +	 * select it.  The goal is to allow it to allocate so that it may
> +	 * quickly exit and free its memory.
> +	 */
> +	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
> +		set_thread_flag(TIF_MEMDIE);
> +		goto cleanup;
> +	}
> +
>  	owait.memcg = memcg;
>  	owait.wait.flags = 0;
>  	owait.wait.func = memcg_oom_wake_function;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
