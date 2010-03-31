Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9988A6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 18:52:24 -0400 (EDT)
Date: Thu, 1 Apr 2010 00:50:11 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
	been killed
Message-ID: <20100331224904.GA4025@redhat.com>
References: <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <alpine.DEB.2.00.1003311342410.25284@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003311342410.25284@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/31, David Rientjes wrote:
>
> On Wed, 31 Mar 2010, Oleg Nesterov wrote:
>
> > On 03/30, David Rientjes wrote:
> > >
> > > On Tue, 30 Mar 2010, Oleg Nesterov wrote:
> > >
> > > > Note that __oom_kill_task() does force_sig(SIGKILL) which assumes that
> > > > ->sighand != NULL. This is not true if out_of_memory() is called after
> > > > current has already passed exit_notify().
> > >
> > > We have an even bigger problem if current is in the oom killer at
> > > exit_notify() since it has already detached its ->mm in exit_mm() :)
> >
> > Can't understand... I thought that in theory even kmalloc(1) can trigger
> > oom.
>
> __oom_kill_task() cannot be called on a task without an ->mm.

Why? You ignored this part:

	Say, right after exit_mm() we are doing acct_process(), and f_op->write()
	needs a page. So, you are saying that in this case __page_cache_alloc()
	can never trigger out_of_memory() ?

why this is not possible?

David, I am not arguing, I am asking.

> > > The check for !p->mm was moved in the -mm tree (and the oom killer was
> > > entirely rewritten in that tree, so I encourage you to work off of it
> > > instead
> >
> > OK, but I guess this !p->mm check is still wrong for the same reason.
> > In fact I do not understand why it is needed in select_bad_process()
> > right before oom_badness() which checks ->mm too (and this check is
> > equally wrong).
>
> It prevents kthreads from being killed.

No it doesn't, see use_mm(). See also another email I sent.

> > > so if the oom killer finds an already exiting task,
> > > it will become a no-op since it should eventually free memory and avoids a
> > > needless oom kill.
> >
> > No, afaics, And this reminds that I already complained about this
> > PF_EXITING check.
> >
> > Once again, p is the group leader. It can be dead (no ->mm, PF_EXITING
> > is set) but it can have sub-threads. This means, unless I missed something,
> > any user can trivially disable select_bad_process() forever.
> >
>
> The task is in the process of exiting and will do so if its not current,
> otherwise it will get access to memory reserves since we're obviously oom
> in the exit path.  Thus, we'll be freeing that memory soon or recalling
> the oom killer to kill additional tasks once those children have been
> reparented (or one of its children was sacrificed).

Just can't understand.

OK, a bad user does

	int sleep_forever(void *)
	{
		pause();
	}

	int main(void)
	{
		pthread_create(sleep_forever);
		syscall(__NR_exit);
	}

Now, every time select_bad_process() is called it will find this process
and PF_EXITING is true, so it just returns ERR_PTR(-1UL). And note that
this process is not going to exit.

> > Say, oom_forkbomb_penalty() does list_for_each_entry(tsk->children).
> > Again, this is not right even if we forget about !child->mm check.
> > This list_for_each_entry() can only see the processes forked by the
> > main thread.
> >
>
> That's the intention.

Why? shouldn't oom_badness() return the same result for any thread
in thread group? We should take all childs into account.

> > Likewise, oom_kill_process()->list_for_each_entry() is not right too.
> >
>
> Why?
>
> > Hmm. Why oom_forkbomb_penalty() does thread_group_cputime() under
> > task_lock() ? It seems, ->alloc_lock() is only needed for get_mm_rss().
> >
>
> Right, but we need to ensure that the check for !child->mm || child->mm ==
> tsk->mm fails before adding in get_mm_rss(child->mm).  It can race and
> detach its mm prior to the dereference.

Oh, yes sure, I mentioned get_mm_rss() above.

> It would be possible to move the
> thread_group_cputime() out of this critical section,

Yes, this is what I meant.

> but I felt it was
> better to do filter all tasks with child->mm == tsk->mm first before
> unnecessarily finding the cputime for them.

Yes, but we can check child->mm == tsk->mm, call get_mm_counter() and drop
task_lock().

Oleg.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
