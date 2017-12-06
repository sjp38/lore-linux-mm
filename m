Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E466B6B0366
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 03:31:34 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w74so1506711wmf.0
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 00:31:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j63si2109851edc.538.2017.12.06.00.31.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 06 Dec 2017 00:31:33 -0800 (PST)
Date: Wed, 6 Dec 2017 09:31:30 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
Message-ID: <20171206083130.GC16386@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 05-12-17 18:43:48, David Rientjes wrote:
> Hi,
> 
> I'd like to understand the synchronization between the oom_reaper's 
> unmap_page_range() and exit_mmap().  The latter does not hold 
> mm->mmap_sem: it's supposed to be the last thread operating on the mm 
> before it is destroyed.
> 
> If unmap_page_range() races with unmap_vmas(), we trivially call 
> page_remove_rmap() twice on the same page:

Well, the oom reaper is basically MADV_DONTNEED and that allows
parallel tear down (it takes only mmap_sem for read). The exit path
doesn't take the mmap_sem during unmap_vmas but that shouldn't make any
difference because both path would take it for read anyway. The
essential synchronization between oom reaper and exit_mmap is
exit_mmap:	
	set_bit(MMF_OOM_SKIP, &mm->flags);
	if (unlikely(tsk_is_oom_victim(current))) {
		/*
		 * Wait for oom_reap_task() to stop working on this
		 * mm. Because MMF_OOM_SKIP is already set before
		 * calling down_read(), oom_reap_task() will not run
		 * on this "mm" post up_write().
		 *
		 * tsk_is_oom_victim() cannot be set from under us
		 * either because current->mm is already set to NULL
		 * under task_lock before calling mmput and oom_mm is
		 * set not NULL by the OOM killer only if current->mm
		 * is found not NULL while holding the task_lock.
		 */
		down_write(&mm->mmap_sem);
		up_write(&mm->mmap_sem);
	}

oom_reaper
	if (!down_read_trylock(&mm->mmap_sem)) {

	/*
	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
	 * under mmap_sem for reading because it serializes against the
	 * down_write();up_write() cycle in exit_mmap().
	 */
	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {

which makes sure that the reaper doesn't race with free_pgtables.

> BUG: Bad page map in process oom_reaper  pte:6353826300000000 pmd:00000000

Hmm, this is really strange. This is a pte without a pmd or is the
output just incomplete.

> addr:00007f50cab1d000 vm_flags:08100073 anon_vma:ffff9eea335603f0 mapping:          (null) index:7f50cab1d
> file:          (null) fault:          (null) mmap:          (null) readpage:          (null)
> CPU: 2 PID: 1001 Comm: oom_reaper
> Call Trace:
>  [<ffffffffa4bd967d>] dump_stack+0x4d/0x70
>  [<ffffffffa4a03558>] unmap_page_range+0x1068/0x1130

could you use addr2line to get the exact spot where this triggered
please?

>  [<ffffffffa4a2e07f>] __oom_reap_task_mm+0xd5/0x16b
>  [<ffffffffa4a2e226>] oom_reaper+0xff/0x14c
>  [<ffffffffa48d6ad1>] kthread+0xc1/0xe0
> 
> And there are more examples of badness from an unmap_page_range() racing 
> with unmap_vmas().  In this case, MMF_OOM_SKIP is doing two things: (1) 
> avoiding additional oom kills until unmap_vmas() returns and (2) avoid the 
> oom_reaper working on the mm after unmap_vmas().  In (2), there's nothing 
> preventing the oom reaper from calling unmap_page_range() in parallel with 
> the final thread doing unmap_vmas() -- we no longer do mmget() to prevent 
> exit_mmap() from being called.

Yes and that is an intentional behavior. There shouldn't be any reason
to exclude the two because this should be equivalent to calling
MADV_DONTNEED in parallel.

I will get to the rest of your email later because the above is the
essential assumption 212925802454 ("mm: oom: let oom_reap_task and
exit_mmap run concurrently") builds on. If it is not correct then we
have a bigger problem.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
