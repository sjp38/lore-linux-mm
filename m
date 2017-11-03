Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC726B0253
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 06:19:57 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b189so75002wmd.9
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 03:19:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o6si2438238eda.375.2017.11.03.03.19.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 03:19:55 -0700 (PDT)
Date: Fri, 3 Nov 2017 11:19:53 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v2] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171103101953.GA5280@quack2.suse.cz>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171102115625.13892e18@gandalf.local.home>
 <20171102130605.05e987e8@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171102130605.05e987e8@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

Hi,

On Thu 02-11-17 13:06:05, Steven Rostedt wrote:
> +			if (spin) {
> +				/* We spin waiting for the owner to release us */
> +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> +				/* Owner will clear console_waiter on hand off */
> +				while (!READ_ONCE(console_waiter))
> +					cpu_relax();

Hum, what prevents us from rescheduling here? And what if the process
stored in console_owner is scheduled out? Both seem to be possible with
CONFIG_PREEMPT kernel? Unless I'm missing something you will need to
disable preemption in some places...

Other than that I like the simplicity of your approach.

								Honza

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
> @@ -2215,6 +2271,20 @@ skip:
>  			goto skip;
>  		}
>  
> +		/*
> +		 * While actively printing out messages, if another printk()
> +		 * were to occur on another CPU, it may wait for this one to
> +		 * finish. This task can not be preempted if there is a
> +		 * waiter waiting to take over.
> +		 */
> +
> +		/* The waiter may spin on us after this */
> +		spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> +
> +		raw_spin_lock(&console_owner_lock);
> +		console_owner = current;
> +		raw_spin_unlock(&console_owner_lock);
> +
>  		len += msg_print_text(msg, false, text + len, sizeof(text) - len);
>  		if (nr_ext_console_drivers) {
>  			ext_len = msg_print_ext_header(ext_text,
> @@ -2232,11 +2302,48 @@ skip:
>  		stop_critical_timings();	/* don't trace print latency */
>  		call_console_drivers(ext_text, ext_len, text, len);
>  		start_critical_timings();
> +
> +		raw_spin_lock(&console_owner_lock);
> +		waiter = console_waiter;
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
> +		/*
> +		 * Hand off console_lock to waiter. The waiter will perform
> +		 * the up(). After this, the waiter is the console_lock owner.
> +		 */
> +		mutex_release(&console_lock_dep_map, 1, _THIS_IP_);
> +		printk_safe_exit_irqrestore(flags);
> +		/* Note, if waiter is set, logbuf_lock is not held */
> +		return;
> +	}
> +
>  	console_locked = 0;
>  
>  	/* Release the exclusive_console once it is used */
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
