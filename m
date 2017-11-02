Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 695606B025E
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 05:14:38 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e64so4747519pfk.0
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 02:14:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor698420pgc.136.2017.11.02.02.14.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 02:14:37 -0700 (PDT)
Date: Thu, 2 Nov 2017 18:14:32 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
Message-ID: <20171102091432.GE655@jagdpanzerIV>
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171031153225.218234b4@gandalf.local.home>
 <20171102085313.GD655@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171102085313.GD655@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On (11/02/17 17:53), Sergey Senozhatsky wrote:
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
> 
> 
> even if we would replace spin_lock(console_owner_lock) with IRQ
> spin_lock, we still would need to protect against IRQs on the very
> same CPU. right? IOW, we need to store smp_processor_id() of a CPU
> currently doing console_unlock() and check it in vprintk_emit()?


a major self-correction:

> and we need to protect the entire console_unlock() function. not
> just the printing loop, otherwise the IRQ CPU will spin forever
> waiting for itself to up() the console_sem.

this part is wrong. should have been
	"we need to protect the entire printing loop"


so now console_unlock()'s printing loop is going to run

a) under preempt_disable()
b) under local_irq_save()

which is risky.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
