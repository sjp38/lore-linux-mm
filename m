Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 39EBC6B02C3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:45:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 79so14115711wmr.0
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:45:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l32si11888463wrl.444.2017.07.25.08.45.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 08:45:18 -0700 (PDT)
Date: Tue, 25 Jul 2017 17:45:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725154514.GN26723@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170725152639.GP29716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725152639.GP29716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 25-07-17 17:26:39, Andrea Arcangeli wrote:
> On Mon, Jul 24, 2017 at 09:23:32AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > David has noticed that the oom killer might kill additional tasks while
> > the exiting oom victim hasn't terminated yet because the oom_reaper marks
> > the curent victim MMF_OOM_SKIP too early when mm->mm_users dropped down
> > to 0. The race is as follows
> > 
> > oom_reap_task				do_exit
> > 					  exit_mm
> >   __oom_reap_task_mm
> > 					    mmput
> > 					      __mmput
> >     mmget_not_zero # fails
> >     						exit_mmap # frees memory
> >   set_bit(MMF_OOM_SKIP)
> > 
> > The victim is still visible to the OOM killer until it is unhashed.
> 
> I think this is a very minor problem, in the worst case you get a
> false positive oom kill, and it requires a race condition for it to
> happen. I wouldn't add mmap_sem in exit_mmap just for this considering
> the mmget_not_zero is already enough to leave exit_mmap alone.

That problem is real though as reported by David.

> Could you first clarify these points then I'll understand better what
> the above is about:
> 
> 1) if exit_mmap runs for a long time with terabytes of RAM with
>    mmap_sem held for writing like your patch does, wouldn't then
>    oom_reap_task_mm fail the same way after a few tries on
>    down_read_trylock? Despite your patch got applied? Isn't that
>    simply moving the failure that leads to set_bit(MMF_OOM_SKIP) from
>    mmget_not_zero to down_read_trylock?

No, it's not because the exclusive lock in exit_mmap is taken _after_ we
unmapped the address space. unmap_vmas will happily race with the oom
reaper.
 
> 2) why isn't __oom_reap_task_mm returning different retvals in case
>    mmget_not_zero fails? What is the point to schedule_timeout
>    and retry MAX_OOM_REAP_RETRIES times if mmget_not_zero caused it to
>    return null as it can't do anything about such task anymore? Why
>    are we scheduling those RETRIES times if mm_users is 0?

We are not. __oom_reap_task_mm will return true if the mm_users is 0 and
bail out.

> 3) if exit_mmap is freeing lots of memory already, why should there be
>    another OOM immediately?

Because the memory can be freed from a different oom domain (e.g. a
different NUMA node).

>    I thought oom reaper only was needed when
>    the task on the right column couldn't reach the final mmput to set
>    mm_users to 0. Why exactly is a problem that MMF_OOM_SKIP gets set
>    on the mm, if exit_mmap is already guaranteed to be running?

MMF_OOM_SKIP will hide this task from the OOM killer and so we will
select another victim if we are still under oom. We _want_ to postpone
setting MMF_OOM_SKIP until we know that the oom victim no longer
interesting and we can go on to select another one.

>    Why
>    isn't the oom reaper happy to just stop in such case and wait it to
>    complete?

Because there is no _guarantee_ that the final __mmput will release the
memory in finite time. And we cannot guarantee that longterm.

>    exit_mmap doesn't even take the mmap_sem and it's running
>    in R state, how would it block in a way that requires the OOM
>    reaper to free memory from another process to complete?

it is not only about exit_mmap. __mmput calls into exit_aio and that can
wait for completion and there is no way to guarantee this will finish in
finite time.

> 4) how is it safe to overwrite a VM_FAULT_RETRY that returns without
>    mmap_sem and then the arch code will release the mmap_sem despite
>    it was already released by handle_mm_fault? Anonymous memory faults
>    aren't common to return VM_FAULT_RETRY but an userfault
>    can. Shouldn't there be a block that prevents overwriting if
>    VM_FAULT_RETRY is set below? (not only VM_FAULT_ERROR)
> 
> 	if (unlikely((current->flags & PF_KTHREAD) && !(ret & VM_FAULT_ERROR)
> 				&& test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)))
> 		ret = VM_FAULT_SIGBUS;

I am not sure I understand what you mean and how this is related to the
patch?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
