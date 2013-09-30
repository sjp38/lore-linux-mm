Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 167AE6B0032
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 10:24:22 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so5934298pad.21
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 07:24:21 -0700 (PDT)
Date: Mon, 30 Sep 2013 16:24:00 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] introduce synchronize_sched_{enter,exit}()
Message-ID: <20130930142400.GK26785@twins.programming.kicks-ass.net>
References: <1378805550-29949-1-git-send-email-mgorman@suse.de>
 <1378805550-29949-38-git-send-email-mgorman@suse.de>
 <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130929183634.GA15563@redhat.com>
 <20130930125942.GB12926@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130930125942.GB12926@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, Sep 30, 2013 at 02:59:42PM +0200, Peter Zijlstra wrote:

> > 
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
> 
> This seems to be when a new xxx_begin() has happened after our last
> xxx_end() and the sync_sched() from xxx_begin() merges with the
> xxx_end() one and we're done.
> 
> > 	} else if (xxx->cb_state == CB_REPLAY) {
> > 		xxx->cb_state = CB_PENDING;
> > 		call_rcu_sched(&xxx->cb_head, cb_rcu_func);
> 
> A later xxx_exit() has happened, and we need to requeue to catch a later
> GP.
> 
> > 	} else {
> > 		xxx->cb_state = CB_IDLE;
> > 		xxx->gp_state = GP_IDLE;
> 
> Nothing fancy happened and we're done.
> 
> > 	}
> > 	spin_unlock_irqrestore(&xxx->xxx_lock, flags);
> > }
> > 
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
> So I don't immediately see the point of the concurrent write side;
> percpu_rwsem wouldn't allow this and afaict neither would
> freeze_super().
> 
> Other than that; yes this makes sense if you care about write side
> performance and I think its solid.

Hmm, wait. I don't see how this is equivalent to:

xxx_end()
{
	synchronize_sched();
	atomic_dec(&xxx->counter);
}

For that we'd have to decrement xxx->gp_count from cb_rcu_func(),
wouldn't we?

Without that there's no guarantee the fast path readers will have a MB
to observe the write critical section, unless I'm completely missing
something obviuos here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
