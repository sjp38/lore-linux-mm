Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5C0516B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 04:36:28 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id e29so5627990plj.12
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 01:36:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b21si1484892pfn.195.2018.01.16.01.36.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 01:36:27 -0800 (PST)
Date: Tue, 16 Jan 2018 10:36:22 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116093622.ybippgmw3bdsicgg@pathway.suse.cz>
References: <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115101743.qh5whicsn6hmac32@pathway.suse.cz>
 <20180115115013.cyeocszurvguc3xu@pathway.suse.cz>
 <20180116061013.GA19801@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116061013.GA19801@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Tue 2018-01-16 15:10:13, Sergey Senozhatsky wrote:
> Hi,
> 
> On (01/15/18 12:50), Petr Mladek wrote:
> > On Mon 2018-01-15 11:17:43, Petr Mladek wrote:
> > > PS: Sergey, you have many good points. The printk-stuff is very
> > > complex and we could spend years discussing the perfect solution.
> > 
> > BTW: One solution that comes to my mind is based on ideas
> > already mentioned in this thread:
> > 
> > void console_unlock(void)
> > {
> > 	disable_preemtion();
> > 
> > 	while(pending_message) {
> > 
> > 	    call_console_drivers();
> > 
> > 	    if (too_long_here() && current != printk_kthread) {
> > 	       wake_up_process(printk_kthread())
> > 
> > 	}
> > 
> > 	enable_preemtion();
> > }
> 
> unfortunately disabling preemtion in console_unlock() is a bit
> dangerous :( we have paths that call console_unlock() exactly
> to flush everything (not only new pending messages, but everything)
> that is in logbuf and we cannot return from console_unlock()
> preliminary in that case.

You are right. Just to be sure. Are you talking about replaying
the entire log when a new console is registered? Or do you know
about more paths?

If I get it correctly, we allow to hand off the lock even when
replying the entire log. But you are right that we should
enable preemption in this case because there are many messages
even without printk() activity.

IMHO, the best solution would be to reply the log in a
separate process asynchronously and do not block existing
consoles in the meantime. But I am not sure if it is worth
the complexity. Anyway, it is a future work.


> > bool too_long_here(void)
> > {
> > 	return should_resched();
> > or
> > 	return spent_here() > 1 / HZ / 2;
> > or
> > 	what ever we agree on
> > }
> > 
> > 
> > int printk_kthread_func(void *data)
> > {
> > 	while(1) {
> > 		 if (!pending_messaged)
> > 			schedule();
> > 
> > 		if (console_trylock_spinning())
> > 			console_unlock();
> > 
> > 		cond_resched();
> > 	}
> > }
> 
> overall that's very close to what I have in one of my private branches.
> console_trylock_spinning() for some reason does not perform really
> well on my made-up internal printk torture tests. it seems that I
> have a much better stability (no lockups and so on) when I also let
> printk_kthread to sleep on console_sem(). but I will look further.

I believe that it is not trivial. console_trylock_spinning() is
tricky and the timing is important. For example, it might be tricky
if a torture test affects the normal workflow by many interrupts.
We might need to call even more console_unlock() code with
spinning enabled to improve the success ratio. Another problem
is that the kthread must be scheduled on another CPU. And so
on. I believe that there are many more problems and areas
for improvement.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
