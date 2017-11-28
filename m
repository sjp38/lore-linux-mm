Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 906886B0038
	for <linux-mm@kvack.org>; Mon, 27 Nov 2017 20:42:45 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id q84so25997862pfl.12
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 17:42:45 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id r39si13897731pld.235.2017.11.27.17.42.43
        for <linux-mm@kvack.org>;
        Mon, 27 Nov 2017 17:42:43 -0800 (PST)
Date: Tue, 28 Nov 2017 10:42:29 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171128014229.GA2899@X58A-UD3R>
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

Hello Petr,

IMHO, it would get unbalanced if you only remove this mutex_acquire().

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

IMHO, this release() should be moved to somewhere properly.

> +		lock_commit_crosslock((struct lockdep_map *)&console_lock_dep_map);
>  		printk_safe_exit_irqrestore(flags);
>  		/* Note, if waiter is set, logbuf_lock is not held */
>  		return;

However, now that cross-release was introduces, lockdep can be applied
to semaphore operations. Actually, I have a plan to do that. I think it
would be better to make semaphore tracked with lockdep and remove all
these manual acquire() and release() here. What do you think about it?

Thanks,
Byungchul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
