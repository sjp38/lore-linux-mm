Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B77876B0033
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 11:36:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id j6so4979648pgp.21
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 08:36:33 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k10si13810806pgr.820.2018.01.12.08.36.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 08:36:32 -0800 (PST)
Date: Fri, 12 Jan 2018 11:36:27 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 2/2] printk: Hide console waiter logic into helpers
Message-ID: <20180112113627.7c454063@gandalf.local.home>
In-Reply-To: <20180112160837.GD24497@linux.suse>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110132418.7080-3-pmladek@suse.com>
	<20180110125220.69f5f930@vmware.local.home>
	<20180111120341.GB24419@linux.suse>
	<20180112103754.1916a1e2@gandalf.local.home>
	<20180112160837.GD24497@linux.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Fri, 12 Jan 2018 17:08:37 +0100
Petr Mladek <pmladek@suse.com> wrote:

> On Fri 2018-01-12 10:37:54, Steven Rostedt wrote:
> > On Thu, 11 Jan 2018 13:03:41 +0100
> > Petr Mladek <pmladek@suse.com> wrote:  
> > > All the other changes look good to me. I will use them in the next version.  
> > 
> > Great.  
> 
> Please, find below the updated version. If I get Ack at least from
> Steven and no nack's, I will put it into linux-next next week.
> 

Typos below.

