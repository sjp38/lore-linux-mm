Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6557F6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 04:48:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b65so73087692wmg.0
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 01:48:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cm17si13864807wjb.239.2016.07.25.01.48.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 25 Jul 2016 01:48:04 -0700 (PDT)
Date: Mon, 25 Jul 2016 10:48:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
Message-ID: <20160725084803.GE9401@dhcp22.suse.cz>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160721112140.GG26379@dhcp22.suse.cz>
 <201607222009.DII64068.VHMSQJtOOFOLFF@I-love.SAKURA.ne.jp>
 <20160722120519.GJ794@dhcp22.suse.cz>
 <201607231159.IFD26547.HVMOQtSJFOFFOL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607231159.IFD26547.HVMOQtSJFOFFOL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Sat 23-07-16 11:59:25, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > Now what about future plans? I would like to get rid of TIF_MEMDIE
> > > > altogether and give access to memory reserves to oom victim when they
> > > > allocate the memory. Something like:
> > > 
> > > Before doing so, can we handle a silent hang up caused by lowmem livelock
> > > at http://lkml.kernel.org/r/20160211225929.GU14668@dastard ? It is a nearly
> > > 7 years old bug (since commit 35cd78156c499ef8 "vmscan: throttle direct
> > > reclaim when too many pages are isolated already") which got no progress
> > > so far.
> > 
> > I do not see any dependecy/relation on/to the OOM work. I am even not
> > sure why you are bringing that up here.
> 
> This is a ABBA deadlock bug which disables the OOM killer caused by kswapd
> waiting for GFP_NOIO allocations whereas GFP_NOIO allocations waiting for
> kswapd. A flag like GFP_TRANSIENT suggested at
> http://lkml.kernel.org/r/878twt5i1j.fsf@notabene.neil.brown.name which
> prevents the allocating task from being throttled is expected if we want to
> avoid escaping from too_many_isolated() loop in shrink_inactive_list()
> using timeout.

But this is completely irrelevant to _this_ particular discussion so I
really fail to see why you keep bringing it up. It is definitely not
helping to move on...

> > [...]
> > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > index 788e4f22e0bb..34446f49c2e1 100644
> > > > --- a/mm/page_alloc.c
> > > > +++ b/mm/page_alloc.c
> > > > @@ -3358,7 +3358,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> > > >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > > >  		else if (!in_interrupt() &&
> > > >  				((current->flags & PF_MEMALLOC) ||
> > > > -				 unlikely(test_thread_flag(TIF_MEMDIE))))
> > > > +				 tsk_is_oom_victim(current))
> > > >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > > >  	}
> > > >  #ifdef CONFIG_CMA
> > > > 
> > > > where tsk_is_oom_victim wouldn't require the given task to go via
> > > > out_of_memory. This would solve some of the problems we have right now
> > > > when a thread doesn't get access to memory reserves because it never
> > > > reaches out_of_memory (e.g. recently mentioned mempool_alloc doing
> > > > __GFP_NORETRY). It would also make the code easier to follow. If we want
> > > > to implement that we need an easy to implement tsk_is_oom_victim
> > > > obviously. With the signal_struct::oom_mm this is really trivial thing.
> > > > I am not sure we can do that with the mm list though because we are
> > > > loosing the task->mm at certain point in time.
> > > 
> > > bool tsk_is_oom_victim(void)
> > > {
> > > 	return current->mm && test_bit(MMF_OOM_KILLED, &current->mm->flags) &&
> > > 		 (fatal_signal_pending(current) || (current->flags & PF_EXITING));
> > > }
> > 
> > which doesn't work as soon as exit_mm clears the mm which is exactly
> > the concern I have raised above.
> 
> Are you planning to change the scope where the OOM victims can access memory
> reserves?

Yes. Because we know that there are some post exit_mm allocations and I
do not want to get back to PF_EXITING and other tricks...

