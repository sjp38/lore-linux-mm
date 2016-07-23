Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 95B176B0253
	for <linux-mm@kvack.org>; Fri, 22 Jul 2016 22:59:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b62so119524304pfa.2
        for <linux-mm@kvack.org>; Fri, 22 Jul 2016 19:59:42 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id b1si19280211pfk.262.2016.07.22.19.59.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Jul 2016 19:59:41 -0700 (PDT)
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468330163-4405-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160721112140.GG26379@dhcp22.suse.cz>
	<201607222009.DII64068.VHMSQJtOOFOLFF@I-love.SAKURA.ne.jp>
	<20160722120519.GJ794@dhcp22.suse.cz>
In-Reply-To: <20160722120519.GJ794@dhcp22.suse.cz>
Message-Id: <201607231159.IFD26547.HVMOQtSJFOFFOL@I-love.SAKURA.ne.jp>
Date: Sat, 23 Jul 2016 11:59:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

Michal Hocko wrote:
> > > Now what about future plans? I would like to get rid of TIF_MEMDIE
> > > altogether and give access to memory reserves to oom victim when they
> > > allocate the memory. Something like:
> > 
> > Before doing so, can we handle a silent hang up caused by lowmem livelock
> > at http://lkml.kernel.org/r/20160211225929.GU14668@dastard ? It is a nearly
> > 7 years old bug (since commit 35cd78156c499ef8 "vmscan: throttle direct
> > reclaim when too many pages are isolated already") which got no progress
> > so far.
> 
> I do not see any dependecy/relation on/to the OOM work. I am even not
> sure why you are bringing that up here.

This is a ABBA deadlock bug which disables the OOM killer caused by kswapd
waiting for GFP_NOIO allocations whereas GFP_NOIO allocations waiting for
kswapd. A flag like GFP_TRANSIENT suggested at
http://lkml.kernel.org/r/878twt5i1j.fsf@notabene.neil.brown.name which
prevents the allocating task from being throttled is expected if we want to
avoid escaping from too_many_isolated() loop in shrink_inactive_list()
using timeout.

> [...]
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 788e4f22e0bb..34446f49c2e1 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -3358,7 +3358,7 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> > >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > >  		else if (!in_interrupt() &&
> > >  				((current->flags & PF_MEMALLOC) ||
> > > -				 unlikely(test_thread_flag(TIF_MEMDIE))))
> > > +				 tsk_is_oom_victim(current))
> > >  			alloc_flags |= ALLOC_NO_WATERMARKS;
> > >  	}
> > >  #ifdef CONFIG_CMA
> > > 
> > > where tsk_is_oom_victim wouldn't require the given task to go via
> > > out_of_memory. This would solve some of the problems we have right now
> > > when a thread doesn't get access to memory reserves because it never
> > > reaches out_of_memory (e.g. recently mentioned mempool_alloc doing
> > > __GFP_NORETRY). It would also make the code easier to follow. If we want
> > > to implement that we need an easy to implement tsk_is_oom_victim
> > > obviously. With the signal_struct::oom_mm this is really trivial thing.
> > > I am not sure we can do that with the mm list though because we are
> > > loosing the task->mm at certain point in time.
> > 
> > bool tsk_is_oom_victim(void)
> > {
> > 	return current->mm && test_bit(MMF_OOM_KILLED, &current->mm->flags) &&
> > 		 (fatal_signal_pending(current) || (current->flags & PF_EXITING));
> > }
> 
> which doesn't work as soon as exit_mm clears the mm which is exactly
> the concern I have raised above.

Are you planning to change the scope where the OOM victims can access memory
reserves?

(1) If you plan to allow the OOM victims to access memory reserves until
    TASK_DEAD, tsk_is_oom_victim() will be as trivial as

bool tsk_is_oom_victim(struct task_struct *task)
{
	return task->signal->oom_mm;
}

    because you won't prevent the OOM victims to access memory reserves at
    e.g. exit_task_work() from do_exit(). In that case, I will suggest

bool tsk_is_oom_victim(struct task_struct *task)
{
	return (fatal_signal_pending(task) || (task->flags & PF_EXITING));
}

    like "[PATCH 2/3] mm,page_alloc: favor exiting tasks over normal tasks."
    does.

(2) If you plan to allow the OOM victims to access memory reserves until only
    before calling mmput() from exit_mm() from do_exit(), tsk_is_oom_victim()
    will be

bool tsk_is_oom_victim(struct task_struct *task)
{
	return task->signal->oom_mm && task->mm;
}

    because you don't allow the OOM victims to access memory reserves at
    __mmput() from mmput() from exit_mm() from do_exit(). In that case, I think

bool tsk_is_oom_victim(void)
{
	return current->mm && test_bit(MMF_OOM_KILLED, &current->mm->flags) &&
		(fatal_signal_pending(current) || (current->flags & PF_EXITING));
}

    should work. But as you think it does not work, you are not planning to
    allow the OOM victims to access memory reserves until only before calling
    mmput() from exit_mm() from do_exit(), are you?

(3) If you are not planning to change the scope where the OOM victims can access
    memory reserves (i.e. neither (1) nor (2) above), how can we control it
    without using per task_struct flags like TIF_MEMDIE?

> 
> > 
> > >                                                The only way I can see
> > > this would fly would be preserving TIF_MEMDIE and setting it for all
> > > threads but I am not sure this is very much better and puts the mm list
> > > approach to a worse possition from my POV.
> > > 
> > 
> > But do we still need ALLOC_NO_WATERMARKS for OOM victims?
> 
> Yes as a safety net for cases when the oom_reaper cannot reclaim enough
> to get us out of OOM. Maybe one day we can make the oom_reaper
> completely bullet proof and granting access to memory reserves would be
> pointless. One reason I want to get rid of TIF_MEMDIE is that all would
> need to do at that time would be a single line dropping
> tsk_is_oom_victim from gfp_to_alloc_flags.

I didn't mean to forbid access to memory reserves completely. I meant that
do we need to allow access to all of memory reserves (via ALLOC_NO_WATERMARKS)
rather than portion of memory reserves (via ALLOC_HARDER like [PATCH 2/3] does).
I'm thinking that we can treat "threads killed by the OOM killer" and "threads
killed by SIGKILL" and "threads normally exiting via exit()" evenly by allowing
them access to portion of memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
