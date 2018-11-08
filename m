Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C53906B058C
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 23:45:16 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id d11-v6so254823plo.17
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 20:45:16 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q14-v6sor3215710pgv.63.2018.11.07.20.45.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Nov 2018 20:45:15 -0800 (PST)
Date: Thu, 8 Nov 2018 13:45:10 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Message-ID: <20181108044510.GC2343@jagdpanzerIV>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

On (11/07/18 16:19), Petr Mladek wrote:
> > syzbot is sometimes getting mixed output like below due to concurrent
> > printk(). Mitigate such output by using line-buffered printk() API.
> > 
> > @@ -2421,18 +2458,20 @@ static void check_chain_key(struct task_struct *curr)
> >  print_usage_bug_scenario(struct held_lock *lock)
> >  {
> >  	struct lock_class *class = hlock_class(lock);
> > +	struct printk_buffer *buf = get_printk_buffer();
> >  
> >  	printk(" Possible unsafe locking scenario:\n\n");
> >  	printk("       CPU0\n");
> >  	printk("       ----\n");
> > -	printk("  lock(");
> > -	__print_lock_name(class);
> > -	printk(KERN_CONT ");\n");
> > +	printk_buffered(buf, "  lock(");
> > +	__print_lock_name(class, buf);
> > +	printk_buffered(buf, ");\n");
> >  	printk("  <Interrupt>\n");
> > -	printk("    lock(");
> > -	__print_lock_name(class);
> > -	printk(KERN_CONT ");\n");
> > +	printk_buffered(buf, "    lock(");
> > +	__print_lock_name(class, buf);
> > +	printk_buffered(buf, ");\n");
> >  	printk("\n *** DEADLOCK ***\n\n");
> > +	put_printk_buffer(buf);
> >  }
> >  
> >  static int
> 
> I really hope that the maze of pr_cont() calls in lockdep.c is the most
> complicated one that we would meet.

Hmm... Yes, buffered/seq_buf printk looks like a hard-to-use API,
when it comes to real world cases like this.

So... here is a random and wild idea.

We actually already have an easy-to-use buffered printk. And it's per-CPU.
And it makes all printk-s on this CPU to behave like as if they were called
on UP system. And it cures pr_cont(). And it doesn't require anyone to learn
any new printk API names. And it doesn't require any additional maintenance
work. And it doesn't require any printk->buffered_printk conversions. And
it's already in the kernel. And we gave it a name. And it's printk_safe.

a) lockdep reporting path should be atomic. And it's not a hot path,
   so local_irq_save/local_irq_restore will not cause a lot of trouble
   there probably.

b) We already have some lockdep reports coming via printk_safe.
   All those
	printk->console_driver->scheduler->lockdep
	printk->console_driver->timekeeping->lockdep
	etc.

   came via printk_safe path. So it's not a complete novelty.

c) printk_safe sections can nest.

d) No premature flushes. Everything looks the way it was supposed to
   look.

e) There are no out-of-line printk-s. We keep the actual order of events.

f) We flush it on panic.

g) Low maintenance costs.

So, can we just do the following? /* a sketch */

lockdep.c
	printk_safe_enter_irqsave(flags);
	lockdep_report();
	printk_safe_exit_irqrestore(flags);

	-ss
