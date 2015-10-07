Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id EA6A26B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 05:21:33 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so203540886wic.0
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 02:21:33 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f12si11113358wjs.18.2015.10.07.02.21.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 Oct 2015 02:21:32 -0700 (PDT)
Date: Wed, 7 Oct 2015 11:21:30 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC v2 07/18] kthread: Allow to cancel kthread work
Message-ID: <20151007092130.GD3122@pathway.suse.cz>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-8-git-send-email-pmladek@suse.com>
 <20150922193513.GE17659@mtj.duckdns.org>
 <20150925112617.GA3122@pathway.suse.cz>
 <20150928170314.GF2589@mtj.duckdns.org>
 <20151002154336.GC3122@pathway.suse.cz>
 <20151002192453.GA7564@mtj.duckdns.org>
 <20151005100758.GK9603@pathway.suse.cz>
 <20151005110924.GL9603@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151005110924.GL9603@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 2015-10-05 13:09:24, Petr Mladek wrote:
> On Mon 2015-10-05 12:07:58, Petr Mladek wrote:
> > On Fri 2015-10-02 15:24:53, Tejun Heo wrote:
> > > Hello,
> > > 
> > > On Fri, Oct 02, 2015 at 05:43:36PM +0200, Petr Mladek wrote:
> > > > IMHO, we need both locks. The worker manipulates more works and
> > > > need its own lock. We need work-specific lock because the work
> > > > might be assigned to different workers and we need to be sure
> > > > that the operations are really serialized, e.g. queuing.
> > > 
> > > I don't think we need per-work lock.  Do we have such usage in kernel
> > > at all?  If you're worried, let the first queueing record the worker
> > > and trigger warning if someone tries to queue it anywhere else.  This
> > > doesn't need to be full-on general like workqueue.  Let's make
> > > reasonable trade-offs where possible.
> > 
> > I actually thought about this simplification as well. But then I am
> > in doubts about the API. It would make sense to assign the worker
> > when the work is being initialized and avoid the duplicate information
> > when the work is being queued:
> > 
> > 	init_kthread_work(work, fn, worker);
> > 	queue_work(work);
> > 
> > Or would you prefer to keep the API similar to workqueues even when
> > it makes less sense here?
> > 
> > 
> > In each case, we need a way to switch the worker if the old one
> > is destroyed and a new one is started later. We would need
> > something like:
> > 
> > 	reset_work(work, worker)
> > or
> > 	reinit_work(work, fn, worker)
> 
> I was too fast. We could set "work->worker = NULL" when the work
> finishes and it is not pending. It means that it will be connected
> to the particular worker only when used. Then we could keep the
> workqueues-like API and do not need reset_work().

I have played with this idea and the result is not satisfactory.
I am not able to make the code easier using the single lock.

First, the worker lock is not enough to safely queue the work
without a test_and_set() atomic operation. Let me show this on
a pseudo code:

bool queue_kthread_work(worker, work)
{
	bool ret = false;

	lock(&worker->lock);

	if (test_bit(WORK_PENDING, work->flags);
		goto out;

	if (WARN(work->worker != worker,
		 "Work could not be used by two workers at the same time\n"))
		goto out;

	set_bit(WORK_PENDING, work->flags);
	work->worker = worker;
	insert_work(worker->work_list, work);
	ret = true;

out:
	unlock(&worker->lock);
	return ret;
}

Now, let's have one work: W, two workers: A, B, and try to queue
the same work to the two workers at the same time:

CPU0					CPU1

queue_kthread_work(A, W);		queue_kthread_work(B, W);
  lock(&A->lock);			lock(&B->lock);
  test_bit(WORK_PENDING, W->flags)      test_bit(WORK_PENDING, W->flags)
    # false				  # false
  WARN(W->worker != A);			WARN(W->worker != B);
    # false				  # false

  set_bit(WORK_PENDING, W->flags);	set_bit(WORK_PENDING, W->flags);
  W->worker = A;			W->worker = B;
  insert_work(A->work_list, W);		insert_work(B->work_list, W);

  unlock(&A->lock);			unlock(&B->lock);

=> It is possible and the result is unclear.

We would need to set either WORK_PENDING flag or the work->worker
using a test_and_set atomic operation and bail out if it fails.
But then we are back in the original code.


Second, we still need the busy waiting for the pending timer callback.
Yes, we could set some flag so that the call back does not queue
the work. But cancel_kthread_work_sync() still has to wait.
It could not return if there is still some pending operation
with the struct kthread_work. Otherwise, it never could
be freed a safe way.

Also note that we still need the WORK_PENDING flag. Otherwise, we
would not be able to detect the race when timer is removed but
the callback has not run yet.


Let me to repeat that using per-work and per-worker lock is not an
option either. We would need some crazy hacks to avoid ABBA deadlocks.


All in all, I would prefer to keep the original approach that is
heavily inspired by the workqueues. I think that it is actually
an advantage to reuse some working concept that reinventing wheels.


Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
