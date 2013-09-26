Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4497F6B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 12:21:27 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id lf10so1524600pab.31
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:21:26 -0700 (PDT)
Date: Thu, 26 Sep 2013 18:14:26 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130926161426.GA14372@redhat.com>
References: <20130923173203.GA20392@redhat.com> <20130924202423.GW12926@twins.programming.kicks-ass.net> <20130925155515.GA17447@redhat.com> <20130925174307.GA3220@laptop.programming.kicks-ass.net> <20130925175055.GA25914@redhat.com> <20130925184015.GC3657@laptop.programming.kicks-ass.net> <20130925212200.GA7959@linux.vnet.ibm.com> <20130926111042.GS3081@twins.programming.kicks-ass.net> <20130926155321.GA4342@redhat.com> <20130926161311.GG3657@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130926161311.GG3657@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On 09/26, Peter Zijlstra wrote:
>
> On Thu, Sep 26, 2013 at 05:53:21PM +0200, Oleg Nesterov wrote:
> > On 09/26, Peter Zijlstra wrote:
> > >  void cpu_hotplug_done(void)
> > >  {
> > > -	cpu_hotplug.active_writer = NULL;
> > > -	mutex_unlock(&cpu_hotplug.lock);
> > > +	/* Signal the writer is done, no fast path yet. */
> > > +	__cpuhp_state = readers_slow;
> > > +	wake_up_all(&cpuhp_readers);
> > > +
> > > +	/*
> > > +	 * The wait_event()/wake_up_all() prevents the race where the readers
> > > +	 * are delayed between fetching __cpuhp_state and blocking.
> > > +	 */
> > > +
> > > +	/* See percpu_up_write(); readers will no longer attempt to block. */
> > > +	synchronize_sched();
> >
> > Shouldn't you move wake_up_all(&cpuhp_readers) down after
> > synchronize_sched() (or add another one) ? To ensure that a reader can't
> > see state = BLOCK after wakeup().
>
> Well, if they are blocked, the wake_up_all() will do an actual
> try_to_wake_up() which issues a MB as per smp_mb__before_spinlock().

Yes. Everything is fine with the already blocked readers.

I meant the new reader which still can see state = BLOCK after we
do wakeup(), but I didn't notice it should do __wait_event() which
takes the lock unconditionally, it must see the change after that.

> Right?

Yes, I was wrong, thanks.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
