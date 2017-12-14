Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 66FD66B0260
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:51:12 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a74so4729025pfg.20
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 05:51:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si3255114pfe.403.2017.12.14.05.51.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 05:51:10 -0800 (PST)
Date: Thu, 14 Dec 2017 14:51:02 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171214135102.hjlii7jhqgvyolqr@pathway.suse.cz>
References: <20171108102723.602216b1@gandalf.local.home>
 <20171124152857.ahnapnwmmsricunz@pathway.suse.cz>
 <20171124155816.pxp345ch4gevjqjm@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171124155816.pxp345ch4gevjqjm@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>

On Fri 2017-11-24 16:58:16, Petr Mladek wrote:
> On Fri 2017-11-24 16:54:16, Petr Mladek wrote:
> > On Wed 2017-11-08 10:27:23, Steven Rostedt wrote:
> > > If there is a waiter, then it breaks out of the loop, clears the waiter
> > > flag (because that will release the waiter from its spin), and exits.
> > > Note, it does *not* release the console semaphore. Because it is a
> > > semaphore, there is no owner.
> > 
> > > Index: linux-trace.git/kernel/printk/printk.c
> > > ===================================================================
> > > --- linux-trace.git.orig/kernel/printk/printk.c
> > > +++ linux-trace.git/kernel/printk/printk.c
> > > @@ -86,8 +86,15 @@ EXPORT_SYMBOL_GPL(console_drivers);
> > >  static struct lockdep_map console_lock_dep_map = {
> > >  	.name = "console_lock"
> > >  };
> > > +static struct lockdep_map console_owner_dep_map = {
> > > +	.name = "console_owner"
> > > +};
> > >  #endif
> > >  
> > > +static DEFINE_RAW_SPINLOCK(console_owner_lock);
> > > +static struct task_struct *console_owner;
> > > +static bool console_waiter;
> > > +
> > >  enum devkmsg_log_bits {
> > >  	__DEVKMSG_LOG_BIT_ON = 0,
> > >  	__DEVKMSG_LOG_BIT_OFF,
> > > @@ -1753,8 +1760,56 @@ asmlinkage int vprintk_emit(int facility
> > >  		 * semaphore.  The release will print out buffers and wake up
> > >  		 * /dev/kmsg and syslog() users.
> > >  		 */
> > > -		if (console_trylock())
> > > +		if (console_trylock()) {
> > >  			console_unlock();
> > > +		} else {
> > > +			struct task_struct *owner = NULL;
> > > +			bool waiter;
> > > +			bool spin = false;
> > > +
> > > +			printk_safe_enter_irqsave(flags);
> > > +
> > > +			raw_spin_lock(&console_owner_lock);
> > > +			owner = READ_ONCE(console_owner);
> > > +			waiter = READ_ONCE(console_waiter);
> > > +			if (!waiter && owner && owner != current) {
> > > +				WRITE_ONCE(console_waiter, true);
> > > +				spin = true;
> > > +			}
> > > +			raw_spin_unlock(&console_owner_lock);
> > > +
> > > +			/*
> > > +			 * If there is an active printk() writing to the
> > > +			 * consoles, instead of having it write our data too,
> > > +			 * see if we can offload that load from the active
> > > +			 * printer, and do some printing ourselves.
> > > +			 * Go into a spin only if there isn't already a waiter
> > > +			 * spinning, and there is an active printer, and
> > > +			 * that active printer isn't us (recursive printk?).
> > > +			 */
> > > +			if (spin) {
> > > +				/* We spin waiting for the owner to release us */
> > > +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> > > +				/* Owner will clear console_waiter on hand off */
> > > +				while (READ_ONCE(console_waiter))
> > > +					cpu_relax();
> > > +
> > > +				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> > > +				printk_safe_exit_irqrestore(flags);
> > > +
> > > +				/*
> > > +				 * The owner passed the console lock to us.
> > > +				 * Since we did not spin on console lock, annotate
> > > +				 * this as a trylock. Otherwise lockdep will
> > > +				 * complain.
> > > +				 */
> > > +				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
> > 
> > I am not sure that this correctly imitates the real lock
> > dependency. The trylock flag means that we are able to skip
> > this section when the lock is taken elsewhere. But it is not
> > the whole truth. In fact, we are blocked in this code path
> > when console_sem is taken by another process.
> > 
> > The use of console_owner_lock is not enough. The other
> > console_sem calls a lot of code outside the section
> > guarded by console_owner_lock.

Ah, I confused here console_owner_lock and console_owner_dep_map.
The custom map covers all the code where console_owner is set.
It might be enough to catch a potential bug after all.


> > I think that we have actually entered the cross-release bunch
> > of problems, see https://lwn.net/Articles/709849/

Also I think that we do not need the cross-release stuff after all.
The thing is that we move console_sem only to printk() call
that normally calls console_unlock() as well. It means that
the transferred owner should not bring new type of dependencies.
As Steven said somewhere: "If there is a deadlock, it was
there even before."

We could look at it from this side. The possible deadlock would
look like:

CPU0				CPU1

console_unlock()

  console_owner = current;

				spin_lockA()
				  printk()
				    spin = true;
				    while (...)

    call_console_drivers()
      spin_lockA()

This would be a deadlock. CPU0 would wait for the lock A.
While CPU1 would own the lockA and would wait for CPU0
to finish calling the console drivers and pass the console_sem
owner.

But if the above is true than the following scenario was
already possible before:

CPU0

spin_lockA()
  printk()
    console_unlock()
      call_console_drivers()
	spin_lockA()

By other words, this deadlock was there even before. Such
deadlocks are prevented by using printk_deferred() in
the sections guarded by the lock A.

I am sorry for the noise and that it took me so long to
get over this. Well, nobody said that there was something
wrong with my fears and why. I hope that I did not simplified
it too much this time ;-)

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
