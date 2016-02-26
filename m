Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 250796B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 10:38:22 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id a4so74886333wme.1
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 07:38:22 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r8si16592433wjq.3.2016.02.26.07.38.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Feb 2016 07:38:21 -0800 (PST)
Date: Fri, 26 Feb 2016 16:38:18 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 08/20] kthread: Allow to cancel kthread work
Message-ID: <20160226153818.GI3305@pathway.suse.cz>
References: <1456153030-12400-9-git-send-email-pmladek@suse.com>
 <201602230025.uuCAc4Tn%fengguang.wu@intel.com>
 <20160224161805.GB3305@pathway.suse.cz>
 <20160225125932.GI6357@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160225125932.GI6357@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 2016-02-25 13:59:32, Peter Zijlstra wrote:
> On Wed, Feb 24, 2016 at 05:18:05PM +0100, Petr Mladek wrote:
> > @@ -770,7 +782,22 @@ void delayed_kthread_work_timer_fn(unsigned long __data)
> >  	if (WARN_ON_ONCE(!worker))
> >  		return;
> >  
> > -	spin_lock(&worker->lock);
> > +	/*
> > +	 * We might be unable to take the lock if someone is trying to
> > +	 * cancel this work and calls del_timer_sync() when this callback
> > +	 * has already been removed from the timer list.
> > +	 */
> > +	while (!spin_trylock(&worker->lock)) {
> > +		/*
> > +		 * Busy wait with spin_is_locked() to avoid cache bouncing.
> > +		 * Break when canceling is set to avoid a deadlock.
> > +		 */
> > +		do {
> > +			if (work->canceling)
> > +				return;
> > +			cpu_relax();
> > +		} while (spin_is_locked(&worker->lock));
> > +	}
> >  	/* Work must not be used with more workers, see queue_kthread_work(). */
> >  	WARN_ON_ONCE(work->worker != worker);
> >  
> 
> This is pretty vile; why can't you drop the lock over del_timer_sync() ?

We would need to take the lock later and check if nobody has set the timer
again in the meantime.

Now, timer_active() check is not reliable. It does not check if the
timer handler is running at the moment. I tried to implement
a safe timer_active()[1] but nobody was keen to take it.

Even if we have that timer_active() check, we would need to add
some relock/check/try_again stuff around the del_timer_sync().
So, it would just move the complexity somewhere else.

I think that the current solution is quite elegant after all.
Thanks a lot Tejun for the idea.

Reference:
[1] http://thread.gmane.org/gmane.linux.kernel.mm/144964/focus=144965


Thanks a lot for review,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
