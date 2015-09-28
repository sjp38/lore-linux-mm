Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4356B025D
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 13:03:21 -0400 (EDT)
Received: by ykdg206 with SMTP id g206so184930083ykd.1
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 10:03:21 -0700 (PDT)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id a145si9010977ykf.43.2015.09.28.10.03.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 10:03:20 -0700 (PDT)
Received: by ykdz138 with SMTP id z138so187517525ykd.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 10:03:20 -0700 (PDT)
Date: Mon, 28 Sep 2015 13:03:14 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 07/18] kthread: Allow to cancel kthread work
Message-ID: <20150928170314.GF2589@mtj.duckdns.org>
References: <1442840639-6963-1-git-send-email-pmladek@suse.com>
 <1442840639-6963-8-git-send-email-pmladek@suse.com>
 <20150922193513.GE17659@mtj.duckdns.org>
 <20150925112617.GA3122@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150925112617.GA3122@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello, Petr.

On Fri, Sep 25, 2015 at 01:26:17PM +0200, Petr Mladek wrote:
> 1) PENDING state plus -EAGAIN/busy loop cycle
> ---------------------------------------------
> 
> IMHO, we want to use the timer because it is an elegant solution.
> Then we must release the lock when the timer is running. The lock
> must be taken by the timer->function(). And there is a small window
> when the timer is not longer pending but timer->function is not running:
> 
> CPU0                            CPU1
> 
> run_timer_softirq()
>   __run_timers()
>     detach_expired_timer()
>       detach_timer()
> 	#clear_pending
> 
> 				try_to_grab_pending_kthread_work()
> 				  del_timer()
> 				    # fails because not pending
> 
> 				  test_and_set_bit(KTHREAD_WORK_PENDING_BIT)
> 				    # fails because already set
> 
> 				  if (!list_empty(&work->node))
> 				    # fails because still not queued
> 
> 			!!! problematic window !!!
> 
>     call_timer_fn()
>      queue_kthraed_work()

Let's say each work item has a state variable which is protected by a
lock and the state can be one of IDLE, PENDING, CANCELING.  Let's also
assume that all cancelers synchronize with each other via mutex, so we
only have to worry about a single canceler.  Wouldn't something like
the following work while being a lot simpler?

Delayed queueing and execution.

1. Lock and check whether state is IDLE.  If not, nothing to do.

2. Set state to PENDING and schedule the timer and unlock.

3. On expiration, timer_fn grabs the lock and see whether state is
   still PENDING.  If so, schedule the work item for execution;
   otherwise, nothing to do.

4. After dequeueing from execution queue with lock held, the worker is
   marked as executing the work item and state is reset to IDLE.

Canceling

1. Lock, dequeue and set the state to CANCELING.

2. Unlock and perform del_timer_sync().

3. Flush the work item.

4. Lock and reset the state to IDLE and unlock.


> 2) CANCEL state plus custom waitqueue
> -------------------------------------
> 
> cancel_kthread_work_sync() has to wait for the running work. It might take
> quite some time. Therefore we could not block others by a spinlock.
> Also others could not wait for the spin lock in a busy wait.

Hmmm?  Cancelers can synchronize amongst them using a mutex and the
actual work item wait can use flushing.

> IMHO, the proposed and rather complex solutions are needed in both cases.
> 
> Or did I miss a possible trick, please?

I probably have missed something in the above and it is not completley
correct but I do think it can be way simpler than how workqueue does
it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
