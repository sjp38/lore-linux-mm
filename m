Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE576B02B4
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 07:26:56 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f17so4512803wmd.11
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 04:26:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r27si14419010wrr.120.2017.06.27.04.26.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 27 Jun 2017 04:26:54 -0700 (PDT)
Date: Tue, 27 Jun 2017 13:26:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170627112650.GK28072@dhcp22.suse.cz>
References: <20170626130346.26314-1-mhocko@kernel.org>
 <201706271952.FEB21375.SFJFHOQLOtVOMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201706271952.FEB21375.SFJFHOQLOtVOMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, andrea@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Tue 27-06-17 19:52:03, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > David has noticed that the oom killer might kill additional tasks while
> > the existing victim hasn't terminated yet because the oom_reaper marks
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
> > Currently we are try to reduce a risk of this race by taking oom_lock
> > and wait for out_of_memory sleep while holding the lock to give the
> > victim some time to exit. This is quite suboptimal approach because
> > there is no guarantee the victim (especially a large one) will manage
> > to unmap its address space and free enough memory to the particular oom
> > domain which needs a memory (e.g. a specific NUMA node).
> > 
> > Fix this problem by allowing __oom_reap_task_mm and __mmput path to
> > race. __oom_reap_task_mm is basically MADV_DONTNEED and that is allowed
> > to run in parallel with other unmappers (hence the mmap_sem for read).
> > The only tricky part is we have to exclude page tables tear down and all
> > operations which modify the address space in the __mmput path. exit_mmap
> > doesn't expect any other users so it doesn't use any locking. Nothing
> > really forbids us to use mmap_sem for write, though. In fact we are
> > already relying on this lock earlier in the __mmput path to synchronize
> > with ksm and khugepaged.
> > 
> > Take the exclusive mmap_sem when calling free_pgtables and destroying
> > vmas to sync with __oom_reap_task_mm which take the lock for read. All
> > other operations can safely race with the parallel unmap.
> > 
> > Reported-by: David Rientjes <rientjes@google.com>
> > Fixes: 26db62f179d1 ("oom: keep mm of the killed task available")
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> > 
> > Hi,
> > I am sending this as an RFC because I am not yet sure I haven't missed
> > something subtle here but the appoach should work in principle. I have
> > run it through some of my OOM stress tests to see if anything blows up
> > and it all went smoothly.
> > 
> > The issue has been brought up by David [1]. There were some attempts to
> > address it in oom proper [2][3] but the first one would cause problems
> > on their own [4] while the later is just too hairy.
> > 
> > Thoughts, objections, alternatives?
> 
> I wonder why you prefer timeout based approach. Your patch will after all
> set MMF_OOM_SKIP if operations between down_write() and up_write() took
> more than one second.

if we reach down_write then we have unmapped the address space in
exit_mmap and oom reaper cannot do much more.

> lock_anon_vma_root() from unlink_anon_vmas() from
> free_pgtables() for example calls down_write()/up_write(). unlink_file_vma()
>  from free_pgtables() for another example calls down_write()/up_write().
> This means that it might happen that exit_mmap() takes more than one second
> with mm->mmap_sem held for write, doesn't this?
> 
> The worst situation is that no memory is released by uprobe_clear_state(), exit_aio(),
> ksm_exit(), khugepaged_exit() and operations before down_write(&mm->mmap_sem), and then
> one second elapses before some memory is released after down_write(&mm->mmap_sem).
> In that case, down_write()/up_write() in your patch helps nothing.
> 
> Less worst situation is that no memory is released by uprobe_clear_state(), exit_aio(),
> ksm_exit(), khugepaged_exit() and operations before down_write(&mm->mmap_sem), and then
> only some memory is released after down_write(&mm->mmap_sem) before one second elapses.
> Someone might think that this is still premature.

This would basically mean that the the oom victim had all its memory in
page tables and vma structures with basically nothing mapped. While this
is possible this is something oom reaper cannot really help with until
we start reclaiming page tables as well. I have had a plan for that but
never got to implement it so this is still on my todo list.

> More likely situation is that down_read_trylock(&mm->mmap_sem) in __oom_reap_task_mm()
> succeeds before exit_mmap() calls down_write(&mm->mmap_sem) (especially true if we remove
> mutex_lock(&oom_lock) from __oom_reap_task_mm()). In this case, your patch merely gives
> uprobe_clear_state(), exit_aio(), ksm_exit(), khugepaged_exit() and operations before
> down_write(&mm->mmap_sem) some time to release memory, for your patch will after all set
> MMF_OOM_SKIP immediately after __oom_reap_task_mm() called up_read(&mm->mmap_sem). If we
> assume that majority of memory is released by operations between
> down_write(&mm->mmap_sem)/up_write(&mm->mmap_sem) in exit_mm(), this is not a preferable
> behavior.
> 
> My patch [3] cannot give uprobe_clear_state(), exit_aio(), ksm_exit(), khugepaged_exit()
> and exit_mm() some time to release memory. But [3] can guarantee that all memory which
> the OOM reaper can reclaim is reclaimed before setting MMF_OOM_SKIP.

This should be the case with this patch as well. We simply do not set
MMF_OOM_SKIP if there is something to unmap.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
