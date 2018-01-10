Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B38626B0033
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 12:52:24 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id p14so11816958pgq.2
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 09:52:24 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j4si7331533plt.737.2018.01.10.09.52.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jan 2018 09:52:23 -0800 (PST)
Date: Wed, 10 Jan 2018 12:52:20 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 2/2] printk: Hide console waiter logic into helpers
Message-ID: <20180110125220.69f5f930@vmware.local.home>
In-Reply-To: <20180110132418.7080-3-pmladek@suse.com>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110132418.7080-3-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Wed, 10 Jan 2018 14:24:18 +0100
Petr Mladek <pmladek@suse.com> wrote:

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
>  kernel/printk/printk.c | 242 +++++++++++++++++++++++++++++--------------------
>  1 file changed, 145 insertions(+), 97 deletions(-)
> 
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index 7e6459abba43..6217c280e6c1 100644
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
> @@ -1551,6 +1544,143 @@ SYSCALL_DEFINE3(syslog, int, type, char __user *, buf, int, len)
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
> + * This might be called in sections where the current console_lock owner


"might be"? It has to be called in sections where the current
console_lock owner can not sleep. It's basically saying "console lock is
now acting like a spinlock".

> + * cannot sleep. It is a signal that another thread might start busy
> + * waiting for console_lock.
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
> + * This is called at the end of section when spinning was enabled by
> + * console_lock_spinning_enable(). It has two functions. First, it

"This is called at the end of the section where spinning is allowed."

> + * is a signal that it is not longer safe to start busy waiting

	"it is no longer safe"

> + * for the lock. Second, it checks if there is a busy waiter and
> + * passes the lock rights to her.
> + *
> + * Important: Callers lose the lock if there was the busy waiter.
> + *	They must not longer touch items synchornized by console_lock

	"They must not touch items ..."

> + *	in this case.
> + *
> + * Return: 1 if the lock rights were passed, 0 othrewise.

						"otherwise"

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
> + * the current owner is running and cannot reschedule until it
> + * is ready to loose the lock.
> + *
> + * Return: 1 if we got the lock, 0 othrewise
> + */
> +static int console_trylock_spinning(void)
> +{
> +	struct task_struct *owner = NULL;
> +	bool waiter;
> +	bool spin = false;
> +	unsigned long flags;

Can we add here:

	if (console_trylock())
		return 1;

And then we can simplify the below from:

	if (console_trylock() || console_trylock_spinning())

to just

	if (console_trylock_spinning())

-- Steve

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
> @@ -1760,56 +1890,8 @@ asmlinkage int vprintk_emit(int facility, int level,
>  		 * semaphore.  The release will print out buffers and wake up
>  		 * /dev/kmsg and syslog() users.
>  		 */
> -		if (console_trylock()) {
> +		if (console_trylock() || console_trylock_spinning())
>  			console_unlock();
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
