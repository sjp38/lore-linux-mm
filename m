Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA9FA8E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 15:59:59 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 123so1745364itv.6
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 12:59:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id e12si4999750ioc.3.2019.01.07.12.59.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 12:59:58 -0800 (PST)
Subject: Re: [PATCH 2/2] memcg: do not report racy no-eligible OOM tasks
References: <20190107143802.16847-1-mhocko@kernel.org>
 <20190107143802.16847-3-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <fa8892d1-4a38-dccd-9597-923924aa0a66@i-love.sakura.ne.jp>
Date: Tue, 8 Jan 2019 05:59:49 +0900
MIME-Version: 1.0
In-Reply-To: <20190107143802.16847-3-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 2019/01/07 23:38, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Tetsuo has reported [1] that a single process group memcg might easily
> swamp the log with no-eligible oom victim reports due to race between
> the memcg charge and oom_reaper

This explanation is outdated. I reported that one memcg OOM killer can
kill all processes in that memcg. I expect the changelog to be updated.

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
> index af7f18b32389..90eb2e2093e7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1387,10 +1387,22 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  		.gfp_mask = gfp_mask,
>  		.order = order,
>  	};
> -	bool ret;
> +	bool ret = true;
>  
>  	mutex_lock(&oom_lock);

And because of "[PATCH 1/2] mm, oom: marks all killed tasks as oom
victims", mark_oom_victim() will be called on current thread even if
we used mutex_lock_killable(&oom_lock) here, like you said

  mutex_lock_killable would take care of exiting task already. I would
  then still prefer to check for mark_oom_victim because that is not racy
  with the exit path clearing signals. I can update my patch to use
  _killable lock variant if we are really going with the memcg specific
  fix.

. If current thread is not yet killed by the OOM killer but can terminate
without invoking the OOM killer, using mutex_lock_killable(&oom_lock) here
saves some processes. What is the race you are referring by "racy with the
exit path clearing signals" ?

> +
> +	/*
> +	 * multi-threaded tasks might race with oom_reaper and gain
> +	 * MMF_OOM_SKIP before reaching out_of_memory which can lead
> +	 * to out_of_memory failure if the task is the last one in
> +	 * memcg which would be a false possitive failure reported
> +	 */

Not only out_of_memory() failure. Current thread needlessly tries to
select next OOM victim. out_of_memory() failure is nothing but a result
of no eligible candidate case.

> +	if (tsk_is_oom_victim(current))
> +		goto unlock;
> +
>  	ret = out_of_memory(&oc);
> +
> +unlock:
>  	mutex_unlock(&oom_lock);
>  	return ret;
>  }
> 
