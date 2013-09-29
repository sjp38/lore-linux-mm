Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCFE6B0031
	for <linux-mm@kvack.org>; Sun, 29 Sep 2013 16:01:25 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so4653804pbb.24
        for <linux-mm@kvack.org>; Sun, 29 Sep 2013 13:01:24 -0700 (PDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Sun, 29 Sep 2013 14:01:22 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id A372AC40005
	for <linux-mm@kvack.org>; Sun, 29 Sep 2013 14:01:12 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8TK1Ij0411774
	for <linux-mm@kvack.org>; Sun, 29 Sep 2013 14:01:19 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8TK4MKw015302
	for <linux-mm@kvack.org>; Sun, 29 Sep 2013 14:04:23 -0600
Date: Sun, 29 Sep 2013 13:01:14 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [RFC] introduce synchronize_sched_{enter,exit}()
Message-ID: <20130929200114.GC19582@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130929183634.GA15563@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130929183634.GA15563@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Sep 29, 2013 at 08:36:34PM +0200, Oleg Nesterov wrote:
> Hello.
> 
> Paul, Peter, et al, could you review the code below?
> 
> I am not sending the patch, I think it is simpler to read the code
> inline (just in case, I didn't try to compile it yet).
> 
> It is functionally equivalent to
> 
> 	struct xxx_struct {
> 		atomic_t counter;
> 	};
> 
> 	static inline bool xxx_is_idle(struct xxx_struct *xxx)
> 	{
> 		return atomic_read(&xxx->counter) == 0;
> 	}
> 
> 	static inline void xxx_enter(struct xxx_struct *xxx)
> 	{
> 		atomic_inc(&xxx->counter);
> 		synchronize_sched();
> 	}
> 
> 	static inline void xxx_enter(struct xxx_struct *xxx)
> 	{
> 		synchronize_sched();
> 		atomic_dec(&xxx->counter);
> 	}

But there is nothing for synchronize_sched() to wait for in the above.
Presumably the caller of xxx_is_idle() is required to disable preemption
or be under rcu_read_lock_sched()?

> except: it records the state and synchronize_sched() is only called by
> xxx_enter() and only if necessary.
> 
> Why? Say, percpu_rw_semaphore, or upcoming changes in get_online_cpus(),
> (Peter, I think they should be unified anyway, but lets ignore this for
> now). Or freeze_super() (which currently looks buggy), perhaps something
> else. This pattern
> 
> 	writer:
> 		state = SLOW_MODE;
> 		synchronize_rcu/sched();
> 
> 	reader:
> 		preempt_disable();	// or rcu_read_lock();
> 		if (state != SLOW_MODE)
> 			...
> 
> is quite common.

And this does guarantee that by the time the writer's synchronize_whatever()
exits, all readers will know that state==SLOW_MODE.

> Note:
> 	- This implementation allows multiple writers, and sometimes
> 	  this makes sense.

If each writer atomically incremented SLOW_MODE, did its update, then
atomically decremented it, sure.  You could be more clever and avoid
unneeded synchronize_whatever() calls, but I would have to see a good
reason for doing so before recommending this.

OK, but you appear to be doing this below anyway.  ;-)

> 	- But it's trivial to add "bool xxx->exclusive" set by xxx_init().
> 	  If it is true only one xxx_enter() is possible, other callers
> 	  should block until xxx_exit(). This is what percpu_down_write()
> 	  actually needs.

Agreed.

> 	- Probably it makes sense to add xxx->rcu_domain = RCU/SCHED/ETC.

Or just have pointers to the RCU functions in the xxx structure...

So you are trying to make something that abstracts the RCU-protected
state-change pattern?  Or perhaps more accurately, the RCU-protected
state-change-and-back pattern?

> Do you think it is correct? Makes sense? (BUG_ON's are just comments).

... Maybe ...   Please see below for commentary and a question.

							Thanx, Paul

> Oleg.
> 
> // .h	-----------------------------------------------------------------------
> 
> struct xxx_struct {
> 	int			gp_state;
> 
> 	int			gp_count;
> 	wait_queue_head_t	gp_waitq;
> 
> 	int			cb_state;
> 	struct rcu_head		cb_head;

	spinlock_t		xxx_lock;  /* ? */

This spinlock might not make the big-system guys happy, but it appears to
be needed below.

> };
> 
> static inline bool xxx_is_idle(struct xxx_struct *xxx)
> {
> 	return !xxx->gp_state; /* GP_IDLE */
> }
> 
> extern void xxx_enter(struct xxx_struct *xxx);
> extern void xxx_exit(struct xxx_struct *xxx);
> 
> // .c	-----------------------------------------------------------------------
> 
> enum { GP_IDLE = 0, GP_PENDING, GP_PASSED };
> 
> enum { CB_IDLE = 0, CB_PENDING, CB_REPLAY };
> 
> #define xxx_lock	gp_waitq.lock
> 
> void xxx_enter(struct xxx_struct *xxx)
> {
> 	bool need_wait, need_sync;
> 
> 	spin_lock_irq(&xxx->xxx_lock);
> 	need_wait = xxx->gp_count++;
> 	need_sync = xxx->gp_state == GP_IDLE;

Suppose ->gp_state is GP_PASSED.  It could transition to GP_IDLE at any
time, right?

> 	if (need_sync)
> 		xxx->gp_state = GP_PENDING;
> 	spin_unlock_irq(&xxx->xxx_lock);
> 
> 	BUG_ON(need_wait && need_sync);
> 
> 	} if (need_sync) {
> 		synchronize_sched();
> 		xxx->gp_state = GP_PASSED;
> 		wake_up_all(&xxx->gp_waitq);
> 	} else if (need_wait) {
> 		wait_event(&xxx->gp_waitq, xxx->gp_state == GP_PASSED);

Suppose the wakeup is delayed until after the state has been updated
back to GP_IDLE?  Ah, presumably the non-zero ->gp_count prevents this.
Never mind!

> 	} else {
> 		BUG_ON(xxx->gp_state != GP_PASSED);
> 	}
> }
> 
> static void cb_rcu_func(struct rcu_head *rcu)
> {
> 	struct xxx_struct *xxx = container_of(rcu, struct xxx_struct, cb_head);
> 	long flags;
> 
> 	BUG_ON(xxx->gp_state != GP_PASSED);
> 	BUG_ON(xxx->cb_state == CB_IDLE);
> 
> 	spin_lock_irqsave(&xxx->xxx_lock, flags);
> 	if (xxx->gp_count) {
> 		xxx->cb_state = CB_IDLE;
> 	} else if (xxx->cb_state == CB_REPLAY) {
> 		xxx->cb_state = CB_PENDING;
> 		call_rcu_sched(&xxx->cb_head, cb_rcu_func);
> 	} else {
> 		xxx->cb_state = CB_IDLE;
> 		xxx->gp_state = GP_IDLE;
> 	}

It took me a bit to work out the above.  It looks like the intent is
to have the last xxx_exit() put the state back to GP_IDLE, which appears
to be the state in which readers can use a fastpath.

This works because if ->gp_count is non-zero and ->cb_state is CB_IDLE,
there must be an xxx_exit() in our future.

> 	spin_unlock_irqrestore(&xxx->xxx_lock, flags);
> }
> 
> void xxx_exit(struct xxx_struct *xxx)
> {
> 	spin_lock_irq(&xxx->xxx_lock);
> 	if (!--xxx->gp_count) {
> 		if (xxx->cb_state == CB_IDLE) {
> 			xxx->cb_state = CB_PENDING;
> 			call_rcu_sched(&xxx->cb_head, cb_rcu_func);
> 		} else if (xxx->cb_state == CB_PENDING) {
> 			xxx->cb_state = CB_REPLAY;
> 		}
> 	}
> 	spin_unlock_irq(&xxx->xxx_lock);
> }

Then we also have something like this?

bool xxx_readers_fastpath_ok(struct xxx_struct *xxx)
{
	BUG_ON(!rcu_read_lock_sched_held());
	return xxx->gp_state == GP_IDLE;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
