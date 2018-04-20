Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58FEF6B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:17:56 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id d13so4720535pfn.21
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 07:17:56 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e17si4949767pgr.475.2018.04.20.07.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 07:17:54 -0700 (PDT)
Date: Fri, 20 Apr 2018 10:17:51 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180420101751.6c1c70e8@gandalf.local.home>
In-Reply-To: <20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
References: <20180413124704.19335-1-pmladek@suse.com>
	<20180413101233.0792ebf0@gandalf.local.home>
	<20180414023516.GA17806@tigerII.localdomain>
	<20180416014729.GB1034@jagdpanzerIV>
	<20180416042553.GA555@jagdpanzerIV>
	<20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
	<20180420021511.GB6397@jagdpanzerIV>
	<20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
	<20180420080428.622a8e7f@gandalf.local.home>
	<20180420140157.2nx5nkojj7l2y7if@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Fri, 20 Apr 2018 16:01:57 +0200
Petr Mladek <pmladek@suse.com> wrote:

> On Fri 2018-04-20 08:04:28, Steven Rostedt wrote:
> > On Fri, 20 Apr 2018 11:12:24 +0200
> > Petr Mladek <pmladek@suse.com> wrote:
> >   
> > > Yes, my number was arbitrary. The important thing is that it was long
> > > enough. Or do you know about an console that will not be able to write
> > > 100 lines within one hour?  
> > 
> > The problem is the way rate limit works. If you print 100 lines (or
> > 1000) in 5 seconds, then you just stopped printing from that context
> > for 59 minutes and 55 seconds. That's a long time to block printing.  
> 
> Are we talking about the same context?
> 
> I am talking about console drivers called from console_unlock(). It is
> very special context because it is more or less recursive:
> 
>      + could cause infinite loop
>      + the errors are usually the same again and again

The check is only when console_owner == current, which can easily
happen with an interrupt let alone an NMI.

The common case is not recursive.

> 
> As a result, if you get too many messages from this context:
> 
>      + you are lost (recursion)
>      + more messages != new information
> 
> And you need to fix the problem anyway. Otherwise, the system
> logging is a mess.
> 
> 
> > What happens if you had a couple of NMIs go off that takes up that
> > time, and then you hit a bug 10 minutes later from that context. You
> > just lost it.  
> 
> I do not understand how this is related to the NMI context.
> The messages in NMI context are not throttled!
> 
> OK, the original patch throttled also NMI messages when NMI
> interrupted console drivers. But it is easy to fix.

My mistake in just mentioning NMIs, because the check is on
console_owner which can be set with interrupts enabled. That means an
interrupt that does a print could hide printks from other interrupts or
NMIs when console_owner is set.

> 
> 
> > This is a magnitude larger than any other user of rate limit in the
> > kernel. The most common time is 5 seconds. The longest I can find is 1
> > minute. You are saying you want to block printing from this context for
> > 60 minutes!  
> 
> I see 1 day long limits in dio_warn_stale_pagecache() and
> xfs_scrub_experimental_warning().
> 
> Note that most ratelimiting is related to a single message. Also it
> is in situation where the system should recover within seconds.
> 
> 
> > That is HUGE! I don't understand your rational for such a huge number.
> > What data do you have to back that up with?  
> 
> We want to allow seeing the entire lockdep splat (Sergey wants more
> than 100 lines). Also it is not that unusual that slow console is busy
> several minutes when too many things are happening.
> 
> I proposed that long delay because I want to be on the safe side.
> Also I do not see a huge benefit in repeating the same messages
> too often.
> 
> Alternative solution would be to allow first, lets say 250, lines
> and then nothing. I mean to change the approach from rate-limiting
> to print-once.


Actually, I think we are fine with the one hour and 1000 prints if we
add to the condition. It can't just check console_owner. We need a way
to know that this is indeed a recursion. Perhaps we should set the
context we are in when setting console owner. Something like I have in
the ring buffer code.

enum {
	CONTEXT_NONE,
	CONTEXT_NMI,
	CONTEXT_IRQ,
	CONTEXT_SOFTIRQ,
	CONTEXT_NORMAL
};

int git_context(void)
{
	unsigned long pc = preempt_count();

	if (!(pc & (NMI_MASK | HARDIRQ_MASK | SOFTIRQ_OFFSET)))
		return CONTEXT_NORMAL;
	else
		return pc & NMI_MASK ? CONTEXT_NMI :
			pc & HARDIRQ_MASK ? CONTEXT_IRQ : CONTEXT_SOFTIRQ;
}

static void console_lock_spinning_enable(void)
{
	raw_spin_lock(&console_owner_lock);
	console_owner = current;
	console_context = get_context();
	raw_spin_unlock(&console_owner_lock);
[..]


static int console_lock_spinning_disable_and_check(void)
{
	raw_spin_lock(&console_owner_lock);
	waiter = READ_ONCE(console_waiter);
	console_owner = NULL;
	console_context = CONTEXT_NONE;
	raw_spin_unlock(&console_owner_lock);
[..]


Then have your check be:

+	/* Prevent infinite loop caused by messages from console drivers. */
+	if (console_owner == current && console_context == get_context() &&
+	    !__ratelimit(&ratelimit_console))
+		return 0;

Then you know that this is definitely due to recursion.

-- Steve
