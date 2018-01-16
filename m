Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D66536B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 21:23:55 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id 34so4941612plm.23
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 18:23:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g12sor321012plt.0.2018.01.15.18.23.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 18:23:54 -0800 (PST)
Date: Tue, 16 Jan 2018 11:23:49 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116022349.GD6607@jagdpanzerIV>
References: <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115070637.1915ac20@gandalf.local.home>
 <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180115144530.pej3k3xmkybjr6zb@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/15/18 15:45), Petr Mladek wrote:
[..]
> > With the preempt_disable() there really isn't a delay. I agree, we
> > shouldn't let printk preempt (unless we have CONFIG_PREEMPT_RT enabled,
> > but that's another story).
> > 
> > > 
> > > so very schematically, for hand-off it's something like
> > > 
> > > 	if (... console_trylock_spinning()) // grabbed the ownership
> > > 
> > > 		<< ... preempted ... >>
> > > 
> > > 		console_unlock();
> > 
> > Which I think we should stop, with the preempt_disable().
> 
> Adding the preempt_disable() basically means to revert the already
> mentioned commit 6b97a20d3a7909daa06625 ("printk: set may_schedule
> for some of console_trylock() callers").
> 
> I originally wanted to solve this separately to make it easier. But
> the change looks fine to me. Therefore we reached a mutual agreement.
> Sergey, do you want to send a patch or should I just put it at
> the end of this patchset?

you can add the patch.

[..]
> > I think adding the preempt_disable() would fix printk() but let non
> > printk console_unlock() still preempt.
> 
> I would personally remove cond_resched() from console_unlock()
> completely.

hmm, not so sure. I think it's there for !PREEMPT systems which have
to print a lot of messages. the case I'm speaking about in particular
is when we register a CON_PRINTBUFFER console and need to console_unlock()
(flush) all of the messages we currently have in the logbuf. we better
have that cond_resched() there, I think.

> Sleeping in console_unlock() increases the chance that more messages
> would need to be handled. And more importantly it reduces the chance
> of a successful handover.
> 
> As a result, the caller might spend there very long time, it might
> be getting increasingly far behind. There is higher risk of lost
> messages. Also the eventual taker might have too much to proceed
> in preemption disabled context.

yes.

> Removing cond_resched() is in sync with printk() priorities.

hmm, not sure. we have sleeping console_lock()->console_unlock() path
for PREEMPT kernels, that cond_resched() makes the !PREEMPT kernels to
have the same sleeping console_lock()->console_unlock().

printk()->console_unlock() seems to be a pretty independent thing,
unfortunately (!), yet sleeping console_lock()->console_unlock()
messes up with it a lot.

> The highest one is to get the messages out.
> 
> Finally, removing cond_resched() should make the behavior more
> predictable (never preempted)

but we are always preempted in PREEMPT kernels when the current
console_sem owner acquired the lock via console_lock(), not via
console_trylock(). cond_resched() does the same, but for !PREEMPT.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
