Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3B386B0033
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 03:48:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id s11so28466851pgc.13
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 00:48:36 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id u79si18904959pfa.354.2017.11.27.00.48.34
        for <linux-mm@kvack.org>;
        Mon, 27 Nov 2017 00:48:35 -0800 (PST)
Date: Mon, 27 Nov 2017 17:48:22 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171127084822.GA15859@X58A-UD3R>
References: <20171108102723.602216b1@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108102723.602216b1@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, yuwang.yuwang@alibabab-inc.com, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, kernel-team@lge.com

On Wed, Nov 08, 2017 at 10:27:23AM -0500, Steven Rostedt wrote:
> --- linux-trace.git.orig/kernel/printk/printk.c
> +++ linux-trace.git/kernel/printk/printk.c
> @@ -86,8 +86,15 @@ EXPORT_SYMBOL_GPL(console_drivers);
>  static struct lockdep_map console_lock_dep_map = {
>  	.name = "console_lock"
>  };
> +static struct lockdep_map console_owner_dep_map = {
> +	.name = "console_owner"
> +};
>  #endif
>  
> +static DEFINE_RAW_SPINLOCK(console_owner_lock);
> +static struct task_struct *console_owner;
> +static bool console_waiter;
> +
>  enum devkmsg_log_bits {
>  	__DEVKMSG_LOG_BIT_ON = 0,
>  	__DEVKMSG_LOG_BIT_OFF,
> @@ -1753,8 +1760,56 @@ asmlinkage int vprintk_emit(int facility
>  		 * semaphore.  The release will print out buffers and wake up
>  		 * /dev/kmsg and syslog() users.
>  		 */
> -		if (console_trylock())
> +		if (console_trylock()) {
>  			console_unlock();
> +		} else {
> +			struct task_struct *owner = NULL;
> +			bool waiter;
> +			bool spin = false;
> +
> +			printk_safe_enter_irqsave(flags);
> +
> +			raw_spin_lock(&console_owner_lock);
> +			owner = READ_ONCE(console_owner);
> +			waiter = READ_ONCE(console_waiter);
> +			if (!waiter && owner && owner != current) {
> +				WRITE_ONCE(console_waiter, true);
> +				spin = true;
> +			}
> +			raw_spin_unlock(&console_owner_lock);
> +
> +			/*
> +			 * If there is an active printk() writing to the
> +			 * consoles, instead of having it write our data too,
> +			 * see if we can offload that load from the active
> +			 * printer, and do some printing ourselves.
> +			 * Go into a spin only if there isn't already a waiter
> +			 * spinning, and there is an active printer, and
> +			 * that active printer isn't us (recursive printk?).
> +			 */
> +			if (spin) {
> +				/* We spin waiting for the owner to release us */
> +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);

Hello Steven,

I think it would be better to use cross-release stuff here, because the
waiter waits for an event which happens in another context.

> +				/* Owner will clear console_waiter on hand off */
> +				while (READ_ONCE(console_waiter))
> +					cpu_relax();
> +
> +				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> +				printk_safe_exit_irqrestore(flags);
> +
> +				/*
> +				 * The owner passed the console lock to us.
> +				 * Since we did not spin on console lock, annotate
> +				 * this as a trylock. Otherwise lockdep will
> +				 * complain.
> +				 */
> +				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);

I'm afraid if it's ok even not to lock(or trylock) actually here. Is there
any problem if you call console_trylock() instead of mutex_acquire() here?

> +				console_unlock();
> +				printk_safe_enter_irqsave(flags);
> +			}
> +			printk_safe_exit_irqrestore(flags);
> +
> +		}
>  	}
>  
>  	return printed_len;
> @@ -2141,6 +2196,7 @@ void console_unlock(void)
>  	static u64 seen_seq;
>  	unsigned long flags;
>  	bool wake_klogd = false;
> +	bool waiter = false;
>  	bool do_cond_resched, retry;
>  
>  	if (console_suspended) {
> @@ -2229,14 +2285,64 @@ skip:
>  		console_seq++;
>  		raw_spin_unlock(&logbuf_lock);
>  
> +		/*
> +		 * While actively printing out messages, if another printk()
> +		 * were to occur on another CPU, it may wait for this one to
> +		 * finish. This task can not be preempted if there is a
> +		 * waiter waiting to take over.
> +		 */
> +		raw_spin_lock(&console_owner_lock);
> +		console_owner = current;
> +		raw_spin_unlock(&console_owner_lock);
> +
> +		/* The waiter may spin on us after setting console_owner */
> +		spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);

If you want to do this speculatively here, I think it would be better to
use a read recursive acquisition. I think spin_acquire() is too stong
for that purpose - I also mentioned it on workqueue flush code. Don't
you think so?

> +
>  		stop_critical_timings();	/* don't trace print latency */
>  		call_console_drivers(ext_text, ext_len, text, len);
>  		start_critical_timings();
> +
> +		raw_spin_lock(&console_owner_lock);
> +		waiter = READ_ONCE(console_waiter);
> +		console_owner = NULL;
> +		raw_spin_unlock(&console_owner_lock);
> +
> +		/*
> +		 * If there is a waiter waiting for us, then pass the
> +		 * rest of the work load over to that waiter.
> +		 */
> +		if (waiter)
> +			break;
> +
> +		/* There was no waiter, and nothing will spin on us here */
> +		spin_release(&console_owner_dep_map, 1, _THIS_IP_);

I think this release() can be moved up over 'if (waiter)' because only
waiters within the region between acquire() and release() are meaningful.

> +
>  		printk_safe_exit_irqrestore(flags);
>  
>  		if (do_cond_resched)
>  			cond_resched();
>  	}
> +
> +	/*
> +	 * If there is an active waiter waiting on the console_lock.
> +	 * Pass off the printing to the waiter, and the waiter
> +	 * will continue printing on its CPU, and when all writing
> +	 * has finished, the last printer will wake up klogd.
> +	 */
> +	if (waiter) {
> +		WRITE_ONCE(console_waiter, false);
> +		/* The waiter is now free to continue */
> +		spin_release(&console_owner_dep_map, 1, _THIS_IP_);

So this can be removed.

Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
