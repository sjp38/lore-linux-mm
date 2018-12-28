Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37D1F8E0001
	for <linux-mm@kvack.org>; Fri, 28 Dec 2018 05:22:13 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id v74-v6so6868745lje.6
        for <linux-mm@kvack.org>; Fri, 28 Dec 2018 02:22:13 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id d6-v6si35772287ljg.177.2018.12.28.02.22.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Dec 2018 02:22:10 -0800 (PST)
Subject: Re: [PATCH] memcg: killed threads should not invoke memcg OOM killer
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <6a52dc15-3e0a-5469-3a68-c7922a52a2d3@virtuozzo.com>
Date: Fri, 28 Dec 2018 13:22:06 +0300
MIME-Version: 1.0
In-Reply-To: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>

Hi, Tetsuo,

On 26.12.2018 13:13, Tetsuo Handa wrote:
> It is possible that a single process group memcg easily swamps the log
> with no-eligible OOM victim messages after current thread was OOM-killed,
> due to race between the memcg charge and the OOM reaper [1].
> 
> Thread-1                 Thread-2                       OOM reaper
> try_charge()
>   mem_cgroup_out_of_memory()
>     mutex_lock(oom_lock)
>                         try_charge()
>                           mem_cgroup_out_of_memory()
>                             mutex_lock(oom_lock)
>     out_of_memory()
>       select_bad_process()
>       oom_kill_process(current)
>       wake_oom_reaper()
>                                                         oom_reap_task()
>                                                         # sets MMF_OOM_SKIP
>     mutex_unlock(oom_lock)
>                             out_of_memory()
>                               select_bad_process() # no task
>                             mutex_unlock(oom_lock)
> 
> We don't need to invoke the memcg OOM killer if current thread was killed
> when waiting for oom_lock, for mem_cgroup_oom_synchronize(true) and
> memory_max_write() can bail out upon SIGKILL, and try_charge() allows
> already killed/exiting threads to make forward progress.
> 
> Michal has a plan to use tsk_is_oom_victim() by calling mark_oom_victim()
> on all thread groups sharing victim's mm. But fatal_signal_pending() in
> this patch helps regardless of Michal's plan because it will avoid
> needlessly calling out_of_memory() when current thread is already
> terminating (e.g. got SIGINT after passing fatal_signal_pending() check
> in try_charge() and mutex_lock_killable() did not block).
> 
> [1] https://lkml.kernel.org/r/ea637f9a-5dd0-f927-d26d-d0b4fd8ccb6f@i-love.sakura.ne.jp
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/memcontrol.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index b860dd4f7..b0d3bf3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1389,8 +1389,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
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
> +	ret = fatal_signal_pending(current) || out_of_memory(&oc);

This fatal_signal_pending() check has a sense because of
it's possible, a killed task is waking up slowly, and it
returns from schedule(), when there are no more waiters
for a lock.

Why not make this approach generic, and add a check into
__mutex_lock_common() after schedule_preempt_disabled()
instead of this? This will handle all the places like
that at once.

(The only adding a check is not enough for __mutex_lock_common(),
 since mutex code will require to wake next waiter also. So,
 you will need a couple of changes in mutex code).

Kirill

>  	mutex_unlock(&oom_lock);
>  	return ret;
>  }
> 
