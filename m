Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id D86C46B006C
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 07:47:21 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so12108428wiv.11
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 04:47:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cl6si1206738wjb.49.2014.12.16.04.47.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Dec 2014 04:47:20 -0800 (PST)
Date: Tue, 16 Dec 2014 13:47:14 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141216124714.GF22914@dhcp22.suse.cz>
References: <201412122254.AJJ57896.OLFOOJQHSMtFVF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412122254.AJJ57896.OLFOOJQHSMtFVF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Fri 12-12-14 22:54:53, Tetsuo Handa wrote:
> >From 29d0b34a1c60e91ace8e1208a415ca371e6851fe Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Fri, 12 Dec 2014 21:29:06 +0900
> Subject: [PATCH] oom: Don't count on mm-less current process.
> 
> out_of_memory() doesn't trigger OOM killer if the current task is already
> exiting or it has fatal signals pending, and gives the task access to
> memory reserves instead. This is done to prevent from livelocks described by
> commit 9ff4868e3051d912 ("mm, oom: allow exiting threads to have access to
> memory reserves") and commit 7b98c2e402eaa1f2 ("oom: give current access to
> memory reserves if it has been killed") as well as to prevent from unnecessary
> killing of other tasks, with heuristic that the current task would finish
> soon and release its resources.
> 
> However, this heuristic doesn't work as expected when out_of_memory() is
> triggered by an allocation after the current task has already released
> its memory in exit_mm() (e.g. from exit_task_work()) because it might
> livelock waiting for a memory which gets never released while there are
> other tasks sitting on a lot of memory.
> 
> Therefore, consider doing checks as with sysctl_oom_kill_allocating_task
> case before giving the current task access to memory reserves.

The most important part is to check whether the current has still its
address sapce. So please be explicit about that refering to a sysctl and
not mentioning what is the check is not helpful much. Besides that I do
not think oom_unkillable_task which you have added is really correct.
See below.

> Note that this patch cannot prevent somebody from calling oom_kill_process()
> with a victim task when the victim task already got PF_EXITING flag and
> released its memory. This means that the OOM killer is kept disabled for
> unpredictable duration when the victim task is unkillable due to dependency
> which is invisible to the OOM killer (e.g. waiting for lock held by somebody)
> after somebody set TIF_MEMDIE flag on the victim task by calling
> oom_kill_process(). What is unfortunate, a local unprivileged user can make
> the victim task unkillable on purpose. There are two approaches for mitigating
> this problem. Workaround is to use sysctl-tunable panic on TIF_MEMDIE timeout
> (Detect DoS attacks and react. Easy to backport. Works for memory depletion
> bugs caused by kernel code.) and preferred fix is to develop complete kernel
> memory allocation tracking (Try to avoid DoS but do nothing when failed to
> avoid. Hard to backport. Works for memory depletion attacks caused by user
> programs). Anyway that's beyond what this patch can do.

And I think the whole paragraph is not really relevant for the patch.

> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/oom.h |  3 +++
>  mm/memcontrol.c     |  8 +++++++-
>  mm/oom_kill.c       | 12 +++++++++---
>  3 files changed, 19 insertions(+), 4 deletions(-)
> 
[...]
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c6ac50e..6d9532d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1558,8 +1558,14 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>  	 * If current has a pending SIGKILL or is exiting, then automatically
>  	 * select it.  The goal is to allow it to allocate so that it may
>  	 * quickly exit and free its memory.
> +	 *
> +	 * However, if current is calling out_of_memory() by doing memory
> +	 * allocation from e.g. exit_task_work() in do_exit() after PF_EXITING
> +	 * was set by exit_signals() and mm was released by exit_mm(), it is
> +	 * wrong to expect current to exit and free its memory quickly.
>  	 */
> -	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
> +	if ((fatal_signal_pending(current) || current->flags & PF_EXITING) &&
> +	    current->mm && !oom_unkillable_task(current, memcg, NULL)) {
>  		set_thread_flag(TIF_MEMDIE);
>  		return;
>  	}

Why do you check oom_unkillable_task for memcg OOM killer?

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 481d550..01719d6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
[...]
> @@ -649,8 +649,14 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>  	 * If current has a pending SIGKILL or is exiting, then automatically
>  	 * select it.  The goal is to allow it to allocate so that it may
>  	 * quickly exit and free its memory.
> +	 *
> +	 * However, if current is calling out_of_memory() by doing memory
> +	 * allocation from e.g. exit_task_work() in do_exit() after PF_EXITING
> +	 * was set by exit_signals() and mm was released by exit_mm(), it is
> +	 * wrong to expect current to exit and free its memory quickly.
>  	 */
> -	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
> +	if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
> +	    current->mm && !oom_unkillable_task(current, NULL, nodemask)) {
>  		set_thread_flag(TIF_MEMDIE);
>  		return;
>  	}

Calling oom_unkillable_task doesn't make much sense to me. Even if it made
sense it should be in a separate patch, no?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
