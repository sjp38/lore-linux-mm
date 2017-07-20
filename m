Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 093866B02B4
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 21:18:38 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id s64so16797601pfa.1
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:18:38 -0700 (PDT)
Received: from mail-pg0-x230.google.com (mail-pg0-x230.google.com. [2607:f8b0:400e:c05::230])
        by mx.google.com with ESMTPS id d73si860850pga.296.2017.07.19.18.18.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 18:18:36 -0700 (PDT)
Received: by mail-pg0-x230.google.com with SMTP id 125so7381090pgi.3
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 18:18:36 -0700 (PDT)
Date: Wed, 19 Jul 2017 18:18:27 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
In-Reply-To: <20170719055542.GA22162@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1707191716030.2055@eggly.anvils>
References: <20170626130346.26314-1-mhocko@kernel.org> <20170629084621.GE31603@dhcp22.suse.cz> <20170719055542.GA22162@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrea Arcangeli <andrea@kernel.org>, Hugh Dickins <hughd@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 19 Jul 2017, Michal Hocko wrote:
> On Thu 29-06-17 10:46:21, Michal Hocko wrote:
> > Forgot to CC Hugh.
> > 
> > Hugh, Andrew, do you see this could cause any problem wrt.
> > ksm/khugepaged exit path?
> 
> ping. I would really appreciate some help here. I would like to resend
> the patch soon.

Sorry, Michal, I've been hiding from everyone.

No, I don't think your patch will cause any trouble for the ksm or
khugepaged exit path; but we'll find out for sure when akpm puts it
in mmotm - I doubt I'll get to trying it out in advance of that.

On the contrary, I think it will allow us to remove the peculiar
"down_write(mmap_sem); up_write(mmap_sem);" from those exit paths:
which were there to serialize, precisely because exit_mmap() did
not otherwise take mmap_sem; but you're now changing it to do so.

You could add a patch to remove those yourself, or any of us add
that on afterwards.

But I don't entirely agree (or disagree) with your placement:
see comment below.

> 
> > On Mon 26-06-17 15:03:46, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > David has noticed that the oom killer might kill additional tasks while
> > > the existing victim hasn't terminated yet because the oom_reaper marks
> > > the curent victim MMF_OOM_SKIP too early when mm->mm_users dropped down
> > > to 0. The race is as follows
> > > 
> > > oom_reap_task				do_exit
> > > 					  exit_mm
> > >   __oom_reap_task_mm
> > > 					    mmput
> > > 					      __mmput
> > >     mmget_not_zero # fails
> > >     						exit_mmap # frees memory
> > >   set_bit(MMF_OOM_SKIP)
> > > 
> > > Currently we are try to reduce a risk of this race by taking oom_lock
> > > and wait for out_of_memory sleep while holding the lock to give the
> > > victim some time to exit. This is quite suboptimal approach because
> > > there is no guarantee the victim (especially a large one) will manage
> > > to unmap its address space and free enough memory to the particular oom
> > > domain which needs a memory (e.g. a specific NUMA node).
> > > 
> > > Fix this problem by allowing __oom_reap_task_mm and __mmput path to
> > > race. __oom_reap_task_mm is basically MADV_DONTNEED and that is allowed
> > > to run in parallel with other unmappers (hence the mmap_sem for read).
> > > The only tricky part is we have to exclude page tables tear down and all
> > > operations which modify the address space in the __mmput path. exit_mmap
> > > doesn't expect any other users so it doesn't use any locking. Nothing
> > > really forbids us to use mmap_sem for write, though. In fact we are
> > > already relying on this lock earlier in the __mmput path to synchronize
> > > with ksm and khugepaged.
> > > 
> > > Take the exclusive mmap_sem when calling free_pgtables and destroying
> > > vmas to sync with __oom_reap_task_mm which take the lock for read. All
> > > other operations can safely race with the parallel unmap.
> > > 
> > > Reported-by: David Rientjes <rientjes@google.com>
> > > Fixes: 26db62f179d1 ("oom: keep mm of the killed task available")
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > ---
> > > 
> > > Hi,
> > > I am sending this as an RFC because I am not yet sure I haven't missed
> > > something subtle here but the appoach should work in principle. I have
> > > run it through some of my OOM stress tests to see if anything blows up
> > > and it all went smoothly.
> > > 
> > > The issue has been brought up by David [1]. There were some attempts to
> > > address it in oom proper [2][3] but the first one would cause problems
> > > on their own [4] while the later is just too hairy.
> > > 
> > > Thoughts, objections, alternatives?
> > > 
> > > [1] http://lkml.kernel.org/r/alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com
> > > [2] http://lkml.kernel.org/r/201706171417.JHG48401.JOQLHMFSVOOFtF@I-love.SAKURA.ne.jp
> > > [3] http://lkml.kernel.org/r/201706220053.v5M0rmOU078764@www262.sakura.ne.jp
> > > [4] http://lkml.kernel.org/r/201706210217.v5L2HAZc081021@www262.sakura.ne.jp
> > > 
> > >  mm/mmap.c     |  7 +++++++
> > >  mm/oom_kill.c | 40 ++--------------------------------------
> > >  2 files changed, 9 insertions(+), 38 deletions(-)
> > > 
> > > diff --git a/mm/mmap.c b/mm/mmap.c
> > > index 3bd5ecd20d4d..253808e716dc 100644
> > > --- a/mm/mmap.c
> > > +++ b/mm/mmap.c
> > > @@ -2962,6 +2962,11 @@ void exit_mmap(struct mm_struct *mm)
> > >  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
> > >  	unmap_vmas(&tlb, vma, 0, -1);
> > >  
> > > +	/*
> > > +	 * oom reaper might race with exit_mmap so make sure we won't free
> > > +	 * page tables or unmap VMAs under its feet
> > > +	 */
> > > +	down_write(&mm->mmap_sem);

