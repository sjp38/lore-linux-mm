Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 918DA6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 17:07:27 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [10.3.21.11])
	by smtp-out.google.com with ESMTP id o2VL7MoL005589
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 23:07:22 +0200
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by hpaq11.eem.corp.google.com with ESMTP id o2VL7KcM026642
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 23:07:21 +0200
Received: by pzk27 with SMTP id 27so681366pzk.2
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:07:20 -0700 (PDT)
Date: Wed, 31 Mar 2010 14:07:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
 been killed
In-Reply-To: <20100331175836.GA11635@redhat.com>
Message-ID: <alpine.DEB.2.00.1003311342410.25284@chino.kir.corp.google.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com>
 <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com>
 <20100331175836.GA11635@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, Oleg Nesterov wrote:

> On 03/30, David Rientjes wrote:
> >
> > On Tue, 30 Mar 2010, Oleg Nesterov wrote:
> >
> > > Note that __oom_kill_task() does force_sig(SIGKILL) which assumes that
> > > ->sighand != NULL. This is not true if out_of_memory() is called after
> > > current has already passed exit_notify().
> >
> > We have an even bigger problem if current is in the oom killer at
> > exit_notify() since it has already detached its ->mm in exit_mm() :)
> 
> Can't understand... I thought that in theory even kmalloc(1) can trigger
> oom.
> 

__oom_kill_task() cannot be called on a task without an ->mm.

> > > IOW, unless I missed something, it is very easy to hide the process
> > > from oom-kill:
> > >
> > > 	int main()
> > > 	{
> > > 		pthread_create(memory_hog_func);
> > > 		syscall(__NR_exit);
> > > 	}
> > >
> >
> > The check for !p->mm was moved in the -mm tree (and the oom killer was
> > entirely rewritten in that tree, so I encourage you to work off of it
> > instead
> 
> OK, but I guess this !p->mm check is still wrong for the same reason.
> In fact I do not understand why it is needed in select_bad_process()
> right before oom_badness() which checks ->mm too (and this check is
> equally wrong).
> 

It prevents kthreads from being killed.  We already identify tasks that 
are in the exit path with PF_EXITING in select_bad_process() and chosen to 
make the oom killer a no-op when it's not current so it can exit and free 
its memory.  If it is current, then we're ooming in the exit path and we 
need to oom kill it so that it gets access to memory reserves so its no 
longer blocking.

> > so if the oom killer finds an already exiting task,
> > it will become a no-op since it should eventually free memory and avoids a
> > needless oom kill.
> 
> No, afaics, And this reminds that I already complained about this
> PF_EXITING check.
> 
> Once again, p is the group leader. It can be dead (no ->mm, PF_EXITING
> is set) but it can have sub-threads. This means, unless I missed something,
> any user can trivially disable select_bad_process() forever.
> 

The task is in the process of exiting and will do so if its not current, 
otherwise it will get access to memory reserves since we're obviously oom 
in the exit path.  Thus, we'll be freeing that memory soon or recalling 
the oom killer to kill additional tasks once those children have been 
reparented (or one of its children was sacrificed).

> 
> Well. Looks like, -mm has a lot of changes in oom_kill.c. Perhaps it
> would be better to fix these mt bugs first...
> 
> Say, oom_forkbomb_penalty() does list_for_each_entry(tsk->children).
> Again, this is not right even if we forget about !child->mm check.
> This list_for_each_entry() can only see the processes forked by the
> main thread.
>

That's the intention.
 
> Likewise, oom_kill_process()->list_for_each_entry() is not right too.
> 

Why?

> Hmm. Why oom_forkbomb_penalty() does thread_group_cputime() under
> task_lock() ? It seems, ->alloc_lock() is only needed for get_mm_rss().
> 

Right, but we need to ensure that the check for !child->mm || child->mm == 
tsk->mm fails before adding in get_mm_rss(child->mm).  It can race and 
detach its mm prior to the dereference.  It would be possible to move the 
thread_group_cputime() out of this critical section, but I felt it was 
better to do filter all tasks with child->mm == tsk->mm first before 
unnecessarily finding the cputime for them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
