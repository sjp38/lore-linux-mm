Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43ECB6B0268
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 07:50:14 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id o11so954817pgp.14
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 04:50:14 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n6si11993447pla.565.2018.01.10.04.50.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 Jan 2018 04:50:13 -0800 (PST)
Date: Wed, 10 Jan 2018 13:50:04 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20180110125004.GC13631@linux.suse>
References: <20171108102723.602216b1@gandalf.local.home>
 <20171222102927.eiunret5ykx55bvq@pathway.suse.cz>
 <20171222074426.5df24526@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171222074426.5df24526@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org

On Fri 2017-12-22 07:44:26, Steven Rostedt wrote:
> On Fri, 22 Dec 2017 11:31:31 +0100
> Petr Mladek <pmladek@suse.com> wrote:
> 
> > > Index: linux-trace.git/kernel/printk/printk.c
> > > ===================================================================
> > > --- linux-trace.git.orig/kernel/printk/printk.c
> > > +++ linux-trace.git/kernel/printk/printk.c
> > > @@ -2141,6 +2196,7 @@ void console_unlock(void)
> > >  	static u64 seen_seq;
> > >  	unsigned long flags;
> > >  	bool wake_klogd = false;
> > > +	bool waiter = false;
> > >  	bool do_cond_resched, retry;
> > >  
> > >  	if (console_suspended) {
> > > @@ -2229,14 +2285,64 @@ skip:
> > >  		console_seq++;
> > >  		raw_spin_unlock(&logbuf_lock);
> > >  
> > > +		/*
> > > +		 * While actively printing out messages, if another printk()
> > > +		 * were to occur on another CPU, it may wait for this one to
> > > +		 * finish. This task can not be preempted if there is a
> > > +		 * waiter waiting to take over.
> > > +		 */
> > > +		raw_spin_lock(&console_owner_lock);
> > > +		console_owner = current;
> > > +		raw_spin_unlock(&console_owner_lock);  
> > 
> > One idea. We could do the above only when "do_cond_resched" is false.
> > I mean that we could allow stealing the console duty only from
> > atomic context.
> 
> I'd like to hold off before making a change like that. I thought about
> it, but by saying "atomic" is more important than "non-atomic" can also
> lead to problems. Once you don't allow stealing, you just changed
> printk to be unbounded again. Maybe that's not an issue. But I'd rather
> add that as an enhancement in case. I could make this a patch series,
> and we can build cases like this up.

I see the point. It might reduce the chance of the handshake and
load balancing. Let's avoid it for now.

> > 
> > If I get it correctly, this variable is always true in schedulable
> > context.
> > 
> > > +
> > > +		/* The waiter may spin on us after setting console_owner */
> > > +		spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> > > +
> > >  		stop_critical_timings();	/* don't trace print latency */
> > >  		call_console_drivers(ext_text, ext_len, text, len);
> > >  		start_critical_timings();
> > > +
> > > +		raw_spin_lock(&console_owner_lock);
> > > +		waiter = READ_ONCE(console_waiter);
> > > +		console_owner = NULL;
> > > +		raw_spin_unlock(&console_owner_lock);
> > > +
> > > +		/*
> > > +		 * If there is a waiter waiting for us, then pass the
> > > +		 * rest of the work load over to that waiter.
> > > +		 */
> > > +		if (waiter)
> > > +			break;
> > > +
> > > +		/* There was no waiter, and nothing will spin on us here */
> > > +		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> > > +
> > >  		printk_safe_exit_irqrestore(flags);
> > >  
> > >  		if (do_cond_resched)
> > >  			cond_resched();  
> > 
> > On the contrary, we could allow steeling the console semaphore
> > when sleeping here. It would allow to get the messages out
> > faster. It might help to move the duty to someone who is
> > actually producing many messages or even the panic() caller.
> 
> Good point. I'll add a patch that adds that feature too.

Ah, it would require a bit different logic. The waiter would need
to take the lock immediately. The current/owner would need to detect
that she lost the lock once she wakes up. It would make sense
to support yet another passing of the lock even before the first
owner wakes up.

All this is doable but not that easy. We might and should try
it later only if the current solution is not enough.

Best Regards,
Petr

PS: I am about to sent a clean up on top of Steven's patch.
I offered this to Steven before Christmas. Unfortunately
it got delayed by the holidays, another urgent work and sickness.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
