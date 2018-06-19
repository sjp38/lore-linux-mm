Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B93D6B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 16:34:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x25-v6so370270pfn.21
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:34:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13-v6sor149750pgq.331.2018.06.19.13.34.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 13:34:03 -0700 (PDT)
Date: Tue, 19 Jun 2018 13:34:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: fix unnecessary killing of additional
 processes
In-Reply-To: <20180618172733.39322643725b196ff4e64703@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1806191314480.218079@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1805241422070.182300@chino.kir.corp.google.com> <alpine.DEB.2.21.1806141339580.4543@chino.kir.corp.google.com> <20180618172733.39322643725b196ff4e64703@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 18 Jun 2018, Andrew Morton wrote:

> > The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
> > it cannot reap an mm.  This can happen for a variety of reasons,
> > including:
> > 
> >  - the inability to grab mm->mmap_sem in a sufficient amount of time,
> > 
> >  - when the mm has blockable mmu notifiers that could cause the oom reaper
> >    to stall indefinitely,
> 
> Maybe we should have more than one oom reaper thread?  I assume the
> probability of the oom reaper thread blocking on an mmu notifier is
> small, so perhaps just dive in and hope for the best.  If the oom
> reaper gets stuck then there's another thread ready to take over.  And
> revisit the decision to use a kernel thread instead of workqueues.
> 

I'm not sure that we need more than one thread, per se, but we need the 
ability to operate on more than one oom victim while deciding whether one 
victim can be reaped or not.  The current implementation only processes 
one victim at a time: it tries to grab mm->mmap_sem, it sleeps, retries, 
sleeps, etc.  We need to try other oom victims (we do parallel memcg oom 
stress testing, and the oom reaper can uncharge memory to a hierarchy that 
prevents livelock as well), which my patch does.

> So what's actually happening here.  A process has a large amount of
> mlocked memory, it has been oom-killed and it is in the process of
> releasing its memory and exiting, yes?
> 

That's one failure mode, yes, and three possible ways:

 - the oom reaper immediately sets MMF_OOM_SKIP because it tried to free
   memory and completely failed, so it actually declares this as a success
   and sets MMF_OOM_SKIP assuming memory was freed, which wasn't,

 - to avoid CVE-2018-1000200 exit_mmap() must set MMF_OOM_SKIP before 
   doing munlock_vma_pages_all() which the oom reaper uses to determine if
   it can safely operate on a vma, so the exit path sets MMF_OOM_SKIP 
   before any possible memory freeing as well, and

 - the previous iteration of the oom reaper to set MMF_OOM_SKIP between
   unmap_vmas() and free_pgtables() suffered from the same problem for 
   large amounts of virtual memory whereas subsequent oom kill could have 
   been prevented if free_pgtables() could have completed.

My patch fixes all these issues because MMF_OOM_SKIP only gets set after 
free_pgtables(), i.e. no additional memory freeing is possible through 
exit_mmap(), or a process has failed to exit for 10s by the oom reaper.  I 
will patch this to make the timeout configurable.  I use the existing 
MMF_UNSTABLE to determine if the oom reaper can safely operate on vmas of 
the mm.

> If so, why does this task set MMF_OOM_SKIP on itself?  Why aren't we
> just patiently waiting for its attempt to release meory?
> 

That's what my patch does, yes, it needs to wait to ensure forward 
progress is not being made before setting MMF_OOM_SKIP and allowing all 
other processes on the system to be oom killed.  Taken to an extreme, 
imagine a single large mlocked process or one with a blockable mmu 
notifier taking up almost all memory on a machine.  If there is a memory 
leak, it will be oom killed same as it always has been.  The difference 
now is that the machine panic()'s because MMF_OOM_SKIP is set with no 
memory freeing and the oom killer finds no more eligible processes so its 
only alternative is panicking.

> > We can't simply defer setting MMF_OOM_SKIP, however, because if there is
> > a true oom livelock in progress, it never gets set and no additional
> > killing is possible.
> 
> I guess that's my answer.  What causes this livelock?  Process looping
> in alloc_pages while holding a lock the oom victim wants?
> 

