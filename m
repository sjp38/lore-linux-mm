Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 417B56B0069
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 05:31:35 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q186so17196375pga.23
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 02:31:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si16219906plr.336.2017.12.22.02.31.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Dec 2017 02:31:34 -0800 (PST)
Date: Fri, 22 Dec 2017 11:31:31 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171222102927.eiunret5ykx55bvq@pathway.suse.cz>
References: <20171108102723.602216b1@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171108102723.602216b1@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org

On Wed 2017-11-08 10:27:23, Steven Rostedt wrote:
> [ claws-mail is really pissing me off. It did it again, after I
>   manually fixed all the addresses. This time, I'm going to do things
>   slightly different. Sorry for all the spam :-( ]
> 
> From: Steven Rostedt (VMware) <rostedt@goodmis.org>
> 
> This patch implements what I discussed in Kernel Summit. I added
> lockdep annotation (hopefully correctly), and it hasn't had any splats
> (since I fixed some bugs in the first iterations). It did catch
> problems when I had the owner covering too much. But now that the owner
> is only set when actively calling the consoles, lockdep has stayed
> quiet.

> Index: linux-trace.git/kernel/printk/printk.c
> ===================================================================
> --- linux-trace.git.orig/kernel/printk/printk.c
> +++ linux-trace.git/kernel/printk/printk.c
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

One idea. We could do the above only when "do_cond_resched" is false.
I mean that we could allow stealing the console duty only from
atomic context.

If I get it correctly, this variable is always true in schedulable
context.

> +
> +		/* The waiter may spin on us after setting console_owner */
> +		spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
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
> +
>  		printk_safe_exit_irqrestore(flags);
>  
>  		if (do_cond_resched)
>  			cond_resched();

On the contrary, we could allow steeling the console semaphore
when sleeping here. It would allow to get the messages out
faster. It might help to move the duty to someone who is
actually producing many messages or even the panic() caller.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
