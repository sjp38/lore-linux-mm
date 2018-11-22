Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5A006B28D0
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 21:04:28 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id l9so11798301plt.7
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 18:04:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p61sor31215390plb.41.2018.11.21.18.04.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Nov 2018 18:04:27 -0800 (PST)
Date: Thu, 22 Nov 2018 11:04:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
Message-ID: <20181122020422.GA3441@jagdpanzerIV>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
 <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On (11/21/18 11:49), Waiman Long wrote:
[..]
> >  	case ODEBUG_STATE_ACTIVE:
> > -		debug_print_object(obj, "init");
> >  		state = obj->state;
> >  		raw_spin_unlock_irqrestore(&db->lock, flags);
> > +		debug_print_object(obj, "init");
> >  		debug_object_fixup(descr->fixup_init, addr, state);
> >  		return;
> >  
> >  	case ODEBUG_STATE_DESTROYED:
> > -		debug_print_object(obj, "init");
> > +		debug_printobj = true;
> >  		break;
> >  	default:
> >  		break;
> >  	}
> >  
> >  	raw_spin_unlock_irqrestore(&db->lock, flags);
> > +	if (debug_chkstack)
> > +		debug_object_is_on_stack(addr, onstack);
> > +	if (debug_printobj)
> > +		debug_print_object(obj, "init");
> >
[..]
>
> As a side note, one of the test systems that I used generated a
> debugobjects splat in the bootup process and the system hanged
> afterward. Applying this patch alone fix the hanging problem and the
> system booted up successfully. So it is not really a good idea to call
> printk() while holding a raw spinlock.

Right, I like this patch.
And I think that we, maybe, can go even further.

Some serial consoles call mod_timer(). So what we could have with the
debug objects enabled was

	mod_timer()
	 lock_timer_base()
	  debug_activate()
	   printk()
	    call_console_drivers()
	     foo_console()
	      mod_timer()
	       lock_timer_base()       << deadlock

That's one possible scenario. The other one can involve console's
IRQ handler, uart port spinlock, mod_timer, debug objects, printk,
and an eventual deadlock on the uart port spinlock. This one can
be mitigated with printk_safe. But mod_timer() deadlock will require
a different fix.

So maybe we need to switch debug objects print-outs to _always_
printk_deferred(). Debug objects can be used in code which cannot
do direct printk() - timekeeping is just one example.

	-ss