That's one way, yes, the other is to be charging memory in the mem cgroup 
path while holding a mutex the victim wants.  If additional kmem will 
start being charged to mem cgroup hierarchies and the oom killer is called 
synchronously in the charge path (there is no fault path to unwind to), 
which has been discussed, this problem will become much more prolific.

> > The exit path will now set MMF_OOM_SKIP only after all memory has been
> > freed, so additional oom killing is justified,
> 
> That seems sensible, but why set MMF_OOM_SKIP at all?
> 

The oom reaper will eventually need to set it if its actually livelocked, 
which happens extremely rarely in practice, because the oom reaper was 
unable to free memory such that an allocator holding our mutex could 
successfully allocate.  It sets it immediately now for mlocked processes 
(it doesn't realize it didn't free a single page).  It retries 10 times to 
grab mm->mmap_sem and sets it after one second if it fails.  If it has a 
blockable mmu notifier it sleeps for a second and sets it.  I'm replacing 
all the current timeouts with a per-mm timeout and volunteering to make it 
configurable so that it can be disabled or set to 10s as preferred by us 
because we are tired of every process getting oom killed pointlessly.  
I'll suggest a default of 1s to match the timeouts currently implemented 
in the oom reaper and generalize them to be per-mm.

> > and rely on MMF_UNSTABLE to
> > determine when it can race with the oom reaper.
> > 
> > The oom reaper will now set MMF_OOM_SKIP only after the reap timeout has
> > lapsed because it can no longer guarantee forward progress.
> > 
> > The reaping timeout is intentionally set for a substantial amount of time
> > since oom livelock is a very rare occurrence and it's better to optimize
> > for preventing additional (unnecessary) oom killing than a scenario that
> > is much more unlikely.
> 
> What happened to the old idea of permitting the task which is blocking
> the oom victim to access additional reserves?
> 

That is an alternative to the oom reaper and worked quite successfully for 
us.  We'd detect when a process was looping endlessly waiting for the same 
victim to exit and then grant it access to additional reserves, 
specifically to detect oom livelock scenarios.  The oom reaper should 
theoretically make this extremely rare since it normally can free *some* 
memory so we aren't oom anymore and allocators holding mutexes can 
succeed.

> > +#ifdef CONFIG_MMU
> > +	/* When to give up on oom reaping this mm */
> > +	unsigned long reap_timeout;
> 
> "timeout" implies "interval".  To me, anyway.  This is an absolute
> time, so something like reap_time would be clearer.  Along with a
> comment explaining that the units are in jiffies.
> 

Ack.

> > +#endif
> >  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
> >  	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
> >  #endif
> > diff --git a/include/linux/sched.h b/include/linux/sched.h
> > --- a/include/linux/sched.h
> > +++ b/include/linux/sched.h
> > @@ -1163,7 +1163,7 @@ struct task_struct {
> >  #endif
> >  	int				pagefault_disabled;
> >  #ifdef CONFIG_MMU
> > -	struct task_struct		*oom_reaper_list;
> > +	struct list_head		oom_reap_list;
> 
> Can we have a comment explaining its locking.
> 

Ok.

> >  #endif
> >  #ifdef CONFIG_VMAP_STACK
> >  	struct vm_struct		*stack_vm_area;
> >
> > ...
> >
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -3059,11 +3059,10 @@ void exit_mmap(struct mm_struct *mm)
> >  	if (unlikely(mm_is_oom_victim(mm))) {
> >  		/*
> >  		 * Manually reap the mm to free as much memory as possible.
> > -		 * Then, as the oom reaper does, set MMF_OOM_SKIP to disregard
> > -		 * this mm from further consideration.  Taking mm->mmap_sem for
> > -		 * write after setting MMF_OOM_SKIP will guarantee that the oom
> > -		 * reaper will not run on this mm again after mmap_sem is
> > -		 * dropped.
> > +		 * Then, set MMF_UNSTABLE to avoid racing with the oom reaper.
> > +		 * Taking mm->mmap_sem for write after setting MMF_UNSTABLE will
> > +		 * guarantee that the oom reaper will not run on this mm again
> > +		 * after mmap_sem is dropped.
> 
> Comment should explain *why* we don't want the reaper to run on this mm
> again.
> 

Sounds good.
