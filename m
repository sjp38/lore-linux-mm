Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2566C800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 03:56:39 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x24so8213535pge.13
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 00:56:39 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 31-v6sor109876plz.36.2018.01.22.00.56.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 00:56:37 -0800 (PST)
Date: Mon, 22 Jan 2018 17:56:32 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180122085632.GA403@jagdpanzerIV>
References: <20180116194456.GS3460072@devbig577.frc2.facebook.com>
 <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
 <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
 <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180121160441.7ea4b6d9@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180121160441.7ea4b6d9@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/21/18 16:04), Steven Rostedt wrote:
[..]
> > The problem is that we flush printk_safe right when console_unlock() printing
> > loop enables local IRQs via printk_safe_exit_irqrestore() [given that IRQs
> > were enabled in the first place when the CPU went to console_unlock()].
> > This forces that CPU to loop in console_unlock() as long as we have
> > printk-s coming from call_console_drivers(). But we probably can postpone
> > printk_safe flush. Basically, we can declare a new rule - we don't flush
> > printk_safe buffer as long as console_sem is locked. Because this is how
> > that printing CPU stuck in the console_unlock() printing loop. printk_safe
> > buffer is very important when it comes to storing a non-repetitive stuff, like
> > a lockdep splat, which is a single shot event. But the more repetitive the
> > message is, like millions of similar kmalloc() dump_stack()-s over and over
> > again, the less value in it. We should have printk_safe buffer big enough for
> > important info, like a lockdep splat, but millions of similar kmalloc()
> > messages are pretty invaluable - one is already enough, we can drop the rest.
> > And we should not flush new messages while there is a CPU looping in
> > console_unlock(), because it already has messages to print, which were
> > log_store()-ed the normal way.
> 
> The above is really hard to read without any capitalization. Everything
> seems to be a run-on sentence and gives me a head ache. So you lost me
> there.

Apologies. Will improve.

> > This is where the "postpone thing" jumps in. so how do we postpone printk_safe
> > flush.
> > 
> > We can't console_trylock()/console_unlock() in printk_safe flush code.
> > But there is a `console_locked' flag and is_console_locked() function which
> > tell us if the console_sem is locked. As long as we are in console_unlock()
> > printing loop that flag is set, even if we enabled local IRQs and printk_safe
> > flush work arrived. So now printk_safe flush does extra check and does
> > not flush printk_safe buffer content as long as someone is currently
> > printing or soon will start printing. But we need to take extra step and
> > to re-queue flush on CPUs that did postpone it [console_unlock() can
> > reschedule]. So now we flush only when printing CPU printed all pending
> > logbuf messages, hit the "console_seq == log_next_seq" and up()
> > console_sem. This sets a boundary -- no matter how many times during the
> > current printing loop we called console drivers and how many times those
> > drivers caused printk recursion, we will flush only SAFE_LOG_BUF_LEN chars.
> 
> Another big paragraph with no capitals (besides macros and CPU ;-)

I walked through it and mostly "fixed" your head ache :)

> I guess this is what it is like when people listen to me talk too fast.

Absolutely!!!

> > IOW, what we have now, looks like this:
> > 
> > a) printk_safe is for important stuff, we don't guarantee that a flood
> >    of messages will be preserved.
> > 
> > b) we extend the previously existing "will flush messages later on from
> >    a safer context" and now we also consider console_unlock() printing loop
> >    as unsafe context. so the unsafe context it's not only the one that can
> >    deadlock, but also the one that can lockup CPU in a printing loop because
> >    of recursive printk messages.
> 
> Sure.
> 
> > 
> > 
> > so this
> > 
> >  printk
> >   console_unlock
> >   {
> >    for (;;) {
> >      call_console_drivers
> >       net_console
> >        printk
> >         printk_save -> irq_work queue
> > 
> > 	   IRQ work
> > 	     prink_safe_flush
> > 	       printk_deferred -> log_store()
> >            iret
> >     }
> >     up();
> >   }
> > 
> > 
> >    // which can never break out, because we can always append new messages
> >    // from prink_safe_flush.
> > 
> > becomes this
> > 
> > printk
> >   console_unlock
> >   {
> >    for (;;) {
> >      call_console_drivers
> >       net_console
> >        printk
> >         printk_save -> irq_work queue
> > 
> >     }
> >     up();
> > 
> >   IRQ work
> >    prink_safe_flush
> >     printk_deferred -> log_store()
> >   iret
> > }
> 
> But we do eventually send this data out to the consoles, and if the
> consoles cause more printks, wouldn't this still never end?

Right. But not immediately. We wait for all pending messages to be evicted
first (and up()) and we limit the amount of data that we flush. So at least
it's not exponential anymore: every line that we print does not log_store()
a whole new dump_stack() of lines. Which is still miles away from "a perfect
solution", tho. But limiting the number of lines we print recursive is not
much better.

First, we don't know how many lines we want to flush from printk_safe.
And having a knob indicates that no one ever will do it right.

Second, hand off can play games with it.

Assume the following,

- I set `recursion_max' to 200. Which looks reasonable to me.
  Then I have the following ping-pong:

	CPU0						CPU1
	printk()
	recursion_check_start()
	 call_console_drivers()         		printk()
							recursion_check_start()
	  dump_stack()					console_trylock_spinning()
	 flush_printk_safe()
	 spinning_disable_and_check() //handoff
        recursion_check_finish() // reset		 call_console_drivers()
							  dump_stack()
							 flush_printk_safe()
	printk()
	recursion_check_start()
	console_trylock_spinning()			 spinning_disable_and_check() // handoff
							recursion_check_finish() // reset

	 call_console_drivers()				printk
	  dump_stack()					recursion_check_start()
	 flush_printk_safe()				console_trylock_spinning()
	 spinning_disable_and_check()
	recursion_check_finish() // reset		 call_console_drivers()
							 ...

And so on. So it's - take the lock, call console drivers, fill up the
printk_safe buffer, flush it completely, hand off printing to another
CPU, reset this CPU's recursion counter, repeat everything again. Every
line of dump_stack() which we print adds another dump_stack() lines.


	Sergey "no-time-for-capitals" Senozhatsky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
