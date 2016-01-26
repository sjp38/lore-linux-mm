Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id E5D726B0005
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 11:38:26 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l65so111766652wmf.1
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 08:38:26 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id v71si6530651wmd.18.2016.01.26.08.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jan 2016 08:38:25 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id u188so18363411wmu.0
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 08:38:25 -0800 (PST)
Date: Tue, 26 Jan 2016 17:38:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/2] oom: clear TIF_MEMDIE after oom_reaper managed to
 unmap the address space
Message-ID: <20160126163823.GG27563@dhcp22.suse.cz>
References: <1452094975-551-1-git-send-email-mhocko@kernel.org>
 <1452516120-5535-1-git-send-email-mhocko@kernel.org>
 <201601181335.JJD69226.JHVQSMFOFOFtOL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601181335.JJD69226.JHVQSMFOFOFtOL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, rientjes@google.com, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 18-01-16 13:35:44, Tetsuo Handa wrote:
[...]
> (1) Make the OOM reaper available on CONFIG_MMU=n kernels.
> 
>     I don't know about MMU, but I assume we can handle these errors.

What is the usecase for this on !MMU configurations? Why does it make
sense to add more code to such a restricted environments? I haven't
heard of a single OOM report from that land.

>     slub.c:(.text+0x4184): undefined reference to `tlb_gather_mmu'
>     slub.c:(.text+0x41bc): undefined reference to `unmap_page_range'
>     slub.c:(.text+0x41d8): undefined reference to `tlb_finish_mmu'
> 
> (2) Do not boot the system if failed to create the OOM reaper thread.
> 
>     We are already heavily depending on the OOM reaper.

Hohmm, does this really bother you that much? This all happens really
early during the boot. If a single kernel thread creation fails that
early then we are screwed anyway and OOM killer will not help a tiny
bit. The only place where the current benevolence matters is a test for
oom_reaper_th != NULL in wake_oom_reaper and I doubt it adds an
overhead. BUG_ON is suited for unrecoverable errors and we can clearly
live without oom_reaper.
 
>     pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
>                     PTR_ERR(oom_reaper_th));
> 
> (3) Eliminate locations that call mark_oom_victim() without
>     making the OOM victim task under monitor of the OOM reaper.
> 
>     The OOM reaper needs to take actions when the OOM victim task got stuck
>     because we (except me) do not want to use my sysctl-controlled timeout-
>     based OOM victim selection.

I do not think this is a correct way to approach the problem. I think we
should involve oom_reaper for those cases. I just want to do that in an
incremental steps. Originally I had the oom_reaper invocation in
mark_oom_victim but that didn't work out (for reasons I do not remember
right now and would have to find them in the archive).
[...]

> (4) Don't select an OOM victim until mm_to_reap (or task_to_reap) becomes NULL.

If we ever see a realistic case where the OOM killer hits in such a pace
that the oom reaper cannot cope with it then I would rather introduce a
queuing mechanism than add a complex code to synchronize the two
contexts. They are currently synchronized via TIF_MEMDIE and that should
be sufficient until the TIF_MEMDIE stops being the oom synchronization
point.

>     This is needed for making sure that any OOM victim is made under
>     monitor of the OOM reaper in order to let the OOM reaper take action
>     before leaving oom_reap_vmas() (or oom_reap_task()).
> 
>     Since the OOM reaper can do mm_to_reap (or task_to_reap) = NULL shortly
>     (e.g. within a second if it retries for 10 times with 0.1 second interval),
>     waiting should not become a problem.
> 
> (5) Decrease oom_score_adj value after the OOM reaper reclaimed memory.
> 
>     If __oom_reap_vmas(mm) (or __oom_reap_task(tsk)) succeeded, set oom_score_adj
>     value of all tasks sharing the same mm to -1000 (by walking the process list)
>     and clear TIF_MEMDIE.
> 
>     Changing only the OOM victim's oom_score_adj is not sufficient
>     when there are other thread groups sharing the OOM victim's memory
>     (i.e. clone(!CLONE_THREAD && CLONE_VM) case).
>
> (6) Decrease oom_score_adj value even if the OOM reaper failed to reclaim memory.
> 
>     If __oom_reap_vmas(mm) (or __oom_reap_task(tsk)) failed for 10 times, decrease
>     oom_score_adj value of all tasks sharing the same mm and clear TIF_MEMDIE.
>     This is needed for preventing the OOM killer from selecting the same thread
>     group forever.

I understand what you mean but I would consider this outside of the
scope of the patchset as I want to pursue it right now. I really want to
introduce a simple async OOM handling. Further steps can be built on top
but please let's not make it a huge monster right away. The same applies
to the point 5. mm shared between processes is a border line to focus on
it in the first submission.

>     An example is, set oom_score_adj to -999 if oom_score_adj is greater than
>     -999, set -1000 if oom_score_adj is already -999. This will allow the OOM
>     killer try to choose different OOM victims before retrying __oom_reap_vmas(mm)
>     (or __oom_reap_task(tsk)) of this OOM victim, then trigger kernel panic if
>     all OOM victims got -1000.
> 
>     Changing mmap_sem lock killable increases possibility of __oom_reap_vmas(mm)
>     (or __oom_reap_task(tsk)) to succeed. But due to the changes in (3) and (4),
>     there is no guarantee that TIF_MEMDIE is set to the thread which is looping at
>     __alloc_pages_slowpath() with the mmap_sem held for writing. If the OOM killer
>     were able to know which thread is looping at __alloc_pages_slowpath() with the
>     mmap_sem held for writing (via per task_struct variable), the OOM killer would
>     set TIF_MEMDIE on that thread before randomly choosing one thread using
>     find_lock_task_mm().

If mmap_sem (for write) holder is looping in the allocator and the
process gets killed it will get access to memory reserves automatically,
so I am not sure what do you mean here.

Thank you for your feedback. There are some improvements and additional
heuristics proposed and they might be really valuable in some cases but
I believe that none of the points you are rising are blockers for the
current code. My intention here is to push the initial version which
would handle the most probable cases and build more on top. I would
really prefer this doesn't grow into a hard to evaluate bloat from the
early beginning.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
