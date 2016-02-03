Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 12F1D82963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 18:48:21 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id n128so22728608pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:48:21 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id wk6si12248923pac.91.2016.02.03.15.48.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 15:48:20 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id 65so22920950pfd.2
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:48:20 -0800 (PST)
Date: Wed, 3 Feb 2016 15:48:18 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] mm, oom: introduce oom reaper
In-Reply-To: <1454505240-23446-2-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1602031543250.10331@chino.kir.corp.google.com>
References: <1454505240-23446-1-git-send-email-mhocko@kernel.org> <1454505240-23446-2-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Wed, 3 Feb 2016, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> This is based on the idea from Mel Gorman discussed during LSFMM 2015 and
> independently brought up by Oleg Nesterov.
> 
> The OOM killer currently allows to kill only a single task in a good
> hope that the task will terminate in a reasonable time and frees up its
> memory.  Such a task (oom victim) will get an access to memory reserves
> via mark_oom_victim to allow a forward progress should there be a need
> for additional memory during exit path.
> 
> It has been shown (e.g. by Tetsuo Handa) that it is not that hard to
> construct workloads which break the core assumption mentioned above and
> the OOM victim might take unbounded amount of time to exit because it
> might be blocked in the uninterruptible state waiting for an event
> (e.g. lock) which is blocked by another task looping in the page
> allocator.
> 
> This patch reduces the probability of such a lockup by introducing a
> specialized kernel thread (oom_reaper) which tries to reclaim additional
> memory by preemptively reaping the anonymous or swapped out memory
> owned by the oom victim under an assumption that such a memory won't
> be needed when its owner is killed and kicked from the userspace anyway.
> There is one notable exception to this, though, if the OOM victim was
> in the process of coredumping the result would be incomplete. This is
> considered a reasonable constrain because the overall system health is
> more important than debugability of a particular application.
> 
> A kernel thread has been chosen because we need a reliable way of
> invocation so workqueue context is not appropriate because all the
> workers might be busy (e.g. allocating memory). Kswapd which sounds
> like another good fit is not appropriate as well because it might get
> blocked on locks during reclaim as well.
> 
> oom_reaper has to take mmap_sem on the target task for reading so the
> solution is not 100% because the semaphore might be held or blocked for
> write but the probability is reduced considerably wrt. basically any
> lock blocking forward progress as described above. In order to prevent
> from blocking on the lock without any forward progress we are using only
> a trylock and retry 10 times with a short sleep in between.
> Users of mmap_sem which need it for write should be carefully reviewed
> to use _killable waiting as much as possible and reduce allocations
> requests done with the lock held to absolute minimum to reduce the risk
> even further.
> 
> The API between oom killer and oom reaper is quite trivial. wake_oom_reaper
> updates mm_to_reap with cmpxchg to guarantee only NULL->mm transition
> and oom_reaper clear this atomically once it is done with the work. This
> means that only a single mm_struct can be reaped at the time. As the
> operation is potentially disruptive we are trying to limit it to the
> ncessary minimum and the reaper blocks any updates while it operates on
> an mm. mm_struct is pinned by mm_count to allow parallel exit_mmap and a
> race is detected by atomic_inc_not_zero(mm_users).
> 
> Chnages since v4
> - drop MAX_RT_PRIO-1 as per David - memcg/cpuset/mempolicy OOM killing
>   might interfere with the rest of the system
> Changes since v3
> - many style/compile fixups by Andrew
> - unmap_mapping_range_tree needs full initialization of zap_details
>   to prevent from missing unmaps and follow up BUG_ON during truncate
>   resp. misaccounting - Kirill/Andrew
> - exclude mlocked pages because they need an explicit munlock by Kirill
> - use subsys_initcall instead of module_init - Paul Gortmaker
> - do not tear down mm if it is shared with the global init because this
>   could lead to SEGV and panic - Tetsuo
> Changes since v2
> - fix mm_count refernce leak reported by Tetsuo
> - make sure oom_reaper_th is NULL after kthread_run fails - Tetsuo
> - use wait_event_freezable rather than open coded wait loop - suggested
>   by Tetsuo
> Changes since v1
> - fix the screwed up detail->check_swap_entries - Johannes
> - do not use kthread_should_stop because that would need a cleanup
>   and we do not have anybody to stop us - Tetsuo
> - move wake_oom_reaper to oom_kill_process because we have to wait
>   for all tasks sharing the same mm to get killed - Tetsuo
> - do not reap mm structs which are shared with unkillable tasks - Tetsuo
> 
> Suggested-by: Oleg Nesterov <oleg@redhat.com>
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: David Rientjes <rientjes@google.com>

I think all the patches could really have been squashed together because 
subsequent patches just overwrite already added code.  I was going to 
suggest not doing atomic_inc(&mm->mm_count) in wake_oom_reaper() and 
change oom_kill_process() to do

	if (can_oom_reap)
		wake_oom_reaper(mm);
	else
		mmdrop(mm);

but I see that we don't even touch mm->mm_count after the third patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
