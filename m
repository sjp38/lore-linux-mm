Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 846FF6B0008
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:22:47 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id u8-v6so2786200pfn.18
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:22:47 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 33-v6sor1577441plt.9.2018.07.18.13.22.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 13:22:46 -0700 (PDT)
Date: Wed, 18 Jul 2018 13:22:44 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com> <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 18 Jul 2018, Tetsuo Handa wrote:

> > diff --git a/mm/mmap.c b/mm/mmap.c
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -3059,25 +3059,28 @@ void exit_mmap(struct mm_struct *mm)
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
> > -		 *
> > -		 * This needs to be done before calling munlock_vma_pages_all(),
> > -		 * which clears VM_LOCKED, otherwise the oom reaper cannot
> > -		 * reliably test it.
> >  		 */
> >  		mutex_lock(&oom_lock);
> >  		__oom_reap_task_mm(mm);
> >  		mutex_unlock(&oom_lock);
> >  
> > -		set_bit(MMF_OOM_SKIP, &mm->flags);
> > +		/*
> > +		 * Now, set MMF_UNSTABLE to avoid racing with the oom reaper.
> > +		 * This needs to be done before calling munlock_vma_pages_all(),
> > +		 * which clears VM_LOCKED, otherwise the oom reaper cannot
> > +		 * reliably test for it.  If the oom reaper races with
> > +		 * munlock_vma_pages_all(), this can result in a kernel oops if
> > +		 * a pmd is zapped, for example, after follow_page_mask() has
> > +		 * checked pmd_none().
> > +		 *
> > +		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
> > +		 * guarantee that the oom reaper will not run on this mm again
> > +		 * after mmap_sem is dropped.
> > +		 */
> > +		set_bit(MMF_UNSTABLE, &mm->flags);
> 
> Since MMF_UNSTABLE is set by __oom_reap_task_mm() from exit_mmap() before start reaping
> (because the purpose of MMF_UNSTABLE is to "tell all users of get_user/copy_from_user
> etc... that the content is no longer stable"), it cannot be used for a flag for indicating
> that the OOM reaper can't work on the mm anymore.
> 

Why?  It should be able to be set by exit_mmap() since nothing else should 
be accessing this mm in the first place.  There is no reason to wait for 
the oom reaper and the following down_write();up_write(); cycle will 
guarantee it is not operating on the mm before munlocking.

> If the oom_lock serialization is removed, the OOM reaper will give up after (by default)
> 1 second even if current thread is immediately after set_bit(MMF_UNSTABLE, &mm->flags) from
> __oom_reap_task_mm() from exit_mmap(). Thus, this patch and the other patch which removes
> oom_lock serialization should be dropped.
> 

No, it shouldn't, lol.  The oom reaper may give up because we have entered 
__oom_reap_task_mm() by way of exit_mmap(), there's no other purpose for 
it acting on the mm.  This is very different from giving up by setting 
MMF_OOM_SKIP, which it will wait for oom_free_timeout_ms to do unless the 
thread can make forward progress here in exit_mmap().

> >  		down_write(&mm->mmap_sem);
> >  		up_write(&mm->mmap_sem);
> >  	}
> 
> > @@ -637,25 +649,57 @@ static int oom_reaper(void *unused)
> >  	return 0;
> >  }
> >  
> > +/*
> > + * Millisecs to wait for an oom mm to free memory before selecting another
> > + * victim.
> > + */
> > +static u64 oom_free_timeout_ms = 1000;
> >  static void wake_oom_reaper(struct task_struct *tsk)
> >  {
> > -	/* tsk is already queued? */
> > -	if (tsk == oom_reaper_list || tsk->oom_reaper_list)
> > +	/*
> > +	 * Set the reap timeout; if it's already set, the mm is enqueued and
> > +	 * this tsk can be ignored.
> > +	 */
> > +	if (cmpxchg(&tsk->signal->oom_mm->oom_free_expire, 0UL,
> > +			jiffies + msecs_to_jiffies(oom_free_timeout_ms)))
> >  		return;
> 
> "expire" must not be 0 in order to avoid double list_add(). See
> https://lore.kernel.org/lkml/201807130620.w6D6KiAJ093010@www262.sakura.ne.jp/T/#u .
> 

We should not allow oom_free_timeout_ms to be 0 for sure, I assume 1000 is 
the sane minimum since we need to allow time for some memory freeing and 
this will not be radically different from what existed before the patch 
for the various backoffs.  Or maybe you meant something else for "expire" 
here?
