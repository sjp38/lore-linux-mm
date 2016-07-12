Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9686B0262
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 03:09:07 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so4090254lfw.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 00:09:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 19si1652412wmv.99.2016.07.12.00.09.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 00:09:05 -0700 (PDT)
Date: Tue, 12 Jul 2016 09:09:04 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/6] mm,oom: Use list of mm_struct used by OOM victims.
Message-ID: <20160712070903.GB14586@dhcp22.suse.cz>
References: <201607080058.BFI87504.JtFOOFQFVHSLOM@I-love.SAKURA.ne.jp>
 <201607080103.CDH12401.LFOHStQFOOFVJM@I-love.SAKURA.ne.jp>
 <20160711125051.GF1811@dhcp22.suse.cz>
 <201607121500.AGE04699.FFQOFHVSOtOLMJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607121500.AGE04699.FFQOFHVSOtOLMJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Tue 12-07-16 15:00:41, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > diff --git a/kernel/fork.c b/kernel/fork.c
> > > index 7926993..8e469e0 100644
> > > --- a/kernel/fork.c
> > > +++ b/kernel/fork.c
> > > @@ -722,6 +722,10 @@ static inline void __mmput(struct mm_struct *mm)
> > >  	}
> > >  	if (mm->binfmt)
> > >  		module_put(mm->binfmt->module);
> > > +#ifndef CONFIG_MMU
> > > +	if (mm->oom_mm.victim)
> > > +		exit_oom_mm(mm);
> > > +#endif
> > 
> > This ifdef is not really needed. There is no reason we should wait for
> > the oom_reaper to unlink the mm.
> 
> Oleg wanted to avoid adding OOM related hooks if possible
> ( http://lkml.kernel.org/r/20160705205231.GA25340@redhat.com ),
> but I thought that calling exit_oom_mm() from here is better for CONFIG_MMU=n case
> ( http://lkml.kernel.org/r/201607062043.FEC86485.JFFVLtFOQOSHMO@I-love.SAKURA.ne.jp ).

__mmput is a MM part of the exit path so I think sticking oom related
things there is not harmful. Yes we do take a global lock (btw. the lock
contention could be reduced if you preserve the existing spinlock and
use it for enqueing. Besides that the ifdef is really ugly.

> I think that not calling exit_oom_mm() from here is better for CONFIG_MMU=y case.
> Calling exit_oom_mm() from here will require !list_empty() check after holding
> oom_lock at oom_reaper(). Instead, we can do
> 
> +#ifdef CONFIG_MMU
> +	if (mm->oom_mm.victim)
> +		set_bit(MMF_OOM_REAPED, &mm->flags);
> +#else
> +	if (mm->oom_mm.victim)
> +		exit_oom_mm(mm);
> +#endif
> 
> here and let oom_has_pending_mm() check for MMF_OOM_REAPED.

Yes that would be possible but why should we make this more complicated
than necessary. It is natural that exit_oom_mm is called after the
address space has been torn down. This would be the most common path.
We have oom_reaper as a backup if this doesn't happen in time. It really
doesn't make much sense to keep mm on the list artificially if the
oom_reaper should just skip over it because it is already empty.
So please let's make it as simple as possible.

[...]
> > > @@ -653,6 +657,9 @@ subsys_initcall(oom_init)
> > >   */
> > >  void mark_oom_victim(struct task_struct *tsk)
> > >  {
> > > +	struct mm_struct *mm = tsk->mm;
> > > +	struct task_struct *old_tsk = mm->oom_mm.victim;
> > > +
> > >  	WARN_ON(oom_killer_disabled);
> > >  	/* OOM killer might race with memcg OOM */
> > >  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
> > > @@ -666,6 +673,18 @@ void mark_oom_victim(struct task_struct *tsk)
> > >  	 */
> > >  	__thaw_task(tsk);
> > >  	atomic_inc(&oom_victims);
> > > +	/*
> > > +	 * Since mark_oom_victim() is called from multiple threads,
> > > +	 * connect this mm to oom_mm_list only if not yet connected.
> > > +	 */
> > > +	get_task_struct(tsk);
> > > +	mm->oom_mm.victim = tsk;
> > > +	if (!old_tsk) {
> > > +		atomic_inc(&mm->mm_count);
> > > +		list_add_tail(&mm->oom_mm.list, &oom_mm_list);
> > > +	} else {
> > > +		put_task_struct(old_tsk);
> > > +	}
> > 
> > Isn't this overcomplicated? Why do we need to replace the old task by
> > the current one?
> 
> I'm not sure whether task_in_oom_domain(mm->oom_mm.victim, memcg, nodemask) in
> oom_has_pending_mm() will work as expected, especially when all threads in
> one thread group (which mm->oom_mm.victim belongs to) reached TASK_DEAD state.
> ( http://lkml.kernel.org/r/201607042150.CIB00512.FSOtMHLOOVFFQJ@I-love.SAKURA.ne.jp )
> 
> I guess that task_in_oom_domain() will return false, and that mm will be selected
> by another thread group (which mm->oom_mm.victim does not belongs to). Therefore,
> I think we need to replace the old task with the new task (at least when
> task_in_oom_domain() returned false) at mark_oom_victim().

Can we do that in a separate patch then. It would make this patch easier
to review and we can discuss about this corner case without distracting
from the main point of this patch series.

> If task_in_oom_domain(mm->oom_mm.victim, memcg, nodemask) in oom_has_pending_mm()
> does not work as expected even if we replace the old task with the new task at
> mark_oom_victim(), I think we after all need to use something like
> 
> struct task_struct {
> (...snipped...)
> +	struct mm_struct *oom_mm; /* current->mm as of getting TIF_MEMDIE */
> +	struct task_struct *oom_mm_list; /* Connected to oom_mm_list global list. */
> -#ifdef CONFIG_MMU
> -	struct task_struct *oom_reaper_list;
> -#endif
> (...snipped...)
> };
> 
> or your signal_struct->oom_mm approach.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
