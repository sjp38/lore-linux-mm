Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D1F8B828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 10:21:34 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id l68so82626210wml.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 07:21:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y127si5426489wmg.13.2016.03.02.07.21.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 07:21:33 -0800 (PST)
Date: Wed, 2 Mar 2016 16:21:32 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: How to avoid printk() delay caused by cond_resched() ?
Message-ID: <20160302152132.GE22171@pathway.suse.cz>
References: <201603022101.CAH73907.OVOOMFHFFtQJSL@I-love.SAKURA.ne.jp>
 <20160302133810.GB22171@pathway.suse.cz>
 <201603022311.CGC64089.HOOLJFVSMFQOtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603022311.CGC64089.HOOLJFVSMFQOtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sergey.senozhatsky@gmail.com, jack@suse.com, tj@kernel.org, kyle@kernel.org, davej@codemonkey.org.uk, calvinowens@fb.com, akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@kernel.org

On Wed 2016-03-02 23:11:30, Tetsuo Handa wrote:
> That's a good news. I was wishing that there were a dedicated kernel
> thread which does printk() operation. While at it, I ask for an API
> which waits for printk buffer to be flushed (something like below) so that
> a watchdog thread which might dump thousands of threads from sleepable
> context (like my dump) can avoid "** XXX printk messages dropped **"
> messages.
>
> ----------
> diff --git a/include/linux/console.h b/include/linux/console.h
> index ea731af..11e936c 100644
> --- a/include/linux/console.h
> +++ b/include/linux/console.h
> @@ -147,6 +147,7 @@ extern int unregister_console(struct console *);
>  extern struct console *console_drivers;
>  extern void console_lock(void);
>  extern int console_trylock(void);
> +extern void wait_console_flushed(unsigned long timeout);
>  extern void console_unlock(void);
>  extern void console_conditional_schedule(void);
>  extern void console_unblank(void);
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index 9917f69..2eb60df 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -121,6 +121,15 @@ static int __down_trylock_console_sem(unsigned long ip)
>  	up(&console_sem);\
>  } while (0)
>  
> +static int __down_timeout_console_sem(unsigned long timeout, unsigned long ip)
> +{
> +	if (down_timeout(&console_sem, timeout))
> +		return 1;
> +	mutex_acquire(&console_lock_dep_map, 0, 1, ip);
> +	return 0;
> +}
> +#define down_timeout_console_sem(timeout) __down_timeout_console_sem((timeout), _RET_IP_)
> +
>  /*
>   * This is used for debugging the mess that is the VT code by
>   * keeping track if we have the console semaphore held. It's
> @@ -2125,6 +2134,21 @@ int console_trylock(void)
>  }
>  EXPORT_SYMBOL(console_trylock);
>  
> +void wait_console_flushed(unsigned long timeout)
> +{
> +	might_sleep();
> +
> +	if (down_timeout_console_sem(timeout))
> +		return;
> +	if (console_suspended) {
> +		up_console_sem();
> +		return;
> +	}
> +	console_locked = 1;
> +	console_may_schedule = 1;
> +	console_unlock();
> +}

This tries to take over the responsibility for printing to the
console. I would personally solve this by a wait queue.
console_unlock() might wakeup all waiters when empty. This
will work also when the console stuff is offloaded into
the workqueue.

But there still might be dropped messages if there is a flood
of them from another process. Note that even userspace could push
messages into the kernel ring buffer via /dev/kmsg. We need
to be careful against DOS attacks.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
