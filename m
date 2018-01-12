Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3C86B0069
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 07:55:44 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id m7so4655265pgv.17
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 04:55:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3si5518037pgn.264.2018.01.12.04.55.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 12 Jan 2018 04:55:43 -0800 (PST)
Date: Fri, 12 Jan 2018 13:55:37 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180112125536.GC24497@linux.suse>
References: <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180112072123.33bb567d@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Fri 2018-01-12 07:21:23, Steven Rostedt wrote:
> On Fri, 12 Jan 2018 19:05:44 +0900
> Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:
> > 3) console_unlock(void)
> >    {
> > 	for (;;) {
> > 		printk_safe_enter_irqsave(flags);
> > 		// lock-unlock logbuf
> > 		call_console_drivers(ext_text, ext_len, text, len);
> > 		printk_safe_exit_irqrestore(flags);
> > 	}
> >    }
> > 
> > with slow serial console, call_console_drivers() takes enough time to
> > to make preemption of a current console_sem owner right after it irqrestore()
> > highly possible; unless there is a spinning console_waiter. which easily may
> > not be there; but can come in while current console_sem is preempted, why not.
> > so when preempted console_sem owner comes back - it suddenly has a whole bunch
> > of new messages to print and on one to hand off printing to. in a super
> > imperfect and ugly world, BTW, this is how console_unlock() still can be
> > O(infinite): schedule between the printed lines [even !PREEMPT kernel tries
> 
> I'm not fixing console_unlock(), I'm fixing printk(). BTW, all my
> kernels are CONFIG_PREEMPT (I'm a RT guy), my mind thinks more about
> PREEMPT kernels than !PREEMPT ones.

I would say that the patch improves also console_unlock() but only in
non-preemttive context.

By other words, it makes console_unlock() finite in preemptible context
(limited by buffer size). It might still be unlimited in
non-preemtible context.


> > to cond_resched() after every line it prints] from current console_sem
> > owner and printk() while console_sem owner is scheduled out.
> > 
> > 4) the interesting thing here is that call_console_drivers() can
> >    cause console_sem owner to schedule even if it has handed off the
> >    ownership. because waiting CPU has to spin with local IRQs disabled
> >    as long as call_console_drivers() prints its message. so if consoles
> >    are slow, then the first thing the waiter will face after it receives
> >    the console_sem ownership and enables the IRQs is - preemption.
> >    so hand off is not immediate. there is a possibility of re-scheduling
> >    between hand off and actual printing. so that "there is always an active
> >    printing CPU" is not quite true.
> > 
> > vprintk_emit()
> > {
> > 
> > 	console_trylock_spinning(void)
> > 	{
> > 	   printk_safe_enter_irqsave(flags);
> > 	   while (READ_ONCE(console_waiter))       // spins as long as call_console_drivers() on other CPU
> > 	        cpu_relax();
> > 	   printk_safe_exit_irqrestore(flags);
> > --->	}  
> > |						   // preemptible up until printk_safe_enter_irqsave() in console_unlock()
> > |	console_unlock()
> > |	{
> > |		
> > |		....
> > |		for (;;) {
> > |-------------->	printk_safe_enter_irqsave(flags);
> > 			....
> > 		}
> > 
> > 	}
> > }
> > 
> > reverting 6b97a20d3a7909daa06625d4440c2c52d7bf08d7 may be the right
> > thing after all.
> 
> I would analyze that more before doing so. Because with my patch, I
> think we make those that can do long prints (without triggering a
> watchdog), the ones most likely doing the long prints.

IMHO, it might make sense because it would help to see the messages
faster. But I would prefer to handle this separately because it
might also increase the risk of softlockups. Therefore it might
cause regressions.

We should also take into account the commit 8d91f8b15361dfb438ab6
("printk: do cond_resched() between lines while outputting to
consoles"). It has the same effect for console_lock() callers.

> > BTW, note the disclaimer [in capitals] -
> > 
> > 	LIKE I SAID, IF STEVEN OR PETR WANT TO PUSH THE PATCH, I'M NOT
> > 	GOING TO BLOCK IT.
> 
> GREAT! Then we can continue this conversation after the patch goes in.
> Because I'm focused on fixing #1 above.

Thanks for the disclaimer!

> > anyway. like I said weeks ago and repeated it in several emails: I have
> > no intention to NACK or block the patch.
> > but the patch is not doing enough. that's all I'm saying.
> 
> Great, then Petr can start pushing this through.
> 
> Below is my latest module I used for testing:

I am going to send v6 with fixes suggested for the 2nd patch by Steven.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
