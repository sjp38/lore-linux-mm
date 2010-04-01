Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D60AB6B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 11:28:42 -0400 (EDT)
Date: Thu, 1 Apr 2010 17:26:38 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch] oom: give current access to memory reserves if it has
	been killed
Message-ID: <20100401152638.GC14603@redhat.com>
References: <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330154659.GA12416@redhat.com> <alpine.DEB.2.00.1003301320020.5234@chino.kir.corp.google.com> <20100331175836.GA11635@redhat.com> <alpine.DEB.2.00.1003311342410.25284@chino.kir.corp.google.com> <20100331224904.GA4025@redhat.com> <alpine.DEB.2.00.1004010044320.6285@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004010044320.6285@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 04/01, David Rientjes wrote:
>
> On Thu, 1 Apr 2010, Oleg Nesterov wrote:
>
> > Why? You ignored this part:
> >
> > 	Say, right after exit_mm() we are doing acct_process(), and f_op->write()
> > 	needs a page. So, you are saying that in this case __page_cache_alloc()
> > 	can never trigger out_of_memory() ?
> >
> > why this is not possible?
> >
>
> It can, but the check for p->mm is sufficient since exit_notify()

Yes, but I meant out_of_memory()->__oom_kill_task(current). OK, we
already discussed this in the previous emails.

> We cannot rely on oom_badness() to filter this task because we still
> select it as our chosen task even with a badness score of 0 if !chosen

Yes, see another email from me.

> Your point about p->mm being non-NULL for kthreads using use_mm() is
> taken, we should probably just change the is_global_init() check in
> select_bad_process() to p->flags & PF_KTHREAD and ensure we reject
> oom_kill_process() for them.

Yes, but we have to check both is_global_init() and PF_KTHREAD.

The "patch" I sent checks PF_KTHREAD in find_lock_task_mm(), but as I
said select_bad_process() is the better place.

> > OK, a bad user does
> >
> > 	int sleep_forever(void *)
> > 	{
> > 		pause();
> > 	}
> >
> > 	int main(void)
> > 	{
> > 		pthread_create(sleep_forever);
> > 		syscall(__NR_exit);
> > 	}
> >
> > Now, every time select_bad_process() is called it will find this process
> > and PF_EXITING is true, so it just returns ERR_PTR(-1UL). And note that
> > this process is not going to exit.
> >
>
> Hmm, so it looks like we need to filter on !p->mm before checking for
> PF_EXITING so that tasks that are EXIT_ZOMBIE won't make the oom killer
> into a no-op.

As it was already discussed, it is not easy to check !p->mm. Once
again, we must not filter out the task just because its ->mm == NULL.

Probably the best change for now is

	- if (p->flags & PF_EXITING) {
	+ if (p->flags & PF_EXITING && p->mm) {

This is not perfect too, but much better.

> > > > Say, oom_forkbomb_penalty() does list_for_each_entry(tsk->children).
> > > > Again, this is not right even if we forget about !child->mm check.
> > > > This list_for_each_entry() can only see the processes forked by the
> > > > main thread.
> > > >
> > >
> > > That's the intention.
> >
> > Why? shouldn't oom_badness() return the same result for any thread
> > in thread group? We should take all childs into account.
> >
>
> oom_forkbomb_penalty() only cares about first-descendant children that
> do not share the same memory,

I see, but the code doesn't really do this. I mean, it doesn't really
see the first-descendant children, only those which were forked by the
main thread.

Look. We have a main thread M and the sub-thread T. T forks a lot of
processes which use a lot of memory. These processes _are_ the first
descendant children of the M+T thread group, they should be accounted.
But M->children list is empty.

oom_forkbomb_penalty() and oom_kill_process() should do

	t = tsk;
	do {
		list_for_each_entry(child, &t->children, sibling) {
			... take child into account ...
		}
	} while_each_thread(tsk, t);


> > > > Hmm. Why oom_forkbomb_penalty() does thread_group_cputime() under
> > > > task_lock() ? It seems, ->alloc_lock() is only needed for get_mm_rss().
> > > >
> [...snip...]
> We need task_lock() to ensure child->mm hasn't detached between the check
> for child->mm == tsk->mm and get_mm_rss(child->mm).  So I'm not sure what
> you're trying to improve with this variation, it's a tradeoff between
> calling thread_group_cputime() under task_lock() for a subset of a task's
> threads when we already need to hold task_lock() anyway vs. calling it for
> all threads unconditionally.

See the patch below. Yes, this is minor, but it is always good to avoid
the unnecessary locks, and thread_group_cputime() is O(N).

Not only for performance reasons. This allows to change the locking in
thread_group_cputime() if needed without fear to deadlock with task_lock().

Oleg.

--- x/mm/oom_kill.c
+++ x/mm/oom_kill.c
@@ -97,13 +97,16 @@ static unsigned long oom_forkbomb_penalt
 		return 0;
 	list_for_each_entry(child, &tsk->children, sibling) {
 		struct task_cputime task_time;
-		unsigned long runtime;
+		unsigned long runtime, this_rss;
 
 		task_lock(child);
 		if (!child->mm || child->mm == tsk->mm) {
 			task_unlock(child);
 			continue;
 		}
+		this_rss = get_mm_rss(child->mm);
+		task_unlock(child);
+
 		thread_group_cputime(child, &task_time);
 		runtime = cputime_to_jiffies(task_time.utime) +
 			  cputime_to_jiffies(task_time.stime);
@@ -113,10 +116,9 @@ static unsigned long oom_forkbomb_penalt
 		 * get to execute at all in such cases anyway.
 		 */
 		if (runtime < HZ) {
-			child_rss += get_mm_rss(child->mm);
+			child_rss += this_rss;
 			forkcount++;
 		}
-		task_unlock(child);
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
