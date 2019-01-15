Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8CA78E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 06:56:00 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id b3so1046774edi.0
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 03:56:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m7si423368edl.414.2019.01.15.03.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 03:55:59 -0800 (PST)
Date: Tue, 15 Jan 2019 12:55:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] memcg: killed threads should not invoke memcg OOM
 killer
Message-ID: <20190115115557.GQ21345@dhcp22.suse.cz>
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <f6d97ad3-ab04-f5e2-4822-96eac6ab45da@i-love.sakura.ne.jp>
 <20190107114139.GF31793@dhcp22.suse.cz>
 <b0c4748e-f024-4d5c-a233-63c269660004@i-love.sakura.ne.jp>
 <20190107133720.GH31793@dhcp22.suse.cz>
 <935ae77c-9663-c3a4-c73a-fa69f9a3065f@i-love.sakura.ne.jp>
 <01370f70-e1f6-ebe4-b95e-0df21a0bc15e@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01370f70-e1f6-ebe4-b95e-0df21a0bc15e@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 15-01-19 19:17:27, Tetsuo Handa wrote:
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> 
> If $N > $M, a single process with $N threads in a memcg group can easily
> kill all $M processes in that memcg group, for mem_cgroup_out_of_memory()
> does not check if current thread needs to invoke the memcg OOM killer.
> 
>   T1@P1     |T2...$N@P1|P2...$M   |OOM reaper
>   ----------+----------+----------+----------
>                         # all sleeping
>   try_charge()
>     mem_cgroup_out_of_memory()
>       mutex_lock(oom_lock)
>              try_charge()
>                mem_cgroup_out_of_memory()
>                  mutex_lock(oom_lock)
>       out_of_memory()
>         select_bad_process()
>         oom_kill_process(P1)
>         wake_oom_reaper()
>                                    oom_reap_task() # ignores P1
>       mutex_unlock(oom_lock)
>                  out_of_memory()
>                    select_bad_process(P2...$M)
>                         # all killed by T2...$N@P1
>                    wake_oom_reaper()
>                                    oom_reap_task() # ignores P2...$M
>                  mutex_unlock(oom_lock)
> 
> We don't need to invoke the memcg OOM killer if current thread was killed
> when waiting for oom_lock, for mem_cgroup_oom_synchronize(true) can count
> on try_charge() when mem_cgroup_oom_synchronize(true) can not make forward
> progress because try_charge() allows already killed/exiting threads to
> make forward progress, and memory_max_write() can bail out upon signals.
> 
> At first Michal thought that fatal signal check is racy compared to
> tsk_is_oom_victim() check. But an experiment showed that trying to call
> mark_oom_victim() on all killed thread groups is more racy than fatal
> signal check due to task_will_free_mem(current) path in out_of_memory().
> 
> Therefore, this patch changes mem_cgroup_out_of_memory() to bail out upon
> should_force_charge() == T rather than upon fatal_signal_pending() == T,
> for should_force_charge() == T && signal_pending(current) == F at
> memory_max_write() can't happen because current thread won't call
> memory_max_write() after getting PF_EXITING.

The changelog is too cryptic IMHO. Can we make it something as simple as
"
If a memory cgroup contains a single process with many threads
(including different process group sharing the mm) then it is possible
to trigger a race when the oom killer complains that there are no oom
elible tasks and complain into the log which is both annoying and
confusing because there is no actual problem. The race looks as follows:

P1				oom_reaper		P2
try_charge						try_charge
  mem_cgroup_out_of_memory
    mutex_lock(oom_lock)
      out_of_memory
        oom_kill_process(P1,P2)
         wake_oom_reaper
    mutex_unlock(oom_lock)
    				oom_reap_task
							  mutex_lock(oom_lock)
							    select_bad_process # no victim


The problem is more visible with many threads.

Fix this by checking for fatal_signal_pending from mem_cgroup_out_of_memory
when the oom_lock is already held.

The oom bypass is safe because we do the same early in the try_charge
path already. The situation migh have changed in the mean time. It
should be safe to check for fatal_signal_pending and tsk_is_oom_victim
but for a better code readability abstract the current charge bypass
condition into should_force_charge and reuse it from that path.
"

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Anyway, to the change
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 19 ++++++++++++++-----
>  1 file changed, 14 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index af7f18b..79a7d2a 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -248,6 +248,12 @@ enum res_type {
>  	     iter != NULL;				\
>  	     iter = mem_cgroup_iter(NULL, iter, NULL))
>  
> +static inline bool should_force_charge(void)
> +{
> +	return tsk_is_oom_victim(current) || fatal_signal_pending(current) ||
> +		(current->flags & PF_EXITING);
> +}
> +
>  /* Some nice accessors for the vmpressure. */
>  struct vmpressure *memcg_to_vmpressure(struct mem_cgroup *memcg)
>  {
> @@ -1389,8 +1395,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	};
>  	bool ret;
>  
> -	mutex_lock(&oom_lock);
> -	ret = out_of_memory(&oc);
> +	if (mutex_lock_killable(&oom_lock))
> +		return true;
> +	/*
> +	 * A few threads which were not waiting at mutex_lock_killable() can
> +	 * fail to bail out. Therefore, check again after holding oom_lock.
> +	 */
> +	ret = should_force_charge() || out_of_memory(&oc);
>  	mutex_unlock(&oom_lock);
>  	return ret;
>  }
> @@ -2209,9 +2220,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	 * bypass the last charges so that they can exit quickly and
>  	 * free their memory.
>  	 */
> -	if (unlikely(tsk_is_oom_victim(current) ||
> -		     fatal_signal_pending(current) ||
> -		     current->flags & PF_EXITING))
> +	if (unlikely(should_force_charge()))
>  		goto force;
>  
>  	/*
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs
