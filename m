Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0646482FA1
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 11:43:39 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so38975197wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 08:43:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fd7si13988556wjc.157.2015.10.02.08.43.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 08:43:37 -0700 (PDT)
Date: Fri, 2 Oct 2015 17:43:36 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC v2 07/18] kthread: Allow to cancel kthread work
Message-ID: <20151002154336.GC3122@pathway.suse.cz>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-8-git-send-email-pmladek@suse.com>
 <20150922193513.GE17659@mtj.duckdns.org>
 <20150925112617.GA3122@pathway.suse.cz>
 <20150928170314.GF2589@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150928170314.GF2589@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 2015-09-28 13:03:14, Tejun Heo wrote:
> Hello, Petr.
> 
> On Fri, Sep 25, 2015 at 01:26:17PM +0200, Petr Mladek wrote:
> > 1) PENDING state plus -EAGAIN/busy loop cycle
> > ---------------------------------------------
> > 
> > IMHO, we want to use the timer because it is an elegant solution.
> > Then we must release the lock when the timer is running. The lock
> > must be taken by the timer->function(). And there is a small window
> > when the timer is not longer pending but timer->function is not running:
> > 
> > CPU0                            CPU1
> > 
> > run_timer_softirq()
> >   __run_timers()
> >     detach_expired_timer()
> >       detach_timer()
> > 	#clear_pending
> > 
> > 				try_to_grab_pending_kthread_work()
> > 				  del_timer()
> > 				    # fails because not pending
> > 
> > 				  test_and_set_bit(KTHREAD_WORK_PENDING_BIT)
> > 				    # fails because already set
> > 
> > 				  if (!list_empty(&work->node))
> > 				    # fails because still not queued
> > 
> > 			!!! problematic window !!!
> > 
> >     call_timer_fn()
> >      queue_kthraed_work()
> 
> Let's say each work item has a state variable which is protected by a
> lock and the state can be one of IDLE, PENDING, CANCELING.  Let's also
> assume that all cancelers synchronize with each other via mutex, so we
> only have to worry about a single canceler.  Wouldn't something like
> the following work while being a lot simpler?
> 
> Delayed queueing and execution.
> 
> 1. Lock and check whether state is IDLE.  If not, nothing to do.
> 
> 2. Set state to PENDING and schedule the timer and unlock.
> 
> 3. On expiration, timer_fn grabs the lock and see whether state is
>    still PENDING.  If so, schedule the work item for execution;
>    otherwise, nothing to do.
> 
> 4. After dequeueing from execution queue with lock held, the worker is
>    marked as executing the work item and state is reset to IDLE.
> 
> Canceling
> 
> 1. Lock, dequeue and set the state to CANCELING.
> 
> 2. Unlock and perform del_timer_sync().
> 
> 3. Flush the work item.
> 
> 4. Lock and reset the state to IDLE and unlock.
> 
> 
> > 2) CANCEL state plus custom waitqueue
> > -------------------------------------
> > 
> > cancel_kthread_work_sync() has to wait for the running work. It might take
> > quite some time. Therefore we could not block others by a spinlock.
> > Also others could not wait for the spin lock in a busy wait.
> 
> Hmmm?  Cancelers can synchronize amongst them using a mutex and the
> actual work item wait can use flushing.
> 
> > IMHO, the proposed and rather complex solutions are needed in both cases.
> > 
> > Or did I miss a possible trick, please?
> 
> I probably have missed something in the above and it is not completley
> correct but I do think it can be way simpler than how workqueue does
> it.

I have played with this idea and it opens a can of worms with locking
problems and it looks even more complicated.

Let me show this on a snippet of code:

struct kthread_worker {
	spinlock_t		lock;
	struct list_head	work_list;
	struct kthread_work	*current_work;
};

enum {
	KTHREAD_WORK_IDLE,
	KTHREAD_WORK_PENDING,
	KTHREAD_WORK_CANCELING,
};

struct kthread_work {
	unsigned int		flags;
	spinlock_t		lock;
	struct list_head	node;
	kthread_work_func_t	func;
	struct kthread_worker	*worker;
};


