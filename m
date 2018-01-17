Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6472528029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 07:04:54 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id f3so3857832wmc.8
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:04:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8si3588983wre.211.2018.01.17.04.04.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Jan 2018 04:04:52 -0800 (PST)
Date: Wed, 17 Jan 2018 13:04:46 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 1/2] printk: Add console owner and waiter logic to
 load balance console writes
Message-ID: <20180117120446.44ewafav7epaibde@pathway.suse.cz>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110132418.7080-2-pmladek@suse.com>
 <f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f4ea1404-404d-11d2-550c-7367add3f5fa@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Wed 2018-01-17 11:19:53, Byungchul Park wrote:
> On 1/10/2018 10:24 PM, Petr Mladek wrote:
> > From: Steven Rostedt <rostedt@goodmis.org>
> > By Petr Mladek about possible new deadlocks:
> > 
> > The thing is that we move console_sem only to printk() call
> > that normally calls console_unlock() as well. It means that
> > the transferred owner should not bring new type of dependencies.
> > As Steven said somewhere: "If there is a deadlock, it was
> > there even before."
> > 
> > We could look at it from this side. The possible deadlock would
> > look like:
> > 
> > CPU0                            CPU1
> > 
> > console_unlock()
> > 
> >    console_owner = current;
> > 
> > 				spin_lockA()
> > 				  printk()
> > 				    spin = true;
> > 				    while (...)
> > 
> >      call_console_drivers()
> >        spin_lockA()
> > 
> > This would be a deadlock. CPU0 would wait for the lock A.
> > While CPU1 would own the lockA and would wait for CPU0
> > to finish calling the console drivers and pass the console_sem
> > owner.
> > 
> > But if the above is true than the following scenario was
> > already possible before:
> > 
> > CPU0
> > 
> > spin_lockA()
> >    printk()
> >      console_unlock()
> >        call_console_drivers()
> > 	spin_lockA()
> > 
> > By other words, this deadlock was there even before. Such
> > deadlocks are prevented by using printk_deferred() in
> > the sections guarded by the lock A.
> 
> Hello,
> 
> I didn't see what you did, at the last version. You were
> tring to transfer the semaphore owner and make it taken
> over. I see.

I realized that I did not understand lockdep and especially
the cross-release stuff enough to be sure about the annotations.
In addition, the cross-release feature was removed, ...

Instead, I made a proof by contradiction. A very simplified
summary is mentioned in the commit message above. I believe
that the new dependency actually does not bring any new risk
of a deadlock.

Anyway, the last version of the code can be found in printk.git,
for-4.16-console-waiter-logic branch, see
https://git.kernel.org/pub/scm/linux/kernel/git/pmladek/printk.git/log/?h=for-4.16-console-waiter-logic

It is also merged into linux-next.

> > diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> > index b9006617710f..7e6459abba43 100644
> > --- a/kernel/printk/printk.c
> > +++ b/kernel/printk/printk.c
> > @@ -1753,8 +1760,56 @@ asmlinkage int vprintk_emit(int facility, int level,
> >   		 * semaphore.  The release will print out buffers and wake up
> >   		 * /dev/kmsg and syslog() users.
> >   		 */
> > -		if (console_trylock())
> > +		if (console_trylock()) {
> >   			console_unlock();
> > +		} else {
> > +			struct task_struct *owner = NULL;
> > +			bool waiter;
> > +			bool spin = false;
> > +
> > +			printk_safe_enter_irqsave(flags);
> > +
> > +			raw_spin_lock(&console_owner_lock);
> > +			owner = READ_ONCE(console_owner);
> > +			waiter = READ_ONCE(console_waiter);
> > +			if (!waiter && owner && owner != current) {
> > +				WRITE_ONCE(console_waiter, true);
> > +				spin = true;
> > +			}
> > +			raw_spin_unlock(&console_owner_lock);
> > +
> > +			/*
> > +			 * If there is an active printk() writing to the
> > +			 * consoles, instead of having it write our data too,
> > +			 * see if we can offload that load from the active
> > +			 * printer, and do some printing ourselves.
> > +			 * Go into a spin only if there isn't already a waiter
> > +			 * spinning, and there is an active printer, and
> > +			 * that active printer isn't us (recursive printk?).
> > +			 */
> > +			if (spin) {
> > +				/* We spin waiting for the owner to release us */
> > +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> > +				/* Owner will clear console_waiter on hand off */
> > +				while (READ_ONCE(console_waiter))
> > +					cpu_relax();
> > +
> > +				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> 
> Why don't you move this over "while (READ_ONCE(console_waiter))" and
> right after acquire()?
>
> As I said last time, only acquisitions between acquire() and release()
> are meaningful. Are you taking care of acquisitions within cpu_relax()?
> If so, leave it.

We are simulating a spinlock here. The above code corresponds to

	    spin_lock(&console_owner_spin_lock);
	    spin_unlock(&console_owner_spin_lock);

I mean that spin_acquire() + while-cycle corresponds
to spin_lock(). And spin_release() corresponds to
spin_unlock().

> > +				printk_safe_exit_irqrestore(flags);
> > +
> > +				/*
> > +				 * The owner passed the console lock to us.
> > +				 * Since we did not spin on console lock, annotate
> > +				 * this as a trylock. Otherwise lockdep will
> > +				 * complain.
> > +				 */
> > +				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
> > +				console_unlock();
> > +				printk_safe_enter_irqsave(flags);
> > +			}
> > +			printk_safe_exit_irqrestore(flags);
> > +
> > +		}
> >   	}
> >   	return printed_len;
> > @@ -2141,6 +2196,7 @@ void console_unlock(void)
> >   	static u64 seen_seq;
> >   	unsigned long flags;
> >   	bool wake_klogd = false;
> > +	bool waiter = false;
> >   	bool do_cond_resched, retry;
> >   	if (console_suspended) {
> > @@ -2229,14 +2285,64 @@ void console_unlock(void)
> >   		console_seq++;
> >   		raw_spin_unlock(&logbuf_lock);
> > +		/*
> > +		 * While actively printing out messages, if another printk()
> > +		 * were to occur on another CPU, it may wait for this one to
> > +		 * finish. This task can not be preempted if there is a
> > +		 * waiter waiting to take over.
> > +		 */
> > +		raw_spin_lock(&console_owner_lock);
> > +		console_owner = current;
> > +		raw_spin_unlock(&console_owner_lock);
> > +
> > +		/* The waiter may spin on us after setting console_owner */
> > +		spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> > +
> >   		stop_critical_timings();	/* don't trace print latency */
> >   		call_console_drivers(ext_text, ext_len, text, len);
> >   		start_critical_timings();
> > +
> > +		raw_spin_lock(&console_owner_lock);
> > +		waiter = READ_ONCE(console_waiter);
> > +		console_owner = NULL;
> > +		raw_spin_unlock(&console_owner_lock);
> > +
> > +		/*
> > +		 * If there is a waiter waiting for us, then pass the
> > +		 * rest of the work load over to that waiter.
> > +		 */
> > +		if (waiter)
> > +			break;
> > +
> > +		/* There was no waiter, and nothing will spin on us here */
> > +		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> 
> Why don't you move this over "if (waiter)"?

We want to actually release the lock before calling spin_release,
see below.


> > +
> >   		printk_safe_exit_irqrestore(flags);
> >   		if (do_cond_resched)
> >   			cond_resched();
> >   	}
> > +
> > +	/*
> > +	 * If there is an active waiter waiting on the console_lock.
> > +	 * Pass off the printing to the waiter, and the waiter
> > +	 * will continue printing on its CPU, and when all writing
> > +	 * has finished, the last printer will wake up klogd.
> > +	 */
> > +	if (waiter) {
> > +		WRITE_ONCE(console_waiter, false);
> > +		/* The waiter is now free to continue */
> > +		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> 
> Why don't you remove this release() after relocating the upper one?

The manipulation of "console_waiter" implements the spin_lock that
we are trying to simulate. It is such easy because it is guaranteed
that there is always only one process that tries to get this
fake spin_lock. Also the other waiter releases the spin lock
immediately after it gets it.

I mean that WRITE_ONCE(console_waiter, false) causes that
the simulated spin lock is released here. Also the while-cycle
in vprintk_emit() succeeds. The while-cycle success means
that vprintk_emit() actually acquires the simulated spinlock.

This synchronization is need to make sure that the two processes
pass the console_lock ownership at the right place.

I think that at least this simulated spin lock is annotated the right
way by console_owner_dep_map manipulations. And I think that we
do not need the cross-release feature to simulate this spin lock.


> > +		/*
> > +		 * Hand off console_lock to waiter. The waiter will perform
> > +		 * the up(). After this, the waiter is the console_lock owner.
> > +		 */
> > +		mutex_release(&console_lock_dep_map, 1, _THIS_IP_);

The cross-release feature might be needed here. The above annotation
says that the semaphore is release here. In reality, it is released
in the process that calls vprintk_emit(). We actually just passed the
ownership here.

Does this make any sense? Could we do better using the existing
lockdep annotations?

If you have a better solution, it might make sense to send a patch
on top of linux-next. There is a commit that moved these code
into three helper functions:

    console_lock_spinning_enable()
    console_lock_spinning_disable_and_check()
    console_trylock_spinning()

See
https://git.kernel.org/pub/scm/linux/kernel/git/pmladek/printk.git/commit/?h=for-4.16-console-waiter-logic&id=c162d5b4338d72deed61aa65ed0f2f4ba2bbc8ab

Best Regards,
Petr

> > +		printk_safe_exit_irqrestore(flags);
> > +		/* Note, if waiter is set, logbuf_lock is not held */
> > +		return;
> > +	}
> > +
> >   	console_locked = 0;
> >   	/* Release the exclusive_console once it is used */
> > 
> 
> -- 
> Thanks,
> Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
