Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 386B36B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 07:21:43 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id p41so113930489lfi.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 04:21:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e5si14430431wjn.39.2016.07.25.04.21.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 04:21:41 -0700 (PDT)
Date: Mon, 25 Jul 2016 13:21:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
Message-ID: <20160725112140.GF9401@dhcp22.suse.cz>
References: <20160721112140.GG26379@dhcp22.suse.cz>
 <201607222009.DII64068.VHMSQJtOOFOLFF@I-love.SAKURA.ne.jp>
 <20160722120519.GJ794@dhcp22.suse.cz>
 <201607231159.IFD26547.HVMOQtSJFOFFOL@I-love.SAKURA.ne.jp>
 <20160725084803.GE9401@dhcp22.suse.cz>
 <201607252007.BGI56224.SHVFLFOOFMJtOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607252007.BGI56224.SHVFLFOOFMJtOQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Mon 25-07-16 20:07:11, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > > > index 788e4f22e0bb..34446f49c2e1 100644
> > > > > > --- a/mm/page_alloc.c
> > > > > > +++ b/mm/page_alloc.c
> > > > > > @@ -3358,7 +3358,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> > > > > >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > > > > >  		else if (!in_interrupt() &&
> > > > > >  				((current->flags & PF_MEMALLOC) ||
> > > > > > -				 unlikely(test_thread_flag(TIF_MEMDIE))))
> > > > > > +				 tsk_is_oom_victim(current))
> > > > > >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > > > > >  	}
> > > > > >  #ifdef CONFIG_CMA
> > > > > > 
> > > > > > where tsk_is_oom_victim wouldn't require the given task to go via
> > > > > > out_of_memory. This would solve some of the problems we have right now
> > > > > > when a thread doesn't get access to memory reserves because it never
> > > > > > reaches out_of_memory (e.g. recently mentioned mempool_alloc doing
> > > > > > __GFP_NORETRY). It would also make the code easier to follow. If we want
> > > > > > to implement that we need an easy to implement tsk_is_oom_victim
> > > > > > obviously. With the signal_struct::oom_mm this is really trivial thing.
> > > > > > I am not sure we can do that with the mm list though because we are
> > > > > > loosing the task->mm at certain point in time.
> > > > > 
> > > > > bool tsk_is_oom_victim(void)
> > > > > {
> > > > > 	return current->mm && test_bit(MMF_OOM_KILLED, &current->mm->flags) &&
> > > > > 		 (fatal_signal_pending(current) || (current->flags & PF_EXITING));
> > > > > }
> > > > 
> > > > which doesn't work as soon as exit_mm clears the mm which is exactly
> > > > the concern I have raised above.
> > > 
> > > Are you planning to change the scope where the OOM victims can access memory
> > > reserves?
> > 
> > Yes. Because we know that there are some post exit_mm allocations and I
> > do not want to get back to PF_EXITING and other tricks...
> > 
> > > (1) If you plan to allow the OOM victims to access memory reserves until
> > >     TASK_DEAD, tsk_is_oom_victim() will be as trivial as
> > > 
> > > bool tsk_is_oom_victim(struct task_struct *task)
> > > {
> > > 	return task->signal->oom_mm;
> > > }
> > 
> > yes, exactly. That's what I've tried to say above. with the oom_mm this
> > is trivial to implement while mm lists will not help us much due to
> > their life time. This also means that we know about the oom victim until
> > it is unhashed and become invisible to the oom killer.
> 
> Then, what are advantages with allowing only OOM victims access to memory
> reserves after they left exit_mm()?

Because they might need it in order to move on... Say you want to close
all the files which might release considerable amount of memory or any
other post exit_mm() resources.

> OOM victims might be waiting for locks
> at e.g. exit_task_work() held by non OOM victims waiting for memory
> allocation. If you change the OOM killer wait until existing OOM victims
> are removed from task_list, we might OOM livelock, don't we?

I didn't say the oom killer would wait for those victims to finish. We
have a per mm flag to tell the oom killer to skip over that task.

> I think that
> what we should do is make the OOM killer wait until MMF_OOM_REAPED is set
> rather than wait until existing OOM victims are removed from task_list.

Yes.

> Since we assume that mm_struct is the primary source of memory consumption,
> we don't select threads which already left exit_mm(). Since we assume that
> mm_struct is the primary source of memory consumption, why should we
> distinguish OOM victims and non OOM victims after they left exit_mm()?

Because we might prevent from pointless OOM killer selection that way.
If we know that the currently allocating task is an OOM victim then
giving it access to memory reserves is preferable to selecting another
oom victim.

> > Yes. the exit_mm is not really suitable place to cut the access to
> > memory reserves. a) mmput might be not the last one and b) even if it is
> > we shouldn't really rely it has cleared the memory. It will in 99% cases
> > but we have seen that the code had to play PF_EXITING tricks in the past
> > to cover post exit_mm allocations. I think the code flow would get
> > simplified greatly if we just do not rely on tsk->mm for anything but
> > the oom victim selection.
> 
> Even if exit_mm() is not suitable place to cut the access to memory reserves,
> I don't see advantages with allowing only OOM victims access to memory
> reserves after they left exit_mm().

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
