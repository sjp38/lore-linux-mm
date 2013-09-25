Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 718F66B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 13:43:28 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so6441020pdj.1
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:43:28 -0700 (PDT)
Date: Wed, 25 Sep 2013 19:43:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130925174307.GA3220@laptop.programming.kicks-ass.net>
References: <20130917143003.GA29354@twins.programming.kicks-ass.net>
 <20130917162050.GK22421@suse.de>
 <20130917164505.GG12926@twins.programming.kicks-ass.net>
 <20130918154939.GZ26785@twins.programming.kicks-ass.net>
 <20130919143241.GB26785@twins.programming.kicks-ass.net>
 <20130921163404.GA8545@redhat.com>
 <20130923092955.GV9326@twins.programming.kicks-ass.net>
 <20130923173203.GA20392@redhat.com>
 <20130924202423.GW12926@twins.programming.kicks-ass.net>
 <20130925155515.GA17447@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130925155515.GA17447@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

On Wed, Sep 25, 2013 at 05:55:15PM +0200, Oleg Nesterov wrote:
> On 09/24, Peter Zijlstra wrote:
> >
> > So now we drop from a no memory barriers fast path, into a memory
> > barrier 'slow' path into blocking.
> 
> Cough... can't understand the above ;) In fact I can't understand
> the patch... see below. But in any case, afaics the fast path
> needs mb() unless you add another synchronize_sched() into
> cpu_hotplug_done().

Sure we can add more ;-) But I went with perpcu_up_write(), it too does
the sync_sched() before clearing the fast path state.

> > +static inline void get_online_cpus(void)
> > +{
> > +	might_sleep();
> > +
> > +	/* Support reader-in-reader recursion */
> > +	if (current->cpuhp_ref++) {
> > +		barrier();
> > +		return;
> > +	}
> > +
> > +	preempt_disable();
> > +	if (likely(!__cpuhp_writer))
> > +		__this_cpu_inc(__cpuhp_refcount);
> 
> mb() to ensure the reader can't miss, say, a STORE done inside
> the cpu_hotplug_begin/end section.
> 
> put_online_cpus() needs mb() as well.

OK, I'm not getting this; why isn't the sync_sched sufficient to get out
of this fast path without barriers?

> > +void __get_online_cpus(void)
> > +{
> > +	if (__cpuhp_writer == 1) {
> > +		/* See __srcu_read_lock() */
> > +		__this_cpu_inc(__cpuhp_refcount);
> > +		smp_mb();
> > +		__this_cpu_inc(cpuhp_seq);
> > +		return;
> > +	}
> 
> OK, cpuhp_seq should guarantee cpuhp_readers_active_check() gets
> the "stable" numbers. Looks suspicious... but lets assume this
> works.

I 'borrowed' it from SRCU, so if its broken here its broken there too I
suppose.

> However, I do not see how "__cpuhp_writer == 1" can work, please
> see below.
> 
> > +	if (atomic_dec_and_test(&cpuhp_waitcount))
> > +		wake_up_all(&cpuhp_writer);
> 
> Same problem as in previous version. __get_online_cpus() succeeds
> without incrementing __cpuhp_refcount. "goto start" can't help
> afaics.

I added a goto into the cond-block, not before the cond; but see the
version below.

> >  void cpu_hotplug_begin(void)
> >  {
> > +	unsigned int count = 0;
> > +	int cpu;
> >  
> > +	lockdep_assert_held(&cpu_add_remove_lock);
> > +
> > +	/* allow reader-in-writer recursion */
> > +	current->cpuhp_ref++;
> > +
> > +	/* make readers take the slow path */
> > +	__cpuhp_writer = 1;
> > +
> > +	/* See percpu_down_write() */
> > +	synchronize_sched();
> 
> Suppose there are no readers at this point,
> 
> > +
> > +	/* make readers block */
> > +	__cpuhp_writer = 2;
> > +
> > +	/* Wait for all readers to go away */
> > +	wait_event(cpuhp_writer, cpuhp_readers_active_check());
> 
> So wait_event() "quickly" returns.
> 
> Now. Why the new reader should see __cpuhp_writer = 2 ? It can
> still see it == 1, and take that "if (__cpuhp_writer == 1)" path
> above.

OK, .. I see the hole, no immediate way to fix it -- too tired atm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
