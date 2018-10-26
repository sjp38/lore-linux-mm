Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BEE3B6B0318
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 10:25:35 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f62-v6so1119483qtb.17
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 07:25:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor12779612qvj.63.2018.10.26.07.25.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Oct 2018 07:25:34 -0700 (PDT)
Date: Fri, 26 Oct 2018 10:25:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
Message-ID: <20181026142531.GA27370@cmpxchg.org>
References: <20181022071323.9550-1-mhocko@kernel.org>
 <20181022071323.9550-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022071323.9550-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, Oct 22, 2018 at 09:13:23AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo has reported [1] that a single process group memcg might easily
> swamp the log with no-eligible oom victim reports due to race between
> the memcg charge and oom_reaper
> 
> Thread 1		Thread2				oom_reaper
> try_charge		try_charge
> 			  mem_cgroup_out_of_memory
> 			    mutex_lock(oom_lock)
>   mem_cgroup_out_of_memory
>     mutex_lock(oom_lock)
> 			      out_of_memory
> 			        select_bad_process
> 				oom_kill_process(current)
> 				  wake_oom_reaper
> 							  oom_reap_task
> 							  MMF_OOM_SKIP->victim
> 			    mutex_unlock(oom_lock)
>     out_of_memory
>       select_bad_process # no task
> 
> If Thread1 didn't race it would bail out from try_charge and force the
> charge. We can achieve the same by checking tsk_is_oom_victim inside
> the oom_lock and therefore close the race.
> 
> [1] http://lkml.kernel.org/r/bb2074c0-34fe-8c2c-1c7d-db71338f1e7f@i-love.sakura.ne.jp
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memcontrol.c | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e79cb59552d9..a9dfed29967b 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1380,10 +1380,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  		.gfp_mask = gfp_mask,
>  		.order = order,
>  	};
> -	bool ret;
> +	bool ret = true;
>  
>  	mutex_lock(&oom_lock);
> +
> +	/*
> +	 * multi-threaded tasks might race with oom_reaper and gain
> +	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
> +	 * to out_of_memory failure if the task is the last one in
> +	 * memcg which would be a false possitive failure reported
> +	 */
> +	if (tsk_is_oom_victim(current))
> +		goto unlock;
> +
>  	ret = out_of_memory(&oc);

We already check tsk_is_oom_victim(current) in try_charge() before
looping on the OOM killer, so at most we'd have a single "no eligible
tasks" message from such a race before we force the charge - right?

While that's not perfect, I don't think it warrants complicating this
code even more. I honestly find it near-impossible to follow the code
and the possible scenarios at this point.

out_of_memory() bails on task_will_free_mem(current), which
specifically *excludes* already reaped tasks. Why are we then adding a
separate check before that to bail on already reaped victims?

Do we want to bail if current is a reaped victim or not?

I don't see how we could skip it safely in general: the current task
might have been killed and reaped and gotten access to the memory
reserve and still fail to allocate on its way out. It needs to kill
the next task if there is one, or warn if there isn't another
one. Because we're genuinely oom without reclaimable tasks.

There is of course the scenario brought forward in this thread, where
multiple threads of a process race and the second one enters oom even
though it doesn't need to anymore. What the global case does to catch
this is to grab the oom lock and do one last alloc attempt. Should
memcg lock the oom_lock and try one more time to charge the memcg?

Some simplification in this area would really be great. I'm reluctant
to ack patches like the above, even if they have some optical benefits
for the user, because the code is already too tricky for what it does.
