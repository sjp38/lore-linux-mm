Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id C748C6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 05:58:48 -0400 (EDT)
Received: by wgme6 with SMTP id e6so109467678wgm.2
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 02:58:48 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4si17857747wix.18.2015.06.01.02.58.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 02:58:46 -0700 (PDT)
Date: Mon, 1 Jun 2015 11:58:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150601095845.GB7147@dhcp22.suse.cz>
References: <201505280659.HBE69765.SOtQMJLVFHFFOO@I-love.SAKURA.ne.jp>
 <20150528180524.GB2321@dhcp22.suse.cz>
 <201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
 <20150529144922.GE22728@dhcp22.suse.cz>
 <201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
 <201505312010.JJJ26561.FJOOVSQHLFOtMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201505312010.JJJ26561.FJOOVSQHLFOtMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Sun 31-05-15 20:10:23, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > So I think, but I have to think more about this, a proper way to handle
> > this would be something like the following. The patch is obviously
> > incomplete because memcg OOM killer would need the same treatment which
> > calls for a common helper etc...
> 
> I believe that current out_of_memory() code is too optimistic about exiting
> task. Current code can easily result in either
> 
>   (1) silent hang up due to reporting nothing upon OOM deadlock
>   (2) very noisy oom_kill_process() due to re-reporting the same mm struct

Are you able to trigger any of those?

> because we set TIF_MEMDIE to only one thread.

No, we select only one task. And that is a difference. Because we allow
to set TIF_MEMDIE to multiple tasks if they are on their way out. This
is what the below code snippet, which you want to remove, does.

> To avoid (1), we should remove
> 
> 	/*
> 	 * If current has a pending SIGKILL or is exiting, then automatically
> 	 * select it.  The goal is to allow it to allocate so that it may
> 	 * quickly exit and free its memory.
> 	 *
> 	 * But don't select if current has already released its mm and cleared
> 	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
> 	 */
> 	if (current->mm &&
> 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
> 		mark_oom_victim(current);
> 		goto out;
> 	}
> 
> in out_of_memory() and
> 
> 	/*
> 	 * If the task is already exiting, don't alarm the sysadmin or kill
> 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
> 	 */
> 	task_lock(p);
> 	if (p->mm && task_will_free_mem(p)) {
> 		mark_oom_victim(p);
> 		task_unlock(p);
> 		put_task_struct(p);
> 		return;
> 	}
> 	task_unlock(p);
>
> in oom_kill_process() which set TIF_MEMDIE to only one thread.
> Removing the former chunk helps when check_panic_on_oom() is configured to
> call panic() (i.e. /proc/sys/vm/panic_on_oom is not 0) and then the system
> fell into TIF_MEMDIE deadlock, for their systems will be rebooted
> automatically than entering into silent hang up loop upon OOM condition.

Hmm, I guess we should simply move check_panic_on_oom before the current
is dying check. It seems that reliable panic is more important than a
premature failure which is quite unlikely anyway. If somebody configures
panic_on_oom we should obey that and not try to be clever (will post a
patch later today).

> To avoid (2), we should consider either
> 
>   (a) Add a bool to "struct mm_struct" and set that bool to true when that
>       mm struct was chosen for the first time. Set TIF_MEMDIE to next thread
>       without calling printk() unless that mm was chosen for the first time.

Will not work in general as explained in other email.

> 
>   (b) Set TIF_MEMDIE to all threads in all processes sharing the same mm
>       struct, making oom_scan_process_thread() return OOM_SCAN_ABORT as
>       long as there is a TIF_MEMDIE thread.

Again, too risky to deplete the whole memory.

[...]
> If we forget about complete depletion of all memory, (b) is preferable from
> the point of view of reducing the possibility of falling into TIF_MEMDIE
> deadlock.

Why doesn't "lazy" mark_oom_victim work? I mean if the mm sharing tasks
get TIF_MEMDIE when they enter OOM killer?

> The TIF_MEMDIE is meant to facilitate setting tsk->mm = NULL so that memory
> associated with the TIF_MEMDIE thread's mm struct is released soon. But the
> algorithm for choosing a thread does not (more precisely, can not) take lock
> dependency into account. There are locations where down_read(&tsk->mm->mmap_sem)
> and up_read(&tsk->mm->mmap_sem) are called between getting PF_EXITING and
> setting tsk->mm = NULL. Also, there are locations where memory allocations
> are done between down_write(&current->mm->mmap_sem) and
> up_write(&current->mm->mmap_sem). As a result, TIF_MEMDIE can be set to
> a thread which is waiting at e.g. down_read(&current->mm->mmap_sem) when one
> of threads sharing the same mm struct is doing memory allocations between
> down_write(&current->mm->mmap_sem) and up_write(&current->mm->mmap_sem).
> When such case occurred, the TIF_MEMDIE thread can not be terminated because
> memory allocation by non-TIF_MEMDIE thread cannot complete until
> non-TIF_MEMDIE thread gets TIF_MEMDIE (assuming that the "too small to fail"
> memory-allocation rule remains due to reasons explained at
> http://marc.info/?l=linux-mm&m=143239200805478 ). It seems to me that the
> description
> 
>   This prevents mm->mmap_sem livelock when an oom killed thread cannot exit
>   because it requires the semaphore and its contended by another thread
>   trying to allocate memory itself.
> 
> is not true, for sending SIGKILL cannot make another thread to return from
> memory allocation attempt.

It does because those processes would have fatal_signal_pending and so
they would get access to memory reserves which should help them to
succeed the allocation and release the lock. IMO we should be able to
get rid of this loop and rely on a counter in mm and use it for lazy
TIF_MEMDIE for processes sharing the mm struct (similar to
fatal_signal_pending heuristic). But I am still not convinced this is
really worth bothering. Processes sharing mm are rare and the current
code should be able to deal with them quite well, modulo the race you
have pointed out but that is quite unlikely. If you are able to trigger
it, though, then I would prefer we do the counter thing and then getting
rid of the loop would be probably better.
 
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
