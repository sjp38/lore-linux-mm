Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 875AC6B0253
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 10:58:20 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id o60so14132349wrc.14
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 07:58:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4si3445994edd.36.2017.11.24.07.58.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 07:58:18 -0800 (PST)
Date: Fri, 24 Nov 2017 16:58:16 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171124155816.pxp345ch4gevjqjm@pathway.suse.cz>
References: <20171108102723.602216b1@gandalf.local.home>
 <20171124152857.ahnapnwmmsricunz@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171124152857.ahnapnwmmsricunz@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>

On Fri 2017-11-24 16:54:16, Petr Mladek wrote:
> On Wed 2017-11-08 10:27:23, Steven Rostedt wrote:
> > If there is a waiter, then it breaks out of the loop, clears the waiter
> > flag (because that will release the waiter from its spin), and exits.
> > Note, it does *not* release the console semaphore. Because it is a
> > semaphore, there is no owner.
> 
> > Index: linux-trace.git/kernel/printk/printk.c
> > ===================================================================
> > --- linux-trace.git.orig/kernel/printk/printk.c
> > +++ linux-trace.git/kernel/printk/printk.c
> > @@ -86,8 +86,15 @@ EXPORT_SYMBOL_GPL(console_drivers);
> >  static struct lockdep_map console_lock_dep_map = {
> >  	.name = "console_lock"
> >  };
> > +static struct lockdep_map console_owner_dep_map = {
> > +	.name = "console_owner"
> > +};
> >  #endif
> >  
> > +static DEFINE_RAW_SPINLOCK(console_owner_lock);
> > +static struct task_struct *console_owner;
> > +static bool console_waiter;
> > +
> >  enum devkmsg_log_bits {
> >  	__DEVKMSG_LOG_BIT_ON = 0,
> >  	__DEVKMSG_LOG_BIT_OFF,
> > @@ -1753,8 +1760,56 @@ asmlinkage int vprintk_emit(int facility
> >  		 * semaphore.  The release will print out buffers and wake up
> >  		 * /dev/kmsg and syslog() users.
> >  		 */
> > -		if (console_trylock())
> > +		if (console_trylock()) {
> >  			console_unlock();
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
> > +				printk_safe_exit_irqrestore(flags);
> > +
> > +				/*
> > +				 * The owner passed the console lock to us.
> > +				 * Since we did not spin on console lock, annotate
> > +				 * this as a trylock. Otherwise lockdep will
> > +				 * complain.
> > +				 */
> > +				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
> 
> I am not sure that this correctly imitates the real lock
> dependency. The trylock flag means that we are able to skip
> this section when the lock is taken elsewhere. But it is not
> the whole truth. In fact, we are blocked in this code path
> when console_sem is taken by another process.
> 
> The use of console_owner_lock is not enough. The other
> console_sem calls a lot of code outside the section
> guarded by console_owner_lock.
> 
> I think that we have actually entered the cross-release bunch
> of problems, see https://lwn.net/Articles/709849/
> 
> IMHO, we need to use struct lockdep_map_cross for
> console_lock_dep_map. Also we need to put somewhere
> lock_commit_crosslock().
> 
> I am going to play with it. Also I add Byungchul Park into CC.
> This is why I keep most of the context in this reply (I am sorry
> for it).

See my first attempt below. I do not get any lockdep
warning but it is possible that I just did it wrong.