Hmm.  I'm conflicted about this.  From a design point of view, I would
very much prefer you to take the mmap_sem higher up, maybe just before
or after the mmu_notifier_release() or arch_exit_mmap() (depends on
what those actually do): anyway before the unmap_vmas().

Because the things which go on in exit_mmap() are things which we expect
mmap_sem to be held across, and we get caught out when it is not: it's
awkard and error-prone enough that MADV_DONTNEED and MADV_FREE (for
very good reason) do things with only down_read(mmap_sem).  But there's
a number of times (ksm exit being only one of them) when I've found it
a nuisance that we had no proper way of serializing against exit_mmap().

I'm conflicted because, on the other hand, I'm staunchly against adding
obstructions ("robust" futexes? gah!) into the exit patch, or widening
the use of locks that are not strictly needed.  But wouldn't it be the
case here, that most contenders on the mmap_sem must hold a reference
to mm_users, and that prevents any possibility of racing exit_mmap();
only ksm and khugepaged, and any others who already need such mmap_sem
tricks to serialize against exit_mmap(), could offer any contention.

But I haven't looked at the oom_kill or oom_reaper end of it at all,
perhaps you have an overriding argument on the placement from that end.

Hugh

[Not strictly relevant here, but a related note: I was very surprised
to discover, only quite recently, how handle_mm_fault() may be called
without down_read(mmap_sem) - when core dumping.  That seems a
misguided optimization to me, which would also be nice to correct;
but again I might not appreciate the full picture.]

> > >  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> > >  	tlb_finish_mmu(&tlb, 0, -1);
> > >  
> > > @@ -2974,7 +2979,9 @@ void exit_mmap(struct mm_struct *mm)
> > >  			nr_accounted += vma_pages(vma);
> > >  		vma = remove_vma(vma);
> > >  	}
> > > +	mm->mmap = NULL;
> > >  	vm_unacct_memory(nr_accounted);
> > > +	up_write(&mm->mmap_sem);
> > >  }
> > >  
> > >  /* Insert vm structure into process list sorted by address
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 0e2c925e7826..5dc0ff22d567 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -472,36 +472,8 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
> > >  	struct vm_area_struct *vma;
> > >  	bool ret = true;
> > >  
> > > -	/*
> > > -	 * We have to make sure to not race with the victim exit path
> > > -	 * and cause premature new oom victim selection:
> > > -	 * __oom_reap_task_mm		exit_mm
> > > -	 *   mmget_not_zero
> > > -	 *				  mmput
> > > -	 *				    atomic_dec_and_test
> > > -	 *				  exit_oom_victim
> > > -	 *				[...]
> > > -	 *				out_of_memory
> > > -	 *				  select_bad_process
> > > -	 *				    # no TIF_MEMDIE task selects new victim
> > > -	 *  unmap_page_range # frees some memory
> > > -	 */
> > > -	mutex_lock(&oom_lock);
> > > -
> > > -	if (!down_read_trylock(&mm->mmap_sem)) {
> > > -		ret = false;
> > > -		goto unlock_oom;
> > > -	}
> > > -
> > > -	/*
> > > -	 * increase mm_users only after we know we will reap something so
> > > -	 * that the mmput_async is called only when we have reaped something
> > > -	 * and delayed __mmput doesn't matter that much
> > > -	 */
> > > -	if (!mmget_not_zero(mm)) {
> > > -		up_read(&mm->mmap_sem);
> > > -		goto unlock_oom;
> > > -	}
> > > +	if (!down_read_trylock(&mm->mmap_sem))
> > > +		return false;
> > >  
> > >  	/*
> > >  	 * Tell all users of get_user/copy_from_user etc... that the content
> > > @@ -538,14 +510,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
> > >  			K(get_mm_counter(mm, MM_SHMEMPAGES)));
> > >  	up_read(&mm->mmap_sem);
> > >  
> > > -	/*
> > > -	 * Drop our reference but make sure the mmput slow path is called from a
> > > -	 * different context because we shouldn't risk we get stuck there and
> > > -	 * put the oom_reaper out of the way.
> > > -	 */
> > > -	mmput_async(mm);
> > > -unlock_oom:
> > > -	mutex_unlock(&oom_lock);
> > >  	return ret;
> > >  }
> > >  
> > > -- 
> > > 2.11.0
> > > 
> > > --
> > > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > > the body to majordomo@kvack.org.  For more info on Linux MM,
> > > see: http://www.linux-mm.org/ .
> > > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> > -- 
> > Michal Hocko
> > SUSE Labs
> 
> -- 
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
