Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8FB66B0033
	for <linux-mm@kvack.org>; Sat, 20 Jan 2018 10:49:37 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e185so4573742pfg.23
        for <linux-mm@kvack.org>; Sat, 20 Jan 2018 07:49:37 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b14-v6si818445pll.758.2018.01.20.07.49.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Jan 2018 07:49:36 -0800 (PST)
Date: Sat, 20 Jan 2018 10:49:31 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180120104931.1942483e@gandalf.local.home>
In-Reply-To: <20180120071402.GB8371@jagdpanzerIV>
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
	<20180120071402.GB8371@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Sat, 20 Jan 2018 16:14:02 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> [..]
> >  asmlinkage int vprintk_emit(int facility, int level,
> >  			    const char *dict, size_t dictlen,
> > @@ -1849,6 +1918,17 @@ asmlinkage int vprintk_emit(int facility, int level,
> >  
> >  	/* This stops the holder of console_sem just where we want him */
> >  	logbuf_lock_irqsave(flags);
> > +
> > +	if (recursion_check_test()) {
> > +		/* A printk happened within a printk at the same context */
> > +		if (this_cpu_inc_return(recursion_count) > recursion_max) {
> > +			atomic_inc(&recursion_overflow);
> > +			logbuf_unlock_irqrestore(flags);
> > +			printed_len = 0;
> > +			goto out;
> > +		}
> > +	}  
> 
> didn't have time to look at this carefully, but is this possible?
> 
> printks from console_unlock()->call_console_drivers() are redirected
> to printk_safe buffer. we need irq_work on that CPU to flush its
> printk_safe buffer.

So is the issue that we keep triggering this irq work then? Then this
solution does seem to be one that would work. Because after x amount of
recursive printks (printk called by printk) it would just stop printing
them, and end the irq work.

Perhaps what Tejun is seeing is:

 printk()
   net_console()
     printk() --> redirected to irq work

 <irq work>
  printk
    net_console()
      printk() --> redirected to another irq work

and so on and so on.

This solution would need to be tweaked to add a timer to allow only so
many nested printks in a given time. Otherwise it too would be an issue:

 printk()
   net_console()
     printk() -> redirected
     printk() -> throttled

But the first x printk()s would still be redirected. and that x gets
reset in this current patch at he end of the outermost printk. Perhaps
it shouldn't reset x, or it can flush the printk safe buffer first. Is
there a reason that console_unlock() doesn't flush the
printk_safe_buffer? With a throttle number and flushing the
printk_safe_buffer, that should solve the issue Tejun explained.


> 
> how are we going to distinguish between lockdep splats, for instance,
> or WARNs from call_console_drivers() -> foo_write(), which are valuable,
> and kmalloc() print outs, which might be less valuable? are we going to

The problem is that printk causing more printks is extremely dangerous,
and ANY printk that is caused by a printk is of equal value, whether it
is a console driver running out of memory or a lockdep splat. And
the chances of having two hit at the same time is extremely low.

> lose all of them now? then we can do a much simpler thing - steal one
> bit from `printk_context' and use if for a new PRINTK_NOOP_CONTEXT, which
> will be set around call_console_drivers(). vprintk_func() would redirect
> printks to vprintk_noop(fmt, args), which will do nothing.

Not sure what you mean here. Have some pseudo code to demonstrate with?

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
