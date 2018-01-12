Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6A5F26B0038
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 05:05:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e185so4645176pfg.23
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 02:05:51 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q77sor3441093pfq.127.2018.01.12.02.05.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jan 2018 02:05:49 -0800 (PST)
Date: Fri, 12 Jan 2018 19:05:44 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180112100544.GA441@jagdpanzerIV>
References: <20180110132418.7080-1-pmladek@suse.com>
 <20180110140547.GZ3668920@devbig577.frc2.facebook.com>
 <20180110130517.6ff91716@vmware.local.home>
 <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180111222140.7fd89d52@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Steven, we are having too many things in one email, I've dropped most
of them to concentrate on one topic only.

On (01/11/18 22:21), Steven Rostedt wrote:
[..]
>
> After playing with the module in my last email, I think your trying to
> solve multiple printks, not one that is stuck

I wouldn't say so. I'm trying to fix the same thing. but when system has
additional limitations - there are NO concurrent printk-s to hand off to
and A * B > C, so we can't have "last console_sem prints it all" bounded
to O(A * B).

- no concurrent printk-s to hand off is explainable - preemption under
  console_sem and the fact that console_sem is a sleeping lock.

- on a system with slow consoles A * B > C is also pretty clear.

- slow consoles make preemption under console_sem more likely.


to summarize:

1) I have a slow serial console. call_console_drivers() is significantly
   slower than log_store().

   the disproportion can be 1:1000. that is while CPUA prints a single
   logbuf message, other CPUs can add 1000 new entries.

2) not every CPU that stuck in console_unlock() came there through printk().
   CPUs that directly call console_lock() can sleep under console_sem. a bunch
   of printk-s can happen in the meantime -- OOM can happen in the meantime;
   no hand off will happen.

3) console_unlock(void)
   {
	for (;;) {
		printk_safe_enter_irqsave(flags);
		// lock-unlock logbuf
		call_console_drivers(ext_text, ext_len, text, len);
		printk_safe_exit_irqrestore(flags);
	}
   }

with slow serial console, call_console_drivers() takes enough time to
to make preemption of a current console_sem owner right after it irqrestore()
highly possible; unless there is a spinning console_waiter. which easily may
not be there; but can come in while current console_sem is preempted, why not.
so when preempted console_sem owner comes back - it suddenly has a whole bunch
of new messages to print and on one to hand off printing to. in a super
imperfect and ugly world, BTW, this is how console_unlock() still can be
O(infinite): schedule between the printed lines [even !PREEMPT kernel tries
to cond_resched() after every line it prints] from current console_sem
owner and printk() while console_sem owner is scheduled out.

4) the interesting thing here is that call_console_drivers() can
   cause console_sem owner to schedule even if it has handed off the
   ownership. because waiting CPU has to spin with local IRQs disabled
   as long as call_console_drivers() prints its message. so if consoles
   are slow, then the first thing the waiter will face after it receives
   the console_sem ownership and enables the IRQs is - preemption.

   so hand off is not immediate. there is a possibility of re-scheduling
   between hand off and actual printing. so that "there is always an active
   printing CPU" is not quite true.

vprintk_emit()
{

	console_trylock_spinning(void)
	{
	   printk_safe_enter_irqsave(flags);
	   while (READ_ONCE(console_waiter))       // spins as long as call_console_drivers() on other CPU
	        cpu_relax();
	   printk_safe_exit_irqrestore(flags);
--->	}
|						   // preemptible up until printk_safe_enter_irqsave() in console_unlock()
|	console_unlock()
|	{
|		
|		....
|		for (;;) {
|-------------->	printk_safe_enter_irqsave(flags);
			....
		}

	}
}

reverting 6b97a20d3a7909daa06625d4440c2c52d7bf08d7 may be the right
thing after all.

preemption latencies can be high. especially during OOM. I went
through reports that Tetsuo provided over the years. On some of
his tests preempted console_sem owner can sleep long enough to
let other CPUs to start overflowing the logbuf with the pending
messages.

more on preemption. see this email, for instance. a bunch of links in
the middle, scroll down:
https://marc.info/?l=linux-kernel&m=151375384500555


BTW, note the disclaimer [in capitals] -

	LIKE I SAID, IF STEVEN OR PETR WANT TO PUSH THE PATCH, I'M NOT
	GOING TO BLOCK IT.


> > and I demonstrated how exactly we end up having a full logbuf of pending
> > messages even on systems with faster consoles.
> 
> Where did you demonstrate that. There's so many emails I can't keep up.
> 
> But still, take a look at my simple module. I locked up the system
> immediately with something that shouldn't have locked up the system.
> And my patch fixed it. I think that speaks louder than any of our
> opinions.

sure it will!
you don't have scheduler latencies mixed in under console_sem (neither in
vprintk_emit(), nor in console_unlock(), nor anywhere in between), you have
printks only from non-preemptible contexts, so your hand off logic always
works and is never preempted, you have concurrent printks from many CPUs,
so once again your hand off logic always works, and you have fast console,
and, due to hand off, console_sem is never up() so no schedulable context
can ever acquire it - you pass it between non-preemptible printk CPUs only.
I cannot see why your patch would not help. your patch works fine in these
conditions, I said it many times. and I have no issues with that. my setups
(real HW, by the way) are far from those conditions. but there is an active
denial of that.

anyway. like I said weeks ago and repeated it in several emails: I have
no intention to NACK or block the patch.
but the patch is not doing enough. that's all I'm saying.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