/* the main kthread worker cycle */
int kthread_worker_fn(void *worker_ptr)
{
	struct kthread_worker *worker = worker_ptr;
	struct kthread_work *work;

repeat:

	work = NULL;
	spin_lock_irq(&worker->lock);
	if (!list_empty(&worker->work_list)) {
		work = list_first_entry(&worker->work_list,
					struct kthread_work, node);
		spin_lock(&work->lock);
		list_del_init(&work->node);
		work->flags = KTHREAD_WORK_IDLE;
		spin_unlock(&work->lock);
	}
	worker->current_work = work;
	spin_unlock_irq(&worker->lock);

	if (work) {
		__set_current_state(TASK_RUNNING);
		work->func(work);
	} else if (!freezing(current))
		schedule();

	goto repeat;
}
EXPORT_SYMBOL_GPL(kthread_worker_fn);


static void __queue_kthread_work(struct kthread_worker *worker,
			  struct kthread_work *work)
{
	list_add_tail(&work->node, pos);
	work->worker = worker;
}


bool queue_kthread_work(struct kthread_worker *worker,
			struct kthread_work *work)
{
	bool ret = false;
	unsigned long flags;

	/*
	 * Lock worker first to avoid ABBA deadlock.
	 * What if the work is already queued to another worker?
	 */
	spin_lock_irqsave(&worker->lock, flags);
	spin_lock(&work->lock);

	if (work->flags != KTHREAD_WORK_IDLE)
		goto unlock_out;

	__queue_kthread_work(worker, work);
	ret = true;

unlock_out:
	spin_unlock(&work->lock);
	spin_unlock_irqrestore(&worker->lock, flags);
out:
	return ret;
}

bool cancel_kthread_work_sync(struct kthread_work *work)
{
	struct kthread_worker *worker;
	bool flush = true;
	unsigned long flags;

again:
	worker = ACCESS_ONCE(work->worker);

	if (worker)
		spin_lock_irqsave(&worker->lock, flags);
	else
		local_irq_save(flags);

	spin_lock(&work->lock);

	if (worker && worker != work->worker) {
		spin_unlock(&work->lock);
		spin_unlock_irqrestore(&worker->lock, flags);
		goto again;
	}

	switch (work->flags) {
	case KTHREAD_WORK_PENDING:
		list_del_init(&work->node);
	case KTHREAD_WORK_IDLE:
		work->flags = KTHREAD_WORK_CANCELING;
		break;
	case KTHREAD_WORK_CANCELING:
		/*
		 * Some other work is canceling. Let's wait in a
		 * custom waitqueue until the work is flushed.
		 */
		prepare_to_wait_exclusive(&cancel_waitq, &cwait.wait,
						  TASK_UNINTERRUPTIBLE);
		flush = false;
		break;
	}

	spin_unlock(&work->lock);
	if (worker)
		spin_unlock_irqrestore(&worker->lock, flags);
	else
		local_irq_restore(flags);

	if (flush) {
		kthread_work_flush(work);
		/*
		 * We are the cancel leader. Nobody else could manipulate the
		 * work.
		 */
		work->flags = KTHREAD_WORK_IDLE;
		/*
		 * Paired with prepare_to_wait() above so that either
		 * waitqueue_active() is visible here or CANCELING bit is
		 * visible there.
		 */
		smp_mb();
		if (waitqueue_active(&cancel_waitq))
			__wake_up(&cancel_waitq, TASK_NORMAL, 1, work);
	} elseif (READ_ONCE(work->flags) == KTHREAD_WORK_CANCELING) {
	       schedule();
	}
}


IMHO, we need both locks. The worker manipulates more works and
need its own lock. We need work-specific lock because the work
might be assigned to different workers and we need to be sure
that the operations are really serialized, e.g. queuing.

Now, worker_fn() needs to get the first work from the the worker list
and then manipulate the work => it needs to get the worker->lock
and then work->lock.

It means that most other functions would need to take both locks
in this order to avoid ABBA deadlock. This causes quite some
complications, e.g. in cancel_work().

There might be even more problems if we try to queue the same work
into more workers and we start mixing the locks from different
workers.

I do not know. It is possible that you prefer this solution than
the atomic bit operations. Also it is possible that there exists
a trick that might make it easier.

I would personally prefer to use the tricks from the workqueues.
They are proven to work and they make the code faster. I think
that we might need to queue the work in a sensitive fast path.

IMHO, the code already is much easier than the workqueues because
there are no pools of kthreads behind each worker.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
