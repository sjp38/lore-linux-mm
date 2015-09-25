Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2983E6B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 07:26:20 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so15326459wic.0
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 04:26:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa4si4030160wib.45.2015.09.25.04.26.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 25 Sep 2015 04:26:19 -0700 (PDT)
Date: Fri, 25 Sep 2015 13:26:17 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC v2 07/18] kthread: Allow to cancel kthread work
Message-ID: <20150925112617.GA3122@pathway.suse.cz>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-8-git-send-email-pmladek@suse.com>
 <20150922193513.GE17659@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150922193513.GE17659@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 2015-09-22 15:35:13, Tejun Heo wrote:
> On Mon, Sep 21, 2015 at 03:03:48PM +0200, Petr Mladek wrote:
> >  /**
> > + * try_to_grab_pending_kthread_work - steal kthread work item from worklist,
> > + *	and disable irq
> > + * @work: work item to steal
> > + * @is_dwork: @work is a delayed_work
> > + * @flags: place to store irq state
> > + *
> > + * Try to grab PENDING bit of @work.  This function can handle @work in any
> > + * stable state - idle, on timer or on worklist.
> > + *
> > + * Return:
> > + *  1		if @work was pending and we successfully stole PENDING
> > + *  0		if @work was idle and we claimed PENDING
> > + *  -EAGAIN	if PENDING couldn't be grabbed at the moment, safe to busy-retry
> > + *  -ENOENT	if someone else is canceling @work, this state may persist
> > + *		for arbitrarily long
> > + *
> > + * Note:
> > + * On >= 0 return, the caller owns @work's PENDING bit.  To avoid getting
> > + * interrupted while holding PENDING and @work off queue, irq must be
> > + * disabled on return.  This, combined with delayed_work->timer being
> > + * irqsafe, ensures that we return -EAGAIN for finite short period of time.
> > + *
> > + * On successful return, >= 0, irq is disabled and the caller is
> > + * responsible for releasing it using local_irq_restore(*@flags).
> > + *
> > + * This function is safe to call from any context including IRQ handler.
> > + */
> 
> Ugh... I think this is way too much for kthread_worker.  Workqueue is
> as complex as it is partly for historical reasons and partly because
> it's used so widely and heavily.  kthread_worker is always guaranteed
> to have a single worker and in most cases maybe several work items.
> There's no reason to bring this level of complexity onto it.
> Providing simliar semantics is fine but it should be possible to do
> this in a lot simpler way if the requirements on space and concurrency
> is this much lower.
> 
> e.g. always embed timer_list in a work item and use per-worker
> spinlock to synchronize access to both the work item and timer and use
> per-work-item mutex to synchronize multiple cancelers.  Let's please
> keep it simple.

I thought about it a lot and I do not see a way how to make it easier
using the locks.

I guess that you are primary interested into the two rather
complicated things:


1) PENDING state plus -EAGAIN/busy loop cycle
---------------------------------------------

IMHO, we want to use the timer because it is an elegant solution.
Then we must release the lock when the timer is running. The lock
must be taken by the timer->function(). And there is a small window
when the timer is not longer pending but timer->function is not running:

CPU0                            CPU1

run_timer_softirq()
  __run_timers()
    detach_expired_timer()
      detach_timer()
	#clear_pending

				try_to_grab_pending_kthread_work()
				  del_timer()
				    # fails because not pending

				  test_and_set_bit(KTHREAD_WORK_PENDING_BIT)
				    # fails because already set

				  if (!list_empty(&work->node))
				    # fails because still not queued

			!!! problematic window !!!

    call_timer_fn()
     queue_kthraed_work()


2) CANCEL state plus custom waitqueue
-------------------------------------

cancel_kthread_work_sync() has to wait for the running work. It might take
quite some time. Therefore we could not block others by a spinlock.
Also others could not wait for the spin lock in a busy wait.


IMHO, the proposed and rather complex solutions are needed in both cases.

Or did I miss a possible trick, please?

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
