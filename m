Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 77B056B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 12:59:34 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so6235440pbc.39
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 09:59:34 -0700 (PDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 25 Sep 2013 10:59:30 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 6738119D8043
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:59:23 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8PGx8xX358370
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 10:59:12 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8PH2BNr000653
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 11:02:12 -0600
Date: Wed, 25 Sep 2013 09:59:07 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] hotplug: Optimize {get,put}_online_cpus()
Message-ID: <20130925165907.GW9093@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
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
Cc: Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>

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

For whatever it is worth, I too don't see how it works without read-side
memory barriers.

							Thanx, Paul

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
> 
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
> 
> However, I do not see how "__cpuhp_writer == 1" can work, please
> see below.
> 
> > +	/*
> > +	 * XXX list_empty_careful(&cpuhp_readers.task_list) ?
> > +	 */
> > +	if (atomic_dec_and_test(&cpuhp_waitcount))
> > +		wake_up_all(&cpuhp_writer);
> 
> Same problem as in previous version. __get_online_cpus() succeeds
> without incrementing __cpuhp_refcount. "goto start" can't help
> afaics.
> 
> >  void cpu_hotplug_begin(void)
> >  {
> > -	cpu_hotplug.active_writer = current;
> > +	unsigned int count = 0;
> > +	int cpu;
> >  
> > -	for (;;) {
> > -		mutex_lock(&cpu_hotplug.lock);
> > -		if (likely(!cpu_hotplug.refcount))
> > -			break;
> > -		__set_current_state(TASK_UNINTERRUPTIBLE);
> > -		mutex_unlock(&cpu_hotplug.lock);
> > -		schedule();
> > -	}
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
> 
> Oleg.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
