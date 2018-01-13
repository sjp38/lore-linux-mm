Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 696476B0038
	for <linux-mm@kvack.org>; Sat, 13 Jan 2018 02:28:41 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id a74so6719536pfg.20
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 23:28:41 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g70sor826869pgc.299.2018.01.12.23.28.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jan 2018 23:28:40 -0800 (PST)
Date: Sat, 13 Jan 2018 16:28:34 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180113072834.GA1701@tigerII.localdomain>
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
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/12/18 07:21), Steven Rostedt wrote:
[..]
> Yep, but I'm still not convinced you are seeing an issue with a single
> printk.

what do you mean by this?

> An OOM does not do everything in one printk, it calls hundreds.
> Having hundreds of printks is an issue, especially in critical sections.

unless your console_sem owner is preempted. as long as it is preempted
it doesn't really matter how many times we call printk from which CPUs
and from which sections, but what matters - who is going to print that all
out when console_sem is running again and how much time will it take.
that's what I'm saying.

[..]
> > with slow serial console, call_console_drivers() takes enough time to
> > to make preemption of a current console_sem owner right after it irqrestore()
> > highly possible; unless there is a spinning console_waiter. which easily may
> > not be there; but can come in while current console_sem is preempted, why not.
> > so when preempted console_sem owner comes back - it suddenly has a whole bunch
> > of new messages to print and on one to hand off printing to. in a super
> > imperfect and ugly world, BTW, this is how console_unlock() still can be
> > O(infinite): schedule between the printed lines [even !PREEMPT kernel tries
> 
> I'm not fixing console_unlock(), I'm fixing printk().

I know. I'm fixing console_unlock(). because console_unlock() is its own
thing.

> > 4) the interesting thing here is that call_console_drivers() can
> >    cause console_sem owner to schedule even if it has handed off the
> >    ownership. because waiting CPU has to spin with local IRQs disabled
> >    as long as call_console_drivers() prints its message. so if consoles
> >    are slow, then the first thing the waiter will face after it receives
> >    the console_sem ownership and enables the IRQs is - preemption.
> 
> If the waiter is preempted, that means its not in a critical section.
> Isn't that what you want?

see below.

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
> 
> Again, this means the waiter is not in a critical section. Why do we
> care?

which is not what I was talking about. the point was that you said


 :                                                .... and what about the
 : printks that haven't gotten out yet? Delay them to something else, and
 : if the machine were to crash in the transfer, we lost all that data.
 :
 : My method, there's really no delay between a hand off. There's always
 : an active CPU doing printing. It matches the current method which works
 : well for getting information out. A delayed approach will break that


that is not true. we can have preemption "during" hand off. hand off,
thus, is a "delayed approach", by definition. so if you consider the
possibility of "if the machine were to crash in the transfer, we lost
all that data" and if you consider this to be important [otherwise you
wouldn't bring that up, would you] then the reality is that your patch
has the same problem as printk_kthread.

so very schematically, for hand-off it's something like

	if (... console_trylock_spinning()) // grabbed the ownership

		<< ... preempted ... >>

		console_unlock();


for printk_kthread it's something like

		wake_up_process(printk_kthread);
		up(console_sem);


in the later case we at least have console_sem unlocked. so any other CPU
that might do printk() can grab the lock and emit the logbuf messages. but
in case on hand-off, we have console_sem locked, so no printk() will be
able to emit the messages, we need that specific task to become running.


hence the following:

[..]
> > reverting 6b97a20d3a7909daa06625d4440c2c52d7bf08d7 may be the right
> > thing after all.

this was cryptic and misleading. sorry.
some clarifications.

what I meant was that with 6b97a20d3a7909daa06625d4440c2c52d7bf08d7
I think I badly broke printk() [some of paths]. I know what I tried
to fix (and you don't have to explain to me what a lock up is) with
that patch, but I don't think the patch ended up to be a clear win.
a very simple explanation would be:

instead of having a direct nonpreemptible path

	logbuf -> for(;;) call_console_drivers -> happy user

we now have

	logbuf -> for(;;) { call_console_drivers, scheduler ... ???} -> happy user

which is a big change. with a non-zero potential for regressions.
and it didn't take long to find out that not all "happy users" were
exactly happy with the new scheme of things. glance through Tetsuo's
emails [see links in my another email], Tetsuo reported that printk can
stall for minutes now. basically, the worse the system state is the lower
printk throughput can be [down to zero chars in the worst case]. that's
why I think that my patch was a mistake. and that's why in my out-of-tree
patches I'm moving towards the non-preemptible path from logbuf through
console to a happy user [just like it used to be]. but, obviously, I can't
just restore preempt_disable()/preempt_enable() in vprintk_emit(). that's
why I bound console_unlock() to watchdog threshold and move towards the
batched non-preemptible print outs (enabling preemption and up()-ing the
console_sem at the end of each print out batch). this is not super good,
preemption is still here, but at least not after every line console_unlock()
prints. up() console_sem also increases chances that, for instance, systemd
or any other task that is sleeping in TASK_UNINTERRUPTIBLE on console_sem
now has a chance to be woken up sooner (not only after we flush all pending
logbuf messages and finally up() the console_sem).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
