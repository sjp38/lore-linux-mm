Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8A96B2BEB
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 11:02:53 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id s50so4682781edd.11
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:02:53 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g14si12009348edy.160.2018.11.22.08.02.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 08:02:51 -0800 (PST)
Date: Thu, 22 Nov 2018 17:02:50 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v2 07/17] debugobjects: Move printk out of db lock
 critical sections
Message-ID: <20181122160250.lxyfzsybfwskrh54@pathway.suse.cz>
References: <1542653726-5655-1-git-send-email-longman@redhat.com>
 <1542653726-5655-8-git-send-email-longman@redhat.com>
 <2ddd9e3d-951e-1892-c941-54be80f7e6aa@redhat.com>
 <20181122020422.GA3441@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122020422.GA3441@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 2018-11-22 11:04:22, Sergey Senozhatsky wrote:
> On (11/21/18 11:49), Waiman Long wrote:
> [..]
> > >  	case ODEBUG_STATE_ACTIVE:
> > > -		debug_print_object(obj, "init");
> > >  		state = obj->state;
> > >  		raw_spin_unlock_irqrestore(&db->lock, flags);
> > > +		debug_print_object(obj, "init");
> > >  		debug_object_fixup(descr->fixup_init, addr, state);
> > >  		return;
> > >  
> > >  	case ODEBUG_STATE_DESTROYED:
> > > -		debug_print_object(obj, "init");
> > > +		debug_printobj = true;
> > >  		break;
> > >  	default:
> > >  		break;
> > >  	}
> > >  
> > >  	raw_spin_unlock_irqrestore(&db->lock, flags);
> > > +	if (debug_chkstack)
> > > +		debug_object_is_on_stack(addr, onstack);
> > > +	if (debug_printobj)
> > > +		debug_print_object(obj, "init");
> > >
> [..]
> >
> > As a side note, one of the test systems that I used generated a
> > debugobjects splat in the bootup process and the system hanged
> > afterward. Applying this patch alone fix the hanging problem and the
> > system booted up successfully. So it is not really a good idea to call
> > printk() while holding a raw spinlock.

Please, was the system hang reproducible? I wonder if it was a
deadlock described by Sergey below.

The commit message is right. printk() might take too long and
cause softlockup or livelock. But it does not explain why
the system could competely hang.

Also note that prinkt() should not longer block a single process
indefinitely thanks to the commit dbdda842fe96f8932 ("printk:
Add console owner and waiter logic to load balance console writes").

> Some serial consoles call mod_timer(). So what we could have with the
> debug objects enabled was
> 
> 	mod_timer()
> 	 lock_timer_base()
> 	  debug_activate()
> 	   printk()
> 	    call_console_drivers()
> 	     foo_console()
> 	      mod_timer()
> 	       lock_timer_base()       << deadlock

Anyway, I wonder what was the primary motivation for this patch.
Was it the system hang? Or was it lockdep report about nesting
two terminal locks: db->lock, pool_lock with logbuf_lock?

Printk is problematic. It might delay any atomic context
where it is used. I would like to better understand the
problem here before we start spread printk-related hacks.

Best Regards,
Petr
