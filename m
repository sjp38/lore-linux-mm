Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6D7B06B04D4
	for <linux-mm@kvack.org>; Tue,  5 Sep 2017 09:34:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l19so4112231wmi.1
        for <linux-mm@kvack.org>; Tue, 05 Sep 2017 06:34:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si362186wmf.18.2017.09.05.06.34.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Sep 2017 06:34:44 -0700 (PDT)
Date: Tue, 5 Sep 2017 15:34:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v7 1/5] mm, oom: refactor the oom_kill_process() function
Message-ID: <20170905133440.ekcwesdltttieoi7@dhcp22.suse.cz>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170904142108.7165-2-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 04-09-17 15:21:04, Roman Gushchin wrote:
> The oom_kill_process() function consists of two logical parts:
> the first one is responsible for considering task's children as
> a potential victim and printing the debug information.
> The second half is responsible for sending SIGKILL to all
> tasks sharing the mm struct with the given victim.
> 
> This commit splits the oom_kill_process() function with
> an intention to re-use the the second half: __oom_kill_process().
> 
> The cgroup-aware OOM killer will kill multiple tasks
> belonging to the victim cgroup. We don't need to print
> the debug information for the each task, as well as play
> with task selection (considering task's children),
> so we can't use the existing oom_kill_process().
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: kernel-team@fb.com
> Cc: cgroups@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org

Looks good to me
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 123 +++++++++++++++++++++++++++++++---------------------------
>  1 file changed, 65 insertions(+), 58 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 99736e026712..f061b627092c 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -804,68 +804,12 @@ static bool task_will_free_mem(struct task_struct *task)
>  	return ret;
>  }
>  
> -static void oom_kill_process(struct oom_control *oc, const char *message)
> +static void __oom_kill_process(struct task_struct *victim)
>  {
> -	struct task_struct *p = oc->chosen;
> -	unsigned int points = oc->chosen_points;
> -	struct task_struct *victim = p;
> -	struct task_struct *child;
> -	struct task_struct *t;
> +	struct task_struct *p;
>  	struct mm_struct *mm;
> -	unsigned int victim_points = 0;
> -	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
> -					      DEFAULT_RATELIMIT_BURST);
>  	bool can_oom_reap = true;
>  
> -	/*
> -	 * If the task is already exiting, don't alarm the sysadmin or kill
> -	 * its children or threads, just give it access to memory reserves
> -	 * so it can die quickly
> -	 */
> -	task_lock(p);
> -	if (task_will_free_mem(p)) {
> -		mark_oom_victim(p);
> -		wake_oom_reaper(p);
> -		task_unlock(p);
> -		put_task_struct(p);
> -		return;
> -	}
> -	task_unlock(p);
> -
> -	if (__ratelimit(&oom_rs))
> -		dump_header(oc, p);
> -
> -	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
> -		message, task_pid_nr(p), p->comm, points);
> -
> -	/*
> -	 * If any of p's children has a different mm and is eligible for kill,
> -	 * the one with the highest oom_badness() score is sacrificed for its
> -	 * parent.  This attempts to lose the minimal amount of work done while
> -	 * still freeing memory.
> -	 */
> -	read_lock(&tasklist_lock);
> -	for_each_thread(p, t) {
> -		list_for_each_entry(child, &t->children, sibling) {
> -			unsigned int child_points;
> -
> -			if (process_shares_mm(child, p->mm))
> -				continue;
> -			/*
> -			 * oom_badness() returns 0 if the thread is unkillable
> -			 */
> -			child_points = oom_badness(child,
> -				oc->memcg, oc->nodemask, oc->totalpages);
> -			if (child_points > victim_points) {
> -				put_task_struct(victim);
> -				victim = child;
> -				victim_points = child_points;
> -				get_task_struct(victim);
> -			}
> -		}
> -	}
> -	read_unlock(&tasklist_lock);
> -
>  	p = find_lock_task_mm(victim);
>  	if (!p) {
>  		put_task_struct(victim);
> @@ -939,6 +883,69 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  }
>  #undef K
>  
> +static void oom_kill_process(struct oom_control *oc, const char *message)
> +{
> +	struct task_struct *p = oc->chosen;
> +	unsigned int points = oc->chosen_points;
> +	struct task_struct *victim = p;
> +	struct task_struct *child;
> +	struct task_struct *t;
> +	unsigned int victim_points = 0;
> +	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
> +					      DEFAULT_RATELIMIT_BURST);
> +
> +	/*
> +	 * If the task is already exiting, don't alarm the sysadmin or kill
> +	 * its children or threads, just give it access to memory reserves
> +	 * so it can die quickly
> +	 */
> +	task_lock(p);
> +	if (task_will_free_mem(p)) {
> +		mark_oom_victim(p);
> +		wake_oom_reaper(p);
> +		task_unlock(p);
> +		put_task_struct(p);
> +		return;
> +	}
> +	task_unlock(p);
> +
> +	if (__ratelimit(&oom_rs))
> +		dump_header(oc, p);
> +
> +	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
> +		message, task_pid_nr(p), p->comm, points);
> +
> +	/*
> +	 * If any of p's children has a different mm and is eligible for kill,
> +	 * the one with the highest oom_badness() score is sacrificed for its
> +	 * parent.  This attempts to lose the minimal amount of work done while
> +	 * still freeing memory.
> +	 */
> +	read_lock(&tasklist_lock);
> +	for_each_thread(p, t) {
> +		list_for_each_entry(child, &t->children, sibling) {
> +			unsigned int child_points;
> +
> +			if (process_shares_mm(child, p->mm))
> +				continue;
> +			/*
> +			 * oom_badness() returns 0 if the thread is unkillable
> +			 */
> +			child_points = oom_badness(child,
> +				oc->memcg, oc->nodemask, oc->totalpages);
> +			if (child_points > victim_points) {
> +				put_task_struct(victim);
> +				victim = child;
> +				victim_points = child_points;
> +				get_task_struct(victim);
> +			}
> +		}
> +	}
> +	read_unlock(&tasklist_lock);
> +
> +	__oom_kill_process(victim);
> +}
> +
>  /*
>   * Determines whether the kernel must panic because of the panic_on_oom sysctl.
>   */
> -- 
> 2.13.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
