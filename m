Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id EF13A6B0031
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 09:00:04 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so5492659pbc.7
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 06:00:04 -0700 (PDT)
Date: Mon, 30 Sep 2013 14:59:42 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] introduce synchronize_sched_{enter,exit}()
Message-ID: <20130930125942.GB12926@twins.programming.kicks-ass.net>
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
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Sep 29, 2013 at 08:36:34PM +0200, Oleg Nesterov wrote:
> Why? Say, percpu_rw_semaphore, or upcoming changes in get_online_cpus(),
> (Peter, I think they should be unified anyway, but lets ignore this for
> now). 

If you think the percpu_rwsem users can benefit sure.. So far its good I
didn't go the percpu_rwsem route for it looks like we got something
better at the end of it ;-)

> Or freeze_super() (which currently looks buggy), perhaps something
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

Well, if we make percpu_rwsem the defacto container of the pattern and
use that throughout, we'd have only a single implementation and don't
need the abstraction.

That said; we could still use the idea proposed; so let me take a look.

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

This seems to be when a new xxx_begin() has happened after our last
xxx_end() and the sync_sched() from xxx_begin() merges with the
xxx_end() one and we're done.

> 	} else if (xxx->cb_state == CB_REPLAY) {
> 		xxx->cb_state = CB_PENDING;
> 		call_rcu_sched(&xxx->cb_head, cb_rcu_func);

A later xxx_exit() has happened, and we need to requeue to catch a later
GP.

> 	} else {
> 		xxx->cb_state = CB_IDLE;
> 		xxx->gp_state = GP_IDLE;

Nothing fancy happened and we're done.

> 	}
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

So I don't immediately see the point of the concurrent write side;
percpu_rwsem wouldn't allow this and afaict neither would
freeze_super().

Other than that; yes this makes sense if you care about write side
performance and I think its solid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