> 
> >From f67f70d910d9cf310a7bc73e97bf14097d31b059 Mon Sep 17 00:00:00 2001  
> From: Petr Mladek <pmladek@suse.com>
> Date: Fri, 22 Dec 2017 18:58:46 +0100
> Subject: [PATCH v6 2/4] printk: Hide console waiter logic into helpers
> 
> The commit ("printk: Add console owner and waiter logic to load balance
> console writes") made vprintk_emit() and console_unlock() even more
> complicated.
> 
> This patch extracts the new code into 3 helper functions. They should
> help to keep it rather self-contained. It will be easier to use and
> maintain.
> 
> This patch just shuffles the existing code. It does not change
> the functionality.
> 
> Signed-off-by: Petr Mladek <pmladek@suse.com>
> ---
> Changes against v5:
>  
>   + updated some comments (Steven)
>   + do console_trylock() in console_trylock_spinning() (Steven)
> 
>  kernel/printk/printk.c | 245 +++++++++++++++++++++++++++++--------------------
>  1 file changed, 148 insertions(+), 97 deletions(-)
> 
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index 7e6459abba43..3057dbc69b4f 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -86,15 +86,8 @@ EXPORT_SYMBOL_GPL(console_drivers);
>  static struct lockdep_map console_lock_dep_map = {
>  	.name = "console_lock"
>  };
> -static struct lockdep_map console_owner_dep_map = {
> -	.name = "console_owner"
> -};
>  #endif
>  
> -static DEFINE_RAW_SPINLOCK(console_owner_lock);
> -static struct task_struct *console_owner;
> -static bool console_waiter;
> -
>  enum devkmsg_log_bits {
>  	__DEVKMSG_LOG_BIT_ON = 0,
>  	__DEVKMSG_LOG_BIT_OFF,
> @@ -1551,6 +1544,146 @@ SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
>  }
>  
>  /*
> + * Special console_lock variants that help to reduce the risk of soft-lockups.
> + * They allow to pass console_lock to another printk() call using a busy wait.
> + */
> +
> +#ifdef CONFIG_LOCKDEP
> +static struct lockdep_map console_owner_dep_map = {
> +	.name = "console_owner"
> +};
> +#endif
> +
> +static DEFINE_RAW_SPINLOCK(console_owner_lock);
> +static struct task_struct *console_owner;
> +static bool console_waiter;
> +
> +/**
> + * console_lock_spinning_enable - mark beginning of code where another
> + *	thread might safely busy wait
> + *
> + * This basically converts console_lock into a spinlock. This marks
> + * the section where the console_lock owner can not sleep, because
> + * there may be a waiter spinning (like a spinlock). Also it must be
> + * ready to hand over the lock at the end of the section.
> + */
> +static void console_lock_spinning_enable(void)
> +{
> +	raw_spin_lock(&console_owner_lock);
> +	console_owner = current;
> +	raw_spin_unlock(&console_owner_lock);
> +
> +	/* The waiter may spin on us after setting console_owner */
> +	spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> +}
> +
> +/**
> + * console_lock_spinning_disable_and_check - mark end of code where another
> + *	thread was able to busy wait and check if there is a waiter
> + *
> + * This is called at the end of the section where spinning is allowed.
> + * It has two functions. First, it is a signal that it is not longer

"it is no longer safe"

> + * safe to start busy waiting for the lock. Second, it checks if
> + * there is a busy waiter and passes the lock rights to her.
> + *
> + * Important: Callers lose the lock if there was the busy waiter.

"if there was a busy waiter"

> + *	They must not touch items synchronized by console_lock
> + *	in this case.
> + *
> + * Return: 1 if the lock rights were passed, 0 otherwise.
> + */
> +static int console_lock_spinning_disable_and_check(void)
> +{
> +	int waiter;
> +
> +	raw_spin_lock(&console_owner_lock);
> +	waiter = READ_ONCE(console_waiter);
> +	console_owner = NULL;
> +	raw_spin_unlock(&console_owner_lock);
> +
> +	if (!waiter) {
> +		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> +		return 0;
> +	}
> +
> +	/* The waiter is now free to continue */
> +	WRITE_ONCE(console_waiter, false);
> +
> +	spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> +
> +	/*
> +	 * Hand off console_lock to waiter. The waiter will perform
> +	 * the up(). After this, the waiter is the console_lock owner.
> +	 */
> +	mutex_release(&console_lock_dep_map, 1, _THIS_IP_);
> +	return 1;
> +}
> +
> +/**
> + * console_trylock_spinning - try to get console_lock by busy waiting
> + *
> + * This allows to busy wait for the console_lock when the current
> + * owner is running in a special marked sections. It means that

 "running in specially marked sections."


> + * the current owner is running and cannot reschedule until it
> + * is ready to loose the lock.

"ready to lose the lock."

> + *
> + * Return: 1 if we got the lock, 0 othrewise
> + */
> +static int console_trylock_spinning(void)
> +{
> +	struct task_struct *owner = NULL;
> +	bool waiter;
> +	bool spin = false;
> +	unsigned long flags;
> +
> +	if (console_trylock())
> +		return 1;
> +
> +	printk_safe_enter_irqsave(flags);
> +
> +	raw_spin_lock(&console_owner_lock);
> +	owner = READ_ONCE(console_owner);
> +	waiter = READ_ONCE(console_waiter);
> +	if (!waiter && owner && owner != current) {
> +		WRITE_ONCE(console_waiter, true);
> +		spin = true;
> +	}
> +	raw_spin_unlock(&console_owner_lock);
> +
> +	/*
> +	 * If there is an active printk() writing to the
> +	 * consoles, instead of having it write our data too,
> +	 * see if we can offload that load from the active
> +	 * printer, and do some printing ourselves.
> +	 * Go into a spin only if there isn't already a waiter
> +	 * spinning, and there is an active printer, and
> +	 * that active printer isn't us (recursive printk?).
> +	 */
> +	if (!spin) {
> +		printk_safe_exit_irqrestore(flags);
> +		return 0;
> +	}
> +
> +	/* We spin waiting for the owner to release us */
> +	spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> +	/* Owner will clear console_waiter on hand off */
> +	while (READ_ONCE(console_waiter))
> +		cpu_relax();
> +	spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> +
> +	printk_safe_exit_irqrestore(flags);
> +	/*
> +	 * The owner passed the console lock to us.
> +	 * Since we did not spin on console lock, annotate
> +	 * this as a trylock. Otherwise lockdep will
> +	 * complain.
> +	 */
> +	mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
> +
> +	return 1;
> +}
> +
> +/*
>   * Call the console drivers, asking them to write out
>   * log_buf[start] to log_buf[end - 1].
>   * The console_lock must be held.
> @@ -1760,56 +1893,8 @@ asmlinkage int vprintk_emit(int facility, int level,
>  		 * semaphore.  The release will print out buffers and wake up
>  		 * /dev/kmsg and syslog() users.
>  		 */
> -		if (console_trylock()) {
> +		if (console_trylock_spinning())
>  			console_unlock();
> -		} else {
> -			struct task_struct *owner = NULL;
> -			bool waiter;
> -			bool spin = false;
> -
> -			printk_safe_enter_irqsave(flags);
> -
> -			raw_spin_lock(&console_owner_lock);
> -			owner = READ_ONCE(console_owner);
> -			waiter = READ_ONCE(console_waiter);
> -			if (!waiter && owner && owner != current) {
> -				WRITE_ONCE(console_waiter, true);
> -				spin = true;
> -			}
> -			raw_spin_unlock(&console_owner_lock);
> -
> -			/*
> -			 * If there is an active printk() writing to the
> -			 * consoles, instead of having it write our data too,
> -			 * see if we can offload that load from the active
> -			 * printer, and do some printing ourselves.
> -			 * Go into a spin only if there isn't already a waiter
> -			 * spinning, and there is an active printer, and
> -			 * that active printer isn't us (recursive printk?).
> -			 */
> -			if (spin) {
> -				/* We spin waiting for the owner to release us */
> -				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> -				/* Owner will clear console_waiter on hand off */
> -				while (READ_ONCE(console_waiter))
> -					cpu_relax();
> -
> -				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> -				printk_safe_exit_irqrestore(flags);
> -
> -				/*
> -				 * The owner passed the console lock to us.
> -				 * Since we did not spin on console lock, annotate
> -				 * this as a trylock. Otherwise lockdep will
> -				 * complain.
> -				 */
> -				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
> -				console_unlock();
> -				printk_safe_enter_irqsave(flags);
> -			}
> -			printk_safe_exit_irqrestore(flags);
> -
> -		}
>  	}
>  
>  	return printed_len;
> @@ -1910,6 +1995,8 @@ static ssize_t msg_print_ext_header(char *buf, size_t size,
>  static ssize_t msg_print_ext_body(char *buf, size_t size,
>  				  char *dict, size_t dict_len,
>  				  char *text, size_t text_len) { return 0; }
> +static void console_lock_spinning_enable(void) { }
> +static int console_lock_spinning_disable_and_check(void) { return 0; }
>  static void call_console_drivers(const char *ext_text, size_t ext_len,
>  				 const char *text, size_t len) {}
>  static size_t msg_print_text(const struct printk_log *msg,
> @@ -2196,7 +2283,6 @@ void console_unlock(void)
>  	static u64 seen_seq;
>  	unsigned long flags;
>  	bool wake_klogd = false;
> -	bool waiter = false;
>  	bool do_cond_resched, retry;
>  
>  	if (console_suspended) {
> @@ -2291,31 +2377,16 @@ void console_unlock(void)
>  		 * finish. This task can not be preempted if there is a
>  		 * waiter waiting to take over.
>  		 */
> -		raw_spin_lock(&console_owner_lock);
> -		console_owner = current;
> -		raw_spin_unlock(&console_owner_lock);
> -
> -		/* The waiter may spin on us after setting console_owner */
> -		spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> +		console_lock_spinning_enable();
>  
>  		stop_critical_timings();	/* don't trace print latency */
>  		call_console_drivers(ext_text, ext_len, text, len);
>  		start_critical_timings();
>  
> -		raw_spin_lock(&console_owner_lock);
> -		waiter = READ_ONCE(console_waiter);
> -		console_owner = NULL;
> -		raw_spin_unlock(&console_owner_lock);
> -
> -		/*
> -		 * If there is a waiter waiting for us, then pass the
> -		 * rest of the work load over to that waiter.
> -		 */
> -		if (waiter)
> -			break;
> -
> -		/* There was no waiter, and nothing will spin on us here */
> -		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> +		if (console_lock_spinning_disable_and_check()) {
> +			printk_safe_exit_irqrestore(flags);
> +			return;
> +		}
>  
>  		printk_safe_exit_irqrestore(flags);
>  
> @@ -2323,26 +2394,6 @@ void console_unlock(void)
>  			cond_resched();
>  	}
>  
> -	/*
> -	 * If there is an active waiter waiting on the console_lock.
> -	 * Pass off the printing to the waiter, and the waiter
> -	 * will continue printing on its CPU, and when all writing
> -	 * has finished, the last printer will wake up klogd.
> -	 */
> -	if (waiter) {
> -		WRITE_ONCE(console_waiter, false);
> -		/* The waiter is now free to continue */
> -		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> -		/*
> -		 * Hand off console_lock to waiter. The waiter will perform
> -		 * the up(). After this, the waiter is the console_lock owner.
> -		 */
> -		mutex_release(&console_lock_dep_map, 1, _THIS_IP_);
> -		printk_safe_exit_irqrestore(flags);
> -		/* Note, if waiter is set, logbuf_lock is not held */
> -		return;
> -	}
> -
>  	console_locked = 0;
>  
>  	/* Release the exclusive_console once it is used */

Besides the typos (which should be fixed)...

Reviewed-by: Steven Rostedt (VMware) <rostedt@goodmis.org>

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
