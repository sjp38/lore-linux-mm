Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 31BE96B0031
	for <linux-mm@kvack.org>; Sun, 29 Sep 2013 14:43:38 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id xa7so4647701pbc.17
        for <linux-mm@kvack.org>; Sun, 29 Sep 2013 11:43:37 -0700 (PDT)
Date: Sun, 29 Sep 2013 20:36:34 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [RFC] introduce synchronize_sched_{enter,exit}()
Message-ID: <20130929183634.GA15563@redhat.com>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de> <1378805550-29949-38-git-send-email-mgorman@suse.de> <20130917143003.GA29354@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130917143003.GA29354@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>

Hello.

Paul, Peter, et al, could you review the code below?

I am not sending the patch, I think it is simpler to read the code
inline (just in case, I didn't try to compile it yet).

It is functionally equivalent to

	struct xxx_struct {
		atomic_t counter;
	};

	static inline bool xxx_is_idle(struct xxx_struct *xxx)
	{
		return atomic_read(&xxx->counter) == 0;
	}

	static inline void xxx_enter(struct xxx_struct *xxx)
	{
		atomic_inc(&xxx->counter);
		synchronize_sched();
	}

	static inline void xxx_enter(struct xxx_struct *xxx)
	{
		synchronize_sched();
		atomic_dec(&xxx->counter);
	}

except: it records the state and synchronize_sched() is only called by
xxx_enter() and only if necessary.

Why? Say, percpu_rw_semaphore, or upcoming changes in get_online_cpus(),
(Peter, I think they should be unified anyway, but lets ignore this for
now). Or freeze_super() (which currently looks buggy), perhaps something
else. This pattern

	writer:
		state = SLOW_MODE;
		synchronize_rcu/sched();

	reader:
		preempt_disable();	// or rcu_read_lock();
		if (state != SLOW_MODE)
			...

is quite common.

Note:
	- This implementation allows multiple writers, and sometimes
	  this makes sense.

	- But it's trivial to add "bool xxx->exclusive" set by xxx_init().
	  If it is true only one xxx_enter() is possible, other callers
	  should block until xxx_exit(). This is what percpu_down_write()
	  actually needs.

	- Probably it makes sense to add xxx->rcu_domain = RCU/SCHED/ETC.

Do you think it is correct? Makes sense? (BUG_ON's are just comments).

Oleg.

// .h	-----------------------------------------------------------------------

struct xxx_struct {
	int			gp_state;

	int			gp_count;
	wait_queue_head_t	gp_waitq;

	int			cb_state;
	struct rcu_head		cb_head;
};

static inline bool xxx_is_idle(struct xxx_struct *xxx)
{
	return !xxx->gp_state; /* GP_IDLE */
}

extern void xxx_enter(struct xxx_struct *xxx);
extern void xxx_exit(struct xxx_struct *xxx);

// .c	-----------------------------------------------------------------------

enum { GP_IDLE = 0, GP_PENDING, GP_PASSED };

enum { CB_IDLE = 0, CB_PENDING, CB_REPLAY };

#define xxx_lock	gp_waitq.lock

void xxx_enter(struct xxx_struct *xxx)
{
	bool need_wait, need_sync;

	spin_lock_irq(&xxx->xxx_lock);
	need_wait = xxx->gp_count++;
	need_sync = xxx->gp_state == GP_IDLE;
	if (need_sync)
		xxx->gp_state = GP_PENDING;
	spin_unlock_irq(&xxx->xxx_lock);

	BUG_ON(need_wait && need_sync);

	} if (need_sync) {
		synchronize_sched();
		xxx->gp_state = GP_PASSED;
		wake_up_all(&xxx->gp_waitq);
	} else if (need_wait) {
		wait_event(&xxx->gp_waitq, xxx->gp_state == GP_PASSED);
	} else {
		BUG_ON(xxx->gp_state != GP_PASSED);
	}
}

static void cb_rcu_func(struct rcu_head *rcu)
{
	struct xxx_struct *xxx = container_of(rcu, struct xxx_struct, cb_head);
	long flags;

	BUG_ON(xxx->gp_state != GP_PASSED);
	BUG_ON(xxx->cb_state == CB_IDLE);

	spin_lock_irqsave(&xxx->xxx_lock, flags);
	if (xxx->gp_count) {
		xxx->cb_state = CB_IDLE;
	} else if (xxx->cb_state == CB_REPLAY) {
		xxx->cb_state = CB_PENDING;
		call_rcu_sched(&xxx->cb_head, cb_rcu_func);
	} else {
		xxx->cb_state = CB_IDLE;
		xxx->gp_state = GP_IDLE;
	}
	spin_unlock_irqrestore(&xxx->xxx_lock, flags);
}

void xxx_exit(struct xxx_struct *xxx)
{
	spin_lock_irq(&xxx->xxx_lock);
	if (!--xxx->gp_count) {
		if (xxx->cb_state == CB_IDLE) {
			xxx->cb_state = CB_PENDING;
			call_rcu_sched(&xxx->cb_head, cb_rcu_func);
		} else if (xxx->cb_state == CB_PENDING) {
			xxx->cb_state = CB_REPLAY;
		}
	}
	spin_unlock_irq(&xxx->xxx_lock);
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
