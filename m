Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B31EE6B0005
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:31:10 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id q8so43967287lfe.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 04:31:10 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ym9si26194381wjc.4.2016.04.14.04.31.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Apr 2016 04:31:09 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id n3so22008681wmn.1
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 04:31:09 -0700 (PDT)
Date: Thu, 14 Apr 2016 13:31:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: Clarify reason to kill other threads sharing the
 vitctim's memory.
Message-ID: <20160414113108.GE2850@dhcp22.suse.cz>
References: <1460631391-8628-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1460631391-8628-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1460631391-8628-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Thu 14-04-16 19:56:31, Tetsuo Handa wrote:
> Current comment for "Kill all user processes sharing victim->mm in other
> thread groups" is not clear that doing so is a best effort avoidance.
> 
> I tried to update that logic along with TIF_MEMDIE for several times
> but not yet accepted. Therefore, this patch changes only comment so that
> we can apply now.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  mm/oom_kill.c | 29 ++++++++++++++++++++++-------
>  1 file changed, 22 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index e78818d..43d0002 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -814,13 +814,28 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	task_unlock(victim);
>  
>  	/*
> -	 * Kill all user processes sharing victim->mm in other thread groups, if
> -	 * any.  They don't get access to memory reserves, though, to avoid
> -	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
           ^^^^^^^^^
this was an useful information which you have dropped. Why?

> -	 * oom killed thread cannot exit because it requires the semaphore and
> -	 * its contended by another thread trying to allocate memory itself.
> -	 * That thread will now get access to memory reserves since it has a
> -	 * pending fatal signal.
> +	 * Kill all user processes sharing victim->mm in other thread groups,
> +	 * if any. This reduces possibility of hitting mm->mmap_sem livelock
> +	 * when an OOM victim thread cannot exit because it requires the
> +	 * mm->mmap_sem for read at exit_mm() while another thread is trying
> +	 * to allocate memory with that mm->mmap_sem held for write.
> +	 *
> +	 * Any thread except the victim thread itself which is killed by
> +	 * this heuristic does not get access to memory reserves as of now,
> +	 * but it will get access to memory reserves by calling out_of_memory()
> +	 * or mem_cgroup_out_of_memory() since it has a pending fatal signal.
> +	 *
> +	 * Note that this heuristic is not perfect because it is possible that
> +	 * a thread which shares victim->mm and is doing memory allocation with
> +	 * victim->mm->mmap_sem held for write is marked as OOM_SCORE_ADJ_MIN.

Is this really helpful? I would rather be explicit that we _do not care_
about these configurations. It is just PITA maintain and it doesn't make
any sense. So rather than trying to document all the weird thing that
might happen I would welcome a warning "mm shared with OOM_SCORE_ADJ_MIN
task. Something is broken in your configuration!"

> +	 * Also, it is possible that a thread which shares victim->mm and is
> +	 * doing memory allocation with victim->mm->mmap_sem held for write
> +	 * (possibly the victim thread itself which got TIF_MEMDIE) is blocked
> +	 * at unkillable locks from direct reclaim paths because nothing
> +	 * prevents TIF_MEMDIE threads which already started direct reclaim
> +	 * paths from being blocked at unkillable locks. In such cases, the
> +	 * OOM reaper will be unable to reap victim->mm and we will need to
> +	 * select a different OOM victim.

This is a more general problem and not related to this particular code.
Whenever we select a victim and call mark_oom_victim we hope it will
eventually get out of its kernel code path (unless it was running in the
userspace) so I am not sure this is placed properly.

>  	 */
>  	rcu_read_lock();
>  	for_each_process(p) {
> -- 
> 1.8.3.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
