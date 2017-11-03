Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 36F536B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 07:21:27 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id i38so7639184iod.10
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 04:21:27 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0139.hostedemail.com. [216.40.44.139])
        by mx.google.com with ESMTPS id v74si2227020itc.100.2017.11.03.04.21.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 04:21:26 -0700 (PDT)
Date: Fri, 3 Nov 2017 07:21:21 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v3] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171103072121.3c2fd5ab@vmware.local.home>
In-Reply-To: <9f3bbbab-ef58-a2a6-d4c5-89e62ade34f8@nvidia.com>
References: <20171102134515.6eef16de@gandalf.local.home>
	<82a3df5e-c8ad-dc41-8739-247e5034de29@suse.cz>
	<9f3bbbab-ef58-a2a6-d4c5-89e62ade34f8@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

On Thu, 2 Nov 2017 21:09:32 -0700
John Hubbard <jhubbard@nvidia.com> wrote:

> On 11/02/2017 03:16 PM, Vlastimil Babka wrote:
> > On 11/02/2017 06:45 PM, Steven Rostedt wrote:  
> > ...>  	__DEVKMSG_LOG_BIT_ON = 0,
> >>  	__DEVKMSG_LOG_BIT_OFF,
> >> @@ -1753,8 +1760,56 @@ asmlinkage int vprintk_emit(int facility
> >>  		 * semaphore.  The release will print out buffers and wake up
> >>  		 * /dev/kmsg and syslog() users.
> >>  		 */
> >> -		if (console_trylock())
> >> +		if (console_trylock()) {
> >>  			console_unlock();
> >> +		} else {
> >> +			struct task_struct *owner = NULL;
> >> +			bool waiter;
> >> +			bool spin = false;
> >> +
> >> +			printk_safe_enter_irqsave(flags);
> >> +
> >> +			raw_spin_lock(&console_owner_lock);
> >> +			owner = READ_ONCE(console_owner);
> >> +			waiter = READ_ONCE(console_waiter);
> >> +			if (!waiter && owner && owner != current) {
> >> +				WRITE_ONCE(console_waiter, true);
> >> +				spin = true;
> >> +			}
> >> +			raw_spin_unlock(&console_owner_lock);
> >> +
> >> +			/*
> >> +			 * If there is an active printk() writing to the
> >> +			 * consoles, instead of having it write our data too,
> >> +			 * see if we can offload that load from the active
> >> +			 * printer, and do some printing ourselves.
> >> +			 * Go into a spin only if there isn't already a waiter
> >> +			 * spinning, and there is an active printer, and
> >> +			 * that active printer isn't us (recursive printk?).
> >> +			 */
> >> +			if (spin) {
> >> +				/* We spin waiting for the owner to release us */
> >> +				spin_acquire(&console_owner_dep_map, 0, 0, _THIS_IP_);
> >> +				/* Owner will clear console_waiter on hand off */
> >> +				while (!READ_ONCE(console_waiter))  
> > 
> > This should not be negated, right? We should spin while it's true, not
> > false.
> >   
> 
> Vlastimil's right about the polarity problem above, but while I was trying
> to verify that, I noticed another problem: the "handoff" of the console lock
> is broken.
> 
> For example, if there are 3 or more threads, you can do the following:
> 
> thread A: holds the console lock, is printing, then moves into the console_unlock
>           phase
> 
> thread B: goes into the waiter spin loop above, and (once the polarity is corrected)
>           waits for console_waiter to become 0
> 
> thread A: finishing up, sets console_waiter --> 0
> 
> thread C: before thread B notices, thread C goes into the "else" section, sees that
>           console_waiter == 0, and sets console_waiter --> 1. So thread C now
>           becomes the waiter

But console_waiter only gets set to 1 if console_waiter is 0 *and*
console_owner is not NULL and is not current. console_owner is only
updated under a spin lock and console_waiter is only set under a spin
lock when console_owner is not NULL.

This means this scenario can not happen.


> 
> thread B: gets *very* unlucky and never sees the 1 --> 0 --> 1 transition of
>           console_waiter, so it continues waiting.  And now we have both B
>           and C in the same spin loop, and this is now broken.
> 
> At the root, this is really due to the absence of a pre-existing "hand-off this lock"
> mechanism. And this one here is not quite correct.
> 
> Solution ideas: for a true hand-off, there needs to be a bit more information
> exchanged. Conceptually, a (lock-protected) list of waiters (which would 
> only ever have zero or one entries) is a good way to start thinking about it.

As stated above, the console owner check will prevent this issue.

-- Steve

> 
> I talked it over with Mark Hairgrove here, he suggested a more sophisticated
> way of doing that sort of hand-off, using compare-and-exchange. I can turn that
> into a patch if you like (I'm not as fast as some folks, so I didn't attempt to
> do that right away), although I'm sure you have lots of ideas on how to do it.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
