Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A9116B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 09:45:36 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id h38so2287128wrh.11
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 06:45:36 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k15si1585904wre.538.2018.01.15.06.45.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 06:45:35 -0800 (PST)
Date: Mon, 15 Jan 2018 15:45:30 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
References: <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115070637.1915ac20@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180115070637.1915ac20@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Mon 2018-01-15 07:06:37, Steven Rostedt wrote:
> On Sat, 13 Jan 2018 16:28:34 +0900
> Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:
> > On (01/12/18 07:21), Steven Rostedt wrote:
> > 
> > > An OOM does not do everything in one printk, it calls hundreds.
> > > Having hundreds of printks is an issue, especially in critical sections.  
> > 
> > unless your console_sem owner is preempted. as long as it is preempted
> > it doesn't really matter how many times we call printk from which CPUs
> > and from which sections, but what matters - who is going to print that all
> > out when console_sem is running again and how much time will it take.
> > that's what I'm saying.
> 
> OK, if this is an issue, then we could do:
> 
> 	preempt_disable();
> 	if (console_trylock_spinning())
> 		console_unlock();
> 	preempt_enable();
> 
> Which would prevent any printks from being preempted, but allow for
> other console_lock owners to be so.

[...]

> >  :                                                .... and what about the
> >  : printks that haven't gotten out yet? Delay them to something else, and
> >  : if the machine were to crash in the transfer, we lost all that data.
> >  :
> >  : My method, there's really no delay between a hand off. There's always
> >  : an active CPU doing printing. It matches the current method which works
> >  : well for getting information out. A delayed approach will break that
> > 
> > 
> > that is not true. we can have preemption "during" hand off. hand off,
> > thus, is a "delayed approach", by definition. so if you consider the
> > possibility of "if the machine were to crash in the transfer, we lost
> > all that data" and if you consider this to be important [otherwise you
> > wouldn't bring that up, would you] then the reality is that your patch
> > has the same problem as printk_kthread.
> 
> With the preempt_disable() there really isn't a delay. I agree, we
> shouldn't let printk preempt (unless we have CONFIG_PREEMPT_RT enabled,
> but that's another story).
> 
> > 
> > so very schematically, for hand-off it's something like
> > 
> > 	if (... console_trylock_spinning()) // grabbed the ownership
> > 
> > 		<< ... preempted ... >>
> > 
> > 		console_unlock();
> 
> Which I think we should stop, with the preempt_disable().

Adding the preempt_disable() basically means to revert the already
mentioned commit 6b97a20d3a7909daa06625 ("printk: set may_schedule
for some of console_trylock() callers").

I originally wanted to solve this separately to make it easier. But
the change looks fine to me. Therefore we reached a mutual agreement.
Sergey, do you want to send a patch or should I just put it at
the end of this patchset?


> > for printk_kthread it's something like
> > 
> > 		wake_up_process(printk_kthread);
> > 		up(console_sem);
> > 
> > 
> > in the later case we at least have console_sem unlocked. so any other CPU
> > that might do printk() can grab the lock and emit the logbuf messages. but
> > in case on hand-off, we have console_sem locked, so no printk() will be
> > able to emit the messages, we need that specific task to become running.
> > 
> > 
> > hence the following:
> > 
> > [..]
> > > > reverting 6b97a20d3a7909daa06625d4440c2c52d7bf08d7 may be the right
> > > > thing after all.  
> > 
> > this was cryptic and misleading. sorry.
> > some clarifications.
> > 
> > what I meant was that with 6b97a20d3a7909daa06625d4440c2c52d7bf08d7
> > I think I badly broke printk() [some of paths]. I know what I tried
> 
> I think adding the preempt_disable() would fix printk() but let non
> printk console_unlock() still preempt.

I would personally remove cond_resched() from console_unlock()
completely.

Sleeping in console_unlock() increases the chance that more messages
would need to be handled. And more importantly it reduces the chance
of a successful handover.

As a result, the caller might spend there very long time, it might
be getting increasingly far behind. There is higher risk of lost
messages. Also the eventual taker might have too much to proceed
in preemption disabled context.

Removing cond_resched() is in sync with printk() priorities.
The highest one is to get the messages out.

Finally, removing cond_resched() should make the behavior more
predictable (never preempted), same in all situations (called
from printk() or other locations) => easier to analyze problems
and maintain.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
