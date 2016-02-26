Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 965616B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 11:26:01 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id w128so6779621pfb.2
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:26:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id c74si20826460pfj.65.2016.02.26.08.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 08:26:00 -0800 (PST)
Date: Fri, 26 Feb 2016 17:25:52 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 08/20] kthread: Allow to cancel kthread work
Message-ID: <20160226162552.GB6356@twins.programming.kicks-ass.net>
References: <1456153030-12400-9-git-send-email-pmladek@suse.com>
 <201602230025.uuCAc4Tn%fengguang.wu@intel.com>
 <20160224161805.GB3305@pathway.suse.cz>
 <20160225125932.GI6357@twins.programming.kicks-ass.net>
 <20160226153818.GI3305@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160226153818.GI3305@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Feb 26, 2016 at 04:38:18PM +0100, Petr Mladek wrote:
> On Thu 2016-02-25 13:59:32, Peter Zijlstra wrote:
> > On Wed, Feb 24, 2016 at 05:18:05PM +0100, Petr Mladek wrote:
> > > @@ -770,7 +782,22 @@ void delayed_kthread_work_timer_fn(unsigned long __data)
> > >  	if (WARN_ON_ONCE(!worker))
> > >  		return;
> > >  
> > > -	spin_lock(&worker->lock);
> > > +	/*
> > > +	 * We might be unable to take the lock if someone is trying to
> > > +	 * cancel this work and calls del_timer_sync() when this callback
> > > +	 * has already been removed from the timer list.
> > > +	 */
> > > +	while (!spin_trylock(&worker->lock)) {
> > > +		/*
> > > +		 * Busy wait with spin_is_locked() to avoid cache bouncing.
> > > +		 * Break when canceling is set to avoid a deadlock.
> > > +		 */
> > > +		do {
> > > +			if (work->canceling)
> > > +				return;
> > > +			cpu_relax();
> > > +		} while (spin_is_locked(&worker->lock));
> > > +	}
> > >  	/* Work must not be used with more workers, see queue_kthread_work(). */
> > >  	WARN_ON_ONCE(work->worker != worker);
> > >  
> > 
> > This is pretty vile; why can't you drop the lock over del_timer_sync() ?
> 
> We would need to take the lock later and check if nobody has set the timer
> again in the meantime.

Well, if ->cancelling is !0, nobody should be re-queueing, re-arming
timers etc.., right?

And since you do add_timer() while holding the spinlock, this should all
work out, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
