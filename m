Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 989AE6B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 14:00:38 -0400 (EDT)
Date: Wed, 31 Mar 2010 19:58:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
	been killed
Message-ID: <20100331175836.GA11635@redhat.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/30, David Rientjes wrote:
>
> On Tue, 30 Mar 2010, Oleg Nesterov wrote:
>
> > Note that __oom_kill_task() does force_sig(SIGKILL) which assumes that
> > ->sighand != NULL. This is not true if out_of_memory() is called after
> > current has already passed exit_notify().
>
> We have an even bigger problem if current is in the oom killer at
> exit_notify() since it has already detached its ->mm in exit_mm() :)

Can't understand... I thought that in theory even kmalloc(1) can trigger
oom.

Say, right after exit_mm() we are doing acct_process(), and f_op->write()
needs a page. So, you are saying that in this case __page_cache_alloc()
can never trigger out_of_memory() ?

> > IOW, unless I missed something, it is very easy to hide the process
> > from oom-kill:
> >
> > 	int main()
> > 	{
> > 		pthread_create(memory_hog_func);
> > 		syscall(__NR_exit);
> > 	}
> >
>
> The check for !p->mm was moved in the -mm tree (and the oom killer was
> entirely rewritten in that tree, so I encourage you to work off of it
> instead

OK, but I guess this !p->mm check is still wrong for the same reason.
In fact I do not understand why it is needed in select_bad_process()
right before oom_badness() which checks ->mm too (and this check is
equally wrong).

> with
> oom-avoid-race-for-oom-killed-tasks-detaching-mm-prior-to-exit.patch to
> even after the check for PF_EXITING.  This is set in the exit path before
> the ->mm is detached

Yes. Then I do not understand "if (!p->mm)" completely.

> so if the oom killer finds an already exiting task,
> it will become a no-op since it should eventually free memory and avoids a
> needless oom kill.

No, afaics, And this reminds that I already complained about this
PF_EXITING check.

Once again, p is the group leader. It can be dead (no ->mm, PF_EXITING
is set) but it can have sub-threads. This means, unless I missed something,
any user can trivially disable select_bad_process() forever.


Well. Looks like, -mm has a lot of changes in oom_kill.c. Perhaps it
would be better to fix these mt bugs first...

Say, oom_forkbomb_penalty() does list_for_each_entry(tsk->children).
Again, this is not right even if we forget about !child->mm check.
This list_for_each_entry() can only see the processes forked by the
main thread.

Likewise, oom_kill_process()->list_for_each_entry() is not right too.

Hmm. Why oom_forkbomb_penalty() does thread_group_cputime() under
task_lock() ? It seems, ->alloc_lock() is only needed for get_mm_rss().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
