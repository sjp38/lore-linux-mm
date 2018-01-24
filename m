Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD901800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 21:11:41 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so1359797pge.13
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 18:11:41 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d6-v6sor1486807plo.13.2018.01.23.18.11.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jan 2018 18:11:39 -0800 (PST)
Date: Wed, 24 Jan 2018 11:11:33 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180124021034.GA651@jagdpanzerIV>
References: <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180123064023.GA492@jagdpanzerIV>
 <20180123095652.5e14da85@gandalf.local.home>
 <20180123152130.GB429@tigerII.localdomain>
 <20180123104121.2ef96d81@gandalf.local.home>
 <20180123160153.GC429@tigerII.localdomain>
 <20180123112436.0c94bc2e@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180123112436.0c94bc2e@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello,

On (01/23/18 11:24), Steven Rostedt wrote:
[..]
> > With WQ we don't lockup the kernel, because we flush printk_safe in
> > preemptible context. And people are very much expected to fix the
> > misbehaving consoles. But that should not be printk_safe problem.
> 
> Right, but now you just made printk safe unreliable to get information
> out, because you need to wait for a schedule to occur, and if there's
> issues, like a deadlock, that thread will never run. And you just lost
> you lockdep splat.

Yes and No.

printk_safe and printk_nmi are unreliable - both need irq_work. That's
why we forcibly flush those buffers in panic(). At least for printk_safe
case, and I'm pretty sure the same stands for printk_nmi, we never said
that we will store all the messages that were printed from unsafe context
(recursion or NMI). The only thing we said - we will try not to deadlock
the system.

Now we are adding one more thing to printk_safe - we will also try not to
lockup the system.

Default printk_safe buffer size might not be enough to store a very large
lockdep splat. And we will report that the buffer is too small and that we
lost some of the lines: "here is what we have, we lost N lines, but at least
we didn't deadlock the system". See f975237b76827956fe13ecfe993a319158e2c303
for more details, it contains a list of recursive-printk deadlock scenarios
that printk_safe was meant to handle.

It is possible and OK to lose messages in printk_safe/printk_nmi

printk_safe_enter_irqsave()
  printk
  printk
  ...
  ...
  printk
  printk
printk_safe_exit_irqrestore()

No flush will take place as long as there is no IRQ on that CPU.
But printk_safe and printk_nmi are solving different problem in
the first place.

> > I'll re-read this one tomorrow. Not quite following it.
> 
> I'll add more capitals next time ;-)

Ha-ha-ha ;)

[..]
> > pintk_safe was designed to be recursive. It was never designed to be
> > used to troubleshoot or debug consoles. But it was designed to be
> > recursive - because that's the sort of the problems it was meant to
> > handle: recursive printks that would otherwise deadlock us. That's why
> > we have it in the first place.
> 
> So printk safe is only triggered when at the same context? If we can
> guarantee that printk safe is triggered only when its because a printk
> is happening at the same context (not because of an interrupt, but
> really at the same context, using my context check), then I'm fine with
> delaying them to a work queue.

printk_safe is for printk recursion only. It happens in the same context
only. When we switch to printk_safe we disable local IRQs, NMIs have their
own printk_nmi thing. And the way we flush printk_safe is mostly recursive.
Because we flush when we know that we will not deadlock [as much as we can;
we can't control any 3rd party locks which might be involved; thus
printk_deferred() usage].

Usually it's something like

   printk
    spin_lock_irqsave(logbuf_lock)
     printk
      spin_lock_irqsave(logbuf_lock) << deadlock

What we have with printk_safe is

  printk
   local_irq_save
   printk_safe_enter
   spin_lock(logbuf_lock)
    printk
     vprintk_safe
      queue irq work
   spin_unlock(logbuf_lock)
   printk_safe_exit
   local_irq_restore
   >>> IRQ work
       printk_safe_flush
        printk
	 spin_lock_irqsave(logbuf_lock)
	 log_store()
	 spin_unlock_irqrestore(logbuf_lock)

So we flush printk_safe ASAP, which usually (unless originally we were
not in IRQ) means that the flush is recursive, but safe - we don't
deadlock.

> That is, if we have this:
> 
> 	printk()
> 		console_lock()
> 			<interrupt>
> 				printk()
> 					add to log buffer
> 		<print irq printk too>
> 		console_unlock();

Right. This is what we have right now. Every time we enable local IRQs in
the console_unlock() printing loop - we flush printk_safe. And that's the
problem.

> 	printk()
> 		console_lock()
> 			<console does a printk>
> 				put in printk safe buffer
> 				trigger work queue
> 		console_unlock()
> 	<work queue>
> 		flush safe buffer
> 		printk()

Right. This is what we will have with WQ. We don't flush printk_safe until
we return from console_unlock(). Because printk() disables preemption for
the duration of console_unlock(), we can't schedule WQ on that CPU. And we
schedule flushing work only on the CPU that has triggered the recursion.

Another thing:

console_lock()
 blah blah
console_unlock()

In this case we will flush printk_safe withing the printing loop.
Immediately. But we don't care - the CPU is preemptible, we don't
lock up the kernel.


> Then I'm fine with that.
> 
> I have to look at the latest code. If this is indeed what we have, then
> I admit I misunderstood the problem you want to solve.
> 
> I only want recursive printks (those that are actually triggered by
> doing a printk) to be allowed to be delayed.
> 
> Make sense?

Please take a look.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
