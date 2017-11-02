Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE496B0038
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 18:17:44 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id l23so1090573pgc.10
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 15:17:44 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n10si2602426plp.726.2017.11.02.15.17.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Nov 2017 15:17:42 -0700 (PDT)
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
References: <20171102134515.6eef16de@gandalf.local.home>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <82a3df5e-c8ad-dc41-8739-247e5034de29@suse.cz>
Date: Thu, 2 Nov 2017 23:16:16 +0100
MIME-Version: 1.0
In-Reply-To: <20171102134515.6eef16de@gandalf.local.home>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On 11/02/2017 06:45 PM, Steven Rostedt wrote:
...>  	__DEVKMSG_LOG_BIT_ON = 0,
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
> +				/* Owner will clear console_waiter on hand off */
> +				while (!READ_ONCE(console_waiter))

This should not be negated, right? We should spin while it's true, not
false.

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
> +				console_unlock();
> +				printk_safe_enter_irqsave(flags);
> +			}
> +			printk_safe_exit_irqrestore(flags);
> +
> +		}
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
