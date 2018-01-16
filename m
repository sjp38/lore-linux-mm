Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C5B196B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 05:10:35 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z12so9125239pgv.6
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 02:10:35 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m30sor634871pli.16.2018.01.16.02.10.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jan 2018 02:10:34 -0800 (PST)
Date: Tue, 16 Jan 2018 19:10:29 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116101029.GA485@jagdpanzerIV>
References: <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115101743.qh5whicsn6hmac32@pathway.suse.cz>
 <20180115115013.cyeocszurvguc3xu@pathway.suse.cz>
 <20180116061013.GA19801@jagdpanzerIV>
 <20180116093622.ybippgmw3bdsicgg@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116093622.ybippgmw3bdsicgg@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/16/18 10:36), Petr Mladek wrote:
[..]
> > unfortunately disabling preemtion in console_unlock() is a bit
> > dangerous :( we have paths that call console_unlock() exactly
> > to flush everything (not only new pending messages, but everything)
> > that is in logbuf and we cannot return from console_unlock()
> > preliminary in that case.
> 
> You are right. Just to be sure. Are you talking about replaying
> the entire log when a new console is registered? Or do you know
> about more paths?

to the best of my knowledge CON_PRINTBUFFER is the only thing that
explicitly states
  "I want everything what's in logbuf, even if it has been already
   printed on other consoles"

the rest want to have only pending messages, so we can offload
from there.

CON_PRINTBUFFER registration can happen any time. e.g. via modprobe
netconsole. we can be up and running for some time when netconsole
joins in, so that CON_PRINTBUFFER thing can be painful.

> If I get it correctly, we allow to hand off the lock even when
> replying the entire log. But you are right that we should
> enable preemption in this case because there are many messages
> even without printk() activity.

> IMHO, the best solution would be to reply the log in a
> separate process asynchronously and do not block existing
> consoles in the meantime. But I am not sure if it is worth
> the complexity. Anyway, it is a future work.
[..]
> > > int printk_kthread_func(void *data)
> > > {
> > > 	while(1) {
> > > 		 if (!pending_messaged)
> > > 			schedule();
> > > 
> > > 		if (console_trylock_spinning())
> > > 			console_unlock();
> > > 
> > > 		cond_resched();
> > > 	}
> > > }
> > 
> > overall that's very close to what I have in one of my private branches.
> > console_trylock_spinning() for some reason does not perform really
> > well on my made-up internal printk torture tests. it seems that I
> > have a much better stability (no lockups and so on) when I also let
> > printk_kthread to sleep on console_sem(). but I will look further.
> 
> I believe that it is not trivial. console_trylock_spinning() is
> tricky and the timing is important.

yes, timing seems to be very important.
 *as far as I can see from the traces on my printk torture tests*

> For example, it might be tricky if a torture test affects the normal
> workflow by many interrupts. We might need to call even more
> console_unlock() code with spinning enabled to improve the success
> ratio. Another problem is that the kthread must be scheduled on
> another CPU.

yes, I always schedule it on another CPU [if any].

> And so on. I believe that there are many more problems and areas
> for improvement.

right.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
