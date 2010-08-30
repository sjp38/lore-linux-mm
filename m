Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E2F486B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 17:14:50 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id o7ULEldu001847
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 14:14:47 -0700
Received: from pxi4 (pxi4.prod.google.com [10.243.27.4])
	by wpaz1.hot.corp.google.com with ESMTP id o7ULEhOB029554
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 14:14:46 -0700
Received: by pxi4 with SMTP id 4so2422956pxi.8
        for <linux-mm@kvack.org>; Mon, 30 Aug 2010 14:14:43 -0700 (PDT)
Date: Mon, 30 Aug 2010 14:14:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/3 v3] oom: add per-mm oom disable count
In-Reply-To: <20100830130913.525F.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008301409040.4852@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com> <20100830130913.525F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Aug 2010, KOSAKI Motohiro wrote:

> > diff --git a/fs/exec.c b/fs/exec.c
> > --- a/fs/exec.c
> > +++ b/fs/exec.c
> > @@ -54,6 +54,7 @@
> >  #include <linux/fsnotify.h>
> >  #include <linux/fs_struct.h>
> >  #include <linux/pipe_fs_i.h>
> > +#include <linux/oom.h>
> >  
> >  #include <asm/uaccess.h>
> >  #include <asm/mmu_context.h>
> > @@ -745,6 +746,10 @@ static int exec_mmap(struct mm_struct *mm)
> >  	tsk->mm = mm;
> >  	tsk->active_mm = mm;
> >  	activate_mm(active_mm, mm);
> > +	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > +		atomic_dec(&active_mm->oom_disable_count);
> 
> When kernel thread makes user-land process (e.g. usermode-helper),
> active_mm might point to unrelated process. active_mm is only meaningful
> for scheduler code. please don't touch it. probably you intend to
> change old_mm.
> 

This is safe because kthreads never have non-zero 
p->signal->oom_score_adj.

> > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -310,6 +310,8 @@ struct mm_struct {
> >  #ifdef CONFIG_MMU_NOTIFIER
> >  	struct mmu_notifier_mm *mmu_notifier_mm;
> >  #endif
> > +	/* How many tasks sharing this mm are OOM_DISABLE */
> > +	atomic_t oom_disable_count;
> >  };
> >  
> >  /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
> > diff --git a/kernel/exit.c b/kernel/exit.c
> > --- a/kernel/exit.c
> > +++ b/kernel/exit.c
> > @@ -50,6 +50,7 @@
> >  #include <linux/perf_event.h>
> >  #include <trace/events/sched.h>
> >  #include <linux/hw_breakpoint.h>
> > +#include <linux/oom.h>
> >  
> >  #include <asm/uaccess.h>
> >  #include <asm/unistd.h>
> > @@ -689,6 +690,8 @@ static void exit_mm(struct task_struct * tsk)
> >  	enter_lazy_tlb(mm, current);
> >  	/* We don't want this task to be frozen prematurely */
> >  	clear_freeze_flag(tsk);
> > +	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +		atomic_dec(&mm->oom_disable_count);
> >  	task_unlock(tsk);
> >  	mm_update_next_owner(mm);
> >  	mmput(mm);
> > diff --git a/kernel/fork.c b/kernel/fork.c
> > --- a/kernel/fork.c
> > +++ b/kernel/fork.c
> > @@ -65,6 +65,7 @@
> >  #include <linux/perf_event.h>
> >  #include <linux/posix-timers.h>
> >  #include <linux/user-return-notifier.h>
> > +#include <linux/oom.h>
> >  
> >  #include <asm/pgtable.h>
> >  #include <asm/pgalloc.h>
> > @@ -485,6 +486,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
> >  	mm->cached_hole_size = ~0UL;
> >  	mm_init_aio(mm);
> >  	mm_init_owner(mm, p);
> > +	atomic_set(&mm->oom_disable_count, 0);
> >  
> >  	if (likely(!mm_alloc_pgd(mm))) {
> >  		mm->def_flags = 0;
> > @@ -738,6 +740,8 @@ good_mm:
> >  	/* Initializing for Swap token stuff */
> >  	mm->token_priority = 0;
> >  	mm->last_interval = 0;
> > +	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +		atomic_inc(&mm->oom_disable_count);
> >  
> >  	tsk->mm = mm;
> >  	tsk->active_mm = mm;
> > @@ -1296,8 +1300,11 @@ bad_fork_cleanup_io:
> >  bad_fork_cleanup_namespaces:
> >  	exit_task_namespaces(p);
> >  bad_fork_cleanup_mm:
> > -	if (p->mm)
> > +	if (p->mm) {
> > +		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +			atomic_dec(&p->mm->oom_disable_count);
> >  		mmput(p->mm);
> > +	}
> 
> This place, we don't have any lock. so, checking signal->oom_score_adj and
> change oom_disable_count seems inatomic.
> 

Ah, true, we need task_lock(p) around the conditional, thanks.

> >  bad_fork_cleanup_signal:
> >  	if (!(clone_flags & CLONE_THREAD))
> >  		free_signal_struct(p->signal);
> > @@ -1690,6 +1697,10 @@ SYSCALL_DEFINE1(unshare, unsigned long, unshare_flags)
> >  			active_mm = current->active_mm;
> >  			current->mm = new_mm;
> >  			current->active_mm = new_mm;
> > +			if (current->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> > +				atomic_dec(&mm->oom_disable_count);
> > +				atomic_inc(&new_mm->oom_disable_count);
> > +			}
> >  			activate_mm(active_mm, new_mm);
> >  			new_mm = mm;
> >  		}
> 
> This place, we are grabbing task_lock(), but task_lock don't prevent
> to change signal->oom_score_adj from another thread. This seems racy.
> 

It does, task_lock(current) protects current->signal->oom_score_adj from 
changing in oom-add-per-mm-oom-disable-count.patch.

I'll add the task_lock(p) in mm_init(), thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
