Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA916B025F
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 06:27:21 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id e70so850298wmc.6
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 03:27:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y43si5541676wrd.466.2017.12.08.03.27.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 03:27:19 -0800 (PST)
Date: Fri, 8 Dec 2017 12:27:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
Message-ID: <20171208112717.GT20234@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
 <20171207113548.GG20234@dhcp22.suse.cz>
 <201712080044.BID56711.FFVOLMStJOQHOF@I-love.SAKURA.ne.jp>
 <20171207163003.GM20234@dhcp22.suse.cz>
 <alpine.DEB.2.10.1712071352480.135101@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712080118420.145074@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1712080118420.145074@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 08-12-17 01:26:46, David Rientjes wrote:
> On Thu, 7 Dec 2017, David Rientjes wrote:
> 
> > I'm backporting and testing the following patch against Linus's tree.  To 
> > clarify an earlier point, we don't actually have any change from upstream 
> > code that allows for free_pgtables() before the 
> > set_bit(MMF_OOM_SKIP);down_write();up_write() cycle.
> > 
> > diff --git a/include/linux/oom.h b/include/linux/oom.h
> > --- a/include/linux/oom.h
> > +++ b/include/linux/oom.h
> > @@ -66,6 +66,15 @@ static inline bool tsk_is_oom_victim(struct task_struct * tsk)
> >  	return tsk->signal->oom_mm;
> >  }
> >  
> > +/*
> > + * Use this helper if tsk->mm != mm and the victim mm needs a special
> > + * handling. This is guaranteed to stay true after once set.
> > + */
> > +static inline bool mm_is_oom_victim(struct mm_struct *mm)
> > +{
> > +	return test_bit(MMF_OOM_VICTIM, &mm->flags);
> > +}
> > +
> >  /*
> >   * Checks whether a page fault on the given mm is still reliable.
> >   * This is no longer true if the oom reaper started to reap the
> > diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
> > --- a/include/linux/sched/coredump.h
> > +++ b/include/linux/sched/coredump.h
> > @@ -71,6 +71,7 @@ static inline int get_dumpable(struct mm_struct *mm)
> >  #define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
> >  #define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
> >  #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
> > +#define MMF_OOM_VICTIM		25	/* mm is the oom victim */
> >  
> >  #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
> >  				 MMF_DISABLE_THP_MASK)
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -3019,20 +3019,20 @@ void exit_mmap(struct mm_struct *mm)
> >  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
> >  	unmap_vmas(&tlb, vma, 0, -1);
> >  
> > -	set_bit(MMF_OOM_SKIP, &mm->flags);
> > -	if (unlikely(tsk_is_oom_victim(current))) {
> > +	if (unlikely(mm_is_oom_victim(mm))) {
> >  		/*
> >  		 * Wait for oom_reap_task() to stop working on this
> >  		 * mm. Because MMF_OOM_SKIP is already set before
> >  		 * calling down_read(), oom_reap_task() will not run
> >  		 * on this "mm" post up_write().
> >  		 *
> > -		 * tsk_is_oom_victim() cannot be set from under us
> > +		 * mm_is_oom_victim() cannot be set from under us
> >  		 * either because current->mm is already set to NULL
> >  		 * under task_lock before calling mmput and oom_mm is
> >  		 * set not NULL by the OOM killer only if current->mm
> >  		 * is found not NULL while holding the task_lock.
> >  		 */
> > +		set_bit(MMF_OOM_SKIP, &mm->flags);
> >  		down_write(&mm->mmap_sem);
> >  		up_write(&mm->mmap_sem);
> >  	}
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -683,8 +683,10 @@ static void mark_oom_victim(struct task_struct *tsk)
> >  		return;
> >  
> >  	/* oom_mm is bound to the signal struct life time. */
> > -	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
> > +	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
> >  		mmgrab(tsk->signal->oom_mm);
> > +		set_bit(MMF_OOM_VICTIM, &mm->flags);
> > +	}
> >  
> >  	/*
> >  	 * Make sure that the task is woken up from uninterruptible sleep
> > 
> 
> This passes all functional testing that I have and I can create a 
> synthetic testcase that can trigger at least MMF_OOM_VICTIM getting set 
> while oom_reaper is still working on an mm that this prevents, so feel 
> free to add an
> 
> 	Acked-by: David Rientjes <rientjes@google.com>
> 
> with a variant of your previous changelogs.  Thanks!
> 
> I think it would appropriate to cc stable for 4.14 and add a
> 
> Fixes: 212925802454 ("mm: oom: let oom_reap_task and exit_mmap run 
> concurrently")
> 
> if nobody disagrees, which I think you may have already done on a previous 
> iteration.

Thanks for your testing! I will repost the patch later today.

> We can still discuss if there are any VM_LOCKED subtleties in the this 
> thread, but I have no evidence that it is responsible for any issues.

Yes this is worth a separate discussion.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