> (1) If you plan to allow the OOM victims to access memory reserves until
>     TASK_DEAD, tsk_is_oom_victim() will be as trivial as
> 
> bool tsk_is_oom_victim(struct task_struct *task)
> {
> 	return task->signal->oom_mm;
> }

yes, exactly. That's what I've tried to say above. with the oom_mm this
is trivial to implement while mm lists will not help us much due to
their life time. This also means that we know about the oom victim until
it is unhashed and become invisible to the oom killer.

>     because you won't prevent the OOM victims to access memory reserves at
>     e.g. exit_task_work() from do_exit(). In that case, I will suggest
> 
> bool tsk_is_oom_victim(struct task_struct *task)
> {
> 	return (fatal_signal_pending(task) || (task->flags & PF_EXITING));
> }

No. This will cover any SIGKILLED or exiting task. I really do not think
we can safely give exiting tasks access to memory reserves in general.
That would require much more changes.

>     like "[PATCH 2/3] mm,page_alloc: favor exiting tasks over normal tasks."
>     does.
> 
> (2) If you plan to allow the OOM victims to access memory reserves until only
>     before calling mmput() from exit_mm() from do_exit(), tsk_is_oom_victim()
>     will be
> 
> bool tsk_is_oom_victim(struct task_struct *task)
> {
> 	return task->signal->oom_mm && task->mm;
> }
> 
>     because you don't allow the OOM victims to access memory reserves at
>     __mmput() from mmput() from exit_mm() from do_exit(). In that case, I think
> 
> bool tsk_is_oom_victim(void)
> {
> 	return current->mm && test_bit(MMF_OOM_KILLED, &current->mm->flags) &&
> 		(fatal_signal_pending(current) || (current->flags & PF_EXITING));
> }
> 
>     should work. But as you think it does not work, you are not planning to
>     allow the OOM victims to access memory reserves until only before calling
>     mmput() from exit_mm() from do_exit(), are you?

Yes. the exit_mm is not really suitable place to cut the access to
memory reserves. a) mmput might be not the last one and b) even if it is
we shouldn't really rely it has cleared the memory. It will in 99% cases
but we have seen that the code had to play PF_EXITING tricks in the past
to cover post exit_mm allocations. I think the code flow would get
simplified greatly if we just do not rely on tsk->mm for anything but
the oom victim selection.

> (3) If you are not planning to change the scope where the OOM victims can access
>     memory reserves (i.e. neither (1) nor (2) above), how can we control it
>     without using per task_struct flags like TIF_MEMDIE?
> 
> > 
> > > 
> > > >                                                The only way I can see
> > > > this would fly would be preserving TIF_MEMDIE and setting it for all
> > > > threads but I am not sure this is very much better and puts the mm list
> > > > approach to a worse possition from my POV.
> > > > 
> > > 
> > > But do we still need ALLOC_NO_WATERMARKS for OOM victims?
> > 
> > Yes as a safety net for cases when the oom_reaper cannot reclaim enough
> > to get us out of OOM. Maybe one day we can make the oom_reaper
> > completely bullet proof and granting access to memory reserves would be
> > pointless. One reason I want to get rid of TIF_MEMDIE is that all would
> > need to do at that time would be a single line dropping
> > tsk_is_oom_victim from gfp_to_alloc_flags.
> 
> I didn't mean to forbid access to memory reserves completely. I meant that
> do we need to allow access to all of memory reserves (via ALLOC_NO_WATERMARKS)
> rather than portion of memory reserves (via ALLOC_HARDER like [PATCH 2/3] does).
> I'm thinking that we can treat "threads killed by the OOM killer" and "threads
> killed by SIGKILL" and "threads normally exiting via exit()" evenly by allowing
> them access to portion of memory reserves.

I didn't plan to change how much from the memory reserve the victim can
consume. And I believe this is not really necessary at this stage. Maybe
we want to do something about it but I would propose it to later. At
this stage I would really like to make access to memory reserves
independent on any other oom decisions. So either mm lists or
signal::oom_mm approach. Can we get to some decision which one to go?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
