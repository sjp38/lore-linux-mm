Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6D5956B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 06:50:21 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id t94so8226045wrc.18
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 03:50:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z52si4826890wrz.317.2018.01.15.03.50.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 03:50:19 -0800 (PST)
Date: Mon, 15 Jan 2018 12:50:13 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180115115013.cyeocszurvguc3xu@pathway.suse.cz>
References: <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180113072834.GA1701@tigerII.localdomain>
 <20180115101743.qh5whicsn6hmac32@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180115101743.qh5whicsn6hmac32@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Mon 2018-01-15 11:17:43, Petr Mladek wrote:
> PS: Sergey, you have many good points. The printk-stuff is very
> complex and we could spend years discussing the perfect solution.

BTW: One solution that comes to my mind is based on ideas
already mentioned in this thread:


void console_unlock(void)
{
	disable_preemtion();

	while(pending_message) {

	    call_console_drivers();

	    if (too_long_here() && current != printk_kthread) {
	       wake_up_process(printk_kthread())

	}

	enable_preemtion();
}

bool too_long_here(void)
{
	return should_resched();
or
	return spent_here() > 1 / HZ / 2;
or
	what ever we agree on
}


int printk_kthread_func(void *data)
{
	while(1) {
		 if (!pending_messaged)
			schedule();

		if (console_trylock_spinning())
			console_unlock();

		cond_resched();
	}
}

It means that console_unlock() will aggressively push messages
with disabled preemption. It will wake up printk_kthread when
it is pushing too long. The printk_kthread would try
to steal the lock and take over the job.

If the system is in reasonable state, printk_kthread should
succeed and avoid softlockup. The offload should be more safe
than a pure wake_up_process().

If printk_kthread is not able to take over the job, it
might suggest that the offload is not safe and the softlockup
is inevitable.

One question is how to avoid softlockup when console_unlock()
is called from printk_kthread. I think that printk_kthread
should release console_lock and call cond_resched from
time to time. It means that the printing will be less
aggressive but anyone could continue flushing the console.
If there are no new messages, it is probably acceptable
to be less aggressive with flushing the messages.


Anyway, this should be more safe than a direct offload
if we agree that getting the messages out is more
important than a possible softlockup.

If this is not enough, I would start thinking about
throttling writers.

Finally, this is all a future work that can be done
and discussed later.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
