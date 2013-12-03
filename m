Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7F3F36B0088
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 18:50:46 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so9197448yho.24
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:50:46 -0800 (PST)
Received: from mail-yh0-x22b.google.com (mail-yh0-x22b.google.com [2607:f8b0:4002:c01::22b])
        by mx.google.com with ESMTPS id z48si1013819yha.231.2013.12.03.15.50.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Dec 2013 15:50:44 -0800 (PST)
Received: by mail-yh0-f43.google.com with SMTP id a41so10251692yho.16
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:50:44 -0800 (PST)
Date: Tue, 3 Dec 2013 15:50:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131203120454.GA12758@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com>
References: <20131114032508.GL707@cmpxchg.org> <alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com> <alpine.DEB.2.02.1311141525440.30112@chino.kir.corp.google.com> <20131118154115.GA3556@cmpxchg.org> <20131118165110.GE32623@dhcp22.suse.cz>
 <20131122165100.GN3556@cmpxchg.org> <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com> <20131127163435.GA3556@cmpxchg.org> <20131202200221.GC5524@dhcp22.suse.cz> <20131202212500.GN22729@cmpxchg.org> <20131203120454.GA12758@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 3 Dec 2013, Michal Hocko wrote:

> OK, as it seems that the notification part is too controversial, how
> would you like the following? It reverts the notification part and still
> solves the fault on exit path. I will prepare the full patch with the
> changelog if this looks reasonable:

Um, no, that's not satisfactory because it obviously does the check after 
mem_cgroup_oom_notify().  There is absolutely no reason why userspace 
should be woken up when current simply needs access to memory reserves to 
exit.  You can already get such notification by memory thresholds at the 
memcg limit.

I'll repeat: Section 10 of Documentation/cgroups/memory.txt specifies what 
userspace should do when waking up; one of those options is not "check if 
the memcg is still actually oom in a short period of time once a charging 
task with a pending SIGKILL or in the exit path has been able to exit."  
Users of this interface typically also disable the memcg oom killer 
through the same file, it's ludicrous to put the responsibility on 
userspace to determine if the wakeup is actionable and requires it to 
intervene in one of the methods listed in section 10.

> ---
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 28c9221b74ea..f44fe7e65a98 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1783,6 +1783,16 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	unsigned int points = 0;
>  	struct task_struct *chosen = NULL;
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
>  	check_panic_on_oom(CONSTRAINT_MEMCG, gfp_mask, order, NULL);
>  	totalpages = mem_cgroup_get_limit(memcg) >> PAGE_SHIFT ? : 1;
>  	for_each_mem_cgroup_tree(iter, memcg) {
> @@ -2233,16 +2243,6 @@ bool mem_cgroup_oom_synchronize(bool handle)
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
> @@ -2266,6 +2266,13 @@ bool mem_cgroup_oom_synchronize(bool handle)
>  		schedule();
>  		mem_cgroup_unmark_under_oom(memcg);
>  		finish_wait(&memcg_oom_waitq, &owait.wait);
> +
> +		/* Userspace OOM handler cannot set TIF_MEMDIE to a target */
> +		if (memcg->oom_kill_disable) {
> +			if ((fatal_signal_pending(current) ||
> +						current->flags & PF_EXITING))
> +				set_thread_flag(TIF_MEMDIE);
> +		}
>  	}
>  
>  	if (locked) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
