Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56AD26B0055
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:57:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a6so4792500pfn.3
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 07:57:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v201si4867615pgb.295.2018.04.20.07.57.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Apr 2018 07:57:24 -0700 (PDT)
Date: Fri, 20 Apr 2018 16:57:20 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180420145720.hb7bbyd5xbm5je32@pathway.suse.cz>
References: <20180413101233.0792ebf0@gandalf.local.home>
 <20180414023516.GA17806@tigerII.localdomain>
 <20180416014729.GB1034@jagdpanzerIV>
 <20180416042553.GA555@jagdpanzerIV>
 <20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
 <20180420021511.GB6397@jagdpanzerIV>
 <20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
 <20180420080428.622a8e7f@gandalf.local.home>
 <20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
 <20180420101751.6c1c70e8@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420101751.6c1c70e8@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri 2018-04-20 10:17:51, Steven Rostedt wrote:
> On Fri, 20 Apr 2018 16:01:57 +0200
> Petr Mladek <pmladek@suse.com> wrote:
> > On Fri 2018-04-20 08:04:28, Steven Rostedt wrote:
> > > The problem is the way rate limit works. If you print 100 lines (or
> > > 1000) in 5 seconds, then you just stopped printing from that context
> > > for 59 minutes and 55 seconds. That's a long time to block printing.  
> > 
> > Are we talking about the same context?
> > 
> > I am talking about console drivers called from console_unlock(). It is
> > very special context because it is more or less recursive:
> > 
> >      + could cause infinite loop
> >      + the errors are usually the same again and again
> 
> The check is only when console_owner == current, which can easily
> happen with an interrupt let alone an NMI.

Yeah. Sergey pointed this out and I suggested to update it
to

	if (console_owner == current && !in_nmi() &&
	    !__ratelimit(&ratelimit_console))
		return 0;

Only messages from console drivers called from console_unlock()
should be ratelimited. Ratelimiting any other messages was not
intended (is a bug).

The above does not handle recursion in NMI. But console drivers
are called from NMI only when we flush consoles in panic().
I wonder if it is worth the effort.


> > > What happens if you had a couple of NMIs go off that takes up that
> > > time, and then you hit a bug 10 minutes later from that context. You
> > > just lost it.  
> > 
> > I do not understand how this is related to the NMI context.
> > The messages in NMI context are not throttled!
> > 
> > OK, the original patch throttled also NMI messages when NMI
> > interrupted console drivers. But it is easy to fix.
> 
> My mistake in just mentioning NMIs, because the check is on
> console_owner which can be set with interrupts enabled. That means an
> interrupt that does a print could hide printks from other interrupts or
> NMIs when console_owner is set.

No, call_console_drivers() is done with interrupts disabled:

		console_lock_spinning_enable();

		stop_critical_timings();	/* don't trace print latency */
 ---->		call_console_drivers(ext_text, ext_len, text, len);
		start_critical_timings();

		if (console_lock_spinning_disable_and_check()) {
 ---->			printk_safe_exit_irqrestore(flags);
			goto out;
		}

 ---->		printk_safe_exit_irqrestore(flags);

They were called with interrupts disabled for ages, long before
printk_safe. In fact, it was all the time in the git kernel history.

Therefore only NMIs are in the game. And they should be solved
by the above change.


> > I proposed that long delay because I want to be on the safe side.
> > Also I do not see a huge benefit in repeating the same messages
> > too often.
> 
> Actually, I think we are fine with the one hour and 1000 prints if we
> add to the condition.

great

> It can't just check console_owner. We need a way
> to know that this is indeed a recursion. Perhaps we should set the
> context we are in when setting console owner. Something like I have in
> the ring buffer code.

> enum {
> 	CONTEXT_NONE,
> 	CONTEXT_NMI,
> 	CONTEXT_IRQ,
> 	CONTEXT_SOFTIRQ,
> 	CONTEXT_NORMAL
> };
> 
> int get_context(void)
> {
> 	unsigned long pc = preempt_count();
> 
> 	if (!(pc & (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_OFFSET)))
> 		return CONTEXT_NORMAL;
> 	else
> 		return pc & NMI_MASK ? CONTEXT_NMI :
> 			pc & HARDIRQ_MASK ? CONTEXT_IRQ : CONTEXT_SOFTIRQ;
> }

We actually would need this only when flushing consoles in NMI in panic().
I am not sure of it is worth the effort.

Best Regards,
Petr
