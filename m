Date: Thu, 3 Jan 2008 02:06:31 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 09 of 24] fallback killing more tasks if tif-memdie
	doesn't go away
Message-ID: <20080103010631.GK30939@v2.random>
References: <patchbomb.1187786927@v2.random> <9bf6a66eab3c52327daa.1187786936@v2.random> <20070912053022.b7d152c3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070912053022.b7d152c3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 12, 2007 at 05:30:22AM -0700, Andrew Morton wrote:
> On Wed, 22 Aug 2007 14:48:56 +0200 Andrea Arcangeli <andrea@suse.de> wrote:
> 
> > # HG changeset patch
> > # User Andrea Arcangeli <andrea@suse.de>
> > # Date 1187778125 -7200
> > # Node ID 9bf6a66eab3c52327daa831ef101d7802bc71791
> > # Parent  ffdc30241856d7155ceedd4132eef684f7cc7059
> > fallback killing more tasks if tif-memdie doesn't go away
> > 
> > Waiting indefinitely for a TIF_MEMDIE task to go away will deadlock. Two
> > tasks reading from the same inode at the same time and both going out of
> > memory inside a read(largebuffer) syscall, will even deadlock through
> > contention over the PG_locked bitflag. The task holding the semaphore
> > detects oom but the oom killer decides to kill the task blocked in
> > wait_on_page_locked(). The task holding the semaphore will hang inside
> > alloc_pages that will never return because it will wait the TIF_MEMDIE
> > task to go away, but the TIF_MEMDIE task can't go away until the task
> > holding the semaphore is killed in the first place.
> 
> hrm, OK, that's not nice
> 
> > It's quite unpractical to teach the oom killer the locking dependencies
> > across running tasks, so the feasible fix is to develop a logic that
> > after waiting a long time for a TIF_MEMDIE tasks goes away, fallbacks
> > on killing one more task. This also eliminates the possibility of
> > suprious oom killage (i.e. two tasks killed despite only one had to be
> > killed). It's not a math guarantee because we can't demonstrate that if
> > a TIF_MEMDIE SIGKILLED task didn't mange to complete do_exit within
> > 10sec, it never will. But the current probability of suprious oom
> > killing is sure much higher than the probability of suprious oom killing
> > with this patch applied.
> > 
> > The whole locking is around the tasklist_lock. On one side do_exit reads
> > TIF_MEMDIE and clears VM_is_OOM under the lock, on the other side the
> > oom killer accesses VM_is_OOM and TIF_MEMDIE under the lock. This is a
> > read_lock in the oom killer but it's actually a write lock thanks to the
> > OOM_lock semaphore running one oom killer at once (the locking rule is,
> > either use write_lock_irq or read_lock+OOM_lock).
> > 
> 
> 
> > 
> > diff --git a/kernel/exit.c b/kernel/exit.c
> > --- a/kernel/exit.c
> > +++ b/kernel/exit.c
> > @@ -849,6 +849,15 @@ static void exit_notify(struct task_stru
> >  	if (tsk->exit_signal == -1 && likely(!tsk->ptrace))
> >  		state = EXIT_DEAD;
> >  	tsk->exit_state = state;
> > +
> > +	/*
> > +	 * Read TIF_MEMDIE and set VM_is_OOM to 0 atomically inside
> > +	 * the tasklist_lock_lock.
> > +	 */
> > +	if (unlikely(test_tsk_thread_flag(tsk, TIF_MEMDIE))) {
> > +		extern unsigned long VM_is_OOM;
> > +		clear_bit(0, &VM_is_OOM);
> > +	}
> 
> Please, no externs-in-C, ever.

You mean in .c ;).

Anyway I dropped VM_is_OOM for now so the critical fixes will be
easier to merge. There are downsides in that, suprious oom killing
isn't impossibile anymore, but at least the other fixes have much more
priority.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
