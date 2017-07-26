Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 79B546B02C3
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:45:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id u89so30610916wrc.1
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 22:45:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 71si8726378wms.268.2017.07.25.22.45.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 22:45:36 -0700 (PDT)
Date: Wed, 26 Jul 2017 07:45:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170726054533.GA960@dhcp22.suse.cz>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170725152639.GP29716@redhat.com>
 <20170725154514.GN26723@dhcp22.suse.cz>
 <20170725182619.GQ29716@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725182619.GQ29716@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 25-07-17 20:26:19, Andrea Arcangeli wrote:
> On Tue, Jul 25, 2017 at 05:45:14PM +0200, Michal Hocko wrote:
> > That problem is real though as reported by David.
> 
> I'm not against fixing it, I just think it's not a major concern, and
> the solution doesn't seem optimal as measured by Kirill.
> 
> I'm just skeptical it's the best to solve that tiny race, 99.9% of the
> time such down_write is unnecessary.
> 
> > it is not only about exit_mmap. __mmput calls into exit_aio and that can
> > wait for completion and there is no way to guarantee this will finish in
> > finite time.
> 
> exit_aio blocking is actually the only good point for wanting this
> concurrency where exit_mmap->unmap_vmas and
> oom_reap_task->unmap_page_range have to run concurrently on the same
> mm.

Yes, exit_aio is the only blocking call I know of currently. But I would
like this to be as robust as possible and so I do not want to rely on
the current implementation. This can change in future and I can
guarantee that nobody will think about the oom path when adding
something to the final __mmput path.

> exit_mmap would have no issue, if there was enough time in the
> lifetime CPU to allocate the memory, sure the memory will also be
> freed in finite amount of time by exit_mmap.

I am not sure I understand. Say that any call prior to unmap_vmas blocks
on a lock which is held by another call path which cannot proceed with
the allocation...
 
> In fact you mentioned multiple OOM in the NUMA case, exit_mmap may not
> solve that, so depending on the runtime it may have been better not to
> wait all memory of the process to be freed before moving to the next
> task, but only a couple of seconds before the OOM reaper moves to a
> new candidate. Again this is only a tradeoff between solving the OOM
> faster vs risk of false positives OOM.

I really do not want to rely on any timing. This just too fragile. Once
we have killed a task then we shouldn't pick another victim until it
passed exit_mmap or the oom_reaper did its job. Otherwise we just risk
false positives while we have already disrupted the workload.
 
> If it wasn't because of exit_aio (which may have to wait I/O
> completion), changing the OOM reaper to return "false" if
> mmget_not_zero returns zero and MMF_OOM_SKIP is not set yet, would
> have been enough (and depending on the runtime it may have solved OOM
> faster in NUMA) and there would be absolutely no need to run OOM
> reaper and exit_mmap concurrently on the same mm. However there's such
> exit_aio..
> 
> Raw I/O mempools never require memory allocations, although aio if it
> involves a filesystem to complete may run into filesystem or buffering
> locks which are known to loop forever or depend on other tasks stuck
> in kernel allocations, so I didn't go down that chain too long.

Exactly. We simply cannot assume anything here because veryfying this
basically impossible.
 
[...]
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f19efcf75418..615133762b99 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2993,6 +2993,11 @@ void exit_mmap(struct mm_struct *mm)
>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>  	unmap_vmas(&tlb, vma, 0, -1);
>  
> +	if (test_and_set_bit(MMF_OOM_SKIP, &mm->flags)) {
> +		/* wait the OOM reaper to stop working on this mm */
> +		down_write(&mm->mmap_sem);
> +		up_write(&mm->mmap_sem);
> +	}
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>  	tlb_finish_mmu(&tlb, 0, -1);
>  
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 9e8b4f030c1c..2a7000995784 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -471,6 +471,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	struct mmu_gather tlb;
>  	struct vm_area_struct *vma;
>  	bool ret = true;
> +	bool mmgot = true;
>  
>  	/*
>  	 * We have to make sure to not race with the victim exit path
> @@ -500,9 +501,16 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	 * and delayed __mmput doesn't matter that much
>  	 */
>  	if (!mmget_not_zero(mm)) {
> -		up_read(&mm->mmap_sem);
>  		trace_skip_task_reaping(tsk->pid);
> -		goto unlock_oom;
> +		/*
> +		 * MMF_OOM_SKIP is set by exit_mmap when the OOM
> +		 * reaper can't work on the mm anymore.
> +		 */
> +		if (test_and_set_bit(MMF_OOM_SKIP, &mm->flags)) {
> +			up_read(&mm->mmap_sem);
> +			goto unlock_oom;
> +		}
> +		mmgot = false;
>  	}

This will work more or less the same to what we have currently.

[victim]		[oom reaper]				[oom killer]
do_exit			__oom_reap_task_mm
  mmput
    __mmput
			  mmget_not_zero
			    test_and_set_bit(MMF_OOM_SKIP)
			    					oom_evaluate_task
								   # select next victim 
			  # reap the mm
      unmap_vmas

so we can select a next victim while the current one is still not
completely torn down.

> > > 4) how is it safe to overwrite a VM_FAULT_RETRY that returns without
> > >    mmap_sem and then the arch code will release the mmap_sem despite
> > >    it was already released by handle_mm_fault? Anonymous memory faults
> > >    aren't common to return VM_FAULT_RETRY but an userfault
> > >    can. Shouldn't there be a block that prevents overwriting if
> > >    VM_FAULT_RETRY is set below? (not only VM_FAULT_ERROR)
> > > 
> > > 	if (unlikely((current->flags & PF_KTHREAD) && !(ret & VM_FAULT_ERROR)
> > > 				&& test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)))
> > > 		ret = VM_FAULT_SIGBUS;
> > 
> > I am not sure I understand what you mean and how this is related to the
> > patch?
> 
> It's not related to the patch but it involves the OOM reaper as it
> only happens when MMF_UNSTABLE is set which is set only by the OOM
> reaper. I was simply reading the OOM reaper code and following up what
> MMF_UNSTABLE does and it ringed a bell.

I hope 3f70dc38cec2 ("mm: make sure that kthreads will not refault oom
reaped memory") will clarify this code. If not please start a new thread
so that we do not conflate different things together.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
