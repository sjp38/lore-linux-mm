Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 829196B0253
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 07:44:31 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t65so20153456pfe.22
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 04:44:31 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t10si16646074plh.762.2017.12.22.04.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Dec 2017 04:44:30 -0800 (PST)
Date: Fri, 22 Dec 2017 07:44:26 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171222074426.5df24526@gandalf.local.home>
In-Reply-To: <20171222102927.eiunret5ykx55bvq@pathway.suse.cz>
References: <20171108102723.602216b1@gandalf.local.home>
	<20171222102927.eiunret5ykx55bvq@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org

On Fri, 22 Dec 2017 11:31:31 +0100
Petr Mladek <pmladek@suse.com> wrote:

> > Index: linux-trace.git/kernel/printk/printk.c
> > ===================================================================
> > --- linux-trace.git.orig/kernel/printk/printk.c
> > +++ linux-trace.git/kernel/printk/printk.c
> > @@ -2141,6 +2196,7 @@ void console_unlock(void)
> >  	static u64 seen_seq;
> >  	unsigned long flags;
> >  	bool wake_klogd = false;
> > +	bool waiter = false;
> >  	bool do_cond_resched, retry;
> >  
> >  	if (console_suspended) {
> > @@ -2229,14 +2285,64 @@ skip:
> >  		console_seq++;
> >  		raw_spin_unlock(&logbuf_lock);
> >  
> > +		/*
> > +		 * While actively printing out messages, if another printk()
> > +		 * were to occur on another CPU, it may wait for this one to
> > +		 * finish. This task can not be preempted if there is a
> > +		 * waiter waiting to take over.
> > +		 */
> > +		raw_spin_lock(&console_owner_lock);
> > +		console_owner = current;
> > +		raw_spin_unlock(&console_owner_lock);  
> 
> One idea. We could do the above only when "do_cond_resched" is false.
> I mean that we could allow stealing the console duty only from
> atomic context.

I'd like to hold off before making a change like that. I thought about
it, but by saying "atomic" is more important than "non-atomic" can also
lead to problems. Once you don't allow stealing, you just changed
printk to be unbounded again. Maybe that's not an issue. But I'd rather
add that as an enhancement in case. I could make this a patch series,
and we can build cases like this up.

> 
> If I get it correctly, this variable is always true in schedulable
> context.
> 
> > +
> > +		/* The waiter may spin on us after setting console_owner */
> > +		spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> > +
> >  		stop_critical_timings();	/* don't trace print latency */
> >  		call_console_drivers(ext_text, ext_len, text, len);
> >  		start_critical_timings();
> > +
> > +		raw_spin_lock(&console_owner_lock);
> > +		waiter = READ_ONCE(console_waiter);
> > +		console_owner = NULL;
> > +		raw_spin_unlock(&console_owner_lock);
> > +
> > +		/*
> > +		 * If there is a waiter waiting for us, then pass the
> > +		 * rest of the work load over to that waiter.
> > +		 */
> > +		if (waiter)
> > +			break;
> > +
> > +		/* There was no waiter, and nothing will spin on us here */
> > +		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> > +
> >  		printk_safe_exit_irqrestore(flags);
> >  
> >  		if (do_cond_resched)
> >  			cond_resched();  
> 
> On the contrary, we could allow steeling the console semaphore
> when sleeping here. It would allow to get the messages out
> faster. It might help to move the duty to someone who is
> actually producing many messages or even the panic() caller.

Good point. I'll add a patch that adds that feature too.

Thanks!

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
