Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 19EA46B0033
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 10:55:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v2so5499697pfa.10
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 07:55:18 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u187si3608209pgb.536.2017.11.02.07.55.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 07:55:16 -0700 (PDT)
Date: Thu, 2 Nov 2017 10:55:13 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too
 long
Message-ID: <20171102105513.50f8e29e@gandalf.local.home>
In-Reply-To: <20171102085313.GD655@jagdpanzerIV>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171031153225.218234b4@gandalf.local.home>
	<20171102085313.GD655@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On Thu, 2 Nov 2017 17:53:13 +0900
Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com> wrote:

> On (10/31/17 15:32), Steven Rostedt wrote:
> [..]
> > (new globals)
> > static DEFINE_SPIN_LOCK(console_owner_lock);
> > static struct task_struct console_owner;
> > static bool waiter;
> > 
> > console_unlock() {
> > 
> > [ Assumes this part can not preempt ]
> >
> > 	spin_lock(console_owner_lock);
> > 	console_owner = current;
> > 	spin_unlock(console_owner_lock);  
> 
>  + disables IRQs?

Yes, this was pseudo code, just to get an idea out. I'll have a patch
soon that will include all the nasty details.

> 
> > 	for each message
> > 		write message out to console
> > 
> > 		if (READ_ONCE(waiter))
> > 			break;
> > 
> > 	spin_lock(console_owner_lock);
> > 	console_owner = NULL;
> > 	spin_unlock(console_owner_lock);
> > 
> > [ preemption possible ]  
> 
> otherwise
> 
>      printk()
>       if (console_trylock())
>         console_unlock()
>          preempt_disable()
>           spin_lock(console_owner_lock);
>           console_owner = current;
>           spin_unlock(console_owner_lock);
>           .......
>           spin_lock(console_owner_lock);
> IRQ
>     printk()
>      console_trylock() // fails so we go to busy-loop part
>       spin_lock(console_owner_lock);       << deadlock

Yeah, I do disable interrupts. The pseudo code was just a way to
quickly convey the idea. I said "spin_lock" where I could have just
said "lock".

> 
> 
> even if we would replace spin_lock(console_owner_lock) with IRQ
> spin_lock, we still would need to protect against IRQs on the very
> same CPU. right? IOW, we need to store smp_processor_id() of a CPU
> currently doing console_unlock() and check it in vprintk_emit()?
> and we need to protect the entire console_unlock() function. not
> just the printing loop, otherwise the IRQ CPU will spin forever
> waiting for itself to up() the console_sem.

Yes and it will.

> 
> this somehow reminds me of "static unsigned int logbuf_cpu", which
> we used to have in vprintk_emit() and were happy to remove it...
> 
> 
> the whole "console_unlock() is non-preemptible" can bite, I'm
> afraid. it's not always printk()->console_unlock(), sometimes
> it's console_lock()->console_unlock() that has to flush the
> logbuf.
> 
> CPU0					CPU1  ~  CPU99
> console_lock();
> 					printk(); ... printk();
> console_unlock()
>  preempt_disable();
>   for (;;)
>     call_console_drivers();
>     <<lockup>>
> 
> 
> this pattern is not so unusual. _especially_ in the existing scheme
> of things.
> 
> not to mention the problem of "the last printk()", which will take
> over and do the flush.
> 
> CPU0					CPU1  ~  CPU99
> console_lock();
> 					printk(); ... printk();
> console_unlock();
> 					    IRQ on CPU2
> 					     printk()
> 					      // take over console_sem
> 					      console_unlock()
> 
> and so on.
> seems that there will be lots of if-s.


Let's wait for the patch and talk more after I post it.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
