Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id C1DDD828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 05:46:00 -0500 (EST)
Received: by mail-ob0-f175.google.com with SMTP id wb13so60574537obb.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 02:46:00 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q83si8530404oib.137.2016.02.18.02.45.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Feb 2016 02:46:00 -0800 (PST)
Subject: Re: [PATCH 6/6] mm,oom: wait for OOM victims when using oom_kill_allocating_task == 1
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201602171928.GDE00540.SLJMOFFQOHtFVO@I-love.SAKURA.ne.jp>
	<201602171936.JDC18598.JHOFtLVOQSFMOF@I-love.SAKURA.ne.jp>
	<20160217133242.GJ29196@dhcp22.suse.cz>
In-Reply-To: <20160217133242.GJ29196@dhcp22.suse.cz>
Message-Id: <201602181945.EDI35454.MVOHLQSOFFJOtF@I-love.SAKURA.ne.jp>
Date: Thu, 18 Feb 2016 19:45:45 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 17-02-16 19:36:36, Tetsuo Handa wrote:
> > From 0b36864d4100ecbdcaa2fc2d1927c9e270f1b629 Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Wed, 17 Feb 2016 16:37:59 +0900
> > Subject: [PATCH 6/6] mm,oom: wait for OOM victims when using oom_kill_allocating_task == 1
> >
> > Currently, out_of_memory() does not wait for existing TIF_MEMDIE threads
> > if /proc/sys/vm/oom_kill_allocating_task is set to 1. This can result in
> > killing more OOM victims than needed. We can wait for the OOM reaper to
> > reap memory used by existing TIF_MEMDIE threads if possible. If the OOM
> > reaper is not available, the system will be kept OOM stalled until an
> > OOM-unkillable thread does a GFP_FS allocation request and calls
> > oom_kill_allocating_task == 0 path.
> >
> > This patch changes oom_kill_allocating_task == 1 case to call
> > select_bad_process() in order to wait for existing TIF_MEMDIE threads.
>
> The primary motivation for oom_kill_allocating_task was to reduce the
> overhead of select_bad_process. See fe071d7e8aae ("oom: add
> oom_kill_allocating_task sysctl"). So this basically defeats the whole
> purpose of the feature.
>

I didn't know that. But I think that printk()ing all candidates much more
significantly degrades performance than scanning the tasklist. It would be
nice if setting /proc/sys/vm/oom_dump_tasks = N (N > 1) shows only top N
memory-hog processes.

> I am not user of this knob because it behaves absolutely randomly but
> IMHO we should simply do something like the following. It would be more
> compliant to the documentation and prevent from livelock which is
> currently possible (albeit very unlikely) when a single task consimes
> all the memory reserves and we keep looping over out_of_memory without
> any progress.
>
> But as I've said I have no idea whether somebody relies on the current
> behavior so this is more of a thinking loudly than proposing an actual
> patch at this point of time.

Maybe try warning messages for finding somebody using
oom_kill_allocating_task?

> ---
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 078e07ec0906..7de84fb2dd03 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -706,6 +706,9 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
>  		message, task_pid_nr(p), p->comm, points);
>
> +	if (sysctl_oom_kill_allocating_task)
> +		goto kill;
> +

We have

  "Out of memory (oom_kill_allocating_task)"
  "Out of memory"
  "Memory cgroup out of memory"

but we don't have

  "Memory cgroup out of memory (oom_kill_allocating_task)"

.

I don't know whether we should use this condition for memcg OOM case.

>  	/*
>  	 * If any of p's children has a different mm and is eligible for kill,
>  	 * the one with the highest oom_badness() score is sacrificed for its
> @@ -734,6 +737,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	}
>  	read_unlock(&tasklist_lock);
>
> +kill:
>  	p = find_lock_task_mm(victim);
>  	if (!p) {
>  		put_task_struct(victim);
> @@ -888,6 +892,9 @@ bool out_of_memory(struct oom_control *oc)
>  	if (sysctl_oom_kill_allocating_task && current->mm &&
>  	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
>  	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
> +		if (test_thread_flag(TIF_MEMDIE))
> +			panic("Out of memory (oom_kill_allocating_task) not able to make a forward progress");
> +

If current thread got TIF_MEMDIE, current thread will not call out_of_memory()
again because current thread will exit the allocation (unless __GFP_NOFAIL)
due to use of ALLOC_NO_WATERMARKS.

This condition becomes true only when "some OOM-unkillable thread called
out_of_memory() and chose current as the OOM victim" && "current was
running between gfp_to_alloc_flags() in __alloc_pages_slowpath() and
!mutex_trylock(&oom_lock) in __alloc_pages_may_oom()" which is almost
impossibly triggerable. If we trigger this condition, I think it was
triggered by error by chance (rather than really unable to make a
forward progress).

>  		get_task_struct(current);
>  		oom_kill_process(oc, current, 0, totalpages, NULL,
>  				 "Out of memory (oom_kill_allocating_task)");

Anyway, we can forget about this [PATCH 6/6] for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
