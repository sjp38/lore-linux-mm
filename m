Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9263F6B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 08:49:26 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id fa1so5831301pad.19
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 05:49:26 -0700 (PDT)
Date: Mon, 30 Sep 2013 14:42:14 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC] introduce synchronize_sched_{enter,exit}()
Message-ID: <20130930124214.GA19560@redhat.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de> <1378805550-29949-38-git-send-email-mgorman@suse.de> <20130917143003.GA29354@twins.programming.kicks-ass.net> <20130929183634.GA15563@redhat.com> <20130929200114.GC19582@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130929200114.GC19582@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 09/29, Paul E. McKenney wrote:
>
> On Sun, Sep 29, 2013 at 08:36:34PM +0200, Oleg Nesterov wrote:
> >
> > 	struct xxx_struct {
> > 		atomic_t counter;
> > 	};
> >
> > 	static inline bool xxx_is_idle(struct xxx_struct *xxx)
> > 	{
> > 		return atomic_read(&xxx->counter) == 0;
> > 	}
> >
> > 	static inline void xxx_enter(struct xxx_struct *xxx)
> > 	{
> > 		atomic_inc(&xxx->counter);
> > 		synchronize_sched();
> > 	}
> >
> > 	static inline void xxx_enter(struct xxx_struct *xxx)
> > 	{
> > 		synchronize_sched();
> > 		atomic_dec(&xxx->counter);
> > 	}
>
> But there is nothing for synchronize_sched() to wait for in the above.
> Presumably the caller of xxx_is_idle() is required to disable preemption
> or be under rcu_read_lock_sched()?

Yes, yes, sure, xxx_is_idle() should be called under preempt_disable().
(or rcu_read_lock() if xxx_enter() uses synchronize_rcu()).

> So you are trying to make something that abstracts the RCU-protected
> state-change pattern?  Or perhaps more accurately, the RCU-protected
> state-change-and-back pattern?

Yes, exactly.

> > struct xxx_struct {
> > 	int			gp_state;
> >
> > 	int			gp_count;
> > 	wait_queue_head_t	gp_waitq;
> >
> > 	int			cb_state;
> > 	struct rcu_head		cb_head;
>
> 	spinlock_t		xxx_lock;  /* ? */

See

	#define xxx_lock	gp_waitq.lock
	
in .c below, but we can add another spinlock.

> This spinlock might not make the big-system guys happy, but it appears to
> be needed below.

Only the writers use this spinlock, and they should synchronize with each
other anyway. I don't think this can really penalize, say, percpu_down_write
or cpu_hotplug_begin.

> > // .c	-----------------------------------------------------------------------
> >
> > enum { GP_IDLE = 0, GP_PENDING, GP_PASSED };
> >
> > enum { CB_IDLE = 0, CB_PENDING, CB_REPLAY };
> >
> > #define xxx_lock	gp_waitq.lock
> >
> > void xxx_enter(struct xxx_struct *xxx)
> > {
> > 	bool need_wait, need_sync;
> >
> > 	spin_lock_irq(&xxx->xxx_lock);
> > 	need_wait = xxx->gp_count++;
> > 	need_sync = xxx->gp_state == GP_IDLE;
>
> Suppose ->gp_state is GP_PASSED.  It could transition to GP_IDLE at any
> time, right?

As you already pointed below - no.

Once we incremented ->nr_writers, nobody can set GP_IDLE. And if the
caller is the "first" writer (need_sync == T) nobody else can change
->gp_state, so xxx_enter() sets GP_PASSED lockless.

> > 	if (need_sync)
> > 		xxx->gp_state = GP_PENDING;
> > 	spin_unlock_irq(&xxx->xxx_lock);
> >
> > 	BUG_ON(need_wait && need_sync);
> >
> > 	} if (need_sync) {
> > 		synchronize_sched();
> > 		xxx->gp_state = GP_PASSED;
> > 		wake_up_all(&xxx->gp_waitq);
> > 	} else if (need_wait) {
> > 		wait_event(&xxx->gp_waitq, xxx->gp_state == GP_PASSED);
>
> Suppose the wakeup is delayed until after the state has been updated
> back to GP_IDLE?  Ah, presumably the non-zero ->gp_count prevents this.

Yes, exactly.

> > static void cb_rcu_func(struct rcu_head *rcu)
> > {
> > 	struct xxx_struct *xxx = container_of(rcu, struct xxx_struct, cb_head);
> > 	long flags;
> >
> > 	BUG_ON(xxx->gp_state != GP_PASSED);
> > 	BUG_ON(xxx->cb_state == CB_IDLE);
> >
> > 	spin_lock_irqsave(&xxx->xxx_lock, flags);
> > 	if (xxx->gp_count) {
> > 		xxx->cb_state = CB_IDLE;
> > 	} else if (xxx->cb_state == CB_REPLAY) {
> > 		xxx->cb_state = CB_PENDING;
> > 		call_rcu_sched(&xxx->cb_head, cb_rcu_func);
> > 	} else {
> > 		xxx->cb_state = CB_IDLE;
> > 		xxx->gp_state = GP_IDLE;
> > 	}
>
> It took me a bit to work out the above.  It looks like the intent is
> to have the last xxx_exit() put the state back to GP_IDLE, which appears
> to be the state in which readers can use a fastpath.

Yes, and we we offload this work to rcu callback so xxx_exit() doesn't
block.

The only complication is the next writer which does xxx_enter() after
xxx_exit(). If there are no other writers, the next xxx_exit() should do

	rcu_cancel(&xxx->cb_head);
	call_rcu_sched(&xxx->cb_head, cb_rcu_func);

to "extend" the gp, but since we do not have rcu_cancel() it simply sets
CB_REPLAY to instruct cb_rcu_func() to reschedule itself.

> This works because if ->gp_count is non-zero and ->cb_state is CB_IDLE,
> there must be an xxx_exit() in our future.

Yes, but ->cb_state doesn't really matter if ->gp_count != 0 in xxx_exit()
or cb_rcu_func() (except it can't be CB_IDLE in cb_rcu_func).

> > void xxx_exit(struct xxx_struct *xxx)
> > {
> > 	spin_lock_irq(&xxx->xxx_lock);
> > 	if (!--xxx->gp_count) {
> > 		if (xxx->cb_state == CB_IDLE) {
> > 			xxx->cb_state = CB_PENDING;
> > 			call_rcu_sched(&xxx->cb_head, cb_rcu_func);
> > 		} else if (xxx->cb_state == CB_PENDING) {
> > 			xxx->cb_state = CB_REPLAY;
> > 		}
> > 	}
> > 	spin_unlock_irq(&xxx->xxx_lock);
> > }
>
> Then we also have something like this?
>
> bool xxx_readers_fastpath_ok(struct xxx_struct *xxx)
> {
> 	BUG_ON(!rcu_read_lock_sched_held());
> 	return xxx->gp_state == GP_IDLE;
> }

Yes, this is what xxx_is_idle() does (ignoring BUG_ON). It actually
checks xxx->gp_state == 0, this is just to avoid the unnecessary export
of GP_* enum.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
