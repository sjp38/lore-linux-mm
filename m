Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id EDA916B0033
	for <linux-mm@kvack.org>; Sat, 20 Jan 2018 02:14:09 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i2so3627003pgq.8
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 23:14:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u29sor2276862pgn.426.2018.01.19.23.14.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 23:14:08 -0800 (PST)
Date: Sat, 20 Jan 2018 16:14:02 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180120071402.GB8371@jagdpanzerIV>
References: <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180111203057.5b1a8f8f@gandalf.local.home>
 <20180111215547.2f66a23a@gandalf.local.home>
 <20180116194456.GS3460072@devbig577.frc2.facebook.com>
 <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
 <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
 <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180119132052.02b89626@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org


On (01/19/18 13:20), Steven Rostedt wrote:
[..]
> I was thinking about this a bit more, and instead of offloading a
> recursive printk, perhaps its best to simply throttle it. Because the
> problem may not go away if a printk thread takes over, because the bug
> is really the printk infrastructure filling the printk buffer keeping
> printk from ever stopping.

right. I didn't quite got it how that would help. if we would
kick_offload every time we add new printks after call_console_drivers(),
then we can just end up in a kick_offload loop traveling across all CPUs.

[..]
>  asmlinkage int vprintk_emit(int facility, int level,
>  			    const char *dict, size_t dictlen,
> @@ -1849,6 +1918,17 @@ asmlinkage int vprintk_emit(int facility, int level,
>  
>  	/* This stops the holder of console_sem just where we want him */
>  	logbuf_lock_irqsave(flags);
> +
> +	if (recursion_check_test()) {
> +		/* A printk happened within a printk at the same context */
> +		if (this_cpu_inc_return(recursion_count) > recursion_max) {
> +			atomic_inc(&recursion_overflow);
> +			logbuf_unlock_irqrestore(flags);
> +			printed_len = 0;
> +			goto out;
> +		}
> +	}

didn't have time to look at this carefully, but is this possible?

printks from console_unlock()->call_console_drivers() are redirected
to printk_safe buffer. we need irq_work on that CPU to flush its
printk_safe buffer.

>  EXPORT_SYMBOL(vprintk_emit);
> @@ -2343,9 +2428,14 @@ void console_unlock(void)
>  			seen_seq = log_next_seq;
>  		}
>  
> -		if (console_seq < log_first_seq) {
> +		if (console_seq < log_first_seq || atomic_read(&recursion_overflow)) {
> +			size_t missed;
> +
> +			missed = atomic_xchg(&recursion_overflow, 0);
> +			missed += log_first_seq - console_seq;
> +
>  			len = sprintf(text, "** %u printk messages dropped **\n",
> -				      (unsigned)(log_first_seq - console_seq));
> +				      (unsigned)missed);
>  
>  			/* messages are gone, move to first one */
>  			console_seq = log_first_seq;

how are we going to distinguish between lockdep splats, for instance,
or WARNs from call_console_drivers() -> foo_write(), which are valuable,
and kmalloc() print outs, which might be less valuable? are we going to
lose all of them now? then we can do a much simpler thing - steal one
bit from `printk_context' and use if for a new PRINTK_NOOP_CONTEXT, which
will be set around call_console_drivers(). vprintk_func() would redirect
printks to vprintk_noop(fmt, args), which will do nothing.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
