Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E4B026B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:53:57 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i123so28501035pgd.2
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:53:57 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id d81si9264233pfj.183.2017.11.27.00.53.56
        for <linux-mm@kvack.org>;
        Mon, 27 Nov 2017 00:53:56 -0800 (PST)
Date: Mon, 27 Nov 2017 17:53:43 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171127085343.GB15859@X58A-UD3R>
References: <20171108102723.602216b1@gandalf.local.home>
 <20171124152857.ahnapnwmmsricunz@pathway.suse.cz>
 <20171124155816.pxp345ch4gevjqjm@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171124155816.pxp345ch4gevjqjm@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, kernel-team@lge.com

On Fri, Nov 24, 2017 at 04:58:16PM +0100, Petr Mladek wrote:
> On Fri 2017-11-24 16:54:16, Petr Mladek wrote:
> > On Wed 2017-11-08 10:27:23, Steven Rostedt wrote:
> > > If there is a waiter, then it breaks out of the loop, clears the waiter
> > > flag (because that will release the waiter from its spin), and exits.
> > > Note, it does *not* release the console semaphore. Because it is a
> > > semaphore, there is no owner.

Hello Petr,

Thank you for adding me into this thread.

You seem to change console_lock_dep_map to cross-release stuff. I will
add my opinion after reviewing it :)

Thanks,
Byungchul

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
> > 
> > I think that we have actually entered the cross-release bunch
> > of problems, see https://lwn.net/Articles/709849/
> > 
> > IMHO, we need to use struct lockdep_map_cross for
> > console_lock_dep_map. Also we need to put somewhere
> > lock_commit_crosslock().
> > 
> > I am going to play with it. Also I add Byungchul Park into CC.
> > This is why I keep most of the context in this reply (I am sorry
> > for it).
> 
> See my first attempt below. I do not get any lockdep
> warning but it is possible that I just did it wrong.
> 
> 
> >From 0345785d4767f853ff2d733b565084c3339f9fe0 Mon Sep 17 00:00:00 2001
> From: Petr Mladek <pmladek@suse.com>
> Date: Fri, 24 Nov 2017 16:50:25 +0100
> Subject: [PATCH] printk: Try to describe real console_sem dependecies using
>  the crosslock feature
> 
> console_sem might be newly taken and released by different
> processes. This is an attempt to check the crossrelease
> dependencies.
> ---
>  kernel/printk/printk.c | 25 +++++++++----------------
>  1 file changed, 9 insertions(+), 16 deletions(-)
> 
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index 040fb948924e..bda25feae0d5 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -83,9 +83,9 @@ struct console *console_drivers;
>  EXPORT_SYMBOL_GPL(console_drivers);
>  
>  #ifdef CONFIG_LOCKDEP
> -static struct lockdep_map console_lock_dep_map = {
> -	.name = "console_lock"
> -};
> +static struct lockdep_map_cross console_lock_dep_map =
> +	STATIC_CROSS_LOCKDEP_MAP_INIT("console_lock", &console_sem);
> +
>  static struct lockdep_map console_owner_dep_map = {
>  	.name = "console_owner"
>  };
> @@ -218,7 +218,7 @@ static int nr_ext_console_drivers;
>   */
>  #define down_console_sem() do { \
>  	down(&console_sem);\
> -	mutex_acquire(&console_lock_dep_map, 0, 0, _RET_IP_);\
> +	mutex_acquire((struct lockdep_map *)&console_lock_dep_map, 0, 0, _RET_IP_);\
>  } while (0)
>  
>  static int __down_trylock_console_sem(unsigned long ip)
> @@ -237,7 +237,7 @@ static int __down_trylock_console_sem(unsigned long ip)
>  
>  	if (lock_failed)
>  		return 1;
> -	mutex_acquire(&console_lock_dep_map, 0, 1, ip);
> +	mutex_acquire((struct lockdep_map *)&console_lock_dep_map, 0, 1, ip);
>  	return 0;
>  }
>  #define down_trylock_console_sem() __down_trylock_console_sem(_RET_IP_)
> @@ -246,7 +246,7 @@ static void __up_console_sem(unsigned long ip)
>  {
>  	unsigned long flags;
>  
> -	mutex_release(&console_lock_dep_map, 1, ip);
> +	mutex_release((struct lockdep_map *)&console_lock_dep_map, 1, ip);
>  
>  	printk_safe_enter_irqsave(flags);
>  	up(&console_sem);
> @@ -1797,13 +1797,6 @@ asmlinkage int vprintk_emit(int facility, int level,
>  				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
>  				printk_safe_exit_irqrestore(flags);
>  
> -				/*
> -				 * The owner passed the console lock to us.
> -				 * Since we did not spin on console lock, annotate
> -				 * this as a trylock. Otherwise lockdep will
> -				 * complain.
> -				 */
> -				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
>  				console_unlock();
>  				printk_safe_enter_irqsave(flags);
>  			}
> @@ -2334,10 +2327,10 @@ void console_unlock(void)
>  		/* The waiter is now free to continue */
>  		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
>  		/*
> -		 * Hand off console_lock to waiter. The waiter will perform
> -		 * the up(). After this, the waiter is the console_lock owner.
> +		 * Hand off console_lock to waiter. After this, the waiter
> +		 * is the console_lock owner.
>  		 */
> -		mutex_release(&console_lock_dep_map, 1, _THIS_IP_);
> +		lock_commit_crosslock((struct lockdep_map *)&console_lock_dep_map);
>  		printk_safe_exit_irqrestore(flags);
>  		/* Note, if waiter is set, logbuf_lock is not held */
>  		return;
> -- 
> 2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
