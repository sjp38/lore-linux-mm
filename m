Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id B3A236B0005
	for <linux-mm@kvack.org>; Sat, 27 Feb 2016 10:16:44 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p65so19579727wmp.1
        for <linux-mm@kvack.org>; Sat, 27 Feb 2016 07:16:44 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id 200si10225210wms.27.2016.02.27.07.16.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Feb 2016 07:16:43 -0800 (PST)
Date: Sat, 27 Feb 2016 16:16:36 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v5 08/20] kthread: Allow to cancel kthread work
Message-ID: <20160227151636.GF6356@twins.programming.kicks-ass.net>
References: <1456153030-12400-9-git-send-email-pmladek@suse.com>
 <201602230025.uuCAc4Tn%fengguang.wu@intel.com>
 <20160224161805.GB3305@pathway.suse.cz>
 <20160225125932.GI6357@twins.programming.kicks-ass.net>
 <20160226153818.GI3305@pathway.suse.cz>
 <20160226162552.GB6356@twins.programming.kicks-ass.net>
 <20160226170056.GA12548@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160226170056.GA12548@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Feb 26, 2016 at 06:00:56PM +0100, Petr Mladek wrote:
> On Fri 2016-02-26 17:25:52, Peter Zijlstra wrote:
> > On Fri, Feb 26, 2016 at 04:38:18PM +0100, Petr Mladek wrote:
> > > On Thu 2016-02-25 13:59:32, Peter Zijlstra wrote:
> > > > On Wed, Feb 24, 2016 at 05:18:05PM +0100, Petr Mladek wrote:
> > > > > @@ -770,7 +782,22 @@ void delayed_kthread_work_timer_fn(unsigned long __data)
> > > > >  	if (WARN_ON_ONCE(!worker))
> > > > >  		return;
> > > > >  
> > > > > -	spin_lock(&worker->lock);
> > > > > +	/*
> > > > > +	 * We might be unable to take the lock if someone is trying to
> > > > > +	 * cancel this work and calls del_timer_sync() when this callback
> > > > > +	 * has already been removed from the timer list.
> > > > > +	 */
> > > > > +	while (!spin_trylock(&worker->lock)) {
> > > > > +		/*
> > > > > +		 * Busy wait with spin_is_locked() to avoid cache bouncing.
> > > > > +		 * Break when canceling is set to avoid a deadlock.
> > > > > +		 */
> > > > > +		do {
> > > > > +			if (work->canceling)
> > > > > +				return;
> > > > > +			cpu_relax();
> > > > > +		} while (spin_is_locked(&worker->lock));
> > > > > +	}
> > > > >  	/* Work must not be used with more workers, see queue_kthread_work(). */
> > > > >  	WARN_ON_ONCE(work->worker != worker);

> > And since you do add_timer() while holding the spinlock, this should all
> > work out, no?
> 
> Interesting idea. Yes, it should work. But is this really easier? The
> try_again/relock/recheck code is not trivial either.

The trylock loop has very bad worst case behaviour, it really is best to
avoid such patterns if at all possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
