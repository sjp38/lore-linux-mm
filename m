Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 263DB60080F
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 20:53:38 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id o7O0rgZI020851
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 17:53:49 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by hpaq2.eem.corp.google.com with ESMTP id o7O0re7F007470
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 17:53:40 -0700
Received: by pzk4 with SMTP id 4so2801499pzk.21
        for <linux-mm@kvack.org>; Mon, 23 Aug 2010 17:53:39 -0700 (PDT)
Date: Mon, 23 Aug 2010 17:53:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/3 v3] oom: add per-mm oom disable count
In-Reply-To: <20100823161302.e4378ca0.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1008231724130.19474@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com> <20100823161302.e4378ca0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 23 Aug 2010, Andrew Morton wrote:

> > --- a/fs/proc/base.c
> > +++ b/fs/proc/base.c
> > @@ -1047,6 +1047,21 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
> >  		return -EACCES;
> >  	}
> >  
> > +	task_lock(task);
> > +	if (!task->mm) {
> > +		task_unlock(task);
> > +		unlock_task_sighand(task, &flags);
> > +		put_task_struct(task);
> > +		return -EINVAL;
> > +	}
> > +
> > +	if (oom_adjust != task->signal->oom_adj) {
> > +		if (oom_adjust == OOM_DISABLE)
> > +			atomic_inc(&task->mm->oom_disable_count);
> > +		if (task->signal->oom_adj == OOM_DISABLE)
> > +			atomic_dec(&task->mm->oom_disable_count);
> > +	}
> 
> scary function.  Wanna try converting oom_adjust_write() to the
> single-exit-with-goto model sometime, see if the result looks more
> maintainable?
> 

Ok, that would certainly be better.

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
> 
> So in fork() we zap this if !CLONE_VM?  Was the CLONE_VM case tested
> nicely?
> 

In clone(), yeah, fork() doesn't use CLONE_VM so the child thread will 
always have a different ->mm.  The new ->mm will get oom_disable_count 
incremented later if tsk has inherited a OOM_DISABLE value.

We've been running with this patch (minus the sys_unshare() code I added) 
for a year now internally.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
