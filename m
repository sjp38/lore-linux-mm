Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4F96B0006
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 10:42:22 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id a70-v6so2385780qkb.16
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 07:42:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1-v6sor2127333qkd.138.2018.08.08.07.42.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Aug 2018 07:42:16 -0700 (PDT)
Date: Wed, 8 Aug 2018 10:45:15 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] memcg, oom: emit oom report when there is no
 eligible task
Message-ID: <20180808144515.GA9276@cmpxchg.org>
References: <20180808064414.GA27972@dhcp22.suse.cz>
 <20180808071301.12478-1-mhocko@kernel.org>
 <20180808071301.12478-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180808071301.12478-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Greg Thelen <gthelen@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, Aug 08, 2018 at 09:13:01AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Johannes had doubts that the current WARN in the memcg oom path
> when there is no eligible task is not all that useful because it doesn't
> really give any useful insight into the memcg state. My original
> intention was to make this lightweight but it is true that seeing
> a stack trace will likely be not sufficient when somebody gets back to
> us and report this warning.
> 
> Therefore replace the current warning by the full oom report which will
> give us not only the back trace of the offending path but also the full
> memcg state - memory counters and existing tasks.
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  include/linux/oom.h |  2 ++
>  mm/memcontrol.c     | 24 +++++++++++++-----------
>  mm/oom_kill.c       |  8 ++++----
>  3 files changed, 19 insertions(+), 15 deletions(-)
> 
> diff --git a/include/linux/oom.h b/include/linux/oom.h
> index a16a155a0d19..7424f9673cd1 100644
> --- a/include/linux/oom.h
> +++ b/include/linux/oom.h
> @@ -133,6 +133,8 @@ extern struct task_struct *find_lock_task_mm(struct task_struct *p);
>  
>  extern int oom_evaluate_task(struct task_struct *task, void *arg);
>  
> +extern void dump_oom_header(struct oom_control *oc, struct task_struct *victim);
> +
>  /* sysctls */
>  extern int sysctl_oom_dump_tasks;
>  extern int sysctl_oom_kill_allocating_task;
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c80e5b6a8e9f..3d7c90e6c235 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1390,6 +1390,19 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	mutex_lock(&oom_lock);
>  	ret = out_of_memory(&oc);
>  	mutex_unlock(&oom_lock);
> +
> +	/*
> +	 * under rare race the current task might have been selected while
> +	 * reaching mem_cgroup_out_of_memory and there is no other oom victim
> +	 * left. There is still no reason to warn because this task will
> +	 * die and release its bypassed charge eventually.

"rare race" is a bit vague. Can we describe the situation?

	/*
	 * We killed and reaped every task in the group, and still no
	 * luck with the charge. This is likely the result of a crazy
	 * configuration, let the user know.
	 *
	 * With one exception: current is the last task, it's already
	 * been killed and reaped, but that wasn't enough to satisfy
	 * the charge request under the configured limit. In that case
	 * let it bypass quietly and current exit.
	 */

And after spelling that out, I no longer think we want to skip the OOM
header in that situation. The first paragraph still applies: this is
probably a funny configuration, we're going to bypass the charge, let
the user know that we failed containment - to help THEM identify by
themselves what is likely an easy to fix problem.

> +	 */
> +	if (tsk_is_oom_victim(current))
> +		return ret;
> +
> +	pr_warn("Memory cgroup charge failed because of no reclaimable memory! "
> +		"This looks like a misconfiguration or a kernel bug.");
> +	dump_oom_header(&oc, NULL);

All other sites print the context first before printing the
conclusion, we should probably do the same here.

I'd also prefer keeping the message in line with the global case when
no eligible tasks are left. There is no need to speculate whose fault
this could be, that's apparent from the OOM header. If the user can't
figure it out from the OOM header, they'll still report it to us.

How about this?

---
