Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E59FE6B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 18:13:47 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t19-v6so8407318plo.9
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:13:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v6-v6sor870760pfk.68.2018.07.20.15.13.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 15:13:46 -0700 (PDT)
Date: Fri, 20 Jul 2018 15:13:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v4] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <ca34b123-5c81-569f-85ea-4851bc569962@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1807201505550.38399@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp> <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com> <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com> <alpine.DEB.2.21.1807201314230.231119@chino.kir.corp.google.com> <ca34b123-5c81-569f-85ea-4851bc569962@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 21 Jul 2018, Tetsuo Handa wrote:

> > diff --git a/mm/mmap.c b/mm/mmap.c
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -3066,25 +3066,27 @@ void exit_mmap(struct mm_struct *mm)
> >  	if (unlikely(mm_is_oom_victim(mm))) {
> >  		/*
> >  		 * Manually reap the mm to free as much memory as possible.
> > -		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
> > -		 * this mm from further consideration.  Taking mm->mmap_sem for
> > -		 * write after setting MMF_OOM_SKIP will guarantee that the oom
> > -		 * reaper will not run on this mm again after mmap_sem is
> > -		 * dropped.
> > -		 *
> >  		 * Nothing can be holding mm->mmap_sem here and the above call
> >  		 * to mmu_notifier_release(mm) ensures mmu notifier callbacks in
> >  		 * __oom_reap_task_mm() will not block.
> >  		 *
> > +		 * This sets MMF_UNSTABLE to avoid racing with the oom reaper.
> >  		 * This needs to be done before calling munlock_vma_pages_all(),
> >  		 * which clears VM_LOCKED, otherwise the oom reaper cannot
> > -		 * reliably test it.
> > +		 * reliably test for it.  If the oom reaper races with
> > +		 * munlock_vma_pages_all(), this can result in a kernel oops if
> > +		 * a pmd is zapped, for example, after follow_page_mask() has
> > +		 * checked pmd_none().
> >  		 */
> >  		mutex_lock(&oom_lock);
> >  		__oom_reap_task_mm(mm);
> >  		mutex_unlock(&oom_lock);
> 
> I don't like holding oom_lock for full teardown of an mm, for an OOM victim's mm
> might have multiple TB memory which could take long time.
> 

This patch does not involve deltas for oom_lock here, it can certainly be 
changed on top of this patch.  I'm not attempting to address any oom_lock 
issue here.  It should pose no roadblock for you.

I only propose this patch now since it fixes millions of processes being 
oom killed unnecessarily, it was in -mm before a NACK for the most trivial 
fixes that have now been squashed into it, and is actually tested.

> >  
> > -		set_bit(MMF_OOM_SKIP, &mm->flags);
> > +		/*
> > +		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
> > +		 * guarantee that the oom reaper will not run on this mm again
> > +		 * after mmap_sem is dropped.
> > +		 */
> >  		down_write(&mm->mmap_sem);
> >  		up_write(&mm->mmap_sem);
> >  	}
> 
> 
> 
> > -#define MAX_OOM_REAP_RETRIES 10
> >  static void oom_reap_task(struct task_struct *tsk)
> >  {
> > -	int attempts = 0;
> >  	struct mm_struct *mm = tsk->signal->oom_mm;
> >  
> > -	/* Retry the down_read_trylock(mmap_sem) a few times */
> > -	while (attempts++ < MAX_OOM_REAP_RETRIES && !oom_reap_task_mm(tsk, mm))
> > -		schedule_timeout_idle(HZ/10);
> > +	/*
> > +	 * If this mm has either been fully unmapped, or the oom reaper has
> > +	 * given up on it, nothing left to do except drop the refcount.
> > +	 */
> > +	if (test_bit(MMF_OOM_SKIP, &mm->flags))
> > +		goto drop;
> >  
> > -	if (attempts <= MAX_OOM_REAP_RETRIES ||
> > -	    test_bit(MMF_OOM_SKIP, &mm->flags))
> > -		goto done;
> > +	/*
> > +	 * If this mm has already been reaped, doing so again will not likely
> > +	 * free additional memory.
> > +	 */
> > +	if (!test_bit(MMF_UNSTABLE, &mm->flags))
> > +		oom_reap_task_mm(tsk, mm);
> 
> This is still wrong. If preempted immediately after set_bit(MMF_UNSTABLE, &mm->flags) from
> __oom_reap_task_mm() from exit_mmap(), oom_reap_task() can give up before reclaiming any memory.

If there is a single thread holding onto the mm and has reached 
exit_mmap() and is in the process of starting oom reaping itself, there's 
no advantage to the oom reaper trying to oom reap it.  The thread in 
exit_mmap() will take care of it, __oom_reap_task_mm() does not block and 
oom_free_timeout_ms allows for enough time for that memory freeing to 
occur.  The oom reaper will not set MMF_OOM_SKIP until the timeout has 
expired.

As I said before, you could make a case for extending the timeout once 
MMF_UNSTABLE has been set.  It practice, we haven't encountered a case 
where that matters.  But that's trivial to do if you would prefer.
